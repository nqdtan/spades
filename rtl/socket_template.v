
`timescale 1ns/1ps
`include "socket_config.vh"

module socket_template #(
  parameter AXI_AWIDTH = 64,
  parameter AXI_DWIDTH = 512,//64,
  parameter AXI_MAX_BURST_LEN = 256,
  parameter DMEM_AWIDTH = `DMEM_AWIDTH,
  parameter DMEM_AWIDTH_LM = 14,
  parameter DMEM_DWIDTH = 512,//64,
  parameter DMEM_MIF_HEX = "dmem_data.mif",
  parameter IMEM_MIF_HEX = "imem_data.mif",
  parameter SOCKET_BASE_ADDR = 64'h0000_0201_0000_0000
) (
  input clk,
  output socket_reset,
  output socket_start,
  input [31:0] instrument_cnt0,
  input [31:0] instrument_cnt1,

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

  input  [DMEM_AWIDTH_LM-1:0] dmem_addr_lm,
  input  [DMEM_DWIDTH-1:0]    dmem_din_lm,
  output [DMEM_DWIDTH-1:0]    dmem_dout_lm,
  input                       dmem_we_lm,
  input                       dmem_en_lm,

  output ctrl_maxi_running,
  output [63:0] ext_mem_offset,
  input dma0_write_idle,

  input  s0_axi_start,
  //output s0_axi_done,
  input s0_axi_done,

  input [AXI_DWIDTH-1:0]   s0_axi_ss_in_data,
  input                    s0_axi_ss_in_valid,
  output                   s0_axi_ss_in_ready,
  output  [AXI_DWIDTH-1:0] s0_axi_ss_out_data,
  output                   s0_axi_ss_out_valid,
  input                    s0_axi_ss_out_ready,

  input         cl_done,
  output [11:0] cl_ctrl_addr,
  output [31:0] cl_ctrl_d,
  input  [31:0] cl_ctrl_q,
  output        cl_ctrl_ce,
  output        cl_ctrl_we,

  // for LSU0
  output [31:0] lsu0_ram_start_idx,
  output [31:0] lsu0_ram_block_factor,
  output [31:0] lsu0_ram_cyclic_factor,
  output [31:0] lsu0_ram_stride,
  output [31:0] lsu0_ram_seg_stride,
  output [31:0] lsu0_ram_addr_offset,

  output [31:0] lsu0_m_offset_lo,
  output [31:0] lsu0_m_offset_hi,
  output [31:0] lsu0_seg_stride,
  output [31:0] lsu0_seg_count,
  output [31:0] lsu0_len,
  output [31:0] lsu0_mode,

  output  lsu0_start,
  input   lsu0_done,

`ifndef SOCKET_S
  input dma1_write_idle,

  // for LSU1
  output [31:0] lsu1_ram_start_idx,
  output [31:0] lsu1_ram_block_factor,
  output [31:0] lsu1_ram_cyclic_factor,
  output [31:0] lsu1_ram_stride,
  output [31:0] lsu1_ram_seg_stride,
  output [31:0] lsu1_ram_addr_offset,

  output [31:0] lsu1_m_offset_lo,
  output [31:0] lsu1_m_offset_hi,
  output [31:0] lsu1_seg_stride,
  output [31:0] lsu1_seg_count,
  output [31:0] lsu1_len,
  output [31:0] lsu1_mode,

  output  lsu1_start,
  input   lsu1_done,
  output [31:0] comm1_mode,
