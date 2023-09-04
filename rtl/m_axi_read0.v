`include "axi_consts.vh"

// Used for system_sim_socket.tcl
module m_axi_read0 #(
  parameter AXI_AWIDTH = 64,
  parameter AXI_DWIDTH = 256,
  parameter AXI_MAX_BURST_LEN = 128
) (
  input clk,
  input resetn, // active-low reset

  // Read request address channel
  output [3:0]            m_arid,
  output [AXI_AWIDTH-1:0] m_araddr,
  output                  m_arvalid,
  input                   m_arready,
  output [7:0]            m_arlen,
  output [2:0]            m_arsize,
  output [1:0]            m_arburst,
  // lock, cache, prot, qos, region, user (unused)

  // Read response data channel
  input  [3:0]            m_rid,
  input  [AXI_DWIDTH-1:0] m_rdata,
  input                   m_rvalid,
  output                  m_rready,
  input                   m_rlast,
  input  [1:0]            m_rresp,
  // user (unused)

  // Core (client) read interface
  input                   core_read_request_valid,
  output                  core_read_request_ready,
  input  [AXI_AWIDTH-1:0] core_read_addr,
  input  [31:0]           core_read_len,
  input  [2:0]            core_read_size,
  input  [1:0]            core_read_burst,
  output [AXI_DWIDTH-1:0] core_read_data,
  output                  core_read_data_valid,
  input                   core_read_data_ready,
  output                  core_read_data_last
);

  // number of data transfers (beats) = len + 1
  // number of bytes in transfer = 2^size

  wire m_ar_fire = m_arvalid & m_arready;
  wire m_dr_fire = m_rvalid  & m_rready;

  wire core_read_request_fire  = core_read_request_valid & core_read_request_ready;

  localparam STATE_AR_IDLE = 0;
  localparam STATE_AR_WAIT = 5;
  localparam STATE_AR_RUN0 = 1;
  localparam STATE_AR_RUN1 = 2;
  localparam STATE_AR_FIX0 = 3;
  localparam STATE_AR_FIX1 = 4;

  localparam STATE_DR_IDLE = 0;
  localparam STATE_DR_RUN  = 1;

  wire [2:0] state_ar_value;
  reg  [2:0] state_ar_next;
  wire state_dr_value;
  reg  state_dr_next;

  REGISTER_R #(.N(3), .INIT(STATE_AR_IDLE)) state_ar_reg (
    .clk(clk),
    .rst(~resetn),
    .d(state_ar_next),
    .q(state_ar_value)
  );

  REGISTER_R #(.N(1), .INIT(STATE_DR_IDLE)) state_dr_reg (
    .clk(clk),
    .rst(~resetn),
    .d(state_dr_next),
    .q(state_dr_value)
  );

  wire [AXI_AWIDTH-1:0] raddr_next, raddr_value;
  wire raddr_ce;
  REGISTER_R_CE #(.N(AXI_AWIDTH), .INIT(0)) raddr_reg (
    .clk(clk),
    .rst(~resetn),
    .d(raddr_next),
    .q(raddr_value),
    .ce(raddr_ce)
  );

  wire [31:0] rlen_next, rlen_value;
  wire rlen_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) rlen_reg (
    .clk(clk),
    .rst(~resetn),
    .d(rlen_next),
    .q(rlen_value),
    .ce(rlen_ce)
  );

  wire [2:0] rsize_next, rsize_value;
  wire rsize_ce;
  REGISTER_R_CE #(.N(3), .INIT(0)) rsize_reg (
    .clk(clk),
    .rst(~resetn),
    .d(rsize_next),
    .q(rsize_value),
    .ce(rsize_ce)
  );

  wire [1:0] rburst_next, rburst_value;
  wire rburst_ce;
  REGISTER_R_CE #(.N(2), .INIT(0)) rburst_reg (
    .clk(clk),
    .rst(~resetn),
    .d(rburst_next),
    .q(rburst_value),
    .ce(rburst_ce)
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

  wire st_ar_idle = (state_ar_value == STATE_AR_IDLE);
  wire st_ar_run0 = (state_ar_value == STATE_AR_RUN0);
  wire st_ar_run1 = (state_ar_value == STATE_AR_RUN1);
  wire st_ar_fix0 = (state_ar_value == STATE_AR_FIX0);
  wire st_ar_fix1 = (state_ar_value == STATE_AR_FIX1);

  wire st_dr_idle = (state_dr_value == STATE_DR_IDLE);
  wire st_dr_run  = (state_dr_value == STATE_DR_RUN);

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

  wire ff_rresp_enq_data, ff_rresp_deq_data;
  wire ff_rresp_enq_valid, ff_rresp_enq_ready;
  wire ff_rresp_deq_valid, ff_rresp_deq_ready;

  fifo #(
    .WIDTH(1),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_rresp (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_rresp_enq_data),
    .enq_valid(ff_rresp_enq_valid),
    .enq_ready(ff_rresp_enq_ready),

    .deq_data(ff_rresp_deq_data),
    .deq_valid(ff_rresp_deq_valid),
    .deq_ready(ff_rresp_deq_ready)
  );

  wire ff_addr_enq_fire  = ff_addr_enq_valid  & ff_addr_enq_ready;
  wire ff_len0_enq_fire  = ff_len0_enq_valid  & ff_len0_enq_ready;
  wire ff_size_enq_fire  = ff_size_enq_valid  & ff_size_enq_ready;
  wire ff_burst_enq_fire = ff_burst_enq_valid & ff_burst_enq_ready;
  wire ff_rresp_enq_fire = ff_rresp_enq_valid & ff_rresp_enq_ready;

  wire ff_addr_deq_fire  = ff_addr_deq_valid  & ff_addr_deq_ready;
  wire ff_len0_deq_fire  = ff_len0_deq_valid  & ff_len0_deq_ready;
  wire ff_size_deq_fire  = ff_size_deq_valid  & ff_size_deq_ready;
  wire ff_burst_deq_fire = ff_burst_deq_valid & ff_burst_deq_ready;
  wire ff_rresp_deq_fire = ff_rresp_deq_valid & ff_rresp_deq_ready;

  wire [2:0] ar_wait_cnt_next, ar_wait_cnt_value;
  wire ar_wait_cnt_ce, ar_wait_cnt_rst;
  REGISTER_R_CE #(.N(3), .INIT(0)) ar_wait_cnt_reg (
    .clk(clk),
    .d(ar_wait_cnt_next),
    .q(ar_wait_cnt_value),
    .ce(ar_wait_cnt_ce),
    .rst(ar_wait_cnt_rst)
  );

  assign ar_wait_cnt_next = ar_wait_cnt_value + 1;
  assign ar_wait_cnt_ce   = (state_ar_value == STATE_AR_WAIT);
  assign ar_wait_cnt_rst  = ~resetn | (state_ar_value == STATE_AR_IDLE);

  wire [AXI_AWIDTH-1:0] raddr_4KB_aligned = ((raddr_value + 4096) >> 12) << 12;
  wire [AXI_AWIDTH-1:0] raddr_4KB_aligned_pipe0;
  REGISTER #(.N(AXI_AWIDTH)) raddr_4KB_aligned_pipe0_reg (
    .clk(clk),
    .d(raddr_4KB_aligned),
    .q(raddr_4KB_aligned_pipe0)
  );

  wire [AXI_AWIDTH-1:0] rem = raddr_4KB_aligned_pipe0 - raddr_value;
  wire rlen_cond_pipe;
  REGISTER #(.N(1)) rlen_cond_pipe_reg (
    .clk(clk),
    .d(rlen_value > (AXI_MAX_BURST_LEN - 1)),
    .q(rlen_cond_pipe)
  );
  wire [7:0] cur_len = rlen_cond_pipe ? (AXI_MAX_BURST_LEN - 1) : rlen_value;

  wire [AXI_AWIDTH-1:0] rem_pipe0;
  REGISTER #(.N(AXI_AWIDTH)) rem_pipe0_reg (
    .clk(clk),
    .d(rem),
    .q(rem_pipe0)
  );

  wire [AXI_AWIDTH-1:0] tmp;
  REGISTER #(.N(AXI_AWIDTH)) tmp_reg (
    .clk(clk),
    .d((cur_len + 1) << rsize_value),
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
    .ce(st_ar_run0),
    .d((rem >> rsize_value) - 1),
    .q(len0)
  );

  wire [7:0] cur_len_pipe0;
  REGISTER_CE #(.N(8)) cur_len_pipe0_reg (
    .clk(clk),
    .ce(st_ar_run0),
    .d(cur_len),
    .q(cur_len_pipe0)
  );

  wire [7:0] len1;
  REGISTER_CE #(.N(8)) len1_pipe_reg (
    .clk(clk),
    .ce(st_ar_fix0),
    .d((cur_len_pipe0 - len0) - 1),
    .q(len1)
  );

  always @(*) begin
    state_ar_next = state_ar_value;
    case (state_ar_value)
      STATE_AR_IDLE: begin
        if (core_read_request_fire)
          state_ar_next = STATE_AR_WAIT;
      end

      // Wait for 4KB-boundary check result
      STATE_AR_WAIT: begin
        if (ar_wait_cnt_value == 2)
          state_ar_next = STATE_AR_RUN0;
      end

      STATE_AR_RUN0: begin
        if (is_4KB_misaligned_pipe0)
          state_ar_next = STATE_AR_FIX0;
        else
          state_ar_next = STATE_AR_RUN1;
      end

      STATE_AR_RUN1: begin
        if (ff_addr_enq_fire) begin
          if (~rlen_cond_pipe)
            state_ar_next = STATE_AR_IDLE;
          else
            state_ar_next = STATE_AR_RUN0;
        end
      end

      STATE_AR_FIX0: begin
        if (ff_addr_enq_fire)
          state_ar_next = STATE_AR_FIX1;
      end

      STATE_AR_FIX1: begin
        if (ff_addr_enq_fire) begin
          if (~rlen_cond_pipe)
            state_ar_next = STATE_AR_IDLE;
          else
            state_ar_next = STATE_AR_RUN0;
        end
      end

    endcase
  end

  always @(*) begin
    state_dr_next = state_dr_value;
    case (state_dr_value)
      STATE_DR_IDLE: begin
        // If the AXI has submitted the request, we'll wait for the
        // response data in the next state
        if (ff_rresp_deq_fire)
          state_dr_next = STATE_DR_RUN;
      end

      STATE_DR_RUN: begin
        // If the last data is fired, we are done
        if (m_dr_fire && m_rlast) begin
          state_dr_next = STATE_DR_IDLE;
        end
      end
    endcase
  end

  wire full_rburst = rlen_cond_pipe;

  assign ff_addr_enq_data  = raddr_value;
  assign ff_addr_enq_valid = st_ar_run1 | st_ar_fix0 | st_ar_fix1;

  assign ff_len0_enq_data  = st_ar_fix0 ? len0 :
                             st_ar_fix1 ? len1 :
                             full_rburst ? (AXI_MAX_BURST_LEN - 1) : rlen_value;
  assign ff_len0_enq_valid = st_ar_run1 | st_ar_fix0 | st_ar_fix1;

  assign ff_burst_enq_data  = rburst_value;
  assign ff_burst_enq_valid = st_ar_run1 | st_ar_fix0 | st_ar_fix1;

  assign ff_size_enq_data  = rsize_value;
  assign ff_size_enq_valid = st_ar_run1 | st_ar_fix0 | st_ar_fix1;

  // Register the settings from the core client
  // (size, burst)
  assign rsize_next = core_read_size;
  assign rsize_ce   = core_read_request_fire;

  assign rburst_next = core_read_burst;
  assign rburst_ce   = core_read_request_fire;

  // Recalculate the address if we need to send multiple requests to cover
  // the full burst length
  assign raddr_next =
    core_read_request_fire          ? core_read_addr    :
    (st_ar_fix0 & ff_addr_enq_fire) ? raddr_4KB_aligned :
                             (raddr_value + {AXI_MAX_BURST_LEN << rsize_value});
  assign raddr_ce   = core_read_request_fire |
                      (ff_addr_enq_fire & (st_ar_fix0 | st_ar_fix1 | st_ar_run1));

  // Recalculate the len if we need to send multiple requests to cover
  // the full burst length
  wire [63:0] rlen_sub_pipe0;
  REGISTER #(.N(64)) rlen_sub_pipe0_reg (
    .clk(clk),
    .d(rlen_value - AXI_MAX_BURST_LEN),
    .q(rlen_sub_pipe0)
  );

  assign rlen_next = core_read_request_fire ? core_read_len : rlen_sub_pipe0;
  assign rlen_ce   = core_read_request_fire |
                     (ff_len0_enq_fire & (st_ar_fix1 | st_ar_run1));

  // Setup read request for AXI adater read
  assign m_araddr           = ff_addr_deq_data;
  assign m_arvalid          = ff_addr_deq_valid & ff_rresp_enq_ready;

  assign ff_addr_deq_ready  = m_arready & ff_rresp_enq_ready;
  assign m_arlen            = ff_len0_deq_data;
  assign ff_len0_deq_ready  = m_arready & ff_rresp_enq_ready;
  assign m_arsize           = ff_size_deq_data;
  assign ff_size_deq_ready  = m_arready & ff_rresp_enq_ready;
  assign m_arburst          = ff_burst_deq_data;
  assign ff_burst_deq_ready = m_arready & ff_rresp_enq_ready;

  assign ff_rresp_enq_data  = 0;
  assign ff_rresp_enq_valid = m_arready & ff_addr_deq_valid;

  assign ff_rresp_deq_ready = st_dr_idle;

  assign m_rready  = st_dr_run & core_read_data_ready;

  assign core_read_request_ready = st_ar_idle;
  assign core_read_data          = m_rdata;
  assign core_read_data_valid    = st_dr_run & m_rvalid;
  assign core_read_data_last     = st_dr_run & m_rvalid & m_rlast;
  // Keep it simple: use ID 0 for now
  assign m_arid = 0;

  // Keep it simple: ignore rid for now

endmodule
