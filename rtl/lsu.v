`timescale 1ns/1ps
`include "socket_config.vh"

//`define DEBUG_LSU 1
// Load/Store Unit
// On parallel update, 4 ports are used to read/write to ram groups concurrently.
// For now, support cyclic factor that is divisible by 2
module lsu_core #(
  parameter AWIDTH   = 12,
  parameter DWIDTH   = 64,
  parameter RAM_READ_LATENCY = 4,
  parameter ID = 0
) (
  output [2*AWIDTH-1:0] port0_addr,
  output [2*DWIDTH-1:0] port0_d,
  input  [2*DWIDTH-1:0] port0_q,
  output [1:0]          port0_ce,
  output                port0_we,

  output [2*AWIDTH-1:0] port1_addr,
  output [2*DWIDTH-1:0] port1_d,
  input  [2*DWIDTH-1:0] port1_q,
  output [1:0]          port1_ce,
  output                port1_we,

  output [2*AWIDTH-1:0] port2_addr,
  output [2*DWIDTH-1:0] port2_d,
  input  [2*DWIDTH-1:0] port2_q,
  output [1:0]          port2_ce,
  output                port2_we,

  output [2*AWIDTH-1:0] port3_addr,
  output [2*DWIDTH-1:0] port3_d,
  input  [2*DWIDTH-1:0] port3_q,
  output [1:0]          port3_ce,
  output                port3_we,

  input  [2*DWIDTH-1:0] ss_in_data,
  input                 ss_in_valid,
  output                ss_in_ready,

  output [511:0]      ss_out_data,
  output              ss_out_valid,
  input               ss_out_ready,

  output [4:0] ram_en,

  input parallel_mode,

  input parallel_in,
  input [2*DWIDTH-1:0] word0_in,
  input [2*DWIDTH-1:0] word1_in,
  input [2*DWIDTH-1:0] word2_in,
  input [2*DWIDTH-1:0] word3_in,

  input  lsu_start,
  output lsu_done,

  input [4:0] ram_en_init,
  input [31:0] ram_cnt_init,

  input [31:0] ram_block_factor,
  input [31:0] ram_cyclic_factor,
  input [31:0] ram_stride,
  input [31:0] ram_seg_stride,
  input [31:0] ram_addr_offset,

  input [31:0] seg_count,
  input [31:0] len,
  input [31:0] mode,

  input [31:0] ram_block_factor_updated,
  input [31:0] ram_block_factor_base,
  input dw_mode,
  input dp_mode,
  input dp_mode_base0,
  input dp_mode_base2,
  input clk,
  input rst
);

  wire ss_in_fire  = ss_in_valid & ss_in_ready;
  wire ss_out_fire = ss_out_valid & ss_out_ready;

  wire [31:0] xlen_cnt_next, xlen_cnt_value;
  wire xlen_cnt_ce, xlen_cnt_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) xlen_cnt_reg (
    .clk(clk),
    .rst(xlen_cnt_rst),
    .ce(xlen_cnt_ce),
    .d(xlen_cnt_next),
    .q(xlen_cnt_value)
  );

  wire [31:0] xseg_count_next, xseg_count_value;
  wire xseg_count_ce, xseg_count_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) xseg_count_reg (
    .clk(clk),
    .rst(xseg_count_rst),
    .ce(xseg_count_ce),
    .d(xseg_count_next),
    .q(xseg_count_value)
  );

  wire [31:0] port_xaddr_next, port_xaddr_value;
  wire port_xaddr_ce, port_xaddr_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) port_xaddr_reg (
    .clk(clk),
    .rst(port_xaddr_rst),
    .ce(port_xaddr_ce),
    .d(port_xaddr_next),
    .q(port_xaddr_value)
  );

  wire [31:0] block_cnt_next, block_cnt_value;
  wire block_cnt_ce, block_cnt_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) block_cnt_reg (
    .clk(clk),
    .rst(block_cnt_rst),
    .ce(block_cnt_ce),
    .d(block_cnt_next),
    .q(block_cnt_value)
  );

  // Note: cyclic_cnt is init to 1
  wire [31:0] cyclic_cnt_next, cyclic_cnt_value;
  wire cyclic_cnt_ce, cyclic_cnt_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) cyclic_cnt_reg (
    .clk(clk),
    .rst(cyclic_cnt_rst),
    .ce(cyclic_cnt_ce),
    .d(cyclic_cnt_next),
    .q(cyclic_cnt_value)
  );

  wire [4:0] ram_en_next, ram_en_value;
  wire ram_en_ce, ram_en_rst;
  REGISTER_R_CE #(.N(5), .INIT(0)) ram_en_reg (
    .clk(clk),
    .rst(ram_en_rst),
    .ce(ram_en_ce),
    .d(ram_en_next),
    .q(ram_en_value)
  );

  // RAM group size is 4
  wire [1:0] ram_cnt_next, ram_cnt_value;
  wire ram_cnt_ce, ram_cnt_rst;
  REGISTER_CE #(.N(2)) ram_cnt_reg (
    .clk(clk),
    //.rst(ram_cnt_rst),
    .ce(ram_cnt_ce),
    .d(ram_cnt_next),
    .q(ram_cnt_value)
  );


  wire [2:0] ram_rd_lat_cnt_next, ram_rd_lat_cnt_value;
  wire ram_rd_lat_cnt_ce, ram_rd_lat_cnt_rst;
  REGISTER_R_CE #(.N(3), .INIT(0)) ram_rd_lat_cnt_reg (
    .clk(clk),
    .rst(ram_rd_lat_cnt_rst),
    .ce(ram_rd_lat_cnt_ce),
    .d(ram_rd_lat_cnt_next),
    .q(ram_rd_lat_cnt_value)
  );

  // A FIFO for buffering RAM read results to ss_out
  // The depth should equal the RAM read latency
  wire [511:0] tmp_out_enq_data, tmp_out_deq_data;
  wire tmp_out_enq_valid, tmp_out_enq_ready;
  wire tmp_out_deq_valid, tmp_out_deq_ready;
  wire tmp_out_almost_full;

  fifo #(
    .WIDTH(512),
    .LOGDEPTH(3)
  ) ff_tmp_out (
    .clk(clk),
    .rst(rst),

    .enq_data(tmp_out_enq_data),
    .enq_valid(tmp_out_enq_valid),
    .enq_ready(tmp_out_enq_ready),

    .deq_data(tmp_out_deq_data),
    .deq_valid(tmp_out_deq_valid),
    .deq_ready(tmp_out_deq_ready)
  );

  wire tmp_out_enq_fire = tmp_out_enq_valid & tmp_out_enq_ready;
  wire tmp_out_deq_fire = tmp_out_deq_valid & tmp_out_deq_ready;

  localparam STATE_IDLE = 0;
  localparam STATE_RUN  = 1;
  localparam STATE_SS_OUT_WAIT = 2;
  localparam STATE_DONE = 3;

  wire [1:0] state_value;
  reg  [1:0] state_next;
  REGISTER_R #(.N(2)) state_reg (
    .clk(clk),
    .d(state_next),
    .q(state_value)
  );

  wire st_idle      = state_value == STATE_IDLE;
  wire st_run       = state_value == STATE_RUN;
  wire st_done      = state_value == STATE_DONE;

  wire [31:0] cyclic_offset;
  REGISTER #(.N(32)) cyclic_offset_reg (
    .clk(clk),
    .d(parallel_mode ? 4 : 1),
    .q(cyclic_offset)
  );
  wire [31:0] cyclic_offset1;
  REGISTER #(.N(32)) cyclic_offset1_reg (
    .clk(clk),
    .d(parallel_mode ? 8 : 2),
    .q(cyclic_offset1)
  );

  wire [31:0] cyclic_offset2 = dw_mode ? (2 * cyclic_offset) : cyclic_offset;
  wire [31:0] cyclic_offset3 = dw_mode ? (4 * cyclic_offset) : (2 * cyclic_offset);
  wire [31:0] block_cnt_offset2 = dw_mode ? 2 : 1;
  wire [31:0] ram_block_factor_offset = dw_mode ? 4 : 2;
  wire [31:0] ram_stride2 = dw_mode ? 2 * ram_stride : ram_stride;

  wire b1c8 = (ram_block_factor == 1) & (ram_cyclic_factor == 8);
  wire cond_xlen;// = xlen_cnt_value == len - 1;
  REGISTER_R_CE #(.N(1)) cond_xlen_reg (
    .clk(clk),
    .ce((xlen_cnt_value == len - cyclic_offset3 & xlen_cnt_ce) | (len == 8 & parallel_mode & ~b1c8)),
    .rst(((xlen_cnt_rst & ~(len == 8 & parallel_mode & ~b1c8))) | st_idle),
    .d(1'b1),
    .q(cond_xlen)
  );

  wire cond_xseg_count;// = xseg_count_value == seg_count - 1;
  REGISTER_R_CE #(.N(1)) cond_xseg_count_reg (
    .clk(clk),
    .ce((xseg_count_value == seg_count - 2 & xseg_count_ce) | (seg_count == 1)),
    .rst((xseg_count_rst & seg_count != 1) | st_idle),
    .d(1'b1),
    .q(cond_xseg_count)
  );

  wire cond_block_cnt;// = block_cnt_value == ram_block_factor - 1;
  REGISTER_R_CE #(.N(1)) cond_block_cnt_reg (
    .clk(clk),
    .ce((block_cnt_value == ram_block_factor - ram_block_factor_offset & block_cnt_ce) | (ram_block_factor == ram_block_factor_base)),
    .rst((block_cnt_rst & ram_block_factor != ram_block_factor_base) | st_idle),
    .d(1'b1),
    .q(cond_block_cnt)
  );

  wire cond_cyclic_cnt;// = cyclic_cnt_value == ram_cyclic_factor;
  REGISTER_R_CE #(.N(1)) cond_cyclic_cnt_reg (
    .clk(clk),
    //.ce((cyclic_cnt_value == ram_cyclic_factor - 1 & cyclic_cnt_ce) | (ram_cyclic_factor == 1)),
    .ce((cyclic_cnt_value == ram_cyclic_factor - cyclic_offset1 & cyclic_cnt_ce) |
        (ram_cyclic_factor == 1) | (ram_cyclic_factor == 4 & parallel_mode) |
        (((ram_block_factor == 1) | (ram_block_factor == 2)) & ram_cyclic_factor == 2 & dp_mode)),
    .rst((cyclic_cnt_rst & ((ram_cyclic_factor != 1 & ~parallel_mode) | (ram_cyclic_factor != 4 & parallel_mode & ~dp_mode))) | st_idle),
    .d(1'b1),
    .q(cond_cyclic_cnt)
  );

  wire ss_out_ok;

  wire tmp_out_deq_fire_pipe0;
  REGISTER_R_CE #(.N(1)) tmp_out_deq_fire_pipe0_reg (
    .clk(clk),
    .rst((tmp_out_deq_valid == 1'b0) & (state_value == STATE_SS_OUT_WAIT)),
    .ce(tmp_out_deq_fire),
    .d(1'b1),
    .q(tmp_out_deq_fire_pipe0)
  );

  wire broadcast_mode;
  REGISTER_R_CE #(.N(1)) broadcast_mode_reg (
    .clk(clk),
    .rst(lsu_done),
    .ce(mode[3]),
    .d(1'b1),
    .q(broadcast_mode)
  );

  wire mode_read;// = st_run & (mode == 1);
  REGISTER_R_CE #(.N(1)) mode_read_reg (
    .clk(clk),
    .rst(cond_xseg_count & cond_xlen & (ss_in_fire | parallel_in)),
    .ce(st_idle & lsu_start & (mode[1:0] == 1)),
    .d(1'b1),
    .q(mode_read)
  );

  wire mode_write;// = st_run & (mode == 2);
  REGISTER_R_CE #(.N(1)) mode_write_reg (
    .clk(clk),
    .rst(cond_xseg_count & cond_xlen & ss_out_ok),
    .ce(st_idle & lsu_start & (mode[1:0] == 2)),
    .d(1'b1),
    .q(mode_write)
  );

  assign ss_out_ok = mode_write & (ram_rd_lat_cnt_value != 0) & ss_out_ready;
  wire ss_out_ok_pipe;
  pipe_block #(.WIDTH(1), .NUM_STAGES(RAM_READ_LATENCY)) ss_out_ok_pipe_pb (
    .clk(clk),
    .d(ss_out_ok),
    .q(ss_out_ok_pipe)
  );

  always @(*) begin
    state_next = state_value;
    case (state_value)
      STATE_IDLE: begin
        if (lsu_start)
          state_next = STATE_RUN;
      end

      STATE_RUN: begin
        if (cond_xseg_count & cond_xlen & (ss_in_fire | parallel_in))
          state_next = STATE_DONE;
        else if (cond_xseg_count & cond_xlen & ss_out_ok)
          state_next = STATE_SS_OUT_WAIT;
      end

      STATE_SS_OUT_WAIT: begin
        if (tmp_out_deq_fire_pipe0 & (tmp_out_deq_valid == 1'b0))
          state_next = STATE_DONE;
      end

      STATE_DONE: begin
        state_next = STATE_IDLE;
      end
    endcase
  end

  wire lsu_start_pipe;
  REGISTER #(.N(1)) lsu_start_reg (
    .clk(clk),
    .d(lsu_start),
    .q(lsu_start_pipe)
  );

  wire lsu_start_pulse = lsu_start & (~lsu_start_pipe);

//  REGISTER_R_CE #(.N(1)) lsu_done_reg (
//    .clk(clk),
//    .rst(lsu_start_pulse),
//    .ce(st_done),
//    .d(1'b1),
//    .q(lsu_done)
//  );

  wire lsu_done_pipe0;
  REGISTER #(.N(1)) lsu_done_pipe0_reg (
    .clk(clk),
    .d(st_done),
    .q(lsu_done_pipe0)
  );

  wire lsu_done_pipe1;
  REGISTER #(.N(1)) lsu_done_pipe1_reg (
    .clk(clk),
    .d(lsu_done_pipe0),
    .q(lsu_done_pipe1)
  );
