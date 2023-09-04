`include "socket_config.vh"

module rg_cl_wrapper #(
  parameter RAM_READ_LATENCY = `RAM_READ_LATENCY,
  parameter AXIS_DWIDTH = 256,
  parameter AXIS_DESTW  = 1
) (
  input socket_reset,

  input lsu0_dp_mode,

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
  input [4:0] lsu0_ram_en,

`ifndef SOCKET_S
  input lsu1_dp_mode,

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
  input [4:0] lsu1_ram_en,
`endif

`ifndef NO_AXIS
  output [AXIS_DWIDTH-1:0]   m_axis_tdata,
  output                     m_axis_tvalid,
  input                      m_axis_tready,
  output                     m_axis_tlast,
  output [AXIS_DWIDTH/8-1:0] m_axis_tkeep,
  output [AXIS_DWIDTH/8-1:0] m_axis_tstrb,
  output [AXIS_DESTW-1:0]    m_axis_tdest,

  input [AXIS_DWIDTH-1:0]   s_axis_tdata,
  input                     s_axis_tvalid,
  output                    s_axis_tready,
  input                     s_axis_tlast,
  input [AXIS_DWIDTH/8-1:0] s_axis_tkeep,
  input [AXIS_DWIDTH/8-1:0] s_axis_tstrb,
  input [AXIS_DESTW-1:0]    s_axis_tdest,
`endif

  output        cl_done,
  input  [11:0] cl_ctrl_addr,
  input  [31:0] cl_ctrl_d,
  output [31:0] cl_ctrl_q,
  input         cl_ctrl_ce,
  input         cl_ctrl_we,

  //input clk1,
  input clk
);

//`ifdef FF_BRIDGE
  wire [11:0] lsu0_port0_addr_ff;
  wire [11:0] lsu0_port1_addr_ff;
  wire [11:0] lsu0_port2_addr_ff;
  wire [11:0] lsu0_port3_addr_ff;
  wire        lsu0_port0_ce_ff, lsu0_port0_we_ff;
  wire        lsu0_port1_ce_ff, lsu0_port1_we_ff;
  wire        lsu0_port2_ce_ff, lsu0_port2_we_ff;
  wire        lsu0_port3_ce_ff, lsu0_port3_we_ff;

  wire [63:0] lsu0_port0_d_ff;
  wire [63:0] lsu0_port1_d_ff;
  wire [63:0] lsu0_port2_d_ff;
  wire [63:0] lsu0_port3_d_ff;
  wire [63:0] lsu0_port0_q_ff;
  wire [63:0] lsu0_port1_q_ff;
  wire [63:0] lsu0_port2_q_ff;
  wire [63:0] lsu0_port3_q_ff;

  wire lsu0_dp_mode_ff;
  wire [4:0] lsu0_ram_en_ff;

