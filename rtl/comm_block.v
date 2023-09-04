`timescale 1ns/1ps
`include "axi_consts.vh"
`include "socket_config.vh"
module comm_block #(
  parameter AXI_AWIDTH       = 64,
  parameter AXI_DWIDTH       = 512,
  parameter DMEM_AWIDTH      = `DMEM_AWIDTH,
  parameter DMEM_AWIDTH_LM   = 13,
  parameter DMEM_DWIDTH      = 512,
  parameter RAM_READ_LATENCY = 6
) (
  input clk,
  input resetn, // active-low reset
  // AXI bus interface
  // Read address channel
  output [3:0]            m0_arid,
  output [AXI_AWIDTH-1:0] m0_araddr,
  output                  m0_arvalid,
  input                   m0_arready,
  output [7:0]            m0_arlen,
  output [2:0]            m0_arsize,
  output [1:0]            m0_arburst,
  // lock, cache, prot, qos, region, user (unused)
  // Read data channel
  input  [3:0]            m0_rid,
  input  [AXI_DWIDTH-1:0] m0_rdata,
  input                   m0_rvalid,
  output                  m0_rready,
  input                   m0_rlast,
  input  [1:0]            m0_rresp,
  // user (unused)
  // Write address channel
  output [3:0]            m0_awid,
  output [AXI_AWIDTH-1:0] m0_awaddr,
  output                  m0_awvalid,
  input                   m0_awready,
  output [7:0]            m0_awlen,
  output [2:0]            m0_awsize,
  output [1:0]            m0_awburst,
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
  input [3:0] m0_bid,
  input [1:0] m0_bresp,
  input       m0_bvalid,
  output      m0_bready,
  // user (unused)

`ifndef SOCKET_S
  // AXI bus interface
  // Read address channel
  output [3:0]            m1_arid,
  output [AXI_AWIDTH-1:0] m1_araddr,
  output                  m1_arvalid,
  input                   m1_arready,
  output [7:0]            m1_arlen,
  output [2:0]            m1_arsize,
  output [1:0]            m1_arburst,
  // lock, cache, prot, qos, region, user (unused)
  // Read data channel
  input  [3:0]            m1_rid,
  input  [AXI_DWIDTH-1:0] m1_rdata,
  input                   m1_rvalid,
  output                  m1_rready,
  input                   m1_rlast,
  input  [1:0]            m1_rresp,
  // user (unused)
  // Write address channel
  output [3:0]            m1_awid,
  output [AXI_AWIDTH-1:0] m1_awaddr,
  output                  m1_awvalid,
  input                   m1_awready,
  output [7:0]            m1_awlen,
  output [2:0]            m1_awsize,
  output [1:0]            m1_awburst,
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
  input [3:0] m1_bid,
  input [1:0] m1_bresp,
  input       m1_bvalid,
  output      m1_bready,
  // user (unused)
`endif

  input [63:0] ext_mem_offset,

  output dma0_write_idle,

  output s0_axi_start,
  //input  s0_axi_done,
  output  s0_axi_done,

  output [AXI_DWIDTH-1:0] s0_axi_ss_in_data,
  output                  s0_axi_ss_in_valid,
  input                   s0_axi_ss_in_ready,
  input  [AXI_DWIDTH-1:0] s0_axi_ss_out_data,
  input                   s0_axi_ss_out_valid,
  output                  s0_axi_ss_out_ready,

  input [31:0] lsu0_ram_start_idx,
  input [31:0] lsu0_ram_block_factor,
  input [31:0] lsu0_ram_cyclic_factor,
  input [31:0] lsu0_ram_stride,
  input [31:0] lsu0_ram_seg_stride,
  input [31:0] lsu0_ram_addr_offset,

  input [31:0] lsu0_m_offset_lo,
  input [31:0] lsu0_m_offset_hi,
  input [31:0] lsu0_seg_stride,
  input [31:0] lsu0_seg_count,
  input [31:0] lsu0_len,
  input [31:0] lsu0_mode,

  input  lsu0_start,
  output lsu0_done,

`ifndef SOCKET_S
  output dma1_write_idle,

  input [31:0] lsu1_ram_start_idx,
  input [31:0] lsu1_ram_block_factor,
  input [31:0] lsu1_ram_cyclic_factor,
  input [31:0] lsu1_ram_stride,
  input [31:0] lsu1_ram_seg_stride,
  input [31:0] lsu1_ram_addr_offset,

  input [31:0] lsu1_m_offset_lo,
  input [31:0] lsu1_m_offset_hi,
  input [31:0] lsu1_seg_stride,
  input [31:0] lsu1_seg_count,
  input [31:0] lsu1_len,
  input [31:0] lsu1_mode,

  input  lsu1_start,
  output lsu1_done,
`endif

  output [2*12-1:0] lsu0_port0_addr,
  output [2*64-1:0] lsu0_port0_d,
  input  [2*64-1:0] lsu0_port0_q,
  output [1:0]      lsu0_port0_ce,
  output            lsu0_port0_we,

  output [2*12-1:0] lsu0_port1_addr,
  output [2*64-1:0] lsu0_port1_d,
  input  [2*64-1:0] lsu0_port1_q,
  output [1:0]      lsu0_port1_ce,
  output            lsu0_port1_we,

  output [2*12-1:0] lsu0_port2_addr,
  output [2*64-1:0] lsu0_port2_d,
  input  [2*64-1:0] lsu0_port2_q,
  output [1:0]      lsu0_port2_ce,
  output            lsu0_port2_we,

  output [2*12-1:0] lsu0_port3_addr,
  output [2*64-1:0] lsu0_port3_d,
  input  [2*64-1:0] lsu0_port3_q,
  output [1:0]      lsu0_port3_ce,
  output            lsu0_port3_we,

`ifndef SOCKET_S
  output [2*12-1:0] lsu1_port0_addr,
  output [2*64-1:0] lsu1_port0_d,
  input  [2*64-1:0] lsu1_port0_q,
  output [1:0]      lsu1_port0_ce,
  output            lsu1_port0_we,

  output [2*12-1:0] lsu1_port1_addr,
  output [2*64-1:0] lsu1_port1_d,
  input  [2*64-1:0] lsu1_port1_q,
  output [1:0]      lsu1_port1_ce,
  output            lsu1_port1_we,

  output [2*12-1:0] lsu1_port2_addr,
  output [2*64-1:0] lsu1_port2_d,
  input  [2*64-1:0] lsu1_port2_q,
  output [1:0]      lsu1_port2_ce,
  output            lsu1_port2_we,

  output [2*12-1:0] lsu1_port3_addr,
  output [2*64-1:0] lsu1_port3_d,
  input  [2*64-1:0] lsu1_port3_q,
  output [1:0]      lsu1_port3_ce,
  output            lsu1_port3_we,

  output [4:0] lsu1_ram_en,
`endif
  output [4:0] lsu0_ram_en
);
  localparam KRN_DWIDTH = 256;

  wire lsu0_done_tmp;
  wire lsu1_done_tmp;

  wire [AXI_AWIDTH-1:0] m0_araddr_tmp;
  wire [AXI_AWIDTH-1:0] m0_awaddr_tmp;
  assign m0_araddr = m0_araddr_tmp + ext_mem_offset;
  assign m0_awaddr = m0_awaddr_tmp + ext_mem_offset;