//  assign lsu_done = lsu_done_pipe0 | lsu_done_pipe1;
  assign lsu_done = lsu_done_pipe0;// | lsu_done_pipe1;

  wire [1:0] ram_cnt_pipe;
  pipe_block #(.WIDTH(2), .NUM_STAGES(RAM_READ_LATENCY)) ram_cnt_pipe_pb (
    .clk(clk),
    .d(ram_cnt_value),
    .q(ram_cnt_pipe)
  );
  assign xlen_cnt_next = xlen_cnt_value + cyclic_offset2;
  assign xlen_cnt_ce   = ss_in_fire | parallel_in | ss_out_ok;
  assign xlen_cnt_rst  = rst | (cond_xlen & (ss_in_fire | parallel_in | ss_out_ok));

  assign xseg_count_next = xseg_count_value + 1;
  assign xseg_count_ce   = cond_xlen & (ss_in_fire | parallel_in | ss_out_ok);
  assign xseg_count_rst  = rst | (cond_xseg_count & cond_xlen & (ss_in_fire | parallel_in | ss_out_ok));

  assign block_cnt_next = block_cnt_value + block_cnt_offset2;
  assign block_cnt_ce   = ss_in_fire | ss_out_ok;
  assign block_cnt_rst  = rst | (cond_block_cnt & (ss_in_fire | parallel_in | ss_out_ok));

  assign cyclic_cnt_next = cyclic_cnt_value + cyclic_offset;
  assign cyclic_cnt_ce   = (cond_block_cnt & (ss_in_fire | parallel_in | ss_out_ok));
  assign cyclic_cnt_rst  = (cond_block_cnt &
                            cond_cyclic_cnt &
                            (ss_in_fire | ss_out_ok | parallel_in));

  assign ram_cnt_next = (lsu_start | ram_cnt_rst) ? ram_cnt_init : (ram_cnt_value + 1);
  assign ram_cnt_ce   = lsu_start | (cond_block_cnt & (ss_in_fire | ss_out_ok));
  assign ram_cnt_rst  = cond_block_cnt & cond_cyclic_cnt & (ss_in_fire | ss_out_ok);

