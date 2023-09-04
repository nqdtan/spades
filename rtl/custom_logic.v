`include "socket_config.vh"
module custom_logic (

  input  [255:0] cl_ss0_in_data,
  input          cl_ss0_in_valid,
  output         cl_ss0_in_ready,
  output [255:0] cl_ss0_out_data,
  output         cl_ss0_out_valid,
  input          cl_ss0_out_ready,

  input  [255:0] cl_ss1_in_data,
  input          cl_ss1_in_valid,
  output         cl_ss1_in_ready,
  output [255:0] cl_ss1_out_data,
  output         cl_ss1_out_valid,
  input          cl_ss1_out_ready,

  output [11:0] cl_rg_0_0_addr0,
  output [63:0] cl_rg_0_0_d0,
  input  [63:0] cl_rg_0_0_q0,
  output        cl_rg_0_0_ce0,
  output        cl_rg_0_0_we0,
  output [11:0] cl_rg_0_0_addr1,
  output [63:0] cl_rg_0_0_d1,
  input  [63:0] cl_rg_0_0_q1,
  output        cl_rg_0_0_ce1,
  output        cl_rg_0_0_we1,

  output [11:0] cl_rg_0_1_addr0,
  output [63:0] cl_rg_0_1_d0,
  input  [63:0] cl_rg_0_1_q0,
  output        cl_rg_0_1_ce0,
  output        cl_rg_0_1_we0,
  output [11:0] cl_rg_0_1_addr1,
  output [63:0] cl_rg_0_1_d1,
  input  [63:0] cl_rg_0_1_q1,
  output        cl_rg_0_1_ce1,
  output        cl_rg_0_1_we1,

  output [11:0] cl_rg_0_2_addr0,
  output [63:0] cl_rg_0_2_d0,
  input  [63:0] cl_rg_0_2_q0,
  output        cl_rg_0_2_ce0,
  output        cl_rg_0_2_we0,
  output [11:0] cl_rg_0_2_addr1,
  output [63:0] cl_rg_0_2_d1,
  input  [63:0] cl_rg_0_2_q1,
  output        cl_rg_0_2_ce1,
  output        cl_rg_0_2_we1,

  output [11:0] cl_rg_0_3_addr0,
  output [63:0] cl_rg_0_3_d0,
  input  [63:0] cl_rg_0_3_q0,
  output        cl_rg_0_3_ce0,
  output        cl_rg_0_3_we0,
  output [11:0] cl_rg_0_3_addr1,
  output [63:0] cl_rg_0_3_d1,
  input  [63:0] cl_rg_0_3_q1,
  output        cl_rg_0_3_ce1,
  output        cl_rg_0_3_we1,

  output [11:0] cl_rg_1_0_addr0,
  output [63:0] cl_rg_1_0_d0,
  input  [63:0] cl_rg_1_0_q0,
  output        cl_rg_1_0_ce0,
  output        cl_rg_1_0_we0,
  output [11:0] cl_rg_1_0_addr1,
  output [63:0] cl_rg_1_0_d1,
  input  [63:0] cl_rg_1_0_q1,
  output        cl_rg_1_0_ce1,
  output        cl_rg_1_0_we1,

  output [11:0] cl_rg_1_1_addr0,
  output [63:0] cl_rg_1_1_d0,
  input  [63:0] cl_rg_1_1_q0,
  output        cl_rg_1_1_ce0,
  output        cl_rg_1_1_we0,
  output [11:0] cl_rg_1_1_addr1,
  output [63:0] cl_rg_1_1_d1,
  input  [63:0] cl_rg_1_1_q1,
  output        cl_rg_1_1_ce1,
  output        cl_rg_1_1_we1,

  output [11:0] cl_rg_1_2_addr0,
  output [63:0] cl_rg_1_2_d0,
  input  [63:0] cl_rg_1_2_q0,
  output        cl_rg_1_2_ce0,
  output        cl_rg_1_2_we0,
  output [11:0] cl_rg_1_2_addr1,
  output [63:0] cl_rg_1_2_d1,
  input  [63:0] cl_rg_1_2_q1,
  output        cl_rg_1_2_ce1,
  output        cl_rg_1_2_we1,

  output [11:0] cl_rg_1_3_addr0,
  output [63:0] cl_rg_1_3_d0,
  input  [63:0] cl_rg_1_3_q0,
  output        cl_rg_1_3_ce0,
  output        cl_rg_1_3_we0,
  output [11:0] cl_rg_1_3_addr1,
  output [63:0] cl_rg_1_3_d1,
  input  [63:0] cl_rg_1_3_q1,
  output        cl_rg_1_3_ce1,
  output        cl_rg_1_3_we1,

  output [11:0] cl_rg_2_0_addr0,
  output [63:0] cl_rg_2_0_d0,
  input  [63:0] cl_rg_2_0_q0,
  output        cl_rg_2_0_ce0,
  output        cl_rg_2_0_we0,
  output [11:0] cl_rg_2_0_addr1,
  output [63:0] cl_rg_2_0_d1,
  input  [63:0] cl_rg_2_0_q1,
  output        cl_rg_2_0_ce1,
  output        cl_rg_2_0_we1,

  output [11:0] cl_rg_2_1_addr0,
  output [63:0] cl_rg_2_1_d0,
  input  [63:0] cl_rg_2_1_q0,
  output        cl_rg_2_1_ce0,
  output        cl_rg_2_1_we0,
  output [11:0] cl_rg_2_1_addr1,
  output [63:0] cl_rg_2_1_d1,
  input  [63:0] cl_rg_2_1_q1,
  output        cl_rg_2_1_ce1,
  output        cl_rg_2_1_we1,

  output [11:0] cl_rg_2_2_addr0,
  output [63:0] cl_rg_2_2_d0,
  input  [63:0] cl_rg_2_2_q0,
  output        cl_rg_2_2_ce0,
  output        cl_rg_2_2_we0,
  output [11:0] cl_rg_2_2_addr1,
  output [63:0] cl_rg_2_2_d1,
  input  [63:0] cl_rg_2_2_q1,
  output        cl_rg_2_2_ce1,
  output        cl_rg_2_2_we1,

  output [11:0] cl_rg_2_3_addr0,
  output [63:0] cl_rg_2_3_d0,
  input  [63:0] cl_rg_2_3_q0,
  output        cl_rg_2_3_ce0,
  output        cl_rg_2_3_we0,
  output [11:0] cl_rg_2_3_addr1,
  output [63:0] cl_rg_2_3_d1,
  input  [63:0] cl_rg_2_3_q1,
  output        cl_rg_2_3_ce1,
  output        cl_rg_2_3_we1,

  output [11:0] cl_rg_3_0_addr0,
  output [63:0] cl_rg_3_0_d0,
  input  [63:0] cl_rg_3_0_q0,
  output        cl_rg_3_0_ce0,
  output        cl_rg_3_0_we0,
  output [11:0] cl_rg_3_0_addr1,
  output [63:0] cl_rg_3_0_d1,
  input  [63:0] cl_rg_3_0_q1,
  output        cl_rg_3_0_ce1,
  output        cl_rg_3_0_we1,

  output [11:0] cl_rg_3_1_addr0,
  output [63:0] cl_rg_3_1_d0,
  input  [63:0] cl_rg_3_1_q0,
  output        cl_rg_3_1_ce0,
  output        cl_rg_3_1_we0,
  output [11:0] cl_rg_3_1_addr1,
  output [63:0] cl_rg_3_1_d1,
  input  [63:0] cl_rg_3_1_q1,
  output        cl_rg_3_1_ce1,
  output        cl_rg_3_1_we1,

  output [11:0] cl_rg_3_2_addr0,
  output [63:0] cl_rg_3_2_d0,
  input  [63:0] cl_rg_3_2_q0,
  output        cl_rg_3_2_ce0,
  output        cl_rg_3_2_we0,
  output [11:0] cl_rg_3_2_addr1,
  output [63:0] cl_rg_3_2_d1,
  input  [63:0] cl_rg_3_2_q1,
  output        cl_rg_3_2_ce1,
  output        cl_rg_3_2_we1,

  output [11:0] cl_rg_3_3_addr0,
  output [63:0] cl_rg_3_3_d0,
  input  [63:0] cl_rg_3_3_q0,
  output        cl_rg_3_3_ce0,
  output        cl_rg_3_3_we0,
  output [11:0] cl_rg_3_3_addr1,
  output [63:0] cl_rg_3_3_d1,
  input  [63:0] cl_rg_3_3_q1,
  output        cl_rg_3_3_ce1,
  output        cl_rg_3_3_we1,

  output [11:0] cl_rg_4_0_addr0,
  output [63:0] cl_rg_4_0_d0,
  input  [63:0] cl_rg_4_0_q0,
  output        cl_rg_4_0_ce0,
  output        cl_rg_4_0_we0,
  output [11:0] cl_rg_4_0_addr1,
  output [63:0] cl_rg_4_0_d1,
  input  [63:0] cl_rg_4_0_q1,
  output        cl_rg_4_0_ce1,
  output        cl_rg_4_0_we1,

  output [11:0] cl_rg_4_1_addr0,
  output [63:0] cl_rg_4_1_d0,
  input  [63:0] cl_rg_4_1_q0,
  output        cl_rg_4_1_ce0,
  output        cl_rg_4_1_we0,
  output [11:0] cl_rg_4_1_addr1,
  output [63:0] cl_rg_4_1_d1,
  input  [63:0] cl_rg_4_1_q1,
  output        cl_rg_4_1_ce1,
  output        cl_rg_4_1_we1,

  output [11:0] cl_rg_4_2_addr0,
  output [63:0] cl_rg_4_2_d0,
  input  [63:0] cl_rg_4_2_q0,
  output        cl_rg_4_2_ce0,
  output        cl_rg_4_2_we0,
  output [11:0] cl_rg_4_2_addr1,
  output [63:0] cl_rg_4_2_d1,
  input  [63:0] cl_rg_4_2_q1,
  output        cl_rg_4_2_ce1,
  output        cl_rg_4_2_we1,

  output [11:0] cl_rg_4_3_addr0,
  output [63:0] cl_rg_4_3_d0,
  input  [63:0] cl_rg_4_3_q0,
  output        cl_rg_4_3_ce0,
  output        cl_rg_4_3_we0,
  output [11:0] cl_rg_4_3_addr1,
  output [63:0] cl_rg_4_3_d1,
  input  [63:0] cl_rg_4_3_q1,
  output        cl_rg_4_3_ce1,
  output        cl_rg_4_3_we1,

  output [11:0] cl_rg_5_0_addr0,
  output [63:0] cl_rg_5_0_d0,
  input  [63:0] cl_rg_5_0_q0,
  output        cl_rg_5_0_ce0,
  output        cl_rg_5_0_we0,
  output [11:0] cl_rg_5_0_addr1,
  output [63:0] cl_rg_5_0_d1,
  input  [63:0] cl_rg_5_0_q1,
  output        cl_rg_5_0_ce1,
  output        cl_rg_5_0_we1,

  output [11:0] cl_rg_5_1_addr0,
  output [63:0] cl_rg_5_1_d0,
  input  [63:0] cl_rg_5_1_q0,
  output        cl_rg_5_1_ce0,
  output        cl_rg_5_1_we0,
  output [11:0] cl_rg_5_1_addr1,
  output [63:0] cl_rg_5_1_d1,
  input  [63:0] cl_rg_5_1_q1,
  output        cl_rg_5_1_ce1,
  output        cl_rg_5_1_we1,

  output [11:0] cl_rg_5_2_addr0,
  output [63:0] cl_rg_5_2_d0,
  input  [63:0] cl_rg_5_2_q0,
  output        cl_rg_5_2_ce0,
  output        cl_rg_5_2_we0,
  output [11:0] cl_rg_5_2_addr1,
  output [63:0] cl_rg_5_2_d1,
  input  [63:0] cl_rg_5_2_q1,
  output        cl_rg_5_2_ce1,
  output        cl_rg_5_2_we1,

  output [11:0] cl_rg_5_3_addr0,
  output [63:0] cl_rg_5_3_d0,
  input  [63:0] cl_rg_5_3_q0,
  output        cl_rg_5_3_ce0,
  output        cl_rg_5_3_we0,
  output [11:0] cl_rg_5_3_addr1,
  output [63:0] cl_rg_5_3_d1,
  input  [63:0] cl_rg_5_3_q1,
  output        cl_rg_5_3_ce1,
  output        cl_rg_5_3_we1,

  output [11:0] cl_rg_6_0_addr0,
  output [63:0] cl_rg_6_0_d0,
  input  [63:0] cl_rg_6_0_q0,
  output        cl_rg_6_0_ce0,
  output        cl_rg_6_0_we0,
  output [11:0] cl_rg_6_0_addr1,
  output [63:0] cl_rg_6_0_d1,
  input  [63:0] cl_rg_6_0_q1,
  output        cl_rg_6_0_ce1,
  output        cl_rg_6_0_we1,

  output [11:0] cl_rg_6_1_addr0,
  output [63:0] cl_rg_6_1_d0,
  input  [63:0] cl_rg_6_1_q0,
  output        cl_rg_6_1_ce0,
  output        cl_rg_6_1_we0,
  output [11:0] cl_rg_6_1_addr1,
  output [63:0] cl_rg_6_1_d1,
  input  [63:0] cl_rg_6_1_q1,
  output        cl_rg_6_1_ce1,
  output        cl_rg_6_1_we1,

  output [11:0] cl_rg_6_2_addr0,
  output [63:0] cl_rg_6_2_d0,
  input  [63:0] cl_rg_6_2_q0,
  output        cl_rg_6_2_ce0,
  output        cl_rg_6_2_we0,
  output [11:0] cl_rg_6_2_addr1,
  output [63:0] cl_rg_6_2_d1,
  input  [63:0] cl_rg_6_2_q1,
  output        cl_rg_6_2_ce1,
  output        cl_rg_6_2_we1,

  output [11:0] cl_rg_6_3_addr0,
  output [63:0] cl_rg_6_3_d0,
  input  [63:0] cl_rg_6_3_q0,
  output        cl_rg_6_3_ce0,
  output        cl_rg_6_3_we0,
  output [11:0] cl_rg_6_3_addr1,
  output [63:0] cl_rg_6_3_d1,
  input  [63:0] cl_rg_6_3_q1,
  output        cl_rg_6_3_ce1,
  output        cl_rg_6_3_we1,

  output [11:0] cl_rg_7_0_addr0,
  output [63:0] cl_rg_7_0_d0,
  input  [63:0] cl_rg_7_0_q0,
  output        cl_rg_7_0_ce0,
  output        cl_rg_7_0_we0,
  output [11:0] cl_rg_7_0_addr1,
  output [63:0] cl_rg_7_0_d1,
  input  [63:0] cl_rg_7_0_q1,
  output        cl_rg_7_0_ce1,
  output        cl_rg_7_0_we1,

  output [11:0] cl_rg_7_1_addr0,
  output [63:0] cl_rg_7_1_d0,
  input  [63:0] cl_rg_7_1_q0,
  output        cl_rg_7_1_ce0,
  output        cl_rg_7_1_we0,
  output [11:0] cl_rg_7_1_addr1,
  output [63:0] cl_rg_7_1_d1,
  input  [63:0] cl_rg_7_1_q1,
  output        cl_rg_7_1_ce1,
  output        cl_rg_7_1_we1,

  output [11:0] cl_rg_7_2_addr0,
  output [63:0] cl_rg_7_2_d0,
  input  [63:0] cl_rg_7_2_q0,
  output        cl_rg_7_2_ce0,
  output        cl_rg_7_2_we0,
  output [11:0] cl_rg_7_2_addr1,
  output [63:0] cl_rg_7_2_d1,
  input  [63:0] cl_rg_7_2_q1,
  output        cl_rg_7_2_ce1,
  output        cl_rg_7_2_we1,

  output [11:0] cl_rg_7_3_addr0,
  output [63:0] cl_rg_7_3_d0,
  input  [63:0] cl_rg_7_3_q0,
  output        cl_rg_7_3_ce0,
  output        cl_rg_7_3_we0,
  output [11:0] cl_rg_7_3_addr1,
  output [63:0] cl_rg_7_3_d1,
  input  [63:0] cl_rg_7_3_q1,
  output        cl_rg_7_3_ce1,
  output        cl_rg_7_3_we1,

  output [11:0] cl_rg_8_0_addr0,
  output [63:0] cl_rg_8_0_d0,
  input  [63:0] cl_rg_8_0_q0,
  output        cl_rg_8_0_ce0,
  output        cl_rg_8_0_we0,
  output [11:0] cl_rg_8_0_addr1,
  output [63:0] cl_rg_8_0_d1,
  input  [63:0] cl_rg_8_0_q1,
  output        cl_rg_8_0_ce1,
  output        cl_rg_8_0_we1,

  output [11:0] cl_rg_8_1_addr0,
  output [63:0] cl_rg_8_1_d0,
  input  [63:0] cl_rg_8_1_q0,
  output        cl_rg_8_1_ce0,
  output        cl_rg_8_1_we0,
  output [11:0] cl_rg_8_1_addr1,
  output [63:0] cl_rg_8_1_d1,
  input  [63:0] cl_rg_8_1_q1,
  output        cl_rg_8_1_ce1,
  output        cl_rg_8_1_we1,

  output [11:0] cl_rg_8_2_addr0,
  output [63:0] cl_rg_8_2_d0,
  input  [63:0] cl_rg_8_2_q0,
  output        cl_rg_8_2_ce0,
  output        cl_rg_8_2_we0,
  output [11:0] cl_rg_8_2_addr1,
  output [63:0] cl_rg_8_2_d1,
  input  [63:0] cl_rg_8_2_q1,
  output        cl_rg_8_2_ce1,
  output        cl_rg_8_2_we1,

  output [11:0] cl_rg_8_3_addr0,
  output [63:0] cl_rg_8_3_d0,
  input  [63:0] cl_rg_8_3_q0,
  output        cl_rg_8_3_ce0,
  output        cl_rg_8_3_we0,
  output [11:0] cl_rg_8_3_addr1,
  output [63:0] cl_rg_8_3_d1,
  input  [63:0] cl_rg_8_3_q1,
  output        cl_rg_8_3_ce1,
  output        cl_rg_8_3_we1,

  output [11:0] cl_rg_9_0_addr0,
  output [63:0] cl_rg_9_0_d0,
  input  [63:0] cl_rg_9_0_q0,
  output        cl_rg_9_0_ce0,
  output        cl_rg_9_0_we0,
  output [11:0] cl_rg_9_0_addr1,
  output [63:0] cl_rg_9_0_d1,
  input  [63:0] cl_rg_9_0_q1,
  output        cl_rg_9_0_ce1,
  output        cl_rg_9_0_we1,

  output [11:0] cl_rg_9_1_addr0,
  output [63:0] cl_rg_9_1_d0,
  input  [63:0] cl_rg_9_1_q0,
  output        cl_rg_9_1_ce0,
  output        cl_rg_9_1_we0,
  output [11:0] cl_rg_9_1_addr1,
  output [63:0] cl_rg_9_1_d1,
  input  [63:0] cl_rg_9_1_q1,
  output        cl_rg_9_1_ce1,
  output        cl_rg_9_1_we1,

  output [11:0] cl_rg_9_2_addr0,
  output [63:0] cl_rg_9_2_d0,
  input  [63:0] cl_rg_9_2_q0,
  output        cl_rg_9_2_ce0,
  output        cl_rg_9_2_we0,
  output [11:0] cl_rg_9_2_addr1,
  output [63:0] cl_rg_9_2_d1,
  input  [63:0] cl_rg_9_2_q1,
  output        cl_rg_9_2_ce1,
  output        cl_rg_9_2_we1,

  output [11:0] cl_rg_9_3_addr0,
  output [63:0] cl_rg_9_3_d0,
  input  [63:0] cl_rg_9_3_q0,
  output        cl_rg_9_3_ce0,
  output        cl_rg_9_3_we0,
  output [11:0] cl_rg_9_3_addr1,
  output [63:0] cl_rg_9_3_d1,
  input  [63:0] cl_rg_9_3_q1,
  output        cl_rg_9_3_ce1,
  output        cl_rg_9_3_we1,

  output [11:0] cl_rg_10_0_addr0,
  output [63:0] cl_rg_10_0_d0,
  input  [63:0] cl_rg_10_0_q0,
  output        cl_rg_10_0_ce0,
  output        cl_rg_10_0_we0,
  output [11:0] cl_rg_10_0_addr1,
  output [63:0] cl_rg_10_0_d1,
  input  [63:0] cl_rg_10_0_q1,
  output        cl_rg_10_0_ce1,
  output        cl_rg_10_0_we1,

  output [11:0] cl_rg_10_1_addr0,
  output [63:0] cl_rg_10_1_d0,
  input  [63:0] cl_rg_10_1_q0,
  output        cl_rg_10_1_ce0,
  output        cl_rg_10_1_we0,
  output [11:0] cl_rg_10_1_addr1,
  output [63:0] cl_rg_10_1_d1,
  input  [63:0] cl_rg_10_1_q1,
  output        cl_rg_10_1_ce1,
  output        cl_rg_10_1_we1,

  output [11:0] cl_rg_10_2_addr0,
  output [63:0] cl_rg_10_2_d0,
  input  [63:0] cl_rg_10_2_q0,
  output        cl_rg_10_2_ce0,
  output        cl_rg_10_2_we0,
  output [11:0] cl_rg_10_2_addr1,
  output [63:0] cl_rg_10_2_d1,
  input  [63:0] cl_rg_10_2_q1,
  output        cl_rg_10_2_ce1,
  output        cl_rg_10_2_we1,

  output [11:0] cl_rg_10_3_addr0,
  output [63:0] cl_rg_10_3_d0,
  input  [63:0] cl_rg_10_3_q0,
  output        cl_rg_10_3_ce0,
  output        cl_rg_10_3_we0,
  output [11:0] cl_rg_10_3_addr1,
  output [63:0] cl_rg_10_3_d1,
  input  [63:0] cl_rg_10_3_q1,
  output        cl_rg_10_3_ce1,
  output        cl_rg_10_3_we1,

  output [11:0] cl_rg_11_0_addr0,
  output [63:0] cl_rg_11_0_d0,
  input  [63:0] cl_rg_11_0_q0,
  output        cl_rg_11_0_ce0,
  output        cl_rg_11_0_we0,
  output [11:0] cl_rg_11_0_addr1,
  output [63:0] cl_rg_11_0_d1,
  input  [63:0] cl_rg_11_0_q1,
  output        cl_rg_11_0_ce1,
  output        cl_rg_11_0_we1,

  output [11:0] cl_rg_11_1_addr0,
  output [63:0] cl_rg_11_1_d0,
  input  [63:0] cl_rg_11_1_q0,
  output        cl_rg_11_1_ce0,
  output        cl_rg_11_1_we0,
  output [11:0] cl_rg_11_1_addr1,
  output [63:0] cl_rg_11_1_d1,
  input  [63:0] cl_rg_11_1_q1,
  output        cl_rg_11_1_ce1,
  output        cl_rg_11_1_we1,

  output [11:0] cl_rg_11_2_addr0,
  output [63:0] cl_rg_11_2_d0,
  input  [63:0] cl_rg_11_2_q0,
  output        cl_rg_11_2_ce0,
  output        cl_rg_11_2_we0,
  output [11:0] cl_rg_11_2_addr1,
  output [63:0] cl_rg_11_2_d1,
  input  [63:0] cl_rg_11_2_q1,
  output        cl_rg_11_2_ce1,
  output        cl_rg_11_2_we1,

  output [11:0] cl_rg_11_3_addr0,
  output [63:0] cl_rg_11_3_d0,
  input  [63:0] cl_rg_11_3_q0,
  output        cl_rg_11_3_ce0,
  output        cl_rg_11_3_we0,
  output [11:0] cl_rg_11_3_addr1,
  output [63:0] cl_rg_11_3_d1,
  input  [63:0] cl_rg_11_3_q1,
  output        cl_rg_11_3_ce1,
  output        cl_rg_11_3_we1,

  output [11:0] cl_rg_12_0_addr0,
  output [63:0] cl_rg_12_0_d0,
  input  [63:0] cl_rg_12_0_q0,
  output        cl_rg_12_0_ce0,
  output        cl_rg_12_0_we0,
  output [11:0] cl_rg_12_0_addr1,
  output [63:0] cl_rg_12_0_d1,
  input  [63:0] cl_rg_12_0_q1,
  output        cl_rg_12_0_ce1,
  output        cl_rg_12_0_we1,

  output [11:0] cl_rg_12_1_addr0,
  output [63:0] cl_rg_12_1_d0,
  input  [63:0] cl_rg_12_1_q0,
  output        cl_rg_12_1_ce0,
  output        cl_rg_12_1_we0,
  output [11:0] cl_rg_12_1_addr1,
  output [63:0] cl_rg_12_1_d1,
  input  [63:0] cl_rg_12_1_q1,
  output        cl_rg_12_1_ce1,
  output        cl_rg_12_1_we1,

  output [11:0] cl_rg_12_2_addr0,
  output [63:0] cl_rg_12_2_d0,
  input  [63:0] cl_rg_12_2_q0,
  output        cl_rg_12_2_ce0,
  output        cl_rg_12_2_we0,
  output [11:0] cl_rg_12_2_addr1,
  output [63:0] cl_rg_12_2_d1,
  input  [63:0] cl_rg_12_2_q1,
  output        cl_rg_12_2_ce1,
  output        cl_rg_12_2_we1,

  output [11:0] cl_rg_12_3_addr0,
  output [63:0] cl_rg_12_3_d0,
  input  [63:0] cl_rg_12_3_q0,
  output        cl_rg_12_3_ce0,
  output        cl_rg_12_3_we0,
  output [11:0] cl_rg_12_3_addr1,
  output [63:0] cl_rg_12_3_d1,
  input  [63:0] cl_rg_12_3_q1,
  output        cl_rg_12_3_ce1,
  output        cl_rg_12_3_we1,

  output [11:0] cl_rg_13_0_addr0,
  output [63:0] cl_rg_13_0_d0,
  input  [63:0] cl_rg_13_0_q0,
  output        cl_rg_13_0_ce0,
  output        cl_rg_13_0_we0,
  output [11:0] cl_rg_13_0_addr1,
  output [63:0] cl_rg_13_0_d1,
  input  [63:0] cl_rg_13_0_q1,
  output        cl_rg_13_0_ce1,
  output        cl_rg_13_0_we1,

  output [11:0] cl_rg_13_1_addr0,
  output [63:0] cl_rg_13_1_d0,
  input  [63:0] cl_rg_13_1_q0,
  output        cl_rg_13_1_ce0,
  output        cl_rg_13_1_we0,
  output [11:0] cl_rg_13_1_addr1,
  output [63:0] cl_rg_13_1_d1,
  input  [63:0] cl_rg_13_1_q1,
  output        cl_rg_13_1_ce1,
  output        cl_rg_13_1_we1,

  output [11:0] cl_rg_13_2_addr0,
  output [63:0] cl_rg_13_2_d0,
  input  [63:0] cl_rg_13_2_q0,
  output        cl_rg_13_2_ce0,
  output        cl_rg_13_2_we0,
  output [11:0] cl_rg_13_2_addr1,
  output [63:0] cl_rg_13_2_d1,
  input  [63:0] cl_rg_13_2_q1,
  output        cl_rg_13_2_ce1,
  output        cl_rg_13_2_we1,

  output [11:0] cl_rg_13_3_addr0,
  output [63:0] cl_rg_13_3_d0,
  input  [63:0] cl_rg_13_3_q0,
  output        cl_rg_13_3_ce0,
  output        cl_rg_13_3_we0,
  output [11:0] cl_rg_13_3_addr1,
  output [63:0] cl_rg_13_3_d1,
  input  [63:0] cl_rg_13_3_q1,
  output        cl_rg_13_3_ce1,
  output        cl_rg_13_3_we1,

  output [11:0] cl_rg_14_0_addr0,
  output [63:0] cl_rg_14_0_d0,
  input  [63:0] cl_rg_14_0_q0,
  output        cl_rg_14_0_ce0,
  output        cl_rg_14_0_we0,
  output [11:0] cl_rg_14_0_addr1,
  output [63:0] cl_rg_14_0_d1,
  input  [63:0] cl_rg_14_0_q1,
  output        cl_rg_14_0_ce1,
  output        cl_rg_14_0_we1,

  output [11:0] cl_rg_14_1_addr0,
  output [63:0] cl_rg_14_1_d0,
  input  [63:0] cl_rg_14_1_q0,
  output        cl_rg_14_1_ce0,
  output        cl_rg_14_1_we0,
  output [11:0] cl_rg_14_1_addr1,
  output [63:0] cl_rg_14_1_d1,
  input  [63:0] cl_rg_14_1_q1,
  output        cl_rg_14_1_ce1,
  output        cl_rg_14_1_we1,

  output [11:0] cl_rg_14_2_addr0,
  output [63:0] cl_rg_14_2_d0,
  input  [63:0] cl_rg_14_2_q0,
  output        cl_rg_14_2_ce0,
  output        cl_rg_14_2_we0,
  output [11:0] cl_rg_14_2_addr1,
  output [63:0] cl_rg_14_2_d1,
  input  [63:0] cl_rg_14_2_q1,
  output        cl_rg_14_2_ce1,
  output        cl_rg_14_2_we1,

  output [11:0] cl_rg_14_3_addr0,
  output [63:0] cl_rg_14_3_d0,
  input  [63:0] cl_rg_14_3_q0,
  output        cl_rg_14_3_ce0,
  output        cl_rg_14_3_we0,
  output [11:0] cl_rg_14_3_addr1,
  output [63:0] cl_rg_14_3_d1,
  input  [63:0] cl_rg_14_3_q1,
  output        cl_rg_14_3_ce1,
  output        cl_rg_14_3_we1,

  output [11:0] cl_rg_15_0_addr0,
  output [63:0] cl_rg_15_0_d0,
  input  [63:0] cl_rg_15_0_q0,
  output        cl_rg_15_0_ce0,
  output        cl_rg_15_0_we0,
  output [11:0] cl_rg_15_0_addr1,
  output [63:0] cl_rg_15_0_d1,
  input  [63:0] cl_rg_15_0_q1,
  output        cl_rg_15_0_ce1,
  output        cl_rg_15_0_we1,

  output [11:0] cl_rg_15_1_addr0,
  output [63:0] cl_rg_15_1_d0,
  input  [63:0] cl_rg_15_1_q0,
  output        cl_rg_15_1_ce0,
  output        cl_rg_15_1_we0,
  output [11:0] cl_rg_15_1_addr1,
  output [63:0] cl_rg_15_1_d1,
  input  [63:0] cl_rg_15_1_q1,
  output        cl_rg_15_1_ce1,
  output        cl_rg_15_1_we1,

  output [11:0] cl_rg_15_2_addr0,
  output [63:0] cl_rg_15_2_d0,
  input  [63:0] cl_rg_15_2_q0,
  output        cl_rg_15_2_ce0,
  output        cl_rg_15_2_we0,
  output [11:0] cl_rg_15_2_addr1,
  output [63:0] cl_rg_15_2_d1,
  input  [63:0] cl_rg_15_2_q1,
  output        cl_rg_15_2_ce1,
  output        cl_rg_15_2_we1,

  output [11:0] cl_rg_15_3_addr0,
  output [63:0] cl_rg_15_3_d0,
  input  [63:0] cl_rg_15_3_q0,
  output        cl_rg_15_3_ce0,
  output        cl_rg_15_3_we0,
  output [11:0] cl_rg_15_3_addr1,
  output [63:0] cl_rg_15_3_d1,
  input  [63:0] cl_rg_15_3_q1,
  output        cl_rg_15_3_ce1,
  output        cl_rg_15_3_we1,

  output [11:0] cl_rg_16_0_addr0,
  output [63:0] cl_rg_16_0_d0,
  input  [63:0] cl_rg_16_0_q0,
  output        cl_rg_16_0_ce0,
  output        cl_rg_16_0_we0,
  output [11:0] cl_rg_16_0_addr1,
  output [63:0] cl_rg_16_0_d1,
  input  [63:0] cl_rg_16_0_q1,
  output        cl_rg_16_0_ce1,
  output        cl_rg_16_0_we1,

  output [11:0] cl_rg_16_1_addr0,
  output [63:0] cl_rg_16_1_d0,
  input  [63:0] cl_rg_16_1_q0,
  output        cl_rg_16_1_ce0,
  output        cl_rg_16_1_we0,
  output [11:0] cl_rg_16_1_addr1,
  output [63:0] cl_rg_16_1_d1,
  input  [63:0] cl_rg_16_1_q1,
  output        cl_rg_16_1_ce1,
  output        cl_rg_16_1_we1,

  output [11:0] cl_rg_16_2_addr0,
  output [63:0] cl_rg_16_2_d0,
  input  [63:0] cl_rg_16_2_q0,
  output        cl_rg_16_2_ce0,
  output        cl_rg_16_2_we0,
  output [11:0] cl_rg_16_2_addr1,
  output [63:0] cl_rg_16_2_d1,
  input  [63:0] cl_rg_16_2_q1,
  output        cl_rg_16_2_ce1,
  output        cl_rg_16_2_we1,

  output [11:0] cl_rg_16_3_addr0,
  output [63:0] cl_rg_16_3_d0,
  input  [63:0] cl_rg_16_3_q0,
  output        cl_rg_16_3_ce0,
  output        cl_rg_16_3_we0,
  output [11:0] cl_rg_16_3_addr1,
  output [63:0] cl_rg_16_3_d1,
  input  [63:0] cl_rg_16_3_q1,
  output        cl_rg_16_3_ce1,
  output        cl_rg_16_3_we1,

  output [11:0] cl_rg_17_0_addr0,
  output [63:0] cl_rg_17_0_d0,
  input  [63:0] cl_rg_17_0_q0,
  output        cl_rg_17_0_ce0,
  output        cl_rg_17_0_we0,
  output [11:0] cl_rg_17_0_addr1,
  output [63:0] cl_rg_17_0_d1,
  input  [63:0] cl_rg_17_0_q1,
  output        cl_rg_17_0_ce1,
  output        cl_rg_17_0_we1,

  output [11:0] cl_rg_17_1_addr0,
  output [63:0] cl_rg_17_1_d0,
  input  [63:0] cl_rg_17_1_q0,
  output        cl_rg_17_1_ce0,
  output        cl_rg_17_1_we0,
  output [11:0] cl_rg_17_1_addr1,
  output [63:0] cl_rg_17_1_d1,
  input  [63:0] cl_rg_17_1_q1,
  output        cl_rg_17_1_ce1,
  output        cl_rg_17_1_we1,

  output [11:0] cl_rg_17_2_addr0,
  output [63:0] cl_rg_17_2_d0,
  input  [63:0] cl_rg_17_2_q0,
  output        cl_rg_17_2_ce0,
  output        cl_rg_17_2_we0,
  output [11:0] cl_rg_17_2_addr1,
  output [63:0] cl_rg_17_2_d1,
  input  [63:0] cl_rg_17_2_q1,
  output        cl_rg_17_2_ce1,
  output        cl_rg_17_2_we1,

  output [11:0] cl_rg_17_3_addr0,
  output [63:0] cl_rg_17_3_d0,
  input  [63:0] cl_rg_17_3_q0,
  output        cl_rg_17_3_ce0,
  output        cl_rg_17_3_we0,
  output [11:0] cl_rg_17_3_addr1,
  output [63:0] cl_rg_17_3_d1,
  input  [63:0] cl_rg_17_3_q1,
  output        cl_rg_17_3_ce1,
  output        cl_rg_17_3_we1,

  output [11:0] cl_rg_18_0_addr0,
  output [63:0] cl_rg_18_0_d0,
  input  [63:0] cl_rg_18_0_q0,
  output        cl_rg_18_0_ce0,
  output        cl_rg_18_0_we0,
  output [11:0] cl_rg_18_0_addr1,
  output [63:0] cl_rg_18_0_d1,
  input  [63:0] cl_rg_18_0_q1,
  output        cl_rg_18_0_ce1,
  output        cl_rg_18_0_we1,

  output [11:0] cl_rg_18_1_addr0,
  output [63:0] cl_rg_18_1_d0,
  input  [63:0] cl_rg_18_1_q0,
  output        cl_rg_18_1_ce0,
  output        cl_rg_18_1_we0,
  output [11:0] cl_rg_18_1_addr1,
  output [63:0] cl_rg_18_1_d1,
  input  [63:0] cl_rg_18_1_q1,
  output        cl_rg_18_1_ce1,
  output        cl_rg_18_1_we1,

  output [11:0] cl_rg_18_2_addr0,
  output [63:0] cl_rg_18_2_d0,
  input  [63:0] cl_rg_18_2_q0,
  output        cl_rg_18_2_ce0,
  output        cl_rg_18_2_we0,
  output [11:0] cl_rg_18_2_addr1,
  output [63:0] cl_rg_18_2_d1,
  input  [63:0] cl_rg_18_2_q1,
  output        cl_rg_18_2_ce1,
  output        cl_rg_18_2_we1,

  output [11:0] cl_rg_18_3_addr0,
  output [63:0] cl_rg_18_3_d0,
  input  [63:0] cl_rg_18_3_q0,
  output        cl_rg_18_3_ce0,
  output        cl_rg_18_3_we0,
  output [11:0] cl_rg_18_3_addr1,
  output [63:0] cl_rg_18_3_d1,
  input  [63:0] cl_rg_18_3_q1,
  output        cl_rg_18_3_ce1,
  output        cl_rg_18_3_we1,

  output [11:0] cl_rg_19_0_addr0,
  output [63:0] cl_rg_19_0_d0,
  input  [63:0] cl_rg_19_0_q0,
  output        cl_rg_19_0_ce0,
  output        cl_rg_19_0_we0,
  output [11:0] cl_rg_19_0_addr1,
  output [63:0] cl_rg_19_0_d1,
  input  [63:0] cl_rg_19_0_q1,
  output        cl_rg_19_0_ce1,
  output        cl_rg_19_0_we1,

  output [11:0] cl_rg_19_1_addr0,
  output [63:0] cl_rg_19_1_d0,
  input  [63:0] cl_rg_19_1_q0,
  output        cl_rg_19_1_ce0,
  output        cl_rg_19_1_we0,
  output [11:0] cl_rg_19_1_addr1,
  output [63:0] cl_rg_19_1_d1,
  input  [63:0] cl_rg_19_1_q1,
  output        cl_rg_19_1_ce1,
  output        cl_rg_19_1_we1,

  output [11:0] cl_rg_19_2_addr0,
  output [63:0] cl_rg_19_2_d0,
  input  [63:0] cl_rg_19_2_q0,
  output        cl_rg_19_2_ce0,
  output        cl_rg_19_2_we0,
  output [11:0] cl_rg_19_2_addr1,
  output [63:0] cl_rg_19_2_d1,
  input  [63:0] cl_rg_19_2_q1,
  output        cl_rg_19_2_ce1,
  output        cl_rg_19_2_we1,

  output [11:0] cl_rg_19_3_addr0,
  output [63:0] cl_rg_19_3_d0,
  input  [63:0] cl_rg_19_3_q0,
  output        cl_rg_19_3_ce0,
  output        cl_rg_19_3_we0,
  output [11:0] cl_rg_19_3_addr1,
  output [63:0] cl_rg_19_3_d1,
  input  [63:0] cl_rg_19_3_q1,
  output        cl_rg_19_3_ce1,
  output        cl_rg_19_3_we1,

  output [11:0] cl_rg_20_0_addr0,
  output [63:0] cl_rg_20_0_d0,
  input  [63:0] cl_rg_20_0_q0,
  output        cl_rg_20_0_ce0,
  output        cl_rg_20_0_we0,
  output [11:0] cl_rg_20_0_addr1,
  output [63:0] cl_rg_20_0_d1,
  input  [63:0] cl_rg_20_0_q1,
  output        cl_rg_20_0_ce1,
  output        cl_rg_20_0_we1,

  output [11:0] cl_rg_20_1_addr0,
  output [63:0] cl_rg_20_1_d0,
  input  [63:0] cl_rg_20_1_q0,
  output        cl_rg_20_1_ce0,
  output        cl_rg_20_1_we0,
  output [11:0] cl_rg_20_1_addr1,
  output [63:0] cl_rg_20_1_d1,
  input  [63:0] cl_rg_20_1_q1,
  output        cl_rg_20_1_ce1,
  output        cl_rg_20_1_we1,

  output [11:0] cl_rg_20_2_addr0,
  output [63:0] cl_rg_20_2_d0,
  input  [63:0] cl_rg_20_2_q0,
  output        cl_rg_20_2_ce0,
  output        cl_rg_20_2_we0,
  output [11:0] cl_rg_20_2_addr1,
  output [63:0] cl_rg_20_2_d1,
  input  [63:0] cl_rg_20_2_q1,
  output        cl_rg_20_2_ce1,
  output        cl_rg_20_2_we1,

  output [11:0] cl_rg_20_3_addr0,
  output [63:0] cl_rg_20_3_d0,
  input  [63:0] cl_rg_20_3_q0,
  output        cl_rg_20_3_ce0,
  output        cl_rg_20_3_we0,
  output [11:0] cl_rg_20_3_addr1,
  output [63:0] cl_rg_20_3_d1,
  input  [63:0] cl_rg_20_3_q1,
  output        cl_rg_20_3_ce1,
  output        cl_rg_20_3_we1,

`ifndef NO_AXIS
  output [256-1:0]   m_axis_tdata,
  output             m_axis_tvalid,
  input              m_axis_tready,
  output             m_axis_tlast,
  output [256/8-1:0] m_axis_tkeep,
  output [256/8-1:0] m_axis_tstrb,
  output [1-1:0]     m_axis_tdest,

  input [256-1:0]   s_axis_tdata,
  input             s_axis_tvalid,
  output            s_axis_tready,
  input             s_axis_tlast,
  input [256/8-1:0] s_axis_tkeep,
  input [256/8-1:0] s_axis_tstrb,
  input [1-1:0]     s_axis_tdest,