`ifndef SOCKET_S
  wire [AXI_AWIDTH-1:0] m1_araddr_tmp;
  wire [AXI_AWIDTH-1:0] m1_awaddr_tmp;
  assign m1_araddr = m1_araddr_tmp + ext_mem_offset;
  assign m1_awaddr = m1_awaddr_tmp + ext_mem_offset;
`endif

  wire [AXI_DWIDTH-1:0] dma0_ss_in_data;
  wire                  dma0_ss_in_valid;
  wire                  dma0_ss_in_ready;
  wire [AXI_DWIDTH-1:0] dma0_ss_out_data;
  wire                  dma0_ss_out_valid;
  wire                  dma0_ss_out_ready;

  wire [AXI_DWIDTH-1:0] dma1_ss_in_data;
  wire                  dma1_ss_in_valid;
  wire                  dma1_ss_in_ready;
  wire [AXI_DWIDTH-1:0] dma1_ss_out_data;
  wire                  dma1_ss_out_valid;
  wire                  dma1_ss_out_ready;

  wire [31:0] len0, seg_stride0, seg_count0;
  wire [31:0] mode0;
  wire [31:0] m0_offset_lo0, m0_offset_hi0;
  wire [63:0] m0_offset0;
  wire        dma0_start, dma0_done;

  wire [31:0] len1, seg_stride1, seg_count1;
  wire [31:0] mode1;
  wire [31:0] m0_offset_lo1, m0_offset_hi1;
  wire [63:0] m0_offset1;
  wire        dma1_start, dma1_done;

  assign m0_offset_lo0 = lsu0_m_offset_lo;
  assign m0_offset_hi0 = lsu0_m_offset_hi;
  assign seg_stride0   = lsu0_seg_stride;
  assign seg_count0    = lsu0_seg_count;
  assign len0          = lsu0_len;
  assign mode0         = lsu0_mode;

  assign dma0_start = lsu0_start & (~mode0[4]);
  assign m0_offset0 = {m0_offset_hi0, m0_offset_lo0};

  m_axi_adapter_mm_ss #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .ID(0)
  ) dma_inst0 (
    .clk(clk),
    .resetn(resetn),

    .m_awvalid(m0_awvalid),
    .m_awready(m0_awready),
    .m_awaddr(m0_awaddr_tmp),
    .m_awid(m0_awid),
    .m_awlen(m0_awlen),
    .m_awsize(m0_awsize),
    .m_awburst(m0_awburst),

    .m_wvalid(m0_wvalid),
    .m_wready(m0_wready),
    .m_wdata(m0_wdata),
    .m_wstrb(m0_wstrb),
    .m_wlast(m0_wlast),
    .m_wid(m0_wid),

    .m_arvalid(m0_arvalid),
    .m_arready(m0_arready),
    .m_araddr(m0_araddr_tmp),
    .m_arid(m0_arid),
    .m_arlen(m0_arlen),
    .m_arsize(m0_arsize),
    .m_arburst(m0_arburst),

    .m_rvalid(m0_rvalid),
    .m_rready(m0_rready),
    .m_rdata(m0_rdata),
    .m_rresp(m0_rresp),
    .m_rlast(m0_rlast),
    .m_rid(m0_rid),

    .m_bvalid(m0_bvalid),
    .m_bready(m0_bready),
    .m_bresp(m0_bresp),
    .m_bid(m0_bid),

    .enq_data(dma0_ss_in_data),
    .enq_valid(dma0_ss_in_valid),
    .enq_ready(dma0_ss_in_ready),
    .deq_data(dma0_ss_out_data),
    .deq_valid(dma0_ss_out_valid),
    .deq_ready(dma0_ss_out_ready),

    .dma_write_idle(dma0_write_idle),
    .dma_start(dma0_start),

    .dma_done(dma0_done),
    .dma_len(len0),
    .dma_seg_stride(seg_stride0),
    .dma_seg_count(seg_count0),
    .dma_mode(mode0[1:0]),
    .dma_ext_addr(m0_offset0)
  );