//  assign ram_en_next = (cyclic_cnt_rst | lsu_start)                ? ram_en_init :
//                       (parallel_in | (ss_out_ok & parallel_mode)) ? (ram_en_value << 4) :
//                                                                     (ram_en_value << 1);
  assign ram_en_next = (cyclic_cnt_rst | lsu_start)                ? ram_en_init :
                       (parallel_in | (ss_out_ok & parallel_mode) |
                       (ram_cnt_value == 3 & ram_cnt_ce & ~cond_cyclic_cnt)) ? (ram_en_value + 1) :
                                                                     ram_en_value;

  assign ram_en_ce   = (cond_block_cnt & (ss_in_fire | ss_out_ok | parallel_in)) |
                       cyclic_cnt_rst | lsu_start;
  assign ram_en_rst  = rst;

  wire [AWIDTH-1:0] addr_next, addr_value;
  wire addr_ce, addr_rst;
  REGISTER_R_CE #(.N(AWIDTH)) addr_reg (
    .clk(clk),
    .rst(addr_rst),
    .ce(addr_ce),
    .d(addr_next),
    .q(addr_value)
  );
  assign addr_next = addr_value + ram_block_factor_updated;
  assign addr_ce   = (mode_read | mode_write) & cyclic_cnt_rst;
  assign addr_rst  = st_done;

  wire [31:0] ram_ss_stride;
  REGISTER #(.N(32)) ram_ss_stride_reg (
    .clk(clk),
    .d(ram_stride + ram_seg_stride),
    .q(ram_ss_stride)
  );

  assign port_xaddr_next = cyclic_cnt_rst ? (addr_value + ram_block_factor_updated) :
                            block_cnt_rst  ? addr_value :
                            (cond_xlen | (cond_xlen & ss_out_ok)) ? (port_xaddr_value + ram_ss_stride) :
                                             (port_xaddr_value + ram_stride2);
  assign port_xaddr_ce   = parallel_in |
                            (ss_in_fire) |
                            (ss_out_ok) |
                            cyclic_cnt_rst;
  assign port_xaddr_rst  = st_done;

  wire [AWIDTH-1:0] port_addr_tmp;
  wire [2*DWIDTH-1:0] port0_d_tmp;
  wire port0_ce_tmp, port0_we_tmp;

  assign port_addr_tmp = ram_addr_offset + port_xaddr_value;
  assign port0_d_tmp    = parallel_in ? (dp_mode_base2 ? word2_in : word0_in) : ss_in_data;
  assign port0_ce_tmp   = (mode_read | (mode_write & (ram_rd_lat_cnt_value != 0))) & (((ram_cnt_value == 0) | broadcast_mode) | (parallel_mode & ~dp_mode_base2));
  assign port0_we_tmp   = ss_in_fire | parallel_in;
  wire [AWIDTH-1:0] port_addr_tmp_next = port_addr_tmp + ram_stride;


  wire [AWIDTH-1:0] port1_addr_tmp;
  wire [2*DWIDTH-1:0] port1_d_tmp;
  wire port1_ce_tmp, port1_we_tmp;

  assign port1_d_tmp    = parallel_in ? (dp_mode_base2 ? word3_in : word1_in) : ss_in_data;
  assign port1_ce_tmp   = (mode_read | (mode_write & (ram_rd_lat_cnt_value != 0))) & (((ram_cnt_value == 1) | broadcast_mode) | (parallel_mode & ~dp_mode_base2));
  assign port1_we_tmp   = ss_in_fire | parallel_in;

  wire [AWIDTH-1:0] port2_addr_tmp;
  wire [2*DWIDTH-1:0] port2_d_tmp;
  wire port2_ce_tmp, port2_we_tmp;

  assign port2_d_tmp    = parallel_in ? (dp_mode_base2 ? word0_in : word2_in) : ss_in_data;
  assign port2_ce_tmp   = (mode_read | (mode_write & (ram_rd_lat_cnt_value != 0))) & (((ram_cnt_value == 2) | broadcast_mode) | (parallel_mode & ~dp_mode_base0));
  assign port2_we_tmp   = ss_in_fire | parallel_in;

  wire [AWIDTH-1:0] port3_addr_tmp;
  wire [2*DWIDTH-1:0] port3_d_tmp;
  wire port3_ce_tmp, port3_we_tmp;

  assign port3_d_tmp    = parallel_in ? (dp_mode_base2 ? word1_in : word3_in) : ss_in_data;
  assign port3_ce_tmp   = (mode_read | (mode_write & (ram_rd_lat_cnt_value != 0))) & (((ram_cnt_value == 3) | broadcast_mode) | (parallel_mode & ~dp_mode_base0));
  assign port3_we_tmp   = ss_in_fire | parallel_in;

  wire [23:0] port_addr_tmp1;
  wire [11:0] port_addr_tmp10 = port_addr_tmp1[11:0]  + 2;
  wire [11:0] port_addr_tmp11 = port_addr_tmp1[23:12] + 2;

  pipe_block #(.WIDTH(2*AWIDTH), .NUM_STAGES(1)) port0_addr_pb (
    .clk(clk),
    .d({port_addr_tmp_next, port_addr_tmp}),
    .q(port_addr_tmp1)
  );
  assign port0_addr = (dp_mode_base2) ? {port_addr_tmp11, port_addr_tmp10} : port_addr_tmp1;

  pipe_block #(.WIDTH(2*DWIDTH), .NUM_STAGES(1)) port0_d_pb (
    .clk(clk),
    .d(port0_d_tmp),
    .q(port0_d)
  );
  pipe_block #(.WIDTH(2), .NUM_STAGES(1)) port0_ce_pb (
    .clk(clk),
    .d(dw_mode ? {port0_ce_tmp, port0_ce_tmp} : {1'b0, port0_ce_tmp}),
    .q(port0_ce)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) port0_we_pb (
    .clk(clk),
    .d(port0_we_tmp),
    .q(port0_we)
  );

  assign port1_addr = (dp_mode_base2) ? {port_addr_tmp11, port_addr_tmp10} : port_addr_tmp1;

  pipe_block #(.WIDTH(2*DWIDTH), .NUM_STAGES(1)) port1_d_pb (
    .clk(clk),
    .d(port1_d_tmp),
    .q(port1_d)
  );
  pipe_block #(.WIDTH(2), .NUM_STAGES(1)) port1_ce_pb (
    .clk(clk),
    .d(dw_mode ? {port1_ce_tmp, port1_ce_tmp} : {1'b0, port1_ce_tmp}),
    .q(port1_ce)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) port1_we_pb (
    .clk(clk),
    .d(port1_we_tmp),
    .q(port1_we)
  );

  assign port2_addr = (dp_mode_base0) ? {port_addr_tmp11, port_addr_tmp10} : port_addr_tmp1;

  pipe_block #(.WIDTH(2*DWIDTH), .NUM_STAGES(1)) port2_d_pb (
    .clk(clk),
    .d(port2_d_tmp),
    .q(port2_d)
  );
  pipe_block #(.WIDTH(2), .NUM_STAGES(1)) port2_ce_pb (
    .clk(clk),
    .d(dw_mode ? {port2_ce_tmp, port2_ce_tmp} : {1'b0, port2_ce_tmp}),
    .q(port2_ce)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) port2_we_pb (
    .clk(clk),
    .d(port2_we_tmp),
    .q(port2_we)
  );

  assign port3_addr = (dp_mode_base0) ? {port_addr_tmp11, port_addr_tmp10} : port_addr_tmp1;

  pipe_block #(.WIDTH(2*DWIDTH), .NUM_STAGES(1)) port3_d_pb (
    .clk(clk),
    .d(port3_d_tmp),
    .q(port3_d)
  );
  pipe_block #(.WIDTH(2), .NUM_STAGES(1)) port3_ce_pb (
    .clk(clk),
    .d(dw_mode ? {port3_ce_tmp, port3_ce_tmp} : {1'b0, port3_ce_tmp}),
    .q(port3_ce)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) port3_we_pb (
    .clk(clk),
    .d(port3_we_tmp),
    .q(port3_we)
  );

  pipe_block #(.WIDTH(5), .NUM_STAGES(1)) ram_en_pb (
    .clk(clk),
    .d(ram_en_value),
    .q(ram_en)
  );
  //assign ram_en = ram_en_value;

  assign ss_in_ready  = mode_read;

  assign ram_rd_lat_cnt_next = ram_rd_lat_cnt_value + 1;
  assign ram_rd_lat_cnt_ce   = ((st_run & mode_write & ram_rd_lat_cnt_value == 0) |
                               (ram_rd_lat_cnt_value != 0 & ram_rd_lat_cnt_value <= RAM_READ_LATENCY));
  assign ram_rd_lat_cnt_rst  = st_done;

  wire [2*DWIDTH-1:0] q_tmp = (ram_cnt_pipe == 0) ? port0_q :
                              (ram_cnt_pipe == 1) ? port1_q :
                              (ram_cnt_pipe == 2) ? port2_q :
                                                    port3_q;

  wire parallel_mode_pipe;
  pipe_block #(.WIDTH(1), .NUM_STAGES(RAM_READ_LATENCY)) parallel_mode_pipe_pb (
    .clk(clk),
    .d(parallel_mode),
    .q(parallel_mode_pipe)
  );

  wire dp_mode_base2_pipe;
  pipe_block #(.WIDTH(1), .NUM_STAGES(RAM_READ_LATENCY)) dp_mode_base2_pipe_pb (
    .clk(clk),
    .d(dp_mode_base2),
    .q(dp_mode_base2_pipe)
  );

  assign tmp_out_enq_data  = parallel_mode_pipe ? (
    dp_mode_base2_pipe ? {port1_q, port0_q, port3_q, port2_q} : {port3_q, port2_q, port1_q, port0_q}) : q_tmp;
  assign tmp_out_enq_valid = ss_out_ok_pipe;
  assign tmp_out_deq_ready = ss_out_ready;

  assign ss_out_data  = tmp_out_deq_data;
  assign ss_out_valid = tmp_out_deq_valid;

