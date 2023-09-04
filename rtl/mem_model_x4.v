`include "axi_consts.vh"
`include "socket_config.vh"

module mem_model_x4 #(
  parameter AXI_AWIDTH  = 64,
  parameter AXI_DWIDTH  = 64,
  parameter DMEM_AWIDTH = 20, // 1 MB
  parameter DMEM_DWIDTH = 64
) (
  input clk,
  input resetn, // active-low reset

  // AXI bus interface

  // Read address channel
  input [3:0]              s0_arid,
  input [AXI_AWIDTH-1:0]   s0_araddr,
  input                    s0_arvalid,
  output                   s0_arready,
  input [7:0]              s0_arlen,
  input [2:0]              s0_arsize,
  input [1:0]              s0_arburst,
  // lock, cache, prot, qos, region, user (unused)

  // Read data channel
  output  [3:0]            s0_rid,
  output  [AXI_DWIDTH-1:0] s0_rdata,
  output                   s0_rvalid,
  input                    s0_rready,
  output                   s0_rlast,
  output  [1:0]            s0_rresp,
  // user (unused)

  // Write address channel
  input [3:0]            s0_awid,
  input [AXI_AWIDTH-1:0] s0_awaddr,
  input                  s0_awvalid,
  output                 s0_awready,
  input [7:0]            s0_awlen,
  input [2:0]            s0_awsize,
  input [1:0]            s0_awburst,
  // lock, cache, prot, qos, region, user (unused)

  // Write data channel
  input [3:0]              s0_wid,
  input [AXI_DWIDTH-1:0]   s0_wdata,
  input                    s0_wvalid,
  output                   s0_wready,
  input                    s0_wlast,
  input [AXI_DWIDTH/8-1:0] s0_wstrb,
  // user (unused)

  // Write response channel
  output [3:0] s0_bid,
  output [1:0] s0_bresp,
  output       s0_bvalid,
  input        s0_bready,
  // user (unused)

  // Read address channel
  input [3:0]              s1_arid,
  input [AXI_AWIDTH-1:0]   s1_araddr,
  input                    s1_arvalid,
  output                   s1_arready,
  input [7:0]              s1_arlen,
  input [2:0]              s1_arsize,
  input [1:0]              s1_arburst,
  // lock, cache, prot, qos, region, user (unused)

  // Read data channel
  output  [3:0]            s1_rid,
  output  [AXI_DWIDTH-1:0] s1_rdata,
  output                   s1_rvalid,
  input                    s1_rready,
  output                   s1_rlast,
  output  [1:0]            s1_rresp,
  // user (unused)

  // Write address channel
  input [3:0]            s1_awid,
  input [AXI_AWIDTH-1:0] s1_awaddr,
  input                  s1_awvalid,
  output                 s1_awready,
  input [7:0]            s1_awlen,
  input [2:0]            s1_awsize,
  input [1:0]            s1_awburst,
  // lock, cache, prot, qos, region, user (unused)

  // Write data channel
  input [3:0]              s1_wid,
  input [AXI_DWIDTH-1:0]   s1_wdata,
  input                    s1_wvalid,
  output                   s1_wready,
  input                    s1_wlast,
  input [AXI_DWIDTH/8-1:0] s1_wstrb,
  // user (unused)

  // Write response channel
  output [3:0] s1_bid,
  output [1:0] s1_bresp,
  output       s1_bvalid,
  input        s1_bready,
  // user (unused)

  // Read address channel
  input [3:0]              s2_arid,
  input [AXI_AWIDTH-1:0]   s2_araddr,
  input                    s2_arvalid,
  output                   s2_arready,
  input [7:0]              s2_arlen,
  input [2:0]              s2_arsize,
  input [1:0]              s2_arburst,
  // lock, cache, prot, qos, region, user (unused)

  // Read data channel
  output  [3:0]            s2_rid,
  output  [AXI_DWIDTH-1:0] s2_rdata,
  output                   s2_rvalid,
  input                    s2_rready,
  output                   s2_rlast,
  output  [1:0]            s2_rresp,
  // user (unused)

  // Write address channel
  input [3:0]            s2_awid,
  input [AXI_AWIDTH-1:0] s2_awaddr,
  input                  s2_awvalid,
  output                 s2_awready,
  input [7:0]            s2_awlen,
  input [2:0]            s2_awsize,
  input [1:0]            s2_awburst,
  // lock, cache, prot, qos, region, user (unused)

  // Write data channel
  input [3:0]              s2_wid,
  input [AXI_DWIDTH-1:0]   s2_wdata,
  input                    s2_wvalid,
  output                   s2_wready,
  input                    s2_wlast,
  input [AXI_DWIDTH/8-1:0] s2_wstrb,
  // user (unused)

  // Write response channel
  output [3:0] s2_bid,
  output [1:0] s2_bresp,
  output       s2_bvalid,
  input        s2_bready,
  // user (unused)

  // Read address channel
  input [3:0]              s3_arid,
  input [AXI_AWIDTH-1:0]   s3_araddr,
  input                    s3_arvalid,
  output                   s3_arready,
  input [7:0]              s3_arlen,
  input [2:0]              s3_arsize,
  input [1:0]              s3_arburst,
  // lock, cache, prot, qos, region, user (unused)

  // Read data channel
  output  [3:0]            s3_rid,
  output  [AXI_DWIDTH-1:0] s3_rdata,
  output                   s3_rvalid,
  input                    s3_rready,
  output                   s3_rlast,
  output  [1:0]            s3_rresp,
  // user (unused)

  // Write address channel
  input [3:0]            s3_awid,
  input [AXI_AWIDTH-1:0] s3_awaddr,
  input                  s3_awvalid,
  output                 s3_awready,
  input [7:0]            s3_awlen,
  input [2:0]            s3_awsize,
  input [1:0]            s3_awburst,
  // lock, cache, prot, qos, region, user (unused)

  // Write data channel
  input [3:0]              s3_wid,
  input [AXI_DWIDTH-1:0]   s3_wdata,
  input                    s3_wvalid,
  output                   s3_wready,
  input                    s3_wlast,
  input [AXI_DWIDTH/8-1:0] s3_wstrb,
  // user (unused)

  // Write response channel
  output [3:0] s3_bid,
  output [1:0] s3_bresp,
  output       s3_bvalid,
  input        s3_bready
  // user (unused)
);

  localparam BYTE_SIZE      = AXI_DWIDTH / 8;
  localparam LOG2_BYTE_SIZE = $clog2(BYTE_SIZE);
  localparam FIFO_LOGDEPTH = 3;

  wire [DMEM_AWIDTH-1:0] dmem0_addr0;
  wire  [DMEM_DWIDTH-1:0] dmem0_dout0;
  wire [DMEM_DWIDTH-1:0] dmem0_din0;
  wire dmem0_en0;
  wire dmem0_we0;

  wire [DMEM_AWIDTH-1:0] dmem0_addr1;
  wire  [DMEM_DWIDTH-1:0] dmem0_dout1;
  wire [DMEM_DWIDTH-1:0] dmem0_din1;
  wire dmem0_en1;
  wire dmem0_we1;

  wire [DMEM_AWIDTH-1:0] dmem1_addr0;
  wire  [DMEM_DWIDTH-1:0] dmem1_dout0;
  wire [DMEM_DWIDTH-1:0] dmem1_din0;
  wire dmem1_en0;
  wire dmem1_we0;

  wire [DMEM_AWIDTH-1:0] dmem1_addr1;
  wire  [DMEM_DWIDTH-1:0] dmem1_dout1;
  wire [DMEM_DWIDTH-1:0] dmem1_din1;
  wire dmem1_en1;
  wire dmem1_we1;

  wire [DMEM_AWIDTH-1:0] dmem2_addr0;
  wire  [DMEM_DWIDTH-1:0] dmem2_dout0;
  wire [DMEM_DWIDTH-1:0] dmem2_din0;
  wire dmem2_en0;
  wire dmem2_we0;

  wire [DMEM_AWIDTH-1:0] dmem2_addr1;
  wire  [DMEM_DWIDTH-1:0] dmem2_dout1;
  wire [DMEM_DWIDTH-1:0] dmem2_din1;
  wire dmem2_en1;
  wire dmem2_we1;

  wire [DMEM_AWIDTH-1:0] dmem3_addr0;
  wire  [DMEM_DWIDTH-1:0] dmem3_dout0;
  wire [DMEM_DWIDTH-1:0] dmem3_din0;
  wire dmem3_en0;
  wire dmem3_we0;

  wire [DMEM_AWIDTH-1:0] dmem3_addr1;
  wire  [DMEM_DWIDTH-1:0] dmem3_dout1;
  wire [DMEM_DWIDTH-1:0] dmem3_din1;
  wire dmem3_en1;
  wire dmem3_we1;

  SYNC_RAM_8P #(
    .AWIDTH(DMEM_AWIDTH),
    .DWIDTH(DMEM_DWIDTH)
  ) buffer (
    .clk(clk),

    // for read
    .addr0(dmem0_addr0),
    .d0(dmem0_din0),
    .q0(dmem0_dout0),
    .we0(dmem0_we0),
    .en0(dmem0_en0),

    // for write
    .addr1(dmem0_addr1),
    .d1(dmem0_din1),
    .q1(dmem0_dout1),
    .we1(dmem0_we1),
    .en1(dmem0_en1),

    // for read
    .addr2(dmem1_addr0),
    .d2(dmem1_din0),
    .q2(dmem1_dout0),
    .we2(dmem1_we0),
    .en2(dmem1_en0),

    // for write
    .addr3(dmem1_addr1),
    .d3(dmem1_din1),
    .q3(dmem1_dout1),
    .we3(dmem1_we1),
    .en3(dmem1_en1),

    // for read
    .addr4(dmem2_addr0),
    .d4(dmem2_din0),
    .q4(dmem2_dout0),
    .we4(dmem2_we0),
    .en4(dmem2_en0),

    // for write
    .addr5(dmem2_addr1),
    .d5(dmem2_din1),
    .q5(dmem2_dout1),
    .we5(dmem2_we1),
    .en5(dmem2_en1),

    // for read
    .addr6(dmem3_addr0),
    .d6(dmem3_din0),
    .q6(dmem3_dout0),
    .we6(dmem3_we0),
    .en6(dmem3_en0),

    // for write
    .addr7(dmem3_addr1),
    .d7(dmem3_din1),
    .q7(dmem3_dout1),
    .we7(dmem3_we1),
    .en7(dmem3_en1)
  );

  mem_model0 #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .DMEM_AWIDTH(DMEM_AWIDTH),
    .DMEM_DWIDTH(DMEM_DWIDTH)
  ) mem_model_dmem0 (
    .clk(clk),
    .resetn(~rst),

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

    .dmem_addr0(dmem0_addr0),
    .dmem_din0(dmem0_din0),
    .dmem_dout0(dmem0_dout0),
    .dmem_en0(dmem0_en0),
    .dmem_we0(dmem0_we0),

    .dmem_addr1(dmem0_addr1),
    .dmem_din1(dmem0_din1),
    .dmem_dout1(dmem0_dout1),
    .dmem_en1(dmem0_en1),
    .dmem_we1(dmem0_we1)
  );

  mem_model0 #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .DMEM_AWIDTH(DMEM_AWIDTH),
    .DMEM_DWIDTH(DMEM_DWIDTH)
  ) mem_model_dmem1 (
    .clk(clk),
    .resetn(~rst),

    .s_arid(s1_arid),
    .s_araddr(s1_araddr),
    .s_arvalid(s1_arvalid),
    .s_arready(s1_arready),
    .s_arlen(s1_arlen),
    .s_arsize(s1_arsize),
    .s_arburst(s1_arburst),

    .s_rid(s1_rid),
    .s_rdata(s1_rdata),
    .s_rvalid(s1_rvalid),
    .s_rready(s1_rready),
    .s_rlast(s1_rlast),
    .s_rresp(s1_rresp),

    .s_awid(s1_awid),
    .s_awaddr(s1_awaddr),
    .s_awvalid(s1_awvalid),
    .s_awready(s1_awready),
    .s_awlen(s1_awlen),
    .s_awsize(s1_awsize),
    .s_awburst(s1_awburst),

    .s_wid(s1_wid),
    .s_wdata(s1_wdata),
    .s_wvalid(s1_wvalid),
    .s_wready(s1_wready),
    .s_wlast(s1_wlast),
    .s_wstrb(s1_wstrb),

    .s_bid(s1_bid),
    .s_bresp(s1_bresp),
    .s_bvalid(s1_bvalid),
    .s_bready(s1_bready),

    .dmem_addr0(dmem1_addr0),
    .dmem_din0(dmem1_din0),
    .dmem_dout0(dmem1_dout0),
    .dmem_en0(dmem1_en0),
    .dmem_we0(dmem1_we0),

    .dmem_addr1(dmem1_addr1),
    .dmem_din1(dmem1_din1),
    .dmem_dout1(dmem1_dout1),
    .dmem_en1(dmem1_en1),
    .dmem_we1(dmem1_we1)
  );

  mem_model0 #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .DMEM_AWIDTH(DMEM_AWIDTH),
    .DMEM_DWIDTH(DMEM_DWIDTH)
  ) mem_model_dmem2 (
    .clk(clk),
    .resetn(~rst),

    .s_arid(s2_arid),
    .s_araddr(s2_araddr),
    .s_arvalid(s2_arvalid),
    .s_arready(s2_arready),
    .s_arlen(s2_arlen),
    .s_arsize(s2_arsize),
    .s_arburst(s2_arburst),

    .s_rid(s2_rid),
    .s_rdata(s2_rdata),
    .s_rvalid(s2_rvalid),
    .s_rready(s2_rready),
    .s_rlast(s2_rlast),
    .s_rresp(s2_rresp),

    .s_awid(s2_awid),
    .s_awaddr(s2_awaddr),
    .s_awvalid(s2_awvalid),
    .s_awready(s2_awready),
    .s_awlen(s2_awlen),
    .s_awsize(s2_awsize),
    .s_awburst(s2_awburst),

    .s_wid(s2_wid),
    .s_wdata(s2_wdata),
    .s_wvalid(s2_wvalid),
    .s_wready(s2_wready),
    .s_wlast(s2_wlast),
    .s_wstrb(s2_wstrb),

    .s_bid(s2_bid),
    .s_bresp(s2_bresp),
    .s_bvalid(s2_bvalid),
    .s_bready(s2_bready),

    .dmem_addr0(dmem2_addr0),
    .dmem_din0(dmem2_din0),
    .dmem_dout0(dmem2_dout0),
    .dmem_en0(dmem2_en0),
    .dmem_we0(dmem2_we0),

    .dmem_addr1(dmem2_addr1),
    .dmem_din1(dmem2_din1),
    .dmem_dout1(dmem2_dout1),
    .dmem_en1(dmem2_en1),
    .dmem_we1(dmem2_we1)
  );

  mem_model0 #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .DMEM_AWIDTH(DMEM_AWIDTH),
    .DMEM_DWIDTH(DMEM_DWIDTH)
  ) mem_model_dmem3 (
    .clk(clk),
    .resetn(~rst),

    .s_arid(s3_arid),
    .s_araddr(s3_araddr),
    .s_arvalid(s3_arvalid),
    .s_arready(s3_arready),
    .s_arlen(s3_arlen),
    .s_arsize(s3_arsize),
    .s_arburst(s3_arburst),

    .s_rid(s3_rid),
    .s_rdata(s3_rdata),
    .s_rvalid(s3_rvalid),
    .s_rready(s3_rready),
    .s_rlast(s3_rlast),
    .s_rresp(s3_rresp),

    .s_awid(s3_awid),
    .s_awaddr(s3_awaddr),
    .s_awvalid(s3_awvalid),
    .s_awready(s3_awready),
    .s_awlen(s3_awlen),
    .s_awsize(s3_awsize),
    .s_awburst(s3_awburst),

    .s_wid(s3_wid),
    .s_wdata(s3_wdata),
    .s_wvalid(s3_wvalid),
    .s_wready(s3_wready),
    .s_wlast(s3_wlast),
    .s_wstrb(s3_wstrb),

    .s_bid(s3_bid),
    .s_bresp(s3_bresp),
    .s_bvalid(s3_bvalid),
    .s_bready(s3_bready),

    .dmem_addr0(dmem3_addr0),
    .dmem_din0(dmem3_din0),
    .dmem_dout0(dmem3_dout0),
    .dmem_en0(dmem3_en0),
    .dmem_we0(dmem3_we0),

    .dmem_addr1(dmem3_addr1),
    .dmem_din1(dmem3_din1),
    .dmem_dout1(dmem3_dout1),
    .dmem_en1(dmem3_en1),
    .dmem_we1(dmem3_we1)
  );

`ifdef DEBUG
  always @(posedge clk) begin
    if (dmem0_en1 === 1'b1 && dmem0_we1 === 1'b1)
      $display("MEM_MODEL_DMEM0 WRITE addr=%h, din=%h", dmem0_addr1, dmem0_din1);
    if (dmem1_en1 === 1'b1 && dmem1_we1 === 1'b1)
      $display("MEM_MODEL_DMEM1 WRITE addr=%h, din=%h", dmem1_addr1, dmem1_din1);
    if (dmem2_en1 === 1'b1 && dmem2_we1 === 1'b1)
      $display("MEM_MODEL_DMEM2 WRITE addr=%h, din=%h", dmem2_addr1, dmem2_din1);
    if (dmem3_en1 === 1'b1 && dmem3_we1 === 1'b1)
      $display("MEM_MODEL_DMEM3 WRITE addr=%h, din=%h", dmem3_addr1, dmem3_din1);
  end
`endif

endmodule
