`include "socket_config.vh"

// Used for system_sim_socket.tcl
module dma_engine #(
  parameter AXI_AWIDTH  = 64,
  parameter AXI_DWIDTH  = 256,
  parameter DMEM_AWIDTH = 10,
  parameter DMEM_DWIDTH = 256,
  parameter MEMORY_UNIT_LATENCY = `MEMORY_UNIT_LATENCY
) (
  input clk,
  input resetn,

  // (simplified) read request address and read data channel for
  // interfacing with AXI adapter read
  output                  dma_read_request_valid,
  input                   dma_read_request_ready,
  output [AXI_AWIDTH-1:0] dma_read_addr,
  output [31:0]           dma_read_len,
  output [2:0]            dma_read_size,
  output [1:0]            dma_read_burst,
  input  [AXI_DWIDTH-1:0] dma_read_data,
  input                   dma_read_data_valid,
  output                  dma_read_data_ready,

  // (simplified) write request address and write data channel for
  // interfacing with AXI adapter write
  output                  dma_write_request_valid,
  input                   dma_write_request_ready,
  output [AXI_AWIDTH-1:0] dma_write_addr,
  output [31:0]           dma_write_len,
  output [2:0]            dma_write_size,
  output [1:0]            dma_write_burst,
  output [AXI_DWIDTH-1:0] dma_write_data,
  output                  dma_write_data_valid,
  input                   dma_write_data_ready,
  input                   dma_write_resp_ok,

  input  dma_start,
  output dma_done,
  output dma_idle,
  input  dma_enqueue,
  input [1:0]  dma_mode,       // 1: Write, 0: Read
  input [63:0] dma_int_addr,   // internal address: word-addressable
  input [63:0] dma_ext_addr,   // external address: byte-addressable
  input [31:0] dma_len,        // len of a single ext. mem segment transfer
  input [31:0] dma_stride,     // stride of int. mem
  input [31:0] dma_offset, // offset to int. mem for every len
  input [31:0] dma_seg_stride, // stride between ext. mem segments
  input [31:0] dma_seg_count,  // number of ext. mem segments
  input [31:0] dma_wval,

  output dma_queue_full,
  output dma_wait,

  output [DMEM_AWIDTH-1:0] dmem_addr,
  output [DMEM_DWIDTH-1:0] dmem_din,
  input  [DMEM_DWIDTH-1:0] dmem_dout,
  output                   dmem_we,
  output                   dmem_en
);

  // TODO: adapt to different word-width configuration
  // There are two different data widths that we need to take care of
  // in order to not giving up too much efficiency:
  //   - Datawidth of Memory Unit   -- line width
  //   - Datawidth of Compute Unit  -- word width
  // Typically, the line width is wider than the word width. This leads to some
  // complications, such as when we need to index to a specific word of a line
  // We want to be able to configure the DMA such that it can arrange the data
  // that is convenient for the Compute Unit to access to (i.e, the Compute Unit
  // should not have any assumption of how the data is aligned or arranged --
  // its memory view should be in terms of word width)
  // The system/interconnect bus width should be == line width to maximize the
  // bandwidth utilization. Therefore, we only issue AXI request that matches
  // the system bus width
  localparam LOG2_BYTE_SIZE = $clog2(DMEM_DWIDTH / 8);

  wire dma_write_request_fire = dma_write_request_valid & dma_write_request_ready;
  wire dma_write_data_fire    = dma_write_data_valid    & dma_write_data_ready;
  wire dma_read_request_fire  = dma_read_request_valid  & dma_read_request_ready;
  wire dma_read_data_fire     = dma_read_data_valid     & dma_read_data_ready;

  localparam STATE_WRITE_IDLE        = 0;
  localparam STATE_WRITE_EXT_ST1     = 1;
  localparam STATE_WRITE_EXT_ST2     = 2;
  localparam STATE_WRITE_SINGLE_ST1  = 3;
  localparam STATE_WRITE_SINGLE_ST2  = 4;
  localparam STATE_WRITE_WAIT        = 5;
  localparam STATE_WRITE_DONE        = 6;

  wire [2:0] state_write_value;
  reg  [2:0] state_write_next;
  REGISTER_R #(.N(3), .INIT(STATE_WRITE_IDLE)) state_write_reg (
    .clk(clk),
    .rst(~resetn),
    .d(state_write_next),
    .q(state_write_value)
  );

  localparam STATE_READ_REQ_IDLE = 0;
  localparam STATE_READ_REQ_RUN  = 1;
  localparam STATE_READ_REQ_WAIT = 2;
  localparam STATE_READ_REQ_DONE = 3;

  wire [1:0] state_read_req_value;
  reg  [1:0] state_read_req_next;
  REGISTER_R #(.N(2), .INIT(STATE_READ_REQ_IDLE)) state_read_req_reg (
    .clk(clk),
    .rst(~resetn),
    .d(state_read_req_next),
    .q(state_read_req_value)
  );

  localparam STATE_READ_RESP_IDLE = 0;
  localparam STATE_READ_RESP_RUN  = 1;
  localparam STATE_READ_RESP_DONE = 2;

  wire [1:0] state_read_resp_value;
  reg  [1:0] state_read_resp_next;
  REGISTER_R #(.N(2), .INIT(STATE_READ_RESP_IDLE)) state_read_resp_reg (
    .clk(clk),
    .rst(~resetn),
    .d(state_read_resp_next),
    .q(state_read_resp_value)
  );

  // count the number of data write transfers
  // use this to index to the DMem on a write transaction
  wire [31:0] write_cnt_next, write_cnt_value;
  wire write_cnt_ce, write_cnt_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) write_cnt_reg (
    .clk(clk),
    .rst(write_cnt_rst),
    .d(write_cnt_next),
    .q(write_cnt_value),
    .ce(write_cnt_ce)
  );

  wire [31:0] write_cnt1_next, write_cnt1_value;
  wire write_cnt1_ce, write_cnt1_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) write_cnt1_reg (
    .clk(clk),
    .rst(write_cnt1_rst),
    .d(write_cnt1_next),
    .q(write_cnt1_value),
    .ce(write_cnt1_ce)
  );

  // count the number of data read transfers
  // use this to index to the DMem on a read transaction
  wire [31:0] read_cnt_next, read_cnt_value;
  wire read_cnt_ce, read_cnt_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) read_cnt_reg (
    .clk(clk),
    .rst(read_cnt_rst),
    .d(read_cnt_next),
    .q(read_cnt_value),
    .ce(read_cnt_ce)
  );

  wire [31:0] read_cnt1_next, read_cnt1_value;
  wire read_cnt1_ce, read_cnt1_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) read_cnt1_reg (
    .clk(clk),
    .rst(read_cnt1_rst),
    .d(read_cnt1_next),
    .q(read_cnt1_value),
    .ce(read_cnt1_ce)
  );

  wire [31:0] seg_cnt_next, seg_cnt_value;
  wire seg_cnt_ce, seg_cnt_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) seg_cnt_reg (
    .clk(clk),
    .rst(seg_cnt_rst),
    .d(seg_cnt_next),
    .q(seg_cnt_value),
    .ce(seg_cnt_ce)
  );

  wire [31:0] seg_cnt0_next, seg_cnt0_value;
  wire seg_cnt0_ce, seg_cnt0_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) seg_cnt0_reg (
    .clk(clk),
    .rst(seg_cnt0_rst),
    .d(seg_cnt0_next),
    .q(seg_cnt0_value),
    .ce(seg_cnt0_ce)
  );

  localparam FIFO_LOGDEPTH = 8;

  wire [63:0] ff_ext_addr_enq_data, ff_ext_addr_deq_data;
  wire ff_ext_addr_enq_valid, ff_ext_addr_enq_ready;
  wire ff_ext_addr_deq_valid, ff_ext_addr_deq_ready;

  fifo #(
    .WIDTH(64),
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

  wire [63:0] ff_int_addr_enq_data, ff_int_addr_deq_data;
  wire ff_int_addr_enq_valid, ff_int_addr_enq_ready;
  wire ff_int_addr_deq_valid, ff_int_addr_deq_ready;

  fifo #(
    .WIDTH(64),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_int_addr (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_int_addr_enq_data),
    .enq_valid(ff_int_addr_enq_valid),
    .enq_ready(ff_int_addr_enq_ready),

    .deq_data(ff_int_addr_deq_data),
    .deq_valid(ff_int_addr_deq_valid),
    .deq_ready(ff_int_addr_deq_ready)
  );

  wire [64:0] ff_int_addr1_enq_data, ff_int_addr1_deq_data;
  wire ff_int_addr1_enq_valid, ff_int_addr1_enq_ready;
  wire ff_int_addr1_deq_valid, ff_int_addr1_deq_ready;

  fifo #(
    .WIDTH(65),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_int_addr1 (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_int_addr1_enq_data),
    .enq_valid(ff_int_addr1_enq_valid),
    .enq_ready(ff_int_addr1_enq_ready),

    .deq_data(ff_int_addr1_deq_data),
    .deq_valid(ff_int_addr1_deq_valid),
    .deq_ready(ff_int_addr1_deq_ready)
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

  wire [31:0] ff_len1_enq_data, ff_len1_deq_data;
  wire ff_len1_enq_valid, ff_len1_enq_ready;
  wire ff_len1_deq_valid, ff_len1_deq_ready;

  fifo #(
    .WIDTH(32),
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

  wire [31:0] ff_stride_enq_data, ff_stride_deq_data;
  wire ff_stride_enq_valid, ff_stride_enq_ready;
  wire ff_stride_deq_valid, ff_stride_deq_ready;

  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_stride (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_stride_enq_data),
    .enq_valid(ff_stride_enq_valid),
    .enq_ready(ff_stride_enq_ready),

    .deq_data(ff_stride_deq_data),
    .deq_valid(ff_stride_deq_valid),
    .deq_ready(ff_stride_deq_ready)
  );

  wire [31:0] ff_offset_enq_data, ff_offset_deq_data;
  wire ff_offset_enq_valid, ff_offset_enq_ready;
  wire ff_offset_deq_valid, ff_offset_deq_ready;

  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_offset (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_offset_enq_data),
    .enq_valid(ff_offset_enq_valid),
    .enq_ready(ff_offset_enq_ready),

    .deq_data(ff_offset_deq_data),
    .deq_valid(ff_offset_deq_valid),
    .deq_ready(ff_offset_deq_ready)
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

  wire [31:0] ff_seg_stride1_enq_data, ff_seg_stride1_deq_data;
  wire ff_seg_stride1_enq_valid, ff_seg_stride1_enq_ready;
  wire ff_seg_stride1_deq_valid, ff_seg_stride1_deq_ready;

  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_seg_stride1 (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_seg_stride1_enq_data),
    .enq_valid(ff_seg_stride1_enq_valid),
    .enq_ready(ff_seg_stride1_enq_ready),

    .deq_data(ff_seg_stride1_deq_data),
    .deq_valid(ff_seg_stride1_deq_valid),
    .deq_ready(ff_seg_stride1_deq_ready)
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

  wire [31:0] ff_seg_count1_enq_data, ff_seg_count1_deq_data;
  wire ff_seg_count1_enq_valid, ff_seg_count1_enq_ready;
  wire ff_seg_count1_deq_valid, ff_seg_count1_deq_ready;

  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_seg_count1 (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_seg_count1_enq_data),
    .enq_valid(ff_seg_count1_enq_valid),
    .enq_ready(ff_seg_count1_enq_ready),

    .deq_data(ff_seg_count1_deq_data),
    .deq_valid(ff_seg_count1_deq_valid),
    .deq_ready(ff_seg_count1_deq_ready)
  );

  wire [31:0] ff_wval_enq_data, ff_wval_deq_data;
  wire ff_wval_enq_valid, ff_wval_enq_ready;
  wire ff_wval_deq_valid, ff_wval_deq_ready;

  fifo #(
    .WIDTH(32),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_wval (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_wval_enq_data),
    .enq_valid(ff_wval_enq_valid),
    .enq_ready(ff_wval_enq_ready),

    .deq_data(ff_wval_deq_data),
    .deq_valid(ff_wval_deq_valid),
    .deq_ready(ff_wval_deq_ready)
  );

  wire [1:0] ff_mode_enq_data, ff_mode_deq_data;
  wire ff_mode_enq_valid, ff_mode_enq_ready;
  wire ff_mode_deq_valid, ff_mode_deq_ready;

  fifo #(
    .WIDTH(2),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_mode (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_mode_enq_data),
    .enq_valid(ff_mode_enq_valid),
    .enq_ready(ff_mode_enq_ready),

    .deq_data(ff_mode_deq_data),
    .deq_valid(ff_mode_deq_valid),
    .deq_ready(ff_mode_deq_ready)
  );

  assign dma_queue_full = ~ff_mode_enq_ready;

  wire ff_ext_addr_enq_fire   = ff_ext_addr_enq_valid   & ff_ext_addr_enq_ready;
  wire ff_int_addr_enq_fire   = ff_int_addr_enq_valid   & ff_int_addr_enq_ready;
  wire ff_int_addr1_enq_fire  = ff_int_addr1_enq_valid  & ff_int_addr1_enq_ready;
  wire ff_len_enq_fire        = ff_len_enq_valid        & ff_len_enq_ready;
  wire ff_stride_enq_fire     = ff_stride_enq_valid     & ff_stride_enq_ready;
  wire ff_offset_enq_fire     = ff_offset_enq_valid     & ff_offset_enq_ready;
  wire ff_seg_stride_enq_fire = ff_seg_stride_enq_valid & ff_seg_stride_enq_ready;
  wire ff_seg_count_enq_fire  = ff_seg_count_enq_valid  & ff_seg_count_enq_ready;
  wire ff_wval_enq_fire       = ff_wval_enq_valid       & ff_wval_enq_ready;
  wire ff_mode_enq_fire       = ff_mode_enq_valid       & ff_mode_enq_ready;

  wire ff_ext_addr_deq_fire   = ff_ext_addr_deq_valid   & ff_ext_addr_deq_ready;
  wire ff_int_addr_deq_fire   = ff_int_addr_deq_valid   & ff_int_addr_deq_ready;
  wire ff_int_addr1_deq_fire  = ff_int_addr1_deq_valid  & ff_int_addr1_deq_ready;
  wire ff_len_deq_fire        = ff_len_deq_valid        & ff_len_deq_ready;
  wire ff_stride_deq_fire     = ff_stride_deq_valid     & ff_stride_deq_ready;
  wire ff_offset_deq_fire     = ff_offset_deq_valid     & ff_offset_deq_ready;
  wire ff_seg_stride_deq_fire = ff_seg_stride_deq_valid & ff_seg_stride_deq_ready;
  wire ff_seg_count_deq_fire  = ff_seg_count_deq_valid  & ff_seg_count_deq_ready;
  wire ff_wval_deq_fire       = ff_wval_deq_valid       & ff_wval_deq_ready;
  wire ff_mode_deq_fire       = ff_mode_deq_valid       & ff_mode_deq_ready;

  wire ff_len1_enq_fire        = ff_len1_enq_valid        & ff_len1_enq_ready;
  wire ff_len1_deq_fire        = ff_len1_deq_valid        & ff_len1_deq_ready;
  wire ff_seg_count1_enq_fire  = ff_seg_count1_enq_valid  & ff_seg_count1_enq_ready;
  wire ff_seg_count1_deq_fire  = ff_seg_count1_deq_valid  & ff_seg_count1_deq_ready;
  wire ff_seg_stride1_enq_fire = ff_seg_stride1_enq_valid & ff_seg_stride1_enq_ready;
  wire ff_seg_stride1_deq_fire = ff_seg_stride1_deq_valid & ff_seg_stride1_deq_ready;

  wire [63:0] dma_ext_addr_pipe0;
  REGISTER_CE #(.N(64)) dma_ext_addr_pipe0_reg (
    .clk(clk),
    .ce(ff_ext_addr_deq_fire),
    .d(ff_ext_addr_deq_data),
    .q(dma_ext_addr_pipe0)
  );

  wire [63:0] dma_int_addr_pipe0;
  REGISTER_CE #(.N(64)) dma_int_addr_pipe0_reg (
    .clk(clk),
    .ce(ff_int_addr1_deq_fire),
    .d(ff_int_addr1_deq_data[63:0]),
    .q(dma_int_addr_pipe0)
  );

  wire [31:0] dma_len_pipe0;
  REGISTER_CE #(.N(32)) dma_len_pipe0_reg (
    .clk(clk),
    .ce(ff_len_deq_fire),
    .d(ff_len_deq_data),
    .q(dma_len_pipe0)
  );

  wire [31:0] dma_len1_pipe0;
  REGISTER_CE #(.N(32)) dma_len1_pipe0_reg (
    .clk(clk),
    .ce(ff_len1_deq_fire),
    .d(ff_len1_deq_data),
    .q(dma_len1_pipe0)
  );

  wire [31:0] dma_stride_pipe0;
  REGISTER_CE #(.N(32)) dma_stride_pipe0_reg (
    .clk(clk),
    .ce(ff_stride_deq_fire),
    .d(ff_stride_deq_data),
    .q(dma_stride_pipe0)
  );

  wire [31:0] dma_offset_pipe0;
  REGISTER_CE #(.N(32)) dma_offset_pipe0_reg (
    .clk(clk),
    .ce(ff_offset_deq_fire),
    .d(ff_offset_deq_data),
    .q(dma_offset_pipe0)
  );

  wire [31:0] dma_seg_stride_pipe0;
  REGISTER_CE #(.N(32)) dma_seg_stride_pipe0_reg (
    .clk(clk),
    .ce(ff_seg_stride_deq_fire),
    .d(ff_seg_stride_deq_data),
    .q(dma_seg_stride_pipe0)
  );

  wire [31:0] dma_seg_stride1_pipe0;
  REGISTER_CE #(.N(32)) dma_seg_stride1_pipe0_reg (
    .clk(clk),
    .ce(ff_seg_stride1_deq_fire),
    .d(ff_seg_stride1_deq_data),
    .q(dma_seg_stride1_pipe0)
  );

  wire [31:0] dma_seg_count_pipe0;
  REGISTER_CE #(.N(32)) dma_seg_count_pipe0_reg (
    .clk(clk),
    .ce(ff_seg_count_deq_fire),
    .d(ff_seg_count_deq_data),
    .q(dma_seg_count_pipe0)
  );

  wire [31:0] dma_seg_count1_pipe0;
  REGISTER_CE #(.N(32)) dma_seg_count1_pipe0_reg (
    .clk(clk),
    .ce(ff_seg_count1_deq_fire),
    .d(ff_seg_count1_deq_data),
    .q(dma_seg_count1_pipe0)
  );

  wire [31:0] dma_wval_pipe0;
  REGISTER_CE #(.N(32)) dma_wval_pipe0_reg (
    .clk(clk),
    .ce(ff_wval_deq_fire),
    .d(ff_wval_deq_data),
    .q(dma_wval_pipe0)
  );

  wire [1:0] dma_mode_pipe0;
  REGISTER_CE #(.N(2)) dma_mode_pipe0_reg (
    .clk(clk),
    .ce(ff_mode_deq_fire),
    .d(ff_mode_deq_data),
    .q(dma_mode_pipe0)
  );

  // Buffer dmem_dout to this FIFO
  // The core interface will read from this FIFO to send data to the axi adapter
  wire [DMEM_DWIDTH-1:0] ff_dmem_dout_enq_data, ff_dmem_dout_deq_data;
  wire ff_dmem_dout_enq_valid, ff_dmem_dout_enq_ready;
  wire ff_dmem_dout_deq_valid, ff_dmem_dout_deq_ready;
  fifo #(
    .WIDTH(DMEM_DWIDTH),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_dmem_dout (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_dmem_dout_enq_data),
    .enq_valid(ff_dmem_dout_enq_valid),
    .enq_ready(ff_dmem_dout_enq_ready),

    .deq_data(ff_dmem_dout_deq_data),
    .deq_valid(ff_dmem_dout_deq_valid),
    .deq_ready(ff_dmem_dout_deq_ready)
  );

  wire ff_dmem_dout_enq_fire = ff_dmem_dout_enq_valid & ff_dmem_dout_enq_ready;
  wire ff_dmem_dout_deq_fire = ff_dmem_dout_deq_valid & ff_dmem_dout_deq_ready;

  wire [31:0] dmem_latency_cnt_next, dmem_latency_cnt_value;
  wire dmem_latency_cnt_ce, dmem_latency_cnt_rst;
  REGISTER_R_CE #(.N(32)) dmem_latency_cnt_reg (
    .clk(clk),
    .d(dmem_latency_cnt_next),
    .q(dmem_latency_cnt_value),
    .ce(dmem_latency_cnt_ce),
    .rst(dmem_latency_cnt_rst)
  );

  wire [31:0] dmem_read_idx_next, dmem_read_idx_value;
  wire dmem_read_idx_ce, dmem_read_idx_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) dmem_read_idx_reg (
    .clk(clk),
    .rst(dmem_read_idx_rst),
    .d(dmem_read_idx_next),
    .q(dmem_read_idx_value),
    .ce(dmem_read_idx_ce)
  );

  wire [31:0] dmem_read_idx1_next, dmem_read_idx1_value;
  wire dmem_read_idx1_ce, dmem_read_idx1_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) dmem_read_idx1_reg (
    .clk(clk),
    .rst(dmem_read_idx1_rst),
    .d(dmem_read_idx1_next),
    .q(dmem_read_idx1_value),
    .ce(dmem_read_idx1_ce)
  );

  wire st_write_idle = state_write_value == STATE_WRITE_IDLE;
  wire st_write_ext1 = state_write_value == STATE_WRITE_EXT_ST1;
  wire st_write_ext2 = state_write_value == STATE_WRITE_EXT_ST2;
  wire st_wval1      = state_write_value == STATE_WRITE_SINGLE_ST1;
  wire st_wval2      = state_write_value == STATE_WRITE_SINGLE_ST2;
  wire st_write_wait = state_write_value == STATE_WRITE_WAIT;
  wire st_write_done = state_write_value == STATE_WRITE_DONE;

  wire st_read_req_idle = state_read_req_value == STATE_READ_REQ_IDLE;
  wire st_read_req_run  = state_read_req_value == STATE_READ_REQ_RUN;
  wire st_read_req_wait = state_read_req_value == STATE_READ_REQ_WAIT;
  wire st_read_req_done = state_read_req_value == STATE_READ_REQ_DONE;

  wire st_read_resp_idle = state_read_resp_value == STATE_READ_RESP_IDLE;
  wire st_read_resp_run  = state_read_resp_value == STATE_READ_RESP_RUN;
  wire st_read_resp_done = state_read_resp_value == STATE_READ_RESP_DONE;

  wire dma_read_start, dma_write_start;
  wire write_wait_ext, write_wait_single;

  REGISTER_R_CE #(.N(1)) write_wait_ext_reg (
    .clk(clk),
    .rst(~resetn | st_write_done),
    .ce(dma_write_start & st_write_idle & ff_mode_deq_data == 1),
    .d(1'b1),
    .q(write_wait_ext)
  );

  REGISTER_R_CE #(.N(1)) write_wait_single_reg (
    .clk(clk),
    .rst(~resetn | st_write_done),
    .ce(dma_write_start & st_write_idle & ff_mode_deq_data == 2),
    .d(1'b1),
    .q(write_wait_single)
  );

  always @(*) begin
    state_read_req_next = state_read_req_value;
    case (state_read_req_value)
      STATE_READ_REQ_IDLE: begin
        if (ff_mode_deq_fire && (ff_mode_deq_data == 0))
          state_read_req_next = STATE_READ_REQ_RUN;
        else if (dma_read_start && (~ff_int_addr1_enq_ready))
          state_read_req_next = STATE_READ_REQ_WAIT;
      end

      STATE_READ_REQ_RUN: begin
        if (seg_cnt0_value == dma_seg_count_pipe0)
          state_read_req_next = STATE_READ_REQ_DONE;
      end

      STATE_READ_REQ_WAIT: begin
        if (ff_int_addr1_enq_ready)
          state_read_req_next = STATE_READ_REQ_RUN;
      end

      STATE_READ_REQ_DONE: begin
        state_read_req_next = STATE_READ_REQ_IDLE;
      end
    endcase
  end

  always @(*) begin
    state_read_resp_next = state_read_resp_value;
    case (state_read_resp_value)
      STATE_READ_RESP_IDLE: begin
        if (ff_int_addr1_deq_data[64] && ff_int_addr1_deq_fire)
          state_read_resp_next = STATE_READ_RESP_RUN;
      end

      STATE_READ_RESP_RUN: begin
        if (read_cnt1_value == dma_len1_pipe0) begin
          if (seg_cnt_value == dma_seg_count1_pipe0 - 1) begin
            if (~ff_int_addr1_deq_valid)
              state_read_resp_next = STATE_READ_RESP_DONE;
            else
              state_read_resp_next = STATE_READ_RESP_IDLE;
          end
        end
      end

      STATE_READ_RESP_DONE: begin
        state_read_resp_next = STATE_READ_RESP_IDLE;
      end
    endcase
  end

  always @(*) begin
    state_write_next = state_write_value;
    case (state_write_value)
      STATE_WRITE_IDLE: begin
        if (ff_mode_deq_fire) begin
          if (ff_mode_deq_data == 1)
            state_write_next = STATE_WRITE_EXT_ST1;
          else if (ff_mode_deq_data == 2)
            state_write_next = STATE_WRITE_SINGLE_ST1;
        end
        else if (dma_write_start && ~ff_int_addr1_enq_ready)
          state_write_next = STATE_WRITE_WAIT;
      end

      STATE_WRITE_EXT_ST1: begin
        // a buffer state to setup reading from DMem,
        // since reading from synchronous memory takes one cycle
        if (dma_write_request_fire) begin
          state_write_next = STATE_WRITE_EXT_ST2;
        end
      end

      STATE_WRITE_EXT_ST2: begin
        if (write_cnt1_value == dma_len1_pipe0) begin
          if (seg_cnt_value == dma_seg_count1_pipe0 - 1)
            state_write_next = STATE_WRITE_DONE;
          else
            state_write_next = STATE_WRITE_EXT_ST1;
        end
      end

      STATE_WRITE_SINGLE_ST1: begin
        if (dma_write_request_fire)
          state_write_next = STATE_WRITE_SINGLE_ST2;
      end

      STATE_WRITE_SINGLE_ST2: begin
        if (dma_write_data_fire)
          state_write_next = STATE_WRITE_DONE;
      end

      STATE_WRITE_WAIT: begin
        if (ff_int_addr1_enq_ready) begin
          if (write_wait_ext)
            state_write_next = STATE_WRITE_EXT_ST1;
          else if (write_wait_single)
            state_write_next = STATE_WRITE_SINGLE_ST1;
        end
      end

      STATE_WRITE_DONE: begin
        if (dma_write_resp_ok)
          state_write_next = STATE_WRITE_IDLE;
      end
    endcase
  end

  // TODO: check for backpressure from the fifos
  // If we overflow the FIFO, the DMA should generate some error signal
  assign ff_ext_addr_enq_data  = dma_ext_addr;
  assign ff_ext_addr_enq_valid = dma_enqueue;

  assign ff_int_addr_enq_data  = dma_int_addr;
  assign ff_int_addr_enq_valid = dma_enqueue;

  assign ff_len_enq_data       = dma_len;
  assign ff_len_enq_valid      = dma_enqueue;

  assign ff_stride_enq_data    = dma_stride;
  assign ff_stride_enq_valid   = dma_enqueue;

  assign ff_offset_enq_data   = dma_offset;
  assign ff_offset_enq_valid  = dma_enqueue;

  assign ff_seg_stride_enq_data  = dma_seg_stride;
  assign ff_seg_stride_enq_valid = dma_enqueue;

  assign ff_seg_count_enq_data  = dma_seg_count;
  assign ff_seg_count_enq_valid = dma_enqueue;

  assign ff_wval_enq_data      = dma_wval;
  assign ff_wval_enq_valid     = dma_enqueue;

  assign ff_mode_enq_data      = dma_mode;
  assign ff_mode_enq_valid     = dma_enqueue;

  assign ff_len1_enq_data  = ff_len_deq_data;
  assign ff_len1_enq_valid = ((st_read_req_idle & dma_read_start) | (st_write_idle & dma_write_start) | st_read_req_wait | st_write_wait) & ff_int_addr1_enq_ready;
  assign ff_len1_deq_ready = st_read_resp_idle | st_write_ext1;

  assign ff_seg_count1_enq_data  = ff_seg_count_deq_data;
  assign ff_seg_count1_enq_valid = ((st_read_req_idle & dma_read_start) | (st_write_idle & dma_write_start) | st_read_req_wait | st_write_wait) & ff_int_addr1_enq_ready;
  assign ff_seg_count1_deq_ready = st_read_resp_idle | st_write_ext1;

  assign ff_seg_stride1_enq_data  = ff_seg_stride_deq_data;
  assign ff_seg_stride1_enq_valid = ((st_read_req_idle & dma_read_start) | (st_write_idle & dma_write_start) | st_read_req_wait | st_write_wait) & ff_int_addr1_enq_ready;
  assign ff_seg_stride1_deq_ready = st_read_resp_idle | st_write_ext1;

  assign dma_read_start  = dma_start & (ff_mode_deq_data == 0);
  assign dma_write_start = dma_start & (ff_mode_deq_data != 0);

  assign dma_wait = ~dma_idle;

  assign ff_int_addr1_enq_data  = {(ff_mode_deq_data == 0), ff_int_addr_deq_data};
  assign ff_int_addr1_enq_valid = ff_int_addr_deq_valid &
                                  ((st_read_req_idle & dma_read_start) | (st_write_idle & dma_write_start) | st_read_req_wait | st_write_wait);

  assign ff_ext_addr_deq_ready   = ((st_read_req_idle & dma_read_start) | (st_write_idle & dma_write_start) | st_read_req_wait | st_write_wait) & ff_int_addr1_enq_ready;
  assign ff_int_addr_deq_ready   = ((st_read_req_idle & dma_read_start) | (st_write_idle & dma_write_start) | st_read_req_wait | st_write_wait) & ff_int_addr1_enq_ready;
  assign ff_len_deq_ready        = ((st_read_req_idle & dma_read_start) | (st_write_idle & dma_write_start) | st_read_req_wait | st_write_wait) & ff_int_addr1_enq_ready;
  assign ff_seg_stride_deq_ready = ((st_read_req_idle & dma_read_start) | (st_write_idle & dma_write_start) | st_read_req_wait | st_write_wait) & ff_int_addr1_enq_ready;
  assign ff_seg_count_deq_ready  = ((st_read_req_idle & dma_read_start) | (st_write_idle & dma_write_start) | st_read_req_wait | st_write_wait) & ff_int_addr1_enq_ready;
  assign ff_wval_deq_ready       = ((st_write_idle & dma_write_start) | st_write_wait) & ff_int_addr1_enq_ready;
  assign ff_mode_deq_ready       = ((st_read_req_idle & dma_read_start) | (st_write_idle & dma_write_start) | st_read_req_wait | st_write_wait) & ff_int_addr1_enq_ready;

  assign ff_stride_deq_ready    = st_read_resp_idle | st_write_ext1;
  assign ff_offset_deq_ready    = st_read_resp_idle | st_write_ext1;
  assign ff_int_addr1_deq_ready = st_read_resp_idle | st_write_ext1;

  assign dma_idle = st_read_req_idle & st_write_idle;

  assign dma_done = st_read_resp_done | (st_write_done & dma_write_resp_ok);

  assign write_cnt_next = write_cnt_value + dma_stride_pipe0;
  assign write_cnt_ce   = (st_write_ext2 & dma_write_data_fire);
  assign write_cnt_rst  = st_write_ext2 & (write_cnt1_value == dma_len1_pipe0);

  assign write_cnt1_next = write_cnt1_value + 1;
  assign write_cnt1_ce   = (st_write_ext2 & dma_write_data_fire);
  assign write_cnt1_rst  = st_write_ext2 & (write_cnt1_value == dma_len1_pipe0);

  assign read_cnt_next = read_cnt_value + dma_stride_pipe0;
  assign read_cnt_ce   = dma_read_data_fire;
  assign read_cnt_rst  = (read_cnt1_value == dma_len1_pipe0);

  assign read_cnt1_next = read_cnt1_value + 1;
  assign read_cnt1_ce   = dma_read_data_fire;
  assign read_cnt1_rst  = (read_cnt1_value == dma_len1_pipe0);

  assign seg_cnt_next = seg_cnt_value + 1;
  assign seg_cnt_ce   = (st_read_resp_run & (read_cnt1_value > 0) & (read_cnt1_value == dma_len1_pipe0)) |
                        (st_write_ext2 & (write_cnt1_value == dma_len1_pipe0));
  assign seg_cnt_rst  = (seg_cnt_value == dma_seg_count1_pipe0);

  assign seg_cnt0_next = seg_cnt0_value + 1;
  assign seg_cnt0_ce   = st_read_req_run  & (dma_read_request_fire);
  assign seg_cnt0_rst  = (seg_cnt0_value == dma_seg_count_pipe0);

  // for read request
  wire [31:0] seg_scnt0_value;
  REGISTER_R_CE #(.N(32)) seg_scnt0_reg (
    .clk(clk),
    .d(seg_scnt0_value + dma_seg_stride_pipe0),
    .q(seg_scnt0_value),
    .ce(seg_cnt0_ce),
    .rst(seg_cnt0_rst)
  );

  // for read response & write request
  wire [31:0] seg_scnt_value;
  REGISTER_R_CE #(.N(32)) seg_scnt_reg (
    .clk(clk),
    .d(seg_scnt_value + dma_seg_stride1_pipe0),
    .q(seg_scnt_value),
    .ce(seg_cnt_ce),
    .rst(seg_cnt_rst)
  );

  wire [31:0] dma_slen_seg_cnt_value;
  wire [31:0] slen = st_read_resp_run ? read_cnt_value : write_cnt_value;
  REGISTER_R_CE #(.N(32)) dma_slen_seg_cnt_reg (
    .clk(clk),
    .d(dma_slen_seg_cnt_value + slen + dma_offset_pipe0),
    .q(dma_slen_seg_cnt_value),
    .ce(seg_cnt_ce),
    .rst(seg_cnt_rst)
  );

  wire dmem_ren_pipe;
  pipe_block #(.NUM_STAGES(MEMORY_UNIT_LATENCY), .WIDTH(1)) dmem_ren_pipe_block (
    .clk(clk),
    .d(dmem_read_idx_ce),
    .q(dmem_ren_pipe)
  );

  wire [DMEM_DWIDTH-1:0] ff_dmem_dout0_enq_data, ff_dmem_dout0_deq_data;
  wire ff_dmem_dout0_enq_valid, ff_dmem_dout0_enq_ready;
  wire ff_dmem_dout0_deq_valid, ff_dmem_dout0_deq_ready;
  fifo #(
    .WIDTH(DMEM_DWIDTH),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_dmem_dout0 (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_dmem_dout0_enq_data),
    .enq_valid(ff_dmem_dout0_enq_valid),
    .enq_ready(ff_dmem_dout0_enq_ready),

    .deq_data(ff_dmem_dout0_deq_data),
    .deq_valid(ff_dmem_dout0_deq_valid),
    .deq_ready(ff_dmem_dout0_deq_ready)
  );

  assign dmem_latency_cnt_next = dmem_latency_cnt_value + 1;
  assign dmem_latency_cnt_ce   = (st_write_ext1 & dma_write_request_fire) |
                                 (dmem_latency_cnt_value >= 1 & dmem_latency_cnt_value <= MEMORY_UNIT_LATENCY);
  assign dmem_latency_cnt_rst  = st_write_ext2 & (write_cnt1_value == dma_len1_pipe0);

  assign dmem_read_idx_next = dmem_read_idx_value + dma_stride_pipe0;
  assign dmem_read_idx_ce   = (dmem_latency_cnt_value >= 1) &
                              (dmem_read_idx1_value <= dma_len1_pipe0 - 1) &
                              (ff_dmem_dout_enq_ready);
  assign dmem_read_idx_rst  = st_write_ext2 & (write_cnt1_value == dma_len1_pipe0);

  assign dmem_read_idx1_next = dmem_read_idx1_value + 1;
  assign dmem_read_idx1_ce   = (dmem_latency_cnt_value >= 1) &
                              (dmem_read_idx1_value <= dma_len1_pipe0 - 1) &
                              (ff_dmem_dout_enq_ready);
  assign dmem_read_idx1_rst  = st_write_ext2 & (write_cnt1_value == dma_len1_pipe0);

  assign ff_dmem_dout0_enq_data  = dmem_dout;
  assign ff_dmem_dout0_enq_valid = dmem_ren_pipe;
  assign ff_dmem_dout0_deq_ready = ff_dmem_dout_enq_ready;

  assign ff_dmem_dout_enq_data  = ff_dmem_dout0_deq_data;
  assign ff_dmem_dout_enq_valid = ff_dmem_dout0_deq_valid;
  assign ff_dmem_dout_deq_ready = dma_write_data_ready;

  // setup DMA write request address and data
  // use burst mode INCR with a length of dma_len and 8 bytes per data beat
  assign dma_write_request_valid = st_write_ext1 | st_wval1;
  assign dma_write_addr          = dma_ext_addr_pipe0 + {seg_scnt_value << LOG2_BYTE_SIZE};
  assign dma_write_len           = st_write_ext1 ? (dma_len_pipe0 - 1) : 0;
  assign dma_write_burst         = `BURST_INCR;
  assign dma_write_size          = LOG2_BYTE_SIZE; // 2^3 bytes
  assign dma_write_data_valid    = ff_dmem_dout_deq_valid | st_wval2;
  assign dma_write_data          = st_write_ext2 ? ff_dmem_dout_deq_data : dma_wval_pipe0;

  // setup DMA read request address and read response data
  // use burst mode INCR with a length of dma_len and 8 bytes per data beat
  assign dma_read_request_valid = st_read_req_run;
  assign dma_read_addr          = dma_ext_addr_pipe0 + {seg_scnt0_value << LOG2_BYTE_SIZE};
  assign dma_read_len           = dma_len_pipe0 - 1;
  assign dma_read_burst         = `BURST_INCR;
  assign dma_read_size          = LOG2_BYTE_SIZE; // 2^3 bytes
  assign dma_read_data_ready    = st_read_resp_run;

  // setup DMem access
  // write to DMem on a read from EXT, and read from DMem on a write to EXT
  assign dmem_addr = st_read_resp_run ? (dma_int_addr_pipe0 + dma_slen_seg_cnt_value + read_cnt_value) :
                                        (dma_int_addr_pipe0 + dma_slen_seg_cnt_value + dmem_read_idx_value);
  assign dmem_we   = dma_read_data_fire;
  assign dmem_din  = dma_read_data;

  // use the enable pin of DMem to make sure that the DMem dout
  // won't get updated when there is no handshake on write/read data
  assign dmem_en = (dmem_latency_cnt_value >= 1) |
                    dma_read_data_fire;

`ifdef DEBUG
  always @(posedge clk) begin
    if (dma_read_start === 1'b1)
      $display("[At %t] [%m] DMA RD started, addr=%h, len=%h", $time, ff_ext_addr_deq_data, ff_len_deq_data);
    if (st_read_resp_done === 1'b1)
      $display("[At %t] [%m] DMA RD done", $time);

    if (dma_write_start === 1'b1)
      $display("[At %t] [%m] DMA WR started, addr=%h, len=%h", $time, ff_ext_addr_deq_data, ff_len_deq_data);
    if ((st_write_done & dma_write_resp_ok) === 1'b1)
      $display("[At %t] [%m] DMA WR done", $time);
  end
`endif
endmodule