`ifndef SOCKET_S
  wire [11:0] lsu1_port0_addr_ff;
  wire [11:0] lsu1_port1_addr_ff;
  wire [11:0] lsu1_port2_addr_ff;
  wire [11:0] lsu1_port3_addr_ff;
  wire        lsu1_port0_ce_ff, lsu1_port0_we_ff;
  wire        lsu1_port1_ce_ff, lsu1_port1_we_ff;
  wire        lsu1_port2_ce_ff, lsu1_port2_we_ff;
  wire        lsu1_port3_ce_ff, lsu1_port3_we_ff;

  wire [63:0] lsu1_port0_d_ff;
  wire [63:0] lsu1_port1_d_ff;
  wire [63:0] lsu1_port2_d_ff;
  wire [63:0] lsu1_port3_d_ff;
  wire [63:0] lsu1_port0_q_ff;
  wire [63:0] lsu1_port1_q_ff;
  wire [63:0] lsu1_port2_q_ff;
  wire [63:0] lsu1_port3_q_ff;

  wire lsu1_dp_mode_ff;
  wire [4:0] lsu1_ram_en_ff;
`endif

  wire socket_reset_ff;
  wire        cl_done_ff;
  wire [11:0] cl_ctrl_addr_ff;
  wire [31:0] cl_ctrl_d_ff;
  wire [31:0] cl_ctrl_q_ff;
  wire        cl_ctrl_ce_ff;
  wire        cl_ctrl_we_ff;

  (* DONT_TOUCH = "yes" *) wire stub_in;
  (* DONT_TOUCH = "yes" *) wire stub_out;

  (* DONT_TOUCH = "yes" *)
  ff_bridge ff_bridge (
    .clk0(clk),
    //.clk1(clk1),
    .clk1(clk),

`ifdef FF_BRIDGE_WITH_STUB_NET
    .stub_in(stub_in),
    .stub_out(stub_out),
`endif

    .lsu0_port0_addr(lsu0_port0_addr),
    .lsu0_port1_addr(lsu0_port1_addr),
    .lsu0_port2_addr(lsu0_port2_addr),
    .lsu0_port3_addr(lsu0_port3_addr),
    .lsu0_port0_ce(lsu0_port0_ce),
    .lsu0_port0_we(lsu0_port0_we),
    .lsu0_port1_ce(lsu0_port1_ce),
    .lsu0_port1_we(lsu0_port1_we),
    .lsu0_port2_ce(lsu0_port2_ce),
    .lsu0_port2_we(lsu0_port2_we),
    .lsu0_port3_ce(lsu0_port3_ce),
    .lsu0_port3_we(lsu0_port3_we),
    .lsu0_port0_d(lsu0_port0_d),
    .lsu0_port1_d(lsu0_port1_d),
    .lsu0_port2_d(lsu0_port2_d),
    .lsu0_port3_d(lsu0_port3_d),
    .lsu0_port0_q(lsu0_port0_q),
    .lsu0_port1_q(lsu0_port1_q),
    .lsu0_port2_q(lsu0_port2_q),
    .lsu0_port3_q(lsu0_port3_q),
    .lsu0_dp_mode(lsu0_dp_mode),
    .lsu0_ram_en(lsu0_ram_en),

    .lsu0_port0_addr_ff(lsu0_port0_addr_ff),
    .lsu0_port1_addr_ff(lsu0_port1_addr_ff),
    .lsu0_port2_addr_ff(lsu0_port2_addr_ff),
    .lsu0_port3_addr_ff(lsu0_port3_addr_ff),
    .lsu0_port0_ce_ff(lsu0_port0_ce_ff),
    .lsu0_port0_we_ff(lsu0_port0_we_ff),
    .lsu0_port1_ce_ff(lsu0_port1_ce_ff),
    .lsu0_port1_we_ff(lsu0_port1_we_ff),
    .lsu0_port2_ce_ff(lsu0_port2_ce_ff),
    .lsu0_port2_we_ff(lsu0_port2_we_ff),
    .lsu0_port3_ce_ff(lsu0_port3_ce_ff),
    .lsu0_port3_we_ff(lsu0_port3_we_ff),
    .lsu0_port0_d_ff(lsu0_port0_d_ff),
    .lsu0_port1_d_ff(lsu0_port1_d_ff),
    .lsu0_port2_d_ff(lsu0_port2_d_ff),
    .lsu0_port3_d_ff(lsu0_port3_d_ff),
    .lsu0_port0_q_ff(lsu0_port0_q_ff),
    .lsu0_port1_q_ff(lsu0_port1_q_ff),
    .lsu0_port2_q_ff(lsu0_port2_q_ff),
    .lsu0_port3_q_ff(lsu0_port3_q_ff),
    .lsu0_dp_mode_ff(lsu0_dp_mode_ff),
    .lsu0_ram_en_ff(lsu0_ram_en_ff),

`ifndef SOCKET_S
    .lsu1_port0_addr(lsu1_port0_addr),
    .lsu1_port1_addr(lsu1_port1_addr),
    .lsu1_port2_addr(lsu1_port2_addr),
    .lsu1_port3_addr(lsu1_port3_addr),
    .lsu1_port0_ce(lsu1_port0_ce),
    .lsu1_port0_we(lsu1_port0_we),
    .lsu1_port1_ce(lsu1_port1_ce),
    .lsu1_port1_we(lsu1_port1_we),
    .lsu1_port2_ce(lsu1_port2_ce),
    .lsu1_port2_we(lsu1_port2_we),
    .lsu1_port3_ce(lsu1_port3_ce),
    .lsu1_port3_we(lsu1_port3_we),
    .lsu1_port0_d(lsu1_port0_d),
    .lsu1_port1_d(lsu1_port1_d),
    .lsu1_port2_d(lsu1_port2_d),
    .lsu1_port3_d(lsu1_port3_d),
    .lsu1_port0_q(lsu1_port0_q),
    .lsu1_port1_q(lsu1_port1_q),
    .lsu1_port2_q(lsu1_port2_q),
    .lsu1_port3_q(lsu1_port3_q),
    .lsu1_dp_mode(lsu1_dp_mode),
    .lsu1_ram_en(lsu1_ram_en),

    .lsu1_port0_addr_ff(lsu1_port0_addr_ff),
    .lsu1_port1_addr_ff(lsu1_port1_addr_ff),
    .lsu1_port2_addr_ff(lsu1_port2_addr_ff),
    .lsu1_port3_addr_ff(lsu1_port3_addr_ff),
    .lsu1_port0_ce_ff(lsu1_port0_ce_ff),
    .lsu1_port0_we_ff(lsu1_port0_we_ff),
    .lsu1_port1_ce_ff(lsu1_port1_ce_ff),
    .lsu1_port1_we_ff(lsu1_port1_we_ff),
    .lsu1_port2_ce_ff(lsu1_port2_ce_ff),
    .lsu1_port2_we_ff(lsu1_port2_we_ff),
    .lsu1_port3_ce_ff(lsu1_port3_ce_ff),
    .lsu1_port3_we_ff(lsu1_port3_we_ff),
    .lsu1_port0_d_ff(lsu1_port0_d_ff),
    .lsu1_port1_d_ff(lsu1_port1_d_ff),
    .lsu1_port2_d_ff(lsu1_port2_d_ff),
    .lsu1_port3_d_ff(lsu1_port3_d_ff),
    .lsu1_port0_q_ff(lsu1_port0_q_ff),
    .lsu1_port1_q_ff(lsu1_port1_q_ff),
    .lsu1_port2_q_ff(lsu1_port2_q_ff),
    .lsu1_port3_q_ff(lsu1_port3_q_ff),
    .lsu1_dp_mode_ff(lsu1_dp_mode_ff),
    .lsu1_ram_en_ff(lsu1_ram_en_ff),
`endif

    .socket_reset(socket_reset),
    .cl_done(cl_done),
    .cl_ctrl_addr(cl_ctrl_addr),
    .cl_ctrl_d(cl_ctrl_d),
    .cl_ctrl_q(cl_ctrl_q),
    .cl_ctrl_ce(cl_ctrl_ce),
    .cl_ctrl_we(cl_ctrl_we),

    .socket_reset_ff(socket_reset_ff),
    .cl_done_ff(cl_done_ff),
    .cl_ctrl_addr_ff(cl_ctrl_addr_ff),
    .cl_ctrl_d_ff(cl_ctrl_d_ff),
    .cl_ctrl_q_ff(cl_ctrl_q_ff),
    .cl_ctrl_ce_ff(cl_ctrl_ce_ff),
    .cl_ctrl_we_ff(cl_ctrl_we_ff)
  );

  wire [11:0] cl_rg_0_0_addr0;
  wire [63:0] cl_rg_0_0_d0;
  wire [63:0] cl_rg_0_0_q0;
  wire cl_rg_0_0_ce0;
  wire cl_rg_0_0_we0;
  wire [11:0] cl_rg_0_0_addr1;
  wire [63:0] cl_rg_0_0_d1;
  wire [63:0] cl_rg_0_0_q1;
  wire cl_rg_0_0_ce1;
  wire cl_rg_0_0_we1;

  wire [11:0] cl_rg_0_1_addr0;
  wire [63:0] cl_rg_0_1_d0;
  wire [63:0] cl_rg_0_1_q0;
  wire cl_rg_0_1_ce0;
  wire cl_rg_0_1_we0;
  wire [11:0] cl_rg_0_1_addr1;
  wire [63:0] cl_rg_0_1_d1;
  wire [63:0] cl_rg_0_1_q1;
  wire cl_rg_0_1_ce1;
  wire cl_rg_0_1_we1;

  wire [11:0] cl_rg_0_2_addr0;
  wire [63:0] cl_rg_0_2_d0;
  wire [63:0] cl_rg_0_2_q0;
  wire cl_rg_0_2_ce0;
  wire cl_rg_0_2_we0;
  wire [11:0] cl_rg_0_2_addr1;
  wire [63:0] cl_rg_0_2_d1;
  wire [63:0] cl_rg_0_2_q1;
  wire cl_rg_0_2_ce1;
  wire cl_rg_0_2_we1;

  wire [11:0] cl_rg_0_3_addr0;
  wire [63:0] cl_rg_0_3_d0;
  wire [63:0] cl_rg_0_3_q0;
  wire cl_rg_0_3_ce0;
  wire cl_rg_0_3_we0;
  wire [11:0] cl_rg_0_3_addr1;
  wire [63:0] cl_rg_0_3_d1;
  wire [63:0] cl_rg_0_3_q1;
  wire cl_rg_0_3_ce1;
  wire cl_rg_0_3_we1;

  wire [11:0] cl_rg_1_0_addr0;
  wire [63:0] cl_rg_1_0_d0;
  wire [63:0] cl_rg_1_0_q0;
  wire cl_rg_1_0_ce0;
  wire cl_rg_1_0_we0;
  wire [11:0] cl_rg_1_0_addr1;
  wire [63:0] cl_rg_1_0_d1;
  wire [63:0] cl_rg_1_0_q1;
  wire cl_rg_1_0_ce1;
  wire cl_rg_1_0_we1;

  wire [11:0] cl_rg_1_1_addr0;
  wire [63:0] cl_rg_1_1_d0;
  wire [63:0] cl_rg_1_1_q0;
  wire cl_rg_1_1_ce0;
  wire cl_rg_1_1_we0;
  wire [11:0] cl_rg_1_1_addr1;
  wire [63:0] cl_rg_1_1_d1;
  wire [63:0] cl_rg_1_1_q1;
  wire cl_rg_1_1_ce1;
  wire cl_rg_1_1_we1;

  wire [11:0] cl_rg_1_2_addr0;
  wire [63:0] cl_rg_1_2_d0;
  wire [63:0] cl_rg_1_2_q0;
  wire cl_rg_1_2_ce0;
  wire cl_rg_1_2_we0;
  wire [11:0] cl_rg_1_2_addr1;
  wire [63:0] cl_rg_1_2_d1;
  wire [63:0] cl_rg_1_2_q1;
  wire cl_rg_1_2_ce1;
  wire cl_rg_1_2_we1;

  wire [11:0] cl_rg_1_3_addr0;
  wire [63:0] cl_rg_1_3_d0;
  wire [63:0] cl_rg_1_3_q0;
  wire cl_rg_1_3_ce0;
  wire cl_rg_1_3_we0;
  wire [11:0] cl_rg_1_3_addr1;
  wire [63:0] cl_rg_1_3_d1;
  wire [63:0] cl_rg_1_3_q1;
  wire cl_rg_1_3_ce1;
  wire cl_rg_1_3_we1;

  wire [11:0] cl_rg_2_0_addr0;
  wire [63:0] cl_rg_2_0_d0;
  wire [63:0] cl_rg_2_0_q0;
  wire cl_rg_2_0_ce0;
  wire cl_rg_2_0_we0;
  wire [11:0] cl_rg_2_0_addr1;
  wire [63:0] cl_rg_2_0_d1;
  wire [63:0] cl_rg_2_0_q1;
  wire cl_rg_2_0_ce1;
  wire cl_rg_2_0_we1;

  wire [11:0] cl_rg_2_1_addr0;
  wire [63:0] cl_rg_2_1_d0;
  wire [63:0] cl_rg_2_1_q0;
  wire cl_rg_2_1_ce0;
  wire cl_rg_2_1_we0;
  wire [11:0] cl_rg_2_1_addr1;
  wire [63:0] cl_rg_2_1_d1;
  wire [63:0] cl_rg_2_1_q1;
  wire cl_rg_2_1_ce1;
  wire cl_rg_2_1_we1;

  wire [11:0] cl_rg_2_2_addr0;
  wire [63:0] cl_rg_2_2_d0;
  wire [63:0] cl_rg_2_2_q0;
  wire cl_rg_2_2_ce0;
  wire cl_rg_2_2_we0;
  wire [11:0] cl_rg_2_2_addr1;
  wire [63:0] cl_rg_2_2_d1;
  wire [63:0] cl_rg_2_2_q1;
  wire cl_rg_2_2_ce1;
  wire cl_rg_2_2_we1;

  wire [11:0] cl_rg_2_3_addr0;
  wire [63:0] cl_rg_2_3_d0;
  wire [63:0] cl_rg_2_3_q0;
  wire cl_rg_2_3_ce0;
  wire cl_rg_2_3_we0;
  wire [11:0] cl_rg_2_3_addr1;
  wire [63:0] cl_rg_2_3_d1;
  wire [63:0] cl_rg_2_3_q1;
  wire cl_rg_2_3_ce1;
  wire cl_rg_2_3_we1;

  wire [11:0] cl_rg_3_0_addr0;
  wire [63:0] cl_rg_3_0_d0;
  wire [63:0] cl_rg_3_0_q0;
  wire cl_rg_3_0_ce0;
  wire cl_rg_3_0_we0;
  wire [11:0] cl_rg_3_0_addr1;
  wire [63:0] cl_rg_3_0_d1;
  wire [63:0] cl_rg_3_0_q1;
  wire cl_rg_3_0_ce1;
  wire cl_rg_3_0_we1;

  wire [11:0] cl_rg_3_1_addr0;
  wire [63:0] cl_rg_3_1_d0;
  wire [63:0] cl_rg_3_1_q0;
  wire cl_rg_3_1_ce0;
  wire cl_rg_3_1_we0;
  wire [11:0] cl_rg_3_1_addr1;
  wire [63:0] cl_rg_3_1_d1;
  wire [63:0] cl_rg_3_1_q1;
  wire cl_rg_3_1_ce1;
  wire cl_rg_3_1_we1;

  wire [11:0] cl_rg_3_2_addr0;
  wire [63:0] cl_rg_3_2_d0;
  wire [63:0] cl_rg_3_2_q0;
  wire cl_rg_3_2_ce0;
  wire cl_rg_3_2_we0;
  wire [11:0] cl_rg_3_2_addr1;
  wire [63:0] cl_rg_3_2_d1;
  wire [63:0] cl_rg_3_2_q1;
  wire cl_rg_3_2_ce1;
  wire cl_rg_3_2_we1;

  wire [11:0] cl_rg_3_3_addr0;
  wire [63:0] cl_rg_3_3_d0;
  wire [63:0] cl_rg_3_3_q0;
  wire cl_rg_3_3_ce0;
  wire cl_rg_3_3_we0;
  wire [11:0] cl_rg_3_3_addr1;
  wire [63:0] cl_rg_3_3_d1;
  wire [63:0] cl_rg_3_3_q1;
  wire cl_rg_3_3_ce1;
  wire cl_rg_3_3_we1;

  wire [11:0] cl_rg_4_0_addr0;
  wire [63:0] cl_rg_4_0_d0;
  wire [63:0] cl_rg_4_0_q0;
  wire cl_rg_4_0_ce0;
  wire cl_rg_4_0_we0;
  wire [11:0] cl_rg_4_0_addr1;
  wire [63:0] cl_rg_4_0_d1;
  wire [63:0] cl_rg_4_0_q1;
  wire cl_rg_4_0_ce1;
  wire cl_rg_4_0_we1;

  wire [11:0] cl_rg_4_1_addr0;
  wire [63:0] cl_rg_4_1_d0;
  wire [63:0] cl_rg_4_1_q0;
  wire cl_rg_4_1_ce0;
  wire cl_rg_4_1_we0;
  wire [11:0] cl_rg_4_1_addr1;
  wire [63:0] cl_rg_4_1_d1;
  wire [63:0] cl_rg_4_1_q1;
  wire cl_rg_4_1_ce1;
  wire cl_rg_4_1_we1;

  wire [11:0] cl_rg_4_2_addr0;
  wire [63:0] cl_rg_4_2_d0;
  wire [63:0] cl_rg_4_2_q0;
  wire cl_rg_4_2_ce0;
  wire cl_rg_4_2_we0;
  wire [11:0] cl_rg_4_2_addr1;
  wire [63:0] cl_rg_4_2_d1;
  wire [63:0] cl_rg_4_2_q1;
  wire cl_rg_4_2_ce1;
  wire cl_rg_4_2_we1;

  wire [11:0] cl_rg_4_3_addr0;
  wire [63:0] cl_rg_4_3_d0;
  wire [63:0] cl_rg_4_3_q0;
  wire cl_rg_4_3_ce0;
  wire cl_rg_4_3_we0;
  wire [11:0] cl_rg_4_3_addr1;
  wire [63:0] cl_rg_4_3_d1;
  wire [63:0] cl_rg_4_3_q1;
  wire cl_rg_4_3_ce1;
  wire cl_rg_4_3_we1;

  wire [11:0] cl_rg_5_0_addr0;
  wire [63:0] cl_rg_5_0_d0;
  wire [63:0] cl_rg_5_0_q0;
  wire cl_rg_5_0_ce0;
  wire cl_rg_5_0_we0;
  wire [11:0] cl_rg_5_0_addr1;
  wire [63:0] cl_rg_5_0_d1;
  wire [63:0] cl_rg_5_0_q1;
  wire cl_rg_5_0_ce1;
  wire cl_rg_5_0_we1;

  wire [11:0] cl_rg_5_1_addr0;
  wire [63:0] cl_rg_5_1_d0;
  wire [63:0] cl_rg_5_1_q0;
  wire cl_rg_5_1_ce0;
  wire cl_rg_5_1_we0;
  wire [11:0] cl_rg_5_1_addr1;
  wire [63:0] cl_rg_5_1_d1;
  wire [63:0] cl_rg_5_1_q1;
  wire cl_rg_5_1_ce1;
  wire cl_rg_5_1_we1;

  wire [11:0] cl_rg_5_2_addr0;
  wire [63:0] cl_rg_5_2_d0;
  wire [63:0] cl_rg_5_2_q0;
  wire cl_rg_5_2_ce0;
  wire cl_rg_5_2_we0;
  wire [11:0] cl_rg_5_2_addr1;
  wire [63:0] cl_rg_5_2_d1;
  wire [63:0] cl_rg_5_2_q1;
  wire cl_rg_5_2_ce1;
  wire cl_rg_5_2_we1;

  wire [11:0] cl_rg_5_3_addr0;
  wire [63:0] cl_rg_5_3_d0;
  wire [63:0] cl_rg_5_3_q0;
  wire cl_rg_5_3_ce0;
  wire cl_rg_5_3_we0;
  wire [11:0] cl_rg_5_3_addr1;
  wire [63:0] cl_rg_5_3_d1;
  wire [63:0] cl_rg_5_3_q1;
  wire cl_rg_5_3_ce1;
  wire cl_rg_5_3_we1;

  wire [11:0] cl_rg_6_0_addr0;
  wire [63:0] cl_rg_6_0_d0;
  wire [63:0] cl_rg_6_0_q0;
  wire cl_rg_6_0_ce0;
  wire cl_rg_6_0_we0;
  wire [11:0] cl_rg_6_0_addr1;
  wire [63:0] cl_rg_6_0_d1;
  wire [63:0] cl_rg_6_0_q1;
  wire cl_rg_6_0_ce1;
  wire cl_rg_6_0_we1;

  wire [11:0] cl_rg_6_1_addr0;
  wire [63:0] cl_rg_6_1_d0;
  wire [63:0] cl_rg_6_1_q0;
  wire cl_rg_6_1_ce0;
  wire cl_rg_6_1_we0;
  wire [11:0] cl_rg_6_1_addr1;
  wire [63:0] cl_rg_6_1_d1;
  wire [63:0] cl_rg_6_1_q1;
  wire cl_rg_6_1_ce1;
  wire cl_rg_6_1_we1;

  wire [11:0] cl_rg_6_2_addr0;
  wire [63:0] cl_rg_6_2_d0;
  wire [63:0] cl_rg_6_2_q0;
  wire cl_rg_6_2_ce0;
  wire cl_rg_6_2_we0;
  wire [11:0] cl_rg_6_2_addr1;
  wire [63:0] cl_rg_6_2_d1;
  wire [63:0] cl_rg_6_2_q1;
  wire cl_rg_6_2_ce1;
  wire cl_rg_6_2_we1;

  wire [11:0] cl_rg_6_3_addr0;
  wire [63:0] cl_rg_6_3_d0;
  wire [63:0] cl_rg_6_3_q0;
  wire cl_rg_6_3_ce0;
  wire cl_rg_6_3_we0;
  wire [11:0] cl_rg_6_3_addr1;
  wire [63:0] cl_rg_6_3_d1;
  wire [63:0] cl_rg_6_3_q1;
  wire cl_rg_6_3_ce1;
  wire cl_rg_6_3_we1;

  wire [11:0] cl_rg_7_0_addr0;
  wire [63:0] cl_rg_7_0_d0;
  wire [63:0] cl_rg_7_0_q0;
  wire cl_rg_7_0_ce0;
  wire cl_rg_7_0_we0;
  wire [11:0] cl_rg_7_0_addr1;
  wire [63:0] cl_rg_7_0_d1;
  wire [63:0] cl_rg_7_0_q1;
  wire cl_rg_7_0_ce1;
  wire cl_rg_7_0_we1;

  wire [11:0] cl_rg_7_1_addr0;
  wire [63:0] cl_rg_7_1_d0;
  wire [63:0] cl_rg_7_1_q0;
  wire cl_rg_7_1_ce0;
  wire cl_rg_7_1_we0;
  wire [11:0] cl_rg_7_1_addr1;
  wire [63:0] cl_rg_7_1_d1;
  wire [63:0] cl_rg_7_1_q1;
  wire cl_rg_7_1_ce1;
  wire cl_rg_7_1_we1;

  wire [11:0] cl_rg_7_2_addr0;
  wire [63:0] cl_rg_7_2_d0;
  wire [63:0] cl_rg_7_2_q0;
  wire cl_rg_7_2_ce0;
  wire cl_rg_7_2_we0;
  wire [11:0] cl_rg_7_2_addr1;
  wire [63:0] cl_rg_7_2_d1;
  wire [63:0] cl_rg_7_2_q1;
  wire cl_rg_7_2_ce1;
  wire cl_rg_7_2_we1;

  wire [11:0] cl_rg_7_3_addr0;
  wire [63:0] cl_rg_7_3_d0;
  wire [63:0] cl_rg_7_3_q0;
  wire cl_rg_7_3_ce0;
  wire cl_rg_7_3_we0;
  wire [11:0] cl_rg_7_3_addr1;
  wire [63:0] cl_rg_7_3_d1;
  wire [63:0] cl_rg_7_3_q1;
  wire cl_rg_7_3_ce1;
  wire cl_rg_7_3_we1;

  wire [11:0] cl_rg_8_0_addr0;
  wire [63:0] cl_rg_8_0_d0;
  wire [63:0] cl_rg_8_0_q0;
  wire cl_rg_8_0_ce0;
  wire cl_rg_8_0_we0;
  wire [11:0] cl_rg_8_0_addr1;
  wire [63:0] cl_rg_8_0_d1;
  wire [63:0] cl_rg_8_0_q1;
  wire cl_rg_8_0_ce1;
  wire cl_rg_8_0_we1;

  wire [11:0] cl_rg_8_1_addr0;
  wire [63:0] cl_rg_8_1_d0;
  wire [63:0] cl_rg_8_1_q0;
  wire cl_rg_8_1_ce0;
  wire cl_rg_8_1_we0;
  wire [11:0] cl_rg_8_1_addr1;
  wire [63:0] cl_rg_8_1_d1;
  wire [63:0] cl_rg_8_1_q1;
  wire cl_rg_8_1_ce1;
  wire cl_rg_8_1_we1;

  wire [11:0] cl_rg_8_2_addr0;
  wire [63:0] cl_rg_8_2_d0;
  wire [63:0] cl_rg_8_2_q0;
  wire cl_rg_8_2_ce0;
  wire cl_rg_8_2_we0;
  wire [11:0] cl_rg_8_2_addr1;
  wire [63:0] cl_rg_8_2_d1;
  wire [63:0] cl_rg_8_2_q1;
  wire cl_rg_8_2_ce1;
  wire cl_rg_8_2_we1;

  wire [11:0] cl_rg_8_3_addr0;
  wire [63:0] cl_rg_8_3_d0;
  wire [63:0] cl_rg_8_3_q0;
  wire cl_rg_8_3_ce0;
  wire cl_rg_8_3_we0;
  wire [11:0] cl_rg_8_3_addr1;
  wire [63:0] cl_rg_8_3_d1;
  wire [63:0] cl_rg_8_3_q1;
  wire cl_rg_8_3_ce1;
  wire cl_rg_8_3_we1;

  wire [11:0] cl_rg_9_0_addr0;
  wire [63:0] cl_rg_9_0_d0;
  wire [63:0] cl_rg_9_0_q0;
  wire cl_rg_9_0_ce0;
  wire cl_rg_9_0_we0;
  wire [11:0] cl_rg_9_0_addr1;
  wire [63:0] cl_rg_9_0_d1;
  wire [63:0] cl_rg_9_0_q1;
  wire cl_rg_9_0_ce1;
  wire cl_rg_9_0_we1;

  wire [11:0] cl_rg_9_1_addr0;
  wire [63:0] cl_rg_9_1_d0;
  wire [63:0] cl_rg_9_1_q0;
  wire cl_rg_9_1_ce0;
  wire cl_rg_9_1_we0;
  wire [11:0] cl_rg_9_1_addr1;
  wire [63:0] cl_rg_9_1_d1;
  wire [63:0] cl_rg_9_1_q1;
  wire cl_rg_9_1_ce1;
  wire cl_rg_9_1_we1;

  wire [11:0] cl_rg_9_2_addr0;
  wire [63:0] cl_rg_9_2_d0;
  wire [63:0] cl_rg_9_2_q0;
  wire cl_rg_9_2_ce0;
  wire cl_rg_9_2_we0;
  wire [11:0] cl_rg_9_2_addr1;
  wire [63:0] cl_rg_9_2_d1;
  wire [63:0] cl_rg_9_2_q1;
  wire cl_rg_9_2_ce1;
  wire cl_rg_9_2_we1;

  wire [11:0] cl_rg_9_3_addr0;
  wire [63:0] cl_rg_9_3_d0;
  wire [63:0] cl_rg_9_3_q0;
  wire cl_rg_9_3_ce0;
  wire cl_rg_9_3_we0;
  wire [11:0] cl_rg_9_3_addr1;
  wire [63:0] cl_rg_9_3_d1;
  wire [63:0] cl_rg_9_3_q1;
  wire cl_rg_9_3_ce1;
  wire cl_rg_9_3_we1;

  wire [11:0] cl_rg_10_0_addr0;
  wire [63:0] cl_rg_10_0_d0;
  wire [63:0] cl_rg_10_0_q0;
  wire cl_rg_10_0_ce0;
  wire cl_rg_10_0_we0;
  wire [11:0] cl_rg_10_0_addr1;
  wire [63:0] cl_rg_10_0_d1;
  wire [63:0] cl_rg_10_0_q1;
  wire cl_rg_10_0_ce1;
  wire cl_rg_10_0_we1;

  wire [11:0] cl_rg_10_1_addr0;
  wire [63:0] cl_rg_10_1_d0;
  wire [63:0] cl_rg_10_1_q0;
  wire cl_rg_10_1_ce0;
  wire cl_rg_10_1_we0;
  wire [11:0] cl_rg_10_1_addr1;
  wire [63:0] cl_rg_10_1_d1;
  wire [63:0] cl_rg_10_1_q1;
  wire cl_rg_10_1_ce1;
  wire cl_rg_10_1_we1;

  wire [11:0] cl_rg_10_2_addr0;
  wire [63:0] cl_rg_10_2_d0;
  wire [63:0] cl_rg_10_2_q0;
  wire cl_rg_10_2_ce0;
  wire cl_rg_10_2_we0;
  wire [11:0] cl_rg_10_2_addr1;
  wire [63:0] cl_rg_10_2_d1;
  wire [63:0] cl_rg_10_2_q1;
  wire cl_rg_10_2_ce1;
  wire cl_rg_10_2_we1;

  wire [11:0] cl_rg_10_3_addr0;
  wire [63:0] cl_rg_10_3_d0;
  wire [63:0] cl_rg_10_3_q0;
  wire cl_rg_10_3_ce0;
  wire cl_rg_10_3_we0;
  wire [11:0] cl_rg_10_3_addr1;
  wire [63:0] cl_rg_10_3_d1;
  wire [63:0] cl_rg_10_3_q1;
  wire cl_rg_10_3_ce1;
  wire cl_rg_10_3_we1;

  wire [11:0] cl_rg_11_0_addr0;
  wire [63:0] cl_rg_11_0_d0;
  wire [63:0] cl_rg_11_0_q0;
  wire cl_rg_11_0_ce0;
  wire cl_rg_11_0_we0;
  wire [11:0] cl_rg_11_0_addr1;
  wire [63:0] cl_rg_11_0_d1;
  wire [63:0] cl_rg_11_0_q1;
  wire cl_rg_11_0_ce1;
  wire cl_rg_11_0_we1;

  wire [11:0] cl_rg_11_1_addr0;
  wire [63:0] cl_rg_11_1_d0;
  wire [63:0] cl_rg_11_1_q0;
  wire cl_rg_11_1_ce0;
  wire cl_rg_11_1_we0;
  wire [11:0] cl_rg_11_1_addr1;
  wire [63:0] cl_rg_11_1_d1;
  wire [63:0] cl_rg_11_1_q1;
  wire cl_rg_11_1_ce1;
  wire cl_rg_11_1_we1;

  wire [11:0] cl_rg_11_2_addr0;
  wire [63:0] cl_rg_11_2_d0;
  wire [63:0] cl_rg_11_2_q0;
  wire cl_rg_11_2_ce0;
  wire cl_rg_11_2_we0;
  wire [11:0] cl_rg_11_2_addr1;
  wire [63:0] cl_rg_11_2_d1;
  wire [63:0] cl_rg_11_2_q1;
  wire cl_rg_11_2_ce1;
  wire cl_rg_11_2_we1;

  wire [11:0] cl_rg_11_3_addr0;
  wire [63:0] cl_rg_11_3_d0;
  wire [63:0] cl_rg_11_3_q0;
  wire cl_rg_11_3_ce0;
  wire cl_rg_11_3_we0;
  wire [11:0] cl_rg_11_3_addr1;
  wire [63:0] cl_rg_11_3_d1;
  wire [63:0] cl_rg_11_3_q1;
  wire cl_rg_11_3_ce1;
  wire cl_rg_11_3_we1;

  wire [11:0] cl_rg_12_0_addr0;
  wire [63:0] cl_rg_12_0_d0;
  wire [63:0] cl_rg_12_0_q0;
  wire cl_rg_12_0_ce0;
  wire cl_rg_12_0_we0;
  wire [11:0] cl_rg_12_0_addr1;
  wire [63:0] cl_rg_12_0_d1;
  wire [63:0] cl_rg_12_0_q1;
  wire cl_rg_12_0_ce1;
  wire cl_rg_12_0_we1;

  wire [11:0] cl_rg_12_1_addr0;
  wire [63:0] cl_rg_12_1_d0;
  wire [63:0] cl_rg_12_1_q0;
  wire cl_rg_12_1_ce0;
  wire cl_rg_12_1_we0;
  wire [11:0] cl_rg_12_1_addr1;
  wire [63:0] cl_rg_12_1_d1;
  wire [63:0] cl_rg_12_1_q1;
  wire cl_rg_12_1_ce1;
  wire cl_rg_12_1_we1;

  wire [11:0] cl_rg_12_2_addr0;
  wire [63:0] cl_rg_12_2_d0;
  wire [63:0] cl_rg_12_2_q0;
  wire cl_rg_12_2_ce0;
  wire cl_rg_12_2_we0;
  wire [11:0] cl_rg_12_2_addr1;
  wire [63:0] cl_rg_12_2_d1;
  wire [63:0] cl_rg_12_2_q1;
  wire cl_rg_12_2_ce1;
  wire cl_rg_12_2_we1;

  wire [11:0] cl_rg_12_3_addr0;
  wire [63:0] cl_rg_12_3_d0;
  wire [63:0] cl_rg_12_3_q0;
  wire cl_rg_12_3_ce0;
  wire cl_rg_12_3_we0;
  wire [11:0] cl_rg_12_3_addr1;
  wire [63:0] cl_rg_12_3_d1;
  wire [63:0] cl_rg_12_3_q1;
  wire cl_rg_12_3_ce1;
  wire cl_rg_12_3_we1;

  wire [11:0] cl_rg_13_0_addr0;
  wire [63:0] cl_rg_13_0_d0;
  wire [63:0] cl_rg_13_0_q0;
  wire cl_rg_13_0_ce0;
  wire cl_rg_13_0_we0;
  wire [11:0] cl_rg_13_0_addr1;
  wire [63:0] cl_rg_13_0_d1;
  wire [63:0] cl_rg_13_0_q1;
  wire cl_rg_13_0_ce1;
  wire cl_rg_13_0_we1;

  wire [11:0] cl_rg_13_1_addr0;
  wire [63:0] cl_rg_13_1_d0;
  wire [63:0] cl_rg_13_1_q0;
  wire cl_rg_13_1_ce0;
  wire cl_rg_13_1_we0;
  wire [11:0] cl_rg_13_1_addr1;
  wire [63:0] cl_rg_13_1_d1;
  wire [63:0] cl_rg_13_1_q1;
  wire cl_rg_13_1_ce1;
  wire cl_rg_13_1_we1;

  wire [11:0] cl_rg_13_2_addr0;
  wire [63:0] cl_rg_13_2_d0;
  wire [63:0] cl_rg_13_2_q0;
  wire cl_rg_13_2_ce0;
  wire cl_rg_13_2_we0;
  wire [11:0] cl_rg_13_2_addr1;
  wire [63:0] cl_rg_13_2_d1;
  wire [63:0] cl_rg_13_2_q1;
  wire cl_rg_13_2_ce1;
  wire cl_rg_13_2_we1;

  wire [11:0] cl_rg_13_3_addr0;
  wire [63:0] cl_rg_13_3_d0;
  wire [63:0] cl_rg_13_3_q0;
  wire cl_rg_13_3_ce0;
  wire cl_rg_13_3_we0;
  wire [11:0] cl_rg_13_3_addr1;
  wire [63:0] cl_rg_13_3_d1;
  wire [63:0] cl_rg_13_3_q1;
  wire cl_rg_13_3_ce1;
  wire cl_rg_13_3_we1;

  wire [11:0] cl_rg_14_0_addr0;
  wire [63:0] cl_rg_14_0_d0;
  wire [63:0] cl_rg_14_0_q0;
  wire cl_rg_14_0_ce0;
  wire cl_rg_14_0_we0;
  wire [11:0] cl_rg_14_0_addr1;
  wire [63:0] cl_rg_14_0_d1;
  wire [63:0] cl_rg_14_0_q1;
  wire cl_rg_14_0_ce1;
  wire cl_rg_14_0_we1;

  wire [11:0] cl_rg_14_1_addr0;
  wire [63:0] cl_rg_14_1_d0;
  wire [63:0] cl_rg_14_1_q0;
  wire cl_rg_14_1_ce0;
  wire cl_rg_14_1_we0;
  wire [11:0] cl_rg_14_1_addr1;
  wire [63:0] cl_rg_14_1_d1;
  wire [63:0] cl_rg_14_1_q1;
  wire cl_rg_14_1_ce1;
  wire cl_rg_14_1_we1;

  wire [11:0] cl_rg_14_2_addr0;
  wire [63:0] cl_rg_14_2_d0;
  wire [63:0] cl_rg_14_2_q0;
  wire cl_rg_14_2_ce0;
  wire cl_rg_14_2_we0;
  wire [11:0] cl_rg_14_2_addr1;
  wire [63:0] cl_rg_14_2_d1;
  wire [63:0] cl_rg_14_2_q1;
  wire cl_rg_14_2_ce1;
  wire cl_rg_14_2_we1;

  wire [11:0] cl_rg_14_3_addr0;
  wire [63:0] cl_rg_14_3_d0;
  wire [63:0] cl_rg_14_3_q0;
  wire cl_rg_14_3_ce0;
  wire cl_rg_14_3_we0;
  wire [11:0] cl_rg_14_3_addr1;
  wire [63:0] cl_rg_14_3_d1;
  wire [63:0] cl_rg_14_3_q1;
  wire cl_rg_14_3_ce1;
  wire cl_rg_14_3_we1;

  wire [11:0] cl_rg_15_0_addr0;
  wire [63:0] cl_rg_15_0_d0;
  wire [63:0] cl_rg_15_0_q0;
  wire cl_rg_15_0_ce0;
  wire cl_rg_15_0_we0;
  wire [11:0] cl_rg_15_0_addr1;
  wire [63:0] cl_rg_15_0_d1;
  wire [63:0] cl_rg_15_0_q1;
  wire cl_rg_15_0_ce1;
  wire cl_rg_15_0_we1;

  wire [11:0] cl_rg_15_1_addr0;
  wire [63:0] cl_rg_15_1_d0;
  wire [63:0] cl_rg_15_1_q0;
  wire cl_rg_15_1_ce0;
  wire cl_rg_15_1_we0;
  wire [11:0] cl_rg_15_1_addr1;
  wire [63:0] cl_rg_15_1_d1;
  wire [63:0] cl_rg_15_1_q1;
  wire cl_rg_15_1_ce1;
  wire cl_rg_15_1_we1;

  wire [11:0] cl_rg_15_2_addr0;
  wire [63:0] cl_rg_15_2_d0;
  wire [63:0] cl_rg_15_2_q0;
  wire cl_rg_15_2_ce0;
  wire cl_rg_15_2_we0;
  wire [11:0] cl_rg_15_2_addr1;
  wire [63:0] cl_rg_15_2_d1;
  wire [63:0] cl_rg_15_2_q1;
  wire cl_rg_15_2_ce1;
  wire cl_rg_15_2_we1;

  wire [11:0] cl_rg_15_3_addr0;
  wire [63:0] cl_rg_15_3_d0;
  wire [63:0] cl_rg_15_3_q0;
  wire cl_rg_15_3_ce0;
  wire cl_rg_15_3_we0;
  wire [11:0] cl_rg_15_3_addr1;
  wire [63:0] cl_rg_15_3_d1;
  wire [63:0] cl_rg_15_3_q1;
  wire cl_rg_15_3_ce1;
  wire cl_rg_15_3_we1;

  wire [11:0] cl_rg_16_0_addr0;
  wire [63:0] cl_rg_16_0_d0;
  wire [63:0] cl_rg_16_0_q0;
  wire cl_rg_16_0_ce0;
  wire cl_rg_16_0_we0;
  wire [11:0] cl_rg_16_0_addr1;
  wire [63:0] cl_rg_16_0_d1;
  wire [63:0] cl_rg_16_0_q1;
  wire cl_rg_16_0_ce1;
  wire cl_rg_16_0_we1;

  wire [11:0] cl_rg_16_1_addr0;
  wire [63:0] cl_rg_16_1_d0;
  wire [63:0] cl_rg_16_1_q0;
  wire cl_rg_16_1_ce0;
  wire cl_rg_16_1_we0;
  wire [11:0] cl_rg_16_1_addr1;
  wire [63:0] cl_rg_16_1_d1;
  wire [63:0] cl_rg_16_1_q1;
  wire cl_rg_16_1_ce1;
  wire cl_rg_16_1_we1;

  wire [11:0] cl_rg_16_2_addr0;
  wire [63:0] cl_rg_16_2_d0;
  wire [63:0] cl_rg_16_2_q0;
  wire cl_rg_16_2_ce0;
  wire cl_rg_16_2_we0;
  wire [11:0] cl_rg_16_2_addr1;
  wire [63:0] cl_rg_16_2_d1;
  wire [63:0] cl_rg_16_2_q1;
  wire cl_rg_16_2_ce1;
  wire cl_rg_16_2_we1;

  wire [11:0] cl_rg_16_3_addr0;
  wire [63:0] cl_rg_16_3_d0;
  wire [63:0] cl_rg_16_3_q0;
  wire cl_rg_16_3_ce0;
  wire cl_rg_16_3_we0;
  wire [11:0] cl_rg_16_3_addr1;
  wire [63:0] cl_rg_16_3_d1;
  wire [63:0] cl_rg_16_3_q1;
  wire cl_rg_16_3_ce1;
  wire cl_rg_16_3_we1;

  wire [11:0] cl_rg_17_0_addr0;
  wire [63:0] cl_rg_17_0_d0;
  wire [63:0] cl_rg_17_0_q0;
  wire cl_rg_17_0_ce0;
  wire cl_rg_17_0_we0;
  wire [11:0] cl_rg_17_0_addr1;
  wire [63:0] cl_rg_17_0_d1;
  wire [63:0] cl_rg_17_0_q1;
  wire cl_rg_17_0_ce1;
  wire cl_rg_17_0_we1;

  wire [11:0] cl_rg_17_1_addr0;
  wire [63:0] cl_rg_17_1_d0;
  wire [63:0] cl_rg_17_1_q0;
  wire cl_rg_17_1_ce0;
  wire cl_rg_17_1_we0;
  wire [11:0] cl_rg_17_1_addr1;
  wire [63:0] cl_rg_17_1_d1;
  wire [63:0] cl_rg_17_1_q1;
  wire cl_rg_17_1_ce1;
  wire cl_rg_17_1_we1;

  wire [11:0] cl_rg_17_2_addr0;
  wire [63:0] cl_rg_17_2_d0;
  wire [63:0] cl_rg_17_2_q0;
  wire cl_rg_17_2_ce0;
  wire cl_rg_17_2_we0;
  wire [11:0] cl_rg_17_2_addr1;
  wire [63:0] cl_rg_17_2_d1;
  wire [63:0] cl_rg_17_2_q1;
  wire cl_rg_17_2_ce1;
  wire cl_rg_17_2_we1;

  wire [11:0] cl_rg_17_3_addr0;
  wire [63:0] cl_rg_17_3_d0;
  wire [63:0] cl_rg_17_3_q0;
  wire cl_rg_17_3_ce0;
  wire cl_rg_17_3_we0;
  wire [11:0] cl_rg_17_3_addr1;
  wire [63:0] cl_rg_17_3_d1;
  wire [63:0] cl_rg_17_3_q1;
  wire cl_rg_17_3_ce1;
  wire cl_rg_17_3_we1;

  wire [11:0] cl_rg_18_0_addr0;
  wire [63:0] cl_rg_18_0_d0;
  wire [63:0] cl_rg_18_0_q0;
  wire cl_rg_18_0_ce0;
  wire cl_rg_18_0_we0;
  wire [11:0] cl_rg_18_0_addr1;
  wire [63:0] cl_rg_18_0_d1;
  wire [63:0] cl_rg_18_0_q1;
  wire cl_rg_18_0_ce1;
  wire cl_rg_18_0_we1;

  wire [11:0] cl_rg_18_1_addr0;
  wire [63:0] cl_rg_18_1_d0;
  wire [63:0] cl_rg_18_1_q0;
  wire cl_rg_18_1_ce0;
  wire cl_rg_18_1_we0;
  wire [11:0] cl_rg_18_1_addr1;
  wire [63:0] cl_rg_18_1_d1;
  wire [63:0] cl_rg_18_1_q1;
  wire cl_rg_18_1_ce1;
  wire cl_rg_18_1_we1;

  wire [11:0] cl_rg_18_2_addr0;
  wire [63:0] cl_rg_18_2_d0;
  wire [63:0] cl_rg_18_2_q0;
  wire cl_rg_18_2_ce0;
  wire cl_rg_18_2_we0;
  wire [11:0] cl_rg_18_2_addr1;
  wire [63:0] cl_rg_18_2_d1;
  wire [63:0] cl_rg_18_2_q1;
  wire cl_rg_18_2_ce1;
  wire cl_rg_18_2_we1;

  wire [11:0] cl_rg_18_3_addr0;
  wire [63:0] cl_rg_18_3_d0;
  wire [63:0] cl_rg_18_3_q0;
  wire cl_rg_18_3_ce0;
  wire cl_rg_18_3_we0;
  wire [11:0] cl_rg_18_3_addr1;
  wire [63:0] cl_rg_18_3_d1;
  wire [63:0] cl_rg_18_3_q1;
  wire cl_rg_18_3_ce1;
  wire cl_rg_18_3_we1;

  wire [11:0] cl_rg_19_0_addr0;
  wire [63:0] cl_rg_19_0_d0;
  wire [63:0] cl_rg_19_0_q0;
  wire cl_rg_19_0_ce0;
  wire cl_rg_19_0_we0;
  wire [11:0] cl_rg_19_0_addr1;
  wire [63:0] cl_rg_19_0_d1;
  wire [63:0] cl_rg_19_0_q1;
  wire cl_rg_19_0_ce1;
  wire cl_rg_19_0_we1;

  wire [11:0] cl_rg_19_1_addr0;
  wire [63:0] cl_rg_19_1_d0;
  wire [63:0] cl_rg_19_1_q0;
  wire cl_rg_19_1_ce0;
  wire cl_rg_19_1_we0;
  wire [11:0] cl_rg_19_1_addr1;
  wire [63:0] cl_rg_19_1_d1;
  wire [63:0] cl_rg_19_1_q1;
  wire cl_rg_19_1_ce1;
  wire cl_rg_19_1_we1;

  wire [11:0] cl_rg_19_2_addr0;
  wire [63:0] cl_rg_19_2_d0;
  wire [63:0] cl_rg_19_2_q0;
  wire cl_rg_19_2_ce0;
  wire cl_rg_19_2_we0;
  wire [11:0] cl_rg_19_2_addr1;
  wire [63:0] cl_rg_19_2_d1;
  wire [63:0] cl_rg_19_2_q1;
  wire cl_rg_19_2_ce1;
  wire cl_rg_19_2_we1;

  wire [11:0] cl_rg_19_3_addr0;
  wire [63:0] cl_rg_19_3_d0;
  wire [63:0] cl_rg_19_3_q0;
  wire cl_rg_19_3_ce0;
  wire cl_rg_19_3_we0;
  wire [11:0] cl_rg_19_3_addr1;
  wire [63:0] cl_rg_19_3_d1;
  wire [63:0] cl_rg_19_3_q1;
  wire cl_rg_19_3_ce1;
  wire cl_rg_19_3_we1;

  wire [11:0] cl_rg_20_0_addr0;
  wire [63:0] cl_rg_20_0_d0;
  wire [63:0] cl_rg_20_0_q0;
  wire cl_rg_20_0_ce0;
  wire cl_rg_20_0_we0;
  wire [11:0] cl_rg_20_0_addr1;
  wire [63:0] cl_rg_20_0_d1;
  wire [63:0] cl_rg_20_0_q1;
  wire cl_rg_20_0_ce1;
  wire cl_rg_20_0_we1;

  wire [11:0] cl_rg_20_1_addr0;
  wire [63:0] cl_rg_20_1_d0;
  wire [63:0] cl_rg_20_1_q0;
  wire cl_rg_20_1_ce0;
  wire cl_rg_20_1_we0;
  wire [11:0] cl_rg_20_1_addr1;
  wire [63:0] cl_rg_20_1_d1;
  wire [63:0] cl_rg_20_1_q1;
  wire cl_rg_20_1_ce1;
  wire cl_rg_20_1_we1;

  wire [11:0] cl_rg_20_2_addr0;
  wire [63:0] cl_rg_20_2_d0;
  wire [63:0] cl_rg_20_2_q0;
  wire cl_rg_20_2_ce0;
  wire cl_rg_20_2_we0;
  wire [11:0] cl_rg_20_2_addr1;
  wire [63:0] cl_rg_20_2_d1;
  wire [63:0] cl_rg_20_2_q1;
  wire cl_rg_20_2_ce1;
  wire cl_rg_20_2_we1;

  wire [11:0] cl_rg_20_3_addr0;
  wire [63:0] cl_rg_20_3_d0;
  wire [63:0] cl_rg_20_3_q0;
  wire cl_rg_20_3_ce0;
  wire cl_rg_20_3_we0;
  wire [11:0] cl_rg_20_3_addr1;
  wire [63:0] cl_rg_20_3_d1;
  wire [63:0] cl_rg_20_3_q1;
  wire cl_rg_20_3_ce1;
  wire cl_rg_20_3_we1;

  (* KEEP_HIERARCHY = "yes" *)
  //(* DONT_TOUCH="yes" *)
  custom_logic custom_logic (
    .cl_rg_0_0_addr0(cl_rg_0_0_addr0),
    .cl_rg_0_0_d0(cl_rg_0_0_d0),
    .cl_rg_0_0_q0(cl_rg_0_0_q0),
    .cl_rg_0_0_ce0(cl_rg_0_0_ce0),
    .cl_rg_0_0_we0(cl_rg_0_0_we0),
    .cl_rg_0_0_addr1(cl_rg_0_0_addr1),
    .cl_rg_0_0_d1(cl_rg_0_0_d1),
    .cl_rg_0_0_q1(cl_rg_0_0_q1),
    .cl_rg_0_0_ce1(cl_rg_0_0_ce1),
    .cl_rg_0_0_we1(cl_rg_0_0_we1),

    .cl_rg_0_1_addr0(cl_rg_0_1_addr0),
    .cl_rg_0_1_d0(cl_rg_0_1_d0),
    .cl_rg_0_1_q0(cl_rg_0_1_q0),
    .cl_rg_0_1_ce0(cl_rg_0_1_ce0),
    .cl_rg_0_1_we0(cl_rg_0_1_we0),
    .cl_rg_0_1_addr1(cl_rg_0_1_addr1),
    .cl_rg_0_1_d1(cl_rg_0_1_d1),
    .cl_rg_0_1_q1(cl_rg_0_1_q1),
    .cl_rg_0_1_ce1(cl_rg_0_1_ce1),
    .cl_rg_0_1_we1(cl_rg_0_1_we1),

    .cl_rg_0_2_addr0(cl_rg_0_2_addr0),
    .cl_rg_0_2_d0(cl_rg_0_2_d0),
    .cl_rg_0_2_q0(cl_rg_0_2_q0),
    .cl_rg_0_2_ce0(cl_rg_0_2_ce0),
    .cl_rg_0_2_we0(cl_rg_0_2_we0),
    .cl_rg_0_2_addr1(cl_rg_0_2_addr1),
    .cl_rg_0_2_d1(cl_rg_0_2_d1),
    .cl_rg_0_2_q1(cl_rg_0_2_q1),
    .cl_rg_0_2_ce1(cl_rg_0_2_ce1),
    .cl_rg_0_2_we1(cl_rg_0_2_we1),

    .cl_rg_0_3_addr0(cl_rg_0_3_addr0),
    .cl_rg_0_3_d0(cl_rg_0_3_d0),
    .cl_rg_0_3_q0(cl_rg_0_3_q0),
    .cl_rg_0_3_ce0(cl_rg_0_3_ce0),
    .cl_rg_0_3_we0(cl_rg_0_3_we0),
    .cl_rg_0_3_addr1(cl_rg_0_3_addr1),
    .cl_rg_0_3_d1(cl_rg_0_3_d1),
    .cl_rg_0_3_q1(cl_rg_0_3_q1),
    .cl_rg_0_3_ce1(cl_rg_0_3_ce1),
    .cl_rg_0_3_we1(cl_rg_0_3_we1),

    .cl_rg_1_0_addr0(cl_rg_1_0_addr0),
    .cl_rg_1_0_d0(cl_rg_1_0_d0),
    .cl_rg_1_0_q0(cl_rg_1_0_q0),
    .cl_rg_1_0_ce0(cl_rg_1_0_ce0),
    .cl_rg_1_0_we0(cl_rg_1_0_we0),
    .cl_rg_1_0_addr1(cl_rg_1_0_addr1),
    .cl_rg_1_0_d1(cl_rg_1_0_d1),
    .cl_rg_1_0_q1(cl_rg_1_0_q1),
    .cl_rg_1_0_ce1(cl_rg_1_0_ce1),
    .cl_rg_1_0_we1(cl_rg_1_0_we1),

    .cl_rg_1_1_addr0(cl_rg_1_1_addr0),
    .cl_rg_1_1_d0(cl_rg_1_1_d0),
    .cl_rg_1_1_q0(cl_rg_1_1_q0),
    .cl_rg_1_1_ce0(cl_rg_1_1_ce0),
    .cl_rg_1_1_we0(cl_rg_1_1_we0),
    .cl_rg_1_1_addr1(cl_rg_1_1_addr1),
    .cl_rg_1_1_d1(cl_rg_1_1_d1),
    .cl_rg_1_1_q1(cl_rg_1_1_q1),
    .cl_rg_1_1_ce1(cl_rg_1_1_ce1),
    .cl_rg_1_1_we1(cl_rg_1_1_we1),

    .cl_rg_1_2_addr0(cl_rg_1_2_addr0),
    .cl_rg_1_2_d0(cl_rg_1_2_d0),
    .cl_rg_1_2_q0(cl_rg_1_2_q0),
    .cl_rg_1_2_ce0(cl_rg_1_2_ce0),
    .cl_rg_1_2_we0(cl_rg_1_2_we0),
    .cl_rg_1_2_addr1(cl_rg_1_2_addr1),
    .cl_rg_1_2_d1(cl_rg_1_2_d1),
    .cl_rg_1_2_q1(cl_rg_1_2_q1),
    .cl_rg_1_2_ce1(cl_rg_1_2_ce1),
    .cl_rg_1_2_we1(cl_rg_1_2_we1),

    .cl_rg_1_3_addr0(cl_rg_1_3_addr0),
    .cl_rg_1_3_d0(cl_rg_1_3_d0),
    .cl_rg_1_3_q0(cl_rg_1_3_q0),
    .cl_rg_1_3_ce0(cl_rg_1_3_ce0),
    .cl_rg_1_3_we0(cl_rg_1_3_we0),
    .cl_rg_1_3_addr1(cl_rg_1_3_addr1),
    .cl_rg_1_3_d1(cl_rg_1_3_d1),
    .cl_rg_1_3_q1(cl_rg_1_3_q1),
    .cl_rg_1_3_ce1(cl_rg_1_3_ce1),
    .cl_rg_1_3_we1(cl_rg_1_3_we1),

    .cl_rg_2_0_addr0(cl_rg_2_0_addr0),
    .cl_rg_2_0_d0(cl_rg_2_0_d0),
    .cl_rg_2_0_q0(cl_rg_2_0_q0),
    .cl_rg_2_0_ce0(cl_rg_2_0_ce0),
    .cl_rg_2_0_we0(cl_rg_2_0_we0),
    .cl_rg_2_0_addr1(cl_rg_2_0_addr1),
    .cl_rg_2_0_d1(cl_rg_2_0_d1),
    .cl_rg_2_0_q1(cl_rg_2_0_q1),
    .cl_rg_2_0_ce1(cl_rg_2_0_ce1),
    .cl_rg_2_0_we1(cl_rg_2_0_we1),

    .cl_rg_2_1_addr0(cl_rg_2_1_addr0),
    .cl_rg_2_1_d0(cl_rg_2_1_d0),
    .cl_rg_2_1_q0(cl_rg_2_1_q0),
    .cl_rg_2_1_ce0(cl_rg_2_1_ce0),
    .cl_rg_2_1_we0(cl_rg_2_1_we0),
    .cl_rg_2_1_addr1(cl_rg_2_1_addr1),
    .cl_rg_2_1_d1(cl_rg_2_1_d1),
    .cl_rg_2_1_q1(cl_rg_2_1_q1),
    .cl_rg_2_1_ce1(cl_rg_2_1_ce1),
    .cl_rg_2_1_we1(cl_rg_2_1_we1),

    .cl_rg_2_2_addr0(cl_rg_2_2_addr0),
    .cl_rg_2_2_d0(cl_rg_2_2_d0),
    .cl_rg_2_2_q0(cl_rg_2_2_q0),
    .cl_rg_2_2_ce0(cl_rg_2_2_ce0),
    .cl_rg_2_2_we0(cl_rg_2_2_we0),
    .cl_rg_2_2_addr1(cl_rg_2_2_addr1),
    .cl_rg_2_2_d1(cl_rg_2_2_d1),
    .cl_rg_2_2_q1(cl_rg_2_2_q1),
    .cl_rg_2_2_ce1(cl_rg_2_2_ce1),
    .cl_rg_2_2_we1(cl_rg_2_2_we1),

    .cl_rg_2_3_addr0(cl_rg_2_3_addr0),
    .cl_rg_2_3_d0(cl_rg_2_3_d0),
    .cl_rg_2_3_q0(cl_rg_2_3_q0),
    .cl_rg_2_3_ce0(cl_rg_2_3_ce0),
    .cl_rg_2_3_we0(cl_rg_2_3_we0),
    .cl_rg_2_3_addr1(cl_rg_2_3_addr1),
    .cl_rg_2_3_d1(cl_rg_2_3_d1),
    .cl_rg_2_3_q1(cl_rg_2_3_q1),
    .cl_rg_2_3_ce1(cl_rg_2_3_ce1),
    .cl_rg_2_3_we1(cl_rg_2_3_we1),

    .cl_rg_3_0_addr0(cl_rg_3_0_addr0),
    .cl_rg_3_0_d0(cl_rg_3_0_d0),
    .cl_rg_3_0_q0(cl_rg_3_0_q0),
    .cl_rg_3_0_ce0(cl_rg_3_0_ce0),
    .cl_rg_3_0_we0(cl_rg_3_0_we0),
    .cl_rg_3_0_addr1(cl_rg_3_0_addr1),
    .cl_rg_3_0_d1(cl_rg_3_0_d1),
    .cl_rg_3_0_q1(cl_rg_3_0_q1),
    .cl_rg_3_0_ce1(cl_rg_3_0_ce1),
    .cl_rg_3_0_we1(cl_rg_3_0_we1),

    .cl_rg_3_1_addr0(cl_rg_3_1_addr0),
    .cl_rg_3_1_d0(cl_rg_3_1_d0),
    .cl_rg_3_1_q0(cl_rg_3_1_q0),
    .cl_rg_3_1_ce0(cl_rg_3_1_ce0),
    .cl_rg_3_1_we0(cl_rg_3_1_we0),
    .cl_rg_3_1_addr1(cl_rg_3_1_addr1),
    .cl_rg_3_1_d1(cl_rg_3_1_d1),
    .cl_rg_3_1_q1(cl_rg_3_1_q1),
    .cl_rg_3_1_ce1(cl_rg_3_1_ce1),
    .cl_rg_3_1_we1(cl_rg_3_1_we1),

    .cl_rg_3_2_addr0(cl_rg_3_2_addr0),
    .cl_rg_3_2_d0(cl_rg_3_2_d0),
    .cl_rg_3_2_q0(cl_rg_3_2_q0),
    .cl_rg_3_2_ce0(cl_rg_3_2_ce0),
    .cl_rg_3_2_we0(cl_rg_3_2_we0),
    .cl_rg_3_2_addr1(cl_rg_3_2_addr1),
    .cl_rg_3_2_d1(cl_rg_3_2_d1),
    .cl_rg_3_2_q1(cl_rg_3_2_q1),
    .cl_rg_3_2_ce1(cl_rg_3_2_ce1),
    .cl_rg_3_2_we1(cl_rg_3_2_we1),

    .cl_rg_3_3_addr0(cl_rg_3_3_addr0),
    .cl_rg_3_3_d0(cl_rg_3_3_d0),
    .cl_rg_3_3_q0(cl_rg_3_3_q0),
    .cl_rg_3_3_ce0(cl_rg_3_3_ce0),
    .cl_rg_3_3_we0(cl_rg_3_3_we0),
    .cl_rg_3_3_addr1(cl_rg_3_3_addr1),
    .cl_rg_3_3_d1(cl_rg_3_3_d1),
    .cl_rg_3_3_q1(cl_rg_3_3_q1),
    .cl_rg_3_3_ce1(cl_rg_3_3_ce1),
    .cl_rg_3_3_we1(cl_rg_3_3_we1),

    .cl_rg_4_0_addr0(cl_rg_4_0_addr0),
    .cl_rg_4_0_d0(cl_rg_4_0_d0),
    .cl_rg_4_0_q0(cl_rg_4_0_q0),
    .cl_rg_4_0_ce0(cl_rg_4_0_ce0),
    .cl_rg_4_0_we0(cl_rg_4_0_we0),
    .cl_rg_4_0_addr1(cl_rg_4_0_addr1),
    .cl_rg_4_0_d1(cl_rg_4_0_d1),
    .cl_rg_4_0_q1(cl_rg_4_0_q1),
    .cl_rg_4_0_ce1(cl_rg_4_0_ce1),
    .cl_rg_4_0_we1(cl_rg_4_0_we1),

    .cl_rg_4_1_addr0(cl_rg_4_1_addr0),
    .cl_rg_4_1_d0(cl_rg_4_1_d0),
    .cl_rg_4_1_q0(cl_rg_4_1_q0),
    .cl_rg_4_1_ce0(cl_rg_4_1_ce0),
    .cl_rg_4_1_we0(cl_rg_4_1_we0),
    .cl_rg_4_1_addr1(cl_rg_4_1_addr1),
    .cl_rg_4_1_d1(cl_rg_4_1_d1),
    .cl_rg_4_1_q1(cl_rg_4_1_q1),
    .cl_rg_4_1_ce1(cl_rg_4_1_ce1),
    .cl_rg_4_1_we1(cl_rg_4_1_we1),

    .cl_rg_4_2_addr0(cl_rg_4_2_addr0),
    .cl_rg_4_2_d0(cl_rg_4_2_d0),
    .cl_rg_4_2_q0(cl_rg_4_2_q0),
    .cl_rg_4_2_ce0(cl_rg_4_2_ce0),
    .cl_rg_4_2_we0(cl_rg_4_2_we0),
    .cl_rg_4_2_addr1(cl_rg_4_2_addr1),
    .cl_rg_4_2_d1(cl_rg_4_2_d1),
    .cl_rg_4_2_q1(cl_rg_4_2_q1),
    .cl_rg_4_2_ce1(cl_rg_4_2_ce1),
    .cl_rg_4_2_we1(cl_rg_4_2_we1),

    .cl_rg_4_3_addr0(cl_rg_4_3_addr0),
    .cl_rg_4_3_d0(cl_rg_4_3_d0),
    .cl_rg_4_3_q0(cl_rg_4_3_q0),
    .cl_rg_4_3_ce0(cl_rg_4_3_ce0),
    .cl_rg_4_3_we0(cl_rg_4_3_we0),
    .cl_rg_4_3_addr1(cl_rg_4_3_addr1),
    .cl_rg_4_3_d1(cl_rg_4_3_d1),
    .cl_rg_4_3_q1(cl_rg_4_3_q1),
    .cl_rg_4_3_ce1(cl_rg_4_3_ce1),
    .cl_rg_4_3_we1(cl_rg_4_3_we1),

    .cl_rg_5_0_addr0(cl_rg_5_0_addr0),
    .cl_rg_5_0_d0(cl_rg_5_0_d0),
    .cl_rg_5_0_q0(cl_rg_5_0_q0),
    .cl_rg_5_0_ce0(cl_rg_5_0_ce0),
    .cl_rg_5_0_we0(cl_rg_5_0_we0),
    .cl_rg_5_0_addr1(cl_rg_5_0_addr1),
    .cl_rg_5_0_d1(cl_rg_5_0_d1),
    .cl_rg_5_0_q1(cl_rg_5_0_q1),
    .cl_rg_5_0_ce1(cl_rg_5_0_ce1),
    .cl_rg_5_0_we1(cl_rg_5_0_we1),

    .cl_rg_5_1_addr0(cl_rg_5_1_addr0),
    .cl_rg_5_1_d0(cl_rg_5_1_d0),
    .cl_rg_5_1_q0(cl_rg_5_1_q0),
    .cl_rg_5_1_ce0(cl_rg_5_1_ce0),
    .cl_rg_5_1_we0(cl_rg_5_1_we0),
    .cl_rg_5_1_addr1(cl_rg_5_1_addr1),
    .cl_rg_5_1_d1(cl_rg_5_1_d1),
    .cl_rg_5_1_q1(cl_rg_5_1_q1),
    .cl_rg_5_1_ce1(cl_rg_5_1_ce1),
    .cl_rg_5_1_we1(cl_rg_5_1_we1),

    .cl_rg_5_2_addr0(cl_rg_5_2_addr0),
    .cl_rg_5_2_d0(cl_rg_5_2_d0),
    .cl_rg_5_2_q0(cl_rg_5_2_q0),
    .cl_rg_5_2_ce0(cl_rg_5_2_ce0),
    .cl_rg_5_2_we0(cl_rg_5_2_we0),
    .cl_rg_5_2_addr1(cl_rg_5_2_addr1),
    .cl_rg_5_2_d1(cl_rg_5_2_d1),
    .cl_rg_5_2_q1(cl_rg_5_2_q1),
    .cl_rg_5_2_ce1(cl_rg_5_2_ce1),
    .cl_rg_5_2_we1(cl_rg_5_2_we1),

    .cl_rg_5_3_addr0(cl_rg_5_3_addr0),
    .cl_rg_5_3_d0(cl_rg_5_3_d0),
    .cl_rg_5_3_q0(cl_rg_5_3_q0),
    .cl_rg_5_3_ce0(cl_rg_5_3_ce0),
    .cl_rg_5_3_we0(cl_rg_5_3_we0),
    .cl_rg_5_3_addr1(cl_rg_5_3_addr1),
    .cl_rg_5_3_d1(cl_rg_5_3_d1),
    .cl_rg_5_3_q1(cl_rg_5_3_q1),
    .cl_rg_5_3_ce1(cl_rg_5_3_ce1),
    .cl_rg_5_3_we1(cl_rg_5_3_we1),

    .cl_rg_6_0_addr0(cl_rg_6_0_addr0),
    .cl_rg_6_0_d0(cl_rg_6_0_d0),
    .cl_rg_6_0_q0(cl_rg_6_0_q0),
    .cl_rg_6_0_ce0(cl_rg_6_0_ce0),
    .cl_rg_6_0_we0(cl_rg_6_0_we0),
    .cl_rg_6_0_addr1(cl_rg_6_0_addr1),
    .cl_rg_6_0_d1(cl_rg_6_0_d1),
    .cl_rg_6_0_q1(cl_rg_6_0_q1),
    .cl_rg_6_0_ce1(cl_rg_6_0_ce1),
    .cl_rg_6_0_we1(cl_rg_6_0_we1),

    .cl_rg_6_1_addr0(cl_rg_6_1_addr0),
    .cl_rg_6_1_d0(cl_rg_6_1_d0),
    .cl_rg_6_1_q0(cl_rg_6_1_q0),
    .cl_rg_6_1_ce0(cl_rg_6_1_ce0),
    .cl_rg_6_1_we0(cl_rg_6_1_we0),
    .cl_rg_6_1_addr1(cl_rg_6_1_addr1),
    .cl_rg_6_1_d1(cl_rg_6_1_d1),
    .cl_rg_6_1_q1(cl_rg_6_1_q1),
    .cl_rg_6_1_ce1(cl_rg_6_1_ce1),
    .cl_rg_6_1_we1(cl_rg_6_1_we1),

    .cl_rg_6_2_addr0(cl_rg_6_2_addr0),
    .cl_rg_6_2_d0(cl_rg_6_2_d0),
    .cl_rg_6_2_q0(cl_rg_6_2_q0),
    .cl_rg_6_2_ce0(cl_rg_6_2_ce0),
    .cl_rg_6_2_we0(cl_rg_6_2_we0),
    .cl_rg_6_2_addr1(cl_rg_6_2_addr1),
    .cl_rg_6_2_d1(cl_rg_6_2_d1),
    .cl_rg_6_2_q1(cl_rg_6_2_q1),
    .cl_rg_6_2_ce1(cl_rg_6_2_ce1),
    .cl_rg_6_2_we1(cl_rg_6_2_we1),

    .cl_rg_6_3_addr0(cl_rg_6_3_addr0),
    .cl_rg_6_3_d0(cl_rg_6_3_d0),
    .cl_rg_6_3_q0(cl_rg_6_3_q0),
    .cl_rg_6_3_ce0(cl_rg_6_3_ce0),
    .cl_rg_6_3_we0(cl_rg_6_3_we0),
    .cl_rg_6_3_addr1(cl_rg_6_3_addr1),
    .cl_rg_6_3_d1(cl_rg_6_3_d1),
    .cl_rg_6_3_q1(cl_rg_6_3_q1),
    .cl_rg_6_3_ce1(cl_rg_6_3_ce1),
    .cl_rg_6_3_we1(cl_rg_6_3_we1),

    .cl_rg_7_0_addr0(cl_rg_7_0_addr0),
    .cl_rg_7_0_d0(cl_rg_7_0_d0),
    .cl_rg_7_0_q0(cl_rg_7_0_q0),
    .cl_rg_7_0_ce0(cl_rg_7_0_ce0),
    .cl_rg_7_0_we0(cl_rg_7_0_we0),
    .cl_rg_7_0_addr1(cl_rg_7_0_addr1),
    .cl_rg_7_0_d1(cl_rg_7_0_d1),
    .cl_rg_7_0_q1(cl_rg_7_0_q1),
    .cl_rg_7_0_ce1(cl_rg_7_0_ce1),
    .cl_rg_7_0_we1(cl_rg_7_0_we1),

    .cl_rg_7_1_addr0(cl_rg_7_1_addr0),
    .cl_rg_7_1_d0(cl_rg_7_1_d0),
    .cl_rg_7_1_q0(cl_rg_7_1_q0),
    .cl_rg_7_1_ce0(cl_rg_7_1_ce0),
    .cl_rg_7_1_we0(cl_rg_7_1_we0),
    .cl_rg_7_1_addr1(cl_rg_7_1_addr1),
    .cl_rg_7_1_d1(cl_rg_7_1_d1),
    .cl_rg_7_1_q1(cl_rg_7_1_q1),
    .cl_rg_7_1_ce1(cl_rg_7_1_ce1),
    .cl_rg_7_1_we1(cl_rg_7_1_we1),

    .cl_rg_7_2_addr0(cl_rg_7_2_addr0),
    .cl_rg_7_2_d0(cl_rg_7_2_d0),
    .cl_rg_7_2_q0(cl_rg_7_2_q0),
    .cl_rg_7_2_ce0(cl_rg_7_2_ce0),
    .cl_rg_7_2_we0(cl_rg_7_2_we0),
    .cl_rg_7_2_addr1(cl_rg_7_2_addr1),
    .cl_rg_7_2_d1(cl_rg_7_2_d1),
    .cl_rg_7_2_q1(cl_rg_7_2_q1),
    .cl_rg_7_2_ce1(cl_rg_7_2_ce1),
    .cl_rg_7_2_we1(cl_rg_7_2_we1),

    .cl_rg_7_3_addr0(cl_rg_7_3_addr0),
    .cl_rg_7_3_d0(cl_rg_7_3_d0),
    .cl_rg_7_3_q0(cl_rg_7_3_q0),
    .cl_rg_7_3_ce0(cl_rg_7_3_ce0),
    .cl_rg_7_3_we0(cl_rg_7_3_we0),
    .cl_rg_7_3_addr1(cl_rg_7_3_addr1),
    .cl_rg_7_3_d1(cl_rg_7_3_d1),
    .cl_rg_7_3_q1(cl_rg_7_3_q1),
    .cl_rg_7_3_ce1(cl_rg_7_3_ce1),
    .cl_rg_7_3_we1(cl_rg_7_3_we1),

    .cl_rg_8_0_addr0(cl_rg_8_0_addr0),
    .cl_rg_8_0_d0(cl_rg_8_0_d0),
    .cl_rg_8_0_q0(cl_rg_8_0_q0),
    .cl_rg_8_0_ce0(cl_rg_8_0_ce0),
    .cl_rg_8_0_we0(cl_rg_8_0_we0),
    .cl_rg_8_0_addr1(cl_rg_8_0_addr1),
    .cl_rg_8_0_d1(cl_rg_8_0_d1),
    .cl_rg_8_0_q1(cl_rg_8_0_q1),
    .cl_rg_8_0_ce1(cl_rg_8_0_ce1),
    .cl_rg_8_0_we1(cl_rg_8_0_we1),

    .cl_rg_8_1_addr0(cl_rg_8_1_addr0),
    .cl_rg_8_1_d0(cl_rg_8_1_d0),
    .cl_rg_8_1_q0(cl_rg_8_1_q0),
    .cl_rg_8_1_ce0(cl_rg_8_1_ce0),
    .cl_rg_8_1_we0(cl_rg_8_1_we0),
    .cl_rg_8_1_addr1(cl_rg_8_1_addr1),
    .cl_rg_8_1_d1(cl_rg_8_1_d1),
    .cl_rg_8_1_q1(cl_rg_8_1_q1),
    .cl_rg_8_1_ce1(cl_rg_8_1_ce1),
    .cl_rg_8_1_we1(cl_rg_8_1_we1),

    .cl_rg_8_2_addr0(cl_rg_8_2_addr0),
    .cl_rg_8_2_d0(cl_rg_8_2_d0),
    .cl_rg_8_2_q0(cl_rg_8_2_q0),
    .cl_rg_8_2_ce0(cl_rg_8_2_ce0),
    .cl_rg_8_2_we0(cl_rg_8_2_we0),
    .cl_rg_8_2_addr1(cl_rg_8_2_addr1),
    .cl_rg_8_2_d1(cl_rg_8_2_d1),
    .cl_rg_8_2_q1(cl_rg_8_2_q1),
    .cl_rg_8_2_ce1(cl_rg_8_2_ce1),
    .cl_rg_8_2_we1(cl_rg_8_2_we1),

    .cl_rg_8_3_addr0(cl_rg_8_3_addr0),
    .cl_rg_8_3_d0(cl_rg_8_3_d0),
    .cl_rg_8_3_q0(cl_rg_8_3_q0),
    .cl_rg_8_3_ce0(cl_rg_8_3_ce0),
    .cl_rg_8_3_we0(cl_rg_8_3_we0),
    .cl_rg_8_3_addr1(cl_rg_8_3_addr1),
    .cl_rg_8_3_d1(cl_rg_8_3_d1),
    .cl_rg_8_3_q1(cl_rg_8_3_q1),
    .cl_rg_8_3_ce1(cl_rg_8_3_ce1),
    .cl_rg_8_3_we1(cl_rg_8_3_we1),

    .cl_rg_9_0_addr0(cl_rg_9_0_addr0),
    .cl_rg_9_0_d0(cl_rg_9_0_d0),
    .cl_rg_9_0_q0(cl_rg_9_0_q0),
    .cl_rg_9_0_ce0(cl_rg_9_0_ce0),
    .cl_rg_9_0_we0(cl_rg_9_0_we0),
    .cl_rg_9_0_addr1(cl_rg_9_0_addr1),
    .cl_rg_9_0_d1(cl_rg_9_0_d1),
    .cl_rg_9_0_q1(cl_rg_9_0_q1),
    .cl_rg_9_0_ce1(cl_rg_9_0_ce1),
    .cl_rg_9_0_we1(cl_rg_9_0_we1),

    .cl_rg_9_1_addr0(cl_rg_9_1_addr0),
    .cl_rg_9_1_d0(cl_rg_9_1_d0),
    .cl_rg_9_1_q0(cl_rg_9_1_q0),
    .cl_rg_9_1_ce0(cl_rg_9_1_ce0),
    .cl_rg_9_1_we0(cl_rg_9_1_we0),
    .cl_rg_9_1_addr1(cl_rg_9_1_addr1),
    .cl_rg_9_1_d1(cl_rg_9_1_d1),
    .cl_rg_9_1_q1(cl_rg_9_1_q1),
    .cl_rg_9_1_ce1(cl_rg_9_1_ce1),
    .cl_rg_9_1_we1(cl_rg_9_1_we1),

    .cl_rg_9_2_addr0(cl_rg_9_2_addr0),
    .cl_rg_9_2_d0(cl_rg_9_2_d0),
    .cl_rg_9_2_q0(cl_rg_9_2_q0),
    .cl_rg_9_2_ce0(cl_rg_9_2_ce0),
    .cl_rg_9_2_we0(cl_rg_9_2_we0),
    .cl_rg_9_2_addr1(cl_rg_9_2_addr1),
    .cl_rg_9_2_d1(cl_rg_9_2_d1),
    .cl_rg_9_2_q1(cl_rg_9_2_q1),
    .cl_rg_9_2_ce1(cl_rg_9_2_ce1),
    .cl_rg_9_2_we1(cl_rg_9_2_we1),

    .cl_rg_9_3_addr0(cl_rg_9_3_addr0),
    .cl_rg_9_3_d0(cl_rg_9_3_d0),
    .cl_rg_9_3_q0(cl_rg_9_3_q0),
    .cl_rg_9_3_ce0(cl_rg_9_3_ce0),
    .cl_rg_9_3_we0(cl_rg_9_3_we0),
    .cl_rg_9_3_addr1(cl_rg_9_3_addr1),
    .cl_rg_9_3_d1(cl_rg_9_3_d1),
    .cl_rg_9_3_q1(cl_rg_9_3_q1),
    .cl_rg_9_3_ce1(cl_rg_9_3_ce1),
    .cl_rg_9_3_we1(cl_rg_9_3_we1),

    .cl_rg_10_0_addr0(cl_rg_10_0_addr0),
    .cl_rg_10_0_d0(cl_rg_10_0_d0),
    .cl_rg_10_0_q0(cl_rg_10_0_q0),
    .cl_rg_10_0_ce0(cl_rg_10_0_ce0),
    .cl_rg_10_0_we0(cl_rg_10_0_we0),
    .cl_rg_10_0_addr1(cl_rg_10_0_addr1),
    .cl_rg_10_0_d1(cl_rg_10_0_d1),
    .cl_rg_10_0_q1(cl_rg_10_0_q1),
    .cl_rg_10_0_ce1(cl_rg_10_0_ce1),
    .cl_rg_10_0_we1(cl_rg_10_0_we1),

    .cl_rg_10_1_addr0(cl_rg_10_1_addr0),
    .cl_rg_10_1_d0(cl_rg_10_1_d0),
    .cl_rg_10_1_q0(cl_rg_10_1_q0),
    .cl_rg_10_1_ce0(cl_rg_10_1_ce0),
    .cl_rg_10_1_we0(cl_rg_10_1_we0),
    .cl_rg_10_1_addr1(cl_rg_10_1_addr1),
    .cl_rg_10_1_d1(cl_rg_10_1_d1),
    .cl_rg_10_1_q1(cl_rg_10_1_q1),
    .cl_rg_10_1_ce1(cl_rg_10_1_ce1),
    .cl_rg_10_1_we1(cl_rg_10_1_we1),

    .cl_rg_10_2_addr0(cl_rg_10_2_addr0),
    .cl_rg_10_2_d0(cl_rg_10_2_d0),
    .cl_rg_10_2_q0(cl_rg_10_2_q0),
    .cl_rg_10_2_ce0(cl_rg_10_2_ce0),
    .cl_rg_10_2_we0(cl_rg_10_2_we0),
    .cl_rg_10_2_addr1(cl_rg_10_2_addr1),
    .cl_rg_10_2_d1(cl_rg_10_2_d1),
    .cl_rg_10_2_q1(cl_rg_10_2_q1),
    .cl_rg_10_2_ce1(cl_rg_10_2_ce1),
    .cl_rg_10_2_we1(cl_rg_10_2_we1),

    .cl_rg_10_3_addr0(cl_rg_10_3_addr0),
    .cl_rg_10_3_d0(cl_rg_10_3_d0),
    .cl_rg_10_3_q0(cl_rg_10_3_q0),
    .cl_rg_10_3_ce0(cl_rg_10_3_ce0),
    .cl_rg_10_3_we0(cl_rg_10_3_we0),
    .cl_rg_10_3_addr1(cl_rg_10_3_addr1),
    .cl_rg_10_3_d1(cl_rg_10_3_d1),
    .cl_rg_10_3_q1(cl_rg_10_3_q1),
    .cl_rg_10_3_ce1(cl_rg_10_3_ce1),
    .cl_rg_10_3_we1(cl_rg_10_3_we1),

    .cl_rg_11_0_addr0(cl_rg_11_0_addr0),
    .cl_rg_11_0_d0(cl_rg_11_0_d0),
    .cl_rg_11_0_q0(cl_rg_11_0_q0),
    .cl_rg_11_0_ce0(cl_rg_11_0_ce0),
    .cl_rg_11_0_we0(cl_rg_11_0_we0),
    .cl_rg_11_0_addr1(cl_rg_11_0_addr1),
    .cl_rg_11_0_d1(cl_rg_11_0_d1),
    .cl_rg_11_0_q1(cl_rg_11_0_q1),
    .cl_rg_11_0_ce1(cl_rg_11_0_ce1),
    .cl_rg_11_0_we1(cl_rg_11_0_we1),

    .cl_rg_11_1_addr0(cl_rg_11_1_addr0),
    .cl_rg_11_1_d0(cl_rg_11_1_d0),
    .cl_rg_11_1_q0(cl_rg_11_1_q0),
    .cl_rg_11_1_ce0(cl_rg_11_1_ce0),
    .cl_rg_11_1_we0(cl_rg_11_1_we0),
    .cl_rg_11_1_addr1(cl_rg_11_1_addr1),
    .cl_rg_11_1_d1(cl_rg_11_1_d1),
    .cl_rg_11_1_q1(cl_rg_11_1_q1),
    .cl_rg_11_1_ce1(cl_rg_11_1_ce1),
    .cl_rg_11_1_we1(cl_rg_11_1_we1),

    .cl_rg_11_2_addr0(cl_rg_11_2_addr0),
    .cl_rg_11_2_d0(cl_rg_11_2_d0),
    .cl_rg_11_2_q0(cl_rg_11_2_q0),
    .cl_rg_11_2_ce0(cl_rg_11_2_ce0),
    .cl_rg_11_2_we0(cl_rg_11_2_we0),
    .cl_rg_11_2_addr1(cl_rg_11_2_addr1),
    .cl_rg_11_2_d1(cl_rg_11_2_d1),
    .cl_rg_11_2_q1(cl_rg_11_2_q1),
    .cl_rg_11_2_ce1(cl_rg_11_2_ce1),
    .cl_rg_11_2_we1(cl_rg_11_2_we1),

    .cl_rg_11_3_addr0(cl_rg_11_3_addr0),
    .cl_rg_11_3_d0(cl_rg_11_3_d0),
    .cl_rg_11_3_q0(cl_rg_11_3_q0),
    .cl_rg_11_3_ce0(cl_rg_11_3_ce0),
    .cl_rg_11_3_we0(cl_rg_11_3_we0),
    .cl_rg_11_3_addr1(cl_rg_11_3_addr1),
    .cl_rg_11_3_d1(cl_rg_11_3_d1),
    .cl_rg_11_3_q1(cl_rg_11_3_q1),
    .cl_rg_11_3_ce1(cl_rg_11_3_ce1),
    .cl_rg_11_3_we1(cl_rg_11_3_we1),

    .cl_rg_12_0_addr0(cl_rg_12_0_addr0),
    .cl_rg_12_0_d0(cl_rg_12_0_d0),
    .cl_rg_12_0_q0(cl_rg_12_0_q0),
    .cl_rg_12_0_ce0(cl_rg_12_0_ce0),
    .cl_rg_12_0_we0(cl_rg_12_0_we0),
    .cl_rg_12_0_addr1(cl_rg_12_0_addr1),
    .cl_rg_12_0_d1(cl_rg_12_0_d1),
    .cl_rg_12_0_q1(cl_rg_12_0_q1),
    .cl_rg_12_0_ce1(cl_rg_12_0_ce1),
    .cl_rg_12_0_we1(cl_rg_12_0_we1),

    .cl_rg_12_1_addr0(cl_rg_12_1_addr0),
    .cl_rg_12_1_d0(cl_rg_12_1_d0),
    .cl_rg_12_1_q0(cl_rg_12_1_q0),
    .cl_rg_12_1_ce0(cl_rg_12_1_ce0),
    .cl_rg_12_1_we0(cl_rg_12_1_we0),
    .cl_rg_12_1_addr1(cl_rg_12_1_addr1),
    .cl_rg_12_1_d1(cl_rg_12_1_d1),
    .cl_rg_12_1_q1(cl_rg_12_1_q1),
    .cl_rg_12_1_ce1(cl_rg_12_1_ce1),
    .cl_rg_12_1_we1(cl_rg_12_1_we1),

    .cl_rg_12_2_addr0(cl_rg_12_2_addr0),
    .cl_rg_12_2_d0(cl_rg_12_2_d0),
    .cl_rg_12_2_q0(cl_rg_12_2_q0),
    .cl_rg_12_2_ce0(cl_rg_12_2_ce0),
    .cl_rg_12_2_we0(cl_rg_12_2_we0),
    .cl_rg_12_2_addr1(cl_rg_12_2_addr1),
    .cl_rg_12_2_d1(cl_rg_12_2_d1),
    .cl_rg_12_2_q1(cl_rg_12_2_q1),
    .cl_rg_12_2_ce1(cl_rg_12_2_ce1),
    .cl_rg_12_2_we1(cl_rg_12_2_we1),

    .cl_rg_12_3_addr0(cl_rg_12_3_addr0),
    .cl_rg_12_3_d0(cl_rg_12_3_d0),
    .cl_rg_12_3_q0(cl_rg_12_3_q0),
    .cl_rg_12_3_ce0(cl_rg_12_3_ce0),
    .cl_rg_12_3_we0(cl_rg_12_3_we0),
    .cl_rg_12_3_addr1(cl_rg_12_3_addr1),
    .cl_rg_12_3_d1(cl_rg_12_3_d1),
    .cl_rg_12_3_q1(cl_rg_12_3_q1),
    .cl_rg_12_3_ce1(cl_rg_12_3_ce1),
    .cl_rg_12_3_we1(cl_rg_12_3_we1),

    .cl_rg_13_0_addr0(cl_rg_13_0_addr0),
    .cl_rg_13_0_d0(cl_rg_13_0_d0),
    .cl_rg_13_0_q0(cl_rg_13_0_q0),
    .cl_rg_13_0_ce0(cl_rg_13_0_ce0),
    .cl_rg_13_0_we0(cl_rg_13_0_we0),
    .cl_rg_13_0_addr1(cl_rg_13_0_addr1),
    .cl_rg_13_0_d1(cl_rg_13_0_d1),
    .cl_rg_13_0_q1(cl_rg_13_0_q1),
    .cl_rg_13_0_ce1(cl_rg_13_0_ce1),
    .cl_rg_13_0_we1(cl_rg_13_0_we1),

    .cl_rg_13_1_addr0(cl_rg_13_1_addr0),
    .cl_rg_13_1_d0(cl_rg_13_1_d0),
    .cl_rg_13_1_q0(cl_rg_13_1_q0),
    .cl_rg_13_1_ce0(cl_rg_13_1_ce0),
    .cl_rg_13_1_we0(cl_rg_13_1_we0),
    .cl_rg_13_1_addr1(cl_rg_13_1_addr1),
    .cl_rg_13_1_d1(cl_rg_13_1_d1),
    .cl_rg_13_1_q1(cl_rg_13_1_q1),
    .cl_rg_13_1_ce1(cl_rg_13_1_ce1),
    .cl_rg_13_1_we1(cl_rg_13_1_we1),

    .cl_rg_13_2_addr0(cl_rg_13_2_addr0),
    .cl_rg_13_2_d0(cl_rg_13_2_d0),
    .cl_rg_13_2_q0(cl_rg_13_2_q0),
    .cl_rg_13_2_ce0(cl_rg_13_2_ce0),
    .cl_rg_13_2_we0(cl_rg_13_2_we0),
    .cl_rg_13_2_addr1(cl_rg_13_2_addr1),
    .cl_rg_13_2_d1(cl_rg_13_2_d1),
    .cl_rg_13_2_q1(cl_rg_13_2_q1),
    .cl_rg_13_2_ce1(cl_rg_13_2_ce1),
    .cl_rg_13_2_we1(cl_rg_13_2_we1),

    .cl_rg_13_3_addr0(cl_rg_13_3_addr0),
    .cl_rg_13_3_d0(cl_rg_13_3_d0),
    .cl_rg_13_3_q0(cl_rg_13_3_q0),
    .cl_rg_13_3_ce0(cl_rg_13_3_ce0),
    .cl_rg_13_3_we0(cl_rg_13_3_we0),
    .cl_rg_13_3_addr1(cl_rg_13_3_addr1),
    .cl_rg_13_3_d1(cl_rg_13_3_d1),
    .cl_rg_13_3_q1(cl_rg_13_3_q1),
    .cl_rg_13_3_ce1(cl_rg_13_3_ce1),
    .cl_rg_13_3_we1(cl_rg_13_3_we1),

    .cl_rg_14_0_addr0(cl_rg_14_0_addr0),
    .cl_rg_14_0_d0(cl_rg_14_0_d0),
    .cl_rg_14_0_q0(cl_rg_14_0_q0),
    .cl_rg_14_0_ce0(cl_rg_14_0_ce0),
    .cl_rg_14_0_we0(cl_rg_14_0_we0),
    .cl_rg_14_0_addr1(cl_rg_14_0_addr1),
    .cl_rg_14_0_d1(cl_rg_14_0_d1),
    .cl_rg_14_0_q1(cl_rg_14_0_q1),
    .cl_rg_14_0_ce1(cl_rg_14_0_ce1),
    .cl_rg_14_0_we1(cl_rg_14_0_we1),

    .cl_rg_14_1_addr0(cl_rg_14_1_addr0),
    .cl_rg_14_1_d0(cl_rg_14_1_d0),
    .cl_rg_14_1_q0(cl_rg_14_1_q0),
    .cl_rg_14_1_ce0(cl_rg_14_1_ce0),
    .cl_rg_14_1_we0(cl_rg_14_1_we0),
    .cl_rg_14_1_addr1(cl_rg_14_1_addr1),
    .cl_rg_14_1_d1(cl_rg_14_1_d1),
    .cl_rg_14_1_q1(cl_rg_14_1_q1),
    .cl_rg_14_1_ce1(cl_rg_14_1_ce1),
    .cl_rg_14_1_we1(cl_rg_14_1_we1),

    .cl_rg_14_2_addr0(cl_rg_14_2_addr0),
    .cl_rg_14_2_d0(cl_rg_14_2_d0),
    .cl_rg_14_2_q0(cl_rg_14_2_q0),
    .cl_rg_14_2_ce0(cl_rg_14_2_ce0),
    .cl_rg_14_2_we0(cl_rg_14_2_we0),
    .cl_rg_14_2_addr1(cl_rg_14_2_addr1),
    .cl_rg_14_2_d1(cl_rg_14_2_d1),
    .cl_rg_14_2_q1(cl_rg_14_2_q1),
    .cl_rg_14_2_ce1(cl_rg_14_2_ce1),
    .cl_rg_14_2_we1(cl_rg_14_2_we1),

    .cl_rg_14_3_addr0(cl_rg_14_3_addr0),
    .cl_rg_14_3_d0(cl_rg_14_3_d0),
    .cl_rg_14_3_q0(cl_rg_14_3_q0),
    .cl_rg_14_3_ce0(cl_rg_14_3_ce0),
    .cl_rg_14_3_we0(cl_rg_14_3_we0),
    .cl_rg_14_3_addr1(cl_rg_14_3_addr1),
    .cl_rg_14_3_d1(cl_rg_14_3_d1),
    .cl_rg_14_3_q1(cl_rg_14_3_q1),
    .cl_rg_14_3_ce1(cl_rg_14_3_ce1),
    .cl_rg_14_3_we1(cl_rg_14_3_we1),

    .cl_rg_15_0_addr0(cl_rg_15_0_addr0),
    .cl_rg_15_0_d0(cl_rg_15_0_d0),
    .cl_rg_15_0_q0(cl_rg_15_0_q0),
    .cl_rg_15_0_ce0(cl_rg_15_0_ce0),
    .cl_rg_15_0_we0(cl_rg_15_0_we0),
    .cl_rg_15_0_addr1(cl_rg_15_0_addr1),
    .cl_rg_15_0_d1(cl_rg_15_0_d1),
    .cl_rg_15_0_q1(cl_rg_15_0_q1),
    .cl_rg_15_0_ce1(cl_rg_15_0_ce1),
    .cl_rg_15_0_we1(cl_rg_15_0_we1),

    .cl_rg_15_1_addr0(cl_rg_15_1_addr0),
    .cl_rg_15_1_d0(cl_rg_15_1_d0),
    .cl_rg_15_1_q0(cl_rg_15_1_q0),
    .cl_rg_15_1_ce0(cl_rg_15_1_ce0),
    .cl_rg_15_1_we0(cl_rg_15_1_we0),
    .cl_rg_15_1_addr1(cl_rg_15_1_addr1),
    .cl_rg_15_1_d1(cl_rg_15_1_d1),
    .cl_rg_15_1_q1(cl_rg_15_1_q1),
    .cl_rg_15_1_ce1(cl_rg_15_1_ce1),
    .cl_rg_15_1_we1(cl_rg_15_1_we1),

    .cl_rg_15_2_addr0(cl_rg_15_2_addr0),
    .cl_rg_15_2_d0(cl_rg_15_2_d0),
    .cl_rg_15_2_q0(cl_rg_15_2_q0),
    .cl_rg_15_2_ce0(cl_rg_15_2_ce0),
    .cl_rg_15_2_we0(cl_rg_15_2_we0),
    .cl_rg_15_2_addr1(cl_rg_15_2_addr1),
    .cl_rg_15_2_d1(cl_rg_15_2_d1),
    .cl_rg_15_2_q1(cl_rg_15_2_q1),
    .cl_rg_15_2_ce1(cl_rg_15_2_ce1),
    .cl_rg_15_2_we1(cl_rg_15_2_we1),

    .cl_rg_15_3_addr0(cl_rg_15_3_addr0),
    .cl_rg_15_3_d0(cl_rg_15_3_d0),
    .cl_rg_15_3_q0(cl_rg_15_3_q0),
    .cl_rg_15_3_ce0(cl_rg_15_3_ce0),
    .cl_rg_15_3_we0(cl_rg_15_3_we0),
    .cl_rg_15_3_addr1(cl_rg_15_3_addr1),
    .cl_rg_15_3_d1(cl_rg_15_3_d1),
    .cl_rg_15_3_q1(cl_rg_15_3_q1),
    .cl_rg_15_3_ce1(cl_rg_15_3_ce1),
    .cl_rg_15_3_we1(cl_rg_15_3_we1),

    .cl_rg_16_0_addr0(cl_rg_16_0_addr0),
    .cl_rg_16_0_d0(cl_rg_16_0_d0),
    .cl_rg_16_0_q0(cl_rg_16_0_q0),
    .cl_rg_16_0_ce0(cl_rg_16_0_ce0),
    .cl_rg_16_0_we0(cl_rg_16_0_we0),
    .cl_rg_16_0_addr1(cl_rg_16_0_addr1),
    .cl_rg_16_0_d1(cl_rg_16_0_d1),
    .cl_rg_16_0_q1(cl_rg_16_0_q1),
    .cl_rg_16_0_ce1(cl_rg_16_0_ce1),
    .cl_rg_16_0_we1(cl_rg_16_0_we1),

    .cl_rg_16_1_addr0(cl_rg_16_1_addr0),
    .cl_rg_16_1_d0(cl_rg_16_1_d0),
    .cl_rg_16_1_q0(cl_rg_16_1_q0),
    .cl_rg_16_1_ce0(cl_rg_16_1_ce0),
    .cl_rg_16_1_we0(cl_rg_16_1_we0),
    .cl_rg_16_1_addr1(cl_rg_16_1_addr1),
    .cl_rg_16_1_d1(cl_rg_16_1_d1),
    .cl_rg_16_1_q1(cl_rg_16_1_q1),
    .cl_rg_16_1_ce1(cl_rg_16_1_ce1),
    .cl_rg_16_1_we1(cl_rg_16_1_we1),

    .cl_rg_16_2_addr0(cl_rg_16_2_addr0),
    .cl_rg_16_2_d0(cl_rg_16_2_d0),
    .cl_rg_16_2_q0(cl_rg_16_2_q0),
    .cl_rg_16_2_ce0(cl_rg_16_2_ce0),
    .cl_rg_16_2_we0(cl_rg_16_2_we0),
    .cl_rg_16_2_addr1(cl_rg_16_2_addr1),
    .cl_rg_16_2_d1(cl_rg_16_2_d1),
    .cl_rg_16_2_q1(cl_rg_16_2_q1),
    .cl_rg_16_2_ce1(cl_rg_16_2_ce1),
    .cl_rg_16_2_we1(cl_rg_16_2_we1),

    .cl_rg_16_3_addr0(cl_rg_16_3_addr0),
    .cl_rg_16_3_d0(cl_rg_16_3_d0),
    .cl_rg_16_3_q0(cl_rg_16_3_q0),
    .cl_rg_16_3_ce0(cl_rg_16_3_ce0),
    .cl_rg_16_3_we0(cl_rg_16_3_we0),
    .cl_rg_16_3_addr1(cl_rg_16_3_addr1),
    .cl_rg_16_3_d1(cl_rg_16_3_d1),
    .cl_rg_16_3_q1(cl_rg_16_3_q1),
    .cl_rg_16_3_ce1(cl_rg_16_3_ce1),
    .cl_rg_16_3_we1(cl_rg_16_3_we1),

    .cl_rg_17_0_addr0(cl_rg_17_0_addr0),
    .cl_rg_17_0_d0(cl_rg_17_0_d0),
    .cl_rg_17_0_q0(cl_rg_17_0_q0),
    .cl_rg_17_0_ce0(cl_rg_17_0_ce0),
    .cl_rg_17_0_we0(cl_rg_17_0_we0),
    .cl_rg_17_0_addr1(cl_rg_17_0_addr1),
    .cl_rg_17_0_d1(cl_rg_17_0_d1),
    .cl_rg_17_0_q1(cl_rg_17_0_q1),
    .cl_rg_17_0_ce1(cl_rg_17_0_ce1),
    .cl_rg_17_0_we1(cl_rg_17_0_we1),

    .cl_rg_17_1_addr0(cl_rg_17_1_addr0),
    .cl_rg_17_1_d0(cl_rg_17_1_d0),
    .cl_rg_17_1_q0(cl_rg_17_1_q0),
    .cl_rg_17_1_ce0(cl_rg_17_1_ce0),
    .cl_rg_17_1_we0(cl_rg_17_1_we0),
    .cl_rg_17_1_addr1(cl_rg_17_1_addr1),
    .cl_rg_17_1_d1(cl_rg_17_1_d1),
    .cl_rg_17_1_q1(cl_rg_17_1_q1),
    .cl_rg_17_1_ce1(cl_rg_17_1_ce1),
    .cl_rg_17_1_we1(cl_rg_17_1_we1),

    .cl_rg_17_2_addr0(cl_rg_17_2_addr0),
    .cl_rg_17_2_d0(cl_rg_17_2_d0),
    .cl_rg_17_2_q0(cl_rg_17_2_q0),
    .cl_rg_17_2_ce0(cl_rg_17_2_ce0),
    .cl_rg_17_2_we0(cl_rg_17_2_we0),
    .cl_rg_17_2_addr1(cl_rg_17_2_addr1),
    .cl_rg_17_2_d1(cl_rg_17_2_d1),
    .cl_rg_17_2_q1(cl_rg_17_2_q1),
    .cl_rg_17_2_ce1(cl_rg_17_2_ce1),
    .cl_rg_17_2_we1(cl_rg_17_2_we1),

    .cl_rg_17_3_addr0(cl_rg_17_3_addr0),
    .cl_rg_17_3_d0(cl_rg_17_3_d0),
    .cl_rg_17_3_q0(cl_rg_17_3_q0),
    .cl_rg_17_3_ce0(cl_rg_17_3_ce0),
    .cl_rg_17_3_we0(cl_rg_17_3_we0),
    .cl_rg_17_3_addr1(cl_rg_17_3_addr1),
    .cl_rg_17_3_d1(cl_rg_17_3_d1),
    .cl_rg_17_3_q1(cl_rg_17_3_q1),
    .cl_rg_17_3_ce1(cl_rg_17_3_ce1),
    .cl_rg_17_3_we1(cl_rg_17_3_we1),

    .cl_rg_18_0_addr0(cl_rg_18_0_addr0),
    .cl_rg_18_0_d0(cl_rg_18_0_d0),
    .cl_rg_18_0_q0(cl_rg_18_0_q0),
    .cl_rg_18_0_ce0(cl_rg_18_0_ce0),
    .cl_rg_18_0_we0(cl_rg_18_0_we0),
    .cl_rg_18_0_addr1(cl_rg_18_0_addr1),
    .cl_rg_18_0_d1(cl_rg_18_0_d1),
    .cl_rg_18_0_q1(cl_rg_18_0_q1),
    .cl_rg_18_0_ce1(cl_rg_18_0_ce1),
    .cl_rg_18_0_we1(cl_rg_18_0_we1),

    .cl_rg_18_1_addr0(cl_rg_18_1_addr0),
    .cl_rg_18_1_d0(cl_rg_18_1_d0),
    .cl_rg_18_1_q0(cl_rg_18_1_q0),
    .cl_rg_18_1_ce0(cl_rg_18_1_ce0),
    .cl_rg_18_1_we0(cl_rg_18_1_we0),
    .cl_rg_18_1_addr1(cl_rg_18_1_addr1),
    .cl_rg_18_1_d1(cl_rg_18_1_d1),
    .cl_rg_18_1_q1(cl_rg_18_1_q1),
    .cl_rg_18_1_ce1(cl_rg_18_1_ce1),
    .cl_rg_18_1_we1(cl_rg_18_1_we1),

    .cl_rg_18_2_addr0(cl_rg_18_2_addr0),
    .cl_rg_18_2_d0(cl_rg_18_2_d0),
    .cl_rg_18_2_q0(cl_rg_18_2_q0),
    .cl_rg_18_2_ce0(cl_rg_18_2_ce0),
    .cl_rg_18_2_we0(cl_rg_18_2_we0),
    .cl_rg_18_2_addr1(cl_rg_18_2_addr1),
    .cl_rg_18_2_d1(cl_rg_18_2_d1),
    .cl_rg_18_2_q1(cl_rg_18_2_q1),
    .cl_rg_18_2_ce1(cl_rg_18_2_ce1),
    .cl_rg_18_2_we1(cl_rg_18_2_we1),

    .cl_rg_18_3_addr0(cl_rg_18_3_addr0),
    .cl_rg_18_3_d0(cl_rg_18_3_d0),
    .cl_rg_18_3_q0(cl_rg_18_3_q0),
    .cl_rg_18_3_ce0(cl_rg_18_3_ce0),
    .cl_rg_18_3_we0(cl_rg_18_3_we0),
    .cl_rg_18_3_addr1(cl_rg_18_3_addr1),
    .cl_rg_18_3_d1(cl_rg_18_3_d1),
    .cl_rg_18_3_q1(cl_rg_18_3_q1),
    .cl_rg_18_3_ce1(cl_rg_18_3_ce1),
    .cl_rg_18_3_we1(cl_rg_18_3_we1),

    .cl_rg_19_0_addr0(cl_rg_19_0_addr0),
    .cl_rg_19_0_d0(cl_rg_19_0_d0),
    .cl_rg_19_0_q0(cl_rg_19_0_q0),
    .cl_rg_19_0_ce0(cl_rg_19_0_ce0),
    .cl_rg_19_0_we0(cl_rg_19_0_we0),
    .cl_rg_19_0_addr1(cl_rg_19_0_addr1),
    .cl_rg_19_0_d1(cl_rg_19_0_d1),
    .cl_rg_19_0_q1(cl_rg_19_0_q1),
    .cl_rg_19_0_ce1(cl_rg_19_0_ce1),
    .cl_rg_19_0_we1(cl_rg_19_0_we1),

    .cl_rg_19_1_addr0(cl_rg_19_1_addr0),
    .cl_rg_19_1_d0(cl_rg_19_1_d0),
    .cl_rg_19_1_q0(cl_rg_19_1_q0),
    .cl_rg_19_1_ce0(cl_rg_19_1_ce0),
    .cl_rg_19_1_we0(cl_rg_19_1_we0),
    .cl_rg_19_1_addr1(cl_rg_19_1_addr1),
    .cl_rg_19_1_d1(cl_rg_19_1_d1),
    .cl_rg_19_1_q1(cl_rg_19_1_q1),
    .cl_rg_19_1_ce1(cl_rg_19_1_ce1),
    .cl_rg_19_1_we1(cl_rg_19_1_we1),

    .cl_rg_19_2_addr0(cl_rg_19_2_addr0),
    .cl_rg_19_2_d0(cl_rg_19_2_d0),
    .cl_rg_19_2_q0(cl_rg_19_2_q0),
    .cl_rg_19_2_ce0(cl_rg_19_2_ce0),
    .cl_rg_19_2_we0(cl_rg_19_2_we0),
    .cl_rg_19_2_addr1(cl_rg_19_2_addr1),
    .cl_rg_19_2_d1(cl_rg_19_2_d1),
    .cl_rg_19_2_q1(cl_rg_19_2_q1),
    .cl_rg_19_2_ce1(cl_rg_19_2_ce1),
    .cl_rg_19_2_we1(cl_rg_19_2_we1),

    .cl_rg_19_3_addr0(cl_rg_19_3_addr0),
    .cl_rg_19_3_d0(cl_rg_19_3_d0),
    .cl_rg_19_3_q0(cl_rg_19_3_q0),
    .cl_rg_19_3_ce0(cl_rg_19_3_ce0),
    .cl_rg_19_3_we0(cl_rg_19_3_we0),
    .cl_rg_19_3_addr1(cl_rg_19_3_addr1),
    .cl_rg_19_3_d1(cl_rg_19_3_d1),
    .cl_rg_19_3_q1(cl_rg_19_3_q1),
    .cl_rg_19_3_ce1(cl_rg_19_3_ce1),
    .cl_rg_19_3_we1(cl_rg_19_3_we1),

    .cl_rg_20_0_addr0(cl_rg_20_0_addr0),
    .cl_rg_20_0_d0(cl_rg_20_0_d0),
    .cl_rg_20_0_q0(cl_rg_20_0_q0),
    .cl_rg_20_0_ce0(cl_rg_20_0_ce0),
    .cl_rg_20_0_we0(cl_rg_20_0_we0),
    .cl_rg_20_0_addr1(cl_rg_20_0_addr1),
    .cl_rg_20_0_d1(cl_rg_20_0_d1),
    .cl_rg_20_0_q1(cl_rg_20_0_q1),
    .cl_rg_20_0_ce1(cl_rg_20_0_ce1),
    .cl_rg_20_0_we1(cl_rg_20_0_we1),

    .cl_rg_20_1_addr0(cl_rg_20_1_addr0),
    .cl_rg_20_1_d0(cl_rg_20_1_d0),
    .cl_rg_20_1_q0(cl_rg_20_1_q0),
    .cl_rg_20_1_ce0(cl_rg_20_1_ce0),
    .cl_rg_20_1_we0(cl_rg_20_1_we0),
    .cl_rg_20_1_addr1(cl_rg_20_1_addr1),
    .cl_rg_20_1_d1(cl_rg_20_1_d1),
    .cl_rg_20_1_q1(cl_rg_20_1_q1),
    .cl_rg_20_1_ce1(cl_rg_20_1_ce1),
    .cl_rg_20_1_we1(cl_rg_20_1_we1),

    .cl_rg_20_2_addr0(cl_rg_20_2_addr0),
    .cl_rg_20_2_d0(cl_rg_20_2_d0),
    .cl_rg_20_2_q0(cl_rg_20_2_q0),
    .cl_rg_20_2_ce0(cl_rg_20_2_ce0),
    .cl_rg_20_2_we0(cl_rg_20_2_we0),
    .cl_rg_20_2_addr1(cl_rg_20_2_addr1),
    .cl_rg_20_2_d1(cl_rg_20_2_d1),
    .cl_rg_20_2_q1(cl_rg_20_2_q1),
    .cl_rg_20_2_ce1(cl_rg_20_2_ce1),
    .cl_rg_20_2_we1(cl_rg_20_2_we1),

    .cl_rg_20_3_addr0(cl_rg_20_3_addr0),
    .cl_rg_20_3_d0(cl_rg_20_3_d0),
    .cl_rg_20_3_q0(cl_rg_20_3_q0),
    .cl_rg_20_3_ce0(cl_rg_20_3_ce0),
    .cl_rg_20_3_we0(cl_rg_20_3_we0),
    .cl_rg_20_3_addr1(cl_rg_20_3_addr1),
    .cl_rg_20_3_d1(cl_rg_20_3_d1),
    .cl_rg_20_3_q1(cl_rg_20_3_q1),
    .cl_rg_20_3_ce1(cl_rg_20_3_ce1),
    .cl_rg_20_3_we1(cl_rg_20_3_we1),

    .cl_done(cl_done_ff),
    .cl_ctrl_addr(cl_ctrl_addr_ff),
    .cl_ctrl_d(cl_ctrl_d_ff),
    .cl_ctrl_q(cl_ctrl_q_ff),
    .cl_ctrl_ce(cl_ctrl_ce_ff),
    .cl_ctrl_we(cl_ctrl_we_ff),

`ifndef NO_AXIS
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tkeep(m_axis_tkeep),
    .m_axis_tstrb(m_axis_tstrb),
    .m_axis_tdest(m_axis_tdest),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tkeep(s_axis_tkeep),
    .s_axis_tstrb(s_axis_tstrb),
    .s_axis_tdest(s_axis_tdest),
`endif

    .clk(clk),
    .rst(socket_reset_ff)
  );

  //(* DONT_TOUCH="yes" *)
  lsu_rg_cl_glue lsu_rg_cl_glue (
    .lsu0_dp_mode(lsu0_dp_mode_ff),

    .lsu0_port0_addr(lsu0_port0_addr_ff),
    .lsu0_port0_d(lsu0_port0_d_ff),
    .lsu0_port0_q(lsu0_port0_q_ff),
    .lsu0_port0_ce(lsu0_port0_ce_ff),
    .lsu0_port0_we(lsu0_port0_we_ff),

    .lsu0_port1_addr(lsu0_port1_addr_ff),
    .lsu0_port1_d(lsu0_port1_d_ff),
    .lsu0_port1_q(lsu0_port1_q_ff),
    .lsu0_port1_ce(lsu0_port1_ce_ff),
    .lsu0_port1_we(lsu0_port1_we_ff),

    .lsu0_port2_addr(lsu0_port2_addr_ff),
    .lsu0_port2_d(lsu0_port2_d_ff),
    .lsu0_port2_q(lsu0_port2_q_ff),
    .lsu0_port2_ce(lsu0_port2_ce_ff),
    .lsu0_port2_we(lsu0_port2_we_ff),

    .lsu0_port3_addr(lsu0_port3_addr_ff),
    .lsu0_port3_d(lsu0_port3_d_ff),
    .lsu0_port3_q(lsu0_port3_q_ff),
    .lsu0_port3_ce(lsu0_port3_ce_ff),
    .lsu0_port3_we(lsu0_port3_we_ff),

    .lsu0_ram_en(lsu0_ram_en_ff),

`ifndef SOCKET_S
    .lsu1_dp_mode(lsu1_dp_mode_ff),

    .lsu1_port0_addr(lsu1_port0_addr_ff),
    .lsu1_port0_d(lsu1_port0_d_ff),
    .lsu1_port0_q(lsu1_port0_q_ff),
    .lsu1_port0_ce(lsu1_port0_ce_ff),
    .lsu1_port0_we(lsu1_port0_we_ff),

    .lsu1_port1_addr(lsu1_port1_addr_ff),
    .lsu1_port1_d(lsu1_port1_d_ff),
    .lsu1_port1_q(lsu1_port1_q_ff),
    .lsu1_port1_ce(lsu1_port1_ce_ff),
    .lsu1_port1_we(lsu1_port1_we_ff),

    .lsu1_port2_addr(lsu1_port2_addr_ff),
    .lsu1_port2_d(lsu1_port2_d_ff),
    .lsu1_port2_q(lsu1_port2_q_ff),
    .lsu1_port2_ce(lsu1_port2_ce_ff),
    .lsu1_port2_we(lsu1_port2_we_ff),

    .lsu1_port3_addr(lsu1_port3_addr_ff),
    .lsu1_port3_d(lsu1_port3_d_ff),
    .lsu1_port3_q(lsu1_port3_q_ff),
    .lsu1_port3_ce(lsu1_port3_ce_ff),
    .lsu1_port3_we(lsu1_port3_we_ff),

    .lsu1_ram_en(lsu1_ram_en_ff),
`endif

    .cl_rg_0_0_addr0(cl_rg_0_0_addr0),
    .cl_rg_0_0_d0(cl_rg_0_0_d0),
    .cl_rg_0_0_q0(cl_rg_0_0_q0),
    .cl_rg_0_0_ce0(cl_rg_0_0_ce0),
    .cl_rg_0_0_we0(cl_rg_0_0_we0),
    .cl_rg_0_0_addr1(cl_rg_0_0_addr1),
    .cl_rg_0_0_d1(cl_rg_0_0_d1),
    .cl_rg_0_0_q1(cl_rg_0_0_q1),
    .cl_rg_0_0_ce1(cl_rg_0_0_ce1),
    .cl_rg_0_0_we1(cl_rg_0_0_we1),

    .cl_rg_0_1_addr0(cl_rg_0_1_addr0),
    .cl_rg_0_1_d0(cl_rg_0_1_d0),
    .cl_rg_0_1_q0(cl_rg_0_1_q0),
    .cl_rg_0_1_ce0(cl_rg_0_1_ce0),
    .cl_rg_0_1_we0(cl_rg_0_1_we0),
    .cl_rg_0_1_addr1(cl_rg_0_1_addr1),
    .cl_rg_0_1_d1(cl_rg_0_1_d1),
    .cl_rg_0_1_q1(cl_rg_0_1_q1),
    .cl_rg_0_1_ce1(cl_rg_0_1_ce1),
    .cl_rg_0_1_we1(cl_rg_0_1_we1),

    .cl_rg_0_2_addr0(cl_rg_0_2_addr0),
    .cl_rg_0_2_d0(cl_rg_0_2_d0),
    .cl_rg_0_2_q0(cl_rg_0_2_q0),
    .cl_rg_0_2_ce0(cl_rg_0_2_ce0),
    .cl_rg_0_2_we0(cl_rg_0_2_we0),
    .cl_rg_0_2_addr1(cl_rg_0_2_addr1),
    .cl_rg_0_2_d1(cl_rg_0_2_d1),
    .cl_rg_0_2_q1(cl_rg_0_2_q1),
    .cl_rg_0_2_ce1(cl_rg_0_2_ce1),
    .cl_rg_0_2_we1(cl_rg_0_2_we1),

    .cl_rg_0_3_addr0(cl_rg_0_3_addr0),
    .cl_rg_0_3_d0(cl_rg_0_3_d0),
    .cl_rg_0_3_q0(cl_rg_0_3_q0),
    .cl_rg_0_3_ce0(cl_rg_0_3_ce0),
    .cl_rg_0_3_we0(cl_rg_0_3_we0),
    .cl_rg_0_3_addr1(cl_rg_0_3_addr1),
    .cl_rg_0_3_d1(cl_rg_0_3_d1),
    .cl_rg_0_3_q1(cl_rg_0_3_q1),
    .cl_rg_0_3_ce1(cl_rg_0_3_ce1),
    .cl_rg_0_3_we1(cl_rg_0_3_we1),

    .cl_rg_1_0_addr0(cl_rg_1_0_addr0),
    .cl_rg_1_0_d0(cl_rg_1_0_d0),
    .cl_rg_1_0_q0(cl_rg_1_0_q0),
    .cl_rg_1_0_ce0(cl_rg_1_0_ce0),
    .cl_rg_1_0_we0(cl_rg_1_0_we0),
    .cl_rg_1_0_addr1(cl_rg_1_0_addr1),
    .cl_rg_1_0_d1(cl_rg_1_0_d1),
    .cl_rg_1_0_q1(cl_rg_1_0_q1),
    .cl_rg_1_0_ce1(cl_rg_1_0_ce1),
    .cl_rg_1_0_we1(cl_rg_1_0_we1),

    .cl_rg_1_1_addr0(cl_rg_1_1_addr0),
    .cl_rg_1_1_d0(cl_rg_1_1_d0),
    .cl_rg_1_1_q0(cl_rg_1_1_q0),
    .cl_rg_1_1_ce0(cl_rg_1_1_ce0),
    .cl_rg_1_1_we0(cl_rg_1_1_we0),
    .cl_rg_1_1_addr1(cl_rg_1_1_addr1),
    .cl_rg_1_1_d1(cl_rg_1_1_d1),
    .cl_rg_1_1_q1(cl_rg_1_1_q1),
    .cl_rg_1_1_ce1(cl_rg_1_1_ce1),
    .cl_rg_1_1_we1(cl_rg_1_1_we1),

    .cl_rg_1_2_addr0(cl_rg_1_2_addr0),
    .cl_rg_1_2_d0(cl_rg_1_2_d0),
    .cl_rg_1_2_q0(cl_rg_1_2_q0),
    .cl_rg_1_2_ce0(cl_rg_1_2_ce0),
    .cl_rg_1_2_we0(cl_rg_1_2_we0),
    .cl_rg_1_2_addr1(cl_rg_1_2_addr1),
    .cl_rg_1_2_d1(cl_rg_1_2_d1),
    .cl_rg_1_2_q1(cl_rg_1_2_q1),
    .cl_rg_1_2_ce1(cl_rg_1_2_ce1),
    .cl_rg_1_2_we1(cl_rg_1_2_we1),

    .cl_rg_1_3_addr0(cl_rg_1_3_addr0),
    .cl_rg_1_3_d0(cl_rg_1_3_d0),
    .cl_rg_1_3_q0(cl_rg_1_3_q0),
    .cl_rg_1_3_ce0(cl_rg_1_3_ce0),
    .cl_rg_1_3_we0(cl_rg_1_3_we0),
    .cl_rg_1_3_addr1(cl_rg_1_3_addr1),
    .cl_rg_1_3_d1(cl_rg_1_3_d1),
    .cl_rg_1_3_q1(cl_rg_1_3_q1),
    .cl_rg_1_3_ce1(cl_rg_1_3_ce1),
    .cl_rg_1_3_we1(cl_rg_1_3_we1),

    .cl_rg_2_0_addr0(cl_rg_2_0_addr0),
    .cl_rg_2_0_d0(cl_rg_2_0_d0),
    .cl_rg_2_0_q0(cl_rg_2_0_q0),
    .cl_rg_2_0_ce0(cl_rg_2_0_ce0),
    .cl_rg_2_0_we0(cl_rg_2_0_we0),
    .cl_rg_2_0_addr1(cl_rg_2_0_addr1),
    .cl_rg_2_0_d1(cl_rg_2_0_d1),
    .cl_rg_2_0_q1(cl_rg_2_0_q1),
    .cl_rg_2_0_ce1(cl_rg_2_0_ce1),
    .cl_rg_2_0_we1(cl_rg_2_0_we1),

    .cl_rg_2_1_addr0(cl_rg_2_1_addr0),
    .cl_rg_2_1_d0(cl_rg_2_1_d0),
    .cl_rg_2_1_q0(cl_rg_2_1_q0),
    .cl_rg_2_1_ce0(cl_rg_2_1_ce0),
    .cl_rg_2_1_we0(cl_rg_2_1_we0),
    .cl_rg_2_1_addr1(cl_rg_2_1_addr1),
    .cl_rg_2_1_d1(cl_rg_2_1_d1),
    .cl_rg_2_1_q1(cl_rg_2_1_q1),
    .cl_rg_2_1_ce1(cl_rg_2_1_ce1),
    .cl_rg_2_1_we1(cl_rg_2_1_we1),

    .cl_rg_2_2_addr0(cl_rg_2_2_addr0),
    .cl_rg_2_2_d0(cl_rg_2_2_d0),
    .cl_rg_2_2_q0(cl_rg_2_2_q0),
    .cl_rg_2_2_ce0(cl_rg_2_2_ce0),
    .cl_rg_2_2_we0(cl_rg_2_2_we0),
    .cl_rg_2_2_addr1(cl_rg_2_2_addr1),
    .cl_rg_2_2_d1(cl_rg_2_2_d1),
    .cl_rg_2_2_q1(cl_rg_2_2_q1),
    .cl_rg_2_2_ce1(cl_rg_2_2_ce1),
    .cl_rg_2_2_we1(cl_rg_2_2_we1),

    .cl_rg_2_3_addr0(cl_rg_2_3_addr0),
    .cl_rg_2_3_d0(cl_rg_2_3_d0),
    .cl_rg_2_3_q0(cl_rg_2_3_q0),
    .cl_rg_2_3_ce0(cl_rg_2_3_ce0),
    .cl_rg_2_3_we0(cl_rg_2_3_we0),
    .cl_rg_2_3_addr1(cl_rg_2_3_addr1),
    .cl_rg_2_3_d1(cl_rg_2_3_d1),
    .cl_rg_2_3_q1(cl_rg_2_3_q1),
    .cl_rg_2_3_ce1(cl_rg_2_3_ce1),
    .cl_rg_2_3_we1(cl_rg_2_3_we1),

    .cl_rg_3_0_addr0(cl_rg_3_0_addr0),
    .cl_rg_3_0_d0(cl_rg_3_0_d0),
    .cl_rg_3_0_q0(cl_rg_3_0_q0),
    .cl_rg_3_0_ce0(cl_rg_3_0_ce0),
    .cl_rg_3_0_we0(cl_rg_3_0_we0),
    .cl_rg_3_0_addr1(cl_rg_3_0_addr1),
    .cl_rg_3_0_d1(cl_rg_3_0_d1),
    .cl_rg_3_0_q1(cl_rg_3_0_q1),
    .cl_rg_3_0_ce1(cl_rg_3_0_ce1),
    .cl_rg_3_0_we1(cl_rg_3_0_we1),

    .cl_rg_3_1_addr0(cl_rg_3_1_addr0),
    .cl_rg_3_1_d0(cl_rg_3_1_d0),
    .cl_rg_3_1_q0(cl_rg_3_1_q0),
    .cl_rg_3_1_ce0(cl_rg_3_1_ce0),
    .cl_rg_3_1_we0(cl_rg_3_1_we0),
    .cl_rg_3_1_addr1(cl_rg_3_1_addr1),
    .cl_rg_3_1_d1(cl_rg_3_1_d1),
    .cl_rg_3_1_q1(cl_rg_3_1_q1),
    .cl_rg_3_1_ce1(cl_rg_3_1_ce1),
    .cl_rg_3_1_we1(cl_rg_3_1_we1),

    .cl_rg_3_2_addr0(cl_rg_3_2_addr0),
    .cl_rg_3_2_d0(cl_rg_3_2_d0),
    .cl_rg_3_2_q0(cl_rg_3_2_q0),
    .cl_rg_3_2_ce0(cl_rg_3_2_ce0),
    .cl_rg_3_2_we0(cl_rg_3_2_we0),
    .cl_rg_3_2_addr1(cl_rg_3_2_addr1),
    .cl_rg_3_2_d1(cl_rg_3_2_d1),
    .cl_rg_3_2_q1(cl_rg_3_2_q1),
    .cl_rg_3_2_ce1(cl_rg_3_2_ce1),
    .cl_rg_3_2_we1(cl_rg_3_2_we1),

    .cl_rg_3_3_addr0(cl_rg_3_3_addr0),
    .cl_rg_3_3_d0(cl_rg_3_3_d0),
    .cl_rg_3_3_q0(cl_rg_3_3_q0),
    .cl_rg_3_3_ce0(cl_rg_3_3_ce0),
    .cl_rg_3_3_we0(cl_rg_3_3_we0),
    .cl_rg_3_3_addr1(cl_rg_3_3_addr1),
    .cl_rg_3_3_d1(cl_rg_3_3_d1),
    .cl_rg_3_3_q1(cl_rg_3_3_q1),
    .cl_rg_3_3_ce1(cl_rg_3_3_ce1),
    .cl_rg_3_3_we1(cl_rg_3_3_we1),

    .cl_rg_4_0_addr0(cl_rg_4_0_addr0),
    .cl_rg_4_0_d0(cl_rg_4_0_d0),
    .cl_rg_4_0_q0(cl_rg_4_0_q0),
    .cl_rg_4_0_ce0(cl_rg_4_0_ce0),
    .cl_rg_4_0_we0(cl_rg_4_0_we0),
    .cl_rg_4_0_addr1(cl_rg_4_0_addr1),
    .cl_rg_4_0_d1(cl_rg_4_0_d1),
    .cl_rg_4_0_q1(cl_rg_4_0_q1),
    .cl_rg_4_0_ce1(cl_rg_4_0_ce1),
    .cl_rg_4_0_we1(cl_rg_4_0_we1),

    .cl_rg_4_1_addr0(cl_rg_4_1_addr0),
    .cl_rg_4_1_d0(cl_rg_4_1_d0),
    .cl_rg_4_1_q0(cl_rg_4_1_q0),
    .cl_rg_4_1_ce0(cl_rg_4_1_ce0),
    .cl_rg_4_1_we0(cl_rg_4_1_we0),
    .cl_rg_4_1_addr1(cl_rg_4_1_addr1),
    .cl_rg_4_1_d1(cl_rg_4_1_d1),
    .cl_rg_4_1_q1(cl_rg_4_1_q1),
    .cl_rg_4_1_ce1(cl_rg_4_1_ce1),
    .cl_rg_4_1_we1(cl_rg_4_1_we1),

    .cl_rg_4_2_addr0(cl_rg_4_2_addr0),
    .cl_rg_4_2_d0(cl_rg_4_2_d0),
    .cl_rg_4_2_q0(cl_rg_4_2_q0),
    .cl_rg_4_2_ce0(cl_rg_4_2_ce0),
    .cl_rg_4_2_we0(cl_rg_4_2_we0),
    .cl_rg_4_2_addr1(cl_rg_4_2_addr1),
    .cl_rg_4_2_d1(cl_rg_4_2_d1),
    .cl_rg_4_2_q1(cl_rg_4_2_q1),
    .cl_rg_4_2_ce1(cl_rg_4_2_ce1),
    .cl_rg_4_2_we1(cl_rg_4_2_we1),

    .cl_rg_4_3_addr0(cl_rg_4_3_addr0),
    .cl_rg_4_3_d0(cl_rg_4_3_d0),
    .cl_rg_4_3_q0(cl_rg_4_3_q0),
    .cl_rg_4_3_ce0(cl_rg_4_3_ce0),
    .cl_rg_4_3_we0(cl_rg_4_3_we0),
    .cl_rg_4_3_addr1(cl_rg_4_3_addr1),
    .cl_rg_4_3_d1(cl_rg_4_3_d1),
    .cl_rg_4_3_q1(cl_rg_4_3_q1),
    .cl_rg_4_3_ce1(cl_rg_4_3_ce1),
    .cl_rg_4_3_we1(cl_rg_4_3_we1),

    .cl_rg_5_0_addr0(cl_rg_5_0_addr0),
    .cl_rg_5_0_d0(cl_rg_5_0_d0),
    .cl_rg_5_0_q0(cl_rg_5_0_q0),
    .cl_rg_5_0_ce0(cl_rg_5_0_ce0),
    .cl_rg_5_0_we0(cl_rg_5_0_we0),
    .cl_rg_5_0_addr1(cl_rg_5_0_addr1),
    .cl_rg_5_0_d1(cl_rg_5_0_d1),
    .cl_rg_5_0_q1(cl_rg_5_0_q1),
    .cl_rg_5_0_ce1(cl_rg_5_0_ce1),
    .cl_rg_5_0_we1(cl_rg_5_0_we1),

    .cl_rg_5_1_addr0(cl_rg_5_1_addr0),
    .cl_rg_5_1_d0(cl_rg_5_1_d0),
    .cl_rg_5_1_q0(cl_rg_5_1_q0),
    .cl_rg_5_1_ce0(cl_rg_5_1_ce0),
    .cl_rg_5_1_we0(cl_rg_5_1_we0),
    .cl_rg_5_1_addr1(cl_rg_5_1_addr1),
    .cl_rg_5_1_d1(cl_rg_5_1_d1),
    .cl_rg_5_1_q1(cl_rg_5_1_q1),
    .cl_rg_5_1_ce1(cl_rg_5_1_ce1),
    .cl_rg_5_1_we1(cl_rg_5_1_we1),

    .cl_rg_5_2_addr0(cl_rg_5_2_addr0),
    .cl_rg_5_2_d0(cl_rg_5_2_d0),
    .cl_rg_5_2_q0(cl_rg_5_2_q0),
    .cl_rg_5_2_ce0(cl_rg_5_2_ce0),
    .cl_rg_5_2_we0(cl_rg_5_2_we0),
    .cl_rg_5_2_addr1(cl_rg_5_2_addr1),
    .cl_rg_5_2_d1(cl_rg_5_2_d1),
    .cl_rg_5_2_q1(cl_rg_5_2_q1),
    .cl_rg_5_2_ce1(cl_rg_5_2_ce1),
    .cl_rg_5_2_we1(cl_rg_5_2_we1),

    .cl_rg_5_3_addr0(cl_rg_5_3_addr0),
    .cl_rg_5_3_d0(cl_rg_5_3_d0),
    .cl_rg_5_3_q0(cl_rg_5_3_q0),
    .cl_rg_5_3_ce0(cl_rg_5_3_ce0),
    .cl_rg_5_3_we0(cl_rg_5_3_we0),
    .cl_rg_5_3_addr1(cl_rg_5_3_addr1),
    .cl_rg_5_3_d1(cl_rg_5_3_d1),
    .cl_rg_5_3_q1(cl_rg_5_3_q1),
    .cl_rg_5_3_ce1(cl_rg_5_3_ce1),
    .cl_rg_5_3_we1(cl_rg_5_3_we1),

    .cl_rg_6_0_addr0(cl_rg_6_0_addr0),
    .cl_rg_6_0_d0(cl_rg_6_0_d0),
    .cl_rg_6_0_q0(cl_rg_6_0_q0),
    .cl_rg_6_0_ce0(cl_rg_6_0_ce0),
    .cl_rg_6_0_we0(cl_rg_6_0_we0),
    .cl_rg_6_0_addr1(cl_rg_6_0_addr1),
    .cl_rg_6_0_d1(cl_rg_6_0_d1),
    .cl_rg_6_0_q1(cl_rg_6_0_q1),
    .cl_rg_6_0_ce1(cl_rg_6_0_ce1),
    .cl_rg_6_0_we1(cl_rg_6_0_we1),

    .cl_rg_6_1_addr0(cl_rg_6_1_addr0),
    .cl_rg_6_1_d0(cl_rg_6_1_d0),
    .cl_rg_6_1_q0(cl_rg_6_1_q0),
    .cl_rg_6_1_ce0(cl_rg_6_1_ce0),
    .cl_rg_6_1_we0(cl_rg_6_1_we0),
    .cl_rg_6_1_addr1(cl_rg_6_1_addr1),
    .cl_rg_6_1_d1(cl_rg_6_1_d1),
    .cl_rg_6_1_q1(cl_rg_6_1_q1),
    .cl_rg_6_1_ce1(cl_rg_6_1_ce1),
    .cl_rg_6_1_we1(cl_rg_6_1_we1),

    .cl_rg_6_2_addr0(cl_rg_6_2_addr0),
    .cl_rg_6_2_d0(cl_rg_6_2_d0),
    .cl_rg_6_2_q0(cl_rg_6_2_q0),
    .cl_rg_6_2_ce0(cl_rg_6_2_ce0),
    .cl_rg_6_2_we0(cl_rg_6_2_we0),
    .cl_rg_6_2_addr1(cl_rg_6_2_addr1),
    .cl_rg_6_2_d1(cl_rg_6_2_d1),
    .cl_rg_6_2_q1(cl_rg_6_2_q1),
    .cl_rg_6_2_ce1(cl_rg_6_2_ce1),
    .cl_rg_6_2_we1(cl_rg_6_2_we1),

    .cl_rg_6_3_addr0(cl_rg_6_3_addr0),
    .cl_rg_6_3_d0(cl_rg_6_3_d0),
    .cl_rg_6_3_q0(cl_rg_6_3_q0),
    .cl_rg_6_3_ce0(cl_rg_6_3_ce0),
    .cl_rg_6_3_we0(cl_rg_6_3_we0),
    .cl_rg_6_3_addr1(cl_rg_6_3_addr1),
    .cl_rg_6_3_d1(cl_rg_6_3_d1),
    .cl_rg_6_3_q1(cl_rg_6_3_q1),
    .cl_rg_6_3_ce1(cl_rg_6_3_ce1),
    .cl_rg_6_3_we1(cl_rg_6_3_we1),

    .cl_rg_7_0_addr0(cl_rg_7_0_addr0),
    .cl_rg_7_0_d0(cl_rg_7_0_d0),
    .cl_rg_7_0_q0(cl_rg_7_0_q0),
    .cl_rg_7_0_ce0(cl_rg_7_0_ce0),
    .cl_rg_7_0_we0(cl_rg_7_0_we0),
    .cl_rg_7_0_addr1(cl_rg_7_0_addr1),
    .cl_rg_7_0_d1(cl_rg_7_0_d1),
    .cl_rg_7_0_q1(cl_rg_7_0_q1),
    .cl_rg_7_0_ce1(cl_rg_7_0_ce1),
    .cl_rg_7_0_we1(cl_rg_7_0_we1),

    .cl_rg_7_1_addr0(cl_rg_7_1_addr0),
    .cl_rg_7_1_d0(cl_rg_7_1_d0),
    .cl_rg_7_1_q0(cl_rg_7_1_q0),
    .cl_rg_7_1_ce0(cl_rg_7_1_ce0),
    .cl_rg_7_1_we0(cl_rg_7_1_we0),
    .cl_rg_7_1_addr1(cl_rg_7_1_addr1),
    .cl_rg_7_1_d1(cl_rg_7_1_d1),
    .cl_rg_7_1_q1(cl_rg_7_1_q1),
    .cl_rg_7_1_ce1(cl_rg_7_1_ce1),
    .cl_rg_7_1_we1(cl_rg_7_1_we1),

    .cl_rg_7_2_addr0(cl_rg_7_2_addr0),
    .cl_rg_7_2_d0(cl_rg_7_2_d0),
    .cl_rg_7_2_q0(cl_rg_7_2_q0),
    .cl_rg_7_2_ce0(cl_rg_7_2_ce0),
    .cl_rg_7_2_we0(cl_rg_7_2_we0),
    .cl_rg_7_2_addr1(cl_rg_7_2_addr1),
    .cl_rg_7_2_d1(cl_rg_7_2_d1),
    .cl_rg_7_2_q1(cl_rg_7_2_q1),
    .cl_rg_7_2_ce1(cl_rg_7_2_ce1),
    .cl_rg_7_2_we1(cl_rg_7_2_we1),

    .cl_rg_7_3_addr0(cl_rg_7_3_addr0),
    .cl_rg_7_3_d0(cl_rg_7_3_d0),
    .cl_rg_7_3_q0(cl_rg_7_3_q0),
    .cl_rg_7_3_ce0(cl_rg_7_3_ce0),
    .cl_rg_7_3_we0(cl_rg_7_3_we0),
    .cl_rg_7_3_addr1(cl_rg_7_3_addr1),
    .cl_rg_7_3_d1(cl_rg_7_3_d1),
    .cl_rg_7_3_q1(cl_rg_7_3_q1),
    .cl_rg_7_3_ce1(cl_rg_7_3_ce1),
    .cl_rg_7_3_we1(cl_rg_7_3_we1),

    .cl_rg_8_0_addr0(cl_rg_8_0_addr0),
    .cl_rg_8_0_d0(cl_rg_8_0_d0),
    .cl_rg_8_0_q0(cl_rg_8_0_q0),
    .cl_rg_8_0_ce0(cl_rg_8_0_ce0),
    .cl_rg_8_0_we0(cl_rg_8_0_we0),
    .cl_rg_8_0_addr1(cl_rg_8_0_addr1),
    .cl_rg_8_0_d1(cl_rg_8_0_d1),
    .cl_rg_8_0_q1(cl_rg_8_0_q1),
    .cl_rg_8_0_ce1(cl_rg_8_0_ce1),
    .cl_rg_8_0_we1(cl_rg_8_0_we1),

    .cl_rg_8_1_addr0(cl_rg_8_1_addr0),
    .cl_rg_8_1_d0(cl_rg_8_1_d0),
    .cl_rg_8_1_q0(cl_rg_8_1_q0),
    .cl_rg_8_1_ce0(cl_rg_8_1_ce0),
    .cl_rg_8_1_we0(cl_rg_8_1_we0),
    .cl_rg_8_1_addr1(cl_rg_8_1_addr1),
    .cl_rg_8_1_d1(cl_rg_8_1_d1),
    .cl_rg_8_1_q1(cl_rg_8_1_q1),
    .cl_rg_8_1_ce1(cl_rg_8_1_ce1),
    .cl_rg_8_1_we1(cl_rg_8_1_we1),

    .cl_rg_8_2_addr0(cl_rg_8_2_addr0),
    .cl_rg_8_2_d0(cl_rg_8_2_d0),
    .cl_rg_8_2_q0(cl_rg_8_2_q0),
    .cl_rg_8_2_ce0(cl_rg_8_2_ce0),
    .cl_rg_8_2_we0(cl_rg_8_2_we0),
    .cl_rg_8_2_addr1(cl_rg_8_2_addr1),
    .cl_rg_8_2_d1(cl_rg_8_2_d1),
    .cl_rg_8_2_q1(cl_rg_8_2_q1),
    .cl_rg_8_2_ce1(cl_rg_8_2_ce1),
    .cl_rg_8_2_we1(cl_rg_8_2_we1),

    .cl_rg_8_3_addr0(cl_rg_8_3_addr0),
    .cl_rg_8_3_d0(cl_rg_8_3_d0),
    .cl_rg_8_3_q0(cl_rg_8_3_q0),
    .cl_rg_8_3_ce0(cl_rg_8_3_ce0),
    .cl_rg_8_3_we0(cl_rg_8_3_we0),
    .cl_rg_8_3_addr1(cl_rg_8_3_addr1),
    .cl_rg_8_3_d1(cl_rg_8_3_d1),
    .cl_rg_8_3_q1(cl_rg_8_3_q1),
    .cl_rg_8_3_ce1(cl_rg_8_3_ce1),
    .cl_rg_8_3_we1(cl_rg_8_3_we1),

    .cl_rg_9_0_addr0(cl_rg_9_0_addr0),
    .cl_rg_9_0_d0(cl_rg_9_0_d0),
    .cl_rg_9_0_q0(cl_rg_9_0_q0),
    .cl_rg_9_0_ce0(cl_rg_9_0_ce0),
    .cl_rg_9_0_we0(cl_rg_9_0_we0),
    .cl_rg_9_0_addr1(cl_rg_9_0_addr1),
    .cl_rg_9_0_d1(cl_rg_9_0_d1),
    .cl_rg_9_0_q1(cl_rg_9_0_q1),
    .cl_rg_9_0_ce1(cl_rg_9_0_ce1),
    .cl_rg_9_0_we1(cl_rg_9_0_we1),

    .cl_rg_9_1_addr0(cl_rg_9_1_addr0),
    .cl_rg_9_1_d0(cl_rg_9_1_d0),
    .cl_rg_9_1_q0(cl_rg_9_1_q0),
    .cl_rg_9_1_ce0(cl_rg_9_1_ce0),
    .cl_rg_9_1_we0(cl_rg_9_1_we0),
    .cl_rg_9_1_addr1(cl_rg_9_1_addr1),
    .cl_rg_9_1_d1(cl_rg_9_1_d1),
    .cl_rg_9_1_q1(cl_rg_9_1_q1),
    .cl_rg_9_1_ce1(cl_rg_9_1_ce1),
    .cl_rg_9_1_we1(cl_rg_9_1_we1),

    .cl_rg_9_2_addr0(cl_rg_9_2_addr0),
    .cl_rg_9_2_d0(cl_rg_9_2_d0),
    .cl_rg_9_2_q0(cl_rg_9_2_q0),
    .cl_rg_9_2_ce0(cl_rg_9_2_ce0),
    .cl_rg_9_2_we0(cl_rg_9_2_we0),
    .cl_rg_9_2_addr1(cl_rg_9_2_addr1),
    .cl_rg_9_2_d1(cl_rg_9_2_d1),
    .cl_rg_9_2_q1(cl_rg_9_2_q1),
    .cl_rg_9_2_ce1(cl_rg_9_2_ce1),
    .cl_rg_9_2_we1(cl_rg_9_2_we1),

    .cl_rg_9_3_addr0(cl_rg_9_3_addr0),
    .cl_rg_9_3_d0(cl_rg_9_3_d0),
    .cl_rg_9_3_q0(cl_rg_9_3_q0),
    .cl_rg_9_3_ce0(cl_rg_9_3_ce0),
    .cl_rg_9_3_we0(cl_rg_9_3_we0),
    .cl_rg_9_3_addr1(cl_rg_9_3_addr1),
    .cl_rg_9_3_d1(cl_rg_9_3_d1),
    .cl_rg_9_3_q1(cl_rg_9_3_q1),
    .cl_rg_9_3_ce1(cl_rg_9_3_ce1),
    .cl_rg_9_3_we1(cl_rg_9_3_we1),

    .cl_rg_10_0_addr0(cl_rg_10_0_addr0),
    .cl_rg_10_0_d0(cl_rg_10_0_d0),
    .cl_rg_10_0_q0(cl_rg_10_0_q0),
    .cl_rg_10_0_ce0(cl_rg_10_0_ce0),
    .cl_rg_10_0_we0(cl_rg_10_0_we0),
    .cl_rg_10_0_addr1(cl_rg_10_0_addr1),
    .cl_rg_10_0_d1(cl_rg_10_0_d1),
    .cl_rg_10_0_q1(cl_rg_10_0_q1),
    .cl_rg_10_0_ce1(cl_rg_10_0_ce1),
    .cl_rg_10_0_we1(cl_rg_10_0_we1),

    .cl_rg_10_1_addr0(cl_rg_10_1_addr0),
    .cl_rg_10_1_d0(cl_rg_10_1_d0),
    .cl_rg_10_1_q0(cl_rg_10_1_q0),
    .cl_rg_10_1_ce0(cl_rg_10_1_ce0),
    .cl_rg_10_1_we0(cl_rg_10_1_we0),
    .cl_rg_10_1_addr1(cl_rg_10_1_addr1),
    .cl_rg_10_1_d1(cl_rg_10_1_d1),
    .cl_rg_10_1_q1(cl_rg_10_1_q1),
    .cl_rg_10_1_ce1(cl_rg_10_1_ce1),
    .cl_rg_10_1_we1(cl_rg_10_1_we1),

    .cl_rg_10_2_addr0(cl_rg_10_2_addr0),
    .cl_rg_10_2_d0(cl_rg_10_2_d0),
    .cl_rg_10_2_q0(cl_rg_10_2_q0),
    .cl_rg_10_2_ce0(cl_rg_10_2_ce0),
    .cl_rg_10_2_we0(cl_rg_10_2_we0),
    .cl_rg_10_2_addr1(cl_rg_10_2_addr1),
    .cl_rg_10_2_d1(cl_rg_10_2_d1),
    .cl_rg_10_2_q1(cl_rg_10_2_q1),
    .cl_rg_10_2_ce1(cl_rg_10_2_ce1),
    .cl_rg_10_2_we1(cl_rg_10_2_we1),

    .cl_rg_10_3_addr0(cl_rg_10_3_addr0),
    .cl_rg_10_3_d0(cl_rg_10_3_d0),
    .cl_rg_10_3_q0(cl_rg_10_3_q0),
    .cl_rg_10_3_ce0(cl_rg_10_3_ce0),
    .cl_rg_10_3_we0(cl_rg_10_3_we0),
    .cl_rg_10_3_addr1(cl_rg_10_3_addr1),
    .cl_rg_10_3_d1(cl_rg_10_3_d1),
    .cl_rg_10_3_q1(cl_rg_10_3_q1),
    .cl_rg_10_3_ce1(cl_rg_10_3_ce1),
    .cl_rg_10_3_we1(cl_rg_10_3_we1),

    .cl_rg_11_0_addr0(cl_rg_11_0_addr0),
    .cl_rg_11_0_d0(cl_rg_11_0_d0),
    .cl_rg_11_0_q0(cl_rg_11_0_q0),
    .cl_rg_11_0_ce0(cl_rg_11_0_ce0),
    .cl_rg_11_0_we0(cl_rg_11_0_we0),
    .cl_rg_11_0_addr1(cl_rg_11_0_addr1),
    .cl_rg_11_0_d1(cl_rg_11_0_d1),
    .cl_rg_11_0_q1(cl_rg_11_0_q1),
    .cl_rg_11_0_ce1(cl_rg_11_0_ce1),
    .cl_rg_11_0_we1(cl_rg_11_0_we1),

    .cl_rg_11_1_addr0(cl_rg_11_1_addr0),
    .cl_rg_11_1_d0(cl_rg_11_1_d0),
    .cl_rg_11_1_q0(cl_rg_11_1_q0),
    .cl_rg_11_1_ce0(cl_rg_11_1_ce0),
    .cl_rg_11_1_we0(cl_rg_11_1_we0),
    .cl_rg_11_1_addr1(cl_rg_11_1_addr1),
    .cl_rg_11_1_d1(cl_rg_11_1_d1),
    .cl_rg_11_1_q1(cl_rg_11_1_q1),
    .cl_rg_11_1_ce1(cl_rg_11_1_ce1),
    .cl_rg_11_1_we1(cl_rg_11_1_we1),

    .cl_rg_11_2_addr0(cl_rg_11_2_addr0),
    .cl_rg_11_2_d0(cl_rg_11_2_d0),
    .cl_rg_11_2_q0(cl_rg_11_2_q0),
    .cl_rg_11_2_ce0(cl_rg_11_2_ce0),
    .cl_rg_11_2_we0(cl_rg_11_2_we0),
    .cl_rg_11_2_addr1(cl_rg_11_2_addr1),
    .cl_rg_11_2_d1(cl_rg_11_2_d1),
    .cl_rg_11_2_q1(cl_rg_11_2_q1),
    .cl_rg_11_2_ce1(cl_rg_11_2_ce1),
    .cl_rg_11_2_we1(cl_rg_11_2_we1),

    .cl_rg_11_3_addr0(cl_rg_11_3_addr0),
    .cl_rg_11_3_d0(cl_rg_11_3_d0),
    .cl_rg_11_3_q0(cl_rg_11_3_q0),
    .cl_rg_11_3_ce0(cl_rg_11_3_ce0),
    .cl_rg_11_3_we0(cl_rg_11_3_we0),
    .cl_rg_11_3_addr1(cl_rg_11_3_addr1),
    .cl_rg_11_3_d1(cl_rg_11_3_d1),
    .cl_rg_11_3_q1(cl_rg_11_3_q1),
    .cl_rg_11_3_ce1(cl_rg_11_3_ce1),
    .cl_rg_11_3_we1(cl_rg_11_3_we1),

    .cl_rg_12_0_addr0(cl_rg_12_0_addr0),
    .cl_rg_12_0_d0(cl_rg_12_0_d0),
    .cl_rg_12_0_q0(cl_rg_12_0_q0),
    .cl_rg_12_0_ce0(cl_rg_12_0_ce0),
    .cl_rg_12_0_we0(cl_rg_12_0_we0),
    .cl_rg_12_0_addr1(cl_rg_12_0_addr1),
    .cl_rg_12_0_d1(cl_rg_12_0_d1),
    .cl_rg_12_0_q1(cl_rg_12_0_q1),
    .cl_rg_12_0_ce1(cl_rg_12_0_ce1),
    .cl_rg_12_0_we1(cl_rg_12_0_we1),

    .cl_rg_12_1_addr0(cl_rg_12_1_addr0),
    .cl_rg_12_1_d0(cl_rg_12_1_d0),
    .cl_rg_12_1_q0(cl_rg_12_1_q0),
    .cl_rg_12_1_ce0(cl_rg_12_1_ce0),
    .cl_rg_12_1_we0(cl_rg_12_1_we0),
    .cl_rg_12_1_addr1(cl_rg_12_1_addr1),
    .cl_rg_12_1_d1(cl_rg_12_1_d1),
    .cl_rg_12_1_q1(cl_rg_12_1_q1),
    .cl_rg_12_1_ce1(cl_rg_12_1_ce1),
    .cl_rg_12_1_we1(cl_rg_12_1_we1),

    .cl_rg_12_2_addr0(cl_rg_12_2_addr0),
    .cl_rg_12_2_d0(cl_rg_12_2_d0),
    .cl_rg_12_2_q0(cl_rg_12_2_q0),
    .cl_rg_12_2_ce0(cl_rg_12_2_ce0),
    .cl_rg_12_2_we0(cl_rg_12_2_we0),
    .cl_rg_12_2_addr1(cl_rg_12_2_addr1),
    .cl_rg_12_2_d1(cl_rg_12_2_d1),
    .cl_rg_12_2_q1(cl_rg_12_2_q1),
    .cl_rg_12_2_ce1(cl_rg_12_2_ce1),
    .cl_rg_12_2_we1(cl_rg_12_2_we1),

    .cl_rg_12_3_addr0(cl_rg_12_3_addr0),
    .cl_rg_12_3_d0(cl_rg_12_3_d0),
    .cl_rg_12_3_q0(cl_rg_12_3_q0),
    .cl_rg_12_3_ce0(cl_rg_12_3_ce0),
    .cl_rg_12_3_we0(cl_rg_12_3_we0),
    .cl_rg_12_3_addr1(cl_rg_12_3_addr1),
    .cl_rg_12_3_d1(cl_rg_12_3_d1),
    .cl_rg_12_3_q1(cl_rg_12_3_q1),
    .cl_rg_12_3_ce1(cl_rg_12_3_ce1),
    .cl_rg_12_3_we1(cl_rg_12_3_we1),

    .cl_rg_13_0_addr0(cl_rg_13_0_addr0),
    .cl_rg_13_0_d0(cl_rg_13_0_d0),
    .cl_rg_13_0_q0(cl_rg_13_0_q0),
    .cl_rg_13_0_ce0(cl_rg_13_0_ce0),
    .cl_rg_13_0_we0(cl_rg_13_0_we0),
    .cl_rg_13_0_addr1(cl_rg_13_0_addr1),
    .cl_rg_13_0_d1(cl_rg_13_0_d1),
    .cl_rg_13_0_q1(cl_rg_13_0_q1),
    .cl_rg_13_0_ce1(cl_rg_13_0_ce1),
    .cl_rg_13_0_we1(cl_rg_13_0_we1),

    .cl_rg_13_1_addr0(cl_rg_13_1_addr0),
    .cl_rg_13_1_d0(cl_rg_13_1_d0),
    .cl_rg_13_1_q0(cl_rg_13_1_q0),
    .cl_rg_13_1_ce0(cl_rg_13_1_ce0),
    .cl_rg_13_1_we0(cl_rg_13_1_we0),
    .cl_rg_13_1_addr1(cl_rg_13_1_addr1),
    .cl_rg_13_1_d1(cl_rg_13_1_d1),
    .cl_rg_13_1_q1(cl_rg_13_1_q1),
    .cl_rg_13_1_ce1(cl_rg_13_1_ce1),
    .cl_rg_13_1_we1(cl_rg_13_1_we1),

    .cl_rg_13_2_addr0(cl_rg_13_2_addr0),
    .cl_rg_13_2_d0(cl_rg_13_2_d0),
    .cl_rg_13_2_q0(cl_rg_13_2_q0),
    .cl_rg_13_2_ce0(cl_rg_13_2_ce0),
    .cl_rg_13_2_we0(cl_rg_13_2_we0),
    .cl_rg_13_2_addr1(cl_rg_13_2_addr1),
    .cl_rg_13_2_d1(cl_rg_13_2_d1),
    .cl_rg_13_2_q1(cl_rg_13_2_q1),
    .cl_rg_13_2_ce1(cl_rg_13_2_ce1),
    .cl_rg_13_2_we1(cl_rg_13_2_we1),

    .cl_rg_13_3_addr0(cl_rg_13_3_addr0),
    .cl_rg_13_3_d0(cl_rg_13_3_d0),
    .cl_rg_13_3_q0(cl_rg_13_3_q0),
    .cl_rg_13_3_ce0(cl_rg_13_3_ce0),
    .cl_rg_13_3_we0(cl_rg_13_3_we0),
    .cl_rg_13_3_addr1(cl_rg_13_3_addr1),
    .cl_rg_13_3_d1(cl_rg_13_3_d1),
    .cl_rg_13_3_q1(cl_rg_13_3_q1),
    .cl_rg_13_3_ce1(cl_rg_13_3_ce1),
    .cl_rg_13_3_we1(cl_rg_13_3_we1),

    .cl_rg_14_0_addr0(cl_rg_14_0_addr0),
    .cl_rg_14_0_d0(cl_rg_14_0_d0),
    .cl_rg_14_0_q0(cl_rg_14_0_q0),
    .cl_rg_14_0_ce0(cl_rg_14_0_ce0),
    .cl_rg_14_0_we0(cl_rg_14_0_we0),
    .cl_rg_14_0_addr1(cl_rg_14_0_addr1),
    .cl_rg_14_0_d1(cl_rg_14_0_d1),
    .cl_rg_14_0_q1(cl_rg_14_0_q1),
    .cl_rg_14_0_ce1(cl_rg_14_0_ce1),
    .cl_rg_14_0_we1(cl_rg_14_0_we1),

    .cl_rg_14_1_addr0(cl_rg_14_1_addr0),
    .cl_rg_14_1_d0(cl_rg_14_1_d0),
    .cl_rg_14_1_q0(cl_rg_14_1_q0),
    .cl_rg_14_1_ce0(cl_rg_14_1_ce0),
    .cl_rg_14_1_we0(cl_rg_14_1_we0),
    .cl_rg_14_1_addr1(cl_rg_14_1_addr1),
    .cl_rg_14_1_d1(cl_rg_14_1_d1),
    .cl_rg_14_1_q1(cl_rg_14_1_q1),
    .cl_rg_14_1_ce1(cl_rg_14_1_ce1),
    .cl_rg_14_1_we1(cl_rg_14_1_we1),

    .cl_rg_14_2_addr0(cl_rg_14_2_addr0),
    .cl_rg_14_2_d0(cl_rg_14_2_d0),
    .cl_rg_14_2_q0(cl_rg_14_2_q0),
    .cl_rg_14_2_ce0(cl_rg_14_2_ce0),
    .cl_rg_14_2_we0(cl_rg_14_2_we0),
    .cl_rg_14_2_addr1(cl_rg_14_2_addr1),
    .cl_rg_14_2_d1(cl_rg_14_2_d1),
    .cl_rg_14_2_q1(cl_rg_14_2_q1),
    .cl_rg_14_2_ce1(cl_rg_14_2_ce1),
    .cl_rg_14_2_we1(cl_rg_14_2_we1),

    .cl_rg_14_3_addr0(cl_rg_14_3_addr0),
    .cl_rg_14_3_d0(cl_rg_14_3_d0),
    .cl_rg_14_3_q0(cl_rg_14_3_q0),
    .cl_rg_14_3_ce0(cl_rg_14_3_ce0),
    .cl_rg_14_3_we0(cl_rg_14_3_we0),
    .cl_rg_14_3_addr1(cl_rg_14_3_addr1),
    .cl_rg_14_3_d1(cl_rg_14_3_d1),
    .cl_rg_14_3_q1(cl_rg_14_3_q1),
    .cl_rg_14_3_ce1(cl_rg_14_3_ce1),
    .cl_rg_14_3_we1(cl_rg_14_3_we1),

    .cl_rg_15_0_addr0(cl_rg_15_0_addr0),
    .cl_rg_15_0_d0(cl_rg_15_0_d0),
    .cl_rg_15_0_q0(cl_rg_15_0_q0),
    .cl_rg_15_0_ce0(cl_rg_15_0_ce0),
    .cl_rg_15_0_we0(cl_rg_15_0_we0),
    .cl_rg_15_0_addr1(cl_rg_15_0_addr1),
    .cl_rg_15_0_d1(cl_rg_15_0_d1),
    .cl_rg_15_0_q1(cl_rg_15_0_q1),
    .cl_rg_15_0_ce1(cl_rg_15_0_ce1),
    .cl_rg_15_0_we1(cl_rg_15_0_we1),

    .cl_rg_15_1_addr0(cl_rg_15_1_addr0),
    .cl_rg_15_1_d0(cl_rg_15_1_d0),
    .cl_rg_15_1_q0(cl_rg_15_1_q0),
    .cl_rg_15_1_ce0(cl_rg_15_1_ce0),
    .cl_rg_15_1_we0(cl_rg_15_1_we0),
    .cl_rg_15_1_addr1(cl_rg_15_1_addr1),
    .cl_rg_15_1_d1(cl_rg_15_1_d1),
    .cl_rg_15_1_q1(cl_rg_15_1_q1),
    .cl_rg_15_1_ce1(cl_rg_15_1_ce1),
    .cl_rg_15_1_we1(cl_rg_15_1_we1),

    .cl_rg_15_2_addr0(cl_rg_15_2_addr0),
    .cl_rg_15_2_d0(cl_rg_15_2_d0),
    .cl_rg_15_2_q0(cl_rg_15_2_q0),
    .cl_rg_15_2_ce0(cl_rg_15_2_ce0),
    .cl_rg_15_2_we0(cl_rg_15_2_we0),
    .cl_rg_15_2_addr1(cl_rg_15_2_addr1),
    .cl_rg_15_2_d1(cl_rg_15_2_d1),
    .cl_rg_15_2_q1(cl_rg_15_2_q1),
    .cl_rg_15_2_ce1(cl_rg_15_2_ce1),
    .cl_rg_15_2_we1(cl_rg_15_2_we1),

    .cl_rg_15_3_addr0(cl_rg_15_3_addr0),
    .cl_rg_15_3_d0(cl_rg_15_3_d0),
    .cl_rg_15_3_q0(cl_rg_15_3_q0),
    .cl_rg_15_3_ce0(cl_rg_15_3_ce0),
    .cl_rg_15_3_we0(cl_rg_15_3_we0),
    .cl_rg_15_3_addr1(cl_rg_15_3_addr1),
    .cl_rg_15_3_d1(cl_rg_15_3_d1),
    .cl_rg_15_3_q1(cl_rg_15_3_q1),
    .cl_rg_15_3_ce1(cl_rg_15_3_ce1),
    .cl_rg_15_3_we1(cl_rg_15_3_we1),

    .cl_rg_16_0_addr0(cl_rg_16_0_addr0),
    .cl_rg_16_0_d0(cl_rg_16_0_d0),
    .cl_rg_16_0_q0(cl_rg_16_0_q0),
    .cl_rg_16_0_ce0(cl_rg_16_0_ce0),
    .cl_rg_16_0_we0(cl_rg_16_0_we0),
    .cl_rg_16_0_addr1(cl_rg_16_0_addr1),
    .cl_rg_16_0_d1(cl_rg_16_0_d1),
    .cl_rg_16_0_q1(cl_rg_16_0_q1),
    .cl_rg_16_0_ce1(cl_rg_16_0_ce1),
    .cl_rg_16_0_we1(cl_rg_16_0_we1),

    .cl_rg_16_1_addr0(cl_rg_16_1_addr0),
    .cl_rg_16_1_d0(cl_rg_16_1_d0),
    .cl_rg_16_1_q0(cl_rg_16_1_q0),
    .cl_rg_16_1_ce0(cl_rg_16_1_ce0),
    .cl_rg_16_1_we0(cl_rg_16_1_we0),
    .cl_rg_16_1_addr1(cl_rg_16_1_addr1),
    .cl_rg_16_1_d1(cl_rg_16_1_d1),
    .cl_rg_16_1_q1(cl_rg_16_1_q1),
    .cl_rg_16_1_ce1(cl_rg_16_1_ce1),
    .cl_rg_16_1_we1(cl_rg_16_1_we1),

    .cl_rg_16_2_addr0(cl_rg_16_2_addr0),
    .cl_rg_16_2_d0(cl_rg_16_2_d0),
    .cl_rg_16_2_q0(cl_rg_16_2_q0),
    .cl_rg_16_2_ce0(cl_rg_16_2_ce0),
    .cl_rg_16_2_we0(cl_rg_16_2_we0),
    .cl_rg_16_2_addr1(cl_rg_16_2_addr1),
    .cl_rg_16_2_d1(cl_rg_16_2_d1),
    .cl_rg_16_2_q1(cl_rg_16_2_q1),
    .cl_rg_16_2_ce1(cl_rg_16_2_ce1),
    .cl_rg_16_2_we1(cl_rg_16_2_we1),

    .cl_rg_16_3_addr0(cl_rg_16_3_addr0),
    .cl_rg_16_3_d0(cl_rg_16_3_d0),
    .cl_rg_16_3_q0(cl_rg_16_3_q0),
    .cl_rg_16_3_ce0(cl_rg_16_3_ce0),
    .cl_rg_16_3_we0(cl_rg_16_3_we0),
    .cl_rg_16_3_addr1(cl_rg_16_3_addr1),
    .cl_rg_16_3_d1(cl_rg_16_3_d1),
    .cl_rg_16_3_q1(cl_rg_16_3_q1),
    .cl_rg_16_3_ce1(cl_rg_16_3_ce1),
    .cl_rg_16_3_we1(cl_rg_16_3_we1),

    .cl_rg_17_0_addr0(cl_rg_17_0_addr0),
    .cl_rg_17_0_d0(cl_rg_17_0_d0),
    .cl_rg_17_0_q0(cl_rg_17_0_q0),
    .cl_rg_17_0_ce0(cl_rg_17_0_ce0),
    .cl_rg_17_0_we0(cl_rg_17_0_we0),
    .cl_rg_17_0_addr1(cl_rg_17_0_addr1),
    .cl_rg_17_0_d1(cl_rg_17_0_d1),
    .cl_rg_17_0_q1(cl_rg_17_0_q1),
    .cl_rg_17_0_ce1(cl_rg_17_0_ce1),
    .cl_rg_17_0_we1(cl_rg_17_0_we1),

    .cl_rg_17_1_addr0(cl_rg_17_1_addr0),
    .cl_rg_17_1_d0(cl_rg_17_1_d0),
    .cl_rg_17_1_q0(cl_rg_17_1_q0),
    .cl_rg_17_1_ce0(cl_rg_17_1_ce0),
    .cl_rg_17_1_we0(cl_rg_17_1_we0),
    .cl_rg_17_1_addr1(cl_rg_17_1_addr1),
    .cl_rg_17_1_d1(cl_rg_17_1_d1),
    .cl_rg_17_1_q1(cl_rg_17_1_q1),
    .cl_rg_17_1_ce1(cl_rg_17_1_ce1),
    .cl_rg_17_1_we1(cl_rg_17_1_we1),

    .cl_rg_17_2_addr0(cl_rg_17_2_addr0),
    .cl_rg_17_2_d0(cl_rg_17_2_d0),
    .cl_rg_17_2_q0(cl_rg_17_2_q0),
    .cl_rg_17_2_ce0(cl_rg_17_2_ce0),
    .cl_rg_17_2_we0(cl_rg_17_2_we0),
    .cl_rg_17_2_addr1(cl_rg_17_2_addr1),
    .cl_rg_17_2_d1(cl_rg_17_2_d1),
    .cl_rg_17_2_q1(cl_rg_17_2_q1),
    .cl_rg_17_2_ce1(cl_rg_17_2_ce1),
    .cl_rg_17_2_we1(cl_rg_17_2_we1),

    .cl_rg_17_3_addr0(cl_rg_17_3_addr0),
    .cl_rg_17_3_d0(cl_rg_17_3_d0),
    .cl_rg_17_3_q0(cl_rg_17_3_q0),
    .cl_rg_17_3_ce0(cl_rg_17_3_ce0),
    .cl_rg_17_3_we0(cl_rg_17_3_we0),
    .cl_rg_17_3_addr1(cl_rg_17_3_addr1),
    .cl_rg_17_3_d1(cl_rg_17_3_d1),
    .cl_rg_17_3_q1(cl_rg_17_3_q1),
    .cl_rg_17_3_ce1(cl_rg_17_3_ce1),
    .cl_rg_17_3_we1(cl_rg_17_3_we1),

    .cl_rg_18_0_addr0(cl_rg_18_0_addr0),
    .cl_rg_18_0_d0(cl_rg_18_0_d0),
    .cl_rg_18_0_q0(cl_rg_18_0_q0),
    .cl_rg_18_0_ce0(cl_rg_18_0_ce0),
    .cl_rg_18_0_we0(cl_rg_18_0_we0),
    .cl_rg_18_0_addr1(cl_rg_18_0_addr1),
    .cl_rg_18_0_d1(cl_rg_18_0_d1),
    .cl_rg_18_0_q1(cl_rg_18_0_q1),
    .cl_rg_18_0_ce1(cl_rg_18_0_ce1),
    .cl_rg_18_0_we1(cl_rg_18_0_we1),

    .cl_rg_18_1_addr0(cl_rg_18_1_addr0),
    .cl_rg_18_1_d0(cl_rg_18_1_d0),
    .cl_rg_18_1_q0(cl_rg_18_1_q0),
    .cl_rg_18_1_ce0(cl_rg_18_1_ce0),
    .cl_rg_18_1_we0(cl_rg_18_1_we0),
    .cl_rg_18_1_addr1(cl_rg_18_1_addr1),
    .cl_rg_18_1_d1(cl_rg_18_1_d1),
    .cl_rg_18_1_q1(cl_rg_18_1_q1),
    .cl_rg_18_1_ce1(cl_rg_18_1_ce1),
    .cl_rg_18_1_we1(cl_rg_18_1_we1),

    .cl_rg_18_2_addr0(cl_rg_18_2_addr0),
    .cl_rg_18_2_d0(cl_rg_18_2_d0),
    .cl_rg_18_2_q0(cl_rg_18_2_q0),
    .cl_rg_18_2_ce0(cl_rg_18_2_ce0),
    .cl_rg_18_2_we0(cl_rg_18_2_we0),
    .cl_rg_18_2_addr1(cl_rg_18_2_addr1),
    .cl_rg_18_2_d1(cl_rg_18_2_d1),
    .cl_rg_18_2_q1(cl_rg_18_2_q1),
    .cl_rg_18_2_ce1(cl_rg_18_2_ce1),
    .cl_rg_18_2_we1(cl_rg_18_2_we1),

    .cl_rg_18_3_addr0(cl_rg_18_3_addr0),
    .cl_rg_18_3_d0(cl_rg_18_3_d0),
    .cl_rg_18_3_q0(cl_rg_18_3_q0),
    .cl_rg_18_3_ce0(cl_rg_18_3_ce0),
    .cl_rg_18_3_we0(cl_rg_18_3_we0),
    .cl_rg_18_3_addr1(cl_rg_18_3_addr1),
    .cl_rg_18_3_d1(cl_rg_18_3_d1),
    .cl_rg_18_3_q1(cl_rg_18_3_q1),
    .cl_rg_18_3_ce1(cl_rg_18_3_ce1),
    .cl_rg_18_3_we1(cl_rg_18_3_we1),

    .cl_rg_19_0_addr0(cl_rg_19_0_addr0),
    .cl_rg_19_0_d0(cl_rg_19_0_d0),
    .cl_rg_19_0_q0(cl_rg_19_0_q0),
    .cl_rg_19_0_ce0(cl_rg_19_0_ce0),
    .cl_rg_19_0_we0(cl_rg_19_0_we0),
    .cl_rg_19_0_addr1(cl_rg_19_0_addr1),
    .cl_rg_19_0_d1(cl_rg_19_0_d1),
    .cl_rg_19_0_q1(cl_rg_19_0_q1),
    .cl_rg_19_0_ce1(cl_rg_19_0_ce1),
    .cl_rg_19_0_we1(cl_rg_19_0_we1),

    .cl_rg_19_1_addr0(cl_rg_19_1_addr0),
    .cl_rg_19_1_d0(cl_rg_19_1_d0),
    .cl_rg_19_1_q0(cl_rg_19_1_q0),
    .cl_rg_19_1_ce0(cl_rg_19_1_ce0),
    .cl_rg_19_1_we0(cl_rg_19_1_we0),
    .cl_rg_19_1_addr1(cl_rg_19_1_addr1),
    .cl_rg_19_1_d1(cl_rg_19_1_d1),
    .cl_rg_19_1_q1(cl_rg_19_1_q1),
    .cl_rg_19_1_ce1(cl_rg_19_1_ce1),
    .cl_rg_19_1_we1(cl_rg_19_1_we1),

    .cl_rg_19_2_addr0(cl_rg_19_2_addr0),
    .cl_rg_19_2_d0(cl_rg_19_2_d0),
    .cl_rg_19_2_q0(cl_rg_19_2_q0),
    .cl_rg_19_2_ce0(cl_rg_19_2_ce0),
    .cl_rg_19_2_we0(cl_rg_19_2_we0),
    .cl_rg_19_2_addr1(cl_rg_19_2_addr1),
    .cl_rg_19_2_d1(cl_rg_19_2_d1),
    .cl_rg_19_2_q1(cl_rg_19_2_q1),
    .cl_rg_19_2_ce1(cl_rg_19_2_ce1),
    .cl_rg_19_2_we1(cl_rg_19_2_we1),

    .cl_rg_19_3_addr0(cl_rg_19_3_addr0),
    .cl_rg_19_3_d0(cl_rg_19_3_d0),
    .cl_rg_19_3_q0(cl_rg_19_3_q0),
    .cl_rg_19_3_ce0(cl_rg_19_3_ce0),
    .cl_rg_19_3_we0(cl_rg_19_3_we0),
    .cl_rg_19_3_addr1(cl_rg_19_3_addr1),
    .cl_rg_19_3_d1(cl_rg_19_3_d1),
    .cl_rg_19_3_q1(cl_rg_19_3_q1),
    .cl_rg_19_3_ce1(cl_rg_19_3_ce1),
    .cl_rg_19_3_we1(cl_rg_19_3_we1),

    .cl_rg_20_0_addr0(cl_rg_20_0_addr0),
    .cl_rg_20_0_d0(cl_rg_20_0_d0),
    .cl_rg_20_0_q0(cl_rg_20_0_q0),
    .cl_rg_20_0_ce0(cl_rg_20_0_ce0),
    .cl_rg_20_0_we0(cl_rg_20_0_we0),
    .cl_rg_20_0_addr1(cl_rg_20_0_addr1),
    .cl_rg_20_0_d1(cl_rg_20_0_d1),
    .cl_rg_20_0_q1(cl_rg_20_0_q1),
    .cl_rg_20_0_ce1(cl_rg_20_0_ce1),
    .cl_rg_20_0_we1(cl_rg_20_0_we1),

    .cl_rg_20_1_addr0(cl_rg_20_1_addr0),
    .cl_rg_20_1_d0(cl_rg_20_1_d0),
    .cl_rg_20_1_q0(cl_rg_20_1_q0),
    .cl_rg_20_1_ce0(cl_rg_20_1_ce0),
    .cl_rg_20_1_we0(cl_rg_20_1_we0),
    .cl_rg_20_1_addr1(cl_rg_20_1_addr1),
    .cl_rg_20_1_d1(cl_rg_20_1_d1),
    .cl_rg_20_1_q1(cl_rg_20_1_q1),
    .cl_rg_20_1_ce1(cl_rg_20_1_ce1),
    .cl_rg_20_1_we1(cl_rg_20_1_we1),

    .cl_rg_20_2_addr0(cl_rg_20_2_addr0),
    .cl_rg_20_2_d0(cl_rg_20_2_d0),
    .cl_rg_20_2_q0(cl_rg_20_2_q0),
    .cl_rg_20_2_ce0(cl_rg_20_2_ce0),
    .cl_rg_20_2_we0(cl_rg_20_2_we0),
    .cl_rg_20_2_addr1(cl_rg_20_2_addr1),
    .cl_rg_20_2_d1(cl_rg_20_2_d1),
    .cl_rg_20_2_q1(cl_rg_20_2_q1),
    .cl_rg_20_2_ce1(cl_rg_20_2_ce1),
    .cl_rg_20_2_we1(cl_rg_20_2_we1),

    .cl_rg_20_3_addr0(cl_rg_20_3_addr0),
    .cl_rg_20_3_d0(cl_rg_20_3_d0),
    .cl_rg_20_3_q0(cl_rg_20_3_q0),
    .cl_rg_20_3_ce0(cl_rg_20_3_ce0),
    .cl_rg_20_3_we0(cl_rg_20_3_we0),
    .cl_rg_20_3_addr1(cl_rg_20_3_addr1),
    .cl_rg_20_3_d1(cl_rg_20_3_d1),
    .cl_rg_20_3_q1(cl_rg_20_3_q1),
    .cl_rg_20_3_ce1(cl_rg_20_3_ce1),
    .cl_rg_20_3_we1(cl_rg_20_3_we1),

    .clk(clk),
    .rst(socket_reset_ff)
  );

endmodule
