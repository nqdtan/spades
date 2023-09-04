`timescale 1ns/1ps
`include "socket_config.vh"

module socket_top #(
  parameter AXI_AWIDTH = 64,
  parameter AXI_DWIDTH = 512,//256,//64,
  parameter AXI_MAX_BURST_LEN = 256,
  parameter DMEM_AWIDTH = `DMEM_AWIDTH,
  parameter DMEM_AWIDTH_LM = 13,
  parameter DMEM_DWIDTH = 512,//256,//64,
  parameter DMEM_MIF_HEX = "",
  parameter IMEM_MIF_HEX = "",
  parameter AXIS_DWIDTH = 256,
  parameter AXIS_DESTW  = 1,
  parameter SOCKET_BASE_ADDR = 64'h0000_0201_0000_0000
) (
  // AXI bus Slave interface
  // Read address channel
  input [3:0]               s0_arid,
  input [AXI_AWIDTH-1:0]    s0_araddr,
  input                     s0_arvalid,
  output                    s0_arready,
  input [7:0]               s0_arlen,
  input [2:0]               s0_arsize,
  input [1:0]               s0_arburst,
  // lock, cache, prot, qos, region, user (unused)

  // Read data channel
  output  [3:0]             s0_rid,
  output  [AXI_DWIDTH-1:0]  s0_rdata,
  output                    s0_rvalid,
  input                     s0_rready,
  output                    s0_rlast,
  output  [1:0]             s0_rresp,
  // user (unused)

  // Write address channel
  input [3:0]               s0_awid,
  input [AXI_AWIDTH-1:0]    s0_awaddr,
  input                     s0_awvalid,
  output                    s0_awready,
  input [7:0]               s0_awlen,
  input [2:0]               s0_awsize,
  input [1:0]               s0_awburst,
  // lock, cache, prot, qos, region, user (unused)

  // Write data channel
  input [3:0]               s0_wid,
  input [AXI_DWIDTH-1:0]    s0_wdata,
  input                     s0_wvalid,
  output                    s0_wready,
  input                     s0_wlast,
  input [AXI_DWIDTH/8-1:0]  s0_wstrb,
  // user (unused)

  // Write response channel
  output [3:0]              s0_bid,
  output [1:0]              s0_bresp,
  output                    s0_bvalid,
  input                     s0_bready,
  // user (unused)

  // AXI bus Master interface
  // Read address channel
  output [3:0]              m0_arid,
  output [AXI_AWIDTH-1:0]   m0_araddr,
  output                    m0_arvalid,
  input                     m0_arready,
  output [7:0]              m0_arlen,
  output [2:0]              m0_arsize,
  output [1:0]              m0_arburst,
  // lock, cache, prot, qos, region, user (unused)

  // Read data channel
  input [3:0]               m0_rid,
  input [AXI_DWIDTH-1:0]    m0_rdata,
  input                     m0_rvalid,
  output                    m0_rready,
  input                     m0_rlast,
  input [1:0]               m0_rresp,
  // user (unused)

  // Write address channel
  output [3:0]              m0_awid,
  output [AXI_AWIDTH-1:0]   m0_awaddr,
  output                    m0_awvalid,
  input                     m0_awready,
  output [7:0]              m0_awlen,
  output [2:0]              m0_awsize,
  output [1:0]              m0_awburst,
  // lock, cache, prot, qos, region, user (unused)

  // Write data channel
  output [3:0]              m0_wid,
  output [AXI_DWIDTH-1:0]   m0_wdata,
  output                    m0_wvalid,
  input                     m0_wready,
  output                    m0_wlast,
  output [AXI_DWIDTH/8-1:0] m0_wstrb,
  // user (unused)

  // Write response channel
  input [3:0]               m0_bid,
  input [1:0]               m0_bresp,
  input                     m0_bvalid,
  output                    m0_bready,
  // user (unused)

`ifndef SOCKET_S
  // AXI bus Master interface
  // Read address channel
  output [3:0]              m1_arid,
  output [AXI_AWIDTH-1:0]   m1_araddr,
  output                    m1_arvalid,
  input                     m1_arready,
  output [7:0]              m1_arlen,
  output [2:0]              m1_arsize,
  output [1:0]              m1_arburst,
  // lock, cache, prot, qos, region, user (unused)

  // Read data channel
  input [3:0]               m1_rid,
  input [AXI_DWIDTH-1:0]    m1_rdata,
  input                     m1_rvalid,
  output                    m1_rready,
  input                     m1_rlast,
  input [1:0]               m1_rresp,
  // user (unused)

  // Write address channel
  output [3:0]              m1_awid,
  output [AXI_AWIDTH-1:0]   m1_awaddr,
  output                    m1_awvalid,
  input                     m1_awready,
  output [7:0]              m1_awlen,
  output [2:0]              m1_awsize,
  output [1:0]              m1_awburst,
  // lock, cache, prot, qos, region, user (unused)

  // Write data channel
  output [3:0]              m1_wid,
  output [AXI_DWIDTH-1:0]   m1_wdata,
  output                    m1_wvalid,
  input                     m1_wready,
  output                    m1_wlast,
  output [AXI_DWIDTH/8-1:0] m1_wstrb,
  // user (unused)

  // Write response channel
  input [3:0]               m1_bid,
  input [1:0]               m1_bresp,
  input                     m1_bvalid,
  output                    m1_bready,
  // user (unused)
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

