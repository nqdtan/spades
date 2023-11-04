`include "socket_config.vh"
`include "axi_consts.vh"

module s_axi_adapter #(
  parameter AXI_AWIDTH  = 64,
  parameter AXI_DWIDTH  = 512,//256,//64,
  parameter DMEM_AWIDTH = 12,
  parameter DMEM_DWIDTH = 512,//256,
  parameter NUM_SYNCS = 16,
  parameter SOCKET_BASE_ADDR = 64'h0000_0201_0000_0000
) (
  input clk,
  output socket_reset,

  input  ss_start,
  //output ss_done,
  input ss_done,

  input [AXI_DWIDTH-1:0]   ss_in_data,
  input                    ss_in_valid,
  output                   ss_in_ready,
  output  [AXI_DWIDTH-1:0] ss_out_data,
  output                   ss_out_valid,
  input                    ss_out_ready,

  // AXI bus interface
  // Read address channel
  input [3:0]              s_arid,
  input [AXI_AWIDTH-1:0]   s_araddr,
  input                    s_arvalid,
  output                   s_arready,
  input [7:0]              s_arlen,
  input [2:0]              s_arsize,
  input [1:0]              s_arburst,
  // lock, cache, prot, qos, region, user (unused)

  // Read data channel
  output  [3:0]            s_rid,
  output  [AXI_DWIDTH-1:0] s_rdata,
  output                   s_rvalid,
  input                    s_rready,
  output                   s_rlast,
  output  [1:0]            s_rresp,
  // user (unused)

  // Write address channel
  input [3:0]            s_awid,
  input [AXI_AWIDTH-1:0] s_awaddr,
  input                  s_awvalid,
  output                 s_awready,
  input [7:0]            s_awlen,
  input [2:0]            s_awsize,
  input [1:0]            s_awburst,
  // lock, cache, prot, qos, region, user (unused)

  // Write data channel
  input [3:0]              s_wid,
  input [AXI_DWIDTH-1:0]   s_wdata,
  input                    s_wvalid,
  output                   s_wready,
  input                    s_wlast,
  input [AXI_DWIDTH/8-1:0] s_wstrb,
  // user (unused)

  // Write response channel
  output [3:0] s_bid,
  output [1:0] s_bresp,
  output       s_bvalid,
  input        s_bready,
  // user (unused)

  output [DMEM_AWIDTH-1:0] dmem_addr,
  output [DMEM_DWIDTH-1:0] dmem_din,
  input  [DMEM_DWIDTH-1:0] dmem_dout,
  output                   dmem_we,
  output                   dmem_en,

  // Synchronization points
  // They are used to sync the socket modules
  output [NUM_SYNCS-1:0] sync_en,

  input [31:0] squeue_out_data,
  input        squeue_out_valid,
  output       squeue_out_ready,

  output [63:0] ext_mem_offset,

  input [31:0] cnt0_value,
  input [31:0] cnt1_value,
  input [31:0] perf_cnt_value,
  input [31:0] instrument_cnt0,
  input [31:0] instrument_cnt1,

  output [31:0] socket_imem_addr,
  output [31:0] socket_imem_wdata,
  input  [31:0] socket_imem_rdata,
  output        socket_imem_we,
  output [31:0] socket_inbox,
  output socket_start,
  input socket_done
);

  localparam BYTE_SIZE      = AXI_DWIDTH / 8;
  localparam LOG2_BYTE_SIZE = $clog2(BYTE_SIZE);

  // The sync points are activated when the s_axi_adapter receives request
  // that is beyond the DMem capacity
  localparam SOCKET_MMIO_REG_SPACE = `SOCKET_MMIO_REG_SPACE;
  localparam SYNC_OFFSET  = 0;

  localparam SQUEUE_OFFSET = 32;

  localparam SOCKET_CSR_OFFSET        = 64;
  localparam EXT_MEM_OFFSET_LO        = 65;
  localparam EXT_MEM_OFFSET_HI        = 66;
  localparam SOCKET_IMEM_ADDR_OFFSET  = 67;
  localparam SOCKET_IMEM_WDATA_OFFSET = 68;
  localparam SOCKET_IMEM_WE_OFFSET    = 69;
  localparam SOCKET_IMEM_RDATA_OFFSET = 70;

  localparam CNT0_OFFSET = 71;
  localparam CNT1_OFFSET = 72;

  localparam SOCKET_INBOX_OFFSET = 73;

  localparam PERF_CNT_OFFSET = 74;

  localparam INSTRUMENT_CNT0_OFFSET = 75;
  localparam INSTRUMENT_CNT1_OFFSET = 76;

  localparam SOCKET_RESET_OFFSET = 256;

  wire s_wlast_pipe;
  wire socket_reset_pipe, socket_reset_ce;

  REGISTER_R_CE #(.N(1), .INIT(0)) s_wlast_reg (
    .clk(clk),
    .rst(socket_reset_pipe & s_wlast_pipe & s_bready),
    .ce(s_wvalid & s_wlast),
    .d(1'b1),
    .q(s_wlast_pipe)
  );

  REGISTER_R_CE #(.N(1), .INIT(0)) socket_reset_reg (
    .clk(clk),
    .rst(socket_reset_pipe & s_wlast_pipe & s_bready),
    .ce(socket_reset_ce),
    .d(1'b1),
    .q(socket_reset_pipe)
  );
  
  assign socket_reset_ce =
     (s_awaddr[SOCKET_MMIO_REG_SPACE+LOG2_BYTE_SIZE]) &
     (s_awaddr[SOCKET_MMIO_REG_SPACE+LOG2_BYTE_SIZE-1:LOG2_BYTE_SIZE] == SOCKET_RESET_OFFSET) &
    s_awvalid;
  assign socket_reset = socket_reset_pipe;

  localparam STATE_IDLE       = 0;
  localparam STATE_W_DATA     = 1;
  localparam STATE_W_RESP     = 2;
  localparam STATE_R_DATA     = 3;

  wire [2:0] state_value;
  reg  [2:0] state_next;

  REGISTER #(.N(3)) state_reg (
    .clk(clk),
    .d(state_next),
    .q(state_value)
  );

  wire [31:0] beat_cnt_value, beat_cnt_next;
  wire beat_cnt_ce, beat_cnt_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) beat_cnt_reg (
    .clk(clk),
    .d(beat_cnt_next),
    .q(beat_cnt_value),
    .ce(beat_cnt_ce),
    .rst(beat_cnt_rst)
  );

  wire [AXI_AWIDTH-1:0] addr_next, addr_value;
  wire addr_ce, addr_rst;

  REGISTER_R_CE #(.N(AXI_AWIDTH), .INIT(0)) addr_reg (
    .clk(clk),
    .d(addr_next),
    .q(addr_value),
    .ce(addr_ce),
    .rst(addr_rst)
  );
 
  wire [31:0] len_next, len_value;
  wire len_ce, len_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) len_reg (
    .clk(clk),
    .d(len_next),
    .q(len_value),
    .ce(len_ce),
    .rst(len_rst)
  );

  wire [31:0] socket_csr_next, socket_csr_value;
  wire socket_csr_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) socket_csr_reg (
    .clk(clk),
    .rst(socket_reset),
    .ce(socket_csr_ce),
    .d(socket_csr_next),
    .q(socket_csr_value)
  );

  wire [31:0] ext_mem_offset_lo_next, ext_mem_offset_lo_value;
  wire ext_mem_offset_lo_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) ext_mem_offset_lo_reg (
    .clk(clk),
    .rst(socket_reset),
    .ce(ext_mem_offset_lo_ce),
    .d(ext_mem_offset_lo_next),
    .q(ext_mem_offset_lo_value)
  );

  wire [31:0] ext_mem_offset_hi_next, ext_mem_offset_hi_value;
  wire ext_mem_offset_hi_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) ext_mem_offset_hi_reg (
    .clk(clk),
    .rst(socket_reset),
    .ce(ext_mem_offset_hi_ce),
    .d(ext_mem_offset_hi_next),
    .q(ext_mem_offset_hi_value)
  );

  wire [31:0] socket_imem_addr_next, socket_imem_addr_value;
  wire socket_imem_addr_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) socket_imem_addr_reg (
    .clk(clk),
    .rst(socket_reset),
    .ce(socket_imem_addr_ce),
    .d(socket_imem_addr_next),
    .q(socket_imem_addr_value)
  );

  wire [31:0] socket_imem_wdata_next, socket_imem_wdata_value;
  wire socket_imem_wdata_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) socket_imem_wdata_reg (
    .clk(clk),
    .rst(socket_reset),
    .ce(socket_imem_wdata_ce),
    .d(socket_imem_wdata_next),
    .q(socket_imem_wdata_value)
  );

  wire [31:0] socket_imem_we_next, socket_imem_we_value;
  wire socket_imem_we_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) socket_imem_we_reg (
    .clk(clk),
    .rst(socket_reset),
    .ce(socket_imem_we_ce),
    .d(socket_imem_we_next),
    .q(socket_imem_we_value)
  );

  wire [31:0] socket_inbox_next, socket_inbox_value;
  wire socket_inbox_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) socket_inbox_reg (
    .clk(clk),
    .rst(socket_reset),
    .ce(socket_inbox_ce),
    .d(socket_inbox_next),
    .q(socket_inbox_value)
  );

  localparam FIFO_LOGDEPTH = 2;//3;

  wire [AXI_AWIDTH-1:0] ff_addr_enq_data, ff_addr_deq_data;
  wire ff_addr_enq_valid, ff_addr_enq_ready;
  wire ff_addr_deq_valid, ff_addr_deq_ready;

  fifo #(
    .WIDTH(AXI_AWIDTH),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_addr (
    .clk(clk),
    .rst(socket_reset),

    .enq_data(ff_addr_enq_data),
    .enq_valid(ff_addr_enq_valid),
    .enq_ready(ff_addr_enq_ready),

    .deq_data(ff_addr_deq_data),
    .deq_valid(ff_addr_deq_valid),
    .deq_ready(ff_addr_deq_ready)
  );

  wire [7:0] ff_len_enq_data, ff_len_deq_data;
  wire ff_len_enq_valid, ff_len_enq_ready;
  wire ff_len_deq_valid, ff_len_deq_ready;

  fifo #(
    .WIDTH(8),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_len (
    .clk(clk),
    .rst(socket_reset),

    .enq_data(ff_len_enq_data),
    .enq_valid(ff_len_enq_valid),
    .enq_ready(ff_len_enq_ready),

    .deq_data(ff_len_deq_data),
    .deq_valid(ff_len_deq_valid),
    .deq_ready(ff_len_deq_ready)
  );

  wire [2:0] ff_size_enq_data, ff_size_deq_data;
  wire ff_size_enq_valid, ff_size_enq_ready;
  wire ff_size_deq_valid, ff_size_deq_ready;

  fifo #(
    .WIDTH(3),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_size (
    .clk(clk),
    .rst(socket_reset),

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
    .rst(socket_reset),

    .enq_data(ff_burst_enq_data),
    .enq_valid(ff_burst_enq_valid),
    .enq_ready(ff_burst_enq_ready),

    .deq_data(ff_burst_deq_data),
    .deq_valid(ff_burst_deq_valid),
    .deq_ready(ff_burst_deq_ready)
  );

  wire ff_wen_enq_data, ff_wen_deq_data;
  wire ff_wen_enq_valid, ff_wen_enq_ready;
  wire ff_wen_deq_valid, ff_wen_deq_ready;

  fifo #(
    .WIDTH(1),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_wen (
    .clk(clk),
    .rst(socket_reset),

    .enq_data(ff_wen_enq_data),
    .enq_valid(ff_wen_enq_valid),
    .enq_ready(ff_wen_enq_ready),

    .deq_data(ff_wen_deq_data),
    .deq_valid(ff_wen_deq_valid),
    .deq_ready(ff_wen_deq_ready)
  );

  wire s_arfire = s_arvalid & s_arready;
  wire s_rfire  = s_rvalid  & s_rready;
  wire s_awfire = s_awvalid & s_awready;
  wire s_wfire  = s_wvalid  & s_wready;
  wire s_bfire  = s_bvalid  & s_bready;

  wire ff_addr_enq_fire  = ff_addr_enq_valid  & ff_addr_enq_ready;
  wire ff_len_enq_fire   = ff_len_enq_valid   & ff_len_enq_ready;
  wire ff_size_enq_fire  = ff_size_enq_valid  & ff_size_enq_ready;
  wire ff_burst_enq_fire = ff_burst_enq_valid & ff_burst_enq_ready;
  wire ff_wen_enq_fire   = ff_wen_enq_valid   & ff_wen_enq_ready;

  wire ff_addr_deq_fire  = ff_addr_deq_valid  & ff_addr_deq_ready;
  wire ff_len_deq_fire   = ff_len_deq_valid   & ff_len_deq_ready;
  wire ff_size_deq_fire  = ff_size_deq_valid  & ff_size_deq_ready;
  wire ff_burst_deq_fire = ff_burst_deq_valid & ff_burst_deq_ready;
  wire ff_wen_deq_fire   = ff_wen_deq_valid   & ff_wen_deq_ready;

  wire squeue_out_fire = squeue_out_valid & squeue_out_ready;

  always @(*) begin
    state_next = state_value;
    case (state_value)
      STATE_IDLE: begin
        if (ff_wen_deq_fire && ff_wen_deq_data && ~socket_reset_pipe)
          state_next = STATE_W_DATA;
        else if (ff_wen_deq_fire && ~ff_wen_deq_data)
          state_next = STATE_R_DATA;
      end

      STATE_W_DATA: begin
        if (s_wlast && s_wfire)
          state_next = STATE_W_RESP;
      end

      STATE_W_RESP: begin
        if (s_bfire)
          state_next = STATE_IDLE;
      end

      STATE_R_DATA: begin
        if (s_rlast && s_rfire)
          state_next = STATE_IDLE;
      end
    endcase
  end

  wire st_idle       = (state_value == STATE_IDLE);
  wire st_w_data     = (state_value == STATE_W_DATA);
  wire st_w_resp     = (state_value == STATE_W_RESP);
  wire st_r_data     = (state_value == STATE_R_DATA);

  wire ss_done_pipe0;
  REGISTER_R_CE #(.N(1), .INIT(0)) ss_done_pipe0_reg (
    .clk(clk),
    .rst((ss_done_pipe0 & st_idle) | ss_start),
    .ce(ss_done),
    .d(1'b1),
    .q(ss_done_pipe0)
  );

  wire ss_running;
  REGISTER_R_CE #(.N(1), .INIT(0)) ss_running_reg (
    .clk(clk),
    .rst(ss_running & ss_done_pipe0 & st_idle),
    .ce(ss_start),
    .d(1'b1),
    .q(ss_running)
  );

  assign ff_wen_enq_data  = s_awvalid ? 1'b1 : 1'b0;
  assign ff_wen_enq_valid = s_awvalid | s_arvalid;
  // Write is prioritized
  assign s_arready        = ~s_awvalid & ff_wen_enq_ready;
  assign s_awready        = ff_wen_enq_ready | socket_reset_pipe;

  assign ff_addr_enq_data  = s_awvalid ? s_awaddr : s_araddr;
  assign ff_addr_enq_valid = s_awvalid | s_arvalid;

  assign ff_len_enq_data    = s_awvalid ? s_awlen : s_arlen;
  assign ff_len_enq_valid   = s_awvalid | s_arvalid;

  assign ff_size_enq_data   = s_awvalid ? s_awsize : s_arsize;
  assign ff_size_enq_valid  = s_awvalid | s_arvalid;

  assign ff_burst_enq_data  = s_awvalid ? s_awburst : s_arburst;
  assign ff_burst_enq_valid = s_awvalid | s_arvalid;

  assign ff_wen_deq_ready   = st_idle;
  assign ff_addr_deq_ready  = st_idle;
  assign ff_len_deq_ready   = st_idle;
  assign ff_size_deq_ready  = st_idle;
  assign ff_burst_deq_ready = st_idle;

  assign addr_next = {ff_addr_deq_data >> LOG2_BYTE_SIZE};
  assign addr_ce   = ff_wen_deq_fire;
  assign addr_rst  = socket_reset;

  assign len_next = ff_len_deq_data + 1;
  assign len_ce   = ff_wen_deq_fire;
  assign len_rst  = socket_reset;

  assign beat_cnt_next = beat_cnt_value + 1;
  assign beat_cnt_ce   = (st_w_data & s_wfire) |
                         (st_r_data & s_rfire);
  assign beat_cnt_rst = st_idle;

  wire [DMEM_AWIDTH-1:0] addr = addr_value + beat_cnt_value;

  wire squeue_read = addr_value[SOCKET_MMIO_REG_SPACE] &
                    (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == SQUEUE_OFFSET) & s_rfire & (beat_cnt_value == 0);

  wire ext_mem_offset_lo_read =
    addr_value[SOCKET_MMIO_REG_SPACE] &
   (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == EXT_MEM_OFFSET_LO) & s_rfire;
  wire ext_mem_offset_hi_read =
    addr_value[SOCKET_MMIO_REG_SPACE] &
   (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == EXT_MEM_OFFSET_HI) & s_rfire;
  wire imem_we_read =
    addr_value[SOCKET_MMIO_REG_SPACE] &
   (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == SOCKET_IMEM_WE_OFFSET) & s_rfire;
  wire imem_addr_read =
    addr_value[SOCKET_MMIO_REG_SPACE] &
   (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == SOCKET_IMEM_ADDR_OFFSET) & s_rfire;
  wire imem_wdata_read =
    addr_value[SOCKET_MMIO_REG_SPACE] &
   (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == SOCKET_IMEM_WDATA_OFFSET) & s_rfire;
  wire imem_rdata_read =
    addr_value[SOCKET_MMIO_REG_SPACE] &
   (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == SOCKET_IMEM_RDATA_OFFSET) & s_rfire;

  wire cnt0_read =
    addr_value[SOCKET_MMIO_REG_SPACE] &
   (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == CNT0_OFFSET) & s_rfire;

  wire cnt1_read =
    addr_value[SOCKET_MMIO_REG_SPACE] &
   (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == CNT1_OFFSET) & s_rfire;

  wire perf_cnt_read =
    addr_value[SOCKET_MMIO_REG_SPACE] &
   (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == PERF_CNT_OFFSET) & s_rfire;

  wire instrument_cnt0_read =
    addr_value[SOCKET_MMIO_REG_SPACE] &
   (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == INSTRUMENT_CNT0_OFFSET) & s_rfire;

  wire instrument_cnt1_read =
    addr_value[SOCKET_MMIO_REG_SPACE] &
   (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == INSTRUMENT_CNT1_OFFSET) & s_rfire;

  wire socket_inbox_read =
    addr_value[SOCKET_MMIO_REG_SPACE] &
   (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == SOCKET_INBOX_OFFSET) & s_rfire;

  wire socket_csr_read = addr_value[SOCKET_MMIO_REG_SPACE] &
                        (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == SOCKET_CSR_OFFSET) &
                         s_rfire;

  wire socket_csr_write = addr_value[SOCKET_MMIO_REG_SPACE] &
                         (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == SOCKET_CSR_OFFSET) &
                          s_wfire;

  wire squeue_read_pipe0;
  REGISTER #(.N(1)) squeue_read_pipe0_reg (
    .clk(clk),
    .d(squeue_read),
    .q(squeue_read_pipe0)
  );

  wire [31:0] squeue_rdata = (~squeue_out_valid ? 32'hFFFFFFFF : squeue_out_data);
  wire [31:0] squeue_rdata_pipe0;
  REGISTER #(.N(32)) squeue_out_data_pipe0_reg (
    .clk(clk),
    .d(squeue_rdata),
    .q(squeue_rdata_pipe0)
  );

  assign s_rdata = socket_csr_read ? socket_csr_value :
                   ext_mem_offset_lo_read ? ext_mem_offset_lo_value :
                   ext_mem_offset_hi_read ? ext_mem_offset_hi_value :
                   imem_we_read ? socket_imem_we_value :
                   imem_addr_read ? socket_imem_addr_value :
                   imem_wdata_read ? socket_imem_wdata_value :
                   imem_rdata_read ? socket_imem_rdata :
                   cnt0_read ? cnt0_value :
                   cnt1_read ? cnt1_value :
                   perf_cnt_read ? perf_cnt_value :
                   instrument_cnt0_read ? instrument_cnt0 :
                   instrument_cnt1_read ? instrument_cnt1 :
                   socket_inbox_read ? socket_inbox_value :
                   squeue_read ? squeue_rdata :
                   squeue_read_pipe0 ? squeue_rdata_pipe0 :
                   ss_running ? ss_in_data : 0;


  assign s_rlast  = (beat_cnt_value == len_value - 1);
  assign s_wready = (st_w_data & (~ss_running | (ss_running & ss_out_ready))) | socket_reset_pipe;
  assign s_bvalid = st_w_resp | (socket_reset_pipe & s_wlast_pipe);

  assign s_rvalid    = st_r_data & (~ss_running | (ss_running & ss_in_valid));
  assign ss_in_ready = st_r_data & ss_running & s_rready;

  assign s_bresp = `RESP_OKAY;
  assign s_rresp = `RESP_OKAY;

  assign squeue_out_ready = squeue_read;

  genvar i;
  generate
    for (i = 0; i < NUM_SYNCS; i = i + 1) begin
      assign sync_en[i] = addr_value[SOCKET_MMIO_REG_SPACE] &
                         (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == SYNC_OFFSET + i) & st_w_data;
    end
  endgenerate

  wire [31:0] write_mask = {{8{s_wstrb[3]}},
                            {8{s_wstrb[2]}},
                            {8{s_wstrb[1]}},
                            {8{s_wstrb[0]}}};

//  assign socket_csr_next = socket_done ? {socket_csr_value[31:2], 1'b1, 1'b0} :
//                                         {s_wdata[31:0] & write_mask};
//  assign socket_csr_ce   = socket_done | (socket_csr_write & |(s_wstrb));
//  assign socket_start = socket_csr_value[0];

  wire socket_done_pipe0;
  REGISTER #(.N(1)) socket_done_pipe0_reg (
    .clk(clk),
    .d(socket_done),
    .q(socket_done_pipe0)
  );

  assign socket_csr_next = socket_done_pipe0 ? {socket_csr_value[31:2], 1'b1, 1'b0} :
                                               {s_wdata[31:0] & write_mask};
  assign socket_csr_ce   = socket_done_pipe0 | (socket_csr_write & |(s_wstrb));

  assign socket_start = socket_csr_value[0];

  assign ext_mem_offset_lo_next = {s_wdata[31:0] & write_mask};
  assign ext_mem_offset_lo_ce   = addr_value[SOCKET_MMIO_REG_SPACE] &
                                 (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == EXT_MEM_OFFSET_LO) & s_wfire & |(s_wstrb);

  assign ext_mem_offset_hi_next = {s_wdata[31:0] & write_mask};
  assign ext_mem_offset_hi_ce   = addr_value[SOCKET_MMIO_REG_SPACE] &
                                 (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == EXT_MEM_OFFSET_HI) & s_wfire & |(s_wstrb);

  assign socket_imem_addr_next = {s_wdata[31:0] & write_mask};
  assign socket_imem_addr_ce   = addr_value[SOCKET_MMIO_REG_SPACE] &
                                (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == SOCKET_IMEM_ADDR_OFFSET) & s_wfire & |(s_wstrb);

  assign socket_imem_wdata_next = {s_wdata[31:0] & write_mask};
  assign socket_imem_wdata_ce   = addr_value[SOCKET_MMIO_REG_SPACE] &
                                 (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == SOCKET_IMEM_WDATA_OFFSET) & s_wfire & |(s_wstrb);

  assign socket_imem_we_next = {s_wdata[31:0] & write_mask};
  assign socket_imem_we_ce   = addr_value[SOCKET_MMIO_REG_SPACE] &
                              (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == SOCKET_IMEM_WE_OFFSET) & s_wfire & |(s_wstrb);

  assign socket_inbox_next = {s_wdata[31:0] & write_mask};
  assign socket_inbox_ce   = addr_value[SOCKET_MMIO_REG_SPACE] &
                            (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == SOCKET_INBOX_OFFSET) & s_wfire & |(s_wstrb);

  assign ext_mem_offset = {ext_mem_offset_hi_value, ext_mem_offset_lo_value};

  assign socket_imem_addr  = socket_imem_addr_value;
  assign socket_imem_wdata = socket_imem_wdata_value;
  assign socket_imem_we    = socket_imem_we_value;
  assign socket_inbox      = socket_inbox_value;

  assign ss_out_data  = s_wdata;
  assign ss_out_valid = (st_w_data & s_wvalid);

endmodule