//  assign ss_out_data  = parallel_mode_pipe ? (
//    dp_mode_base2_pipe ? {port1_q, port0_q, port3_q, port2_q} : {port3_q, port2_q, port1_q, port0_q}) : q_tmp;
//  assign ss_out_valid = ss_out_ok_pipe;

  // debug
`ifdef DEBUG
  always @(posedge clk) begin
    if (|port0_ce === 1'b1 && port0_we === 1'b1) begin
      $display("[%t] [%m] [ram_en=%h] LSU PORT0 WRITE addr=%h, d=%h, ce=%b", $time, ram_en, port0_addr, port0_d, port0_ce);
    end
    if (|port2_ce === 1'b1 && port2_we === 1'b1 && dp_mode === 1'b1 && ram_cnt_init == 2) begin
      $display("[%t] [%m] [ram_en=%h] LSU PORT0 WRITE addr=%h, d=%h, ce=%b", $time, ram_en, port0_addr, port0_d, port2_ce);
    end
    if (|port1_ce === 1'b1 && port1_we === 1'b1) begin
      $display("[%t] [%m] [ram_en=%h] LSU PORT1 WRITE addr=%h, d=%h, ce=%b", $time, ram_en, port1_addr, port1_d, port1_ce);
    end
    if (|port3_ce === 1'b1 && port3_we === 1'b1 && dp_mode === 1'b1 && ram_cnt_init == 2) begin
      $display("[%t] [%m] [ram_en=%h] LSU PORT1 WRITE addr=%h, d=%h, ce=%b", $time, ram_en, port1_addr, port1_d, port3_ce);
    end
    if (|port2_ce === 1'b1 && port2_we === 1'b1) begin
      $display("[%t] [%m] [ram_en=%h] LSU PORT2 WRITE addr=%h, d=%h, ce=%b", $time, ram_en, port2_addr, port2_d, port2_ce);
    end
    if (|port0_ce === 1'b1 && port0_we === 1'b1 && dp_mode === 1'b1 && ram_cnt_init == 0) begin
      $display("[%t] [%m] [ram_en=%h] LSU PORT2 WRITE addr=%h, d=%h, ce=%b", $time, ram_en, port2_addr, port2_d, port0_ce);
    end
    if (|port3_ce === 1'b1 && port3_we === 1'b1) begin
      $display("[%t] [%m] [ram_en=%h] LSU PORT3 WRITE addr=%h, d=%h, ce=%b", $time, ram_en, port3_addr, port3_d, port3_ce);
    end
    if (|port1_ce === 1'b1 && port1_we === 1'b1 && dp_mode === 1'b1 && ram_cnt_init == 0) begin
      $display("[%t] [%m] [ram_en=%h] LSU PORT3 WRITE addr=%h, d=%h, ce=%b", $time, ram_en, port3_addr, port3_d, port1_ce);
    end

//    if (port0_ce === 1'b1 && port0_we === 1'b0) begin
//      $display("[%t] [ram_en=%h] LSU PORT0 READ addr=%h", $time, ram_en, port0_addr);
//    end
//    if (port1_ce === 1'b1 && port1_we === 1'b0) begin
//      $display("[%t] [ram_en=%h] LSU PORT1 READ addr=%h", $time, ram_en, port1_addr);
//    end
//    if (port2_ce === 1'b1 && port2_we === 1'b0) begin
//      $display("[%t] [ram_en=%h] LSU PORT2 READ addr=%h", $time, ram_en, port2_addr);
//    end
//    if (port3_ce === 1'b1 && port3_we === 1'b0) begin
//      $display("[%t] [ram_en=%h] LSU PORT3 READ addr=%h", $time, ram_en, port3_addr);
//    end
  end

`ifdef DEBUG_LSU
  // TAN
  always @(posedge clk) begin
    if (ID === 0) begin
    $display("[%t] [%m] state=%h, start=%b, done=%b, ram_en=%b, ram_block_factor=%h, ram_cyclic_factor=%h, ram_cnt=%h, block_cnt=%h, cyclic_cnt=%h, cond_block_cnt=%b, cond_cyclic_cnt=%b, ram_rd_lat_cnt=%h, port0_addr=%h, port0_ce=%b, port0_we=%b, port0_q=%h, port1_addr=%h, port1_ce=%b, port1_we=%b, port1_q=%h, port2_addr=%h, port2_ce=%b, port2_we=%b, port2_q=%h, port3_addr=%h, port3_ce=%b, port3_we=%b, port3_q=%h, tmp_out_enq [%b %b %h], tmp_out_deq [%b %b %h], ss_out [%b %b %h], ss_out_ok=%b, cyclic_cnt_rst=%b, block_cnt_rst=%b,  parallel_in=%b, ram_en_init=%h, len=%h, seg_count=%h, dp_mode_base0=%b, dp_mode_base2=%b, mode_read=%b, mode_write=%b, tmp_out_deq_fire_pipe0=%b, cond_xseg_count=%b, cond_xlen=%b",
      $time, state_value, lsu_start, lsu_done,
      ram_en,
      ram_block_factor, ram_cyclic_factor,
      ram_cnt_value, block_cnt_value, cyclic_cnt_value, cond_block_cnt, cond_cyclic_cnt,
      ram_rd_lat_cnt_value,
      port0_addr, port0_ce, port0_we, port0_q,
      port1_addr, port1_ce, port1_we, port1_q,
      port2_addr, port2_ce, port2_we, port2_q,
      port3_addr, port3_ce, port3_we, port3_q,

      tmp_out_enq_valid, tmp_out_enq_ready, tmp_out_enq_data,
      tmp_out_deq_valid, tmp_out_deq_ready, tmp_out_deq_data,
      ss_out_valid, ss_out_ready, ss_out_data,
      ss_out_ok,
      cyclic_cnt_rst,
      block_cnt_rst,
      parallel_in,
      ram_en_init,
      len, seg_count,
      dp_mode_base0, dp_mode_base2,
      mode_read, mode_write, tmp_out_deq_fire_pipe0,
      cond_xseg_count, cond_xlen
    );
    end
  end