`ifdef EXCLUDE_RG_CL
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
`endif

  (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF m_axis:s_axis" *) input f_clk,
  (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF m0:m1:s0" *)      input clk
);
  wire socket_start;

  wire [DMEM_AWIDTH_LM-1:0] dmem_addr_lm;
  wire [DMEM_DWIDTH-1:0] dmem_din_lm, dmem_dout_lm;
  wire dmem_we_lm, dmem_en_lm;

  wire socket_reset_cdc;

`ifndef EXCLUDE_RG_CL
  wire socket_reset;

  wire lsu0_dp_mode;

  wire [12-1:0] lsu0_port0_addr;
  wire [64-1:0] lsu0_port0_d;
  wire [64-1:0] lsu0_port0_q;
  wire          lsu0_port0_ce;
  wire          lsu0_port0_we;

  wire [12-1:0] lsu0_port1_addr;
  wire [64-1:0] lsu0_port1_d;
  wire [64-1:0] lsu0_port1_q;
  wire          lsu0_port1_ce;
  wire          lsu0_port1_we;

  wire [12-1:0] lsu0_port2_addr;
  wire [64-1:0] lsu0_port2_d;
  wire [64-1:0] lsu0_port2_q;
  wire          lsu0_port2_ce;
  wire          lsu0_port2_we;

  wire [12-1:0] lsu0_port3_addr;
  wire [64-1:0] lsu0_port3_d;
  wire [64-1:0] lsu0_port3_q;
  wire          lsu0_port3_ce;
  wire          lsu0_port3_we;

  wire [4:0] lsu0_ram_en;

`ifndef SOCKET_S
  wire lsu1_dp_mode;

  wire [12-1:0] lsu1_port0_addr;
  wire [64-1:0] lsu1_port0_d;
  wire [64-1:0] lsu1_port0_q;
  wire          lsu1_port0_ce;
  wire          lsu1_port0_we;

  wire [12-1:0] lsu1_port1_addr;
  wire [64-1:0] lsu1_port1_d;
  wire [64-1:0] lsu1_port1_q;
  wire          lsu1_port1_ce;
  wire          lsu1_port1_we;

  wire [12-1:0] lsu1_port2_addr;
  wire [64-1:0] lsu1_port2_d;
  wire [64-1:0] lsu1_port2_q;
  wire          lsu1_port2_ce;
  wire          lsu1_port2_we;

  wire [12-1:0] lsu1_port3_addr;
  wire [64-1:0] lsu1_port3_d;
  wire [64-1:0] lsu1_port3_q;
  wire          lsu1_port3_ce;
  wire          lsu1_port3_we;

  wire [4:0] lsu1_ram_en;
`endif

  wire        cl_done;
  wire [11:0] cl_ctrl_addr;
  wire [31:0] cl_ctrl_d;
  wire [31:0] cl_ctrl_q;
  wire        cl_ctrl_ce;
  wire        cl_ctrl_we;

  rg_cl_wrapper rg_cl_wrapper (
    .clk(f_clk),
    .socket_reset(socket_reset),

    .lsu0_dp_mode(lsu0_dp_mode),

    .lsu0_port0_addr(lsu0_port0_addr),
    .lsu0_port0_d(lsu0_port0_d),
    .lsu0_port0_q(lsu0_port0_q),
    .lsu0_port0_ce(lsu0_port0_ce),
    .lsu0_port0_we(lsu0_port0_we),

    .lsu0_port1_addr(lsu0_port1_addr),
    .lsu0_port1_d(lsu0_port1_d),
    .lsu0_port1_q(lsu0_port1_q),
    .lsu0_port1_ce(lsu0_port1_ce),
    .lsu0_port1_we(lsu0_port1_we),

    .lsu0_port2_addr(lsu0_port2_addr),
    .lsu0_port2_d(lsu0_port2_d),
    .lsu0_port2_q(lsu0_port2_q),
    .lsu0_port2_ce(lsu0_port2_ce),
    .lsu0_port2_we(lsu0_port2_we),

    .lsu0_port3_addr(lsu0_port3_addr),
    .lsu0_port3_d(lsu0_port3_d),
    .lsu0_port3_q(lsu0_port3_q),
    .lsu0_port3_ce(lsu0_port3_ce),
    .lsu0_port3_we(lsu0_port3_we),

    .lsu0_ram_en(lsu0_ram_en),

`ifndef SOCKET_S
    .lsu1_dp_mode(lsu1_dp_mode),

    .lsu1_port0_addr(lsu1_port0_addr),
    .lsu1_port0_d(lsu1_port0_d),
    .lsu1_port0_q(lsu1_port0_q),
    .lsu1_port0_ce(lsu1_port0_ce),
    .lsu1_port0_we(lsu1_port0_we),

    .lsu1_port1_addr(lsu1_port1_addr),
    .lsu1_port1_d(lsu1_port1_d),
    .lsu1_port1_q(lsu1_port1_q),
    .lsu1_port1_ce(lsu1_port1_ce),
    .lsu1_port1_we(lsu1_port1_we),

    .lsu1_port2_addr(lsu1_port2_addr),
    .lsu1_port2_d(lsu1_port2_d),
    .lsu1_port2_q(lsu1_port2_q),
    .lsu1_port2_ce(lsu1_port2_ce),
    .lsu1_port2_we(lsu1_port2_we),

    .lsu1_port3_addr(lsu1_port3_addr),
    .lsu1_port3_d(lsu1_port3_d),
    .lsu1_port3_q(lsu1_port3_q),
    .lsu1_port3_ce(lsu1_port3_ce),
    .lsu1_port3_we(lsu1_port3_we),

    .lsu1_ram_en(lsu1_ram_en),
`endif

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

    .cl_done(cl_done),
    .cl_ctrl_addr(cl_ctrl_addr),
    .cl_ctrl_d(cl_ctrl_d),
    .cl_ctrl_q(cl_ctrl_q),
    .cl_ctrl_ce(cl_ctrl_ce),
    .cl_ctrl_we(cl_ctrl_we)
  );

`endif

  // ff_bridge
  wire lsu0_dp_mode_tmp;
  wire [11:0] lsu0_port0_addr_tmp;
  wire [63:0] lsu0_port0_d_tmp;
  wire [63:0] lsu0_port0_q_tmp;
  wire lsu0_port0_ce_tmp;
  wire lsu0_port0_we_tmp;
  wire [11:0] lsu0_port1_addr_tmp;
  wire [63:0] lsu0_port1_d_tmp;
  wire [63:0] lsu0_port1_q_tmp;
  wire lsu0_port1_ce_tmp;
  wire lsu0_port1_we_tmp;
  wire [11:0] lsu0_port2_addr_tmp;
  wire [63:0] lsu0_port2_d_tmp;
  wire [63:0] lsu0_port2_q_tmp;
  wire lsu0_port2_ce_tmp;
  wire lsu0_port2_we_tmp;
  wire [11:0] lsu0_port3_addr_tmp;
  wire [63:0] lsu0_port3_d_tmp;
  wire [63:0] lsu0_port3_q_tmp;
  wire lsu0_port3_ce_tmp;
  wire lsu0_port3_we_tmp;
  wire [4:0] lsu0_ram_en_tmp;
`ifndef SOCKET_S
  wire lsu1_dp_mode_tmp;
  wire [11:0] lsu1_port0_addr_tmp;
  wire [63:0] lsu1_port0_d_tmp;
  wire [63:0] lsu1_port0_q_tmp;
  wire lsu1_port0_ce_tmp;
  wire lsu1_port0_we_tmp;
  wire [11:0] lsu1_port1_addr_tmp;
  wire [63:0] lsu1_port1_d_tmp;
  wire [63:0] lsu1_port1_q_tmp;
  wire lsu1_port1_ce_tmp;
  wire lsu1_port1_we_tmp;
  wire [11:0] lsu1_port2_addr_tmp;
  wire [63:0] lsu1_port2_d_tmp;
  wire [63:0] lsu1_port2_q_tmp;
  wire lsu1_port2_ce_tmp;
  wire lsu1_port2_we_tmp;
  wire [11:0] lsu1_port3_addr_tmp;
  wire [63:0] lsu1_port3_d_tmp;
  wire [63:0] lsu1_port3_q_tmp;
  wire lsu1_port3_ce_tmp;
  wire lsu1_port3_we_tmp;
  wire [4:0] lsu1_ram_en_tmp;
`endif
  wire cl_done_tmp;
  wire [11:0] cl_ctrl_addr_tmp;
  wire [31:0] cl_ctrl_d_tmp;
  wire [31:0] cl_ctrl_q_tmp;
  wire cl_ctrl_ce_tmp;
  wire cl_ctrl_we_tmp;
  wire socket_reset_tmp;

  rg_cl_intf_pipe rg_cl_intf_pipe (
    .clk(f_clk),

    .socket_reset(socket_reset),

    .lsu0_dp_mode(lsu0_dp_mode),

    .lsu0_port0_addr(lsu0_port0_addr),
    .lsu0_port0_d(lsu0_port0_d),
    .lsu0_port0_q(lsu0_port0_q),
    .lsu0_port0_ce(lsu0_port0_ce),
    .lsu0_port0_we(lsu0_port0_we),

    .lsu0_port1_addr(lsu0_port1_addr),
    .lsu0_port1_d(lsu0_port1_d),
    .lsu0_port1_q(lsu0_port1_q),
    .lsu0_port1_ce(lsu0_port1_ce),
    .lsu0_port1_we(lsu0_port1_we),

    .lsu0_port2_addr(lsu0_port2_addr),
    .lsu0_port2_d(lsu0_port2_d),
    .lsu0_port2_q(lsu0_port2_q),
    .lsu0_port2_ce(lsu0_port2_ce),
    .lsu0_port2_we(lsu0_port2_we),

    .lsu0_port3_addr(lsu0_port3_addr),
    .lsu0_port3_d(lsu0_port3_d),
    .lsu0_port3_q(lsu0_port3_q),
    .lsu0_port3_ce(lsu0_port3_ce),
    .lsu0_port3_we(lsu0_port3_we),

    .lsu0_ram_en(lsu0_ram_en),

`ifndef SOCKET_S
    .lsu1_dp_mode(lsu1_dp_mode),

    .lsu1_port0_addr(lsu1_port0_addr),
    .lsu1_port0_d(lsu1_port0_d),
    .lsu1_port0_q(lsu1_port0_q),
    .lsu1_port0_ce(lsu1_port0_ce),
    .lsu1_port0_we(lsu1_port0_we),

    .lsu1_port1_addr(lsu1_port1_addr),
    .lsu1_port1_d(lsu1_port1_d),
    .lsu1_port1_q(lsu1_port1_q),
    .lsu1_port1_ce(lsu1_port1_ce),
    .lsu1_port1_we(lsu1_port1_we),

    .lsu1_port2_addr(lsu1_port2_addr),
    .lsu1_port2_d(lsu1_port2_d),
    .lsu1_port2_q(lsu1_port2_q),
    .lsu1_port2_ce(lsu1_port2_ce),
    .lsu1_port2_we(lsu1_port2_we),

    .lsu1_port3_addr(lsu1_port3_addr),
    .lsu1_port3_d(lsu1_port3_d),
    .lsu1_port3_q(lsu1_port3_q),
    .lsu1_port3_ce(lsu1_port3_ce),
    .lsu1_port3_we(lsu1_port3_we),

    .lsu1_ram_en(lsu1_ram_en),
`endif

    .cl_done(cl_done),
    .cl_ctrl_addr(cl_ctrl_addr),
    .cl_ctrl_d(cl_ctrl_d),
    .cl_ctrl_q(cl_ctrl_q),
    .cl_ctrl_ce(cl_ctrl_ce),
    .cl_ctrl_we(cl_ctrl_we),

    // tmp
    .socket_reset_tmp(socket_reset_tmp),

    .lsu0_dp_mode_tmp(lsu0_dp_mode_tmp),

    .lsu0_port0_addr_tmp(lsu0_port0_addr_tmp),
    .lsu0_port0_d_tmp(lsu0_port0_d_tmp),
    .lsu0_port0_q_tmp(lsu0_port0_q_tmp),
    .lsu0_port0_ce_tmp(lsu0_port0_ce_tmp),
    .lsu0_port0_we_tmp(lsu0_port0_we_tmp),

    .lsu0_port1_addr_tmp(lsu0_port1_addr_tmp),
    .lsu0_port1_d_tmp(lsu0_port1_d_tmp),
    .lsu0_port1_q_tmp(lsu0_port1_q_tmp),
    .lsu0_port1_ce_tmp(lsu0_port1_ce_tmp),
    .lsu0_port1_we_tmp(lsu0_port1_we_tmp),

    .lsu0_port2_addr_tmp(lsu0_port2_addr_tmp),
    .lsu0_port2_d_tmp(lsu0_port2_d_tmp),
    .lsu0_port2_q_tmp(lsu0_port2_q_tmp),
    .lsu0_port2_ce_tmp(lsu0_port2_ce_tmp),
    .lsu0_port2_we_tmp(lsu0_port2_we_tmp),

    .lsu0_port3_addr_tmp(lsu0_port3_addr_tmp),
    .lsu0_port3_d_tmp(lsu0_port3_d_tmp),
    .lsu0_port3_q_tmp(lsu0_port3_q_tmp),
    .lsu0_port3_ce_tmp(lsu0_port3_ce_tmp),
    .lsu0_port3_we_tmp(lsu0_port3_we_tmp),

    .lsu0_ram_en_tmp(lsu0_ram_en_tmp),

`ifndef SOCKET_S
    .lsu1_dp_mode_tmp(lsu1_dp_mode_tmp),

    .lsu1_port0_addr_tmp(lsu1_port0_addr_tmp),
    .lsu1_port0_d_tmp(lsu1_port0_d_tmp),
    .lsu1_port0_q_tmp(lsu1_port0_q_tmp),
    .lsu1_port0_ce_tmp(lsu1_port0_ce_tmp),
    .lsu1_port0_we_tmp(lsu1_port0_we_tmp),

    .lsu1_port1_addr_tmp(lsu1_port1_addr_tmp),
    .lsu1_port1_d_tmp(lsu1_port1_d_tmp),
    .lsu1_port1_q_tmp(lsu1_port1_q_tmp),
    .lsu1_port1_ce_tmp(lsu1_port1_ce_tmp),
    .lsu1_port1_we_tmp(lsu1_port1_we_tmp),

    .lsu1_port2_addr_tmp(lsu1_port2_addr_tmp),
    .lsu1_port2_d_tmp(lsu1_port2_d_tmp),
    .lsu1_port2_q_tmp(lsu1_port2_q_tmp),
    .lsu1_port2_ce_tmp(lsu1_port2_ce_tmp),
    .lsu1_port2_we_tmp(lsu1_port2_we_tmp),

    .lsu1_port3_addr_tmp(lsu1_port3_addr_tmp),
    .lsu1_port3_d_tmp(lsu1_port3_d_tmp),
    .lsu1_port3_q_tmp(lsu1_port3_q_tmp),
    .lsu1_port3_ce_tmp(lsu1_port3_ce_tmp),
    .lsu1_port3_we_tmp(lsu1_port3_we_tmp),

    .lsu1_ram_en_tmp(lsu1_ram_en_tmp),
`endif

    .cl_done_tmp(cl_done_tmp),
    .cl_ctrl_addr_tmp(cl_ctrl_addr_tmp),
    .cl_ctrl_d_tmp(cl_ctrl_d_tmp),
    .cl_ctrl_q_tmp(cl_ctrl_q_tmp),
    .cl_ctrl_ce_tmp(cl_ctrl_ce_tmp),
    .cl_ctrl_we_tmp(cl_ctrl_we_tmp)
  );

  wire  [2*12-1:0] lsu0_port0_addr_cdc;
  wire  [2*64-1:0] lsu0_port0_d_cdc;
  wire  [2*64-1:0] lsu0_port0_q_cdc;
  wire  [1:0]      lsu0_port0_ce_cdc;
  wire             lsu0_port0_we_cdc;

  wire  [2*12-1:0] lsu0_port1_addr_cdc;
  wire  [2*64-1:0] lsu0_port1_d_cdc;
  wire  [2*64-1:0] lsu0_port1_q_cdc;
  wire  [1:0]      lsu0_port1_ce_cdc;
  wire             lsu0_port1_we_cdc;

  wire  [2*12-1:0] lsu0_port2_addr_cdc;
  wire  [2*64-1:0] lsu0_port2_d_cdc;
  wire  [2*64-1:0] lsu0_port2_q_cdc;
  wire  [1:0]      lsu0_port2_ce_cdc;
  wire             lsu0_port2_we_cdc;

  wire  [2*12-1:0] lsu0_port3_addr_cdc;
  wire  [2*64-1:0] lsu0_port3_d_cdc;
  wire  [2*64-1:0] lsu0_port3_q_cdc;
  wire  [1:0]      lsu0_port3_ce_cdc;
  wire             lsu0_port3_we_cdc;
  wire [4:0] lsu0_ram_en_cdc;

`ifndef SOCKET_S
  wire  [2*12-1:0] lsu1_port0_addr_cdc;
  wire  [2*64-1:0] lsu1_port0_d_cdc;
  wire  [2*64-1:0] lsu1_port0_q_cdc;
  wire  [1:0]      lsu1_port0_ce_cdc;
  wire             lsu1_port0_we_cdc;

  wire  [2*12-1:0] lsu1_port1_addr_cdc;
  wire  [2*64-1:0] lsu1_port1_d_cdc;
  wire  [2*64-1:0] lsu1_port1_q_cdc;
  wire  [1:0]      lsu1_port1_ce_cdc;
  wire             lsu1_port1_we_cdc;

  wire  [2*12-1:0] lsu1_port2_addr_cdc;
  wire  [2*64-1:0] lsu1_port2_d_cdc;
  wire  [2*64-1:0] lsu1_port2_q_cdc;
  wire  [1:0]      lsu1_port2_ce_cdc;
  wire             lsu1_port2_we_cdc;

  wire  [2*12-1:0] lsu1_port3_addr_cdc;
  wire  [2*64-1:0] lsu1_port3_d_cdc;
  wire  [2*64-1:0] lsu1_port3_q_cdc;
  wire  [1:0]      lsu1_port3_ce_cdc;
  wire             lsu1_port3_we_cdc;
  wire [4:0] lsu1_ram_en_cdc;
`endif

  wire        cl_done_cdc;
  wire [11:0] cl_ctrl_addr_cdc;
  wire [31:0] cl_ctrl_d_cdc;
  wire [31:0] cl_ctrl_q_cdc;
  wire        cl_ctrl_ce_cdc;
  wire        cl_ctrl_we_cdc;

  wire lsu0_dp_mode_cdc;
  REGISTER #(.N(1)) lsu0_dp_mode_cs (
    .clk(f_clk),
    .d(lsu0_mode[2]),
    .q(lsu0_dp_mode_cdc)
  );
  assign lsu0_dp_mode_tmp = lsu0_dp_mode_cdc;
  wire [31:0] lsu0_ram_start_idx;

