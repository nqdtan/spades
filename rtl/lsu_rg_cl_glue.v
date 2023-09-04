module lsu_rg_cl_glue #(
  parameter NUM_RAMS = 40
) (

  input  [12-1:0] lsu0_port0_addr,
  input  [64-1:0] lsu0_port0_d,
  output [64-1:0] lsu0_port0_q,
  input           lsu0_port0_ce,
  input           lsu0_port0_we,

  input  [12-1:0] lsu0_port1_addr,
  input  [64-1:0] lsu0_port1_d,
  output [64-1:0] lsu0_port1_q,
  input           lsu0_port1_ce,
  input           lsu0_port1_we,

  input  [12-1:0] lsu0_port2_addr,
  input  [64-1:0] lsu0_port2_d,
  output [64-1:0] lsu0_port2_q,
  input           lsu0_port2_ce,
  input           lsu0_port2_we,

  input  [12-1:0] lsu0_port3_addr,
  input  [64-1:0] lsu0_port3_d,
  output [64-1:0] lsu0_port3_q,
  input           lsu0_port3_ce,
  input           lsu0_port3_we,
  input lsu0_dp_mode,
  input [4:0] lsu0_ram_en,

  input  [12-1:0] lsu1_port0_addr,
  input  [64-1:0] lsu1_port0_d,
  output [64-1:0] lsu1_port0_q,
  input           lsu1_port0_ce,
  input           lsu1_port0_we,

  input  [12-1:0] lsu1_port1_addr,
  input  [64-1:0] lsu1_port1_d,
  output [64-1:0] lsu1_port1_q,
  input           lsu1_port1_ce,
  input           lsu1_port1_we,

  input  [12-1:0] lsu1_port2_addr,
  input  [64-1:0] lsu1_port2_d,
  output [64-1:0] lsu1_port2_q,
  input           lsu1_port2_ce,
  input           lsu1_port2_we,

  input  [12-1:0] lsu1_port3_addr,
  input  [64-1:0] lsu1_port3_d,
  output [64-1:0] lsu1_port3_q,
  input           lsu1_port3_ce,
  input           lsu1_port3_we,
  input lsu1_dp_mode,
  input [4:0] lsu1_ram_en,

  input [11:0] cl_rg_0_0_addr0,
  input [63:0] cl_rg_0_0_d0,
  output [63:0] cl_rg_0_0_q0,
  input cl_rg_0_0_ce0,
  input cl_rg_0_0_we0,
  input [11:0] cl_rg_0_0_addr1,
  input [63:0] cl_rg_0_0_d1,
  output [63:0] cl_rg_0_0_q1,
  input cl_rg_0_0_ce1,
  input cl_rg_0_0_we1,

  input [11:0] cl_rg_0_1_addr0,
  input [63:0] cl_rg_0_1_d0,
  output [63:0] cl_rg_0_1_q0,
  input cl_rg_0_1_ce0,
  input cl_rg_0_1_we0,
  input [11:0] cl_rg_0_1_addr1,
  input [63:0] cl_rg_0_1_d1,
  output [63:0] cl_rg_0_1_q1,
  input cl_rg_0_1_ce1,
  input cl_rg_0_1_we1,

  input [11:0] cl_rg_0_2_addr0,
  input [63:0] cl_rg_0_2_d0,
  output [63:0] cl_rg_0_2_q0,
  input cl_rg_0_2_ce0,
  input cl_rg_0_2_we0,
  input [11:0] cl_rg_0_2_addr1,
  input [63:0] cl_rg_0_2_d1,
  output [63:0] cl_rg_0_2_q1,
  input cl_rg_0_2_ce1,
  input cl_rg_0_2_we1,

  input [11:0] cl_rg_0_3_addr0,
  input [63:0] cl_rg_0_3_d0,
  output [63:0] cl_rg_0_3_q0,
  input cl_rg_0_3_ce0,
  input cl_rg_0_3_we0,
  input [11:0] cl_rg_0_3_addr1,
  input [63:0] cl_rg_0_3_d1,
  output [63:0] cl_rg_0_3_q1,
  input cl_rg_0_3_ce1,
  input cl_rg_0_3_we1,

  input [11:0] cl_rg_1_0_addr0,
  input [63:0] cl_rg_1_0_d0,
  output [63:0] cl_rg_1_0_q0,
  input cl_rg_1_0_ce0,
  input cl_rg_1_0_we0,
  input [11:0] cl_rg_1_0_addr1,
  input [63:0] cl_rg_1_0_d1,
  output [63:0] cl_rg_1_0_q1,
  input cl_rg_1_0_ce1,
  input cl_rg_1_0_we1,

  input [11:0] cl_rg_1_1_addr0,
  input [63:0] cl_rg_1_1_d0,
  output [63:0] cl_rg_1_1_q0,
  input cl_rg_1_1_ce0,
  input cl_rg_1_1_we0,
  input [11:0] cl_rg_1_1_addr1,
  input [63:0] cl_rg_1_1_d1,
  output [63:0] cl_rg_1_1_q1,
  input cl_rg_1_1_ce1,
  input cl_rg_1_1_we1,

  input [11:0] cl_rg_1_2_addr0,
  input [63:0] cl_rg_1_2_d0,
  output [63:0] cl_rg_1_2_q0,
  input cl_rg_1_2_ce0,
  input cl_rg_1_2_we0,
  input [11:0] cl_rg_1_2_addr1,
  input [63:0] cl_rg_1_2_d1,
  output [63:0] cl_rg_1_2_q1,
  input cl_rg_1_2_ce1,
  input cl_rg_1_2_we1,

  input [11:0] cl_rg_1_3_addr0,
  input [63:0] cl_rg_1_3_d0,
  output [63:0] cl_rg_1_3_q0,
  input cl_rg_1_3_ce0,
  input cl_rg_1_3_we0,
  input [11:0] cl_rg_1_3_addr1,
  input [63:0] cl_rg_1_3_d1,
  output [63:0] cl_rg_1_3_q1,
  input cl_rg_1_3_ce1,
  input cl_rg_1_3_we1,

  input [11:0] cl_rg_2_0_addr0,
  input [63:0] cl_rg_2_0_d0,
  output [63:0] cl_rg_2_0_q0,
  input cl_rg_2_0_ce0,
  input cl_rg_2_0_we0,
  input [11:0] cl_rg_2_0_addr1,
  input [63:0] cl_rg_2_0_d1,
  output [63:0] cl_rg_2_0_q1,
  input cl_rg_2_0_ce1,
  input cl_rg_2_0_we1,

  input [11:0] cl_rg_2_1_addr0,
  input [63:0] cl_rg_2_1_d0,
  output [63:0] cl_rg_2_1_q0,
  input cl_rg_2_1_ce0,
  input cl_rg_2_1_we0,
  input [11:0] cl_rg_2_1_addr1,
  input [63:0] cl_rg_2_1_d1,
  output [63:0] cl_rg_2_1_q1,
  input cl_rg_2_1_ce1,
  input cl_rg_2_1_we1,

  input [11:0] cl_rg_2_2_addr0,
  input [63:0] cl_rg_2_2_d0,
  output [63:0] cl_rg_2_2_q0,
  input cl_rg_2_2_ce0,
  input cl_rg_2_2_we0,
  input [11:0] cl_rg_2_2_addr1,
  input [63:0] cl_rg_2_2_d1,
  output [63:0] cl_rg_2_2_q1,
  input cl_rg_2_2_ce1,
  input cl_rg_2_2_we1,

  input [11:0] cl_rg_2_3_addr0,
  input [63:0] cl_rg_2_3_d0,
  output [63:0] cl_rg_2_3_q0,
  input cl_rg_2_3_ce0,
  input cl_rg_2_3_we0,
  input [11:0] cl_rg_2_3_addr1,
  input [63:0] cl_rg_2_3_d1,
  output [63:0] cl_rg_2_3_q1,
  input cl_rg_2_3_ce1,
  input cl_rg_2_3_we1,

  input [11:0] cl_rg_3_0_addr0,
  input [63:0] cl_rg_3_0_d0,
  output [63:0] cl_rg_3_0_q0,
  input cl_rg_3_0_ce0,
  input cl_rg_3_0_we0,
  input [11:0] cl_rg_3_0_addr1,
  input [63:0] cl_rg_3_0_d1,
  output [63:0] cl_rg_3_0_q1,
  input cl_rg_3_0_ce1,
  input cl_rg_3_0_we1,

  input [11:0] cl_rg_3_1_addr0,
  input [63:0] cl_rg_3_1_d0,
  output [63:0] cl_rg_3_1_q0,
  input cl_rg_3_1_ce0,
  input cl_rg_3_1_we0,
  input [11:0] cl_rg_3_1_addr1,
  input [63:0] cl_rg_3_1_d1,
  output [63:0] cl_rg_3_1_q1,
  input cl_rg_3_1_ce1,
  input cl_rg_3_1_we1,

  input [11:0] cl_rg_3_2_addr0,
  input [63:0] cl_rg_3_2_d0,
  output [63:0] cl_rg_3_2_q0,
  input cl_rg_3_2_ce0,
  input cl_rg_3_2_we0,
  input [11:0] cl_rg_3_2_addr1,
  input [63:0] cl_rg_3_2_d1,
  output [63:0] cl_rg_3_2_q1,
  input cl_rg_3_2_ce1,
  input cl_rg_3_2_we1,

  input [11:0] cl_rg_3_3_addr0,
  input [63:0] cl_rg_3_3_d0,
  output [63:0] cl_rg_3_3_q0,
  input cl_rg_3_3_ce0,
  input cl_rg_3_3_we0,
  input [11:0] cl_rg_3_3_addr1,
  input [63:0] cl_rg_3_3_d1,
  output [63:0] cl_rg_3_3_q1,
  input cl_rg_3_3_ce1,
  input cl_rg_3_3_we1,

  input [11:0] cl_rg_4_0_addr0,
  input [63:0] cl_rg_4_0_d0,
  output [63:0] cl_rg_4_0_q0,
  input cl_rg_4_0_ce0,
  input cl_rg_4_0_we0,
  input [11:0] cl_rg_4_0_addr1,
  input [63:0] cl_rg_4_0_d1,
  output [63:0] cl_rg_4_0_q1,
  input cl_rg_4_0_ce1,
  input cl_rg_4_0_we1,

  input [11:0] cl_rg_4_1_addr0,
  input [63:0] cl_rg_4_1_d0,
  output [63:0] cl_rg_4_1_q0,
  input cl_rg_4_1_ce0,
  input cl_rg_4_1_we0,
  input [11:0] cl_rg_4_1_addr1,
  input [63:0] cl_rg_4_1_d1,
  output [63:0] cl_rg_4_1_q1,
  input cl_rg_4_1_ce1,
  input cl_rg_4_1_we1,

  input [11:0] cl_rg_4_2_addr0,
  input [63:0] cl_rg_4_2_d0,
  output [63:0] cl_rg_4_2_q0,
  input cl_rg_4_2_ce0,
  input cl_rg_4_2_we0,
  input [11:0] cl_rg_4_2_addr1,
  input [63:0] cl_rg_4_2_d1,
  output [63:0] cl_rg_4_2_q1,
  input cl_rg_4_2_ce1,
  input cl_rg_4_2_we1,

  input [11:0] cl_rg_4_3_addr0,
  input [63:0] cl_rg_4_3_d0,
  output [63:0] cl_rg_4_3_q0,
  input cl_rg_4_3_ce0,
  input cl_rg_4_3_we0,
  input [11:0] cl_rg_4_3_addr1,
  input [63:0] cl_rg_4_3_d1,
  output [63:0] cl_rg_4_3_q1,
  input cl_rg_4_3_ce1,
  input cl_rg_4_3_we1,

  input [11:0] cl_rg_5_0_addr0,
  input [63:0] cl_rg_5_0_d0,
  output [63:0] cl_rg_5_0_q0,
  input cl_rg_5_0_ce0,
  input cl_rg_5_0_we0,
  input [11:0] cl_rg_5_0_addr1,
  input [63:0] cl_rg_5_0_d1,
  output [63:0] cl_rg_5_0_q1,
  input cl_rg_5_0_ce1,
  input cl_rg_5_0_we1,

  input [11:0] cl_rg_5_1_addr0,
  input [63:0] cl_rg_5_1_d0,
  output [63:0] cl_rg_5_1_q0,
  input cl_rg_5_1_ce0,
  input cl_rg_5_1_we0,
  input [11:0] cl_rg_5_1_addr1,
  input [63:0] cl_rg_5_1_d1,
  output [63:0] cl_rg_5_1_q1,
  input cl_rg_5_1_ce1,
  input cl_rg_5_1_we1,

  input [11:0] cl_rg_5_2_addr0,
  input [63:0] cl_rg_5_2_d0,
  output [63:0] cl_rg_5_2_q0,
  input cl_rg_5_2_ce0,
  input cl_rg_5_2_we0,
  input [11:0] cl_rg_5_2_addr1,
  input [63:0] cl_rg_5_2_d1,
  output [63:0] cl_rg_5_2_q1,
  input cl_rg_5_2_ce1,
  input cl_rg_5_2_we1,

  input [11:0] cl_rg_5_3_addr0,
  input [63:0] cl_rg_5_3_d0,
  output [63:0] cl_rg_5_3_q0,
  input cl_rg_5_3_ce0,
  input cl_rg_5_3_we0,
  input [11:0] cl_rg_5_3_addr1,
  input [63:0] cl_rg_5_3_d1,
  output [63:0] cl_rg_5_3_q1,
  input cl_rg_5_3_ce1,
  input cl_rg_5_3_we1,

  input [11:0] cl_rg_6_0_addr0,
  input [63:0] cl_rg_6_0_d0,
  output [63:0] cl_rg_6_0_q0,
  input cl_rg_6_0_ce0,
  input cl_rg_6_0_we0,
  input [11:0] cl_rg_6_0_addr1,
  input [63:0] cl_rg_6_0_d1,
  output [63:0] cl_rg_6_0_q1,
  input cl_rg_6_0_ce1,
  input cl_rg_6_0_we1,

  input [11:0] cl_rg_6_1_addr0,
  input [63:0] cl_rg_6_1_d0,
  output [63:0] cl_rg_6_1_q0,
  input cl_rg_6_1_ce0,
  input cl_rg_6_1_we0,
  input [11:0] cl_rg_6_1_addr1,
  input [63:0] cl_rg_6_1_d1,
  output [63:0] cl_rg_6_1_q1,
  input cl_rg_6_1_ce1,
  input cl_rg_6_1_we1,

  input [11:0] cl_rg_6_2_addr0,
  input [63:0] cl_rg_6_2_d0,
  output [63:0] cl_rg_6_2_q0,
  input cl_rg_6_2_ce0,
  input cl_rg_6_2_we0,
  input [11:0] cl_rg_6_2_addr1,
  input [63:0] cl_rg_6_2_d1,
  output [63:0] cl_rg_6_2_q1,
  input cl_rg_6_2_ce1,
  input cl_rg_6_2_we1,

  input [11:0] cl_rg_6_3_addr0,
  input [63:0] cl_rg_6_3_d0,
  output [63:0] cl_rg_6_3_q0,
  input cl_rg_6_3_ce0,
  input cl_rg_6_3_we0,
  input [11:0] cl_rg_6_3_addr1,
  input [63:0] cl_rg_6_3_d1,
  output [63:0] cl_rg_6_3_q1,
  input cl_rg_6_3_ce1,
  input cl_rg_6_3_we1,

  input [11:0] cl_rg_7_0_addr0,
  input [63:0] cl_rg_7_0_d0,
  output [63:0] cl_rg_7_0_q0,
  input cl_rg_7_0_ce0,
  input cl_rg_7_0_we0,
  input [11:0] cl_rg_7_0_addr1,
  input [63:0] cl_rg_7_0_d1,
  output [63:0] cl_rg_7_0_q1,
  input cl_rg_7_0_ce1,
  input cl_rg_7_0_we1,

  input [11:0] cl_rg_7_1_addr0,
  input [63:0] cl_rg_7_1_d0,
  output [63:0] cl_rg_7_1_q0,
  input cl_rg_7_1_ce0,
  input cl_rg_7_1_we0,
  input [11:0] cl_rg_7_1_addr1,
  input [63:0] cl_rg_7_1_d1,
  output [63:0] cl_rg_7_1_q1,
  input cl_rg_7_1_ce1,
  input cl_rg_7_1_we1,

  input [11:0] cl_rg_7_2_addr0,
  input [63:0] cl_rg_7_2_d0,
  output [63:0] cl_rg_7_2_q0,
  input cl_rg_7_2_ce0,
  input cl_rg_7_2_we0,
  input [11:0] cl_rg_7_2_addr1,
  input [63:0] cl_rg_7_2_d1,
  output [63:0] cl_rg_7_2_q1,
  input cl_rg_7_2_ce1,
  input cl_rg_7_2_we1,

  input [11:0] cl_rg_7_3_addr0,
  input [63:0] cl_rg_7_3_d0,
  output [63:0] cl_rg_7_3_q0,
  input cl_rg_7_3_ce0,
  input cl_rg_7_3_we0,
  input [11:0] cl_rg_7_3_addr1,
  input [63:0] cl_rg_7_3_d1,
  output [63:0] cl_rg_7_3_q1,
  input cl_rg_7_3_ce1,
  input cl_rg_7_3_we1,

  input [11:0] cl_rg_8_0_addr0,
  input [63:0] cl_rg_8_0_d0,
  output [63:0] cl_rg_8_0_q0,
  input cl_rg_8_0_ce0,
  input cl_rg_8_0_we0,
  input [11:0] cl_rg_8_0_addr1,
  input [63:0] cl_rg_8_0_d1,
  output [63:0] cl_rg_8_0_q1,
  input cl_rg_8_0_ce1,
  input cl_rg_8_0_we1,

  input [11:0] cl_rg_8_1_addr0,
  input [63:0] cl_rg_8_1_d0,
  output [63:0] cl_rg_8_1_q0,
  input cl_rg_8_1_ce0,
  input cl_rg_8_1_we0,
  input [11:0] cl_rg_8_1_addr1,
  input [63:0] cl_rg_8_1_d1,
  output [63:0] cl_rg_8_1_q1,
  input cl_rg_8_1_ce1,
  input cl_rg_8_1_we1,

  input [11:0] cl_rg_8_2_addr0,
  input [63:0] cl_rg_8_2_d0,
  output [63:0] cl_rg_8_2_q0,
  input cl_rg_8_2_ce0,
  input cl_rg_8_2_we0,
  input [11:0] cl_rg_8_2_addr1,
  input [63:0] cl_rg_8_2_d1,
  output [63:0] cl_rg_8_2_q1,
  input cl_rg_8_2_ce1,
  input cl_rg_8_2_we1,

  input [11:0] cl_rg_8_3_addr0,
  input [63:0] cl_rg_8_3_d0,
  output [63:0] cl_rg_8_3_q0,
  input cl_rg_8_3_ce0,
  input cl_rg_8_3_we0,
  input [11:0] cl_rg_8_3_addr1,
  input [63:0] cl_rg_8_3_d1,
  output [63:0] cl_rg_8_3_q1,
  input cl_rg_8_3_ce1,
  input cl_rg_8_3_we1,

  input [11:0] cl_rg_9_0_addr0,
  input [63:0] cl_rg_9_0_d0,
  output [63:0] cl_rg_9_0_q0,
  input cl_rg_9_0_ce0,
  input cl_rg_9_0_we0,
  input [11:0] cl_rg_9_0_addr1,
  input [63:0] cl_rg_9_0_d1,
  output [63:0] cl_rg_9_0_q1,
  input cl_rg_9_0_ce1,
  input cl_rg_9_0_we1,

  input [11:0] cl_rg_9_1_addr0,
  input [63:0] cl_rg_9_1_d0,
  output [63:0] cl_rg_9_1_q0,
  input cl_rg_9_1_ce0,
  input cl_rg_9_1_we0,
  input [11:0] cl_rg_9_1_addr1,
  input [63:0] cl_rg_9_1_d1,
  output [63:0] cl_rg_9_1_q1,
  input cl_rg_9_1_ce1,
  input cl_rg_9_1_we1,

  input [11:0] cl_rg_9_2_addr0,
  input [63:0] cl_rg_9_2_d0,
  output [63:0] cl_rg_9_2_q0,
  input cl_rg_9_2_ce0,
  input cl_rg_9_2_we0,
  input [11:0] cl_rg_9_2_addr1,
  input [63:0] cl_rg_9_2_d1,
  output [63:0] cl_rg_9_2_q1,
  input cl_rg_9_2_ce1,
  input cl_rg_9_2_we1,

  input [11:0] cl_rg_9_3_addr0,
  input [63:0] cl_rg_9_3_d0,
  output [63:0] cl_rg_9_3_q0,
  input cl_rg_9_3_ce0,
  input cl_rg_9_3_we0,
  input [11:0] cl_rg_9_3_addr1,
  input [63:0] cl_rg_9_3_d1,
  output [63:0] cl_rg_9_3_q1,
  input cl_rg_9_3_ce1,
  input cl_rg_9_3_we1,

  input [11:0] cl_rg_10_0_addr0,
  input [63:0] cl_rg_10_0_d0,
  output [63:0] cl_rg_10_0_q0,
  input cl_rg_10_0_ce0,
  input cl_rg_10_0_we0,
  input [11:0] cl_rg_10_0_addr1,
  input [63:0] cl_rg_10_0_d1,
  output [63:0] cl_rg_10_0_q1,
  input cl_rg_10_0_ce1,
  input cl_rg_10_0_we1,

  input [11:0] cl_rg_10_1_addr0,
  input [63:0] cl_rg_10_1_d0,
  output [63:0] cl_rg_10_1_q0,
  input cl_rg_10_1_ce0,
  input cl_rg_10_1_we0,
  input [11:0] cl_rg_10_1_addr1,
  input [63:0] cl_rg_10_1_d1,
  output [63:0] cl_rg_10_1_q1,
  input cl_rg_10_1_ce1,
  input cl_rg_10_1_we1,

  input [11:0] cl_rg_10_2_addr0,
  input [63:0] cl_rg_10_2_d0,
  output [63:0] cl_rg_10_2_q0,
  input cl_rg_10_2_ce0,
  input cl_rg_10_2_we0,
  input [11:0] cl_rg_10_2_addr1,
  input [63:0] cl_rg_10_2_d1,
  output [63:0] cl_rg_10_2_q1,
  input cl_rg_10_2_ce1,
  input cl_rg_10_2_we1,

  input [11:0] cl_rg_10_3_addr0,
  input [63:0] cl_rg_10_3_d0,
  output [63:0] cl_rg_10_3_q0,
  input cl_rg_10_3_ce0,
  input cl_rg_10_3_we0,
  input [11:0] cl_rg_10_3_addr1,
  input [63:0] cl_rg_10_3_d1,
  output [63:0] cl_rg_10_3_q1,
  input cl_rg_10_3_ce1,
  input cl_rg_10_3_we1,

  input [11:0] cl_rg_11_0_addr0,
  input [63:0] cl_rg_11_0_d0,
  output [63:0] cl_rg_11_0_q0,
  input cl_rg_11_0_ce0,
  input cl_rg_11_0_we0,
  input [11:0] cl_rg_11_0_addr1,
  input [63:0] cl_rg_11_0_d1,
  output [63:0] cl_rg_11_0_q1,
  input cl_rg_11_0_ce1,
  input cl_rg_11_0_we1,

  input [11:0] cl_rg_11_1_addr0,
  input [63:0] cl_rg_11_1_d0,
  output [63:0] cl_rg_11_1_q0,
  input cl_rg_11_1_ce0,
  input cl_rg_11_1_we0,
  input [11:0] cl_rg_11_1_addr1,
  input [63:0] cl_rg_11_1_d1,
  output [63:0] cl_rg_11_1_q1,
  input cl_rg_11_1_ce1,
  input cl_rg_11_1_we1,

  input [11:0] cl_rg_11_2_addr0,
  input [63:0] cl_rg_11_2_d0,
  output [63:0] cl_rg_11_2_q0,
  input cl_rg_11_2_ce0,
  input cl_rg_11_2_we0,
  input [11:0] cl_rg_11_2_addr1,
  input [63:0] cl_rg_11_2_d1,
  output [63:0] cl_rg_11_2_q1,
  input cl_rg_11_2_ce1,
  input cl_rg_11_2_we1,

  input [11:0] cl_rg_11_3_addr0,
  input [63:0] cl_rg_11_3_d0,
  output [63:0] cl_rg_11_3_q0,
  input cl_rg_11_3_ce0,
  input cl_rg_11_3_we0,
  input [11:0] cl_rg_11_3_addr1,
  input [63:0] cl_rg_11_3_d1,
  output [63:0] cl_rg_11_3_q1,
  input cl_rg_11_3_ce1,
  input cl_rg_11_3_we1,

  input [11:0] cl_rg_12_0_addr0,
  input [63:0] cl_rg_12_0_d0,
  output [63:0] cl_rg_12_0_q0,
  input cl_rg_12_0_ce0,
  input cl_rg_12_0_we0,
  input [11:0] cl_rg_12_0_addr1,
  input [63:0] cl_rg_12_0_d1,
  output [63:0] cl_rg_12_0_q1,
  input cl_rg_12_0_ce1,
  input cl_rg_12_0_we1,

  input [11:0] cl_rg_12_1_addr0,
  input [63:0] cl_rg_12_1_d0,
  output [63:0] cl_rg_12_1_q0,
  input cl_rg_12_1_ce0,
  input cl_rg_12_1_we0,
  input [11:0] cl_rg_12_1_addr1,
  input [63:0] cl_rg_12_1_d1,
  output [63:0] cl_rg_12_1_q1,
  input cl_rg_12_1_ce1,
  input cl_rg_12_1_we1,

  input [11:0] cl_rg_12_2_addr0,
  input [63:0] cl_rg_12_2_d0,
  output [63:0] cl_rg_12_2_q0,
  input cl_rg_12_2_ce0,
  input cl_rg_12_2_we0,
  input [11:0] cl_rg_12_2_addr1,
  input [63:0] cl_rg_12_2_d1,
  output [63:0] cl_rg_12_2_q1,
  input cl_rg_12_2_ce1,
  input cl_rg_12_2_we1,

  input [11:0] cl_rg_12_3_addr0,
  input [63:0] cl_rg_12_3_d0,
  output [63:0] cl_rg_12_3_q0,
  input cl_rg_12_3_ce0,
  input cl_rg_12_3_we0,
  input [11:0] cl_rg_12_3_addr1,
  input [63:0] cl_rg_12_3_d1,
  output [63:0] cl_rg_12_3_q1,
  input cl_rg_12_3_ce1,
  input cl_rg_12_3_we1,

  input [11:0] cl_rg_13_0_addr0,
  input [63:0] cl_rg_13_0_d0,
  output [63:0] cl_rg_13_0_q0,
  input cl_rg_13_0_ce0,
  input cl_rg_13_0_we0,
  input [11:0] cl_rg_13_0_addr1,
  input [63:0] cl_rg_13_0_d1,
  output [63:0] cl_rg_13_0_q1,
  input cl_rg_13_0_ce1,
  input cl_rg_13_0_we1,

  input [11:0] cl_rg_13_1_addr0,
  input [63:0] cl_rg_13_1_d0,
  output [63:0] cl_rg_13_1_q0,
  input cl_rg_13_1_ce0,
  input cl_rg_13_1_we0,
  input [11:0] cl_rg_13_1_addr1,
  input [63:0] cl_rg_13_1_d1,
  output [63:0] cl_rg_13_1_q1,
  input cl_rg_13_1_ce1,
  input cl_rg_13_1_we1,

  input [11:0] cl_rg_13_2_addr0,
  input [63:0] cl_rg_13_2_d0,
  output [63:0] cl_rg_13_2_q0,
  input cl_rg_13_2_ce0,
  input cl_rg_13_2_we0,
  input [11:0] cl_rg_13_2_addr1,
  input [63:0] cl_rg_13_2_d1,
  output [63:0] cl_rg_13_2_q1,
  input cl_rg_13_2_ce1,
  input cl_rg_13_2_we1,

  input [11:0] cl_rg_13_3_addr0,
  input [63:0] cl_rg_13_3_d0,
  output [63:0] cl_rg_13_3_q0,
  input cl_rg_13_3_ce0,
  input cl_rg_13_3_we0,
  input [11:0] cl_rg_13_3_addr1,
  input [63:0] cl_rg_13_3_d1,
  output [63:0] cl_rg_13_3_q1,
  input cl_rg_13_3_ce1,
  input cl_rg_13_3_we1,

  input [11:0] cl_rg_14_0_addr0,
  input [63:0] cl_rg_14_0_d0,
  output [63:0] cl_rg_14_0_q0,
  input cl_rg_14_0_ce0,
  input cl_rg_14_0_we0,
  input [11:0] cl_rg_14_0_addr1,
  input [63:0] cl_rg_14_0_d1,
  output [63:0] cl_rg_14_0_q1,
  input cl_rg_14_0_ce1,
  input cl_rg_14_0_we1,

  input [11:0] cl_rg_14_1_addr0,
  input [63:0] cl_rg_14_1_d0,
  output [63:0] cl_rg_14_1_q0,
  input cl_rg_14_1_ce0,
  input cl_rg_14_1_we0,
  input [11:0] cl_rg_14_1_addr1,
  input [63:0] cl_rg_14_1_d1,
  output [63:0] cl_rg_14_1_q1,
  input cl_rg_14_1_ce1,
  input cl_rg_14_1_we1,

  input [11:0] cl_rg_14_2_addr0,
  input [63:0] cl_rg_14_2_d0,
  output [63:0] cl_rg_14_2_q0,
  input cl_rg_14_2_ce0,
  input cl_rg_14_2_we0,
  input [11:0] cl_rg_14_2_addr1,
  input [63:0] cl_rg_14_2_d1,
  output [63:0] cl_rg_14_2_q1,
  input cl_rg_14_2_ce1,
  input cl_rg_14_2_we1,

  input [11:0] cl_rg_14_3_addr0,
  input [63:0] cl_rg_14_3_d0,
  output [63:0] cl_rg_14_3_q0,
  input cl_rg_14_3_ce0,
  input cl_rg_14_3_we0,
  input [11:0] cl_rg_14_3_addr1,
  input [63:0] cl_rg_14_3_d1,
  output [63:0] cl_rg_14_3_q1,
  input cl_rg_14_3_ce1,
  input cl_rg_14_3_we1,

  input [11:0] cl_rg_15_0_addr0,
  input [63:0] cl_rg_15_0_d0,
  output [63:0] cl_rg_15_0_q0,
  input cl_rg_15_0_ce0,
  input cl_rg_15_0_we0,
  input [11:0] cl_rg_15_0_addr1,
  input [63:0] cl_rg_15_0_d1,
  output [63:0] cl_rg_15_0_q1,
  input cl_rg_15_0_ce1,
  input cl_rg_15_0_we1,

  input [11:0] cl_rg_15_1_addr0,
  input [63:0] cl_rg_15_1_d0,
  output [63:0] cl_rg_15_1_q0,
  input cl_rg_15_1_ce0,
  input cl_rg_15_1_we0,
  input [11:0] cl_rg_15_1_addr1,
  input [63:0] cl_rg_15_1_d1,
  output [63:0] cl_rg_15_1_q1,
  input cl_rg_15_1_ce1,
  input cl_rg_15_1_we1,

  input [11:0] cl_rg_15_2_addr0,
  input [63:0] cl_rg_15_2_d0,
  output [63:0] cl_rg_15_2_q0,
  input cl_rg_15_2_ce0,
  input cl_rg_15_2_we0,
  input [11:0] cl_rg_15_2_addr1,
  input [63:0] cl_rg_15_2_d1,
  output [63:0] cl_rg_15_2_q1,
  input cl_rg_15_2_ce1,
  input cl_rg_15_2_we1,

  input [11:0] cl_rg_15_3_addr0,
  input [63:0] cl_rg_15_3_d0,
  output [63:0] cl_rg_15_3_q0,
  input cl_rg_15_3_ce0,
  input cl_rg_15_3_we0,
  input [11:0] cl_rg_15_3_addr1,
  input [63:0] cl_rg_15_3_d1,
  output [63:0] cl_rg_15_3_q1,
  input cl_rg_15_3_ce1,
  input cl_rg_15_3_we1,

  input [11:0] cl_rg_16_0_addr0,
  input [63:0] cl_rg_16_0_d0,
  output [63:0] cl_rg_16_0_q0,
  input cl_rg_16_0_ce0,
  input cl_rg_16_0_we0,
  input [11:0] cl_rg_16_0_addr1,
  input [63:0] cl_rg_16_0_d1,
  output [63:0] cl_rg_16_0_q1,
  input cl_rg_16_0_ce1,
  input cl_rg_16_0_we1,

  input [11:0] cl_rg_16_1_addr0,
  input [63:0] cl_rg_16_1_d0,
  output [63:0] cl_rg_16_1_q0,
  input cl_rg_16_1_ce0,
  input cl_rg_16_1_we0,
  input [11:0] cl_rg_16_1_addr1,
  input [63:0] cl_rg_16_1_d1,
  output [63:0] cl_rg_16_1_q1,
  input cl_rg_16_1_ce1,
  input cl_rg_16_1_we1,

  input [11:0] cl_rg_16_2_addr0,
  input [63:0] cl_rg_16_2_d0,
  output [63:0] cl_rg_16_2_q0,
  input cl_rg_16_2_ce0,
  input cl_rg_16_2_we0,
  input [11:0] cl_rg_16_2_addr1,
  input [63:0] cl_rg_16_2_d1,
  output [63:0] cl_rg_16_2_q1,
  input cl_rg_16_2_ce1,
  input cl_rg_16_2_we1,

  input [11:0] cl_rg_16_3_addr0,
  input [63:0] cl_rg_16_3_d0,
  output [63:0] cl_rg_16_3_q0,
  input cl_rg_16_3_ce0,
  input cl_rg_16_3_we0,
  input [11:0] cl_rg_16_3_addr1,
  input [63:0] cl_rg_16_3_d1,
  output [63:0] cl_rg_16_3_q1,
  input cl_rg_16_3_ce1,
  input cl_rg_16_3_we1,

  input [11:0] cl_rg_17_0_addr0,
  input [63:0] cl_rg_17_0_d0,
  output [63:0] cl_rg_17_0_q0,
  input cl_rg_17_0_ce0,
  input cl_rg_17_0_we0,
  input [11:0] cl_rg_17_0_addr1,
  input [63:0] cl_rg_17_0_d1,
  output [63:0] cl_rg_17_0_q1,
  input cl_rg_17_0_ce1,
  input cl_rg_17_0_we1,

  input [11:0] cl_rg_17_1_addr0,
  input [63:0] cl_rg_17_1_d0,
  output [63:0] cl_rg_17_1_q0,
  input cl_rg_17_1_ce0,
  input cl_rg_17_1_we0,
  input [11:0] cl_rg_17_1_addr1,
  input [63:0] cl_rg_17_1_d1,
  output [63:0] cl_rg_17_1_q1,
  input cl_rg_17_1_ce1,
  input cl_rg_17_1_we1,

  input [11:0] cl_rg_17_2_addr0,
  input [63:0] cl_rg_17_2_d0,
  output [63:0] cl_rg_17_2_q0,
  input cl_rg_17_2_ce0,
  input cl_rg_17_2_we0,
  input [11:0] cl_rg_17_2_addr1,
  input [63:0] cl_rg_17_2_d1,
  output [63:0] cl_rg_17_2_q1,
  input cl_rg_17_2_ce1,
  input cl_rg_17_2_we1,

  input [11:0] cl_rg_17_3_addr0,
  input [63:0] cl_rg_17_3_d0,
  output [63:0] cl_rg_17_3_q0,
  input cl_rg_17_3_ce0,
  input cl_rg_17_3_we0,
  input [11:0] cl_rg_17_3_addr1,
  input [63:0] cl_rg_17_3_d1,
  output [63:0] cl_rg_17_3_q1,
  input cl_rg_17_3_ce1,
  input cl_rg_17_3_we1,

  input [11:0] cl_rg_18_0_addr0,
  input [63:0] cl_rg_18_0_d0,
  output [63:0] cl_rg_18_0_q0,
  input cl_rg_18_0_ce0,
  input cl_rg_18_0_we0,
  input [11:0] cl_rg_18_0_addr1,
  input [63:0] cl_rg_18_0_d1,
  output [63:0] cl_rg_18_0_q1,
  input cl_rg_18_0_ce1,
  input cl_rg_18_0_we1,

  input [11:0] cl_rg_18_1_addr0,
  input [63:0] cl_rg_18_1_d0,
  output [63:0] cl_rg_18_1_q0,
  input cl_rg_18_1_ce0,
  input cl_rg_18_1_we0,
  input [11:0] cl_rg_18_1_addr1,
  input [63:0] cl_rg_18_1_d1,
  output [63:0] cl_rg_18_1_q1,
  input cl_rg_18_1_ce1,
  input cl_rg_18_1_we1,

  input [11:0] cl_rg_18_2_addr0,
  input [63:0] cl_rg_18_2_d0,
  output [63:0] cl_rg_18_2_q0,
  input cl_rg_18_2_ce0,
  input cl_rg_18_2_we0,
  input [11:0] cl_rg_18_2_addr1,
  input [63:0] cl_rg_18_2_d1,
  output [63:0] cl_rg_18_2_q1,
  input cl_rg_18_2_ce1,
  input cl_rg_18_2_we1,

  input [11:0] cl_rg_18_3_addr0,
  input [63:0] cl_rg_18_3_d0,
  output [63:0] cl_rg_18_3_q0,
  input cl_rg_18_3_ce0,
  input cl_rg_18_3_we0,
  input [11:0] cl_rg_18_3_addr1,
  input [63:0] cl_rg_18_3_d1,
  output [63:0] cl_rg_18_3_q1,
  input cl_rg_18_3_ce1,
  input cl_rg_18_3_we1,

  input [11:0] cl_rg_19_0_addr0,
  input [63:0] cl_rg_19_0_d0,
  output [63:0] cl_rg_19_0_q0,
  input cl_rg_19_0_ce0,
  input cl_rg_19_0_we0,
  input [11:0] cl_rg_19_0_addr1,
  input [63:0] cl_rg_19_0_d1,
  output [63:0] cl_rg_19_0_q1,
  input cl_rg_19_0_ce1,
  input cl_rg_19_0_we1,

  input [11:0] cl_rg_19_1_addr0,
  input [63:0] cl_rg_19_1_d0,
  output [63:0] cl_rg_19_1_q0,
  input cl_rg_19_1_ce0,
  input cl_rg_19_1_we0,
  input [11:0] cl_rg_19_1_addr1,
  input [63:0] cl_rg_19_1_d1,
  output [63:0] cl_rg_19_1_q1,
  input cl_rg_19_1_ce1,
  input cl_rg_19_1_we1,

  input [11:0] cl_rg_19_2_addr0,
  input [63:0] cl_rg_19_2_d0,
  output [63:0] cl_rg_19_2_q0,
  input cl_rg_19_2_ce0,
  input cl_rg_19_2_we0,
  input [11:0] cl_rg_19_2_addr1,
  input [63:0] cl_rg_19_2_d1,
  output [63:0] cl_rg_19_2_q1,
  input cl_rg_19_2_ce1,
  input cl_rg_19_2_we1,

  input [11:0] cl_rg_19_3_addr0,
  input [63:0] cl_rg_19_3_d0,
  output [63:0] cl_rg_19_3_q0,
  input cl_rg_19_3_ce0,
  input cl_rg_19_3_we0,
  input [11:0] cl_rg_19_3_addr1,
  input [63:0] cl_rg_19_3_d1,
  output [63:0] cl_rg_19_3_q1,
  input cl_rg_19_3_ce1,
  input cl_rg_19_3_we1,

  input [11:0] cl_rg_20_0_addr0,
  input [63:0] cl_rg_20_0_d0,
  output [63:0] cl_rg_20_0_q0,
  input cl_rg_20_0_ce0,
  input cl_rg_20_0_we0,
  input [11:0] cl_rg_20_0_addr1,
  input [63:0] cl_rg_20_0_d1,
  output [63:0] cl_rg_20_0_q1,
  input cl_rg_20_0_ce1,
  input cl_rg_20_0_we1,

  input [11:0] cl_rg_20_1_addr0,
  input [63:0] cl_rg_20_1_d0,
  output [63:0] cl_rg_20_1_q0,
  input cl_rg_20_1_ce0,
  input cl_rg_20_1_we0,
  input [11:0] cl_rg_20_1_addr1,
  input [63:0] cl_rg_20_1_d1,
  output [63:0] cl_rg_20_1_q1,
  input cl_rg_20_1_ce1,
  input cl_rg_20_1_we1,

  input [11:0] cl_rg_20_2_addr0,
  input [63:0] cl_rg_20_2_d0,
  output [63:0] cl_rg_20_2_q0,
  input cl_rg_20_2_ce0,
  input cl_rg_20_2_we0,
  input [11:0] cl_rg_20_2_addr1,
  input [63:0] cl_rg_20_2_d1,
  output [63:0] cl_rg_20_2_q1,
  input cl_rg_20_2_ce1,
  input cl_rg_20_2_we1,

  input [11:0] cl_rg_20_3_addr0,
  input [63:0] cl_rg_20_3_d0,
  output [63:0] cl_rg_20_3_q0,
  input cl_rg_20_3_ce0,
  input cl_rg_20_3_we0,
  input [11:0] cl_rg_20_3_addr1,
  input [63:0] cl_rg_20_3_d1,
  output [63:0] cl_rg_20_3_q1,
  input cl_rg_20_3_ce1,
  input cl_rg_20_3_we1,

  input clk,
  input rst
);

  wire [9:0] rg_0_0_addr0;
  wire [63:0] rg_0_0_d0;
  wire [63:0] rg_0_0_q0;
  wire rg_0_0_ce0;
  wire rg_0_0_we0;
  wire [9:0] rg_0_0_addr1;
  wire [63:0] rg_0_0_d1;
  wire [63:0] rg_0_0_q1;
  wire rg_0_0_ce1;
  wire rg_0_0_we1;

  wire [9:0] rg_0_1_addr0;
  wire [63:0] rg_0_1_d0;
  wire [63:0] rg_0_1_q0;
  wire rg_0_1_ce0;
  wire rg_0_1_we0;
  wire [9:0] rg_0_1_addr1;
  wire [63:0] rg_0_1_d1;
  wire [63:0] rg_0_1_q1;
  wire rg_0_1_ce1;
  wire rg_0_1_we1;

  wire [9:0] rg_0_2_addr0;
  wire [63:0] rg_0_2_d0;
  wire [63:0] rg_0_2_q0;
  wire rg_0_2_ce0;
  wire rg_0_2_we0;
  wire [9:0] rg_0_2_addr1;
  wire [63:0] rg_0_2_d1;
  wire [63:0] rg_0_2_q1;
  wire rg_0_2_ce1;
  wire rg_0_2_we1;

  wire [9:0] rg_0_3_addr0;
  wire [63:0] rg_0_3_d0;
  wire [63:0] rg_0_3_q0;
  wire rg_0_3_ce0;
  wire rg_0_3_we0;
  wire [9:0] rg_0_3_addr1;
  wire [63:0] rg_0_3_d1;
  wire [63:0] rg_0_3_q1;
  wire rg_0_3_ce1;
  wire rg_0_3_we1;
  ram_group #(.AWIDTH(10), .DWIDTH(64)) rg_0 (
    .ram_0_addr0(rg_0_0_addr0),
    .ram_0_d0(rg_0_0_d0),
    .ram_0_q0(rg_0_0_q0),
    .ram_0_ce0(rg_0_0_ce0),
    .ram_0_we0(rg_0_0_we0),
    .ram_0_addr1(rg_0_0_addr1),
    .ram_0_d1(rg_0_0_d1),
    .ram_0_q1(rg_0_0_q1),
    .ram_0_ce1(rg_0_0_ce1),
    .ram_0_we1(rg_0_0_we1),

    .ram_1_addr0(rg_0_1_addr0),
    .ram_1_d0(rg_0_1_d0),
    .ram_1_q0(rg_0_1_q0),
    .ram_1_ce0(rg_0_1_ce0),
    .ram_1_we0(rg_0_1_we0),
    .ram_1_addr1(rg_0_1_addr1),
    .ram_1_d1(rg_0_1_d1),
    .ram_1_q1(rg_0_1_q1),
    .ram_1_ce1(rg_0_1_ce1),
    .ram_1_we1(rg_0_1_we1),

    .ram_2_addr0(rg_0_2_addr0),
    .ram_2_d0(rg_0_2_d0),
    .ram_2_q0(rg_0_2_q0),
    .ram_2_ce0(rg_0_2_ce0),
    .ram_2_we0(rg_0_2_we0),
    .ram_2_addr1(rg_0_2_addr1),
    .ram_2_d1(rg_0_2_d1),
    .ram_2_q1(rg_0_2_q1),
    .ram_2_ce1(rg_0_2_ce1),
    .ram_2_we1(rg_0_2_we1),

    .ram_3_addr0(rg_0_3_addr0),
    .ram_3_d0(rg_0_3_d0),
    .ram_3_q0(rg_0_3_q0),
    .ram_3_ce0(rg_0_3_ce0),
    .ram_3_we0(rg_0_3_we0),
    .ram_3_addr1(rg_0_3_addr1),
    .ram_3_d1(rg_0_3_d1),
    .ram_3_q1(rg_0_3_q1),
    .ram_3_ce1(rg_0_3_ce1),
    .ram_3_we1(rg_0_3_we1),

    .clk(clk),
    .rst(rst)
  );

  wire [9:0] rg_1_0_addr0;
  wire [63:0] rg_1_0_d0;
  wire [63:0] rg_1_0_q0;
  wire rg_1_0_ce0;
  wire rg_1_0_we0;
  wire [9:0] rg_1_0_addr1;
  wire [63:0] rg_1_0_d1;
  wire [63:0] rg_1_0_q1;
  wire rg_1_0_ce1;
  wire rg_1_0_we1;

  wire [9:0] rg_1_1_addr0;
  wire [63:0] rg_1_1_d0;
  wire [63:0] rg_1_1_q0;
  wire rg_1_1_ce0;
  wire rg_1_1_we0;
  wire [9:0] rg_1_1_addr1;
  wire [63:0] rg_1_1_d1;
  wire [63:0] rg_1_1_q1;
  wire rg_1_1_ce1;
  wire rg_1_1_we1;

  wire [9:0] rg_1_2_addr0;
  wire [63:0] rg_1_2_d0;
  wire [63:0] rg_1_2_q0;
  wire rg_1_2_ce0;
  wire rg_1_2_we0;
  wire [9:0] rg_1_2_addr1;
  wire [63:0] rg_1_2_d1;
  wire [63:0] rg_1_2_q1;
  wire rg_1_2_ce1;
  wire rg_1_2_we1;

  wire [9:0] rg_1_3_addr0;
  wire [63:0] rg_1_3_d0;
  wire [63:0] rg_1_3_q0;
  wire rg_1_3_ce0;
  wire rg_1_3_we0;
  wire [9:0] rg_1_3_addr1;
  wire [63:0] rg_1_3_d1;
  wire [63:0] rg_1_3_q1;
  wire rg_1_3_ce1;
  wire rg_1_3_we1;
  ram_group #(.AWIDTH(10), .DWIDTH(64)) rg_1 (
    .ram_0_addr0(rg_1_0_addr0),
    .ram_0_d0(rg_1_0_d0),
    .ram_0_q0(rg_1_0_q0),
    .ram_0_ce0(rg_1_0_ce0),
    .ram_0_we0(rg_1_0_we0),
    .ram_0_addr1(rg_1_0_addr1),
    .ram_0_d1(rg_1_0_d1),
    .ram_0_q1(rg_1_0_q1),
    .ram_0_ce1(rg_1_0_ce1),
    .ram_0_we1(rg_1_0_we1),

    .ram_1_addr0(rg_1_1_addr0),
    .ram_1_d0(rg_1_1_d0),
    .ram_1_q0(rg_1_1_q0),
    .ram_1_ce0(rg_1_1_ce0),
    .ram_1_we0(rg_1_1_we0),
    .ram_1_addr1(rg_1_1_addr1),
    .ram_1_d1(rg_1_1_d1),
    .ram_1_q1(rg_1_1_q1),
    .ram_1_ce1(rg_1_1_ce1),
    .ram_1_we1(rg_1_1_we1),

    .ram_2_addr0(rg_1_2_addr0),
    .ram_2_d0(rg_1_2_d0),
    .ram_2_q0(rg_1_2_q0),
    .ram_2_ce0(rg_1_2_ce0),
    .ram_2_we0(rg_1_2_we0),
    .ram_2_addr1(rg_1_2_addr1),
    .ram_2_d1(rg_1_2_d1),
    .ram_2_q1(rg_1_2_q1),
    .ram_2_ce1(rg_1_2_ce1),
    .ram_2_we1(rg_1_2_we1),

    .ram_3_addr0(rg_1_3_addr0),
    .ram_3_d0(rg_1_3_d0),
    .ram_3_q0(rg_1_3_q0),
    .ram_3_ce0(rg_1_3_ce0),
    .ram_3_we0(rg_1_3_we0),
    .ram_3_addr1(rg_1_3_addr1),
    .ram_3_d1(rg_1_3_d1),
    .ram_3_q1(rg_1_3_q1),
    .ram_3_ce1(rg_1_3_ce1),
    .ram_3_we1(rg_1_3_we1),

    .clk(clk),
    .rst(rst)
  );

  wire [9:0] rg_2_0_addr0;
  wire [63:0] rg_2_0_d0;
  wire [63:0] rg_2_0_q0;
  wire rg_2_0_ce0;
  wire rg_2_0_we0;
  wire [9:0] rg_2_0_addr1;
  wire [63:0] rg_2_0_d1;
  wire [63:0] rg_2_0_q1;
  wire rg_2_0_ce1;
  wire rg_2_0_we1;

  wire [9:0] rg_2_1_addr0;
  wire [63:0] rg_2_1_d0;
  wire [63:0] rg_2_1_q0;
  wire rg_2_1_ce0;
  wire rg_2_1_we0;
  wire [9:0] rg_2_1_addr1;
  wire [63:0] rg_2_1_d1;
  wire [63:0] rg_2_1_q1;
  wire rg_2_1_ce1;
  wire rg_2_1_we1;

  wire [9:0] rg_2_2_addr0;
  wire [63:0] rg_2_2_d0;
  wire [63:0] rg_2_2_q0;
  wire rg_2_2_ce0;
  wire rg_2_2_we0;
  wire [9:0] rg_2_2_addr1;
  wire [63:0] rg_2_2_d1;
  wire [63:0] rg_2_2_q1;
  wire rg_2_2_ce1;
  wire rg_2_2_we1;

  wire [9:0] rg_2_3_addr0;
  wire [63:0] rg_2_3_d0;
  wire [63:0] rg_2_3_q0;
  wire rg_2_3_ce0;
  wire rg_2_3_we0;
  wire [9:0] rg_2_3_addr1;
  wire [63:0] rg_2_3_d1;
  wire [63:0] rg_2_3_q1;
  wire rg_2_3_ce1;
  wire rg_2_3_we1;
  ram_group #(.AWIDTH(10), .DWIDTH(64)) rg_2 (
    .ram_0_addr0(rg_2_0_addr0),
    .ram_0_d0(rg_2_0_d0),
    .ram_0_q0(rg_2_0_q0),
    .ram_0_ce0(rg_2_0_ce0),
    .ram_0_we0(rg_2_0_we0),
    .ram_0_addr1(rg_2_0_addr1),
    .ram_0_d1(rg_2_0_d1),
    .ram_0_q1(rg_2_0_q1),
    .ram_0_ce1(rg_2_0_ce1),
    .ram_0_we1(rg_2_0_we1),

    .ram_1_addr0(rg_2_1_addr0),
    .ram_1_d0(rg_2_1_d0),
    .ram_1_q0(rg_2_1_q0),
    .ram_1_ce0(rg_2_1_ce0),
    .ram_1_we0(rg_2_1_we0),
    .ram_1_addr1(rg_2_1_addr1),
    .ram_1_d1(rg_2_1_d1),
    .ram_1_q1(rg_2_1_q1),
    .ram_1_ce1(rg_2_1_ce1),
    .ram_1_we1(rg_2_1_we1),

    .ram_2_addr0(rg_2_2_addr0),
    .ram_2_d0(rg_2_2_d0),
    .ram_2_q0(rg_2_2_q0),
    .ram_2_ce0(rg_2_2_ce0),
    .ram_2_we0(rg_2_2_we0),
    .ram_2_addr1(rg_2_2_addr1),
    .ram_2_d1(rg_2_2_d1),
    .ram_2_q1(rg_2_2_q1),
    .ram_2_ce1(rg_2_2_ce1),
    .ram_2_we1(rg_2_2_we1),

    .ram_3_addr0(rg_2_3_addr0),
    .ram_3_d0(rg_2_3_d0),
    .ram_3_q0(rg_2_3_q0),
    .ram_3_ce0(rg_2_3_ce0),
    .ram_3_we0(rg_2_3_we0),
    .ram_3_addr1(rg_2_3_addr1),
    .ram_3_d1(rg_2_3_d1),
    .ram_3_q1(rg_2_3_q1),
    .ram_3_ce1(rg_2_3_ce1),
    .ram_3_we1(rg_2_3_we1),

    .clk(clk),
    .rst(rst)
  );

  wire [9:0] rg_3_0_addr0;
  wire [63:0] rg_3_0_d0;
  wire [63:0] rg_3_0_q0;
  wire rg_3_0_ce0;
  wire rg_3_0_we0;
  wire [9:0] rg_3_0_addr1;
  wire [63:0] rg_3_0_d1;
  wire [63:0] rg_3_0_q1;
  wire rg_3_0_ce1;
  wire rg_3_0_we1;

  wire [9:0] rg_3_1_addr0;
  wire [63:0] rg_3_1_d0;
  wire [63:0] rg_3_1_q0;
  wire rg_3_1_ce0;
  wire rg_3_1_we0;
  wire [9:0] rg_3_1_addr1;
  wire [63:0] rg_3_1_d1;
  wire [63:0] rg_3_1_q1;
  wire rg_3_1_ce1;
  wire rg_3_1_we1;

  wire [9:0] rg_3_2_addr0;
  wire [63:0] rg_3_2_d0;
  wire [63:0] rg_3_2_q0;
  wire rg_3_2_ce0;
  wire rg_3_2_we0;
  wire [9:0] rg_3_2_addr1;
  wire [63:0] rg_3_2_d1;
  wire [63:0] rg_3_2_q1;
  wire rg_3_2_ce1;
  wire rg_3_2_we1;

  wire [9:0] rg_3_3_addr0;
  wire [63:0] rg_3_3_d0;
  wire [63:0] rg_3_3_q0;
  wire rg_3_3_ce0;
  wire rg_3_3_we0;
  wire [9:0] rg_3_3_addr1;
  wire [63:0] rg_3_3_d1;
  wire [63:0] rg_3_3_q1;
  wire rg_3_3_ce1;
  wire rg_3_3_we1;
  ram_group #(.AWIDTH(10), .DWIDTH(64)) rg_3 (
    .ram_0_addr0(rg_3_0_addr0),
    .ram_0_d0(rg_3_0_d0),
    .ram_0_q0(rg_3_0_q0),
    .ram_0_ce0(rg_3_0_ce0),
    .ram_0_we0(rg_3_0_we0),
    .ram_0_addr1(rg_3_0_addr1),
    .ram_0_d1(rg_3_0_d1),
    .ram_0_q1(rg_3_0_q1),
    .ram_0_ce1(rg_3_0_ce1),
    .ram_0_we1(rg_3_0_we1),

    .ram_1_addr0(rg_3_1_addr0),
    .ram_1_d0(rg_3_1_d0),
    .ram_1_q0(rg_3_1_q0),
    .ram_1_ce0(rg_3_1_ce0),
    .ram_1_we0(rg_3_1_we0),
    .ram_1_addr1(rg_3_1_addr1),
    .ram_1_d1(rg_3_1_d1),
    .ram_1_q1(rg_3_1_q1),
    .ram_1_ce1(rg_3_1_ce1),
    .ram_1_we1(rg_3_1_we1),

    .ram_2_addr0(rg_3_2_addr0),
    .ram_2_d0(rg_3_2_d0),
    .ram_2_q0(rg_3_2_q0),
    .ram_2_ce0(rg_3_2_ce0),
    .ram_2_we0(rg_3_2_we0),
    .ram_2_addr1(rg_3_2_addr1),
    .ram_2_d1(rg_3_2_d1),
    .ram_2_q1(rg_3_2_q1),
    .ram_2_ce1(rg_3_2_ce1),
    .ram_2_we1(rg_3_2_we1),

    .ram_3_addr0(rg_3_3_addr0),
    .ram_3_d0(rg_3_3_d0),
    .ram_3_q0(rg_3_3_q0),
    .ram_3_ce0(rg_3_3_ce0),
    .ram_3_we0(rg_3_3_we0),
    .ram_3_addr1(rg_3_3_addr1),
    .ram_3_d1(rg_3_3_d1),
    .ram_3_q1(rg_3_3_q1),
    .ram_3_ce1(rg_3_3_ce1),
    .ram_3_we1(rg_3_3_we1),

    .clk(clk),
    .rst(rst)
  );

  wire [9:0] rg_4_0_addr0;
  wire [63:0] rg_4_0_d0;
  wire [63:0] rg_4_0_q0;
  wire rg_4_0_ce0;
  wire rg_4_0_we0;
  wire [9:0] rg_4_0_addr1;
  wire [63:0] rg_4_0_d1;
  wire [63:0] rg_4_0_q1;
  wire rg_4_0_ce1;
  wire rg_4_0_we1;

  wire [9:0] rg_4_1_addr0;
  wire [63:0] rg_4_1_d0;
  wire [63:0] rg_4_1_q0;
  wire rg_4_1_ce0;
  wire rg_4_1_we0;
  wire [9:0] rg_4_1_addr1;
  wire [63:0] rg_4_1_d1;
  wire [63:0] rg_4_1_q1;
  wire rg_4_1_ce1;
  wire rg_4_1_we1;

  wire [9:0] rg_4_2_addr0;
  wire [63:0] rg_4_2_d0;
  wire [63:0] rg_4_2_q0;
  wire rg_4_2_ce0;
  wire rg_4_2_we0;
  wire [9:0] rg_4_2_addr1;
  wire [63:0] rg_4_2_d1;
  wire [63:0] rg_4_2_q1;
  wire rg_4_2_ce1;
  wire rg_4_2_we1;

  wire [9:0] rg_4_3_addr0;
  wire [63:0] rg_4_3_d0;
  wire [63:0] rg_4_3_q0;
  wire rg_4_3_ce0;
  wire rg_4_3_we0;
  wire [9:0] rg_4_3_addr1;
  wire [63:0] rg_4_3_d1;
  wire [63:0] rg_4_3_q1;
  wire rg_4_3_ce1;
  wire rg_4_3_we1;
  ram_group #(.AWIDTH(10), .DWIDTH(64)) rg_4 (
    .ram_0_addr0(rg_4_0_addr0),
    .ram_0_d0(rg_4_0_d0),
    .ram_0_q0(rg_4_0_q0),
    .ram_0_ce0(rg_4_0_ce0),
    .ram_0_we0(rg_4_0_we0),
    .ram_0_addr1(rg_4_0_addr1),
    .ram_0_d1(rg_4_0_d1),
    .ram_0_q1(rg_4_0_q1),
    .ram_0_ce1(rg_4_0_ce1),
    .ram_0_we1(rg_4_0_we1),

    .ram_1_addr0(rg_4_1_addr0),
    .ram_1_d0(rg_4_1_d0),
    .ram_1_q0(rg_4_1_q0),
    .ram_1_ce0(rg_4_1_ce0),
    .ram_1_we0(rg_4_1_we0),
    .ram_1_addr1(rg_4_1_addr1),
    .ram_1_d1(rg_4_1_d1),
    .ram_1_q1(rg_4_1_q1),
    .ram_1_ce1(rg_4_1_ce1),
    .ram_1_we1(rg_4_1_we1),

    .ram_2_addr0(rg_4_2_addr0),
    .ram_2_d0(rg_4_2_d0),
    .ram_2_q0(rg_4_2_q0),
    .ram_2_ce0(rg_4_2_ce0),
    .ram_2_we0(rg_4_2_we0),
    .ram_2_addr1(rg_4_2_addr1),
    .ram_2_d1(rg_4_2_d1),
    .ram_2_q1(rg_4_2_q1),
    .ram_2_ce1(rg_4_2_ce1),
    .ram_2_we1(rg_4_2_we1),

    .ram_3_addr0(rg_4_3_addr0),
    .ram_3_d0(rg_4_3_d0),
    .ram_3_q0(rg_4_3_q0),
    .ram_3_ce0(rg_4_3_ce0),
    .ram_3_we0(rg_4_3_we0),
    .ram_3_addr1(rg_4_3_addr1),
    .ram_3_d1(rg_4_3_d1),
    .ram_3_q1(rg_4_3_q1),
    .ram_3_ce1(rg_4_3_ce1),
    .ram_3_we1(rg_4_3_we1),

    .clk(clk),
    .rst(rst)
  );

  wire [9:0] rg_5_0_addr0;
  wire [63:0] rg_5_0_d0;
  wire [63:0] rg_5_0_q0;
  wire rg_5_0_ce0;
  wire rg_5_0_we0;
  wire [9:0] rg_5_0_addr1;
  wire [63:0] rg_5_0_d1;
  wire [63:0] rg_5_0_q1;
  wire rg_5_0_ce1;
  wire rg_5_0_we1;

  wire [9:0] rg_5_1_addr0;
  wire [63:0] rg_5_1_d0;
  wire [63:0] rg_5_1_q0;
  wire rg_5_1_ce0;
  wire rg_5_1_we0;
  wire [9:0] rg_5_1_addr1;
  wire [63:0] rg_5_1_d1;
  wire [63:0] rg_5_1_q1;
  wire rg_5_1_ce1;
  wire rg_5_1_we1;

  wire [9:0] rg_5_2_addr0;
  wire [63:0] rg_5_2_d0;
  wire [63:0] rg_5_2_q0;
  wire rg_5_2_ce0;
  wire rg_5_2_we0;
  wire [9:0] rg_5_2_addr1;
  wire [63:0] rg_5_2_d1;
  wire [63:0] rg_5_2_q1;
  wire rg_5_2_ce1;
  wire rg_5_2_we1;

  wire [9:0] rg_5_3_addr0;
  wire [63:0] rg_5_3_d0;
  wire [63:0] rg_5_3_q0;
  wire rg_5_3_ce0;
  wire rg_5_3_we0;
  wire [9:0] rg_5_3_addr1;
  wire [63:0] rg_5_3_d1;
  wire [63:0] rg_5_3_q1;
  wire rg_5_3_ce1;
  wire rg_5_3_we1;
  ram_group #(.AWIDTH(10), .DWIDTH(64)) rg_5 (
    .ram_0_addr0(rg_5_0_addr0),
    .ram_0_d0(rg_5_0_d0),
    .ram_0_q0(rg_5_0_q0),
    .ram_0_ce0(rg_5_0_ce0),
    .ram_0_we0(rg_5_0_we0),
    .ram_0_addr1(rg_5_0_addr1),
    .ram_0_d1(rg_5_0_d1),
    .ram_0_q1(rg_5_0_q1),
    .ram_0_ce1(rg_5_0_ce1),
    .ram_0_we1(rg_5_0_we1),

    .ram_1_addr0(rg_5_1_addr0),
    .ram_1_d0(rg_5_1_d0),
    .ram_1_q0(rg_5_1_q0),
    .ram_1_ce0(rg_5_1_ce0),
    .ram_1_we0(rg_5_1_we0),
    .ram_1_addr1(rg_5_1_addr1),
    .ram_1_d1(rg_5_1_d1),
    .ram_1_q1(rg_5_1_q1),
    .ram_1_ce1(rg_5_1_ce1),
    .ram_1_we1(rg_5_1_we1),

    .ram_2_addr0(rg_5_2_addr0),
    .ram_2_d0(rg_5_2_d0),
    .ram_2_q0(rg_5_2_q0),
    .ram_2_ce0(rg_5_2_ce0),
    .ram_2_we0(rg_5_2_we0),
    .ram_2_addr1(rg_5_2_addr1),
    .ram_2_d1(rg_5_2_d1),
    .ram_2_q1(rg_5_2_q1),
    .ram_2_ce1(rg_5_2_ce1),
    .ram_2_we1(rg_5_2_we1),

    .ram_3_addr0(rg_5_3_addr0),
    .ram_3_d0(rg_5_3_d0),
    .ram_3_q0(rg_5_3_q0),
    .ram_3_ce0(rg_5_3_ce0),
    .ram_3_we0(rg_5_3_we0),
    .ram_3_addr1(rg_5_3_addr1),
    .ram_3_d1(rg_5_3_d1),
    .ram_3_q1(rg_5_3_q1),
    .ram_3_ce1(rg_5_3_ce1),
    .ram_3_we1(rg_5_3_we1),

    .clk(clk),
    .rst(rst)
  );

  wire [11:0] rg_6_0_addr0;
  wire [63:0] rg_6_0_d0;
  wire [63:0] rg_6_0_q0;
  wire rg_6_0_ce0;
  wire rg_6_0_we0;
  wire [11:0] rg_6_0_addr1;
  wire [63:0] rg_6_0_d1;
  wire [63:0] rg_6_0_q1;
  wire rg_6_0_ce1;
  wire rg_6_0_we1;

  wire [11:0] rg_6_1_addr0;
  wire [63:0] rg_6_1_d0;
  wire [63:0] rg_6_1_q0;
  wire rg_6_1_ce0;
  wire rg_6_1_we0;
  wire [11:0] rg_6_1_addr1;
  wire [63:0] rg_6_1_d1;
  wire [63:0] rg_6_1_q1;
  wire rg_6_1_ce1;
  wire rg_6_1_we1;

  wire [11:0] rg_6_2_addr0;
  wire [63:0] rg_6_2_d0;
  wire [63:0] rg_6_2_q0;
  wire rg_6_2_ce0;
  wire rg_6_2_we0;
  wire [11:0] rg_6_2_addr1;
  wire [63:0] rg_6_2_d1;
  wire [63:0] rg_6_2_q1;
  wire rg_6_2_ce1;
  wire rg_6_2_we1;

  wire [11:0] rg_6_3_addr0;
  wire [63:0] rg_6_3_d0;
  wire [63:0] rg_6_3_q0;
  wire rg_6_3_ce0;
  wire rg_6_3_we0;
  wire [11:0] rg_6_3_addr1;
  wire [63:0] rg_6_3_d1;
  wire [63:0] rg_6_3_q1;
  wire rg_6_3_ce1;
  wire rg_6_3_we1;
  ram_group_uram #(.AWIDTH(12), .DWIDTH(64)) rg_6 (
    .ram_0_addr0(rg_6_0_addr0),
    .ram_0_d0(rg_6_0_d0),
    .ram_0_q0(rg_6_0_q0),
    .ram_0_ce0(rg_6_0_ce0),
    .ram_0_we0(rg_6_0_we0),
    .ram_0_addr1(rg_6_0_addr1),
    .ram_0_d1(rg_6_0_d1),
    .ram_0_q1(rg_6_0_q1),
    .ram_0_ce1(rg_6_0_ce1),
    .ram_0_we1(rg_6_0_we1),

    .ram_1_addr0(rg_6_1_addr0),
    .ram_1_d0(rg_6_1_d0),
    .ram_1_q0(rg_6_1_q0),
    .ram_1_ce0(rg_6_1_ce0),
    .ram_1_we0(rg_6_1_we0),
    .ram_1_addr1(rg_6_1_addr1),
    .ram_1_d1(rg_6_1_d1),
    .ram_1_q1(rg_6_1_q1),
    .ram_1_ce1(rg_6_1_ce1),
    .ram_1_we1(rg_6_1_we1),

    .ram_2_addr0(rg_6_2_addr0),
    .ram_2_d0(rg_6_2_d0),
    .ram_2_q0(rg_6_2_q0),
    .ram_2_ce0(rg_6_2_ce0),
    .ram_2_we0(rg_6_2_we0),
    .ram_2_addr1(rg_6_2_addr1),
    .ram_2_d1(rg_6_2_d1),
    .ram_2_q1(rg_6_2_q1),
    .ram_2_ce1(rg_6_2_ce1),
    .ram_2_we1(rg_6_2_we1),

    .ram_3_addr0(rg_6_3_addr0),
    .ram_3_d0(rg_6_3_d0),
    .ram_3_q0(rg_6_3_q0),
    .ram_3_ce0(rg_6_3_ce0),
    .ram_3_we0(rg_6_3_we0),
    .ram_3_addr1(rg_6_3_addr1),
    .ram_3_d1(rg_6_3_d1),
    .ram_3_q1(rg_6_3_q1),
    .ram_3_ce1(rg_6_3_ce1),
    .ram_3_we1(rg_6_3_we1),

    .clk(clk),
    .rst(rst)
  );

  wire [11:0] rg_7_0_addr0;
  wire [63:0] rg_7_0_d0;
  wire [63:0] rg_7_0_q0;
  wire rg_7_0_ce0;
  wire rg_7_0_we0;
  wire [11:0] rg_7_0_addr1;
  wire [63:0] rg_7_0_d1;
  wire [63:0] rg_7_0_q1;
  wire rg_7_0_ce1;
  wire rg_7_0_we1;

  wire [11:0] rg_7_1_addr0;
  wire [63:0] rg_7_1_d0;
  wire [63:0] rg_7_1_q0;
  wire rg_7_1_ce0;
  wire rg_7_1_we0;
  wire [11:0] rg_7_1_addr1;
  wire [63:0] rg_7_1_d1;
  wire [63:0] rg_7_1_q1;
  wire rg_7_1_ce1;
  wire rg_7_1_we1;

  wire [11:0] rg_7_2_addr0;
  wire [63:0] rg_7_2_d0;
  wire [63:0] rg_7_2_q0;
  wire rg_7_2_ce0;
  wire rg_7_2_we0;
  wire [11:0] rg_7_2_addr1;
  wire [63:0] rg_7_2_d1;
  wire [63:0] rg_7_2_q1;
  wire rg_7_2_ce1;
  wire rg_7_2_we1;

  wire [11:0] rg_7_3_addr0;
  wire [63:0] rg_7_3_d0;
  wire [63:0] rg_7_3_q0;
  wire rg_7_3_ce0;
  wire rg_7_3_we0;
  wire [11:0] rg_7_3_addr1;
  wire [63:0] rg_7_3_d1;
  wire [63:0] rg_7_3_q1;
  wire rg_7_3_ce1;
  wire rg_7_3_we1;
  ram_group_uram #(.AWIDTH(12), .DWIDTH(64)) rg_7 (
    .ram_0_addr0(rg_7_0_addr0),
    .ram_0_d0(rg_7_0_d0),
    .ram_0_q0(rg_7_0_q0),
    .ram_0_ce0(rg_7_0_ce0),
    .ram_0_we0(rg_7_0_we0),
    .ram_0_addr1(rg_7_0_addr1),
    .ram_0_d1(rg_7_0_d1),
    .ram_0_q1(rg_7_0_q1),
    .ram_0_ce1(rg_7_0_ce1),
    .ram_0_we1(rg_7_0_we1),

    .ram_1_addr0(rg_7_1_addr0),
    .ram_1_d0(rg_7_1_d0),
    .ram_1_q0(rg_7_1_q0),
    .ram_1_ce0(rg_7_1_ce0),
    .ram_1_we0(rg_7_1_we0),
    .ram_1_addr1(rg_7_1_addr1),
    .ram_1_d1(rg_7_1_d1),
    .ram_1_q1(rg_7_1_q1),
    .ram_1_ce1(rg_7_1_ce1),
    .ram_1_we1(rg_7_1_we1),

    .ram_2_addr0(rg_7_2_addr0),
    .ram_2_d0(rg_7_2_d0),
    .ram_2_q0(rg_7_2_q0),
    .ram_2_ce0(rg_7_2_ce0),
    .ram_2_we0(rg_7_2_we0),
    .ram_2_addr1(rg_7_2_addr1),
    .ram_2_d1(rg_7_2_d1),
    .ram_2_q1(rg_7_2_q1),
    .ram_2_ce1(rg_7_2_ce1),
    .ram_2_we1(rg_7_2_we1),

    .ram_3_addr0(rg_7_3_addr0),
    .ram_3_d0(rg_7_3_d0),
    .ram_3_q0(rg_7_3_q0),
    .ram_3_ce0(rg_7_3_ce0),
    .ram_3_we0(rg_7_3_we0),
    .ram_3_addr1(rg_7_3_addr1),
    .ram_3_d1(rg_7_3_d1),
    .ram_3_q1(rg_7_3_q1),
    .ram_3_ce1(rg_7_3_ce1),
    .ram_3_we1(rg_7_3_we1),

    .clk(clk),
    .rst(rst)
  );

  wire [11:0] rg_8_0_addr0;
  wire [63:0] rg_8_0_d0;
  wire [63:0] rg_8_0_q0;
  wire rg_8_0_ce0;
  wire rg_8_0_we0;
  wire [11:0] rg_8_0_addr1;
  wire [63:0] rg_8_0_d1;
  wire [63:0] rg_8_0_q1;
  wire rg_8_0_ce1;
  wire rg_8_0_we1;

  wire [11:0] rg_8_1_addr0;
  wire [63:0] rg_8_1_d0;
  wire [63:0] rg_8_1_q0;
  wire rg_8_1_ce0;
  wire rg_8_1_we0;
  wire [11:0] rg_8_1_addr1;
  wire [63:0] rg_8_1_d1;
  wire [63:0] rg_8_1_q1;
  wire rg_8_1_ce1;
  wire rg_8_1_we1;

  wire [11:0] rg_8_2_addr0;
  wire [63:0] rg_8_2_d0;
  wire [63:0] rg_8_2_q0;
  wire rg_8_2_ce0;
  wire rg_8_2_we0;
  wire [11:0] rg_8_2_addr1;
  wire [63:0] rg_8_2_d1;
  wire [63:0] rg_8_2_q1;
  wire rg_8_2_ce1;
  wire rg_8_2_we1;

  wire [11:0] rg_8_3_addr0;
  wire [63:0] rg_8_3_d0;
  wire [63:0] rg_8_3_q0;
  wire rg_8_3_ce0;
  wire rg_8_3_we0;
  wire [11:0] rg_8_3_addr1;
  wire [63:0] rg_8_3_d1;
  wire [63:0] rg_8_3_q1;
  wire rg_8_3_ce1;
  wire rg_8_3_we1;
  ram_group_uram #(.AWIDTH(12), .DWIDTH(64)) rg_8 (
    .ram_0_addr0(rg_8_0_addr0),
    .ram_0_d0(rg_8_0_d0),
    .ram_0_q0(rg_8_0_q0),
    .ram_0_ce0(rg_8_0_ce0),
    .ram_0_we0(rg_8_0_we0),
    .ram_0_addr1(rg_8_0_addr1),
    .ram_0_d1(rg_8_0_d1),
    .ram_0_q1(rg_8_0_q1),
    .ram_0_ce1(rg_8_0_ce1),
    .ram_0_we1(rg_8_0_we1),

    .ram_1_addr0(rg_8_1_addr0),
    .ram_1_d0(rg_8_1_d0),
    .ram_1_q0(rg_8_1_q0),
    .ram_1_ce0(rg_8_1_ce0),
    .ram_1_we0(rg_8_1_we0),
    .ram_1_addr1(rg_8_1_addr1),
    .ram_1_d1(rg_8_1_d1),
    .ram_1_q1(rg_8_1_q1),
    .ram_1_ce1(rg_8_1_ce1),
    .ram_1_we1(rg_8_1_we1),

    .ram_2_addr0(rg_8_2_addr0),
    .ram_2_d0(rg_8_2_d0),
    .ram_2_q0(rg_8_2_q0),
    .ram_2_ce0(rg_8_2_ce0),
    .ram_2_we0(rg_8_2_we0),
    .ram_2_addr1(rg_8_2_addr1),
    .ram_2_d1(rg_8_2_d1),
    .ram_2_q1(rg_8_2_q1),
    .ram_2_ce1(rg_8_2_ce1),
    .ram_2_we1(rg_8_2_we1),

    .ram_3_addr0(rg_8_3_addr0),
    .ram_3_d0(rg_8_3_d0),
    .ram_3_q0(rg_8_3_q0),
    .ram_3_ce0(rg_8_3_ce0),
    .ram_3_we0(rg_8_3_we0),
    .ram_3_addr1(rg_8_3_addr1),
    .ram_3_d1(rg_8_3_d1),
    .ram_3_q1(rg_8_3_q1),
    .ram_3_ce1(rg_8_3_ce1),
    .ram_3_we1(rg_8_3_we1),

    .clk(clk),
    .rst(rst)
  );

  wire [11:0] rg_9_0_addr0;
  wire [63:0] rg_9_0_d0;
  wire [63:0] rg_9_0_q0;
  wire rg_9_0_ce0;
  wire rg_9_0_we0;
  wire [11:0] rg_9_0_addr1;
  wire [63:0] rg_9_0_d1;
  wire [63:0] rg_9_0_q1;
  wire rg_9_0_ce1;
  wire rg_9_0_we1;

  wire [11:0] rg_9_1_addr0;
  wire [63:0] rg_9_1_d0;
  wire [63:0] rg_9_1_q0;
  wire rg_9_1_ce0;
  wire rg_9_1_we0;
  wire [11:0] rg_9_1_addr1;
  wire [63:0] rg_9_1_d1;
  wire [63:0] rg_9_1_q1;
  wire rg_9_1_ce1;
  wire rg_9_1_we1;

  wire [11:0] rg_9_2_addr0;
  wire [63:0] rg_9_2_d0;
  wire [63:0] rg_9_2_q0;
  wire rg_9_2_ce0;
  wire rg_9_2_we0;
  wire [11:0] rg_9_2_addr1;
  wire [63:0] rg_9_2_d1;
  wire [63:0] rg_9_2_q1;
  wire rg_9_2_ce1;
  wire rg_9_2_we1;

  wire [11:0] rg_9_3_addr0;
  wire [63:0] rg_9_3_d0;
  wire [63:0] rg_9_3_q0;
  wire rg_9_3_ce0;
  wire rg_9_3_we0;
  wire [11:0] rg_9_3_addr1;
  wire [63:0] rg_9_3_d1;
  wire [63:0] rg_9_3_q1;
  wire rg_9_3_ce1;
  wire rg_9_3_we1;
  ram_group_uram #(.AWIDTH(12), .DWIDTH(64)) rg_9 (
    .ram_0_addr0(rg_9_0_addr0),
    .ram_0_d0(rg_9_0_d0),
    .ram_0_q0(rg_9_0_q0),
    .ram_0_ce0(rg_9_0_ce0),
    .ram_0_we0(rg_9_0_we0),
    .ram_0_addr1(rg_9_0_addr1),
    .ram_0_d1(rg_9_0_d1),
    .ram_0_q1(rg_9_0_q1),
    .ram_0_ce1(rg_9_0_ce1),
    .ram_0_we1(rg_9_0_we1),

    .ram_1_addr0(rg_9_1_addr0),
    .ram_1_d0(rg_9_1_d0),
    .ram_1_q0(rg_9_1_q0),
    .ram_1_ce0(rg_9_1_ce0),
    .ram_1_we0(rg_9_1_we0),
    .ram_1_addr1(rg_9_1_addr1),
    .ram_1_d1(rg_9_1_d1),
    .ram_1_q1(rg_9_1_q1),
    .ram_1_ce1(rg_9_1_ce1),
    .ram_1_we1(rg_9_1_we1),

    .ram_2_addr0(rg_9_2_addr0),
    .ram_2_d0(rg_9_2_d0),
    .ram_2_q0(rg_9_2_q0),
    .ram_2_ce0(rg_9_2_ce0),
    .ram_2_we0(rg_9_2_we0),
    .ram_2_addr1(rg_9_2_addr1),
    .ram_2_d1(rg_9_2_d1),
    .ram_2_q1(rg_9_2_q1),
    .ram_2_ce1(rg_9_2_ce1),
    .ram_2_we1(rg_9_2_we1),

    .ram_3_addr0(rg_9_3_addr0),
    .ram_3_d0(rg_9_3_d0),
    .ram_3_q0(rg_9_3_q0),
    .ram_3_ce0(rg_9_3_ce0),
    .ram_3_we0(rg_9_3_we0),
    .ram_3_addr1(rg_9_3_addr1),
    .ram_3_d1(rg_9_3_d1),
    .ram_3_q1(rg_9_3_q1),
    .ram_3_ce1(rg_9_3_ce1),
    .ram_3_we1(rg_9_3_we1),

    .clk(clk),
    .rst(rst)
  );
  assign rg_0_0_addr1 = cl_rg_0_0_ce1 ? cl_rg_0_0_addr1 : 1'b1 ? lsu0_port0_addr : 0;
  assign rg_0_1_addr1 = cl_rg_0_1_ce1 ? cl_rg_0_1_addr1 : 1'b1 ? lsu0_port1_addr : 0;
  assign rg_0_2_addr1 = cl_rg_0_2_ce1 ? cl_rg_0_2_addr1 : 1'b1 ? lsu0_port2_addr : 0;
  assign rg_0_3_addr1 = cl_rg_0_3_ce1 ? cl_rg_0_3_addr1 : 1'b1 ? lsu0_port3_addr : 0;
  assign rg_1_0_addr1 = cl_rg_1_0_ce1 ? cl_rg_1_0_addr1 : 1'b1 ? lsu0_port0_addr : 0;
  assign rg_1_1_addr1 = cl_rg_1_1_ce1 ? cl_rg_1_1_addr1 : 1'b1 ? lsu0_port1_addr : 0;
  assign rg_1_2_addr1 = cl_rg_1_2_ce1 ? cl_rg_1_2_addr1 : 1'b1 ? lsu0_port2_addr : 0;
  assign rg_1_3_addr1 = cl_rg_1_3_ce1 ? cl_rg_1_3_addr1 : 1'b1 ? lsu0_port3_addr : 0;
  assign rg_2_0_addr1 = cl_rg_2_0_ce1 ? cl_rg_2_0_addr1 : 1'b1 ? lsu0_port0_addr : 0;
  assign rg_2_1_addr1 = cl_rg_2_1_ce1 ? cl_rg_2_1_addr1 : 1'b1 ? lsu0_port1_addr : 0;
  assign rg_2_2_addr1 = cl_rg_2_2_ce1 ? cl_rg_2_2_addr1 : 1'b1 ? lsu0_port2_addr : 0;
  assign rg_2_3_addr1 = cl_rg_2_3_ce1 ? cl_rg_2_3_addr1 : 1'b1 ? lsu0_port3_addr : 0;
  assign rg_3_0_addr1 = cl_rg_3_0_ce1 ? cl_rg_3_0_addr1 : 1'b1 ? lsu1_port0_addr : 0;
  assign rg_3_1_addr1 = cl_rg_3_1_ce1 ? cl_rg_3_1_addr1 : 1'b1 ? lsu1_port1_addr : 0;
  assign rg_3_2_addr1 = cl_rg_3_2_ce1 ? cl_rg_3_2_addr1 : 1'b1 ? lsu1_port2_addr : 0;
  assign rg_3_3_addr1 = cl_rg_3_3_ce1 ? cl_rg_3_3_addr1 : 1'b1 ? lsu1_port3_addr : 0;
  assign rg_4_0_addr1 = cl_rg_4_0_ce1 ? cl_rg_4_0_addr1 : 1'b1 ? lsu1_port0_addr : 0;
  assign rg_4_1_addr1 = cl_rg_4_1_ce1 ? cl_rg_4_1_addr1 : 1'b1 ? lsu1_port1_addr : 0;
  assign rg_4_2_addr1 = cl_rg_4_2_ce1 ? cl_rg_4_2_addr1 : 1'b1 ? lsu1_port2_addr : 0;
  assign rg_4_3_addr1 = cl_rg_4_3_ce1 ? cl_rg_4_3_addr1 : 1'b1 ? lsu1_port3_addr : 0;
  assign rg_5_0_addr1 = cl_rg_5_0_ce1 ? cl_rg_5_0_addr1 : 1'b1 ? lsu0_port0_addr : 0;
  assign rg_5_1_addr1 = cl_rg_5_1_ce1 ? cl_rg_5_1_addr1 : 1'b1 ? lsu0_port1_addr : 0;
  assign rg_5_2_addr1 = cl_rg_5_2_ce1 ? cl_rg_5_2_addr1 : 1'b1 ? lsu0_port2_addr : 0;
  assign rg_5_3_addr1 = cl_rg_5_3_ce1 ? cl_rg_5_3_addr1 : 1'b1 ? lsu0_port3_addr : 0;
  assign rg_6_0_addr1 = cl_rg_6_0_ce1 ? cl_rg_6_0_addr1 : 1'b1 ? lsu0_port0_addr : 0;
  assign rg_6_1_addr1 = cl_rg_6_1_ce1 ? cl_rg_6_1_addr1 : 1'b1 ? lsu0_port1_addr : 0;
  assign rg_6_2_addr1 = cl_rg_6_2_ce1 ? cl_rg_6_2_addr1 : 1'b1 ? lsu0_port2_addr : 0;
  assign rg_6_3_addr1 = cl_rg_6_3_ce1 ? cl_rg_6_3_addr1 : 1'b1 ? lsu0_port3_addr : 0;
  assign rg_7_0_addr1 = cl_rg_7_0_ce1 ? cl_rg_7_0_addr1 : 1'b1 ? lsu1_port0_addr : 0;
  assign rg_7_1_addr1 = cl_rg_7_1_ce1 ? cl_rg_7_1_addr1 : 1'b1 ? lsu1_port1_addr : 0;
  assign rg_7_2_addr1 = cl_rg_7_2_ce1 ? cl_rg_7_2_addr1 : 1'b1 ? lsu1_port2_addr : 0;
  assign rg_7_3_addr1 = cl_rg_7_3_ce1 ? cl_rg_7_3_addr1 : 1'b1 ? lsu1_port3_addr : 0;
  assign rg_8_0_addr1 = cl_rg_8_0_ce1 ? cl_rg_8_0_addr1 : 1'b1 ? lsu0_port0_addr : 0;
  assign rg_8_1_addr1 = cl_rg_8_1_ce1 ? cl_rg_8_1_addr1 : 1'b1 ? lsu0_port1_addr : 0;
  assign rg_8_2_addr1 = cl_rg_8_2_ce1 ? cl_rg_8_2_addr1 : 1'b1 ? lsu0_port2_addr : 0;
  assign rg_8_3_addr1 = cl_rg_8_3_ce1 ? cl_rg_8_3_addr1 : 1'b1 ? lsu0_port3_addr : 0;
  assign rg_9_0_addr1 = cl_rg_9_0_ce1 ? cl_rg_9_0_addr1 : 1'b1 ? lsu1_port0_addr : 0;
  assign rg_9_1_addr1 = cl_rg_9_1_ce1 ? cl_rg_9_1_addr1 : 1'b1 ? lsu1_port1_addr : 0;
  assign rg_9_2_addr1 = cl_rg_9_2_ce1 ? cl_rg_9_2_addr1 : 1'b1 ? lsu1_port2_addr : 0;
  assign rg_9_3_addr1 = cl_rg_9_3_ce1 ? cl_rg_9_3_addr1 : 1'b1 ? lsu1_port3_addr : 0;
  assign rg_0_0_d1 = cl_rg_0_0_ce1 ? cl_rg_0_0_d1 : 1'b1 ? lsu0_port0_d : 0;
  assign rg_0_1_d1 = cl_rg_0_1_ce1 ? cl_rg_0_1_d1 : 1'b1 ? lsu0_port1_d : 0;
  assign rg_0_2_d1 = cl_rg_0_2_ce1 ? cl_rg_0_2_d1 : 1'b1 ? lsu0_port2_d : 0;
  assign rg_0_3_d1 = cl_rg_0_3_ce1 ? cl_rg_0_3_d1 : 1'b1 ? lsu0_port3_d : 0;
  assign rg_1_0_d1 = cl_rg_1_0_ce1 ? cl_rg_1_0_d1 : 1'b1 ? lsu0_port0_d : 0;
  assign rg_1_1_d1 = cl_rg_1_1_ce1 ? cl_rg_1_1_d1 : 1'b1 ? lsu0_port1_d : 0;
  assign rg_1_2_d1 = cl_rg_1_2_ce1 ? cl_rg_1_2_d1 : 1'b1 ? lsu0_port2_d : 0;
  assign rg_1_3_d1 = cl_rg_1_3_ce1 ? cl_rg_1_3_d1 : 1'b1 ? lsu0_port3_d : 0;
  assign rg_2_0_d1 = cl_rg_2_0_ce1 ? cl_rg_2_0_d1 : 1'b1 ? lsu0_port0_d : 0;
  assign rg_2_1_d1 = cl_rg_2_1_ce1 ? cl_rg_2_1_d1 : 1'b1 ? lsu0_port1_d : 0;
  assign rg_2_2_d1 = cl_rg_2_2_ce1 ? cl_rg_2_2_d1 : 1'b1 ? lsu0_port2_d : 0;
  assign rg_2_3_d1 = cl_rg_2_3_ce1 ? cl_rg_2_3_d1 : 1'b1 ? lsu0_port3_d : 0;
  assign rg_3_0_d1 = cl_rg_3_0_ce1 ? cl_rg_3_0_d1 : 1'b1 ? lsu1_port0_d : 0;
  assign rg_3_1_d1 = cl_rg_3_1_ce1 ? cl_rg_3_1_d1 : 1'b1 ? lsu1_port1_d : 0;
  assign rg_3_2_d1 = cl_rg_3_2_ce1 ? cl_rg_3_2_d1 : 1'b1 ? lsu1_port2_d : 0;
  assign rg_3_3_d1 = cl_rg_3_3_ce1 ? cl_rg_3_3_d1 : 1'b1 ? lsu1_port3_d : 0;
  assign rg_4_0_d1 = cl_rg_4_0_ce1 ? cl_rg_4_0_d1 : 1'b1 ? lsu1_port0_d : 0;
  assign rg_4_1_d1 = cl_rg_4_1_ce1 ? cl_rg_4_1_d1 : 1'b1 ? lsu1_port1_d : 0;
  assign rg_4_2_d1 = cl_rg_4_2_ce1 ? cl_rg_4_2_d1 : 1'b1 ? lsu1_port2_d : 0;
  assign rg_4_3_d1 = cl_rg_4_3_ce1 ? cl_rg_4_3_d1 : 1'b1 ? lsu1_port3_d : 0;
  assign rg_5_0_d1 = cl_rg_5_0_ce1 ? cl_rg_5_0_d1 : 1'b1 ? lsu0_port0_d : 0;
  assign rg_5_1_d1 = cl_rg_5_1_ce1 ? cl_rg_5_1_d1 : 1'b1 ? lsu0_port1_d : 0;
  assign rg_5_2_d1 = cl_rg_5_2_ce1 ? cl_rg_5_2_d1 : 1'b1 ? lsu0_port2_d : 0;
  assign rg_5_3_d1 = cl_rg_5_3_ce1 ? cl_rg_5_3_d1 : 1'b1 ? lsu0_port3_d : 0;
  assign rg_6_0_d1 = cl_rg_6_0_ce1 ? cl_rg_6_0_d1 : 1'b1 ? lsu0_port0_d : 0;
  assign rg_6_1_d1 = cl_rg_6_1_ce1 ? cl_rg_6_1_d1 : 1'b1 ? lsu0_port1_d : 0;
  assign rg_6_2_d1 = cl_rg_6_2_ce1 ? cl_rg_6_2_d1 : 1'b1 ? lsu0_port2_d : 0;
  assign rg_6_3_d1 = cl_rg_6_3_ce1 ? cl_rg_6_3_d1 : 1'b1 ? lsu0_port3_d : 0;
  assign rg_7_0_d1 = cl_rg_7_0_ce1 ? cl_rg_7_0_d1 : 1'b1 ? lsu1_port0_d : 0;
  assign rg_7_1_d1 = cl_rg_7_1_ce1 ? cl_rg_7_1_d1 : 1'b1 ? lsu1_port1_d : 0;
  assign rg_7_2_d1 = cl_rg_7_2_ce1 ? cl_rg_7_2_d1 : 1'b1 ? lsu1_port2_d : 0;
  assign rg_7_3_d1 = cl_rg_7_3_ce1 ? cl_rg_7_3_d1 : 1'b1 ? lsu1_port3_d : 0;
  assign rg_8_0_d1 = cl_rg_8_0_ce1 ? cl_rg_8_0_d1 : 1'b1 ? lsu0_port0_d : 0;
  assign rg_8_1_d1 = cl_rg_8_1_ce1 ? cl_rg_8_1_d1 : 1'b1 ? lsu0_port1_d : 0;
  assign rg_8_2_d1 = cl_rg_8_2_ce1 ? cl_rg_8_2_d1 : 1'b1 ? lsu0_port2_d : 0;
  assign rg_8_3_d1 = cl_rg_8_3_ce1 ? cl_rg_8_3_d1 : 1'b1 ? lsu0_port3_d : 0;
  assign rg_9_0_d1 = cl_rg_9_0_ce1 ? cl_rg_9_0_d1 : 1'b1 ? lsu1_port0_d : 0;
  assign rg_9_1_d1 = cl_rg_9_1_ce1 ? cl_rg_9_1_d1 : 1'b1 ? lsu1_port1_d : 0;
  assign rg_9_2_d1 = cl_rg_9_2_ce1 ? cl_rg_9_2_d1 : 1'b1 ? lsu1_port2_d : 0;
  assign rg_9_3_d1 = cl_rg_9_3_ce1 ? cl_rg_9_3_d1 : 1'b1 ? lsu1_port3_d : 0;
  assign rg_0_0_ce1 = cl_rg_0_0_ce1 | ((lsu0_ram_en[4:0] == 0) & lsu0_port0_ce) | 0;
  assign rg_0_1_ce1 = cl_rg_0_1_ce1 | ((lsu0_ram_en[4:0] == 0) & lsu0_port1_ce) | 0;
  assign rg_0_2_ce1 = cl_rg_0_2_ce1 | ((lsu0_ram_en[4:0] == 0) & lsu0_port2_ce) | 0;
  assign rg_0_3_ce1 = cl_rg_0_3_ce1 | ((lsu0_ram_en[4:0] == 0) & lsu0_port3_ce) | 0;
  assign rg_1_0_ce1 = cl_rg_1_0_ce1 | ((lsu0_ram_en[4:0] == 1) & lsu0_port0_ce) | 0;
  assign rg_1_1_ce1 = cl_rg_1_1_ce1 | ((lsu0_ram_en[4:0] == 1) & lsu0_port1_ce) | 0;
  assign rg_1_2_ce1 = cl_rg_1_2_ce1 | ((lsu0_ram_en[4:0] == 1) & lsu0_port2_ce) | 0;
  assign rg_1_3_ce1 = cl_rg_1_3_ce1 | ((lsu0_ram_en[4:0] == 1) & lsu0_port3_ce) | 0;
  assign rg_2_0_ce1 = cl_rg_2_0_ce1 | ((lsu0_ram_en[4:0] == 2) & lsu0_port0_ce) | 0;
  assign rg_2_1_ce1 = cl_rg_2_1_ce1 | ((lsu0_ram_en[4:0] == 2) & lsu0_port1_ce) | 0;
  assign rg_2_2_ce1 = cl_rg_2_2_ce1 | ((lsu0_ram_en[4:0] == 2) & lsu0_port2_ce) | 0;
  assign rg_2_3_ce1 = cl_rg_2_3_ce1 | ((lsu0_ram_en[4:0] == 2) & lsu0_port3_ce) | 0;
  assign rg_3_0_ce1 = cl_rg_3_0_ce1 | ((lsu1_ram_en[4:0] == 3) & lsu1_port0_ce) | 0;
  assign rg_3_1_ce1 = cl_rg_3_1_ce1 | ((lsu1_ram_en[4:0] == 3) & lsu1_port1_ce) | 0;
  assign rg_3_2_ce1 = cl_rg_3_2_ce1 | ((lsu1_ram_en[4:0] == 3) & lsu1_port2_ce) | 0;
  assign rg_3_3_ce1 = cl_rg_3_3_ce1 | ((lsu1_ram_en[4:0] == 3) & lsu1_port3_ce) | 0;
  assign rg_4_0_ce1 = cl_rg_4_0_ce1 | ((lsu1_ram_en[4:0] == 4) & lsu1_port0_ce) | 0;
  assign rg_4_1_ce1 = cl_rg_4_1_ce1 | ((lsu1_ram_en[4:0] == 4) & lsu1_port1_ce) | 0;
  assign rg_4_2_ce1 = cl_rg_4_2_ce1 | ((lsu1_ram_en[4:0] == 4) & lsu1_port2_ce) | 0;
  assign rg_4_3_ce1 = cl_rg_4_3_ce1 | ((lsu1_ram_en[4:0] == 4) & lsu1_port3_ce) | 0;
  assign rg_5_0_ce1 = cl_rg_5_0_ce1 | ((lsu0_ram_en[4:0] == 5) & lsu0_port0_ce) | 0;
  assign rg_5_1_ce1 = cl_rg_5_1_ce1 | ((lsu0_ram_en[4:0] == 5) & lsu0_port1_ce) | 0;
  assign rg_5_2_ce1 = cl_rg_5_2_ce1 | ((lsu0_ram_en[4:0] == 5) & lsu0_port2_ce) | 0;
  assign rg_5_3_ce1 = cl_rg_5_3_ce1 | ((lsu0_ram_en[4:0] == 5) & lsu0_port3_ce) | 0;
  assign rg_6_0_ce1 = cl_rg_6_0_ce1 | ((lsu0_ram_en[4:0] == 6) & lsu0_port0_ce) | 0;
  assign rg_6_1_ce1 = cl_rg_6_1_ce1 | ((lsu0_ram_en[4:0] == 6) & lsu0_port1_ce) | 0;
  assign rg_6_2_ce1 = cl_rg_6_2_ce1 | ((lsu0_ram_en[4:0] == 6) & lsu0_port2_ce) | 0;
  assign rg_6_3_ce1 = cl_rg_6_3_ce1 | ((lsu0_ram_en[4:0] == 6) & lsu0_port3_ce) | 0;
  assign rg_7_0_ce1 = cl_rg_7_0_ce1 | ((lsu1_ram_en[4:0] == 7) & lsu1_port0_ce) | 0;
  assign rg_7_1_ce1 = cl_rg_7_1_ce1 | ((lsu1_ram_en[4:0] == 7) & lsu1_port1_ce) | 0;
  assign rg_7_2_ce1 = cl_rg_7_2_ce1 | ((lsu1_ram_en[4:0] == 7) & lsu1_port2_ce) | 0;
  assign rg_7_3_ce1 = cl_rg_7_3_ce1 | ((lsu1_ram_en[4:0] == 7) & lsu1_port3_ce) | 0;
  assign rg_8_0_ce1 = cl_rg_8_0_ce1 | ((lsu0_ram_en[4:0] == 8) & lsu0_port0_ce) | 0;
  assign rg_8_1_ce1 = cl_rg_8_1_ce1 | ((lsu0_ram_en[4:0] == 8) & lsu0_port1_ce) | 0;
  assign rg_8_2_ce1 = cl_rg_8_2_ce1 | ((lsu0_ram_en[4:0] == 8) & lsu0_port2_ce) | 0;
  assign rg_8_3_ce1 = cl_rg_8_3_ce1 | ((lsu0_ram_en[4:0] == 8) & lsu0_port3_ce) | 0;
  assign rg_9_0_ce1 = cl_rg_9_0_ce1 | ((lsu1_ram_en[4:0] == 9) & lsu1_port0_ce) | 0;
  assign rg_9_1_ce1 = cl_rg_9_1_ce1 | ((lsu1_ram_en[4:0] == 9) & lsu1_port1_ce) | 0;
  assign rg_9_2_ce1 = cl_rg_9_2_ce1 | ((lsu1_ram_en[4:0] == 9) & lsu1_port2_ce) | 0;
  assign rg_9_3_ce1 = cl_rg_9_3_ce1 | ((lsu1_ram_en[4:0] == 9) & lsu1_port3_ce) | 0;
  assign rg_0_0_we1 = (cl_rg_0_0_we1 & cl_rg_0_0_ce1) | ((lsu0_ram_en[4:0] == 0) & lsu0_port0_we) | 0;
  assign rg_0_1_we1 = (cl_rg_0_1_we1 & cl_rg_0_1_ce1) | ((lsu0_ram_en[4:0] == 0) & lsu0_port1_we) | 0;
  assign rg_0_2_we1 = (cl_rg_0_2_we1 & cl_rg_0_2_ce1) | ((lsu0_ram_en[4:0] == 0) & lsu0_port2_we) | 0;
  assign rg_0_3_we1 = (cl_rg_0_3_we1 & cl_rg_0_3_ce1) | ((lsu0_ram_en[4:0] == 0) & lsu0_port3_we) | 0;
  assign rg_1_0_we1 = (cl_rg_1_0_we1 & cl_rg_1_0_ce1) | ((lsu0_ram_en[4:0] == 1) & lsu0_port0_we) | 0;
  assign rg_1_1_we1 = (cl_rg_1_1_we1 & cl_rg_1_1_ce1) | ((lsu0_ram_en[4:0] == 1) & lsu0_port1_we) | 0;
  assign rg_1_2_we1 = (cl_rg_1_2_we1 & cl_rg_1_2_ce1) | ((lsu0_ram_en[4:0] == 1) & lsu0_port2_we) | 0;
  assign rg_1_3_we1 = (cl_rg_1_3_we1 & cl_rg_1_3_ce1) | ((lsu0_ram_en[4:0] == 1) & lsu0_port3_we) | 0;
  assign rg_2_0_we1 = (cl_rg_2_0_we1 & cl_rg_2_0_ce1) | ((lsu0_ram_en[4:0] == 2) & lsu0_port0_we) | 0;
  assign rg_2_1_we1 = (cl_rg_2_1_we1 & cl_rg_2_1_ce1) | ((lsu0_ram_en[4:0] == 2) & lsu0_port1_we) | 0;
  assign rg_2_2_we1 = (cl_rg_2_2_we1 & cl_rg_2_2_ce1) | ((lsu0_ram_en[4:0] == 2) & lsu0_port2_we) | 0;
  assign rg_2_3_we1 = (cl_rg_2_3_we1 & cl_rg_2_3_ce1) | ((lsu0_ram_en[4:0] == 2) & lsu0_port3_we) | 0;
  assign rg_3_0_we1 = (cl_rg_3_0_we1 & cl_rg_3_0_ce1) | ((lsu1_ram_en[4:0] == 3) & lsu1_port0_we) | 0;
  assign rg_3_1_we1 = (cl_rg_3_1_we1 & cl_rg_3_1_ce1) | ((lsu1_ram_en[4:0] == 3) & lsu1_port1_we) | 0;
  assign rg_3_2_we1 = (cl_rg_3_2_we1 & cl_rg_3_2_ce1) | ((lsu1_ram_en[4:0] == 3) & lsu1_port2_we) | 0;
  assign rg_3_3_we1 = (cl_rg_3_3_we1 & cl_rg_3_3_ce1) | ((lsu1_ram_en[4:0] == 3) & lsu1_port3_we) | 0;
  assign rg_4_0_we1 = (cl_rg_4_0_we1 & cl_rg_4_0_ce1) | ((lsu1_ram_en[4:0] == 4) & lsu1_port0_we) | 0;
  assign rg_4_1_we1 = (cl_rg_4_1_we1 & cl_rg_4_1_ce1) | ((lsu1_ram_en[4:0] == 4) & lsu1_port1_we) | 0;
  assign rg_4_2_we1 = (cl_rg_4_2_we1 & cl_rg_4_2_ce1) | ((lsu1_ram_en[4:0] == 4) & lsu1_port2_we) | 0;
  assign rg_4_3_we1 = (cl_rg_4_3_we1 & cl_rg_4_3_ce1) | ((lsu1_ram_en[4:0] == 4) & lsu1_port3_we) | 0;
  assign rg_5_0_we1 = (cl_rg_5_0_we1 & cl_rg_5_0_ce1) | ((lsu0_ram_en[4:0] == 5) & lsu0_port0_we) | 0;
  assign rg_5_1_we1 = (cl_rg_5_1_we1 & cl_rg_5_1_ce1) | ((lsu0_ram_en[4:0] == 5) & lsu0_port1_we) | 0;
  assign rg_5_2_we1 = (cl_rg_5_2_we1 & cl_rg_5_2_ce1) | ((lsu0_ram_en[4:0] == 5) & lsu0_port2_we) | 0;
  assign rg_5_3_we1 = (cl_rg_5_3_we1 & cl_rg_5_3_ce1) | ((lsu0_ram_en[4:0] == 5) & lsu0_port3_we) | 0;
  assign rg_6_0_we1 = (cl_rg_6_0_we1 & cl_rg_6_0_ce1) | ((lsu0_ram_en[4:0] == 6) & lsu0_port0_we) | 0;
  assign rg_6_1_we1 = (cl_rg_6_1_we1 & cl_rg_6_1_ce1) | ((lsu0_ram_en[4:0] == 6) & lsu0_port1_we) | 0;
  assign rg_6_2_we1 = (cl_rg_6_2_we1 & cl_rg_6_2_ce1) | ((lsu0_ram_en[4:0] == 6) & lsu0_port2_we) | 0;
  assign rg_6_3_we1 = (cl_rg_6_3_we1 & cl_rg_6_3_ce1) | ((lsu0_ram_en[4:0] == 6) & lsu0_port3_we) | 0;
  assign rg_7_0_we1 = (cl_rg_7_0_we1 & cl_rg_7_0_ce1) | ((lsu1_ram_en[4:0] == 7) & lsu1_port0_we) | 0;
  assign rg_7_1_we1 = (cl_rg_7_1_we1 & cl_rg_7_1_ce1) | ((lsu1_ram_en[4:0] == 7) & lsu1_port1_we) | 0;
  assign rg_7_2_we1 = (cl_rg_7_2_we1 & cl_rg_7_2_ce1) | ((lsu1_ram_en[4:0] == 7) & lsu1_port2_we) | 0;
  assign rg_7_3_we1 = (cl_rg_7_3_we1 & cl_rg_7_3_ce1) | ((lsu1_ram_en[4:0] == 7) & lsu1_port3_we) | 0;
  assign rg_8_0_we1 = (cl_rg_8_0_we1 & cl_rg_8_0_ce1) | ((lsu0_ram_en[4:0] == 8) & lsu0_port0_we) | 0;
  assign rg_8_1_we1 = (cl_rg_8_1_we1 & cl_rg_8_1_ce1) | ((lsu0_ram_en[4:0] == 8) & lsu0_port1_we) | 0;
  assign rg_8_2_we1 = (cl_rg_8_2_we1 & cl_rg_8_2_ce1) | ((lsu0_ram_en[4:0] == 8) & lsu0_port2_we) | 0;
  assign rg_8_3_we1 = (cl_rg_8_3_we1 & cl_rg_8_3_ce1) | ((lsu0_ram_en[4:0] == 8) & lsu0_port3_we) | 0;
  assign rg_9_0_we1 = (cl_rg_9_0_we1 & cl_rg_9_0_ce1) | ((lsu1_ram_en[4:0] == 9) & lsu1_port0_we) | 0;
  assign rg_9_1_we1 = (cl_rg_9_1_we1 & cl_rg_9_1_ce1) | ((lsu1_ram_en[4:0] == 9) & lsu1_port1_we) | 0;
  assign rg_9_2_we1 = (cl_rg_9_2_we1 & cl_rg_9_2_ce1) | ((lsu1_ram_en[4:0] == 9) & lsu1_port2_we) | 0;
  assign rg_9_3_we1 = (cl_rg_9_3_we1 & cl_rg_9_3_ce1) | ((lsu1_ram_en[4:0] == 9) & lsu1_port3_we) | 0;
  assign rg_0_0_addr0 = cl_rg_0_0_ce0 ? cl_rg_0_0_addr0 : 1'b1 ? lsu0_port2_addr : 0;
  assign rg_0_1_addr0 = cl_rg_0_1_ce0 ? cl_rg_0_1_addr0 : 1'b1 ? lsu0_port3_addr : 0;
  assign rg_0_2_addr0 = cl_rg_0_2_ce0 ? cl_rg_0_2_addr0 : 1'b1 ? lsu0_port0_addr : 0;
  assign rg_0_3_addr0 = cl_rg_0_3_ce0 ? cl_rg_0_3_addr0 : 1'b1 ? lsu0_port1_addr : 0;
  assign rg_1_0_addr0 = cl_rg_1_0_ce0 ? cl_rg_1_0_addr0 : 1'b1 ? lsu0_port2_addr : 0;
  assign rg_1_1_addr0 = cl_rg_1_1_ce0 ? cl_rg_1_1_addr0 : 1'b1 ? lsu0_port3_addr : 0;
  assign rg_1_2_addr0 = cl_rg_1_2_ce0 ? cl_rg_1_2_addr0 : 1'b1 ? lsu0_port0_addr : 0;
  assign rg_1_3_addr0 = cl_rg_1_3_ce0 ? cl_rg_1_3_addr0 : 1'b1 ? lsu0_port1_addr : 0;
  assign rg_2_0_addr0 = cl_rg_2_0_ce0 ? cl_rg_2_0_addr0 : 1'b1 ? lsu0_port2_addr : 0;
  assign rg_2_1_addr0 = cl_rg_2_1_ce0 ? cl_rg_2_1_addr0 : 1'b1 ? lsu0_port3_addr : 0;
  assign rg_2_2_addr0 = cl_rg_2_2_ce0 ? cl_rg_2_2_addr0 : 1'b1 ? lsu0_port0_addr : 0;
  assign rg_2_3_addr0 = cl_rg_2_3_ce0 ? cl_rg_2_3_addr0 : 1'b1 ? lsu0_port1_addr : 0;
  assign rg_3_0_addr0 = cl_rg_3_0_ce0 ? cl_rg_3_0_addr0 : 1'b1 ? lsu1_port2_addr : 0;
  assign rg_3_1_addr0 = cl_rg_3_1_ce0 ? cl_rg_3_1_addr0 : 1'b1 ? lsu1_port3_addr : 0;
  assign rg_3_2_addr0 = cl_rg_3_2_ce0 ? cl_rg_3_2_addr0 : 1'b1 ? lsu1_port0_addr : 0;
  assign rg_3_3_addr0 = cl_rg_3_3_ce0 ? cl_rg_3_3_addr0 : 1'b1 ? lsu1_port1_addr : 0;
  assign rg_4_0_addr0 = cl_rg_4_0_ce0 ? cl_rg_4_0_addr0 : 1'b1 ? lsu1_port2_addr : 0;
  assign rg_4_1_addr0 = cl_rg_4_1_ce0 ? cl_rg_4_1_addr0 : 1'b1 ? lsu1_port3_addr : 0;
  assign rg_4_2_addr0 = cl_rg_4_2_ce0 ? cl_rg_4_2_addr0 : 1'b1 ? lsu1_port0_addr : 0;
  assign rg_4_3_addr0 = cl_rg_4_3_ce0 ? cl_rg_4_3_addr0 : 1'b1 ? lsu1_port1_addr : 0;
  assign rg_5_0_addr0 = cl_rg_5_0_ce0 ? cl_rg_5_0_addr0 : 1'b1 ? lsu0_port2_addr : 0;
  assign rg_5_1_addr0 = cl_rg_5_1_ce0 ? cl_rg_5_1_addr0 : 1'b1 ? lsu0_port3_addr : 0;
  assign rg_5_2_addr0 = cl_rg_5_2_ce0 ? cl_rg_5_2_addr0 : 1'b1 ? lsu0_port0_addr : 0;
  assign rg_5_3_addr0 = cl_rg_5_3_ce0 ? cl_rg_5_3_addr0 : 1'b1 ? lsu0_port1_addr : 0;
  assign rg_6_0_addr0 = cl_rg_6_0_ce0 ? cl_rg_6_0_addr0 : 1'b1 ? lsu0_port0_addr : 0;
  assign rg_6_1_addr0 = cl_rg_6_1_ce0 ? cl_rg_6_1_addr0 : 1'b1 ? lsu0_port1_addr : 0;
  assign rg_6_2_addr0 = cl_rg_6_2_ce0 ? cl_rg_6_2_addr0 : 1'b1 ? lsu0_port2_addr : 0;
  assign rg_6_3_addr0 = cl_rg_6_3_ce0 ? cl_rg_6_3_addr0 : 1'b1 ? lsu0_port3_addr : 0;
  assign rg_7_0_addr0 = cl_rg_7_0_ce0 ? cl_rg_7_0_addr0 : 1'b1 ? lsu1_port0_addr : 0;
  assign rg_7_1_addr0 = cl_rg_7_1_ce0 ? cl_rg_7_1_addr0 : 1'b1 ? lsu1_port1_addr : 0;
  assign rg_7_2_addr0 = cl_rg_7_2_ce0 ? cl_rg_7_2_addr0 : 1'b1 ? lsu1_port2_addr : 0;
  assign rg_7_3_addr0 = cl_rg_7_3_ce0 ? cl_rg_7_3_addr0 : 1'b1 ? lsu1_port3_addr : 0;
  assign rg_8_0_addr0 = cl_rg_8_0_ce0 ? cl_rg_8_0_addr0 : 1'b1 ? lsu0_port0_addr : 0;
  assign rg_8_1_addr0 = cl_rg_8_1_ce0 ? cl_rg_8_1_addr0 : 1'b1 ? lsu0_port1_addr : 0;
  assign rg_8_2_addr0 = cl_rg_8_2_ce0 ? cl_rg_8_2_addr0 : 1'b1 ? lsu0_port2_addr : 0;
  assign rg_8_3_addr0 = cl_rg_8_3_ce0 ? cl_rg_8_3_addr0 : 1'b1 ? lsu0_port3_addr : 0;
  assign rg_9_0_addr0 = cl_rg_9_0_ce0 ? cl_rg_9_0_addr0 : 1'b1 ? lsu1_port0_addr : 0;
  assign rg_9_1_addr0 = cl_rg_9_1_ce0 ? cl_rg_9_1_addr0 : 1'b1 ? lsu1_port1_addr : 0;
  assign rg_9_2_addr0 = cl_rg_9_2_ce0 ? cl_rg_9_2_addr0 : 1'b1 ? lsu1_port2_addr : 0;
  assign rg_9_3_addr0 = cl_rg_9_3_ce0 ? cl_rg_9_3_addr0 : 1'b1 ? lsu1_port3_addr : 0;
  assign rg_0_0_ce0 = cl_rg_0_0_ce0 | 0;
  assign rg_0_1_ce0 = cl_rg_0_1_ce0 | 0;
  assign rg_0_2_ce0 = cl_rg_0_2_ce0 | 0;
  assign rg_0_3_ce0 = cl_rg_0_3_ce0 | 0;
  assign rg_1_0_ce0 = cl_rg_1_0_ce0 | 0;
  assign rg_1_1_ce0 = cl_rg_1_1_ce0 | 0;
  assign rg_1_2_ce0 = cl_rg_1_2_ce0 | 0;
  assign rg_1_3_ce0 = cl_rg_1_3_ce0 | 0;
  assign rg_2_0_ce0 = cl_rg_2_0_ce0 | 0;
  assign rg_2_1_ce0 = cl_rg_2_1_ce0 | 0;
  assign rg_2_2_ce0 = cl_rg_2_2_ce0 | 0;
  assign rg_2_3_ce0 = cl_rg_2_3_ce0 | 0;
  assign rg_3_0_ce0 = cl_rg_3_0_ce0 | 0;
  assign rg_3_1_ce0 = cl_rg_3_1_ce0 | 0;
  assign rg_3_2_ce0 = cl_rg_3_2_ce0 | 0;
  assign rg_3_3_ce0 = cl_rg_3_3_ce0 | 0;
  assign rg_4_0_ce0 = cl_rg_4_0_ce0 | 0;
  assign rg_4_1_ce0 = cl_rg_4_1_ce0 | 0;
  assign rg_4_2_ce0 = cl_rg_4_2_ce0 | 0;
  assign rg_4_3_ce0 = cl_rg_4_3_ce0 | 0;
  assign rg_5_0_ce0 = cl_rg_5_0_ce0 | 0;
  assign rg_5_1_ce0 = cl_rg_5_1_ce0 | 0;
  assign rg_5_2_ce0 = cl_rg_5_2_ce0 | 0;
  assign rg_5_3_ce0 = cl_rg_5_3_ce0 | 0;
  assign rg_6_0_ce0 = cl_rg_6_0_ce0 | ((lsu0_ram_en[4:0] == 6) & lsu0_port0_ce) | 0;
  assign rg_6_1_ce0 = cl_rg_6_1_ce0 | ((lsu0_ram_en[4:0] == 6) & lsu0_port1_ce) | 0;
  assign rg_6_2_ce0 = cl_rg_6_2_ce0 | ((lsu0_ram_en[4:0] == 6) & lsu0_port2_ce) | 0;
  assign rg_6_3_ce0 = cl_rg_6_3_ce0 | ((lsu0_ram_en[4:0] == 6) & lsu0_port3_ce) | 0;
  assign rg_7_0_ce0 = cl_rg_7_0_ce0 | ((lsu1_ram_en[4:0] == 7) & lsu1_port0_ce) | 0;
  assign rg_7_1_ce0 = cl_rg_7_1_ce0 | ((lsu1_ram_en[4:0] == 7) & lsu1_port1_ce) | 0;
  assign rg_7_2_ce0 = cl_rg_7_2_ce0 | ((lsu1_ram_en[4:0] == 7) & lsu1_port2_ce) | 0;
  assign rg_7_3_ce0 = cl_rg_7_3_ce0 | ((lsu1_ram_en[4:0] == 7) & lsu1_port3_ce) | 0;
  assign rg_8_0_ce0 = cl_rg_8_0_ce0 | ((lsu0_ram_en[4:0] == 8) & lsu0_port0_ce) | 0;
  assign rg_8_1_ce0 = cl_rg_8_1_ce0 | ((lsu0_ram_en[4:0] == 8) & lsu0_port1_ce) | 0;
  assign rg_8_2_ce0 = cl_rg_8_2_ce0 | ((lsu0_ram_en[4:0] == 8) & lsu0_port2_ce) | 0;
  assign rg_8_3_ce0 = cl_rg_8_3_ce0 | ((lsu0_ram_en[4:0] == 8) & lsu0_port3_ce) | 0;
  assign rg_9_0_ce0 = cl_rg_9_0_ce0 | ((lsu1_ram_en[4:0] == 9) & lsu1_port0_ce) | 0;
  assign rg_9_1_ce0 = cl_rg_9_1_ce0 | ((lsu1_ram_en[4:0] == 9) & lsu1_port1_ce) | 0;
  assign rg_9_2_ce0 = cl_rg_9_2_ce0 | ((lsu1_ram_en[4:0] == 9) & lsu1_port2_ce) | 0;
  assign rg_9_3_ce0 = cl_rg_9_3_ce0 | ((lsu1_ram_en[4:0] == 9) & lsu1_port3_ce) | 0;
  assign rg_0_0_we0 = (cl_rg_0_0_we0 & cl_rg_0_0_ce0) | 0;
  assign rg_0_1_we0 = (cl_rg_0_1_we0 & cl_rg_0_1_ce0) | 0;
  assign rg_0_2_we0 = (cl_rg_0_2_we0 & cl_rg_0_2_ce0) | 0;
  assign rg_0_3_we0 = (cl_rg_0_3_we0 & cl_rg_0_3_ce0) | 0;
  assign rg_1_0_we0 = (cl_rg_1_0_we0 & cl_rg_1_0_ce0) | 0;
  assign rg_1_1_we0 = (cl_rg_1_1_we0 & cl_rg_1_1_ce0) | 0;
  assign rg_1_2_we0 = (cl_rg_1_2_we0 & cl_rg_1_2_ce0) | 0;
  assign rg_1_3_we0 = (cl_rg_1_3_we0 & cl_rg_1_3_ce0) | 0;
  assign rg_2_0_we0 = (cl_rg_2_0_we0 & cl_rg_2_0_ce0) | 0;
  assign rg_2_1_we0 = (cl_rg_2_1_we0 & cl_rg_2_1_ce0) | 0;
  assign rg_2_2_we0 = (cl_rg_2_2_we0 & cl_rg_2_2_ce0) | 0;
  assign rg_2_3_we0 = (cl_rg_2_3_we0 & cl_rg_2_3_ce0) | 0;
  assign rg_3_0_we0 = (cl_rg_3_0_we0 & cl_rg_3_0_ce0) | 0;
  assign rg_3_1_we0 = (cl_rg_3_1_we0 & cl_rg_3_1_ce0) | 0;
  assign rg_3_2_we0 = (cl_rg_3_2_we0 & cl_rg_3_2_ce0) | 0;
  assign rg_3_3_we0 = (cl_rg_3_3_we0 & cl_rg_3_3_ce0) | 0;
  assign rg_4_0_we0 = (cl_rg_4_0_we0 & cl_rg_4_0_ce0) | 0;
  assign rg_4_1_we0 = (cl_rg_4_1_we0 & cl_rg_4_1_ce0) | 0;
  assign rg_4_2_we0 = (cl_rg_4_2_we0 & cl_rg_4_2_ce0) | 0;
  assign rg_4_3_we0 = (cl_rg_4_3_we0 & cl_rg_4_3_ce0) | 0;
  assign rg_5_0_we0 = (cl_rg_5_0_we0 & cl_rg_5_0_ce0) | 0;
  assign rg_5_1_we0 = (cl_rg_5_1_we0 & cl_rg_5_1_ce0) | 0;
  assign rg_5_2_we0 = (cl_rg_5_2_we0 & cl_rg_5_2_ce0) | 0;
  assign rg_5_3_we0 = (cl_rg_5_3_we0 & cl_rg_5_3_ce0) | 0;
  assign rg_6_0_we0 = (cl_rg_6_0_we0 & cl_rg_6_0_ce0) | 0;
  assign rg_6_1_we0 = (cl_rg_6_1_we0 & cl_rg_6_1_ce0) | 0;
  assign rg_6_2_we0 = (cl_rg_6_2_we0 & cl_rg_6_2_ce0) | 0;
  assign rg_6_3_we0 = (cl_rg_6_3_we0 & cl_rg_6_3_ce0) | 0;
  assign rg_7_0_we0 = (cl_rg_7_0_we0 & cl_rg_7_0_ce0) | 0;
  assign rg_7_1_we0 = (cl_rg_7_1_we0 & cl_rg_7_1_ce0) | 0;
  assign rg_7_2_we0 = (cl_rg_7_2_we0 & cl_rg_7_2_ce0) | 0;
  assign rg_7_3_we0 = (cl_rg_7_3_we0 & cl_rg_7_3_ce0) | 0;
  assign rg_8_0_we0 = (cl_rg_8_0_we0 & cl_rg_8_0_ce0) | 0;
  assign rg_8_1_we0 = (cl_rg_8_1_we0 & cl_rg_8_1_ce0) | 0;
  assign rg_8_2_we0 = (cl_rg_8_2_we0 & cl_rg_8_2_ce0) | 0;
  assign rg_8_3_we0 = (cl_rg_8_3_we0 & cl_rg_8_3_ce0) | 0;
  assign rg_9_0_we0 = (cl_rg_9_0_we0 & cl_rg_9_0_ce0) | 0;
  assign rg_9_1_we0 = (cl_rg_9_1_we0 & cl_rg_9_1_ce0) | 0;
  assign rg_9_2_we0 = (cl_rg_9_2_we0 & cl_rg_9_2_ce0) | 0;
  assign rg_9_3_we0 = (cl_rg_9_3_we0 & cl_rg_9_3_ce0) | 0;
  assign rg_0_0_d0 = cl_rg_0_0_ce0 ? cl_rg_0_0_d0 : 0;
  assign rg_0_1_d0 = cl_rg_0_1_ce0 ? cl_rg_0_1_d0 : 0;
  assign rg_0_2_d0 = cl_rg_0_2_ce0 ? cl_rg_0_2_d0 : 0;
  assign rg_0_3_d0 = cl_rg_0_3_ce0 ? cl_rg_0_3_d0 : 0;
  assign rg_1_0_d0 = cl_rg_1_0_ce0 ? cl_rg_1_0_d0 : 0;
  assign rg_1_1_d0 = cl_rg_1_1_ce0 ? cl_rg_1_1_d0 : 0;
  assign rg_1_2_d0 = cl_rg_1_2_ce0 ? cl_rg_1_2_d0 : 0;
  assign rg_1_3_d0 = cl_rg_1_3_ce0 ? cl_rg_1_3_d0 : 0;
  assign rg_2_0_d0 = cl_rg_2_0_ce0 ? cl_rg_2_0_d0 : 0;
  assign rg_2_1_d0 = cl_rg_2_1_ce0 ? cl_rg_2_1_d0 : 0;
  assign rg_2_2_d0 = cl_rg_2_2_ce0 ? cl_rg_2_2_d0 : 0;
  assign rg_2_3_d0 = cl_rg_2_3_ce0 ? cl_rg_2_3_d0 : 0;
  assign rg_3_0_d0 = cl_rg_3_0_ce0 ? cl_rg_3_0_d0 : 0;
  assign rg_3_1_d0 = cl_rg_3_1_ce0 ? cl_rg_3_1_d0 : 0;
  assign rg_3_2_d0 = cl_rg_3_2_ce0 ? cl_rg_3_2_d0 : 0;
  assign rg_3_3_d0 = cl_rg_3_3_ce0 ? cl_rg_3_3_d0 : 0;
  assign rg_4_0_d0 = cl_rg_4_0_ce0 ? cl_rg_4_0_d0 : 0;
  assign rg_4_1_d0 = cl_rg_4_1_ce0 ? cl_rg_4_1_d0 : 0;
  assign rg_4_2_d0 = cl_rg_4_2_ce0 ? cl_rg_4_2_d0 : 0;
  assign rg_4_3_d0 = cl_rg_4_3_ce0 ? cl_rg_4_3_d0 : 0;
  assign rg_5_0_d0 = cl_rg_5_0_ce0 ? cl_rg_5_0_d0 : 0;
  assign rg_5_1_d0 = cl_rg_5_1_ce0 ? cl_rg_5_1_d0 : 0;
  assign rg_5_2_d0 = cl_rg_5_2_ce0 ? cl_rg_5_2_d0 : 0;
  assign rg_5_3_d0 = cl_rg_5_3_ce0 ? cl_rg_5_3_d0 : 0;
  assign rg_6_0_d0 = cl_rg_6_0_ce0 ? cl_rg_6_0_d0 : 0;
  assign rg_6_1_d0 = cl_rg_6_1_ce0 ? cl_rg_6_1_d0 : 0;
  assign rg_6_2_d0 = cl_rg_6_2_ce0 ? cl_rg_6_2_d0 : 0;
  assign rg_6_3_d0 = cl_rg_6_3_ce0 ? cl_rg_6_3_d0 : 0;
  assign rg_7_0_d0 = cl_rg_7_0_ce0 ? cl_rg_7_0_d0 : 0;
  assign rg_7_1_d0 = cl_rg_7_1_ce0 ? cl_rg_7_1_d0 : 0;
  assign rg_7_2_d0 = cl_rg_7_2_ce0 ? cl_rg_7_2_d0 : 0;
  assign rg_7_3_d0 = cl_rg_7_3_ce0 ? cl_rg_7_3_d0 : 0;
  assign rg_8_0_d0 = cl_rg_8_0_ce0 ? cl_rg_8_0_d0 : 0;
  assign rg_8_1_d0 = cl_rg_8_1_ce0 ? cl_rg_8_1_d0 : 0;
  assign rg_8_2_d0 = cl_rg_8_2_ce0 ? cl_rg_8_2_d0 : 0;
  assign rg_8_3_d0 = cl_rg_8_3_ce0 ? cl_rg_8_3_d0 : 0;
  assign rg_9_0_d0 = cl_rg_9_0_ce0 ? cl_rg_9_0_d0 : 0;
  assign rg_9_1_d0 = cl_rg_9_1_ce0 ? cl_rg_9_1_d0 : 0;
  assign rg_9_2_d0 = cl_rg_9_2_ce0 ? cl_rg_9_2_d0 : 0;
  assign rg_9_3_d0 = cl_rg_9_3_ce0 ? cl_rg_9_3_d0 : 0;
  wire [4:0] lsu0_ram_en_pipe;
  pipe_block #(.NUM_STAGES(3), .WIDTH(5)) lsu0_ram_en_pipe_block (
    .clk(clk),
    .d(lsu0_ram_en),
    .q(lsu0_ram_en_pipe));
  wire lsu0_port0_ce_pipe;
  pipe_block #(.NUM_STAGES(3), .WIDTH(1)) lsu0_port0_ce_pipe_block (
    .clk(clk),
    .d(lsu0_port0_ce),
    .q(lsu0_port0_ce_pipe));
  wire lsu0_port1_ce_pipe;
  pipe_block #(.NUM_STAGES(3), .WIDTH(1)) lsu0_port1_ce_pipe_block (
    .clk(clk),
    .d(lsu0_port1_ce),
    .q(lsu0_port1_ce_pipe));
  wire lsu0_port2_ce_pipe;
  pipe_block #(.NUM_STAGES(3), .WIDTH(1)) lsu0_port2_ce_pipe_block (
    .clk(clk),
    .d(lsu0_port2_ce),
    .q(lsu0_port2_ce_pipe));
  wire lsu0_port3_ce_pipe;
  pipe_block #(.NUM_STAGES(3), .WIDTH(1)) lsu0_port3_ce_pipe_block (
    .clk(clk),
    .d(lsu0_port3_ce),
    .q(lsu0_port3_ce_pipe));
  wire [4:0] lsu1_ram_en_pipe;
  pipe_block #(.NUM_STAGES(3), .WIDTH(5)) lsu1_ram_en_pipe_block (
    .clk(clk),
    .d(lsu1_ram_en),
    .q(lsu1_ram_en_pipe));
  wire lsu1_port0_ce_pipe;
  pipe_block #(.NUM_STAGES(3), .WIDTH(1)) lsu1_port0_ce_pipe_block (
    .clk(clk),
    .d(lsu1_port0_ce),
    .q(lsu1_port0_ce_pipe));
  wire lsu1_port1_ce_pipe;
  pipe_block #(.NUM_STAGES(3), .WIDTH(1)) lsu1_port1_ce_pipe_block (
    .clk(clk),
    .d(lsu1_port1_ce),
    .q(lsu1_port1_ce_pipe));
  wire lsu1_port2_ce_pipe;
  pipe_block #(.NUM_STAGES(3), .WIDTH(1)) lsu1_port2_ce_pipe_block (
    .clk(clk),
    .d(lsu1_port2_ce),
    .q(lsu1_port2_ce_pipe));
  wire lsu1_port3_ce_pipe;
  pipe_block #(.NUM_STAGES(3), .WIDTH(1)) lsu1_port3_ce_pipe_block (
    .clk(clk),
    .d(lsu1_port3_ce),
    .q(lsu1_port3_ce_pipe));
  assign lsu0_port0_q =
    (lsu0_ram_en_pipe[4:0] == 0) ? rg_0_0_q1 :
    (lsu0_ram_en_pipe[4:0] == 1) ? rg_1_0_q1 :
    (lsu0_ram_en_pipe[4:0] == 2) ? rg_2_0_q1 :
    (lsu0_ram_en_pipe[4:0] == 5) ? rg_5_0_q1 :
    (lsu0_ram_en_pipe[4:0] == 6) ? rg_6_0_q0 :
    (lsu0_ram_en_pipe[4:0] == 8) ? rg_8_0_q0 :
    0;
  assign lsu0_port1_q =
    (lsu0_ram_en_pipe[4:0] == 0) ? rg_0_1_q1 :
    (lsu0_ram_en_pipe[4:0] == 1) ? rg_1_1_q1 :
    (lsu0_ram_en_pipe[4:0] == 2) ? rg_2_1_q1 :
    (lsu0_ram_en_pipe[4:0] == 5) ? rg_5_1_q1 :
    (lsu0_ram_en_pipe[4:0] == 6) ? rg_6_1_q0 :
    (lsu0_ram_en_pipe[4:0] == 8) ? rg_8_1_q0 :
    0;
  assign lsu0_port2_q =
    (lsu0_ram_en_pipe[4:0] == 0) ? rg_0_2_q1 :
    (lsu0_ram_en_pipe[4:0] == 1) ? rg_1_2_q1 :
    (lsu0_ram_en_pipe[4:0] == 2) ? rg_2_2_q1 :
    (lsu0_ram_en_pipe[4:0] == 5) ? rg_5_2_q1 :
    (lsu0_ram_en_pipe[4:0] == 6) ? rg_6_2_q0 :
    (lsu0_ram_en_pipe[4:0] == 8) ? rg_8_2_q0 :
    0;
  assign lsu0_port3_q =
    (lsu0_ram_en_pipe[4:0] == 0) ? rg_0_3_q1 :
    (lsu0_ram_en_pipe[4:0] == 1) ? rg_1_3_q1 :
    (lsu0_ram_en_pipe[4:0] == 2) ? rg_2_3_q1 :
    (lsu0_ram_en_pipe[4:0] == 5) ? rg_5_3_q1 :
    (lsu0_ram_en_pipe[4:0] == 6) ? rg_6_3_q0 :
    (lsu0_ram_en_pipe[4:0] == 8) ? rg_8_3_q0 :
    0;
  assign lsu1_port0_q =
    (lsu1_ram_en_pipe[4:0] == 3) ? rg_3_0_q1 :
    (lsu1_ram_en_pipe[4:0] == 4) ? rg_4_0_q1 :
    (lsu1_ram_en_pipe[4:0] == 7) ? rg_7_0_q0 :
    (lsu1_ram_en_pipe[4:0] == 9) ? rg_9_0_q0 :
    0;
  assign lsu1_port1_q =
    (lsu1_ram_en_pipe[4:0] == 3) ? rg_3_1_q1 :
    (lsu1_ram_en_pipe[4:0] == 4) ? rg_4_1_q1 :
    (lsu1_ram_en_pipe[4:0] == 7) ? rg_7_1_q0 :
    (lsu1_ram_en_pipe[4:0] == 9) ? rg_9_1_q0 :
    0;
  assign lsu1_port2_q =
    (lsu1_ram_en_pipe[4:0] == 3) ? rg_3_2_q1 :
    (lsu1_ram_en_pipe[4:0] == 4) ? rg_4_2_q1 :
    (lsu1_ram_en_pipe[4:0] == 7) ? rg_7_2_q0 :
    (lsu1_ram_en_pipe[4:0] == 9) ? rg_9_2_q0 :
    0;
  assign lsu1_port3_q =
    (lsu1_ram_en_pipe[4:0] == 3) ? rg_3_3_q1 :
    (lsu1_ram_en_pipe[4:0] == 4) ? rg_4_3_q1 :
    (lsu1_ram_en_pipe[4:0] == 7) ? rg_7_3_q0 :
    (lsu1_ram_en_pipe[4:0] == 9) ? rg_9_3_q0 :
    0;
  assign cl_rg_0_0_q0 = rg_0_0_q0;
  assign cl_rg_0_0_q1 = rg_0_0_q1;
  assign cl_rg_0_1_q0 = rg_0_1_q0;
  assign cl_rg_0_1_q1 = rg_0_1_q1;
  assign cl_rg_0_2_q0 = rg_0_2_q0;
  assign cl_rg_0_2_q1 = rg_0_2_q1;
  assign cl_rg_0_3_q0 = rg_0_3_q0;
  assign cl_rg_0_3_q1 = rg_0_3_q1;
  assign cl_rg_1_0_q0 = rg_1_0_q0;
  assign cl_rg_1_0_q1 = rg_1_0_q1;
  assign cl_rg_1_1_q0 = rg_1_1_q0;
  assign cl_rg_1_1_q1 = rg_1_1_q1;
  assign cl_rg_1_2_q0 = rg_1_2_q0;
  assign cl_rg_1_2_q1 = rg_1_2_q1;
  assign cl_rg_1_3_q0 = rg_1_3_q0;
  assign cl_rg_1_3_q1 = rg_1_3_q1;
  assign cl_rg_2_0_q0 = rg_2_0_q0;
  assign cl_rg_2_0_q1 = rg_2_0_q1;
  assign cl_rg_2_1_q0 = rg_2_1_q0;
  assign cl_rg_2_1_q1 = rg_2_1_q1;
  assign cl_rg_2_2_q0 = rg_2_2_q0;
  assign cl_rg_2_2_q1 = rg_2_2_q1;
  assign cl_rg_2_3_q0 = rg_2_3_q0;
  assign cl_rg_2_3_q1 = rg_2_3_q1;
  assign cl_rg_3_0_q0 = rg_3_0_q0;
  assign cl_rg_3_0_q1 = rg_3_0_q1;
  assign cl_rg_3_1_q0 = rg_3_1_q0;
  assign cl_rg_3_1_q1 = rg_3_1_q1;
  assign cl_rg_3_2_q0 = rg_3_2_q0;
  assign cl_rg_3_2_q1 = rg_3_2_q1;
  assign cl_rg_3_3_q0 = rg_3_3_q0;
  assign cl_rg_3_3_q1 = rg_3_3_q1;
  assign cl_rg_4_0_q0 = rg_4_0_q0;
  assign cl_rg_4_0_q1 = rg_4_0_q1;
  assign cl_rg_4_1_q0 = rg_4_1_q0;
  assign cl_rg_4_1_q1 = rg_4_1_q1;
  assign cl_rg_4_2_q0 = rg_4_2_q0;
  assign cl_rg_4_2_q1 = rg_4_2_q1;
  assign cl_rg_4_3_q0 = rg_4_3_q0;
  assign cl_rg_4_3_q1 = rg_4_3_q1;
  assign cl_rg_5_0_q0 = rg_5_0_q0;
  assign cl_rg_5_0_q1 = rg_5_0_q1;
  assign cl_rg_5_1_q0 = rg_5_1_q0;
  assign cl_rg_5_1_q1 = rg_5_1_q1;
  assign cl_rg_5_2_q0 = rg_5_2_q0;
  assign cl_rg_5_2_q1 = rg_5_2_q1;
  assign cl_rg_5_3_q0 = rg_5_3_q0;
  assign cl_rg_5_3_q1 = rg_5_3_q1;
  assign cl_rg_6_0_q0 = rg_6_0_q0;
  assign cl_rg_6_0_q1 = rg_6_0_q1;
  assign cl_rg_6_1_q0 = rg_6_1_q0;
  assign cl_rg_6_1_q1 = rg_6_1_q1;
  assign cl_rg_6_2_q0 = rg_6_2_q0;
  assign cl_rg_6_2_q1 = rg_6_2_q1;
  assign cl_rg_6_3_q0 = rg_6_3_q0;
  assign cl_rg_6_3_q1 = rg_6_3_q1;
  assign cl_rg_7_0_q0 = rg_7_0_q0;
  assign cl_rg_7_0_q1 = rg_7_0_q1;
  assign cl_rg_7_1_q0 = rg_7_1_q0;
  assign cl_rg_7_1_q1 = rg_7_1_q1;
  assign cl_rg_7_2_q0 = rg_7_2_q0;
  assign cl_rg_7_2_q1 = rg_7_2_q1;
  assign cl_rg_7_3_q0 = rg_7_3_q0;
  assign cl_rg_7_3_q1 = rg_7_3_q1;
  assign cl_rg_8_0_q0 = rg_8_0_q0;
  assign cl_rg_8_0_q1 = rg_8_0_q1;
  assign cl_rg_8_1_q0 = rg_8_1_q0;
  assign cl_rg_8_1_q1 = rg_8_1_q1;
  assign cl_rg_8_2_q0 = rg_8_2_q0;
  assign cl_rg_8_2_q1 = rg_8_2_q1;
  assign cl_rg_8_3_q0 = rg_8_3_q0;
  assign cl_rg_8_3_q1 = rg_8_3_q1;
  assign cl_rg_9_0_q0 = rg_9_0_q0;
  assign cl_rg_9_0_q1 = rg_9_0_q1;
  assign cl_rg_9_1_q0 = rg_9_1_q0;
  assign cl_rg_9_1_q1 = rg_9_1_q1;
  assign cl_rg_9_2_q0 = rg_9_2_q0;
  assign cl_rg_9_2_q1 = rg_9_2_q1;
  assign cl_rg_9_3_q0 = rg_9_3_q0;
  assign cl_rg_9_3_q1 = rg_9_3_q1;
endmodule

