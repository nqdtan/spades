`include "axi_consts.vh"

// Used for system_sim_socket.tcl
module m_axi_adapter #(
  parameter AXI_AWIDTH = 64,
  parameter AXI_DWIDTH = 64,
  parameter AXI_MAX_BURST_LEN = 256
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

  // Core (client) interface
  // Read request address and Read response data
  input                   core_read_request_valid,
  output                  core_read_request_ready,
  input  [AXI_AWIDTH-1:0] core_read_addr,
  input  [31:0]           core_read_len,
  input  [2:0]            core_read_size,
  input  [1:0]            core_read_burst,
  output [AXI_DWIDTH-1:0] core_read_data,
  output                  core_read_data_valid,
  input                   core_read_data_ready,
  output                  core_read_data_last,

  // Write request address and Write request data
  // (no write response -- assuming write always succeeds)
  input                   core_write_request_valid,
  output                  core_write_request_ready,
  input  [AXI_AWIDTH-1:0] core_write_addr,
  input  [31:0]           core_write_len,
  input  [2:0]            core_write_size,
  input  [1:0]            core_write_burst,
  input  [AXI_DWIDTH-1:0] core_write_data,
  input                   core_write_data_valid,
  output                  core_write_data_ready,
  output                  core_write_resp_ok
);
  m_axi_write0 #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .AXI_MAX_BURST_LEN(AXI_MAX_BURST_LEN)
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

    // core (client) write interface
    .core_write_request_valid(core_write_request_valid),
    .core_write_request_ready(core_write_request_ready),
    .core_write_addr(core_write_addr),
    .core_write_len(core_write_len),
    .core_write_size(core_write_size),
    .core_write_burst(core_write_burst),
    .core_write_data(core_write_data),
    .core_write_data_valid(core_write_data_valid),
    .core_write_data_ready(core_write_data_ready),
    .core_write_resp_ok(core_write_resp_ok)
  );

  m_axi_read0 #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .AXI_MAX_BURST_LEN(AXI_MAX_BURST_LEN),
    .ID(2)
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

    // core (client) read interface
    .core_read_request_valid(core_read_request_valid),
    .core_read_request_ready(core_read_request_ready),
    .core_read_addr(core_read_addr),
    .core_read_len(core_read_len),
    .core_read_size(core_read_size),
    .core_read_burst(core_read_burst),
    .core_read_data(core_read_data),
    .core_read_data_valid(core_read_data_valid),
    .core_read_data_ready(core_read_data_ready),
    .core_read_data_last(core_read_data_last)
  );

endmodule
