// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* DONT_TOUCH="yes" *)
module ff_bridge(lsu0_port1_we, cl_ctrl_we, lsu0_port2_addr, 
  lsu1_port0_ce, lsu0_port3_q, lsu0_port3_addr_ff, lsu1_port1_q, lsu0_port2_ce, cl_ctrl_d_ff, 
  lsu0_port2_ce_ff, lsu1_port0_addr_ff, lsu1_port2_ce_ff, cl_done, lsu1_port2_d, 
  socket_reset, lsu1_ram_en, lsu1_dp_mode, lsu1_port3_q_ff, lsu0_port2_d, lsu0_port3_q_ff, 
  lsu0_port1_we_ff, cl_ctrl_q_ff, lsu1_port2_ce, lsu0_dp_mode, lsu0_port1_q, cl_ctrl_addr_ff, 
  lsu0_ram_en_ff, lsu0_port1_d_ff, lsu1_port1_we_ff, lsu1_port1_d_ff, lsu0_port0_ce, 
  lsu1_port0_addr, lsu0_port0_addr, socket_reset_ff, lsu1_port3_q, lsu1_port1_we, clk0, 
  lsu0_port0_d_ff, lsu1_port0_d_ff, clk1, lsu0_port2_we, lsu0_port2_we_ff, lsu1_port0_q, 
  lsu0_port3_ce, cl_ctrl_ce_ff, lsu1_port2_we_ff, lsu0_port0_d, lsu1_dp_mode_ff, 
  lsu1_port1_d, lsu1_port3_ce_ff, lsu0_port3_ce_ff, stub_out, lsu0_port0_addr_ff, 
  lsu0_port3_we_ff, lsu0_port2_q_ff, lsu1_port2_d_ff, lsu1_port2_addr_ff, lsu1_ram_en_ff, 
  lsu1_port2_q_ff, lsu0_port3_addr, lsu0_port3_d, lsu1_port3_we_ff, lsu1_port3_we, 
  lsu1_port3_addr, cl_ctrl_addr, lsu0_port0_we_ff, lsu0_port0_we, lsu1_port0_we_ff, 
  cl_ctrl_ce, lsu0_port1_addr_ff, lsu1_port1_ce, lsu0_port2_q, lsu0_port2_d_ff, stub_in, 
  lsu1_port1_addr, cl_done_ff, lsu0_port1_addr, lsu0_port1_ce, cl_ctrl_we_ff, lsu1_port2_q, 
  cl_ctrl_d, lsu1_port0_we, lsu1_port1_addr_ff, cl_ctrl_q, lsu1_port1_ce_ff, 
  lsu0_port2_addr_ff, lsu0_port3_we, lsu0_ram_en, lsu1_port3_d, lsu0_port0_q_ff, 
  lsu1_port0_q_ff, lsu0_port1_ce_ff, lsu0_port1_d, lsu1_port3_ce, lsu1_port0_d, lsu0_port0_q, 
  lsu0_port1_q_ff, lsu1_port3_addr_ff, lsu1_port2_we, lsu1_port1_q_ff, lsu0_port3_d_ff, 
  lsu0_dp_mode_ff, lsu0_port0_ce_ff, lsu1_port2_addr, lsu1_port0_ce_ff, lsu1_port3_d_ff);
  input lsu0_port1_we;
  input cl_ctrl_we;
  input [11:0]lsu0_port2_addr;
  input lsu1_port0_ce;
  output [63:0]lsu0_port3_q;
  output [11:0]lsu0_port3_addr_ff;
  output [63:0]lsu1_port1_q;
  input lsu0_port2_ce;
  output [31:0]cl_ctrl_d_ff;
  output lsu0_port2_ce_ff;
  output [11:0]lsu1_port0_addr_ff;
  output lsu1_port2_ce_ff;
  output cl_done;
  input [63:0]lsu1_port2_d;
  input socket_reset;
  input [4:0]lsu1_ram_en;
  input lsu1_dp_mode;
  input [63:0]lsu1_port3_q_ff;
  input [63:0]lsu0_port2_d;
  input [63:0]lsu0_port3_q_ff;
  output lsu0_port1_we_ff;
  input [31:0]cl_ctrl_q_ff;
  input lsu1_port2_ce;
  input lsu0_dp_mode;
  output [63:0]lsu0_port1_q;
  output [11:0]cl_ctrl_addr_ff;
  output [4:0]lsu0_ram_en_ff;
  output [63:0]lsu0_port1_d_ff;
  output lsu1_port1_we_ff;
  output [63:0]lsu1_port1_d_ff;
  input lsu0_port0_ce;
  input [11:0]lsu1_port0_addr;
  input [11:0]lsu0_port0_addr;
  output socket_reset_ff;
  output [63:0]lsu1_port3_q;
  input lsu1_port1_we;
  input clk0;
  output [63:0]lsu0_port0_d_ff;
  output [63:0]lsu1_port0_d_ff;
  input clk1;
  input lsu0_port2_we;
  output lsu0_port2_we_ff;
  output [63:0]lsu1_port0_q;
  input lsu0_port3_ce;
  output cl_ctrl_ce_ff;
  output lsu1_port2_we_ff;
  input [63:0]lsu0_port0_d;
  output lsu1_dp_mode_ff;
  input [63:0]lsu1_port1_d;
  output lsu1_port3_ce_ff;
  output lsu0_port3_ce_ff;
  output stub_out;
  output [11:0]lsu0_port0_addr_ff;
  output lsu0_port3_we_ff;
  input [63:0]lsu0_port2_q_ff;
  output [63:0]lsu1_port2_d_ff;
  output [11:0]lsu1_port2_addr_ff;
  output [4:0]lsu1_ram_en_ff;
  input [63:0]lsu1_port2_q_ff;
  input [11:0]lsu0_port3_addr;
  input [63:0]lsu0_port3_d;
  output lsu1_port3_we_ff;
  input lsu1_port3_we;
  input [11:0]lsu1_port3_addr;
  input [11:0]cl_ctrl_addr;
  output lsu0_port0_we_ff;
  input lsu0_port0_we;
  output lsu1_port0_we_ff;
  input cl_ctrl_ce;
  output [11:0]lsu0_port1_addr_ff;
  input lsu1_port1_ce;
  output [63:0]lsu0_port2_q;
  output [63:0]lsu0_port2_d_ff;
  input stub_in;
  input [11:0]lsu1_port1_addr;
  input cl_done_ff;
  input [11:0]lsu0_port1_addr;
  input lsu0_port1_ce;
  output cl_ctrl_we_ff;
  output [63:0]lsu1_port2_q;
  input [31:0]cl_ctrl_d;
  input lsu1_port0_we;
  output [11:0]lsu1_port1_addr_ff;
  output [31:0]cl_ctrl_q;
  output lsu1_port1_ce_ff;
  output [11:0]lsu0_port2_addr_ff;
  input lsu0_port3_we;
  input [4:0]lsu0_ram_en;
  input [63:0]lsu1_port3_d;
  input [63:0]lsu0_port0_q_ff;
  input [63:0]lsu1_port0_q_ff;
  output lsu0_port1_ce_ff;
  input [63:0]lsu0_port1_d;
  input lsu1_port3_ce;
  input [63:0]lsu1_port0_d;
  output [63:0]lsu0_port0_q;
  input [63:0]lsu0_port1_q_ff;
  output [11:0]lsu1_port3_addr_ff;
  input lsu1_port2_we;
  input [63:0]lsu1_port1_q_ff;
  output [63:0]lsu0_port3_d_ff;
  output lsu0_dp_mode_ff;
  output lsu0_port0_ce_ff;
  input [11:0]lsu1_port2_addr;
  output lsu1_port0_ce_ff;
  output [63:0]lsu1_port3_d_ff;
endmodule