`endif

`endif

endmodule

module lsu_top #(
  parameter AWIDTH   = 12,
  parameter DWIDTH   = 64,
  parameter RAM_READ_LATENCY = 4,
  parameter ID = 0
) (
  output [2*AWIDTH-1:0] port0_addr,
  output [2*DWIDTH-1:0] port0_d,
  input  [2*DWIDTH-1:0] port0_q,
  output [1:0]          port0_ce,
  output                port0_we,

  output [2*AWIDTH-1:0] port1_addr,
  output [2*DWIDTH-1:0] port1_d,
  input  [2*DWIDTH-1:0] port1_q,
  output [1:0]          port1_ce,
  output                port1_we,

  output [2*AWIDTH-1:0] port2_addr,
  output [2*DWIDTH-1:0] port2_d,
  input  [2*DWIDTH-1:0] port2_q,
  output [1:0]          port2_ce,
  output                port2_we,

  output [2*AWIDTH-1:0] port3_addr,
  output [2*DWIDTH-1:0] port3_d,
  input  [2*DWIDTH-1:0] port3_q,
  output [1:0]          port3_ce,
  output                port3_we,

  input  [511:0] ss_in_data,
  input          ss_in_valid,
  output         ss_in_ready,

  output [511:0] ss_out_data,
  output         ss_out_valid,
  input          ss_out_ready,

  output [4:0] ram_en,

  input  lsu_start,
  output lsu_done,

  input [31:0] ram_start_idx,
  input [31:0] ram_block_factor,
  input [31:0] ram_cyclic_factor,
  input [31:0] ram_stride,
  input [31:0] ram_seg_stride,
  input [31:0] ram_addr_offset,

  input [31:0] seg_count,
  input [31:0] len,
  input [31:0] mode,
  input clk,
  input rst
);

  localparam SCALE = 512 / DWIDTH;
  localparam SCALE2 = 512 / (DWIDTH * 2);

  // double-word mode
  wire dw_mode_tmp = (ram_block_factor != 1) |
                     (ram_block_factor == 1 & ((ram_cyclic_factor == 2) | (ram_cyclic_factor == 4)));
  wire dw_mode;
  REGISTER #(.N(1)) dw_mode_reg (
    .clk(clk),
    .d(dw_mode_tmp),
    .q(dw_mode)
  );

  wire [31:0] scale_tmp = dw_mode ? SCALE2 : SCALE;
  wire [31:0] scale;
  REGISTER #(.N(32)) scale_reg (
    .clk(clk),
    .d(scale_tmp),
    .q(scale)
  );

  // Special case: dual-port mode:
  //   + port0 and port2 access to ram0
  //   + port1 and port3 access to ram1
  // For now, dual-port mode only works with cases:
  //   + ram_block_factor == 1 && ram_cyclic_factor == 2 && ram_start_idx = 0 or 2
  //   + ram_block_factor == 2 && ram_cyclic_factor == 2 && ram_start_idx = 0 or 2
  wire dp_mode_tmp = mode[2];
  REGISTER #(.N(1)) dp_mode_reg (
    .clk(clk),
    .d(dp_mode_tmp),
    .q(dp_mode)
  );

  // ram_block_factor == 1: enable 4 parallel read/write ops using 4 LSU ports
  // TODO: use mask in case cyclic factor is not divisible by 4
  wire bf1 = ram_block_factor == 1;
  wire bf2 = ram_block_factor == 2;
  wire cf2 = ram_cyclic_factor == 2;
  wire cf4 = ram_cyclic_factor == 4;

  wire [31:0] ram_block_factor_updated_tmp =
    ((bf1 | bf2) & (cf2 & dp_mode)) ? 4 * ram_block_factor :
    (bf1 & (cf2 | cf4))             ? 2 * ram_block_factor :
                                      1 * ram_block_factor;
  wire [31:0] ram_block_factor_updated;
  REGISTER #(.N(32)) ram_block_factor_updated_reg (
    .clk(clk),
    .d(ram_block_factor_updated_tmp),
    .q(ram_block_factor_updated)
  );

  wire [31:0] ram_block_factor_base_tmp = ~bf1 ? 2 : 1;
  wire [31:0] ram_block_factor_base;
  REGISTER #(.N(32)) ram_block_factor_base_reg (
    .clk(clk),
    .d(ram_block_factor_base_tmp),
    .q(ram_block_factor_base)
  );

  wire parallel_mode_tmp = (bf1 & (((ram_cyclic_factor & 3) == 0) || (cf2 & dp_mode))) |
                           (bf2 & (((ram_cyclic_factor & 3) == 0) || (cf2 & dp_mode)));
  wire parallel_mode;
  REGISTER #(.N(1)) parallel_mode_reg (
    .clk(clk),
    .d(parallel_mode_tmp),
    .q(parallel_mode)
  );

  // parallel single-word mode
  wire psw_mode_tmp = parallel_mode & (~dw_mode);
  REGISTER #(.N(1)) psw_mode_reg (
    .clk(clk),
    .d(psw_mode_tmp),
    .q(psw_mode)
  );

  wire [4:0] ram_en_init;
  // parallel mode will not be working correctly if ram_start_idx is not divisible by 4