`ifndef SOCKET_S
  assign m0_offset_lo1 = lsu1_m_offset_lo;
  assign m0_offset_hi1 = lsu1_m_offset_hi;
  assign seg_stride1   = lsu1_seg_stride;
  assign seg_count1    = lsu1_seg_count;
  assign len1          = lsu1_len;
  assign mode1         = lsu1_mode;

  assign dma1_start = lsu1_start & (~mode1[4]);
  assign m0_offset1 = {m0_offset_hi1, m0_offset_lo1};

  m_axi_adapter_mm_ss #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .ID(1)
  ) dma_inst1 (
    .clk(clk),
    .resetn(resetn),

    .m_awvalid(m1_awvalid),
    .m_awready(m1_awready),
    .m_awaddr(m1_awaddr_tmp),
    .m_awid(m1_awid),
    .m_awlen(m1_awlen),
    .m_awsize(m1_awsize),
    .m_awburst(m1_awburst),

    .m_wvalid(m1_wvalid),
    .m_wready(m1_wready),
    .m_wdata(m1_wdata),
    .m_wstrb(m1_wstrb),
    .m_wlast(m1_wlast),
    .m_wid(m1_wid),

    .m_arvalid(m1_arvalid),
    .m_arready(m1_arready),
    .m_araddr(m1_araddr_tmp),
    .m_arid(m1_arid),
    .m_arlen(m1_arlen),
    .m_arsize(m1_arsize),
    .m_arburst(m1_arburst),

    .m_rvalid(m1_rvalid),
    .m_rready(m1_rready),
    .m_rdata(m1_rdata),
    .m_rresp(m1_rresp),
    .m_rlast(m1_rlast),
    .m_rid(m1_rid),

    .m_bvalid(m1_bvalid),
    .m_bready(m1_bready),
    .m_bresp(m1_bresp),
    .m_bid(m1_bid),

    .enq_data(dma1_ss_in_data),
    .enq_valid(dma1_ss_in_valid),
    .enq_ready(dma1_ss_in_ready),
    .deq_data(dma1_ss_out_data),
    .deq_valid(dma1_ss_out_valid),
    .deq_ready(dma1_ss_out_ready),

    .dma_write_idle(dma1_write_idle),
    .dma_start(dma1_start),
    .dma_done(dma1_done),
    .dma_len(len1),
    .dma_seg_stride(seg_stride1),
    .dma_seg_count(seg_count1),
    .dma_mode(mode1[1:0]),
    .dma_ext_addr(m0_offset1)
  );
`endif

  wire [AXI_DWIDTH-1:0] lsu0_ss_in_data;
  wire                  lsu0_ss_in_valid;
  wire                  lsu0_ss_in_ready;
  wire [AXI_DWIDTH-1:0] lsu0_ss_out_data;
  wire                  lsu0_ss_out_valid;
  wire                  lsu0_ss_out_ready;

  wire [AXI_DWIDTH-1:0] lsu1_ss_in_data;
  wire                  lsu1_ss_in_valid;
  wire                  lsu1_ss_in_ready;
  wire [AXI_DWIDTH-1:0] lsu1_ss_out_data;
  wire                  lsu1_ss_out_valid;
  wire                  lsu1_ss_out_ready;

  wire [2*12-1:0] lsu0_port0_addr;
  wire [2*64-1:0] lsu0_port0_d;
  wire [2*64-1:0] lsu0_port0_q;
  wire [1:0]      lsu0_port0_ce;
  wire            lsu0_port0_we;

  wire [2*12-1:0] lsu0_port1_addr;
  wire [2*64-1:0] lsu0_port1_d;
  wire [2*64-1:0] lsu0_port1_q;
  wire [1:0]      lsu0_port1_ce;
  wire            lsu0_port1_we;

  wire [2*12-1:0] lsu0_port2_addr;
  wire [2*64-1:0] lsu0_port2_d;
  wire [2*64-1:0] lsu0_port2_q;
  wire [1:0]      lsu0_port2_ce;
  wire            lsu0_port2_we;

  wire [2*12-1:0] lsu0_port3_addr;
  wire [2*64-1:0] lsu0_port3_d;
  wire [2*64-1:0] lsu0_port3_q;
  wire [1:0]      lsu0_port3_ce;
  wire            lsu0_port3_we;

  wire [4:0] lsu0_ram_en;

  lsu_top #(
    .AWIDTH(12),
    .DWIDTH(64),
    .RAM_READ_LATENCY(RAM_READ_LATENCY),
    .ID(0)
  ) lsu0_inst (
    .port0_addr(lsu0_port0_addr),
    .port0_d(lsu0_port0_d),
    .port0_q(lsu0_port0_q),
    .port0_ce(lsu0_port0_ce),
    .port0_we(lsu0_port0_we),

    .port1_addr(lsu0_port1_addr),
    .port1_d(lsu0_port1_d),
    .port1_q(lsu0_port1_q),
    .port1_ce(lsu0_port1_ce),
    .port1_we(lsu0_port1_we),

    .port2_addr(lsu0_port2_addr),
    .port2_d(lsu0_port2_d),
    .port2_q(lsu0_port2_q),
    .port2_ce(lsu0_port2_ce),
    .port2_we(lsu0_port2_we),

    .port3_addr(lsu0_port3_addr),
    .port3_d(lsu0_port3_d),
    .port3_q(lsu0_port3_q),
    .port3_ce(lsu0_port3_ce),
    .port3_we(lsu0_port3_we),

    .ss_in_data(lsu0_ss_in_data),
    .ss_in_valid(lsu0_ss_in_valid),
    .ss_in_ready(lsu0_ss_in_ready),

    .ss_out_data(lsu0_ss_out_data),
    .ss_out_valid(lsu0_ss_out_valid),
    .ss_out_ready(lsu0_ss_out_ready),

    .ram_en(lsu0_ram_en),

    .ram_start_idx(lsu0_ram_start_idx),
    .ram_block_factor(lsu0_ram_block_factor),
    .ram_cyclic_factor(lsu0_ram_cyclic_factor),
    .ram_stride(lsu0_ram_stride),
    .ram_seg_stride(lsu0_ram_seg_stride),
    .ram_addr_offset(lsu0_ram_addr_offset),

    .seg_count(lsu0_seg_count),
    .len(lsu0_len * 8), // len is for dma (512b)
    .mode(lsu0_mode),

    .lsu_start(lsu0_start),
    .lsu_done(lsu0_done_tmp),

    .clk(clk),
    .rst(~resetn)
  );