`ifndef SOCKET_S
  wire lsu1_dp_mode_cdc;
  REGISTER #(.N(1)) lsu1_dp_mode_cs (
    .clk(f_clk),
    .d(lsu1_mode[2]),
    .q(lsu1_dp_mode_cdc)
  );
  assign lsu1_dp_mode_tmp = lsu1_dp_mode_cdc;
  wire [31:0] lsu1_ram_start_idx;
`endif

  rg_cl_cdc_intf rg_cl_cdc_intf (
    .socket_reset(socket_reset_cdc),
    .lsu0_dp_mode(lsu0_dp_mode_cdc),
    .lsu0_ram_start_idx(lsu0_ram_start_idx),

    .lsu0_port0_addr(lsu0_port0_addr_cdc),
    .lsu0_port0_d(lsu0_port0_d_cdc),
    .lsu0_port0_q(lsu0_port0_q_cdc),
    .lsu0_port0_ce(lsu0_port0_ce_cdc),
    .lsu0_port0_we(lsu0_port0_we_cdc),

    .lsu0_port1_addr(lsu0_port1_addr_cdc),
    .lsu0_port1_d(lsu0_port1_d_cdc),
    .lsu0_port1_q(lsu0_port1_q_cdc),
    .lsu0_port1_ce(lsu0_port1_ce_cdc),
    .lsu0_port1_we(lsu0_port1_we_cdc),

    .lsu0_port2_addr(lsu0_port2_addr_cdc),
    .lsu0_port2_d(lsu0_port2_d_cdc),
    .lsu0_port2_q(lsu0_port2_q_cdc),
    .lsu0_port2_ce(lsu0_port2_ce_cdc),
    .lsu0_port2_we(lsu0_port2_we_cdc),

    .lsu0_port3_addr(lsu0_port3_addr_cdc),
    .lsu0_port3_d(lsu0_port3_d_cdc),
    .lsu0_port3_q(lsu0_port3_q_cdc),
    .lsu0_port3_ce(lsu0_port3_ce_cdc),
    .lsu0_port3_we(lsu0_port3_we_cdc),

    .lsu0_ram_en(lsu0_ram_en_cdc),

`ifndef SOCKET_S
    .lsu1_dp_mode(lsu1_dp_mode_cdc),
    .lsu1_ram_start_idx(lsu1_ram_start_idx),

    .lsu1_port0_addr(lsu1_port0_addr_cdc),
    .lsu1_port0_d(lsu1_port0_d_cdc),
    .lsu1_port0_q(lsu1_port0_q_cdc),
    .lsu1_port0_ce(lsu1_port0_ce_cdc),
    .lsu1_port0_we(lsu1_port0_we_cdc),

    .lsu1_port1_addr(lsu1_port1_addr_cdc),
    .lsu1_port1_d(lsu1_port1_d_cdc),
    .lsu1_port1_q(lsu1_port1_q_cdc),
    .lsu1_port1_ce(lsu1_port1_ce_cdc),
    .lsu1_port1_we(lsu1_port1_we_cdc),

    .lsu1_port2_addr(lsu1_port2_addr_cdc),
    .lsu1_port2_d(lsu1_port2_d_cdc),
    .lsu1_port2_q(lsu1_port2_q_cdc),
    .lsu1_port2_ce(lsu1_port2_ce_cdc),
    .lsu1_port2_we(lsu1_port2_we_cdc),

    .lsu1_port3_addr(lsu1_port3_addr_cdc),
    .lsu1_port3_d(lsu1_port3_d_cdc),
    .lsu1_port3_q(lsu1_port3_q_cdc),
    .lsu1_port3_ce(lsu1_port3_ce_cdc),
    .lsu1_port3_we(lsu1_port3_we_cdc),

    .lsu1_ram_en(lsu1_ram_en_cdc),
`endif
    .cl_done(cl_done_cdc),
    .cl_ctrl_addr(cl_ctrl_addr_cdc),
    .cl_ctrl_d(cl_ctrl_d_cdc),
    .cl_ctrl_q(cl_ctrl_q_cdc),
    .cl_ctrl_ce(cl_ctrl_ce_cdc),
    .cl_ctrl_we(cl_ctrl_we_cdc),

    // cdc
    .lsu0_port0_addr_cdc(lsu0_port0_addr_tmp),
    .lsu0_port0_d_cdc(lsu0_port0_d_tmp),
    .lsu0_port0_q_cdc(lsu0_port0_q_tmp),
    .lsu0_port0_ce_cdc(lsu0_port0_ce_tmp),
    .lsu0_port0_we_cdc(lsu0_port0_we_tmp),

    .lsu0_port1_addr_cdc(lsu0_port1_addr_tmp),
    .lsu0_port1_d_cdc(lsu0_port1_d_tmp),
    .lsu0_port1_q_cdc(lsu0_port1_q_tmp),
    .lsu0_port1_ce_cdc(lsu0_port1_ce_tmp),
    .lsu0_port1_we_cdc(lsu0_port1_we_tmp),

    .lsu0_port2_addr_cdc(lsu0_port2_addr_tmp),
    .lsu0_port2_d_cdc(lsu0_port2_d_tmp),
    .lsu0_port2_q_cdc(lsu0_port2_q_tmp),
    .lsu0_port2_ce_cdc(lsu0_port2_ce_tmp),
    .lsu0_port2_we_cdc(lsu0_port2_we_tmp),

    .lsu0_port3_addr_cdc(lsu0_port3_addr_tmp),
    .lsu0_port3_d_cdc(lsu0_port3_d_tmp),
    .lsu0_port3_q_cdc(lsu0_port3_q_tmp),
    .lsu0_port3_ce_cdc(lsu0_port3_ce_tmp),
    .lsu0_port3_we_cdc(lsu0_port3_we_tmp),

    .lsu0_ram_en_cdc(lsu0_ram_en_tmp),

`ifndef SOCKET_S
    .lsu1_port0_addr_cdc(lsu1_port0_addr_tmp),
    .lsu1_port0_d_cdc(lsu1_port0_d_tmp),
    .lsu1_port0_q_cdc(lsu1_port0_q_tmp),
    .lsu1_port0_ce_cdc(lsu1_port0_ce_tmp),
    .lsu1_port0_we_cdc(lsu1_port0_we_tmp),

    .lsu1_port1_addr_cdc(lsu1_port1_addr_tmp),
    .lsu1_port1_d_cdc(lsu1_port1_d_tmp),
    .lsu1_port1_q_cdc(lsu1_port1_q_tmp),
    .lsu1_port1_ce_cdc(lsu1_port1_ce_tmp),
    .lsu1_port1_we_cdc(lsu1_port1_we_tmp),

    .lsu1_port2_addr_cdc(lsu1_port2_addr_tmp),
    .lsu1_port2_d_cdc(lsu1_port2_d_tmp),
    .lsu1_port2_q_cdc(lsu1_port2_q_tmp),
    .lsu1_port2_ce_cdc(lsu1_port2_ce_tmp),
    .lsu1_port2_we_cdc(lsu1_port2_we_tmp),

    .lsu1_port3_addr_cdc(lsu1_port3_addr_tmp),
    .lsu1_port3_d_cdc(lsu1_port3_d_tmp),
    .lsu1_port3_q_cdc(lsu1_port3_q_tmp),
    .lsu1_port3_ce_cdc(lsu1_port3_ce_tmp),
    .lsu1_port3_we_cdc(lsu1_port3_we_tmp),

    .lsu1_ram_en_cdc(lsu1_ram_en_tmp),
`endif
    .cl_done_cdc(cl_done_tmp),
    .cl_ctrl_addr_cdc(cl_ctrl_addr_tmp),
    .cl_ctrl_d_cdc(cl_ctrl_d_tmp),
    .cl_ctrl_q_cdc(cl_ctrl_q_tmp),
    .cl_ctrl_ce_cdc(cl_ctrl_ce_tmp),
    .cl_ctrl_we_cdc(cl_ctrl_we_tmp),

    .socket_reset_cdc(socket_reset_tmp),

    .f_clk(f_clk),
    .clk(clk)
  );

  wire [3:0]              m0_k_arid;
  wire [AXI_AWIDTH-1:0]   m0_k_araddr;
  wire                    m0_k_arvalid;
  wire                    m0_k_arready;
  wire [7:0]              m0_k_arlen;
  wire [2:0]              m0_k_arsize;
  wire [1:0]              m0_k_arburst;

  wire [3:0]               m0_k_rid;
  wire [AXI_DWIDTH-1:0]    m0_k_rdata;
  wire                     m0_k_rvalid;
  wire                     m0_k_rready;
  wire                     m0_k_rlast;
  wire [1:0]               m0_k_rresp;

  wire [3:0]              m0_k_awid;
  wire [AXI_AWIDTH-1:0]   m0_k_awaddr;
  wire                    m0_k_awvalid;
  wire                    m0_k_awready;
  wire [7:0]              m0_k_awlen;
  wire [2:0]              m0_k_awsize;
  wire [1:0]              m0_k_awburst;

  wire [3:0]              m0_k_wid;
  wire [AXI_DWIDTH-1:0]   m0_k_wdata;
  wire                    m0_k_wvalid;
  wire                    m0_k_wready;
  wire                    m0_k_wlast;
  wire [AXI_DWIDTH/8-1:0] m0_k_wstrb;

  wire [3:0]               m0_k_bid;
  wire [1:0]               m0_k_bresp;
  wire                     m0_k_bvalid;
  wire                     m0_k_bready;

  wire [31:0] comm0_mode;

  wire [31:0] instrument_cnt0;
  wire [31:0] instrument_cnt1;

  wire [63:0] ext_mem_offset;
  wire dma0_write_idle;

  wire [31:0] lsu0_ram_block_factor;
  wire [31:0] lsu0_ram_cyclic_factor;
  wire [31:0] lsu0_ram_stride;
  wire [31:0] lsu0_ram_seg_stride;
  wire [31:0] lsu0_ram_addr_offset;

  wire [31:0] lsu0_m_offset_lo;
  wire [31:0] lsu0_m_offset_hi;
  wire [31:0] lsu0_seg_stride;
  wire [31:0] lsu0_seg_count;
  wire [31:0] lsu0_len;
  wire [31:0] lsu0_mode;

  wire  lsu0_start;
  wire  lsu0_done;