`endif

  output        cl_done,
  input  [11:0] cl_ctrl_addr,
  input  [31:0] cl_ctrl_d,
  output [31:0] cl_ctrl_q,
  input         cl_ctrl_ce,
  input         cl_ctrl_we,

  input clk,
  input rst
);
  wire [12-1:0] cl_spmv_local_val00_address0;
  wire [1-1:0] cl_spmv_local_val00_ce0;
  wire [64-1:0] cl_spmv_local_val00_q0;
  wire [12-1:0] cl_spmv_local_val10_address0;
  wire [1-1:0] cl_spmv_local_val10_ce0;
  wire [64-1:0] cl_spmv_local_val10_q0;
  wire [12-1:0] cl_spmv_local_val20_address0;
  wire [1-1:0] cl_spmv_local_val20_ce0;
  wire [64-1:0] cl_spmv_local_val20_q0;
  wire [12-1:0] cl_spmv_local_val30_address0;
  wire [1-1:0] cl_spmv_local_val30_ce0;
  wire [64-1:0] cl_spmv_local_val30_q0;
  wire [12-1:0] cl_spmv_local_ind00_address0;
  wire [1-1:0] cl_spmv_local_ind00_ce0;
  wire [64-1:0] cl_spmv_local_ind00_q0;
  wire [12-1:0] cl_spmv_local_ind10_address0;
  wire [1-1:0] cl_spmv_local_ind10_ce0;
  wire [64-1:0] cl_spmv_local_ind10_q0;
  wire [12-1:0] cl_spmv_local_ind20_address0;
  wire [1-1:0] cl_spmv_local_ind20_ce0;
  wire [64-1:0] cl_spmv_local_ind20_q0;
  wire [12-1:0] cl_spmv_local_ind30_address0;
  wire [1-1:0] cl_spmv_local_ind30_ce0;
  wire [64-1:0] cl_spmv_local_ind30_q0;
  wire [10-1:0] cl_spmv_local_x00_address0;
  wire [1-1:0] cl_spmv_local_x00_ce0;
  wire [64-1:0] cl_spmv_local_x00_q0;
  wire [10-1:0] cl_spmv_local_x00_address1;
  wire [1-1:0] cl_spmv_local_x00_ce1;
  wire [64-1:0] cl_spmv_local_x00_q1;
  wire [10-1:0] cl_spmv_local_x10_address0;
  wire [1-1:0] cl_spmv_local_x10_ce0;
  wire [64-1:0] cl_spmv_local_x10_q0;
  wire [10-1:0] cl_spmv_local_x10_address1;
  wire [1-1:0] cl_spmv_local_x10_ce1;
  wire [64-1:0] cl_spmv_local_x10_q1;
  wire [10-1:0] cl_spmv_local_x20_address0;
  wire [1-1:0] cl_spmv_local_x20_ce0;
  wire [64-1:0] cl_spmv_local_x20_q0;
  wire [10-1:0] cl_spmv_local_x20_address1;
  wire [1-1:0] cl_spmv_local_x20_ce1;
  wire [64-1:0] cl_spmv_local_x20_q1;
  wire [10-1:0] cl_spmv_local_x30_address0;
  wire [1-1:0] cl_spmv_local_x30_ce0;
  wire [64-1:0] cl_spmv_local_x30_q0;
  wire [10-1:0] cl_spmv_local_x30_address1;
  wire [1-1:0] cl_spmv_local_x30_ce1;
  wire [64-1:0] cl_spmv_local_x30_q1;
  wire [8-1:0] cl_spmv_local_y0_address0;
  wire [1-1:0] cl_spmv_local_y0_ce0;
  wire [1-1:0] cl_spmv_local_y0_we0;
  wire [64-1:0] cl_spmv_local_y0_d0;
  wire [64-1:0] cl_spmv_local_y0_q0;
  wire [8-1:0] cl_spmv_local_y0_address1;
  wire [1-1:0] cl_spmv_local_y0_ce1;
  wire [64-1:0] cl_spmv_local_y0_q1;
  wire [9-1:0] cl_spmv_local_ptr0_address0;
  wire [1-1:0] cl_spmv_local_ptr0_ce0;
  wire [64-1:0] cl_spmv_local_ptr0_q0;
  wire [12-1:0] cl_spmv_local_val01_address0;
  wire [1-1:0] cl_spmv_local_val01_ce0;
  wire [64-1:0] cl_spmv_local_val01_q0;
  wire [12-1:0] cl_spmv_local_val11_address0;
  wire [1-1:0] cl_spmv_local_val11_ce0;
  wire [64-1:0] cl_spmv_local_val11_q0;
  wire [12-1:0] cl_spmv_local_val21_address0;
  wire [1-1:0] cl_spmv_local_val21_ce0;
  wire [64-1:0] cl_spmv_local_val21_q0;
  wire [12-1:0] cl_spmv_local_val31_address0;
  wire [1-1:0] cl_spmv_local_val31_ce0;
  wire [64-1:0] cl_spmv_local_val31_q0;
  wire [12-1:0] cl_spmv_local_ind01_address0;
  wire [1-1:0] cl_spmv_local_ind01_ce0;
  wire [64-1:0] cl_spmv_local_ind01_q0;
  wire [12-1:0] cl_spmv_local_ind11_address0;
  wire [1-1:0] cl_spmv_local_ind11_ce0;
  wire [64-1:0] cl_spmv_local_ind11_q0;
  wire [12-1:0] cl_spmv_local_ind21_address0;
  wire [1-1:0] cl_spmv_local_ind21_ce0;
  wire [64-1:0] cl_spmv_local_ind21_q0;
  wire [12-1:0] cl_spmv_local_ind31_address0;
  wire [1-1:0] cl_spmv_local_ind31_ce0;
  wire [64-1:0] cl_spmv_local_ind31_q0;
  wire [10-1:0] cl_spmv_local_x01_address0;
  wire [1-1:0] cl_spmv_local_x01_ce0;
  wire [64-1:0] cl_spmv_local_x01_q0;
  wire [10-1:0] cl_spmv_local_x01_address1;
  wire [1-1:0] cl_spmv_local_x01_ce1;
  wire [64-1:0] cl_spmv_local_x01_q1;
  wire [10-1:0] cl_spmv_local_x11_address0;
  wire [1-1:0] cl_spmv_local_x11_ce0;
  wire [64-1:0] cl_spmv_local_x11_q0;
  wire [10-1:0] cl_spmv_local_x11_address1;
  wire [1-1:0] cl_spmv_local_x11_ce1;
  wire [64-1:0] cl_spmv_local_x11_q1;
  wire [10-1:0] cl_spmv_local_x21_address0;
  wire [1-1:0] cl_spmv_local_x21_ce0;
  wire [64-1:0] cl_spmv_local_x21_q0;
  wire [10-1:0] cl_spmv_local_x21_address1;
  wire [1-1:0] cl_spmv_local_x21_ce1;
  wire [64-1:0] cl_spmv_local_x21_q1;
  wire [10-1:0] cl_spmv_local_x31_address0;
  wire [1-1:0] cl_spmv_local_x31_ce0;
  wire [64-1:0] cl_spmv_local_x31_q0;
  wire [10-1:0] cl_spmv_local_x31_address1;
  wire [1-1:0] cl_spmv_local_x31_ce1;
  wire [64-1:0] cl_spmv_local_x31_q1;
  wire [8-1:0] cl_spmv_local_y1_address0;
  wire [1-1:0] cl_spmv_local_y1_ce0;
  wire [1-1:0] cl_spmv_local_y1_we0;
  wire [64-1:0] cl_spmv_local_y1_d0;
  wire [64-1:0] cl_spmv_local_y1_q0;
  wire [9-1:0] cl_spmv_local_ptr1_address0;
  wire [1-1:0] cl_spmv_local_ptr1_ce0;
  wire [64-1:0] cl_spmv_local_ptr1_q0;
  wire [8-1:0] cl_spmv_last_ind0_address0;
  wire [1-1:0] cl_spmv_last_ind0_ce0;
  wire [1-1:0] cl_spmv_last_ind0_we0;
  wire [64-1:0] cl_spmv_last_ind0_d0;
  wire [64-1:0] cl_spmv_last_ind0_q0;
  wire [8-1:0] cl_spmv_last_ind1_address0;
  wire [1-1:0] cl_spmv_last_ind1_ce0;
  wire [1-1:0] cl_spmv_last_ind1_we0;
  wire [64-1:0] cl_spmv_last_ind1_d0;
  wire [64-1:0] cl_spmv_last_ind1_q0;
  wire [32-1:0] cl_spmv_n;
  wire [32-1:0] cl_spmv_row_begin;
  wire [32-1:0] cl_spmv_row_end;
  wire [32-1:0] cl_spmv_len1;
  wire [32-1:0] cl_spmv_len2;
  wire [32-1:0] cl_spmv_i;
  wire [32-1:0] cl_spmv_k0;
  wire [32-1:0] cl_spmv_state;
  wire [32-1:0] cl_spmv_pp;
  wire [32-1:0] cl_spmv_k1_i;
  wire [32-1:0] cl_spmv_k1_o;
  wire [1-1:0] cl_spmv_k1_o_ap_vld;
  wire [32-1:0] cl_spmv_k2_i;
  wire [32-1:0] cl_spmv_k2_o;
  wire [1-1:0] cl_spmv_k2_o_ap_vld;
  wire [32-1:0] cl_spmv_maxlen_i;
  wire [32-1:0] cl_spmv_maxlen_o;
  wire [1-1:0] cl_spmv_maxlen_o_ap_vld;
  wire [32-1:0] cl_spmv_cur_ptr_i;
  wire [32-1:0] cl_spmv_cur_ptr_o;
  wire [1-1:0] cl_spmv_cur_ptr_o_ap_vld;
  wire [31:0] cl_ram_sel;
  wire cl_ap_start;
  wire cl_ap_done;
  wire cl_ap_ready;
 cl_spmv custom_logic_inst (
    .local_val00_address0(cl_spmv_local_val00_address0),
    .local_val00_ce0(cl_spmv_local_val00_ce0),
    .local_val00_q0(cl_spmv_local_val00_q0),
    .local_val10_address0(cl_spmv_local_val10_address0),
    .local_val10_ce0(cl_spmv_local_val10_ce0),
    .local_val10_q0(cl_spmv_local_val10_q0),
    .local_val20_address0(cl_spmv_local_val20_address0),
    .local_val20_ce0(cl_spmv_local_val20_ce0),
    .local_val20_q0(cl_spmv_local_val20_q0),
    .local_val30_address0(cl_spmv_local_val30_address0),
    .local_val30_ce0(cl_spmv_local_val30_ce0),
    .local_val30_q0(cl_spmv_local_val30_q0),
    .local_ind00_address0(cl_spmv_local_ind00_address0),
    .local_ind00_ce0(cl_spmv_local_ind00_ce0),
    .local_ind00_q0(cl_spmv_local_ind00_q0),
    .local_ind10_address0(cl_spmv_local_ind10_address0),
    .local_ind10_ce0(cl_spmv_local_ind10_ce0),
    .local_ind10_q0(cl_spmv_local_ind10_q0),
    .local_ind20_address0(cl_spmv_local_ind20_address0),
    .local_ind20_ce0(cl_spmv_local_ind20_ce0),
    .local_ind20_q0(cl_spmv_local_ind20_q0),
    .local_ind30_address0(cl_spmv_local_ind30_address0),
    .local_ind30_ce0(cl_spmv_local_ind30_ce0),
    .local_ind30_q0(cl_spmv_local_ind30_q0),
    .local_x00_address0(cl_spmv_local_x00_address0),
    .local_x00_ce0(cl_spmv_local_x00_ce0),
    .local_x00_q0(cl_spmv_local_x00_q0),
    .local_x00_address1(cl_spmv_local_x00_address1),
    .local_x00_ce1(cl_spmv_local_x00_ce1),
    .local_x00_q1(cl_spmv_local_x00_q1),
    .local_x10_address0(cl_spmv_local_x10_address0),
    .local_x10_ce0(cl_spmv_local_x10_ce0),
    .local_x10_q0(cl_spmv_local_x10_q0),
    .local_x10_address1(cl_spmv_local_x10_address1),
    .local_x10_ce1(cl_spmv_local_x10_ce1),
    .local_x10_q1(cl_spmv_local_x10_q1),
    .local_x20_address0(cl_spmv_local_x20_address0),
    .local_x20_ce0(cl_spmv_local_x20_ce0),
    .local_x20_q0(cl_spmv_local_x20_q0),
    .local_x20_address1(cl_spmv_local_x20_address1),
    .local_x20_ce1(cl_spmv_local_x20_ce1),
    .local_x20_q1(cl_spmv_local_x20_q1),
    .local_x30_address0(cl_spmv_local_x30_address0),
    .local_x30_ce0(cl_spmv_local_x30_ce0),
    .local_x30_q0(cl_spmv_local_x30_q0),
    .local_x30_address1(cl_spmv_local_x30_address1),
    .local_x30_ce1(cl_spmv_local_x30_ce1),
    .local_x30_q1(cl_spmv_local_x30_q1),
    .local_y0_address0(cl_spmv_local_y0_address0),
    .local_y0_ce0(cl_spmv_local_y0_ce0),
    .local_y0_we0(cl_spmv_local_y0_we0),
    .local_y0_d0(cl_spmv_local_y0_d0),
    .local_y0_q0(cl_spmv_local_y0_q0),
    .local_y0_address1(cl_spmv_local_y0_address1),
    .local_y0_ce1(cl_spmv_local_y0_ce1),
    .local_y0_q1(cl_spmv_local_y0_q1),
    .local_ptr0_address0(cl_spmv_local_ptr0_address0),
    .local_ptr0_ce0(cl_spmv_local_ptr0_ce0),
    .local_ptr0_q0(cl_spmv_local_ptr0_q0),
    .local_val01_address0(cl_spmv_local_val01_address0),
    .local_val01_ce0(cl_spmv_local_val01_ce0),
    .local_val01_q0(cl_spmv_local_val01_q0),
    .local_val11_address0(cl_spmv_local_val11_address0),
    .local_val11_ce0(cl_spmv_local_val11_ce0),
    .local_val11_q0(cl_spmv_local_val11_q0),
    .local_val21_address0(cl_spmv_local_val21_address0),
    .local_val21_ce0(cl_spmv_local_val21_ce0),
    .local_val21_q0(cl_spmv_local_val21_q0),
    .local_val31_address0(cl_spmv_local_val31_address0),
    .local_val31_ce0(cl_spmv_local_val31_ce0),
    .local_val31_q0(cl_spmv_local_val31_q0),
    .local_ind01_address0(cl_spmv_local_ind01_address0),
    .local_ind01_ce0(cl_spmv_local_ind01_ce0),
    .local_ind01_q0(cl_spmv_local_ind01_q0),
    .local_ind11_address0(cl_spmv_local_ind11_address0),
    .local_ind11_ce0(cl_spmv_local_ind11_ce0),
    .local_ind11_q0(cl_spmv_local_ind11_q0),
    .local_ind21_address0(cl_spmv_local_ind21_address0),
    .local_ind21_ce0(cl_spmv_local_ind21_ce0),
    .local_ind21_q0(cl_spmv_local_ind21_q0),
    .local_ind31_address0(cl_spmv_local_ind31_address0),
    .local_ind31_ce0(cl_spmv_local_ind31_ce0),
    .local_ind31_q0(cl_spmv_local_ind31_q0),
    .local_x01_address0(cl_spmv_local_x01_address0),
    .local_x01_ce0(cl_spmv_local_x01_ce0),
    .local_x01_q0(cl_spmv_local_x01_q0),
    .local_x01_address1(cl_spmv_local_x01_address1),
    .local_x01_ce1(cl_spmv_local_x01_ce1),
    .local_x01_q1(cl_spmv_local_x01_q1),
    .local_x11_address0(cl_spmv_local_x11_address0),
    .local_x11_ce0(cl_spmv_local_x11_ce0),
    .local_x11_q0(cl_spmv_local_x11_q0),
    .local_x11_address1(cl_spmv_local_x11_address1),
    .local_x11_ce1(cl_spmv_local_x11_ce1),
    .local_x11_q1(cl_spmv_local_x11_q1),
    .local_x21_address0(cl_spmv_local_x21_address0),
    .local_x21_ce0(cl_spmv_local_x21_ce0),
    .local_x21_q0(cl_spmv_local_x21_q0),
    .local_x21_address1(cl_spmv_local_x21_address1),
    .local_x21_ce1(cl_spmv_local_x21_ce1),
    .local_x21_q1(cl_spmv_local_x21_q1),
    .local_x31_address0(cl_spmv_local_x31_address0),
    .local_x31_ce0(cl_spmv_local_x31_ce0),
    .local_x31_q0(cl_spmv_local_x31_q0),
    .local_x31_address1(cl_spmv_local_x31_address1),
    .local_x31_ce1(cl_spmv_local_x31_ce1),
    .local_x31_q1(cl_spmv_local_x31_q1),
    .local_y1_address0(cl_spmv_local_y1_address0),
    .local_y1_ce0(cl_spmv_local_y1_ce0),
    .local_y1_we0(cl_spmv_local_y1_we0),
    .local_y1_d0(cl_spmv_local_y1_d0),
    .local_y1_q0(cl_spmv_local_y1_q0),
    .local_ptr1_address0(cl_spmv_local_ptr1_address0),
    .local_ptr1_ce0(cl_spmv_local_ptr1_ce0),
    .local_ptr1_q0(cl_spmv_local_ptr1_q0),
    .last_ind0_address0(cl_spmv_last_ind0_address0),
    .last_ind0_ce0(cl_spmv_last_ind0_ce0),
    .last_ind0_we0(cl_spmv_last_ind0_we0),
    .last_ind0_d0(cl_spmv_last_ind0_d0),
    .last_ind0_q0(cl_spmv_last_ind0_q0),
    .last_ind1_address0(cl_spmv_last_ind1_address0),
    .last_ind1_ce0(cl_spmv_last_ind1_ce0),
    .last_ind1_we0(cl_spmv_last_ind1_we0),
    .last_ind1_d0(cl_spmv_last_ind1_d0),
    .last_ind1_q0(cl_spmv_last_ind1_q0),
    .n(cl_spmv_n),
    .row_begin(cl_spmv_row_begin),
    .row_end(cl_spmv_row_end),
    .len1(cl_spmv_len1),
    .len2(cl_spmv_len2),
    .i(cl_spmv_i),
    .k0(cl_spmv_k0),
    .state(cl_spmv_state),
    .pp(cl_spmv_pp),
    .k1_i(cl_spmv_k1_i),
    .k1_o(cl_spmv_k1_o),
    .k1_o_ap_vld(cl_spmv_k1_o_ap_vld),
    .k2_i(cl_spmv_k2_i),
    .k2_o(cl_spmv_k2_o),
    .k2_o_ap_vld(cl_spmv_k2_o_ap_vld),
    .maxlen_i(cl_spmv_maxlen_i),
    .maxlen_o(cl_spmv_maxlen_o),
    .maxlen_o_ap_vld(cl_spmv_maxlen_o_ap_vld),
    .cur_ptr_i(cl_spmv_cur_ptr_i),
    .cur_ptr_o(cl_spmv_cur_ptr_o),
    .cur_ptr_o_ap_vld(cl_spmv_cur_ptr_o_ap_vld),

    .ap_start(cl_ap_start),
    .ap_ready(cl_ap_ready),
    .ap_done(cl_ap_done),
    .ap_rst(rst),
    .ap_clk(clk)
  );
  assign cl_ram_sel = cl_spmv_pp;
  assign cl_rg_0_0_addr1 = cl_spmv_local_y0_ce1 ? cl_spmv_local_y0_address1 : 0;
  assign cl_rg_0_1_addr1 = 0;
  assign cl_rg_0_2_addr1 = cl_spmv_local_ptr1_ce0 ? cl_spmv_local_ptr1_address0 : 0;
  assign cl_rg_0_3_addr1 = 0;
  assign cl_rg_1_0_addr1 = cl_ram_sel[0] ? cl_spmv_local_x00_address1 : 0;
  assign cl_rg_1_1_addr1 = cl_ram_sel[0] ? cl_spmv_local_x10_address1 : 0;
  assign cl_rg_1_2_addr1 = cl_ram_sel[0] ? cl_spmv_local_x20_address1 : 0;
  assign cl_rg_1_3_addr1 = cl_ram_sel[0] ? cl_spmv_local_x30_address1 : 0;
  assign cl_rg_2_0_addr1 = cl_ram_sel[1] ? cl_spmv_local_x00_address1 : 0;
  assign cl_rg_2_1_addr1 = cl_ram_sel[1] ? cl_spmv_local_x10_address1 : 0;
  assign cl_rg_2_2_addr1 = cl_ram_sel[1] ? cl_spmv_local_x20_address1 : 0;
  assign cl_rg_2_3_addr1 = cl_ram_sel[1] ? cl_spmv_local_x30_address1 : 0;
  assign cl_rg_3_0_addr1 = cl_ram_sel[0] ? cl_spmv_local_x01_address1 : 0;
  assign cl_rg_3_1_addr1 = cl_ram_sel[0] ? cl_spmv_local_x11_address1 : 0;
  assign cl_rg_3_2_addr1 = cl_ram_sel[0] ? cl_spmv_local_x21_address1 : 0;
  assign cl_rg_3_3_addr1 = cl_ram_sel[0] ? cl_spmv_local_x31_address1 : 0;
  assign cl_rg_4_0_addr1 = cl_ram_sel[1] ? cl_spmv_local_x01_address1 : 0;
  assign cl_rg_4_1_addr1 = cl_ram_sel[1] ? cl_spmv_local_x11_address1 : 0;
  assign cl_rg_4_2_addr1 = cl_ram_sel[1] ? cl_spmv_local_x21_address1 : 0;
  assign cl_rg_4_3_addr1 = cl_ram_sel[1] ? cl_spmv_local_x31_address1 : 0;
  assign cl_rg_5_0_addr1 = 0;
  assign cl_rg_5_1_addr1 = 0;
  assign cl_rg_5_2_addr1 = 0;
  assign cl_rg_5_3_addr1 = 0;
  assign cl_rg_6_0_addr1 = 0;
  assign cl_rg_6_1_addr1 = 0;
  assign cl_rg_6_2_addr1 = 0;
  assign cl_rg_6_3_addr1 = 0;
  assign cl_rg_7_0_addr1 = 0;
  assign cl_rg_7_1_addr1 = 0;
  assign cl_rg_7_2_addr1 = 0;
  assign cl_rg_7_3_addr1 = 0;
  assign cl_rg_8_0_addr1 = 0;
  assign cl_rg_8_1_addr1 = 0;
  assign cl_rg_8_2_addr1 = 0;
  assign cl_rg_8_3_addr1 = 0;
  assign cl_rg_9_0_addr1 = 0;
  assign cl_rg_9_1_addr1 = 0;
  assign cl_rg_9_2_addr1 = 0;
  assign cl_rg_9_3_addr1 = 0;
  assign cl_rg_0_0_d1 = 0;
  assign cl_rg_0_1_d1 = 0;
  assign cl_rg_0_2_d1 = 0;
  assign cl_rg_0_3_d1 = 0;
  assign cl_rg_1_0_d1 = 0;
  assign cl_rg_1_1_d1 = 0;
  assign cl_rg_1_2_d1 = 0;
  assign cl_rg_1_3_d1 = 0;
  assign cl_rg_2_0_d1 = 0;
  assign cl_rg_2_1_d1 = 0;
  assign cl_rg_2_2_d1 = 0;
  assign cl_rg_2_3_d1 = 0;
  assign cl_rg_3_0_d1 = 0;
  assign cl_rg_3_1_d1 = 0;
  assign cl_rg_3_2_d1 = 0;
  assign cl_rg_3_3_d1 = 0;
  assign cl_rg_4_0_d1 = 0;
  assign cl_rg_4_1_d1 = 0;
  assign cl_rg_4_2_d1 = 0;
  assign cl_rg_4_3_d1 = 0;
  assign cl_rg_5_0_d1 = 0;
  assign cl_rg_5_1_d1 = 0;
  assign cl_rg_5_2_d1 = 0;
  assign cl_rg_5_3_d1 = 0;
  assign cl_rg_6_0_d1 = 0;
  assign cl_rg_6_1_d1 = 0;
  assign cl_rg_6_2_d1 = 0;
  assign cl_rg_6_3_d1 = 0;
  assign cl_rg_7_0_d1 = 0;
  assign cl_rg_7_1_d1 = 0;
  assign cl_rg_7_2_d1 = 0;
  assign cl_rg_7_3_d1 = 0;
  assign cl_rg_8_0_d1 = 0;
  assign cl_rg_8_1_d1 = 0;
  assign cl_rg_8_2_d1 = 0;
  assign cl_rg_8_3_d1 = 0;
  assign cl_rg_9_0_d1 = 0;
  assign cl_rg_9_1_d1 = 0;
  assign cl_rg_9_2_d1 = 0;
  assign cl_rg_9_3_d1 = 0;
  assign cl_rg_0_0_ce1 = cl_spmv_local_y0_ce1 | 0;
  assign cl_rg_0_1_ce1 = 0;
  assign cl_rg_0_2_ce1 = cl_spmv_local_ptr1_ce0 | 0;
  assign cl_rg_0_3_ce1 = 0;
  assign cl_rg_1_0_ce1 = (cl_ram_sel[0] & cl_spmv_local_x00_ce1) | 0;
  assign cl_rg_1_1_ce1 = (cl_ram_sel[0] & cl_spmv_local_x10_ce1) | 0;
  assign cl_rg_1_2_ce1 = (cl_ram_sel[0] & cl_spmv_local_x20_ce1) | 0;
  assign cl_rg_1_3_ce1 = (cl_ram_sel[0] & cl_spmv_local_x30_ce1) | 0;
  assign cl_rg_2_0_ce1 = (cl_ram_sel[1] & cl_spmv_local_x00_ce1) | 0;
  assign cl_rg_2_1_ce1 = (cl_ram_sel[1] & cl_spmv_local_x10_ce1) | 0;
  assign cl_rg_2_2_ce1 = (cl_ram_sel[1] & cl_spmv_local_x20_ce1) | 0;
  assign cl_rg_2_3_ce1 = (cl_ram_sel[1] & cl_spmv_local_x30_ce1) | 0;
  assign cl_rg_3_0_ce1 = (cl_ram_sel[0] & cl_spmv_local_x01_ce1) | 0;
  assign cl_rg_3_1_ce1 = (cl_ram_sel[0] & cl_spmv_local_x11_ce1) | 0;
  assign cl_rg_3_2_ce1 = (cl_ram_sel[0] & cl_spmv_local_x21_ce1) | 0;
  assign cl_rg_3_3_ce1 = (cl_ram_sel[0] & cl_spmv_local_x31_ce1) | 0;
  assign cl_rg_4_0_ce1 = (cl_ram_sel[1] & cl_spmv_local_x01_ce1) | 0;
  assign cl_rg_4_1_ce1 = (cl_ram_sel[1] & cl_spmv_local_x11_ce1) | 0;
  assign cl_rg_4_2_ce1 = (cl_ram_sel[1] & cl_spmv_local_x21_ce1) | 0;
  assign cl_rg_4_3_ce1 = (cl_ram_sel[1] & cl_spmv_local_x31_ce1) | 0;
  assign cl_rg_5_0_ce1 = 0;
  assign cl_rg_5_1_ce1 = 0;
  assign cl_rg_5_2_ce1 = 0;
  assign cl_rg_5_3_ce1 = 0;
  assign cl_rg_6_0_ce1 = 0;
  assign cl_rg_6_1_ce1 = 0;
  assign cl_rg_6_2_ce1 = 0;
  assign cl_rg_6_3_ce1 = 0;
  assign cl_rg_7_0_ce1 = 0;
  assign cl_rg_7_1_ce1 = 0;
  assign cl_rg_7_2_ce1 = 0;
  assign cl_rg_7_3_ce1 = 0;
  assign cl_rg_8_0_ce1 = 0;
  assign cl_rg_8_1_ce1 = 0;
  assign cl_rg_8_2_ce1 = 0;
  assign cl_rg_8_3_ce1 = 0;
  assign cl_rg_9_0_ce1 = 0;
  assign cl_rg_9_1_ce1 = 0;
  assign cl_rg_9_2_ce1 = 0;
  assign cl_rg_9_3_ce1 = 0;
  assign cl_rg_0_0_we1 = 0;
  assign cl_rg_0_1_we1 = 0;
  assign cl_rg_0_2_we1 = 0;
  assign cl_rg_0_3_we1 = 0;
  assign cl_rg_1_0_we1 = 0;
  assign cl_rg_1_1_we1 = 0;
  assign cl_rg_1_2_we1 = 0;
  assign cl_rg_1_3_we1 = 0;
  assign cl_rg_2_0_we1 = 0;
  assign cl_rg_2_1_we1 = 0;
  assign cl_rg_2_2_we1 = 0;
  assign cl_rg_2_3_we1 = 0;
  assign cl_rg_3_0_we1 = 0;
  assign cl_rg_3_1_we1 = 0;
  assign cl_rg_3_2_we1 = 0;
  assign cl_rg_3_3_we1 = 0;
  assign cl_rg_4_0_we1 = 0;
  assign cl_rg_4_1_we1 = 0;
  assign cl_rg_4_2_we1 = 0;
  assign cl_rg_4_3_we1 = 0;
  assign cl_rg_5_0_we1 = 0;
  assign cl_rg_5_1_we1 = 0;
  assign cl_rg_5_2_we1 = 0;
  assign cl_rg_5_3_we1 = 0;
  assign cl_rg_6_0_we1 = 0;
  assign cl_rg_6_1_we1 = 0;
  assign cl_rg_6_2_we1 = 0;
  assign cl_rg_6_3_we1 = 0;
  assign cl_rg_7_0_we1 = 0;
  assign cl_rg_7_1_we1 = 0;
  assign cl_rg_7_2_we1 = 0;
  assign cl_rg_7_3_we1 = 0;
  assign cl_rg_8_0_we1 = 0;
  assign cl_rg_8_1_we1 = 0;
  assign cl_rg_8_2_we1 = 0;
  assign cl_rg_8_3_we1 = 0;
  assign cl_rg_9_0_we1 = 0;
  assign cl_rg_9_1_we1 = 0;
  assign cl_rg_9_2_we1 = 0;
  assign cl_rg_9_3_we1 = 0;
  assign cl_rg_0_0_addr0 = cl_spmv_local_y0_ce0 ? cl_spmv_local_y0_address0 : 0;
  assign cl_rg_0_1_addr0 = cl_spmv_local_y1_ce0 ? cl_spmv_local_y1_address0 : 0;
  assign cl_rg_0_2_addr0 = cl_spmv_local_ptr0_ce0 ? cl_spmv_local_ptr0_address0 : 0;
  assign cl_rg_0_3_addr0 = 0;
  assign cl_rg_1_0_addr0 = cl_ram_sel[0] ? cl_spmv_local_x00_address0 : 0;
  assign cl_rg_1_1_addr0 = cl_ram_sel[0] ? cl_spmv_local_x10_address0 : 0;
  assign cl_rg_1_2_addr0 = cl_ram_sel[0] ? cl_spmv_local_x20_address0 : 0;
  assign cl_rg_1_3_addr0 = cl_ram_sel[0] ? cl_spmv_local_x30_address0 : 0;
  assign cl_rg_2_0_addr0 = cl_ram_sel[1] ? cl_spmv_local_x00_address0 : 0;
  assign cl_rg_2_1_addr0 = cl_ram_sel[1] ? cl_spmv_local_x10_address0 : 0;
  assign cl_rg_2_2_addr0 = cl_ram_sel[1] ? cl_spmv_local_x20_address0 : 0;
  assign cl_rg_2_3_addr0 = cl_ram_sel[1] ? cl_spmv_local_x30_address0 : 0;
  assign cl_rg_3_0_addr0 = cl_ram_sel[0] ? cl_spmv_local_x01_address0 : 0;
  assign cl_rg_3_1_addr0 = cl_ram_sel[0] ? cl_spmv_local_x11_address0 : 0;
  assign cl_rg_3_2_addr0 = cl_ram_sel[0] ? cl_spmv_local_x21_address0 : 0;
  assign cl_rg_3_3_addr0 = cl_ram_sel[0] ? cl_spmv_local_x31_address0 : 0;
  assign cl_rg_4_0_addr0 = cl_ram_sel[1] ? cl_spmv_local_x01_address0 : 0;
  assign cl_rg_4_1_addr0 = cl_ram_sel[1] ? cl_spmv_local_x11_address0 : 0;
  assign cl_rg_4_2_addr0 = cl_ram_sel[1] ? cl_spmv_local_x21_address0 : 0;
  assign cl_rg_4_3_addr0 = cl_ram_sel[1] ? cl_spmv_local_x31_address0 : 0;
  assign cl_rg_5_0_addr0 = cl_spmv_last_ind0_ce0 ? cl_spmv_last_ind0_address0 : 0;
  assign cl_rg_5_1_addr0 = cl_spmv_last_ind1_ce0 ? cl_spmv_last_ind1_address0 : 0;
  assign cl_rg_5_2_addr0 = 0;
  assign cl_rg_5_3_addr0 = 0;
  assign cl_rg_6_0_addr0 = cl_spmv_local_val00_ce0 ? cl_spmv_local_val00_address0 : 0;
  assign cl_rg_6_1_addr0 = cl_spmv_local_val10_ce0 ? cl_spmv_local_val10_address0 : 0;
  assign cl_rg_6_2_addr0 = cl_spmv_local_val20_ce0 ? cl_spmv_local_val20_address0 : 0;
  assign cl_rg_6_3_addr0 = cl_spmv_local_val30_ce0 ? cl_spmv_local_val30_address0 : 0;
  assign cl_rg_7_0_addr0 = cl_spmv_local_ind00_ce0 ? cl_spmv_local_ind00_address0 : 0;
  assign cl_rg_7_1_addr0 = cl_spmv_local_ind10_ce0 ? cl_spmv_local_ind10_address0 : 0;
  assign cl_rg_7_2_addr0 = cl_spmv_local_ind20_ce0 ? cl_spmv_local_ind20_address0 : 0;
  assign cl_rg_7_3_addr0 = cl_spmv_local_ind30_ce0 ? cl_spmv_local_ind30_address0 : 0;
  assign cl_rg_8_0_addr0 = cl_spmv_local_val01_ce0 ? cl_spmv_local_val01_address0 : 0;
  assign cl_rg_8_1_addr0 = cl_spmv_local_val11_ce0 ? cl_spmv_local_val11_address0 : 0;
  assign cl_rg_8_2_addr0 = cl_spmv_local_val21_ce0 ? cl_spmv_local_val21_address0 : 0;
  assign cl_rg_8_3_addr0 = cl_spmv_local_val31_ce0 ? cl_spmv_local_val31_address0 : 0;
  assign cl_rg_9_0_addr0 = cl_spmv_local_ind01_ce0 ? cl_spmv_local_ind01_address0 : 0;
  assign cl_rg_9_1_addr0 = cl_spmv_local_ind11_ce0 ? cl_spmv_local_ind11_address0 : 0;
  assign cl_rg_9_2_addr0 = cl_spmv_local_ind21_ce0 ? cl_spmv_local_ind21_address0 : 0;
  assign cl_rg_9_3_addr0 = cl_spmv_local_ind31_ce0 ? cl_spmv_local_ind31_address0 : 0;
  assign cl_rg_0_0_ce0 = cl_spmv_local_y0_ce0 | 0;
  assign cl_rg_0_1_ce0 = cl_spmv_local_y1_ce0 | 0;
  assign cl_rg_0_2_ce0 = cl_spmv_local_ptr0_ce0 | 0;
  assign cl_rg_0_3_ce0 = 0;
  assign cl_rg_1_0_ce0 = (cl_ram_sel[0] & cl_spmv_local_x00_ce0) | 0;
  assign cl_rg_1_1_ce0 = (cl_ram_sel[0] & cl_spmv_local_x10_ce0) | 0;
  assign cl_rg_1_2_ce0 = (cl_ram_sel[0] & cl_spmv_local_x20_ce0) | 0;
  assign cl_rg_1_3_ce0 = (cl_ram_sel[0] & cl_spmv_local_x30_ce0) | 0;
  assign cl_rg_2_0_ce0 = (cl_ram_sel[1] & cl_spmv_local_x00_ce0) | 0;
  assign cl_rg_2_1_ce0 = (cl_ram_sel[1] & cl_spmv_local_x10_ce0) | 0;
  assign cl_rg_2_2_ce0 = (cl_ram_sel[1] & cl_spmv_local_x20_ce0) | 0;
  assign cl_rg_2_3_ce0 = (cl_ram_sel[1] & cl_spmv_local_x30_ce0) | 0;
  assign cl_rg_3_0_ce0 = (cl_ram_sel[0] & cl_spmv_local_x01_ce0) | 0;
  assign cl_rg_3_1_ce0 = (cl_ram_sel[0] & cl_spmv_local_x11_ce0) | 0;
  assign cl_rg_3_2_ce0 = (cl_ram_sel[0] & cl_spmv_local_x21_ce0) | 0;
  assign cl_rg_3_3_ce0 = (cl_ram_sel[0] & cl_spmv_local_x31_ce0) | 0;
  assign cl_rg_4_0_ce0 = (cl_ram_sel[1] & cl_spmv_local_x01_ce0) | 0;
  assign cl_rg_4_1_ce0 = (cl_ram_sel[1] & cl_spmv_local_x11_ce0) | 0;
  assign cl_rg_4_2_ce0 = (cl_ram_sel[1] & cl_spmv_local_x21_ce0) | 0;
  assign cl_rg_4_3_ce0 = (cl_ram_sel[1] & cl_spmv_local_x31_ce0) | 0;
  assign cl_rg_5_0_ce0 = cl_spmv_last_ind0_ce0 | 0;
  assign cl_rg_5_1_ce0 = cl_spmv_last_ind1_ce0 | 0;
  assign cl_rg_5_2_ce0 = 0;
  assign cl_rg_5_3_ce0 = 0;
  assign cl_rg_6_0_ce0 = cl_spmv_local_val00_ce0 | 0;
  assign cl_rg_6_1_ce0 = cl_spmv_local_val10_ce0 | 0;
  assign cl_rg_6_2_ce0 = cl_spmv_local_val20_ce0 | 0;
  assign cl_rg_6_3_ce0 = cl_spmv_local_val30_ce0 | 0;
  assign cl_rg_7_0_ce0 = cl_spmv_local_ind00_ce0 | 0;
  assign cl_rg_7_1_ce0 = cl_spmv_local_ind10_ce0 | 0;
  assign cl_rg_7_2_ce0 = cl_spmv_local_ind20_ce0 | 0;
  assign cl_rg_7_3_ce0 = cl_spmv_local_ind30_ce0 | 0;
  assign cl_rg_8_0_ce0 = cl_spmv_local_val01_ce0 | 0;
  assign cl_rg_8_1_ce0 = cl_spmv_local_val11_ce0 | 0;
  assign cl_rg_8_2_ce0 = cl_spmv_local_val21_ce0 | 0;
  assign cl_rg_8_3_ce0 = cl_spmv_local_val31_ce0 | 0;
  assign cl_rg_9_0_ce0 = cl_spmv_local_ind01_ce0 | 0;
  assign cl_rg_9_1_ce0 = cl_spmv_local_ind11_ce0 | 0;
  assign cl_rg_9_2_ce0 = cl_spmv_local_ind21_ce0 | 0;
  assign cl_rg_9_3_ce0 = cl_spmv_local_ind31_ce0 | 0;
  assign cl_rg_0_0_we0 = cl_spmv_local_y0_we0 | 0;
  assign cl_rg_0_1_we0 = cl_spmv_local_y1_we0 | 0;
  assign cl_rg_0_2_we0 = 0;
  assign cl_rg_1_0_we0 = 0;
  assign cl_rg_1_1_we0 = 0;
  assign cl_rg_1_2_we0 = 0;
  assign cl_rg_1_3_we0 = 0;
  assign cl_rg_2_0_we0 = 0;
  assign cl_rg_2_1_we0 = 0;
  assign cl_rg_2_2_we0 = 0;
  assign cl_rg_2_3_we0 = 0;
  assign cl_rg_3_0_we0 = 0;
  assign cl_rg_3_1_we0 = 0;
  assign cl_rg_3_2_we0 = 0;
  assign cl_rg_3_3_we0 = 0;
  assign cl_rg_4_0_we0 = 0;
  assign cl_rg_4_1_we0 = 0;
  assign cl_rg_4_2_we0 = 0;
  assign cl_rg_4_3_we0 = 0;
  assign cl_rg_5_0_we0 = cl_spmv_last_ind0_we0 | 0;
  assign cl_rg_5_1_we0 = cl_spmv_last_ind1_we0 | 0;
  assign cl_rg_6_0_we0 = 0;
  assign cl_rg_6_1_we0 = 0;
  assign cl_rg_6_2_we0 = 0;
  assign cl_rg_6_3_we0 = 0;
  assign cl_rg_7_0_we0 = 0;
  assign cl_rg_7_1_we0 = 0;
  assign cl_rg_7_2_we0 = 0;
  assign cl_rg_7_3_we0 = 0;
  assign cl_rg_8_0_we0 = 0;
  assign cl_rg_8_1_we0 = 0;
  assign cl_rg_8_2_we0 = 0;
  assign cl_rg_8_3_we0 = 0;
  assign cl_rg_9_0_we0 = 0;
  assign cl_rg_9_1_we0 = 0;
  assign cl_rg_9_2_we0 = 0;
  assign cl_rg_9_3_we0 = 0;
  assign cl_rg_0_0_d0 = cl_spmv_local_y0_ce0 ? cl_spmv_local_y0_d0 : 0;
  assign cl_rg_0_1_d0 = cl_spmv_local_y1_ce0 ? cl_spmv_local_y1_d0 : 0;
  assign cl_rg_0_2_d0 = 0;
  assign cl_rg_1_0_d0 = 0;
  assign cl_rg_1_1_d0 = 0;
  assign cl_rg_1_2_d0 = 0;
  assign cl_rg_1_3_d0 = 0;
  assign cl_rg_2_0_d0 = 0;
  assign cl_rg_2_1_d0 = 0;
  assign cl_rg_2_2_d0 = 0;
  assign cl_rg_2_3_d0 = 0;
  assign cl_rg_3_0_d0 = 0;
  assign cl_rg_3_1_d0 = 0;
  assign cl_rg_3_2_d0 = 0;
  assign cl_rg_3_3_d0 = 0;
  assign cl_rg_4_0_d0 = 0;
  assign cl_rg_4_1_d0 = 0;
  assign cl_rg_4_2_d0 = 0;
  assign cl_rg_4_3_d0 = 0;
  assign cl_rg_5_0_d0 = cl_spmv_last_ind0_ce0 ? cl_spmv_last_ind0_d0 : 0;
  assign cl_rg_5_1_d0 = cl_spmv_last_ind1_ce0 ? cl_spmv_last_ind1_d0 : 0;
  assign cl_rg_6_0_d0 = 0;
  assign cl_rg_6_1_d0 = 0;
  assign cl_rg_6_2_d0 = 0;
  assign cl_rg_6_3_d0 = 0;
  assign cl_rg_7_0_d0 = 0;
  assign cl_rg_7_1_d0 = 0;
  assign cl_rg_7_2_d0 = 0;
  assign cl_rg_7_3_d0 = 0;
  assign cl_rg_8_0_d0 = 0;
  assign cl_rg_8_1_d0 = 0;
  assign cl_rg_8_2_d0 = 0;
  assign cl_rg_8_3_d0 = 0;
  assign cl_rg_9_0_d0 = 0;
  assign cl_rg_9_1_d0 = 0;
  assign cl_rg_9_2_d0 = 0;
  assign cl_rg_9_3_d0 = 0;
  assign cl_spmv_local_y0_q0 = cl_rg_0_0_q0;
  assign cl_spmv_local_y0_q1 = cl_rg_0_0_q1;
  assign cl_spmv_local_y1_q0 = cl_rg_0_1_q0;
  assign cl_spmv_local_ptr0_q0 = cl_rg_0_2_q0;
  assign cl_spmv_local_ptr1_q0 = cl_rg_0_2_q1;
  assign cl_spmv_last_ind0_q0 = cl_rg_5_0_q0;
  assign cl_spmv_last_ind1_q0 = cl_rg_5_1_q0;
  assign cl_spmv_local_val00_q0 = cl_rg_6_0_q0;
  assign cl_spmv_local_val10_q0 = cl_rg_6_1_q0;
  assign cl_spmv_local_val20_q0 = cl_rg_6_2_q0;
  assign cl_spmv_local_val30_q0 = cl_rg_6_3_q0;
  assign cl_spmv_local_ind00_q0 = cl_rg_7_0_q0;
  assign cl_spmv_local_ind10_q0 = cl_rg_7_1_q0;
  assign cl_spmv_local_ind20_q0 = cl_rg_7_2_q0;
  assign cl_spmv_local_ind30_q0 = cl_rg_7_3_q0;
  assign cl_spmv_local_val01_q0 = cl_rg_8_0_q0;
  assign cl_spmv_local_val11_q0 = cl_rg_8_1_q0;
  assign cl_spmv_local_val21_q0 = cl_rg_8_2_q0;
  assign cl_spmv_local_val31_q0 = cl_rg_8_3_q0;
  assign cl_spmv_local_ind01_q0 = cl_rg_9_0_q0;
  assign cl_spmv_local_ind11_q0 = cl_rg_9_1_q0;
  assign cl_spmv_local_ind21_q0 = cl_rg_9_2_q0;
  assign cl_spmv_local_ind31_q0 = cl_rg_9_3_q0;
  assign cl_spmv_local_x00_q0 = cl_ram_sel[0] ? cl_rg_1_0_q0 : cl_ram_sel[1] ? cl_rg_2_0_q0 : 0;
  assign cl_spmv_local_x00_q1 = cl_ram_sel[0] ? cl_rg_1_0_q1 : cl_ram_sel[1] ? cl_rg_2_0_q1 : 0;
  assign cl_spmv_local_x10_q0 = cl_ram_sel[0] ? cl_rg_1_1_q0 : cl_ram_sel[1] ? cl_rg_2_1_q0 : 0;
  assign cl_spmv_local_x10_q1 = cl_ram_sel[0] ? cl_rg_1_1_q1 : cl_ram_sel[1] ? cl_rg_2_1_q1 : 0;
  assign cl_spmv_local_x20_q0 = cl_ram_sel[0] ? cl_rg_1_2_q0 : cl_ram_sel[1] ? cl_rg_2_2_q0 : 0;
  assign cl_spmv_local_x20_q1 = cl_ram_sel[0] ? cl_rg_1_2_q1 : cl_ram_sel[1] ? cl_rg_2_2_q1 : 0;
  assign cl_spmv_local_x30_q0 = cl_ram_sel[0] ? cl_rg_1_3_q0 : cl_ram_sel[1] ? cl_rg_2_3_q0 : 0;
  assign cl_spmv_local_x30_q1 = cl_ram_sel[0] ? cl_rg_1_3_q1 : cl_ram_sel[1] ? cl_rg_2_3_q1 : 0;
  assign cl_spmv_local_x01_q0 = cl_ram_sel[0] ? cl_rg_3_0_q0 : cl_ram_sel[1] ? cl_rg_4_0_q0 : 0;
  assign cl_spmv_local_x01_q1 = cl_ram_sel[0] ? cl_rg_3_0_q1 : cl_ram_sel[1] ? cl_rg_4_0_q1 : 0;
  assign cl_spmv_local_x11_q0 = cl_ram_sel[0] ? cl_rg_3_1_q0 : cl_ram_sel[1] ? cl_rg_4_1_q0 : 0;
  assign cl_spmv_local_x11_q1 = cl_ram_sel[0] ? cl_rg_3_1_q1 : cl_ram_sel[1] ? cl_rg_4_1_q1 : 0;
  assign cl_spmv_local_x21_q0 = cl_ram_sel[0] ? cl_rg_3_2_q0 : cl_ram_sel[1] ? cl_rg_4_2_q0 : 0;
  assign cl_spmv_local_x21_q1 = cl_ram_sel[0] ? cl_rg_3_2_q1 : cl_ram_sel[1] ? cl_rg_4_2_q1 : 0;
  assign cl_spmv_local_x31_q0 = cl_ram_sel[0] ? cl_rg_3_3_q0 : cl_ram_sel[1] ? cl_rg_4_3_q0 : 0;
  assign cl_spmv_local_x31_q1 = cl_ram_sel[0] ? cl_rg_3_3_q1 : cl_ram_sel[1] ? cl_rg_4_3_q1 : 0;
  localparam OFFSET_CL_CSR = 32'h0;
  localparam OFFSET_CL_SPMV_N = 32'h4;
  localparam OFFSET_CL_SPMV_ROW_BEGIN = 32'h8;
  localparam OFFSET_CL_SPMV_ROW_END = 32'hc;
  localparam OFFSET_CL_SPMV_LEN1 = 32'h10;
  localparam OFFSET_CL_SPMV_LEN2 = 32'h14;
  localparam OFFSET_CL_SPMV_I = 32'h18;
  localparam OFFSET_CL_SPMV_K0 = 32'h1c;
  localparam OFFSET_CL_SPMV_STATE = 32'h20;
  localparam OFFSET_CL_SPMV_PP = 32'h24;
  localparam OFFSET_CL_SPMV_K1 = 32'h28;
  localparam OFFSET_CL_SPMV_K2 = 32'h2c;
  localparam OFFSET_CL_SPMV_MAXLEN = 32'h30;
  localparam OFFSET_CL_SPMV_CUR_PTR = 32'h34;
  wire [31:0] cl_csr_next, cl_csr_value;
  wire cl_csr_ce, cl_csr_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) cl_csr_reg (
    .clk(clk),
    .rst(cl_csr_rst),
    .ce(cl_csr_ce),
    .d(cl_csr_next),
    .q(cl_csr_value)
  );
  wire [31:0] cl_spmv_n_next, cl_spmv_n_value;
  wire cl_spmv_n_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) cl_spmv_n_reg (
    .clk(clk),
    .rst(rst),
    .ce(cl_spmv_n_ce),
    .d(cl_spmv_n_next),
    .q(cl_spmv_n_value)
  );
  wire [31:0] cl_spmv_row_begin_next, cl_spmv_row_begin_value;
  wire cl_spmv_row_begin_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) cl_spmv_row_begin_reg (
    .clk(clk),
    .rst(rst),
    .ce(cl_spmv_row_begin_ce),
    .d(cl_spmv_row_begin_next),
    .q(cl_spmv_row_begin_value)
  );
  wire [31:0] cl_spmv_row_end_next, cl_spmv_row_end_value;
  wire cl_spmv_row_end_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) cl_spmv_row_end_reg (
    .clk(clk),
    .rst(rst),
    .ce(cl_spmv_row_end_ce),
    .d(cl_spmv_row_end_next),
    .q(cl_spmv_row_end_value)
  );
  wire [31:0] cl_spmv_len1_next, cl_spmv_len1_value;
  wire cl_spmv_len1_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) cl_spmv_len1_reg (
    .clk(clk),
    .rst(rst),
    .ce(cl_spmv_len1_ce),
    .d(cl_spmv_len1_next),
    .q(cl_spmv_len1_value)
  );
  wire [31:0] cl_spmv_len2_next, cl_spmv_len2_value;
  wire cl_spmv_len2_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) cl_spmv_len2_reg (
    .clk(clk),
    .rst(rst),
    .ce(cl_spmv_len2_ce),
    .d(cl_spmv_len2_next),
    .q(cl_spmv_len2_value)
  );
  wire [31:0] cl_spmv_i_next, cl_spmv_i_value;
  wire cl_spmv_i_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) cl_spmv_i_reg (
    .clk(clk),
    .rst(rst),
    .ce(cl_spmv_i_ce),
    .d(cl_spmv_i_next),
    .q(cl_spmv_i_value)
  );
  wire [31:0] cl_spmv_k0_next, cl_spmv_k0_value;
  wire cl_spmv_k0_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) cl_spmv_k0_reg (
    .clk(clk),
    .rst(rst),
    .ce(cl_spmv_k0_ce),
    .d(cl_spmv_k0_next),
    .q(cl_spmv_k0_value)
  );
  wire [31:0] cl_spmv_state_next, cl_spmv_state_value;
  wire cl_spmv_state_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) cl_spmv_state_reg (
    .clk(clk),
    .rst(rst),
    .ce(cl_spmv_state_ce),
    .d(cl_spmv_state_next),
    .q(cl_spmv_state_value)
  );
  wire [31:0] cl_spmv_pp_next, cl_spmv_pp_value;
  wire cl_spmv_pp_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) cl_spmv_pp_reg (
    .clk(clk),
    .rst(rst),
    .ce(cl_spmv_pp_ce),
    .d(cl_spmv_pp_next),
    .q(cl_spmv_pp_value)
  );
  wire [31:0] cl_spmv_k1_next, cl_spmv_k1_value;
  wire cl_spmv_k1_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) cl_spmv_k1_reg (
    .clk(clk),
    .rst(rst),
    .ce(cl_spmv_k1_ce),
    .d(cl_spmv_k1_next),
    .q(cl_spmv_k1_value)
  );
  wire [31:0] cl_spmv_k2_next, cl_spmv_k2_value;
  wire cl_spmv_k2_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) cl_spmv_k2_reg (
    .clk(clk),
    .rst(rst),
    .ce(cl_spmv_k2_ce),
    .d(cl_spmv_k2_next),
    .q(cl_spmv_k2_value)
  );
  wire [31:0] cl_spmv_maxlen_next, cl_spmv_maxlen_value;
  wire cl_spmv_maxlen_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) cl_spmv_maxlen_reg (
    .clk(clk),
    .rst(rst),
    .ce(cl_spmv_maxlen_ce),
    .d(cl_spmv_maxlen_next),
    .q(cl_spmv_maxlen_value)
  );
  wire [31:0] cl_spmv_cur_ptr_next, cl_spmv_cur_ptr_value;
  wire cl_spmv_cur_ptr_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) cl_spmv_cur_ptr_reg (
    .clk(clk),
    .rst(rst),
    .ce(cl_spmv_cur_ptr_ce),
    .d(cl_spmv_cur_ptr_next),
    .q(cl_spmv_cur_ptr_value)
  );

  wire [11:0] cl_ctrl_addr_pipe0;
  REGISTER_CE #(.N(12)) cl_ctrl_addr_pipe0_reg (
    .clk(clk),
    .ce(cl_ctrl_ce & ~cl_ctrl_we),
    .d(cl_ctrl_addr),
    .q(cl_ctrl_addr_pipe0)
  );

  wire cl_ap_done_pipe0;
  REGISTER #(.N(1)) cl_ap_done_reg (
    .clk(clk),
    .d(cl_ap_done),
    .q(cl_ap_done_pipe0)
  );

  wire cl_ap_ready_pipe0;
  REGISTER #(.N(1)) cl_ap_ready_reg (
    .clk(clk),
    .d(cl_ap_ready),
    .q(cl_ap_ready_pipe0)
  );

  assign cl_done = cl_csr_value[1];
  assign cl_ctrl_q = (cl_ctrl_addr_pipe0[`MMIO_AW-1:0] == (OFFSET_CL_CSR & {`MMIO_AW{1'b1}})) ? cl_csr_value :
    (cl_ctrl_addr_pipe0[`MMIO_AW-1:0] == OFFSET_CL_SPMV_K1) ? cl_spmv_k1_value :
    (cl_ctrl_addr_pipe0[`MMIO_AW-1:0] == OFFSET_CL_SPMV_K2) ? cl_spmv_k2_value :
    (cl_ctrl_addr_pipe0[`MMIO_AW-1:0] == OFFSET_CL_SPMV_MAXLEN) ? cl_spmv_maxlen_value :
    (cl_ctrl_addr_pipe0[`MMIO_AW-1:0] == OFFSET_CL_SPMV_CUR_PTR) ? cl_spmv_cur_ptr_value :
    0;
  wire cl_csr_read = (cl_ctrl_addr[`MMIO_AW-1:0] == (OFFSET_CL_CSR & {`MMIO_AW{1'b1}})) & (cl_ctrl_ce & ~cl_ctrl_we);
  assign cl_csr_next = cl_ap_done ? {cl_csr_value[31:2], 1'b1, 1'b0} : cl_ap_ready_pipe0 ? {cl_csr_value[31:1], 1'b0} : cl_ctrl_d;
  assign cl_csr_ce   = (cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_CL_CSR)) | cl_ap_done | cl_ap_ready_pipe0;
  assign cl_csr_rst  = rst;
  assign cl_ap_start = cl_csr_value[0] & (~cl_ap_ready_pipe0);
  assign cl_spmv_n_next = cl_ctrl_d;
  assign cl_spmv_n_ce   = cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_CL_SPMV_N);
  assign cl_spmv_n = cl_spmv_n_value;
  assign cl_spmv_row_begin_next = cl_ctrl_d;
  assign cl_spmv_row_begin_ce   = cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_CL_SPMV_ROW_BEGIN);
  assign cl_spmv_row_begin = cl_spmv_row_begin_value;
  assign cl_spmv_row_end_next = cl_ctrl_d;
  assign cl_spmv_row_end_ce   = cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_CL_SPMV_ROW_END);
  assign cl_spmv_row_end = cl_spmv_row_end_value;
  assign cl_spmv_len1_next = cl_ctrl_d;
  assign cl_spmv_len1_ce   = cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_CL_SPMV_LEN1);
  assign cl_spmv_len1 = cl_spmv_len1_value;
  assign cl_spmv_len2_next = cl_ctrl_d;
  assign cl_spmv_len2_ce   = cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_CL_SPMV_LEN2);
  assign cl_spmv_len2 = cl_spmv_len2_value;
  assign cl_spmv_i_next = cl_ctrl_d;
  assign cl_spmv_i_ce   = cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_CL_SPMV_I);
  assign cl_spmv_i = cl_spmv_i_value;
  assign cl_spmv_k0_next = cl_ctrl_d;
  assign cl_spmv_k0_ce   = cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_CL_SPMV_K0);
  assign cl_spmv_k0 = cl_spmv_k0_value;
  assign cl_spmv_state_next = cl_ctrl_d;
  assign cl_spmv_state_ce   = cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_CL_SPMV_STATE);
  assign cl_spmv_state = cl_spmv_state_value;
  assign cl_spmv_pp_next = cl_ctrl_d;
  assign cl_spmv_pp_ce   = cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_CL_SPMV_PP);
  assign cl_spmv_pp = cl_spmv_pp_value;
  assign cl_spmv_k1_next = cl_spmv_k1_o_ap_vld ? cl_spmv_k1_o : cl_ctrl_d;
  assign cl_spmv_k1_ce   = cl_spmv_k1_o_ap_vld | (cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_CL_SPMV_K1));
  assign cl_spmv_k1_i = cl_spmv_k1_value;
  assign cl_spmv_k2_next = cl_spmv_k2_o_ap_vld ? cl_spmv_k2_o : cl_ctrl_d;
  assign cl_spmv_k2_ce   = cl_spmv_k2_o_ap_vld | (cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_CL_SPMV_K2));
  assign cl_spmv_k2_i = cl_spmv_k2_value;
  assign cl_spmv_maxlen_next = cl_spmv_maxlen_o_ap_vld ? cl_spmv_maxlen_o : cl_ctrl_d;
  assign cl_spmv_maxlen_ce   = cl_spmv_maxlen_o_ap_vld | (cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_CL_SPMV_MAXLEN));
  assign cl_spmv_maxlen_i = cl_spmv_maxlen_value;
  assign cl_spmv_cur_ptr_next = cl_spmv_cur_ptr_o_ap_vld ? cl_spmv_cur_ptr_o : cl_ctrl_d;
  assign cl_spmv_cur_ptr_ce   = cl_spmv_cur_ptr_o_ap_vld | (cl_ctrl_ce & cl_ctrl_we & (cl_ctrl_addr[`MMIO_AW-1:0] == OFFSET_CL_SPMV_CUR_PTR));
  assign cl_spmv_cur_ptr_i = cl_spmv_cur_ptr_value;
endmodule
