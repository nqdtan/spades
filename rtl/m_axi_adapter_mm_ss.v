`include "axi_consts.vh"

module m_axi_adapter_mm_ss #(
  parameter AXI_AWIDTH        = 64,
  parameter AXI_DWIDTH        = 512,
  parameter AXI_MAX_BURST_LEN = 64,
  parameter WORD_WIDTH        = 64,
  parameter ID = 0
) (
  input clk,
  input resetn, // active-low reset

  // AXI bus interface

  // Read address channel
  output [3:0]            m_arid,
  output [AXI_AWIDTH-1:0] m_araddr,
  output                  m_arvalid,
  input                   m_arready,
  output [7:0]            m_arlen,
  output [2:0]            m_arsize,
  output [1:0]            m_arburst,
  // lock, cache, prot, qos, region, user (unused)

  // Read data channel
  input  [3:0]            m_rid,
  input  [AXI_DWIDTH-1:0] m_rdata,
  input                   m_rvalid,
  output                  m_rready,
  input                   m_rlast,
  input  [1:0]            m_rresp,
  // user (unused)

  // Write address channel
  output [3:0]            m_awid,
  output [AXI_AWIDTH-1:0] m_awaddr,
  output                  m_awvalid,
  input                   m_awready,
  output [7:0]            m_awlen,
  output [2:0]            m_awsize,
  output [1:0]            m_awburst,
  // lock, cache, prot, qos, region, user (unused)

  // Write data channel
  output [3:0]              m_wid,
  output [AXI_DWIDTH-1:0]   m_wdata,
  output                    m_wvalid,
  input                     m_wready,
  output                    m_wlast,
  output [AXI_DWIDTH/8-1:0] m_wstrb,
  // user (unused)

  // Write response channel
  input [3:0] m_bid,
  input [1:0] m_bresp,
  input       m_bvalid,
  output      m_bready,
  // user (unused)

  input        dma_start,
  output       dma_done,
  input [1:0]  dma_mode,       // 1: read, 2: write
  input [63:0] dma_ext_addr,   // external address: byte-addressable
  input [31:0] dma_len,        // len of a single ext. mem segment transfer
  input [31:0] dma_stride,     // stride of int. mem
  input [31:0] dma_seg_stride, // stride between ext. mem segments
  input [31:0] dma_seg_count,  // number of ext. mem segments
  output dma_queue_wr_ready,
  output dma_write_idle,

  input [AXI_DWIDTH-1:0]  enq_data,
  input                   enq_valid,
  output                  enq_ready,

  output [AXI_DWIDTH-1:0] deq_data,
  output                  deq_valid,
  input                   deq_ready
);

  wire                   dma_arvalid;
  wire                   dma_arready;
  wire [AXI_AWIDTH-1:0]  dma_araddr;
  wire [31:0]            dma_arlen;
  wire [2:0]             dma_arsize;
  wire [1:0]             dma_arburst;
  wire  [AXI_DWIDTH-1:0] dma_rdata;
  wire                   dma_rvalid;
  wire                   dma_rready;

  wire                  dma_awvalid;
  wire                  dma_awready;
  wire [AXI_AWIDTH-1:0] dma_awaddr;
  wire [31:0]           dma_awlen;
  wire [2:0]            dma_awsize;
  wire [1:0]            dma_awburst;
  wire [AXI_DWIDTH-1:0] dma_wdata;
  wire                  dma_wvalid;
  wire                  dma_wready;

  dma_engine_mm_ss #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .WORD_WIDTH(WORD_WIDTH),
    .ID(ID)
  ) dma (
    .clk(clk),
    .resetn(resetn),

    .dma_arvalid(dma_arvalid),
    .dma_arready(dma_arready),
    .dma_araddr(dma_araddr),
    .dma_arlen(dma_arlen),
    .dma_arsize(dma_arsize),
    .dma_arburst(dma_arburst),
    .dma_rdata(dma_rdata),
    .dma_rvalid(dma_rvalid),
    .dma_rready(dma_rready),

    .dma_awvalid(dma_awvalid),
    .dma_awready(dma_awready),
    .dma_awaddr(dma_awaddr),
    .dma_awlen(dma_awlen),
    .dma_awsize(dma_awsize),
    .dma_awburst(dma_awburst),
    .dma_wdata(dma_wdata),
    .dma_wvalid(dma_wvalid),
    .dma_wready(dma_wready),

    .dma_start(dma_start),
    .dma_done(dma_done),
    .dma_mode(dma_mode),
    .dma_ext_addr(dma_ext_addr),
    .dma_len(dma_len),
    .dma_stride(dma_stride),
    .dma_seg_stride(dma_seg_stride),
    .dma_seg_count(dma_seg_count),
    .dma_queue_wr_ready(dma_queue_wr_ready),

    .enq_data(enq_data),
    .enq_valid(enq_valid),
    .enq_ready(enq_ready),

    .deq_data(deq_data),
    .deq_valid(deq_valid),
    .deq_ready(deq_ready)
  );

  m_axi_write #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .AXI_MAX_BURST_LEN(AXI_MAX_BURST_LEN),
    .ID(ID)
  ) write_unit (
    .clk(clk),
    .resetn(resetn),

     // write request address interface
    .m_awid(m_awid),
    .m_awaddr(m_awaddr),
    .m_awvalid(m_awvalid),
    .m_awready(m_awready),
    .m_awlen(m_awlen),
    .m_awsize(m_awsize),
    .m_awburst(m_awburst),

     // write request data interface
    .m_wid(m_wid),
    .m_wdata(m_wdata),
    .m_wvalid(m_wvalid),
    .m_wready(m_wready),
    .m_wlast(m_wlast),
    .m_wstrb(m_wstrb),

     // write response interface
    .m_bid(m_bid),
    .m_bresp(m_bresp),
    .m_bvalid(m_bvalid),
    .m_bready(m_bready),

    // dma write interface
    .core_write_request_valid(dma_awvalid),
    .core_write_request_ready(dma_awready),
    .core_write_addr(dma_awaddr),
    .core_write_len(dma_awlen),
    .core_write_size(dma_awsize),
    .core_write_burst(dma_awburst),
    .core_write_data(dma_wdata),
    .core_write_data_valid(dma_wvalid),
    .core_write_data_ready(dma_wready),
    .dma_write_idle(dma_write_idle)
  );

  m_axi_read #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .AXI_MAX_BURST_LEN(AXI_MAX_BURST_LEN),
    .ID(ID)
  ) read_unit (
    .clk(clk),
    .resetn(resetn),

     // read request address interface
    .m_arid(m_arid),
    .m_araddr(m_araddr),
    .m_arvalid(m_arvalid),
    .m_arready(m_arready),
    .m_arlen(m_arlen),
    .m_arsize(m_arsize),
    .m_arburst(m_arburst),

     // read response data interface
    .m_rid(m_rid),
    .m_rdata(m_rdata),
    .m_rvalid(m_rvalid),
    .m_rready(m_rready),
    .m_rlast(m_rlast),
    .m_rresp(m_rresp),

    // dma read interface
    .core_read_request_valid(dma_arvalid),
    .core_read_request_ready(dma_arready),
    .core_read_addr(dma_araddr),
    .core_read_len(dma_arlen),
    .core_read_size(dma_arsize),
    .core_read_burst(dma_arburst),
    .core_read_data(dma_rdata),
    .core_read_data_valid(dma_rvalid),
    .core_read_data_ready(dma_rready),
    .core_read_data_last()
  );

endmodule
