`timescale 1ns/1ps
`include "socket_config.vh"

(* DONT_TOUCH = "yes" *)
module rg_cl_intf_pipe(
  output lsu0_dp_mode,

  output [12-1:0] lsu0_port0_addr,
  output [64-1:0] lsu0_port0_d,
  input  [64-1:0] lsu0_port0_q,
  output          lsu0_port0_ce,
  output          lsu0_port0_we,

  output [12-1:0] lsu0_port1_addr,
  output [64-1:0] lsu0_port1_d,
  input  [64-1:0] lsu0_port1_q,
  output          lsu0_port1_ce,
  output          lsu0_port1_we,

  output [12-1:0] lsu0_port2_addr,
  output [64-1:0] lsu0_port2_d,
  input  [64-1:0] lsu0_port2_q,
  output          lsu0_port2_ce,
  output          lsu0_port2_we,

  output [12-1:0] lsu0_port3_addr,
  output [64-1:0] lsu0_port3_d,
  input  [64-1:0] lsu0_port3_q,
  output          lsu0_port3_ce,
  output          lsu0_port3_we,

  output [4:0] lsu0_ram_en,

`ifndef SOCKET_S
  output lsu1_dp_mode,

  output [12-1:0] lsu1_port0_addr,
  output [64-1:0] lsu1_port0_d,
  input  [64-1:0] lsu1_port0_q,
  output          lsu1_port0_ce,
  output          lsu1_port0_we,

  output [12-1:0] lsu1_port1_addr,
  output [64-1:0] lsu1_port1_d,
  input  [64-1:0] lsu1_port1_q,
  output          lsu1_port1_ce,
  output          lsu1_port1_we,

  output [12-1:0] lsu1_port2_addr,
  output [64-1:0] lsu1_port2_d,
  input  [64-1:0] lsu1_port2_q,
  output          lsu1_port2_ce,
  output          lsu1_port2_we,

  output [12-1:0] lsu1_port3_addr,
  output [64-1:0] lsu1_port3_d,
  input  [64-1:0] lsu1_port3_q,
  output          lsu1_port3_ce,
  output          lsu1_port3_we,

  output [4:0] lsu1_ram_en,
`endif

  input         cl_done,
  output [11:0] cl_ctrl_addr,
  output [31:0] cl_ctrl_d,
  input  [31:0] cl_ctrl_q,
  output        cl_ctrl_ce,
  output        cl_ctrl_we,

  output socket_reset,

  // tmp
  input lsu0_dp_mode_tmp,

  input [12-1:0] lsu0_port0_addr_tmp,
  input [64-1:0] lsu0_port0_d_tmp,
  output  [64-1:0] lsu0_port0_q_tmp,
  input          lsu0_port0_ce_tmp,
  input          lsu0_port0_we_tmp,

  input [12-1:0] lsu0_port1_addr_tmp,
  input [64-1:0] lsu0_port1_d_tmp,
  output  [64-1:0] lsu0_port1_q_tmp,
  input          lsu0_port1_ce_tmp,
  input          lsu0_port1_we_tmp,

  input [12-1:0] lsu0_port2_addr_tmp,
  input [64-1:0] lsu0_port2_d_tmp,
  output  [64-1:0] lsu0_port2_q_tmp,
  input          lsu0_port2_ce_tmp,
  input          lsu0_port2_we_tmp,

  input [12-1:0] lsu0_port3_addr_tmp,
  input [64-1:0] lsu0_port3_d_tmp,
  output  [64-1:0] lsu0_port3_q_tmp,
  input          lsu0_port3_ce_tmp,
  input          lsu0_port3_we_tmp,

  input [4:0] lsu0_ram_en_tmp,

`ifndef SOCKET_S
  input lsu1_dp_mode_tmp,

  input [12-1:0] lsu1_port0_addr_tmp,
  input [64-1:0] lsu1_port0_d_tmp,
  output  [64-1:0] lsu1_port0_q_tmp,
  input          lsu1_port0_ce_tmp,
  input          lsu1_port0_we_tmp,

  input [12-1:0] lsu1_port1_addr_tmp,
  input [64-1:0] lsu1_port1_d_tmp,
  output  [64-1:0] lsu1_port1_q_tmp,
  input          lsu1_port1_ce_tmp,
  input          lsu1_port1_we_tmp,

  input [12-1:0] lsu1_port2_addr_tmp,
  input [64-1:0] lsu1_port2_d_tmp,
  output  [64-1:0] lsu1_port2_q_tmp,
  input          lsu1_port2_ce_tmp,
  input          lsu1_port2_we_tmp,

  input [12-1:0] lsu1_port3_addr_tmp,
  input [64-1:0] lsu1_port3_d_tmp,
  output  [64-1:0] lsu1_port3_q_tmp,
  input          lsu1_port3_ce_tmp,
  input          lsu1_port3_we_tmp,

  input [4:0] lsu1_ram_en_tmp,
`endif

  output         cl_done_tmp,
  input [11:0] cl_ctrl_addr_tmp,
  input [31:0] cl_ctrl_d_tmp,
  output  [31:0] cl_ctrl_q_tmp,
  input        cl_ctrl_ce_tmp,
  input        cl_ctrl_we_tmp,

  input socket_reset_tmp,

  input clk
);

  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_dp_mode_pb (
    .clk(clk),
    .d(lsu0_dp_mode_tmp),
    .q(lsu0_dp_mode)
  );
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu0_port0_addr_pb (
    .clk(clk),
    .d(lsu0_port0_addr_tmp),
    .q(lsu0_port0_addr)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port0_d_pb (
    .clk(clk),
    .d(lsu0_port0_d_tmp),
    .q(lsu0_port0_d)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port0_q_pb (
    .clk(clk),
    .d(lsu0_port0_q),
    .q(lsu0_port0_q_tmp)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port0_ce_pb (
    .clk(clk),
    .d(lsu0_port0_ce_tmp),
    .q(lsu0_port0_ce)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port0_we_pb (
    .clk(clk),
    .d(lsu0_port0_we_tmp),
    .q(lsu0_port0_we)
  );
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu0_port1_addr_pb (
    .clk(clk),
    .d(lsu0_port1_addr_tmp),
    .q(lsu0_port1_addr)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port1_d_pb (
    .clk(clk),
    .d(lsu0_port1_d_tmp),
    .q(lsu0_port1_d)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port1_q_pb (
    .clk(clk),
    .d(lsu0_port1_q),
    .q(lsu0_port1_q_tmp)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port1_ce_pb (
    .clk(clk),
    .d(lsu0_port1_ce_tmp),
    .q(lsu0_port1_ce)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port1_we_pb (
    .clk(clk),
    .d(lsu0_port1_we_tmp),
    .q(lsu0_port1_we)
  );
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu0_port2_addr_pb (
    .clk(clk),
    .d(lsu0_port2_addr_tmp),
    .q(lsu0_port2_addr)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port2_d_pb (
    .clk(clk),
    .d(lsu0_port2_d_tmp),
    .q(lsu0_port2_d)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port2_q_pb (
    .clk(clk),
    .d(lsu0_port2_q),
    .q(lsu0_port2_q_tmp)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port2_ce_pb (
    .clk(clk),
    .d(lsu0_port2_ce_tmp),
    .q(lsu0_port2_ce)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port2_we_pb (
    .clk(clk),
    .d(lsu0_port2_we_tmp),
    .q(lsu0_port2_we)
  );
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu0_port3_addr_pb (
    .clk(clk),
    .d(lsu0_port3_addr_tmp),
    .q(lsu0_port3_addr)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port3_d_pb (
    .clk(clk),
    .d(lsu0_port3_d_tmp),
    .q(lsu0_port3_d)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu0_port3_q_pb (
    .clk(clk),
    .d(lsu0_port3_q),
    .q(lsu0_port3_q_tmp)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port3_ce_pb (
    .clk(clk),
    .d(lsu0_port3_ce_tmp),
    .q(lsu0_port3_ce)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu0_port3_we_pb (
    .clk(clk),
    .d(lsu0_port3_we_tmp),
    .q(lsu0_port3_we)
  );
  pipe_block #(.WIDTH(5), .NUM_STAGES(1)) lsu0_ram_en_pb (
    .clk(clk),
    .d(lsu0_ram_en_tmp),
    .q(lsu0_ram_en)
  );
`ifndef SOCKET_S
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_dp_mode_pb (
    .clk(clk),
    .d(lsu1_dp_mode_tmp),
    .q(lsu1_dp_mode)
  );
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu1_port0_addr_pb (
    .clk(clk),
    .d(lsu1_port0_addr_tmp),
    .q(lsu1_port0_addr)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port0_d_pb (
    .clk(clk),
    .d(lsu1_port0_d_tmp),
    .q(lsu1_port0_d)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port0_q_pb (
    .clk(clk),
    .d(lsu1_port0_q),
    .q(lsu1_port0_q_tmp)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port0_ce_pb (
    .clk(clk),
    .d(lsu1_port0_ce_tmp),
    .q(lsu1_port0_ce)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port0_we_pb (
    .clk(clk),
    .d(lsu1_port0_we_tmp),
    .q(lsu1_port0_we)
  );
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu1_port1_addr_pb (
    .clk(clk),
    .d(lsu1_port1_addr_tmp),
    .q(lsu1_port1_addr)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port1_d_pb (
    .clk(clk),
    .d(lsu1_port1_d_tmp),
    .q(lsu1_port1_d)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port1_q_pb (
    .clk(clk),
    .d(lsu1_port1_q),
    .q(lsu1_port1_q_tmp)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port1_ce_pb (
    .clk(clk),
    .d(lsu1_port1_ce_tmp),
    .q(lsu1_port1_ce)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port1_we_pb (
    .clk(clk),
    .d(lsu1_port1_we_tmp),
    .q(lsu1_port1_we)
  );
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu1_port2_addr_pb (
    .clk(clk),
    .d(lsu1_port2_addr_tmp),
    .q(lsu1_port2_addr)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port2_d_pb (
    .clk(clk),
    .d(lsu1_port2_d_tmp),
    .q(lsu1_port2_d)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port2_q_pb (
    .clk(clk),
    .d(lsu1_port2_q),
    .q(lsu1_port2_q_tmp)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port2_ce_pb (
    .clk(clk),
    .d(lsu1_port2_ce_tmp),
    .q(lsu1_port2_ce)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port2_we_pb (
    .clk(clk),
    .d(lsu1_port2_we_tmp),
    .q(lsu1_port2_we)
  );
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) lsu1_port3_addr_pb (
    .clk(clk),
    .d(lsu1_port3_addr_tmp),
    .q(lsu1_port3_addr)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port3_d_pb (
    .clk(clk),
    .d(lsu1_port3_d_tmp),
    .q(lsu1_port3_d)
  );
  pipe_block #(.WIDTH(64), .NUM_STAGES(1)) lsu1_port3_q_pb (
    .clk(clk),
    .d(lsu1_port3_q),
    .q(lsu1_port3_q_tmp)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port3_ce_pb (
    .clk(clk),
    .d(lsu1_port3_ce_tmp),
    .q(lsu1_port3_ce)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) lsu1_port3_we_pb (
    .clk(clk),
    .d(lsu1_port3_we_tmp),
    .q(lsu1_port3_we)
  );
  pipe_block #(.WIDTH(5), .NUM_STAGES(1)) lsu1_ram_en_pb (
    .clk(clk),
    .d(lsu1_ram_en_tmp),
    .q(lsu1_ram_en)
  );
`endif
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) cl_done_pb (
    .clk(clk),
    .d(cl_done),
    .q(cl_done_tmp)
  );
  pipe_block #(.WIDTH(12), .NUM_STAGES(1)) cl_ctrl_addr_pb (
    .clk(clk),
    .d(cl_ctrl_addr_tmp),
    .q(cl_ctrl_addr)
  );
  pipe_block #(.WIDTH(32), .NUM_STAGES(1)) cl_ctrl_d_pb (
    .clk(clk),
    .d(cl_ctrl_d_tmp),
    .q(cl_ctrl_d)
  );
  pipe_block #(.WIDTH(32), .NUM_STAGES(1)) cl_ctrl_q_pb (
    .clk(clk),
    .d(cl_ctrl_q),
    .q(cl_ctrl_q_tmp)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) cl_ctrl_ce_pb (
    .clk(clk),
    .d(cl_ctrl_ce_tmp),
    .q(cl_ctrl_ce)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) cl_ctrl_we_pb (
    .clk(clk),
    .d(cl_ctrl_we_tmp),
    .q(cl_ctrl_we)
  );
  pipe_block #(.WIDTH(1), .NUM_STAGES(1)) socket_reset_pb (
    .clk(clk),
    .d(socket_reset_tmp),
    .q(socket_reset)
  );

endmodule