`endif

  output [31:0] comm0_mode
);

  localparam NUM_SYNCS = 16;

  // for LSU1
  wire [31:0] lsu1_ram_start_idx;
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

  wire lsu1_start;
  wire lsu1_done;
  wire [31:0] comm1_mode;

  wire ctrl_maxi_rstart, ctrl_maxi_rdone;
  wire ctrl_maxi_wstart, ctrl_maxi_wdone;
  wire [31:0] ctrl_maxi_rdata, ctrl_maxi_wdata;
  wire [63:0] ctrl_maxi_socket_offset;

  ctrl_maxi #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH)
  ) ctrl_maxi (
    .m0_arid(m0_arid),
    .m0_araddr(m0_araddr),
    .m0_arvalid(m0_arvalid),
    .m0_arready(m0_arready),
    .m0_arlen(m0_arlen),
    .m0_arsize(m0_arsize),
    .m0_arburst(m0_arburst),

    .m0_rid(m0_rid),
    .m0_rdata(m0_rdata),
    .m0_rvalid(m0_rvalid),
    .m0_rready(m0_rready),
    .m0_rlast(m0_rlast),
    .m0_rresp(m0_rresp),

    .m0_awid(m0_awid),
    .m0_awaddr(m0_awaddr),
    .m0_awvalid(m0_awvalid),
    .m0_awready(m0_awready),
    .m0_awlen(m0_awlen),
    .m0_awsize(m0_awsize),
    .m0_awburst(m0_awburst),

    .m0_wid(m0_wid),
    .m0_wdata(m0_wdata),
    .m0_wvalid(m0_wvalid),
    .m0_wready(m0_wready),
    .m0_wlast(m0_wlast),
    .m0_wstrb(m0_wstrb),

    .m0_bid(m0_bid),
    .m0_bresp(m0_bresp),
    .m0_bvalid(m0_bvalid),
    .m0_bready(m0_bready),

    .ctrl_maxi_rstart(ctrl_maxi_rstart),
    .ctrl_maxi_wstart(ctrl_maxi_wstart),
    .ctrl_maxi_rdone(ctrl_maxi_rdone),
    .ctrl_maxi_wdone(ctrl_maxi_wdone),
    .ctrl_maxi_rdata(ctrl_maxi_rdata),
    .ctrl_maxi_wdata(ctrl_maxi_wdata),
    .ctrl_maxi_socket_offset(ctrl_maxi_socket_offset),
    .ctrl_maxi_running(ctrl_maxi_running),

    .clk(clk),
    .resetn(~socket_reset)
  );

  wire socket_done;

  wire [31:0] squeue_out_data;
  wire squeue_out_valid, squeue_out_ready;

  wire [31:0] socket_imem_addr;
  wire [31:0] socket_imem_wdata;
  wire        socket_imem_we;

  wire [NUM_SYNCS-1:0] sync_en;
  wire [31:0] perf_cnt_next, perf_cnt_value;
  wire perf_cnt_ce, perf_cnt_rst;
  REGISTER_R_CE #(.N(32), .INIT(0)) perf_cnt_reg (
    .clk(clk),
    .rst(perf_cnt_rst),
    .ce(perf_cnt_ce),
    .d(perf_cnt_next),
    .q(perf_cnt_value)
  );
  assign perf_cnt_next = perf_cnt_value + 1;
  assign perf_cnt_ce   = socket_start;
  assign perf_cnt_rst  = socket_reset;

  wire [31:0] socket_inbox;

  wire [DMEM_AWIDTH-1:0] dmem_addr_s;
  wire [DMEM_DWIDTH-1:0] dmem_din_s, dmem_dout_s;
  wire dmem_we_s, dmem_en_s;

  s_axi_adapter #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .DMEM_AWIDTH(DMEM_AWIDTH),
    .DMEM_DWIDTH(DMEM_DWIDTH),
    .NUM_SYNCS(NUM_SYNCS),
    .SOCKET_BASE_ADDR(SOCKET_BASE_ADDR)
  ) s0_axi_adapter (
    .clk(clk),
    .socket_reset(socket_reset),

    .instrument_cnt0(instrument_cnt0),
    .instrument_cnt1(instrument_cnt1),

    .ss_start(s0_axi_start),
    .ss_done(s0_axi_done),
    .ss_in_data(s0_axi_ss_in_data),
    .ss_in_valid(s0_axi_ss_in_valid),
    .ss_in_ready(s0_axi_ss_in_ready),
    .ss_out_data(s0_axi_ss_out_data),
    .ss_out_valid(s0_axi_ss_out_valid),
    .ss_out_ready(s0_axi_ss_out_ready),

    .s_arid(s0_arid),
    .s_araddr(s0_araddr),
    .s_arvalid(s0_arvalid),
    .s_arready(s0_arready),
    .s_arlen(s0_arlen),
    .s_arsize(s0_arsize),
    .s_arburst(s0_arburst),

    .s_rid(s0_rid),
    .s_rdata(s0_rdata),
    .s_rvalid(s0_rvalid),
    .s_rready(s0_rready),
    .s_rlast(s0_rlast),
    .s_rresp(s0_rresp),

    .s_awid(s0_awid),
    .s_awaddr(s0_awaddr),
    .s_awvalid(s0_awvalid),
    .s_awready(s0_awready),
    .s_awlen(s0_awlen),
    .s_awsize(s0_awsize),
    .s_awburst(s0_awburst),

    .s_wid(s0_wid),
    .s_wdata(s0_wdata),
    .s_wvalid(s0_wvalid),
    .s_wready(s0_wready),
    .s_wlast(s0_wlast),
    .s_wstrb(s0_wstrb),

    .s_bid(s0_bid),
    .s_bresp(s0_bresp),
    .s_bvalid(s0_bvalid),
    .s_bready(s0_bready),

    .dmem_addr(dmem_addr_s),
    .dmem_din(dmem_din_s),
    .dmem_dout(dmem_dout_s),
    .dmem_we(dmem_we_s),
    .dmem_en(dmem_en_s),

    .sync_en(sync_en),

    .squeue_out_data(squeue_out_data),
    .squeue_out_valid(squeue_out_valid),
    .squeue_out_ready(squeue_out_ready),

    .perf_cnt_value(perf_cnt_value),

    .socket_imem_addr(socket_imem_addr),
    .socket_imem_wdata(socket_imem_wdata),
    .socket_imem_we(socket_imem_we),

    .socket_inbox(socket_inbox),

    .ext_mem_offset(ext_mem_offset),
    .socket_start(socket_start),
    .socket_done(socket_done)
  );

  controller #(
    .AXI_AWIDTH(32),
    .AXI_DWIDTH(32),
    .DMEM_AWIDTH(DMEM_AWIDTH),
    .DMEM_DWIDTH(DMEM_DWIDTH),
    .NUM_SYNCS(NUM_SYNCS),
    .IMEM_MIF_HEX(IMEM_MIF_HEX)
  ) controller (
    .clk(clk),
    .resetn(~socket_reset),

    .sync_en(sync_en),

    .squeue_out_data(squeue_out_data),
    .squeue_out_valid(squeue_out_valid),
    .squeue_out_ready(squeue_out_ready),

    .cl_done(cl_done),
    .cl_ctrl_addr(cl_ctrl_addr),
    .cl_ctrl_d(cl_ctrl_d),
    .cl_ctrl_q(cl_ctrl_q),
    .cl_ctrl_ce(cl_ctrl_ce),
    .cl_ctrl_we(cl_ctrl_we),

    .ctrl_maxi_rstart(ctrl_maxi_rstart),
    .ctrl_maxi_wstart(ctrl_maxi_wstart),
    .ctrl_maxi_rdone(ctrl_maxi_rdone),
    .ctrl_maxi_wdone(ctrl_maxi_wdone),
    .ctrl_maxi_rdata(ctrl_maxi_rdata),
    .ctrl_maxi_wdata(ctrl_maxi_wdata),
    .ctrl_maxi_socket_offset(ctrl_maxi_socket_offset),

    .dma0_write_idle(dma0_write_idle),
    .dma1_write_idle(dma1_write_idle),

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

    .comm0_mode(comm0_mode),
    .comm1_mode(comm1_mode),

    .socket_imem_addr(socket_imem_addr),
    .socket_imem_wdata(socket_imem_wdata),
    .socket_imem_we(socket_imem_we),

    .socket_inbox(socket_inbox),

    .socket_start(socket_start),
    .socket_done(socket_done)
  );

endmodule

