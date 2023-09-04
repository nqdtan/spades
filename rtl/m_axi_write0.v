`include "axi_consts.vh"

// Used for system_sim_socket.tcl
module m_axi_write0 #(
  parameter AXI_AWIDTH = 64,
  parameter AXI_DWIDTH = 64,
  parameter AXI_MAX_BURST_LEN = 256
) (
  input clk,
  input resetn, // active-low reset

  // Write request address channel
  output [3:0]            m_awid,
  output [AXI_AWIDTH-1:0] m_awaddr,
  output                  m_awvalid,
  input                   m_awready,
  output [7:0]            m_awlen,
  output [2:0]            m_awsize,
  output [1:0]            m_awburst,
  // lock, cache, prot, qos, region, user (unused)

  // Write request data channel
  output [3:0]              m_wid,
  output [AXI_DWIDTH-1:0]   m_wdata,
  output                    m_wvalid,
  input                     m_wready,
  output                    m_wlast,
  output [AXI_DWIDTH/8-1:0] m_wstrb,
  // user (unused)

  // Write response channel
  input [3:0] m_bid,
  input [1:0] m_bresp,
  input       m_bvalid,
  output      m_bready,
  // user (unused)

  // Core (client) write interface
  input                   core_write_request_valid,
  output                  core_write_request_ready,
  input  [AXI_AWIDTH-1:0] core_write_addr,
  input  [31:0]           core_write_len,
  input  [2:0]            core_write_size,
  input  [1:0]            core_write_burst,
  input  [AXI_DWIDTH-1:0] core_write_data,
  input                   core_write_data_valid,
  output                  core_write_data_ready,
  output                  core_write_resp_ok
);

  // number of data transfers (beats) = len + 1
  // number of bytes in transfer = 2^size

  wire m_aw_fire    = m_awvalid & m_awready;
  wire m_dw_fire    = m_wvalid  & m_wready;
  wire m_bresp_fire = m_bvalid  & m_bready;

  wire core_write_request_fire = core_write_request_valid & core_write_request_ready;
  wire core_write_data_fire    = core_write_data_valid    & core_write_data_ready;

  localparam NUM_DBYTES = AXI_DWIDTH / 8;

  localparam STATE_AW_IDLE = 0;
  localparam STATE_AW_WAIT = 5;
  localparam STATE_AW_RUN0 = 1;
  localparam STATE_AW_RUN1 = 2;
  localparam STATE_AW_FIX0 = 3;
  localparam STATE_AW_FIX1 = 4;

  localparam STATE_DW_IDLE = 0;
  localparam STATE_DW_RUN  = 1;

  wire [2:0] state_aw_value;
  reg  [2:0] state_aw_next;
  wire state_dw_value;
  reg  state_dw_next;

  REGISTER_R #(.N(3), .INIT(STATE_AW_IDLE)) state_aw_reg (
    .clk(clk),
    .rst(~resetn),
    .d(state_aw_next),
    .q(state_aw_value)
  );

  REGISTER_R #(.N(1), .INIT(STATE_DW_IDLE)) state_dw_reg (
    .clk(clk),
    .rst(~resetn),
    .d(state_dw_next),
    .q(state_dw_value)
  );

  wire [AXI_AWIDTH-1:0] waddr_next, waddr_value;
  wire waddr_ce;
  REGISTER_R_CE #(.N(AXI_AWIDTH), .INIT(0)) waddr_reg (
    .clk(clk),
    .rst(~resetn),
    .d(waddr_next),
    .q(waddr_value),
    .ce(waddr_ce)
  );

  wire [31:0] wlen_next, wlen_value;
  wire wlen_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) wlen_reg (
    .clk(clk),
    .rst(~resetn),
    .d(wlen_next),
    .q(wlen_value),
    .ce(wlen_ce)
  );

  wire [2:0] wsize_next, wsize_value;
  wire wsize_ce;
  REGISTER_R_CE #(.N(3), .INIT(0)) wsize_reg (
    .clk(clk),
    .rst(~resetn),
    .d(wsize_next),
    .q(wsize_value),
    .ce(wsize_ce)
  );

  wire [1:0] wburst_next, wburst_value;
  wire wburst_ce;
  REGISTER_R_CE #(.N(2), .INIT(0)) wburst_reg (
    .clk(clk),
    .rst(~resetn),
    .d(wburst_next),
    .q(wburst_value),
    .ce(wburst_ce)
  );

  wire [7:0] wbeat_cnt_next, wbeat_cnt_value;
  wire wbeat_cnt_ce, wbeat_cnt_rst;
  REGISTER_R_CE #(.N(8), .INIT(0)) wbeat_cnt_reg (
    .clk(clk),
    .rst(wbeat_cnt_rst),
    .d(wbeat_cnt_next),
    .q(wbeat_cnt_value),
    .ce(wbeat_cnt_ce)
  );

  // If a request has a burst length which is greater than the MAX_BURST_LEN,
  // we need to send multiple burst requests one after another to cover the
  // whole burst length
  //
  // e.g. assume len = MAX_BURST_LEN * N + k
  //      req0:     <addr0,  MAX_BURST_LEN>
  //      req1:     <addr0 + {MAX_BURST_LEN << size}, MAX_BURST_LEN>
  //      ...
  //      reqN:     <addr0 + {k << size}, k>

  wire st_aw_idle = (state_aw_value == STATE_AW_IDLE);
  wire st_aw_run0 = (state_aw_value == STATE_AW_RUN0);
  wire st_aw_run1 = (state_aw_value == STATE_AW_RUN1);
  wire st_aw_fix0 = (state_aw_value == STATE_AW_FIX0);
  wire st_aw_fix1 = (state_aw_value == STATE_AW_FIX1);

  wire st_dw_idle = (state_dw_value == STATE_DW_IDLE);
  wire st_dw_run  = (state_dw_value == STATE_DW_RUN);

  localparam FIFO_LOGDEPTH = 3;

  wire [AXI_AWIDTH-1:0] ff_addr_enq_data, ff_addr_deq_data;
  wire ff_addr_enq_valid, ff_addr_enq_ready;
  wire ff_addr_deq_valid, ff_addr_deq_ready;

  fifo #(
    .WIDTH(AXI_AWIDTH),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_addr (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_addr_enq_data),
    .enq_valid(ff_addr_enq_valid),
    .enq_ready(ff_addr_enq_ready),

    .deq_data(ff_addr_deq_data),
    .deq_valid(ff_addr_deq_valid),
    .deq_ready(ff_addr_deq_ready)
  );

  wire [7:0] ff_len0_enq_data, ff_len0_deq_data;
  wire ff_len0_enq_valid, ff_len0_enq_ready;
  wire ff_len0_deq_valid, ff_len0_deq_ready;

  fifo #(
    .WIDTH(8),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_len0 (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_len0_enq_data),
    .enq_valid(ff_len0_enq_valid),
    .enq_ready(ff_len0_enq_ready),

    .deq_data(ff_len0_deq_data),
    .deq_valid(ff_len0_deq_valid),
    .deq_ready(ff_len0_deq_ready)
  );

  wire [7:0] ff_len1_enq_data, ff_len1_deq_data;
  wire ff_len1_enq_valid, ff_len1_enq_ready;
  wire ff_len1_deq_valid, ff_len1_deq_ready;

  fifo #(
    .WIDTH(8),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_len1 (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_len1_enq_data),
    .enq_valid(ff_len1_enq_valid),
    .enq_ready(ff_len1_enq_ready),

    .deq_data(ff_len1_deq_data),
    .deq_valid(ff_len1_deq_valid),
    .deq_ready(ff_len1_deq_ready)
  );

  wire [2:0] ff_size_enq_data, ff_size_deq_data;
  wire ff_size_enq_valid, ff_size_enq_ready;
  wire ff_size_deq_valid, ff_size_deq_ready;

  fifo #(
    .WIDTH(3),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_size (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_size_enq_data),
    .enq_valid(ff_size_enq_valid),
    .enq_ready(ff_size_enq_ready),

    .deq_data(ff_size_deq_data),
    .deq_valid(ff_size_deq_valid),
    .deq_ready(ff_size_deq_ready)
  );

  wire [1:0] ff_burst_enq_data, ff_burst_deq_data;
  wire ff_burst_enq_valid, ff_burst_enq_ready;
  wire ff_burst_deq_valid, ff_burst_deq_ready;

  fifo #(
    .WIDTH(2),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_burst (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_burst_enq_data),
    .enq_valid(ff_burst_enq_valid),
    .enq_ready(ff_burst_enq_ready),

    .deq_data(ff_burst_deq_data),
    .deq_valid(ff_burst_deq_valid),
    .deq_ready(ff_burst_deq_ready)
  );

  wire ff_bresp_enq_data, ff_bresp_deq_data;
  wire ff_bresp_enq_valid, ff_bresp_enq_ready;
  wire ff_bresp_deq_valid, ff_bresp_deq_ready;

  fifo #(
    .WIDTH(1),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_bresp (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_bresp_enq_data),
    .enq_valid(ff_bresp_enq_valid),
    .enq_ready(ff_bresp_enq_ready),

    .deq_data(ff_bresp_deq_data),
    .deq_valid(ff_bresp_deq_valid),
    .deq_ready(ff_bresp_deq_ready)
  );

  wire ff_addr_enq_fire  = ff_addr_enq_valid  & ff_addr_enq_ready;
  wire ff_len0_enq_fire  = ff_len0_enq_valid  & ff_len0_enq_ready;
  wire ff_len1_enq_fire  = ff_len1_enq_valid  & ff_len1_enq_ready;
  wire ff_size_enq_fire  = ff_size_enq_valid  & ff_size_enq_ready;
  wire ff_burst_enq_fire = ff_burst_enq_valid & ff_burst_enq_ready;
  wire ff_bresp_enq_fire = ff_bresp_enq_valid & ff_bresp_enq_ready;

  wire ff_addr_deq_fire  = ff_addr_deq_valid  & ff_addr_deq_ready;
  wire ff_len0_deq_fire  = ff_len0_deq_valid  & ff_len0_deq_ready;
  wire ff_len1_deq_fire  = ff_len1_deq_valid  & ff_len1_deq_ready;
  wire ff_size_deq_fire  = ff_size_deq_valid  & ff_size_deq_ready;
  wire ff_burst_deq_fire = ff_burst_deq_valid & ff_burst_deq_ready;
  wire ff_bresp_deq_fire = ff_bresp_deq_valid & ff_bresp_deq_ready;

  wire [2:0] aw_wait_cnt_next, aw_wait_cnt_value;
  wire aw_wait_cnt_ce, aw_wait_cnt_rst;
  REGISTER_R_CE #(.N(3), .INIT(0)) aw_wait_cnt_reg (
    .clk(clk),
    .d(aw_wait_cnt_next),
    .q(aw_wait_cnt_value),
    .ce(aw_wait_cnt_ce),
    .rst(aw_wait_cnt_rst)
  );

  assign aw_wait_cnt_next = aw_wait_cnt_value + 1;
  assign aw_wait_cnt_ce   = (state_aw_value == STATE_AW_WAIT);
  assign aw_wait_cnt_rst  = ~resetn | (state_aw_value == STATE_AW_IDLE);

  wire [AXI_AWIDTH-1:0] waddr_4KB_aligned = ((waddr_value + 4096) >> 12) << 12;
  wire [AXI_AWIDTH-1:0] waddr_4KB_aligned_pipe0;
  REGISTER #(.N(AXI_AWIDTH)) waddr_4KB_aligned_pipe0_reg (
    .clk(clk),
    .d(waddr_4KB_aligned),
    .q(waddr_4KB_aligned_pipe0)
  );

  wire [AXI_AWIDTH-1:0] rem = waddr_4KB_aligned_pipe0 - waddr_value;
  wire wlen_cond_pipe;
  REGISTER #(.N(1)) wlen_cond_pipe_reg (
    .clk(clk),
    .d(wlen_value > (AXI_MAX_BURST_LEN - 1)),
    .q(wlen_cond_pipe)
  );

  wire [7:0] cur_len = wlen_cond_pipe ? (AXI_MAX_BURST_LEN - 1) : wlen_value;
  wire [AXI_AWIDTH-1:0] rem_pipe0;
  REGISTER #(.N(AXI_AWIDTH)) rem_pipe0_reg (
    .clk(clk),
    .d(rem),
    .q(rem_pipe0)
  );

  wire [AXI_AWIDTH-1:0] tmp;
  REGISTER #(.N(AXI_AWIDTH)) tmp_reg (
    .clk(clk),
    .d((cur_len + 1) << wsize_value),
    .q(tmp)
  );

  wire is_4KB_misaligned = tmp > rem_pipe0;
  wire is_4KB_misaligned_pipe0;
  REGISTER #(.N(1)) is_4KB_misaligned_pipe0_reg (
    .clk(clk),
    .d(is_4KB_misaligned),
    .q(is_4KB_misaligned_pipe0)
  );

  wire [7:0] len0;
  REGISTER_CE #(.N(8)) len0_pipe_reg (
    .clk(clk),
    .ce(st_aw_run0),
    .d((rem >> wsize_value) - 1),
    .q(len0)
  );

  wire [7:0] cur_len_pipe0;
  REGISTER_CE #(.N(8)) cur_len_pipe0_reg (
    .clk(clk),
    .ce(st_aw_run0),
    .d(cur_len),
    .q(cur_len_pipe0)
  );

  wire [7:0] len1;
  REGISTER_CE #(.N(8)) len1_pipe_reg (
    .clk(clk),
    .ce(st_aw_fix0),
    .d((cur_len_pipe0 - len0) - 1),
    .q(len1)
  );

  always @(*) begin
    state_aw_next = state_aw_value;
    case (state_aw_value)
      STATE_AW_IDLE: begin
        if (core_write_request_fire)
          state_aw_next = STATE_AW_WAIT;
      end

      // Wait for 4KB-boundary check result
      STATE_AW_WAIT: begin
        if (aw_wait_cnt_value == 2)
          state_aw_next = STATE_AW_RUN0;
      end

      STATE_AW_RUN0: begin
        if (is_4KB_misaligned_pipe0)
          state_aw_next = STATE_AW_FIX0;
        else
          state_aw_next = STATE_AW_RUN1;
      end

      STATE_AW_RUN1: begin
        if (ff_addr_enq_fire) begin
          if (~wlen_cond_pipe)
            state_aw_next = STATE_AW_IDLE;
          else
            state_aw_next = STATE_AW_RUN0;
        end
      end

      STATE_AW_FIX0: begin
        if (ff_addr_enq_fire)
          state_aw_next = STATE_AW_FIX1;
      end

      STATE_AW_FIX1: begin
        if (ff_addr_enq_fire) begin
          if (~wlen_cond_pipe)
            state_aw_next = STATE_AW_IDLE;
          else
            state_aw_next = STATE_AW_RUN0;
        end
      end

    endcase
  end

  always @(*) begin
    state_dw_next = state_dw_value;
    case (state_dw_value)
      STATE_DW_IDLE: begin
        if (ff_len1_deq_fire)
          state_dw_next = STATE_DW_RUN;
      end

      STATE_DW_RUN: begin
        // If the last data is fired, we are done
        if (m_dw_fire && m_wlast) begin
          state_dw_next = STATE_DW_IDLE;
        end
      end
    endcase
  end

  wire full_wburst = wlen_cond_pipe;

  assign ff_addr_enq_data  = waddr_value;
  assign ff_addr_enq_valid = st_aw_run1 | st_aw_fix0 | st_aw_fix1;

  assign ff_len0_enq_data  = st_aw_fix0 ? len0 :
                             st_aw_fix1 ? len1 :
                             full_wburst ? (AXI_MAX_BURST_LEN - 1) : wlen_value;
  assign ff_len0_enq_valid = st_aw_run1 | st_aw_fix0 | st_aw_fix1;

  assign ff_burst_enq_data  = wburst_value;
  assign ff_burst_enq_valid = st_aw_run1 | st_aw_fix0 | st_aw_fix1;

  assign ff_size_enq_data  = wsize_value;
  assign ff_size_enq_valid = st_aw_run1 | st_aw_fix0 | st_aw_fix1;

  assign ff_len1_enq_data  = ff_len0_deq_data;
  assign ff_len1_enq_valid = m_awready & ff_len0_deq_valid;

  assign ff_bresp_enq_data  = 0;
  assign ff_bresp_enq_valid = m_dw_fire & m_wlast;

  // register the settings from the core client
  // (size, burst)
  assign wsize_next = core_write_size;
  assign wsize_ce   = core_write_request_fire;

  assign wburst_next = core_write_burst;
  assign wburst_ce   = core_write_request_fire;

  // Recalculate the address if we need to send multiple requests to cover
  // the full burst length
  assign waddr_next =
    core_write_request_fire         ? core_write_addr   :
    (st_aw_fix0 & ff_addr_enq_fire) ? waddr_4KB_aligned :
                             (waddr_value + {AXI_MAX_BURST_LEN << wsize_value});
  assign waddr_ce   = core_write_request_fire |
                      (ff_addr_enq_fire & (st_aw_fix0 | st_aw_fix1 | st_aw_run1));

  // Recalculate the len if we need to send multiple requests to cover
  // the full burst length
  wire [63:0] wlen_sub_pipe0;
  REGISTER #(.N(64)) wlen_sub_pipe0_reg (
    .clk(clk),
    .d(wlen_value - AXI_MAX_BURST_LEN),
    .q(wlen_sub_pipe0)
  );

  assign wlen_next = core_write_request_fire ? core_write_len : wlen_sub_pipe0;
  assign wlen_ce   = core_write_request_fire |
                     (ff_len0_enq_fire & (st_aw_fix1 | st_aw_run1));

  // Count the number of write data beats to assert the 'last' signal
  assign wbeat_cnt_next = wbeat_cnt_value + 1;
  assign wbeat_cnt_ce   = m_dw_fire;
  assign wbeat_cnt_rst  = st_dw_idle | (~resetn);

  // Setup write request address for AXI adapter write
  wire [7:0] ff_len1_deq_data_pipe0;

  REGISTER_CE #(.N(8)) ff_len1_deq_data_pipe0_reg (
    .clk(clk),
    .d(ff_len1_deq_data),
    .q(ff_len1_deq_data_pipe0),
    .ce(ff_len1_deq_fire)
  );

  assign m_awaddr           = ff_addr_deq_data;
  assign m_awvalid          = ff_addr_deq_valid & ff_len1_enq_ready;

  assign ff_addr_deq_ready  = m_awready & ff_len1_enq_ready;
  assign m_awlen            = ff_len0_deq_data;
  assign ff_len0_deq_ready  = m_awready & ff_len1_enq_ready;
  assign m_awsize           = ff_size_deq_data;
  assign ff_size_deq_ready  = m_awready & ff_len1_enq_ready;
  assign m_awburst          = ff_burst_deq_data;
  assign ff_burst_deq_ready = m_awready & ff_len1_enq_ready;

  // Setup write request data for AXI adapter write
  assign ff_len1_deq_ready = st_dw_idle;

  assign m_wdata   = core_write_data;
  assign m_wvalid  = st_dw_run & core_write_data_valid;
  assign m_wlast   = st_dw_run &
                    (wbeat_cnt_value == ff_len1_deq_data_pipe0);

  // Write response
  // For now, assume always RESP_OKAY
  assign m_bready           = ff_bresp_deq_valid;
  assign ff_bresp_deq_ready = m_bvalid;

  assign core_write_request_ready = st_aw_idle & m_awready;
  assign core_write_data_ready    = st_dw_run  & m_wready;
  assign core_write_resp_ok       = ff_bresp_deq_fire;

  // Setup write strobe. Full word write for now?
  assign m_wstrb = st_dw_run ? {NUM_DBYTES{1'b1}} : {NUM_DBYTES{1'b0}};

  // Keep it simple: use ID 0 for now
  assign m_awid = 0;
  assign m_wid  = 0;

  // Keep it simple: ignore bid for now

endmodule
