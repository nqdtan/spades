// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module ff_bridge(lsu0_port1_we, cl_ctrl_we, lsu0_port2_addr, 
  lsu0_port3_ce_ff, lsu0_port3_q, stub_out, lsu0_port0_addr_ff, lsu0_port3_addr_ff, 
  lsu0_port2_ce, lsu0_port3_we_ff, lsu0_port2_q_ff, cl_ctrl_d_ff, lsu0_port3_addr, 
  lsu0_port3_d, lsu0_port2_ce_ff, cl_ctrl_addr, lsu0_port0_we_ff, cl_done, lsu0_port0_we, 
  cl_ctrl_ce, lsu0_port1_addr_ff, stub_in, lsu0_port2_d_ff, lsu0_port2_q, cl_done_ff, 
  lsu0_port1_addr, lsu0_port1_ce, socket_reset, cl_ctrl_we_ff, cl_ctrl_d, lsu0_port2_d, 
  lsu0_port3_q_ff, cl_ctrl_q, lsu0_port1_we_ff, cl_ctrl_q_ff, lsu0_port2_addr_ff, 
  lsu0_dp_mode, lsu0_port3_we, cl_ctrl_addr_ff, lsu0_port1_q, lsu0_ram_en, lsu0_port0_q_ff, 
  lsu0_ram_en_ff, lsu0_port1_d_ff, lsu0_port0_ce, socket_reset_ff, lsu0_port0_addr, 
  lsu0_port1_ce_ff, lsu0_port1_d, clk0, clk1, lsu0_port0_d_ff, lsu0_port2_we, lsu0_port0_q, 
  lsu0_port2_we_ff, lsu0_port1_q_ff, lsu0_port3_ce, lsu0_port3_d_ff, cl_ctrl_ce_ff, 
  lsu0_dp_mode_ff, lsu0_port0_ce_ff, lsu0_port0_d);
  input lsu0_port1_we;
  input cl_ctrl_we;
  input [11:0]lsu0_port2_addr;
  output lsu0_port3_ce_ff;
  output [63:0]lsu0_port3_q;
  output stub_out;
  output [11:0]lsu0_port0_addr_ff;
  output [11:0]lsu0_port3_addr_ff;
  input lsu0_port2_ce;
  output lsu0_port3_we_ff;
  input [63:0]lsu0_port2_q_ff;
  output [31:0]cl_ctrl_d_ff;
  input [11:0]lsu0_port3_addr;
  input [63:0]lsu0_port3_d;
  output lsu0_port2_ce_ff;
  input [11:0]cl_ctrl_addr;
  output lsu0_port0_we_ff;
  output cl_done;
  input lsu0_port0_we;
  input cl_ctrl_ce;
  output [11:0]lsu0_port1_addr_ff;
  input stub_in;
  output [63:0]lsu0_port2_d_ff;
  output [63:0]lsu0_port2_q;
  input cl_done_ff;
  input [11:0]lsu0_port1_addr;
  input lsu0_port1_ce;
  input socket_reset;
  output cl_ctrl_we_ff;
  input [31:0]cl_ctrl_d;
  input [63:0]lsu0_port2_d;
  input [63:0]lsu0_port3_q_ff;
  output [31:0]cl_ctrl_q;
  output lsu0_port1_we_ff;
  input [31:0]cl_ctrl_q_ff;
  output [11:0]lsu0_port2_addr_ff;
  input lsu0_dp_mode;
  input lsu0_port3_we;
  output [11:0]cl_ctrl_addr_ff;
  output [63:0]lsu0_port1_q;
  input [4:0]lsu0_ram_en;
  input [63:0]lsu0_port0_q_ff;
  output [4:0]lsu0_ram_en_ff;
  output [63:0]lsu0_port1_d_ff;
  input lsu0_port0_ce;
  output socket_reset_ff;
  input [11:0]lsu0_port0_addr;
  output lsu0_port1_ce_ff;
  input [63:0]lsu0_port1_d;
  input clk0;
  input clk1;
  output [63:0]lsu0_port0_d_ff;
  input lsu0_port2_we;
  output [63:0]lsu0_port0_q;
  output lsu0_port2_we_ff;
  input [63:0]lsu0_port1_q_ff;
  input lsu0_port3_ce;
  output [63:0]lsu0_port3_d_ff;
  output cl_ctrl_ce_ff;
  output lsu0_dp_mode_ff;
  output lsu0_port0_ce_ff;
  input [63:0]lsu0_port0_d;
endmodule