`ifndef SOCKET_S
  wire [31:0] comm1_mode;
  wire dma1_write_idle;

  wire [31:0] lsu1_ram_block_factor;
  wire [31:0] lsu1_ram_cyclic_factor;
  wire [31:0] lsu1_ram_stride;
  wire [31:0] lsu1_ram_seg_stride;
  wire [31:0] lsu1_ram_addr_offset;

  wire [31:0] lsu1_m_offset_lo;
  wire [31:0] lsu1_m_offset_hi;
  wire [31:0] lsu1_seg_stride;
  wire [31:0] lsu1_seg_count;
  wire [31:0] lsu1_len;
  wire [31:0] lsu1_mode;

  wire  lsu1_start;
  wire  lsu1_done;
`endif

  wire s0_axi_start;
  wire s0_axi_done;
  wire [AXI_DWIDTH-1:0] s0_axi_ss_in_data;
  wire                  s0_axi_ss_in_valid;
  wire                  s0_axi_ss_in_ready;
  wire [AXI_DWIDTH-1:0] s0_axi_ss_out_data;
  wire                  s0_axi_ss_out_valid;
  wire                  s0_axi_ss_out_ready;

  comm_block #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .DMEM_AWIDTH(DMEM_AWIDTH_LM),
    .DMEM_DWIDTH(DMEM_DWIDTH),
    .RAM_READ_LATENCY(`RAM_READ_LATENCY)
  ) comm_block (
    .lsu0_port0_addr(lsu0_port0_addr_cdc),
    .lsu0_port0_d(lsu0_port0_d_cdc),
    .lsu0_port0_q(lsu0_port0_q_cdc),
    .lsu0_port0_ce(lsu0_port0_ce_cdc),
    .lsu0_port0_we(lsu0_port0_we_cdc),

    .lsu0_port1_addr(lsu0_port1_addr_cdc),
    .lsu0_port1_d(lsu0_port1_d_cdc),
    .lsu0_port1_q(lsu0_port1_q_cdc),
    .lsu0_port1_ce(lsu0_port1_ce_cdc),
    .lsu0_port1_we(lsu0_port1_we_cdc),

    .lsu0_port2_addr(lsu0_port2_addr_cdc),
    .lsu0_port2_d(lsu0_port2_d_cdc),
    .lsu0_port2_q(lsu0_port2_q_cdc),
    .lsu0_port2_ce(lsu0_port2_ce_cdc),
    .lsu0_port2_we(lsu0_port2_we_cdc),

    .lsu0_port3_addr(lsu0_port3_addr_cdc),
    .lsu0_port3_d(lsu0_port3_d_cdc),
    .lsu0_port3_q(lsu0_port3_q_cdc),
    .lsu0_port3_ce(lsu0_port3_ce_cdc),
    .lsu0_port3_we(lsu0_port3_we_cdc),

    .lsu0_ram_en(lsu0_ram_en_cdc),

`ifndef SOCKET_S
    .lsu1_port0_addr(lsu1_port0_addr_cdc),
    .lsu1_port0_d(lsu1_port0_d_cdc),
    .lsu1_port0_q(lsu1_port0_q_cdc),
    .lsu1_port0_ce(lsu1_port0_ce_cdc),
    .lsu1_port0_we(lsu1_port0_we_cdc),

    .lsu1_port1_addr(lsu1_port1_addr_cdc),
    .lsu1_port1_d(lsu1_port1_d_cdc),
    .lsu1_port1_q(lsu1_port1_q_cdc),
    .lsu1_port1_ce(lsu1_port1_ce_cdc),
    .lsu1_port1_we(lsu1_port1_we_cdc),

    .lsu1_port2_addr(lsu1_port2_addr_cdc),
    .lsu1_port2_d(lsu1_port2_d_cdc),
    .lsu1_port2_q(lsu1_port2_q_cdc),
    .lsu1_port2_ce(lsu1_port2_ce_cdc),
    .lsu1_port2_we(lsu1_port2_we_cdc),

    .lsu1_port3_addr(lsu1_port3_addr_cdc),
    .lsu1_port3_d(lsu1_port3_d_cdc),
    .lsu1_port3_q(lsu1_port3_q_cdc),
    .lsu1_port3_ce(lsu1_port3_ce_cdc),
    .lsu1_port3_we(lsu1_port3_we_cdc),

    .lsu1_ram_en(lsu1_ram_en_cdc),
`endif

    .m0_arid(m0_k_arid),
    .m0_araddr(m0_k_araddr),
    .m0_arvalid(m0_k_arvalid),
    .m0_arready(m0_k_arready),
    .m0_arlen(m0_k_arlen),
    .m0_arsize(m0_k_arsize),
    .m0_arburst(m0_k_arburst),

    .m0_rid(m0_k_rid),
    .m0_rdata(m0_k_rdata),
    .m0_rvalid(m0_k_rvalid),
    .m0_rready(m0_k_rready),
    .m0_rlast(m0_k_rlast),
    .m0_rresp(m0_k_rresp),

    .m0_awid(m0_k_awid),
    .m0_awaddr(m0_k_awaddr),
    .m0_awvalid(m0_k_awvalid),
    .m0_awready(m0_k_awready),
    .m0_awlen(m0_k_awlen),
    .m0_awsize(m0_k_awsize),
    .m0_awburst(m0_k_awburst),

    .m0_wid(m0_k_wid),
    .m0_wdata(m0_k_wdata),
    .m0_wvalid(m0_k_wvalid),
    .m0_wready(m0_k_wready),
    .m0_wlast(m0_k_wlast),
    .m0_wstrb(m0_k_wstrb),

    .m0_bid(m0_k_bid),
    .m0_bresp(m0_k_bresp),
    .m0_bvalid(m0_k_bvalid),
    .m0_bready(m0_k_bready),

`ifndef SOCKET_S
    .m1_arid(m1_arid),
    .m1_araddr(m1_araddr),
    .m1_arvalid(m1_arvalid),
    .m1_arready(m1_arready),
    .m1_arlen(m1_arlen),
    .m1_arsize(m1_arsize),
    .m1_arburst(m1_arburst),

    .m1_rid(m1_rid),
    .m1_rdata(m1_rdata),
    .m1_rvalid(m1_rvalid),
    .m1_rready(m1_rready),
    .m1_rlast(m1_rlast),
    .m1_rresp(m1_rresp),

    .m1_awid(m1_awid),
    .m1_awaddr(m1_awaddr),
    .m1_awvalid(m1_awvalid),
    .m1_awready(m1_awready),
    .m1_awlen(m1_awlen),
    .m1_awsize(m1_awsize),
    .m1_awburst(m1_awburst),

    .m1_wid(m1_wid),
    .m1_wdata(m1_wdata),
    .m1_wvalid(m1_wvalid),
    .m1_wready(m1_wready),
    .m1_wlast(m1_wlast),
    .m1_wstrb(m1_wstrb),

    .m1_bid(m1_bid),
    .m1_bresp(m1_bresp),
    .m1_bvalid(m1_bvalid),
    .m1_bready(m1_bready),
`endif

    .ext_mem_offset(ext_mem_offset),
    .dma0_write_idle(dma0_write_idle),

    .s0_axi_start(s0_axi_start),
    .s0_axi_done(s0_axi_done),
    .s0_axi_ss_in_data(s0_axi_ss_in_data),
    .s0_axi_ss_in_valid(s0_axi_ss_in_valid),
    .s0_axi_ss_in_ready(s0_axi_ss_in_ready),
    .s0_axi_ss_out_data(s0_axi_ss_out_data),
    .s0_axi_ss_out_valid(s0_axi_ss_out_valid),
    .s0_axi_ss_out_ready(s0_axi_ss_out_ready),

    .lsu0_ram_start_idx(lsu0_ram_start_idx),
    .lsu0_ram_block_factor(lsu0_ram_block_factor),
    .lsu0_ram_cyclic_factor(lsu0_ram_cyclic_factor),
    .lsu0_ram_stride(lsu0_ram_stride),
    .lsu0_ram_seg_stride(lsu0_ram_seg_stride),
    .lsu0_ram_addr_offset(lsu0_ram_addr_offset),

    .lsu0_m_offset_lo(lsu0_m_offset_lo),
    .lsu0_m_offset_hi(lsu0_m_offset_hi),
    .lsu0_seg_stride(lsu0_seg_stride),
    .lsu0_seg_count(lsu0_seg_count),
    .lsu0_len(lsu0_len),
    .lsu0_mode(lsu0_mode),

    .lsu0_start(lsu0_start),
    .lsu0_done(lsu0_done),

`ifndef SOCKET_S
    .dma1_write_idle(dma1_write_idle),

    .lsu1_ram_start_idx(lsu1_ram_start_idx),
    .lsu1_ram_block_factor(lsu1_ram_block_factor),
    .lsu1_ram_cyclic_factor(lsu1_ram_cyclic_factor),
    .lsu1_ram_stride(lsu1_ram_stride),
    .lsu1_ram_seg_stride(lsu1_ram_seg_stride),
    .lsu1_ram_addr_offset(lsu1_ram_addr_offset),

    .lsu1_m_offset_lo(lsu1_m_offset_lo),
    .lsu1_m_offset_hi(lsu1_m_offset_hi),
    .lsu1_seg_stride(lsu1_seg_stride),
    .lsu1_seg_count(lsu1_seg_count),
    .lsu1_len(lsu1_len),
    .lsu1_mode(lsu1_mode),

    .lsu1_start(lsu1_start),
    .lsu1_done(lsu1_done),
`endif
    .clk(clk),
    .resetn(~socket_reset_cdc)
  );

  wire [3:0]              m0_ctrl_arid;
  wire [AXI_AWIDTH-1:0]   m0_ctrl_araddr;
  wire                    m0_ctrl_arvalid;
  wire                    m0_ctrl_arready;
  wire [7:0]              m0_ctrl_arlen;
  wire [2:0]              m0_ctrl_arsize;
  wire [1:0]              m0_ctrl_arburst;

  wire [3:0]               m0_ctrl_rid;
  wire [AXI_DWIDTH-1:0]    m0_ctrl_rdata;
  wire                     m0_ctrl_rvalid;
  wire                     m0_ctrl_rready;
  wire                     m0_ctrl_rlast;
  wire [1:0]               m0_ctrl_rresp;

  wire [3:0]              m0_ctrl_awid;
  wire [AXI_AWIDTH-1:0]   m0_ctrl_awaddr;
  wire                    m0_ctrl_awvalid;
  wire                    m0_ctrl_awready;
  wire [7:0]              m0_ctrl_awlen;
  wire [2:0]              m0_ctrl_awsize;
  wire [1:0]              m0_ctrl_awburst;

  wire [3:0]              m0_ctrl_wid;
  wire [AXI_DWIDTH-1:0]   m0_ctrl_wdata;
  wire                    m0_ctrl_wvalid;
  wire                    m0_ctrl_wready;
  wire                    m0_ctrl_wlast;
  wire [AXI_DWIDTH/8-1:0] m0_ctrl_wstrb;

  wire [3:0]               m0_ctrl_bid;
  wire [1:0]               m0_ctrl_bresp;
  wire                     m0_ctrl_bvalid;
  wire                     m0_ctrl_bready;
  wire ctrl_maxi_running;

  assign kernel_running  = ~ctrl_maxi_running;

  assign m0_arid         = (kernel_running) ? m0_k_arid : m0_ctrl_arid;
  assign m0_araddr       = (kernel_running) ? m0_k_araddr : m0_ctrl_araddr;
  assign m0_arvalid      = (kernel_running) ? m0_k_arvalid : m0_ctrl_arvalid;
  assign m0_k_arready    = m0_arready;
  assign m0_ctrl_arready = m0_arready;
  assign m0_arlen        = (kernel_running) ? m0_k_arlen : m0_ctrl_arlen;
  assign m0_arsize       = (kernel_running) ? m0_k_arsize : m0_ctrl_arsize;
  assign m0_arburst      = (kernel_running) ? m0_k_arburst : m0_ctrl_arburst;

  assign m0_k_rid       = m0_rid;
  assign m0_ctrl_rid    = m0_rid;
  assign m0_k_rdata     = m0_rdata;
  assign m0_ctrl_rdata  = m0_rdata;
  assign m0_k_rvalid    = m0_rvalid & kernel_running;
  assign m0_ctrl_rvalid = m0_rvalid;
  assign m0_rready      = (kernel_running) ? m0_k_rready : m0_ctrl_rready;
  assign m0_k_rlast     = m0_rlast;
  assign m0_ctrl_rlast  = m0_rlast;
  assign m0_k_rresp     = m0_rresp;
  assign m0_ctrl_rresp  = m0_rresp;

  assign m0_awid         = (kernel_running) ? m0_k_awid : m0_ctrl_awid;
  assign m0_awaddr       = (kernel_running) ? m0_k_awaddr : m0_ctrl_awaddr;
  assign m0_awvalid      = (kernel_running) ? m0_k_awvalid : m0_ctrl_awvalid;
  assign m0_k_awready    = m0_awready;
  assign m0_ctrl_awready = m0_awready;
  assign m0_awlen        = (kernel_running) ? m0_k_awlen : m0_ctrl_awlen;
  assign m0_awsize       = (kernel_running) ? m0_k_awsize : m0_ctrl_awsize;
  assign m0_awburst      = (kernel_running) ? m0_k_awburst : m0_ctrl_awburst;


  assign m0_wid         = (kernel_running) ? m0_k_wid : m0_ctrl_wid;
  assign m0_wdata       = (kernel_running) ? m0_k_wdata : m0_ctrl_wdata;
  assign m0_wvalid      = (kernel_running) ? m0_k_wvalid : m0_ctrl_wvalid;
  assign m0_k_wready    = m0_wready;
  assign m0_ctrl_wready = m0_wready;
  assign m0_wlast       = (kernel_running) ? m0_k_wlast : m0_ctrl_wlast;
  assign m0_wstrb       = (kernel_running) ? m0_k_wstrb : m0_ctrl_wstrb;

  assign m0_k_bid       = m0_bid;
  assign m0_ctrl_bid    = m0_bid;
  assign m0_k_bresp     = m0_bresp;
  assign m0_ctrl_bresp  = m0_bresp;
  assign m0_k_bvalid    = m0_bvalid;
  assign m0_ctrl_bvalid = m0_bvalid;
  assign m0_bready      = (kernel_running) ? m0_k_bready : m0_ctrl_bready;

  socket_template #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .AXI_MAX_BURST_LEN(AXI_MAX_BURST_LEN),
    .DMEM_AWIDTH(DMEM_AWIDTH),
    .DMEM_AWIDTH_LM(DMEM_AWIDTH_LM),
    .DMEM_DWIDTH(DMEM_DWIDTH),
    .DMEM_MIF_HEX(DMEM_MIF_HEX),
    .IMEM_MIF_HEX(IMEM_MIF_HEX),
    .SOCKET_BASE_ADDR(SOCKET_BASE_ADDR)
  ) socket_template (
    .clk(clk),
    .socket_reset(socket_reset_cdc),
    .socket_start(socket_start),

    .instrument_cnt0(instrument_cnt0),
    .instrument_cnt1(instrument_cnt1),

    // AXI Slave
    .s0_arid(s0_arid),
    .s0_araddr(s0_araddr),
    .s0_arvalid(s0_arvalid),
    .s0_arready(s0_arready),
    .s0_arlen(s0_arlen),
    .s0_arsize(s0_arsize),
    .s0_arburst(s0_arburst),
    .s0_rid(s0_rid),
    .s0_rdata(s0_rdata),
    .s0_rvalid(s0_rvalid),
    .s0_rready(s0_rready),
    .s0_rlast(s0_rlast),
    .s0_rresp(s0_rresp),
    .s0_awid(s0_awid),
    .s0_awaddr(s0_awaddr),
    .s0_awvalid(s0_awvalid),
    .s0_awready(s0_awready),
    .s0_awlen(s0_awlen),
    .s0_awsize(s0_awsize),
    .s0_awburst(s0_awburst),
    .s0_wid(s0_wid),
    .s0_wdata(s0_wdata),
    .s0_wvalid(s0_wvalid),
    .s0_wready(s0_wready),
    .s0_wlast(s0_wlast),
    .s0_wstrb(s0_wstrb),
    .s0_bid(s0_bid),
    .s0_bresp(s0_bresp),
    .s0_bvalid(s0_bvalid),
    .s0_bready(s0_bready),

    // AXI Master
    .m0_arid(m0_ctrl_arid),
    .m0_araddr(m0_ctrl_araddr),
    .m0_arvalid(m0_ctrl_arvalid),
    .m0_arready(m0_ctrl_arready),
    .m0_arlen(m0_ctrl_arlen),
    .m0_arsize(m0_ctrl_arsize),
    .m0_arburst(m0_ctrl_arburst),

    .m0_rid(m0_ctrl_rid),
    .m0_rdata(m0_ctrl_rdata),
    .m0_rvalid(m0_ctrl_rvalid),
    .m0_rready(m0_ctrl_rready),
    .m0_rlast(m0_ctrl_rlast),
    .m0_rresp(m0_ctrl_rresp),

    .m0_awid(m0_ctrl_awid),
    .m0_awaddr(m0_ctrl_awaddr),
    .m0_awvalid(m0_ctrl_awvalid),
    .m0_awready(m0_ctrl_awready),
    .m0_awlen(m0_ctrl_awlen),
    .m0_awsize(m0_ctrl_awsize),
    .m0_awburst(m0_ctrl_awburst),

    .m0_wid(m0_ctrl_wid),
    .m0_wdata(m0_ctrl_wdata),
    .m0_wvalid(m0_ctrl_wvalid),
    .m0_wready(m0_ctrl_wready),
    .m0_wlast(m0_ctrl_wlast),
    .m0_wstrb(m0_ctrl_wstrb),

    .m0_bid(m0_ctrl_bid),
    .m0_bresp(m0_ctrl_bresp),
    .m0_bvalid(m0_ctrl_bvalid),
    .m0_bready(m0_ctrl_bready),

    .dmem_addr_lm(dmem_addr_lm),
    .dmem_din_lm(dmem_din_lm),
    .dmem_dout_lm(dmem_dout_lm),
    .dmem_we_lm(dmem_we_lm),
    .dmem_en_lm(dmem_en_lm),

    .cl_done(cl_done_cdc),
    .cl_ctrl_addr(cl_ctrl_addr_cdc),
    .cl_ctrl_d(cl_ctrl_d_cdc),
    .cl_ctrl_q(cl_ctrl_q_cdc),
    .cl_ctrl_ce(cl_ctrl_ce_cdc),
    .cl_ctrl_we(cl_ctrl_we_cdc),

    .ctrl_maxi_running(ctrl_maxi_running),
    .ext_mem_offset(ext_mem_offset),
    .dma0_write_idle(dma0_write_idle),

    .s0_axi_start(s0_axi_start),
    .s0_axi_done(s0_axi_done),
    .s0_axi_ss_in_data(s0_axi_ss_in_data),
    .s0_axi_ss_in_valid(s0_axi_ss_in_valid),
    .s0_axi_ss_in_ready(s0_axi_ss_in_ready),
    .s0_axi_ss_out_data(s0_axi_ss_out_data),
    .s0_axi_ss_out_valid(s0_axi_ss_out_valid),
    .s0_axi_ss_out_ready(s0_axi_ss_out_ready),

    .lsu0_ram_start_idx(lsu0_ram_start_idx),
    .lsu0_ram_block_factor(lsu0_ram_block_factor),
    .lsu0_ram_cyclic_factor(lsu0_ram_cyclic_factor),
    .lsu0_ram_stride(lsu0_ram_stride),
    .lsu0_ram_seg_stride(lsu0_ram_seg_stride),
    .lsu0_ram_addr_offset(lsu0_ram_addr_offset),

    .lsu0_m_offset_lo(lsu0_m_offset_lo),
    .lsu0_m_offset_hi(lsu0_m_offset_hi),
    .lsu0_seg_stride(lsu0_seg_stride),
    .lsu0_seg_count(lsu0_seg_count),
    .lsu0_len(lsu0_len),
    .lsu0_mode(lsu0_mode),

    .lsu0_start(lsu0_start),
    .lsu0_done(lsu0_done),

`ifndef SOCKET_S
    .dma1_write_idle(dma1_write_idle),

    .lsu1_ram_start_idx(lsu1_ram_start_idx),
    .lsu1_ram_block_factor(lsu1_ram_block_factor),
    .lsu1_ram_cyclic_factor(lsu1_ram_cyclic_factor),
    .lsu1_ram_stride(lsu1_ram_stride),
    .lsu1_ram_seg_stride(lsu1_ram_seg_stride),
    .lsu1_ram_addr_offset(lsu1_ram_addr_offset),

    .lsu1_m_offset_lo(lsu1_m_offset_lo),
    .lsu1_m_offset_hi(lsu1_m_offset_hi),
    .lsu1_seg_stride(lsu1_seg_stride),
    .lsu1_seg_count(lsu1_seg_count),
    .lsu1_len(lsu1_len),
    .lsu1_mode(lsu1_mode),

    .lsu1_start(lsu1_start),
    .lsu1_done(lsu1_done),
    .comm1_mode(comm1_mode),

`endif

    .comm0_mode(comm0_mode)
  );

`ifdef DEBUG
  reg socket_start_pipe;
  always @(posedge f_clk) begin
    socket_start_pipe <= socket_start;

    if ((socket_start & ~socket_start_pipe) === 1'b1)
      $display("[%t] [%m] Socket started!", $time);

    if ((~socket_start & socket_start_pipe) === 1'b1)
      $display("[%t] [%m] Socket done!", $time);
  end

  wire m0_arfire = m0_arvalid & m0_arready;
  wire m0_rfire  = m0_rvalid  & m0_rready;
  wire m0_awfire = m0_awvalid & m0_awready;
  wire m0_wfire  = m0_wvalid  & m0_wready;

  always @(posedge clk) begin
     // m0_axi_adapter
    if (m0_arfire === 1'b1) begin
      $display("[At %t] [%m] [M_AXI READ REQ] m0_araddr=%h, m0_arlen=%h, m0_arsize=%h", $time, m0_araddr, m0_arlen, m0_arsize);
    end
    if (m0_rfire === 1'b1) begin
      $display("[At %t] [%m] [M_AXI READ DATA] m0_rdata=%h", $time, m0_rdata);
      if (m0_rlast === 1'b1) begin
        $display("[At %t] [%m] [M_AXI READ DATA LAST!]", $time);
      end
    end
    if (m0_awfire === 1'b1) begin
      $display("[At %t] [%m] [M_AXI WRITE REQ] m0_awaddr=%h, m0_awlen=%h, m0_awsize=%h", $time, m0_awaddr, m0_awlen, m0_awsize);
    end
    if (m0_wfire === 1'b1) begin
      $display("[At %t] [%m] [M_AXI WRITE DATA] m0_wdata=%h", $time, m0_wdata);
      if (m0_wlast === 1'b1) begin
        $display("[At %t] [%m] [M_AXI WRITE DATA LAST!]", $time);
      end
    end
  end

`ifndef SOCKET_S
  wire m1_arfire = m1_arvalid & m1_arready;
  wire m1_rfire  = m1_rvalid  & m1_rready;
  wire m1_awfire = m1_awvalid & m1_awready;
  wire m1_wfire  = m1_wvalid  & m1_wready;
  always @(posedge clk) begin
     // m1_axi_adapter
    if (m1_arfire === 1'b1) begin
      $display("[At %t] [%m] [M_AXI READ REQ] m1_araddr=%h, m1_arlen=%h, m1_arsize=%h", $time, m1_araddr, m1_arlen, m1_arsize);
    end
    if (m1_rfire === 1'b1) begin
      $display("[At %t] [%m] [M_AXI READ DATA] m1_rdata=%h", $time, m1_rdata);
      if (m1_rlast === 1'b1) begin
        $display("[At %t] [%m] [M_AXI READ DATA LAST!]", $time);
      end
    end
    if (m1_awfire === 1'b1) begin
      $display("[At %t] [%m] [M_AXI WRITE REQ] m1_awaddr=%h, m1_awlen=%h, m1_awsize=%h", $time, m1_awaddr, m1_awlen, m1_awsize);
    end
    if (m1_wfire === 1'b1) begin
      $display("[At %t] [%m] [M_AXI WRITE DATA] m1_wdata=%h", $time, m1_wdata);
      if (m1_wlast === 1'b1) begin
        $display("[At %t] [%m] [M_AXI WRITE DATA LAST!]", $time);
      end
    end
  end
`endif

//  wire s0_arfire = s0_arvalid & s0_arready;
//  wire s0_rfire  = s0_rvalid  & s0_rready;
//  wire s0_awfire = s0_awvalid & s0_awready;
//  wire s0_wfire  = s0_wvalid  & s0_wready;
//  always @(posedge clk) begin
//    // s0_axi_adapter
//    if (s0_arfire === 1'b1) begin
//      $display("[At %t] [%m] [S_AXI READ REQ] s0_araddr=%h, s0_arlen=%h, s0_arsize=%h", $time, s0_araddr, s0_arlen, s0_arsize);
//    end
//    if (s0_rfire === 1'b1) begin
//      $display("[At %t] [%m] [S_AXI READ DATA] s0_rdata=%h", $time, s0_rdata);
//      if (s0_rlast === 1'b1) begin
//        $display("[At %t] [%m] [S_AXI READ DATA LAST!]", $time);
//      end
//    end
//    if (s0_awfire === 1'b1) begin
//      $display("[At %t] [%m] [S_AXI WRITE REQ] s0_awaddr=%h, s0_awlen=%h, s0_awsize=%h", $time, s0_awaddr, s0_awlen, s0_awsize);
//    end
//    if (s0_wfire === 1'b1) begin
//      $display("[At %t] [%m] [S_AXI WRITE DATA] s0_wdata=%h, s0_wstrb=%h", $time, s0_wdata, s0_wstrb);
//      if (s0_wlast === 1'b1) begin
//        $display("[At %t] [%m] [S_AXI WRITE DATA LAST!]", $time);
//      end
//    end
//  end

`ifndef NO_AXIS
  wire m_axis_fire = m_axis_tvalid & m_axis_tready;
  wire s_axis_fire = s_axis_tvalid & s_axis_tready;

  always @(posedge f_clk) begin
    if (m_axis_fire === 1'b1) begin
      $display("[%t] [%m] M_AXIS data=%h, dest=%h", $time, m_axis_tdata, m_axis_tdest);
    end
    if (s_axis_fire === 1'b1) begin
      $display("[%t] [%m] S_AXIS data=%h, dest=%h", $time, s_axis_tdata, s_axis_tdest);
    end
  end

`endif
`endif
endmodule