`ifndef SOCKET_S
  wire [2*12-1:0] lsu1_port0_addr;
  wire [2*64-1:0] lsu1_port0_d;
  wire [2*64-1:0] lsu1_port0_q;
  wire [1:0]      lsu1_port0_ce;
  wire            lsu1_port0_we;

  wire [2*12-1:0] lsu1_port1_addr;
  wire [2*64-1:0] lsu1_port1_d;
  wire [2*64-1:0] lsu1_port1_q;
  wire [1:0]      lsu1_port1_ce;
  wire            lsu1_port1_we;

  wire [2*12-1:0] lsu1_port2_addr;
  wire [2*64-1:0] lsu1_port2_d;
  wire [2*64-1:0] lsu1_port2_q;
  wire [1:0]      lsu1_port2_ce;
  wire            lsu1_port2_we;

  wire [2*12-1:0] lsu1_port3_addr;
  wire [2*64-1:0] lsu1_port3_d;
  wire [2*64-1:0] lsu1_port3_q;
  wire [1:0]      lsu1_port3_ce;
  wire            lsu1_port3_we;

  wire [4:0] lsu1_ram_en;

  lsu_top #(
    .AWIDTH(12),
    .DWIDTH(64),
    .RAM_READ_LATENCY(RAM_READ_LATENCY),
    .ID(1)
  ) lsu1_inst (
    .port0_addr(lsu1_port0_addr),
    .port0_d(lsu1_port0_d),
    .port0_q(lsu1_port0_q),
    .port0_ce(lsu1_port0_ce),
    .port0_we(lsu1_port0_we),

    .port1_addr(lsu1_port1_addr),
    .port1_d(lsu1_port1_d),
    .port1_q(lsu1_port1_q),
    .port1_ce(lsu1_port1_ce),
    .port1_we(lsu1_port1_we),

    .port2_addr(lsu1_port2_addr),
    .port2_d(lsu1_port2_d),
    .port2_q(lsu1_port2_q),
    .port2_ce(lsu1_port2_ce),
    .port2_we(lsu1_port2_we),

    .port3_addr(lsu1_port3_addr),
    .port3_d(lsu1_port3_d),
    .port3_q(lsu1_port3_q),
    .port3_ce(lsu1_port3_ce),
    .port3_we(lsu1_port3_we),

    .ss_in_data(lsu1_ss_in_data),
    .ss_in_valid(lsu1_ss_in_valid),
    .ss_in_ready(lsu1_ss_in_ready),

    .ss_out_data(lsu1_ss_out_data),
    .ss_out_valid(lsu1_ss_out_valid),
    .ss_out_ready(lsu1_ss_out_ready),

    .ram_en(lsu1_ram_en),

    .ram_start_idx(lsu1_ram_start_idx),
    .ram_block_factor(lsu1_ram_block_factor),
    .ram_cyclic_factor(lsu1_ram_cyclic_factor),
    .ram_stride(lsu1_ram_stride),
    .ram_seg_stride(lsu1_ram_seg_stride),
    .ram_addr_offset(lsu1_ram_addr_offset),

    .seg_count(lsu1_seg_count),
    .len(lsu1_len * 8), // len is for dma (512b)
    .mode(lsu1_mode),

    .lsu_start(lsu1_start),
    .lsu_done(lsu1_done_tmp),

    .clk(clk),
    .rst(~resetn)
  );
`endif

  wire s0_axi_read_running;
  REGISTER_R_CE #(.N(1)) s0_axi_read_running_reg (
    .clk(clk),
    .rst(lsu0_done_tmp & s0_axi_read_running),
    .ce((mode0[1:0] == 1) & s0_axi_start),
    .d(1'b1),
    .q(s0_axi_read_running)
  );

  wire s0_axi_write_running;
  REGISTER_R_CE #(.N(1)) s0_axi_write_running_reg (
    .clk(clk),
    .rst(lsu0_done_tmp & s0_axi_write_running),
    .ce((mode0[1:0] == 2) & s0_axi_start),
    .d(1'b1),
    .q(s0_axi_write_running)
  );

  wire dma0_read_running;
  REGISTER_R_CE #(.N(1)) dma0_read_running_reg (
    .clk(clk),
    //.rst(dma0_done & dma0_read_running),
    .rst(lsu0_done_tmp & dma0_read_running),
    .ce((mode0[1:0] == 1) & dma0_start),
    .d(1'b1),
    .q(dma0_read_running)
  );

  // keep HIGH until write_idle (received bresp)
  wire dma0_done_tmp;
  REGISTER_R_CE #(.N(1)) dma0_done_tmp_reg (
    .clk(clk),
    .rst(dma0_write_idle & dma0_done_tmp),
    .ce(dma0_done),
    .d(1'b1),
    .q(dma0_done_tmp)
  );

  wire dma0_write_running;
  REGISTER_R_CE #(.N(1)) dma0_write_running_reg (
    .clk(clk),
    .rst(dma0_write_idle & dma0_done_tmp & dma0_write_running),
    .ce((mode0[1:0] == 2) & dma0_start),
    .d(1'b1),
    .q(dma0_write_running)
  );