//  wire [NUM_RAMS-1:0] ram_en_init_next = parallel_mode ? ('hF << ram_start_idx) : (1 << ram_start_idx);
  wire [4:0] ram_en_init_next = (ram_start_idx >> 2);

  REGISTER #(.N(5)) ram_en_init_reg (
    .clk(clk),
    .d(ram_en_init_next),
    .q(ram_en_init)
  );

  wire [31:0] ram_cnt_init_tmp = (parallel_mode & ~dp_mode) ? ((ram_start_idx >> 2) << 2) : (ram_start_idx & 3);
  wire [31:0] ram_cnt_init;
  REGISTER #(.N(32)) ram_cnt_init_reg (
    .clk(clk),
    .d(ram_cnt_init_tmp),
    .q(ram_cnt_init)
  );

  wire dp_mode_base0_tmp = dp_mode & (ram_cnt_init == 0);
  wire dp_mode_base2_tmp = dp_mode & (ram_cnt_init == 2);

  REGISTER #(.N(1)) dp_mode_base0_reg (
    .clk(clk),
    .d(dp_mode_base0_tmp),
    .q(dp_mode_base0)
  );

  REGISTER #(.N(1)) dp_mode_base2_reg (
    .clk(clk),
    .d(dp_mode_base2_tmp),
    .q(dp_mode_base2)
  );

  wire [2*DWIDTH-1:0] ss0_in_data;
  wire ss0_in_valid, ss0_in_ready;
  wire [511:0] ss0_out_data;
  wire ss0_out_valid, ss0_out_ready;

  wire ss_in_fire   = ss_in_valid   & ss_in_ready;
  wire ss_out_fire  = ss_out_valid  & ss_out_ready;
  wire ss0_in_fire  = ss0_in_valid  & ss0_in_ready;
  wire ss0_out_fire = ss0_out_valid & ss0_out_ready;

  localparam STATE_SS_IN_0 = 0;
  localparam STATE_SS_IN_PARALLEL = 1;
  localparam STATE_SS_IN_PARALLEL_SW = 2;
  localparam STATE_SS_IN_SERIAL = 3;

  wire [1:0] state_ss_in_value;
  reg  [1:0] state_ss_in_next;
  REGISTER #(.N(2)) state_ss_in_reg (
    .clk(clk),
    .d(state_ss_in_next),
    .q(state_ss_in_value)
  );

  wire [2:0] ss0_in_cnt_next, ss0_in_cnt_value;
  wire ss0_in_cnt_ce, ss0_in_cnt_rst;
  REGISTER_R_CE #(.N(3), .INIT(0)) ss0_in_cnt_reg (
    .clk(clk),
    .rst(ss0_in_cnt_rst),
    .ce(ss0_in_cnt_ce),
    .d(ss0_in_cnt_next),
    .q(ss0_in_cnt_value)
  );

  always @(*) begin
    state_ss_in_next = state_ss_in_value;
    case (state_ss_in_value)
      STATE_SS_IN_0: begin
        if (ss_in_fire)
          if (!parallel_mode)
            state_ss_in_next = STATE_SS_IN_SERIAL;
          else if (psw_mode)
            state_ss_in_next = STATE_SS_IN_PARALLEL_SW;
          else
            state_ss_in_next = STATE_SS_IN_PARALLEL;
      end

      STATE_SS_IN_SERIAL: begin
        if (ss0_in_cnt_value == scale - 1 && ss0_in_fire)
          state_ss_in_next = STATE_SS_IN_0;
      end

      STATE_SS_IN_PARALLEL_SW: begin
        state_ss_in_next = STATE_SS_IN_0;
      end

      STATE_SS_IN_PARALLEL: begin
        if (lsu_done)
          state_ss_in_next = STATE_SS_IN_0;
      end
    endcase
  end

  wire ss_in_valid_pipe0;
  REGISTER #(.N(1)) ss_in_valid_pipe0_reg (
    .clk(clk),
    .d(ss_in_valid),
    .q(ss_in_valid_pipe0)
  );
  wire ss_in_valid_pipe1;
  REGISTER #(.N(1)) ss_in_valid_pipe1_reg (
    .clk(clk),
    .d(ss_in_valid_pipe0),
    .q(ss_in_valid_pipe1)
  );

  // Activate all ports
