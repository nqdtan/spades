`include "socket_config.vh"

module dma_engine_mm_ss #(
  parameter AXI_AWIDTH = 64,
  parameter AXI_DWIDTH = 512,
  parameter WORD_WIDTH = 64,
  parameter ID = 0
) (
  input clk,
  input resetn,

  // (simplified) read request address and read data channel for
  // interfacing with AXI adapter read
  output                  dma_arvalid,
  input                   dma_arready,
  output [AXI_AWIDTH-1:0] dma_araddr,
  output [31:0]           dma_arlen,
  output [2:0]            dma_arsize,
  output [1:0]            dma_arburst,
  input  [AXI_DWIDTH-1:0] dma_rdata,
  input                   dma_rvalid,
  output                  dma_rready,

  // (simplified) write request address and write data channel for
  // interfacing with AXI adapter write
  output                  dma_awvalid,
  input                   dma_awready,
  output [AXI_AWIDTH-1:0] dma_awaddr,
  output [31:0]           dma_awlen,
  output [2:0]            dma_awsize,
  output [1:0]            dma_awburst,
  output [AXI_DWIDTH-1:0] dma_wdata,
  output                  dma_wvalid,
  input                   dma_wready,

  input        dma_start,
  output       dma_done,
  input [1:0]  dma_mode,       // 1: read, 2: write
  input [63:0] dma_ext_addr,   // external address: byte-addressable
  input [31:0] dma_len,        // len of a single ext. mem segment transfer
  input [31:0] dma_stride,     // stride of int. mem
  input [31:0] dma_seg_stride, // stride between ext. mem segments
  input [31:0] dma_seg_count,  // number of ext. mem segments

  output dma_queue_wr_ready,
  output dma_write_idle,

  input [AXI_DWIDTH-1:0]  enq_data,
  input                   enq_valid,
  output                  enq_ready,

  output [AXI_DWIDTH-1:0] deq_data,
  output                  deq_valid,
  input                   deq_ready
);

  localparam LOG2_AXI_BYTE_SIZE  = $clog2(AXI_DWIDTH / 8);
  localparam LOG2_WORD_BYTE_SIZE = $clog2(WORD_WIDTH / 8);

  wire dma_arfire = dma_arvalid & dma_arready;
  wire dma_rfire  = dma_rvalid  & dma_rready;
  wire dma_awfire = dma_awvalid & dma_awready;
  wire dma_wfire  = dma_wvalid  & dma_wready;

  localparam STATE_RD_REQ_IDLE = 0;
  localparam STATE_RD_REQ_RUN  = 1;
  localparam STATE_RD_REQ_DONE = 2;

  wire [1:0] state_rd_req_value;
  reg  [1:0] state_rd_req_next;
  REGISTER_R #(.N(2), .INIT(STATE_RD_REQ_IDLE)) state_rd_req_reg (
    .clk(clk),
    .rst(~resetn),
    .d(state_rd_req_next),
    .q(state_rd_req_value)
  );

  localparam STATE_RD_RESP_IDLE = 0;
  localparam STATE_RD_RESP_RUN  = 1;
  localparam STATE_RD_RESP_DONE = 2;

  wire [1:0] state_rd_resp_value;
  reg  [1:0] state_rd_resp_next;
  REGISTER_R #(.N(2), .INIT(STATE_RD_RESP_IDLE)) state_rd_resp_reg (
    .clk(clk),
    .rst(~resetn),
    .d(state_rd_resp_next),
    .q(state_rd_resp_value)
  );

  localparam STATE_WR_REQ_IDLE = 0;
  localparam STATE_WR_REQ_RUN  = 1;
  localparam STATE_WR_REQ_DONE = 2;

  wire [1:0] state_wr_req_value;
  reg  [1:0] state_wr_req_next;
  REGISTER_R #(.N(2), .INIT(STATE_WR_REQ_IDLE)) state_wr_req_reg (
    .clk(clk),
    .rst(~resetn),
    .d(state_wr_req_next),
    .q(state_wr_req_value)
  );

  localparam STATE_WR_DATA_IDLE = 0;
  localparam STATE_WR_DATA_RUN  = 1;
  localparam STATE_WR_DATA_DONE = 2;

  wire [1:0] state_wr_data_value;
  reg  [1:0] state_wr_data_next;
  REGISTER_R #(.N(2), .INIT(STATE_WR_DATA_IDLE)) state_wr_data_reg (
    .clk(clk),
    .rst(~resetn),
    .d(state_wr_data_next),
    .q(state_wr_data_value)
  );

  wire [31:0] read_seg_cnt0_value, read_seg_cnt0_next;
  wire read_seg_cnt0_rst, read_seg_cnt0_ce;

  REGISTER_R_CE #(.N(32), .INIT(0)) read_seg_cnt0_reg (
    .clk(clk),
    .rst(read_seg_cnt0_rst),
    .ce(read_seg_cnt0_ce),
    .d(read_seg_cnt0_next),
    .q(read_seg_cnt0_value)
  );

  wire [31:0] read_seg_cnt1_value, read_seg_cnt1_next;
  wire read_seg_cnt1_rst, read_seg_cnt1_ce;

  REGISTER_R_CE #(.N(32), .INIT(0)) read_seg_cnt1_reg (
    .clk(clk),
    .rst(read_seg_cnt1_rst),
    .ce(read_seg_cnt1_ce),
    .d(read_seg_cnt1_next),
    .q(read_seg_cnt1_value)
  );

  wire [31:0] write_seg_cnt0_value, write_seg_cnt0_next;
  wire write_seg_cnt0_rst, write_seg_cnt0_ce;

  REGISTER_R_CE #(.N(32), .INIT(0)) write_seg_cnt0_reg (
    .clk(clk),
    .rst(write_seg_cnt0_rst),
    .ce(write_seg_cnt0_ce),
    .d(write_seg_cnt0_next),
    .q(write_seg_cnt0_value)
  );

  wire [31:0] write_seg_cnt1_value, write_seg_cnt1_next;
  wire write_seg_cnt1_rst, write_seg_cnt1_ce;

  REGISTER_R_CE #(.N(32), .INIT(0)) write_seg_cnt1_reg (
    .clk(clk),
    .rst(write_seg_cnt1_rst),
    .ce(write_seg_cnt1_ce),
    .d(write_seg_cnt1_next),
    .q(write_seg_cnt1_value)
  );

  wire [31:0] read_len_cnt0_value, read_len_cnt0_next;
  wire read_len_cnt0_rst, read_len_cnt0_ce;

  REGISTER_R_CE #(.N(32), .INIT(0)) read_len_cnt0_reg (
    .clk(clk),
    .rst(read_len_cnt0_rst),
    .ce(read_len_cnt0_ce),
    .d(read_len_cnt0_next),
    .q(read_len_cnt0_value)
  );

  wire [31:0] read_len_cnt1_value, read_len_cnt1_next;
  wire read_len_cnt1_rst, read_len_cnt1_ce;

  REGISTER_R_CE #(.N(32), .INIT(0)) read_len_cnt1_reg (
    .clk(clk),
    .rst(read_len_cnt1_rst),
    .ce(read_len_cnt1_ce),
    .d(read_len_cnt1_next),
    .q(read_len_cnt1_value)
  );

  wire [31:0] write_len_cnt0_value, write_len_cnt0_next;
  wire write_len_cnt0_rst, write_len_cnt0_ce;

  REGISTER_R_CE #(.N(32), .INIT(0)) write_len_cnt0_reg (
    .clk(clk),
    .rst(write_len_cnt0_rst),
    .ce(write_len_cnt0_ce),
    .d(write_len_cnt0_next),
    .q(write_len_cnt0_value)
  );

  wire [31:0] write_len_cnt1_value, write_len_cnt1_next;
  wire write_len_cnt1_rst, write_len_cnt1_ce;

  REGISTER_R_CE #(.N(32), .INIT(0)) write_len_cnt1_reg (
    .clk(clk),
    .rst(write_len_cnt1_rst),
    .ce(write_len_cnt1_ce),
    .d(write_len_cnt1_next),
    .q(write_len_cnt1_value)
  );

  localparam FIFO_LOGDEPTH = 2;//3;

  wire [AXI_AWIDTH-1:0] ff_ext_addr_enq_data, ff_ext_addr_deq_data;
  wire ff_ext_addr_enq_valid, ff_ext_addr_enq_ready;
  wire ff_ext_addr_deq_valid, ff_ext_addr_deq_ready;

  fifo #(
    .WIDTH(AXI_AWIDTH),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_ext_addr (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_ext_addr_enq_data),
    .enq_valid(ff_ext_addr_enq_valid),
    .enq_ready(ff_ext_addr_enq_ready),

    .deq_data(ff_ext_addr_deq_data),
    .deq_valid(ff_ext_addr_deq_valid),
    .deq_ready(ff_ext_addr_deq_ready)
  );

  wire [31:0] ff_len_enq_data, ff_len_deq_data;
  wire ff_len_enq_valid, ff_len_enq_ready;
  wire ff_len_deq_valid, ff_len_deq_ready;

  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_len (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_len_enq_data),
    .enq_valid(ff_len_enq_valid),
    .enq_ready(ff_len_enq_ready),

    .deq_data(ff_len_deq_data),
    .deq_valid(ff_len_deq_valid),
    .deq_ready(ff_len_deq_ready)
  );

  wire [31:0] ff_seg_stride_enq_data, ff_seg_stride_deq_data;
  wire ff_seg_stride_enq_valid, ff_seg_stride_enq_ready;
  wire ff_seg_stride_deq_valid, ff_seg_stride_deq_ready;

  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_seg_stride (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_seg_stride_enq_data),
    .enq_valid(ff_seg_stride_enq_valid),
    .enq_ready(ff_seg_stride_enq_ready),

    .deq_data(ff_seg_stride_deq_data),
    .deq_valid(ff_seg_stride_deq_valid),
    .deq_ready(ff_seg_stride_deq_ready)
  );

  wire [31:0] ff_seg_count_enq_data, ff_seg_count_deq_data;
  wire ff_seg_count_enq_valid, ff_seg_count_enq_ready;
  wire ff_seg_count_deq_valid, ff_seg_count_deq_ready;

  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_seg_count (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_seg_count_enq_data),
    .enq_valid(ff_seg_count_enq_valid),
    .enq_ready(ff_seg_count_enq_ready),

    .deq_data(ff_seg_count_deq_data),
    .deq_valid(ff_seg_count_deq_valid),
    .deq_ready(ff_seg_count_deq_ready)
  );

  wire [1:0] ff_mode_enq_data, ff_mode_deq_data;
  wire ff_mode_enq_valid, ff_mode_enq_ready;
  wire ff_mode_deq_valid, ff_mode_deq_ready;
  wire ff_mode_almost_full;

  fifo_af #(
    .WIDTH(2),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_mode (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_mode_enq_data),
    .enq_valid(ff_mode_enq_valid),
    .enq_ready(ff_mode_enq_ready),
    .almost_full(ff_mode_almost_full),

    .deq_data(ff_mode_deq_data),
    .deq_valid(ff_mode_deq_valid),
    .deq_ready(ff_mode_deq_ready)
  );

  wire [31:0] ff_len_rd_enq_data, ff_len_rd_deq_data;
  wire ff_len_rd_enq_valid, ff_len_rd_enq_ready;
  wire ff_len_rd_deq_valid, ff_len_rd_deq_ready;

  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_len_rd (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_len_rd_enq_data),
    .enq_valid(ff_len_rd_enq_valid),
    .enq_ready(ff_len_rd_enq_ready),

    .deq_data(ff_len_rd_deq_data),
    .deq_valid(ff_len_rd_deq_valid),
    .deq_ready(ff_len_rd_deq_ready)
  );

  wire [31:0] ff_seg_count_rd_enq_data, ff_seg_count_rd_deq_data;
  wire ff_seg_count_rd_enq_valid, ff_seg_count_rd_enq_ready;
  wire ff_seg_count_rd_deq_valid, ff_seg_count_rd_deq_ready;

  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_seg_count_rd (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_seg_count_rd_enq_data),
    .enq_valid(ff_seg_count_rd_enq_valid),
    .enq_ready(ff_seg_count_rd_enq_ready),

    .deq_data(ff_seg_count_rd_deq_data),
    .deq_valid(ff_seg_count_rd_deq_valid),
    .deq_ready(ff_seg_count_rd_deq_ready)
  );

  wire [31:0] ff_len_wr_enq_data, ff_len_wr_deq_data;
  wire ff_len_wr_enq_valid, ff_len_wr_enq_ready;
  wire ff_len_wr_deq_valid, ff_len_wr_deq_ready;

  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_len_wr (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_len_wr_enq_data),
    .enq_valid(ff_len_wr_enq_valid),
    .enq_ready(ff_len_wr_enq_ready),

    .deq_data(ff_len_wr_deq_data),
    .deq_valid(ff_len_wr_deq_valid),
    .deq_ready(ff_len_wr_deq_ready)
  );

  wire [31:0] ff_seg_count_wr_enq_data, ff_seg_count_wr_deq_data;
  wire ff_seg_count_wr_enq_valid, ff_seg_count_wr_enq_ready;
  wire ff_seg_count_wr_deq_valid, ff_seg_count_wr_deq_ready;

  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_seg_count_wr (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_seg_count_wr_enq_data),
    .enq_valid(ff_seg_count_wr_enq_valid),
    .enq_ready(ff_seg_count_wr_enq_ready),

    .deq_data(ff_seg_count_wr_deq_data),
    .deq_valid(ff_seg_count_wr_deq_valid),
    .deq_ready(ff_seg_count_wr_deq_ready)
  );

  wire ff_ext_addr_enq_fire   = ff_ext_addr_enq_valid & ff_ext_addr_enq_ready;
  wire ff_len_enq_fire        = ff_len_enq_valid & ff_len_enq_ready;
  wire ff_seg_stride_enq_fire = ff_seg_stride_enq_valid & ff_seg_stride_enq_ready;
  wire ff_seg_count_enq_fire  = ff_seg_count_enq_valid & ff_seg_count_enq_ready;
  wire ff_mode_enq_fire       = ff_mode_enq_valid & ff_mode_enq_ready;

  wire ff_ext_addr_deq_fire   = ff_ext_addr_deq_valid & ff_ext_addr_deq_ready;
  wire ff_len_deq_fire        = ff_len_deq_valid & ff_len_deq_ready;
  wire ff_seg_stride_deq_fire = ff_seg_stride_deq_valid & ff_seg_stride_deq_ready;
  wire ff_seg_count_deq_fire  = ff_seg_count_deq_valid & ff_seg_count_deq_ready;
  wire ff_mode_deq_fire       = ff_mode_deq_valid & ff_mode_deq_ready;

  wire ff_len_rd_enq_fire       = ff_len_rd_enq_valid & ff_len_rd_enq_ready;
  wire ff_seg_count_rd_enq_fire = ff_seg_count_rd_enq_valid & ff_seg_count_rd_enq_ready;
  wire ff_len_rd_deq_fire       = ff_len_rd_deq_valid & ff_len_rd_deq_ready;
  wire ff_seg_count_rd_deq_fire = ff_seg_count_rd_deq_valid & ff_seg_count_rd_deq_ready;

  wire ff_len_wr_enq_fire       = ff_len_wr_enq_valid & ff_len_wr_enq_ready;
  wire ff_seg_count_wr_enq_fire = ff_seg_count_wr_enq_valid & ff_seg_count_wr_enq_ready;
  wire ff_len_wr_deq_fire       = ff_len_wr_deq_valid & ff_len_wr_deq_ready;
  wire ff_seg_count_wr_deq_fire = ff_seg_count_wr_deq_valid & ff_seg_count_wr_deq_ready;

  wire st_rd_req_idle = (state_rd_req_value == STATE_RD_REQ_IDLE);
  wire st_rd_req_run  = (state_rd_req_value == STATE_RD_REQ_RUN);
  wire st_rd_req_done = (state_rd_req_value == STATE_RD_REQ_DONE);

  wire st_rd_resp_idle = (state_rd_resp_value == STATE_RD_RESP_IDLE);
  wire st_rd_resp_run  = (state_rd_resp_value == STATE_RD_RESP_RUN);
  wire st_rd_resp_done = (state_rd_resp_value == STATE_RD_RESP_DONE);

  wire st_wr_req_idle  = (state_wr_req_value == STATE_WR_REQ_IDLE);
  wire st_wr_req_run   = (state_wr_req_value == STATE_WR_REQ_RUN);
  wire st_wr_req_done  = (state_wr_req_value == STATE_WR_REQ_DONE);

  wire st_wr_data_idle = (state_wr_data_value == STATE_WR_DATA_IDLE);
  wire st_wr_data_run  = (state_wr_data_value == STATE_WR_DATA_RUN);
  wire st_wr_data_done = (state_wr_data_value == STATE_WR_DATA_DONE);

  wire dma_start_pipe;
  REGISTER_R #(.N(1)) dma_start_pipe_reg (
    .clk(clk),
    .rst(~resetn),
    .d(dma_start),
    .q(dma_start_pipe)
  );

  wire dma_start_pulse;
  REGISTER_R #(.N(1)) dma_start_pulse_reg (
    .clk(clk),
    .rst(~resetn),
    .d(dma_start & ~dma_start_pipe),
    .q(dma_start_pulse)
  );

  REGISTER #(.N(1)) dma_done_reg (
    .clk(clk),
    .d(st_rd_resp_done | st_wr_data_done),
    .q(dma_done)
  );

  wire [AXI_AWIDTH-1:0] dma_ext_addr_pipe;
  REGISTER_R_CE #(.N(AXI_AWIDTH)) dma_ext_addr_pipe_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(ff_ext_addr_deq_fire),
    .d(ff_ext_addr_deq_data),
    .q(dma_ext_addr_pipe)
  );

  wire [1:0] dma_mode_pipe;
  REGISTER_R_CE #(.N(2)) dma_mode_pipe_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(ff_mode_deq_fire),
    .d(ff_mode_deq_data),
    .q(dma_mode_pipe)
  );

  wire [31:0] dma_len_pipe;
  REGISTER_R_CE #(.N(32)) dma_len_pipe_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(ff_len_deq_fire),
    .d(ff_len_deq_data),
    .q(dma_len_pipe)
  );

  wire [31:0] dma_seg_stride_pipe;
  REGISTER_R_CE #(.N(32)) dma_seg_stride_pipe_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(ff_seg_stride_deq_fire),
    .d(ff_seg_stride_deq_data),
    .q(dma_seg_stride_pipe)
  );

  wire [31:0] dma_seg_count_pipe;
  REGISTER_R_CE #(.N(32)) dma_seg_count_pipe_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(ff_seg_count_deq_fire),
    .d(ff_seg_count_deq_data),
    .q(dma_seg_count_pipe)
  );

  wire [31:0] dma_len_rd_pipe;
  REGISTER_R_CE #(.N(32)) dma_len_rd_pipe_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(ff_len_rd_deq_fire),
    .d(ff_len_rd_deq_data),
    .q(dma_len_rd_pipe)
  );

  wire [31:0] dma_seg_count_rd_pipe;
  REGISTER_R_CE #(.N(32)) dma_seg_count_rd_pipe_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(ff_seg_count_rd_deq_fire),
    .d(ff_seg_count_rd_deq_data),
    .q(dma_seg_count_rd_pipe)
  );

  wire [31:0] dma_len_wr_pipe;
  REGISTER_R_CE #(.N(32)) dma_len_wr_pipe_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(ff_len_wr_deq_fire),
    .d(ff_len_wr_deq_data),
    .q(dma_len_wr_pipe)
  );

  wire [31:0] dma_seg_count_wr_pipe;
  REGISTER_R_CE #(.N(32)) dma_seg_count_wr_pipe_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(ff_seg_count_wr_deq_fire),
    .d(ff_seg_count_wr_deq_data),
    .q(dma_seg_count_wr_pipe)
  );

  assign ff_ext_addr_enq_data  = dma_ext_addr;
  assign ff_ext_addr_enq_valid = dma_start_pulse;
  assign ff_mode_enq_data  = dma_mode;
  assign ff_mode_enq_valid = dma_start_pulse;
  assign ff_len_enq_data  = dma_len;
  assign ff_len_enq_valid = dma_start_pulse;
  assign ff_seg_stride_enq_data  = dma_seg_stride;
  assign ff_seg_stride_enq_valid = dma_start_pulse;
  assign ff_seg_count_enq_data  = dma_seg_count;
  assign ff_seg_count_enq_valid = dma_start_pulse;

  wire ff_mode_rd = ff_mode_deq_data == 1;
  wire ff_mode_wr = ff_mode_deq_data == 2;
  assign ff_ext_addr_deq_ready   = (st_rd_req_idle & ff_mode_rd & ff_len_rd_enq_ready) |
                                   (st_wr_req_idle & ff_mode_wr & ff_len_wr_enq_ready);
  assign ff_mode_deq_ready       = (st_rd_req_idle & ff_mode_rd & ff_len_rd_enq_ready) |
                                   (st_wr_req_idle & ff_mode_wr & ff_len_wr_enq_ready);
  assign ff_len_deq_ready        = (st_rd_req_idle & ff_mode_rd & ff_len_rd_enq_ready) |
                                   (st_wr_req_idle & ff_mode_wr & ff_len_wr_enq_ready);
  assign ff_seg_stride_deq_ready = (st_rd_req_idle & ff_mode_rd & ff_len_rd_enq_ready) |
                                   (st_wr_req_idle & ff_mode_wr & ff_len_wr_enq_ready);
  assign ff_seg_count_deq_ready  = (st_rd_req_idle & ff_mode_rd & ff_len_rd_enq_ready) |
                                   (st_wr_req_idle & ff_mode_wr & ff_len_wr_enq_ready);

//  assign dma_queue_full_n = ff_mode_enq_ready;
  assign dma_queue_wr_ready = ~ff_mode_almost_full;

  assign ff_len_rd_enq_data  = ff_len_deq_data;
  assign ff_len_rd_enq_valid = ff_len_deq_valid & st_rd_req_idle & ff_mode_rd;
  assign ff_seg_count_rd_enq_data  = ff_seg_count_deq_data;
  assign ff_seg_count_rd_enq_valid = ff_seg_count_deq_valid & st_rd_req_idle & ff_mode_rd;

  assign ff_len_wr_enq_data  = ff_len_deq_data;
  assign ff_len_wr_enq_valid = ff_len_deq_valid & st_wr_req_idle & ff_mode_wr;
  assign ff_seg_count_wr_enq_data  = ff_seg_count_deq_data;
  assign ff_seg_count_wr_enq_valid = ff_seg_count_deq_valid & st_wr_req_idle & ff_mode_wr;

  assign ff_len_rd_deq_ready       = st_rd_resp_idle;
  assign ff_seg_count_rd_deq_ready = st_rd_resp_idle;
  assign ff_len_wr_deq_ready       = st_wr_data_idle;
  assign ff_seg_count_wr_deq_ready = st_wr_data_idle;

  always @(*) begin
    state_rd_req_next = state_rd_req_value;
    case (state_rd_req_value)
      STATE_RD_REQ_IDLE: begin
        if (ff_mode_deq_fire && (ff_mode_rd))
        //if ((dma_start_pulse == 1) && (dma_mode == 1))
          state_rd_req_next = STATE_RD_REQ_RUN;
      end

      STATE_RD_REQ_RUN: begin
        if ((read_seg_cnt0_value == dma_seg_count_pipe - 1) && dma_arfire)
          state_rd_req_next = STATE_RD_REQ_DONE;
      end

      STATE_RD_REQ_DONE: begin
        //if (st_rd_resp_done)
          state_rd_req_next = STATE_RD_REQ_IDLE;
      end

    endcase
  end

  always @(*) begin
    state_rd_resp_next = state_rd_resp_value;
    case (state_rd_resp_value)
      STATE_RD_RESP_IDLE: begin
        if (ff_len_rd_deq_fire)
          state_rd_resp_next = STATE_RD_RESP_RUN;
      end

      STATE_RD_RESP_RUN: begin
        if ((read_len_cnt0_value == dma_len_rd_pipe - 1) &
            (read_len_cnt1_value == dma_seg_count_rd_pipe - 1) & dma_rfire)
          state_rd_resp_next = STATE_RD_RESP_DONE;
      end

      STATE_RD_RESP_DONE: begin
        state_rd_resp_next = STATE_RD_RESP_IDLE;
      end
    endcase
  end

  always @(*) begin
    state_wr_req_next = state_wr_req_value;
    case (state_wr_req_value)
      STATE_WR_REQ_IDLE: begin
        if (ff_mode_deq_fire && (ff_mode_wr))
          state_wr_req_next = STATE_WR_REQ_RUN;
      end

      STATE_WR_REQ_RUN: begin
        if ((write_seg_cnt0_value == dma_seg_count_pipe - 1) && dma_awfire)
          state_wr_req_next = STATE_WR_REQ_DONE;
      end

      STATE_WR_REQ_DONE: begin
        state_wr_req_next = STATE_WR_REQ_IDLE;
      end

    endcase
  end

  always @(*) begin
    state_wr_data_next = state_wr_data_value;
    case (state_wr_data_value)
      STATE_WR_DATA_IDLE: begin
        if (ff_len_wr_deq_fire)
        //if (st_wr_req_run)
          state_wr_data_next = STATE_WR_DATA_RUN;
      end

      STATE_WR_DATA_RUN: begin
        if ((write_len_cnt0_value == dma_len_wr_pipe - 1) &
            (write_len_cnt1_value == dma_seg_count_wr_pipe - 1) & dma_wfire)
          state_wr_data_next = STATE_WR_DATA_DONE;
      end

      STATE_WR_DATA_DONE: begin
        state_wr_data_next = STATE_WR_DATA_IDLE;
      end
    endcase
  end

  assign dma_arvalid = st_rd_req_run;
  assign dma_araddr  = dma_ext_addr_pipe + {read_seg_cnt1_value << LOG2_AXI_BYTE_SIZE};
  assign dma_arlen   = dma_len_pipe - 1;
  assign dma_arburst = `BURST_INCR;
  assign dma_arsize  = LOG2_AXI_BYTE_SIZE;

  assign read_seg_cnt0_next = read_seg_cnt0_value + 1;
  assign read_seg_cnt0_ce   = dma_arfire;
  assign read_seg_cnt0_rst  = ~resetn | st_rd_req_done;

  assign read_seg_cnt1_next = read_seg_cnt1_value + dma_seg_stride_pipe;
  assign read_seg_cnt1_ce   = dma_arfire;
  assign read_seg_cnt1_rst  = ~resetn | st_rd_req_done;

  assign read_len_cnt0_next = read_len_cnt0_value + 1;
  assign read_len_cnt0_ce   = dma_rfire;
  assign read_len_cnt0_rst  = ~resetn | ((read_len_cnt0_value == dma_len_rd_pipe - 1) &
                                          dma_rfire);

  assign read_len_cnt1_next = read_len_cnt1_value + 1;
  assign read_len_cnt1_ce   = (read_len_cnt0_value == dma_len_rd_pipe - 1) & dma_rfire;
  assign read_len_cnt1_rst  = ~resetn | ((read_len_cnt0_value == dma_len_rd_pipe - 1) &
                                         (read_len_cnt1_value == dma_seg_count_rd_pipe - 1) &
                                          dma_rfire);

  assign deq_data   = dma_rdata;
  assign deq_valid  = dma_rvalid & st_rd_resp_run;
  assign dma_rready = deq_ready  & st_rd_resp_run;

  assign dma_awvalid = st_wr_req_run;
  assign dma_awaddr  = dma_ext_addr_pipe + {write_seg_cnt1_value << LOG2_AXI_BYTE_SIZE};
  assign dma_awlen   = dma_len_pipe - 1;
  assign dma_awburst = `BURST_INCR;
  assign dma_awsize  = LOG2_AXI_BYTE_SIZE;

  assign write_seg_cnt0_next = write_seg_cnt0_value + 1;
  assign write_seg_cnt0_ce   = dma_awfire;
  assign write_seg_cnt0_rst  = ~resetn | ((write_seg_cnt0_value == dma_seg_count_pipe - 1) & dma_awfire);

  assign write_seg_cnt1_next = write_seg_cnt1_value + dma_seg_stride_pipe;
  assign write_seg_cnt1_ce   = dma_awfire;
  assign write_seg_cnt1_rst  = ~resetn | st_wr_req_done;

  assign write_len_cnt0_next = write_len_cnt0_value + 1;
  assign write_len_cnt0_ce   = dma_wfire;
  assign write_len_cnt0_rst  = ~resetn | ((write_len_cnt0_value == dma_len_wr_pipe - 1) &
                                           dma_wfire);

  assign write_len_cnt1_next = write_len_cnt1_value + 1;
  assign write_len_cnt1_ce   = (write_len_cnt0_value == dma_len_wr_pipe - 1) & dma_wfire;
  assign write_len_cnt1_rst  = ~resetn | ((write_len_cnt0_value == dma_len_wr_pipe - 1) &
                                          (write_len_cnt1_value == dma_seg_count_wr_pipe - 1) &
                                           dma_wfire);

  assign dma_wdata  = enq_data;
  assign dma_wvalid = enq_valid  & st_wr_data_run;
  assign enq_ready  = dma_wready & st_wr_data_run;
endmodule