`ifndef SOCKET_S
  wire dma1_read_running;
  REGISTER_R_CE #(.N(1)) dma1_read_running_reg (
    .clk(clk),
    //.rst(dma1_done & dma1_read_running),
    .rst(lsu1_done_tmp & dma1_read_running),
    .ce((mode1[1:0] == 1) & dma1_start),
    .d(1'b1),
    .q(dma1_read_running)
  );

  // keep HIGH until write_idle (received bresp)
  wire dma1_done_tmp;
  REGISTER_R_CE #(.N(1)) dma1_done_tmp_reg (
    .clk(clk),
    .rst(dma1_write_idle & dma1_done_tmp),
    .ce(dma1_done),
    .d(1'b1),
    .q(dma1_done_tmp)
  );

  wire dma1_write_running;
  REGISTER_R_CE #(.N(1)) dma1_write_running_reg (
    .clk(clk),
    .rst(dma1_write_idle & dma1_done_tmp & dma1_write_running),
    .ce((mode1[1:0] == 2) & dma1_start),
    .d(1'b1),
    .q(dma1_write_running)
  );
`endif

  assign lsu0_done = (dma0_read_running & lsu0_done_tmp) |
                     (dma0_write_running & dma0_done_tmp & dma0_write_idle) |
                     (s0_axi_read_running & lsu0_done_tmp) |
                     (s0_axi_write_running & lsu0_done_tmp);