//  wire parallel_in = parallel_mode & ss_in_valid_pipe0;
  wire parallel_in = parallel_mode & (ss_in_valid_pipe0 | (psw_mode & ss_in_valid_pipe1));

  assign ss0_in_cnt_next = ss0_in_cnt_value + 1;
  assign ss0_in_cnt_ce   = ss0_in_fire;
  assign ss0_in_cnt_rst  = (ss0_in_cnt_value == scale - 1) & ss0_in_fire;

  wire [63:0] wi0 = ss_in_data[64*1-1:64*0];
  wire [63:0] wi1 = ss_in_data[64*2-1:64*1];
  wire [63:0] wi2 = ss_in_data[64*3-1:64*2];
  wire [63:0] wi3 = ss_in_data[64*4-1:64*3];
  wire [63:0] wi4 = ss_in_data[64*5-1:64*4];
  wire [63:0] wi5 = ss_in_data[64*6-1:64*5];
  wire [63:0] wi6 = ss_in_data[64*7-1:64*6];
  wire [63:0] wi7 = ss_in_data[64*8-1:64*7];

  wire [511:0] ss_in_data_tmp =
    (bf1 & cf2) ? {wi7, wi5, wi6, wi4, wi3, wi1, wi2, wi0} :
    (bf1 & cf4) ? {wi7, wi3, wi6, wi2, wi5, wi1, wi4, wi0} :
    psw_mode    ? {wi7, wi3, wi6, wi2, wi5, wi1, wi4, wi0} :
                  ss_in_data;

  wire [511:0] ss_in_data_pipe;
  REGISTER_CE #(.N(512)) ss_in_data_pipe_reg (
    .clk(clk),
    .ce(ss_in_fire | ss0_in_fire | (state_ss_in_value == STATE_SS_IN_PARALLEL_SW)),
    .d(ss_in_fire              ? ss_in_data_tmp :
       (ss0_in_fire & dw_mode) ? (ss_in_data_pipe >> (DWIDTH * 2)) :
                                 (ss_in_data_pipe >> (DWIDTH * 1))),
    .q(ss_in_data_pipe)
  );

  wire [2*DWIDTH-1:0] word0_in = {ss_in_data_pipe[64*2-1:64*1], ss_in_data_pipe[64*1-1:64*0]};
  wire [2*DWIDTH-1:0] word1_in = {ss_in_data_pipe[64*4-1:64*3], ss_in_data_pipe[64*3-1:64*2]};
  wire [2*DWIDTH-1:0] word2_in = {ss_in_data_pipe[64*6-1:64*5], ss_in_data_pipe[64*5-1:64*4]};
  wire [2*DWIDTH-1:0] word3_in = {ss_in_data_pipe[64*8-1:64*7], ss_in_data_pipe[64*7-1:64*6]};

  assign ss0_in_data  = ss_in_data_pipe[DWIDTH*2-1:0];
  assign ss0_in_valid = (state_ss_in_value == STATE_SS_IN_SERIAL);
  assign ss_in_ready  = (state_ss_in_value == STATE_SS_IN_0) |
                        (state_ss_in_value == STATE_SS_IN_PARALLEL);

  localparam STATE_SS_OUT_0 = 0;
  localparam STATE_SS_OUT_1 = 1;
  localparam STATE_SS_OUT_0_TMP = 2;
  wire [1:0] state_ss_out_value;
  reg  [1:0] state_ss_out_next;
  REGISTER #(.N(2)) state_ss_out_reg (
    .clk(clk),
    .d(state_ss_out_next),
    .q(state_ss_out_value)
  );

  wire [2:0] ss0_out_cnt_next, ss0_out_cnt_value;
  wire ss0_out_cnt_ce, ss0_out_cnt_rst;
  REGISTER_R_CE #(.N(3), .INIT(0)) ss0_out_cnt_reg (
    .clk(clk),
    .rst(ss0_out_cnt_rst),
    .ce(ss0_out_cnt_ce),
    .d(ss0_out_cnt_next),
    .q(ss0_out_cnt_value)
  );

  wire [511:0] ss_out_data_pipe, ss_out_data_pipe_next;
  wire ss_out_data_pipe_ce;
  REGISTER_CE #(.N(512)) ss_out_data_pipe_reg (
    .clk(clk),
    .ce(ss_out_data_pipe_ce),
    .d(ss_out_data_pipe_next),
    .q(ss_out_data_pipe)
  );

  always @(*) begin
    state_ss_out_next = state_ss_out_value;
    case (state_ss_out_value)
      STATE_SS_OUT_0: begin
        if (ss0_out_fire)
          if (psw_mode)
            state_ss_out_next = STATE_SS_OUT_0_TMP;
          else if (ss0_out_cnt_value == scale - 1)
            state_ss_out_next = STATE_SS_OUT_1;
      end

      STATE_SS_OUT_0_TMP: begin
        if (ss0_out_fire)
          state_ss_out_next = STATE_SS_OUT_1;
      end

      STATE_SS_OUT_1: begin
        if (ss_out_fire)
          state_ss_out_next = STATE_SS_OUT_0;
      end

    endcase
  end
 
  wire [DWIDTH-1:0] word0_out, word1_out, word2_out, word3_out;
  wire parallel_out;

  wire [511:0] ss_output = parallel_mode ? ss0_out_data : ss_out_data_pipe;

  assign ss0_out_cnt_next = ss0_out_cnt_value + 1;
  assign ss0_out_cnt_ce   = ss0_out_fire & ~parallel_mode;
  assign ss0_out_cnt_rst  = (ss0_out_cnt_value == scale - 1) & ss0_out_fire;

  wire [63:0] wo0 = ss_output[64*1-1:64*0];
  wire [63:0] wo1 = ss_output[64*2-1:64*1];
  wire [63:0] wo2 = ss_output[64*3-1:64*2];
  wire [63:0] wo3 = ss_output[64*4-1:64*3];
  wire [63:0] wo4 = ss_output[64*5-1:64*4];
  wire [63:0] wo5 = ss_output[64*6-1:64*5];
  wire [63:0] wo6 = ss_output[64*7-1:64*6];
  wire [63:0] wo7 = ss_output[64*8-1:64*7];

  assign ss_out_data_pipe_next = ((state_ss_out_value == STATE_SS_OUT_0) && psw_mode) ? {256'b0, wo6, wo4, wo2, wo0} :
                                 ((state_ss_out_value == STATE_SS_OUT_0_TMP)) ? {wo6, wo4, wo2, wo0, ss_out_data_pipe[255:0]} :
                                  dw_mode ? ((ss_out_data_pipe >> (2 * DWIDTH)) | (ss0_out_data << (6 * DWIDTH))) :
                                            ((ss_out_data_pipe >> (1 * DWIDTH)) | (ss0_out_data << (7 * DWIDTH)));
  assign ss_out_data_pipe_ce   = ss0_out_fire;

  wire [511:0] ss_output_tmp =
    (bf1 & cf2) ? {wo7, wo5, wo6, wo4, wo3, wo1, wo2, wo0} :
    (bf1 & cf4) ? {wo7, wo5, wo3, wo1, wo6, wo4, wo2, wo0} :
    psw_mode    ? ss_out_data_pipe :
                  ss_output;

  assign ss_out_data   = ss_output_tmp;
  assign ss_out_valid  = (parallel_mode & ss0_out_valid & dw_mode) | (state_ss_out_value == STATE_SS_OUT_1);
  assign ss0_out_ready = (parallel_mode & dw_mode) ? ss_out_ready :
                          (state_ss_out_value == STATE_SS_OUT_0 |
                          (state_ss_out_value == STATE_SS_OUT_0_TMP & psw_mode));

  wire lsu_start_pipe0;
  REGISTER #(.N(1)) lsu_start_pipe0_reg (
    .clk(clk),
    .d(lsu_start),
    .q(lsu_start_pipe0)
  );

  lsu_core #(
    .AWIDTH(AWIDTH),
    .DWIDTH(DWIDTH),
    .RAM_READ_LATENCY(RAM_READ_LATENCY),
    .ID(ID)
  ) lsu_core (
    .port0_addr(port0_addr),
    .port0_d(port0_d),
    .port0_q(port0_q),
    .port0_ce(port0_ce),
    .port0_we(port0_we),

    .port1_addr(port1_addr),
    .port1_d(port1_d),
    .port1_q(port1_q),
    .port1_ce(port1_ce),
    .port1_we(port1_we),

    .port2_addr(port2_addr),
    .port2_d(port2_d),
    .port2_q(port2_q),
    .port2_ce(port2_ce),
    .port2_we(port2_we),

    .port3_addr(port3_addr),
    .port3_d(port3_d),
    .port3_q(port3_q),
    .port3_ce(port3_ce),
    .port3_we(port3_we),

    .ss_in_data(ss0_in_data),
    .ss_in_valid(ss0_in_valid),
    .ss_in_ready(ss0_in_ready),

    .ss_out_data(ss0_out_data),
    .ss_out_valid(ss0_out_valid),
    .ss_out_ready(ss0_out_ready),

    .ram_en(ram_en),

    .ram_en_init(ram_en_init),
    .ram_cnt_init(ram_cnt_init),

    .ram_block_factor(ram_block_factor),
    .ram_cyclic_factor(ram_cyclic_factor),
    .ram_stride(ram_stride),
    .ram_seg_stride(ram_seg_stride),
    .ram_addr_offset(ram_addr_offset),
    .seg_count(seg_count),
    .len(len),
    .mode(mode),

    .ram_block_factor_updated(ram_block_factor_updated),
    .ram_block_factor_base(ram_block_factor_base),
    .dw_mode(dw_mode),
    .dp_mode(dp_mode),
    .dp_mode_base0(dp_mode_base0),
    .dp_mode_base2(dp_mode_base2),

    .parallel_mode(parallel_mode),

    .parallel_in(parallel_in),
    .word0_in(word0_in),
    .word1_in(word1_in),
    .word2_in(word2_in),
    .word3_in(word3_in),

    .lsu_start(lsu_start_pipe0),
    .lsu_done(lsu_done),

    .clk(clk),
    .rst(rst)
  );
endmodule