`ifndef SOCKET_S
  assign lsu1_done = (dma1_read_running & lsu1_done_tmp) |
                     (dma1_write_running & dma1_done_tmp & dma1_write_idle);
`endif

  assign lsu0_ss_in_data     = dma0_read_running ? dma0_ss_out_data : s0_axi_ss_out_data;
  assign lsu0_ss_in_valid    = (dma0_read_running & dma0_ss_out_valid) |
                               (s0_axi_read_running & s0_axi_ss_out_valid);
  assign dma0_ss_out_ready   = lsu0_ss_in_ready;
  assign s0_axi_ss_out_ready = lsu0_ss_in_ready;

  assign dma0_ss_in_data   = lsu0_ss_out_data;
  assign dma0_ss_in_valid  = lsu0_ss_out_valid;
  assign lsu0_ss_out_ready = (dma0_ss_in_ready & dma0_write_running) |
                             (s0_axi_ss_in_ready & s0_axi_write_running);

`ifndef SOCKET_S
  assign lsu1_ss_in_data   = dma1_ss_out_data;
  assign lsu1_ss_in_valid  = dma1_ss_out_valid;
  assign dma1_ss_out_ready = lsu1_ss_in_ready;

  assign dma1_ss_in_data   = lsu1_ss_out_data;
  assign dma1_ss_in_valid  = lsu1_ss_out_valid;
  assign lsu1_ss_out_ready = dma1_ss_in_ready;
`endif

  assign s0_axi_start = lsu0_start & mode0[4];
  assign s0_axi_ss_in_data = lsu0_ss_out_data;
  assign s0_axi_ss_in_valid = lsu0_ss_out_valid;

  assign s0_axi_done = lsu0_done_tmp;

endmodule

