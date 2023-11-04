`timescale 1ns/1ps
`include "socket_config.vh"

module socket_top_tb();
  reg clk, rst;
  parameter CLOCK_PERIOD = 2;
  parameter CLOCK_FREQ   = 1_000_000_000 / CLOCK_PERIOD;

  localparam TIMEOUT_CYCLE = 10_000_000;

  initial clk = 0;
  always #(CLOCK_PERIOD/1) clk = ~clk;

  reg f_clk;

  initial f_clk = 0;
  always #(CLOCK_PERIOD/2) f_clk = ~f_clk;

  localparam AXI_AWIDTH = 64;
  localparam AXI_MAX_BURST_LEN = 256;//128;
  localparam AXI_DWIDTH  = 512;
  localparam DMEM_DWIDTH = 512;

  localparam MEM_MODEL_AWIDTH = 20;

  localparam LOG2_NUM_BYTES = $clog2(AXI_DWIDTH / 8);

  // AXI bus Master interface
  wire [3:0] m0_0_arid;
  wire [AXI_AWIDTH-1:0] m0_0_araddr;
  wire m0_0_arvalid;
  wire m0_0_arready;
  wire [7:0] m0_0_arlen;
  wire [2:0] m0_0_arsize;
  wire [1:0] m0_0_arburst;
  wire [3:0] m0_0_rid;
  wire [AXI_DWIDTH-1:0] m0_0_rdata;
  wire m0_0_rvalid;
  wire m0_0_rready;
  wire m0_0_rlast;
  wire [1:0] m0_0_rresp;
  wire [3:0] m0_0_awid;
  wire [AXI_AWIDTH-1:0] m0_0_awaddr;
  wire m0_0_awvalid;
  wire m0_0_awready;
  wire [7:0] m0_0_awlen;
  wire [2:0] m0_0_awsize;
  wire [1:0] m0_0_awburst;
  wire [3:0] m0_0_wid;
  wire [AXI_DWIDTH-1:0] m0_0_wdata;
  wire m0_0_wvalid;
  wire m0_0_wready;
  wire m0_0_wlast;
  wire [AXI_DWIDTH/8-1:0] m0_0_wstrb;
  wire [3:0] m0_0_bid;
  wire [1:0] m0_0_bresp;
  wire m0_0_bvalid;
  wire m0_0_bready;
  wire [3:0] m1_0_arid;
  wire [AXI_AWIDTH-1:0] m1_0_araddr;
  wire m1_0_arvalid;
  wire m1_0_arready;
  wire [7:0] m1_0_arlen;
  wire [2:0] m1_0_arsize;
  wire [1:0] m1_0_arburst;
  wire [3:0] m1_0_rid;
  wire [AXI_DWIDTH-1:0] m1_0_rdata;
  wire m1_0_rvalid;
  wire m1_0_rready;
  wire m1_0_rlast;
  wire [1:0] m1_0_rresp;
  wire [3:0] m1_0_awid;
  wire [AXI_AWIDTH-1:0] m1_0_awaddr;
  wire m1_0_awvalid;
  wire m1_0_awready;
  wire [7:0] m1_0_awlen;
  wire [2:0] m1_0_awsize;
  wire [1:0] m1_0_awburst;
  wire [3:0] m1_0_wid;
  wire [AXI_DWIDTH-1:0] m1_0_wdata;
  wire m1_0_wvalid;
  wire m1_0_wready;
  wire m1_0_wlast;
  wire [AXI_DWIDTH/8-1:0] m1_0_wstrb;
  wire [3:0] m1_0_bid;
  wire [1:0] m1_0_bresp;
  wire m1_0_bvalid;
  wire m1_0_bready;

  // AXI bus Slave interface
  // Read address channel
  wire [3:0]               s0_arid;
  wire [AXI_AWIDTH-1:0]    s0_araddr;
  wire                     s0_arvalid;
  wire                     s0_arready;
  wire [7:0]               s0_arlen;
  wire [2:0]               s0_arsize;
  wire [1:0]               s0_arburst;

  // Read data channel
  wire  [3:0]             s0_rid;
  wire  [AXI_DWIDTH-1:0]  s0_rdata;
  wire                    s0_rvalid;
  wire                    s0_rready;
  wire                    s0_rlast;
  wire  [1:0]             s0_rresp;
  // user (unused)

  // Write address channel
  wire [3:0]               s0_awid;
  wire [AXI_AWIDTH-1:0]    s0_awaddr;
  wire                     s0_awvalid;
  wire                     s0_awready;
  wire [7:0]               s0_awlen;
  wire [2:0]               s0_awsize;
  wire [1:0]               s0_awburst;

  // Write data channel
  wire [3:0]               s0_wid;
  wire [AXI_DWIDTH-1:0]    s0_wdata;
  wire                     s0_wvalid;
  wire                     s0_wready;
  wire                     s0_wlast;
  wire [AXI_DWIDTH/8-1:0]  s0_wstrb;

  // Write response channel
  wire [3:0]              s0_bid;
  wire [1:0]              s0_bresp;
  wire                    s0_bvalid;
  wire                    s0_bready;

  reg [32-1:0] s_axi_control_araddr;
  reg s_axi_control_arvalid;
  wire  s_axi_control_arready;

  wire [32-1:0] s_axi_control_rdata;
  wire s_axi_control_rvalid;
  reg  s_axi_control_rready;
  wire [1:0] s_axi_control_rresp;

  reg [32-1:0] s_axi_control_awaddr;
  reg  s_axi_control_awvalid;
  wire s_axi_control_awready;

  reg [32-1:0] s_axi_control_wdata;
  reg s_axi_control_wvalid;
  wire s_axi_control_wready;
  reg [32/8-1:0] s_axi_control_wstrb;

  wire [1:0] s_axi_control_bresp;
  wire s_axi_control_bvalid;
  reg  s_axi_control_bready;

  localparam VERIFY_LEN = 16576;

  reg [2047:0] CONTROL_FILE;
  reg [2047:0] VERIFY_FILE;
  reg [2047:0] INIT_FILE;

  reg [WORD_WIDTH-1:0] verify_mem [VERIFY_LEN-1:0];
  reg [WORD_WIDTH-1:0] init_mem   [VERIFY_LEN-1:0];

  initial begin
    if (!$value$plusargs("CONTROL_FILE=%s", CONTROL_FILE)) begin
      $display("Must supply CONTROL_FILE!");
      $finish();
    end

    if (!$value$plusargs("VERIFY_FILE=%s", VERIFY_FILE)) begin
      $display("Must supply VERIFY_FILE!");
      $finish();
    end

    if (!$value$plusargs("INIT_FILE=%s", INIT_FILE)) begin
      $display("Must supply INIT_FILE!");
      $finish();
    end

    $readmemh(CONTROL_FILE, dut.socket_template.controller.CPU.imem.mem);
    $readmemh(INIT_FILE, init_mem);
    $readmemh(VERIFY_FILE, verify_mem);
  end

  socket_top #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .AXI_MAX_BURST_LEN(AXI_MAX_BURST_LEN),
    .DMEM_DWIDTH(DMEM_DWIDTH),
    .DMEM_MIF_HEX("dmem_data.mif"),
    .IMEM_MIF_HEX("")
  ) dut (
    .clk(clk),
    .f_clk(f_clk),
    //.resetn(~rst),

    // AXI Master
    .m0_arid(m0_0_arid),
    .m0_araddr(m0_0_araddr),
    .m0_arvalid(m0_0_arvalid),
    .m0_arready(m0_0_arready),
    .m0_arlen(m0_0_arlen),
    .m0_arsize(m0_0_arsize),
    .m0_arburst(m0_0_arburst),

    .m0_rid(m0_0_rid),
    .m0_rdata(m0_0_rdata),
    .m0_rvalid(m0_0_rvalid),
    .m0_rready(m0_0_rready),
    .m0_rlast(m0_0_rlast),
    .m0_rresp(m0_0_rresp),

    .m0_awid(m0_0_awid),
    .m0_awaddr(m0_0_awaddr),
    .m0_awvalid(m0_0_awvalid),
    .m0_awready(m0_0_awready),
    .m0_awlen(m0_0_awlen),
    .m0_awsize(m0_0_awsize),
    .m0_awburst(m0_0_awburst),

    .m0_wid(m0_0_wid),
    .m0_wdata(m0_0_wdata),
    .m0_wvalid(m0_0_wvalid),
    .m0_wready(m0_0_wready),
    .m0_wlast(m0_0_wlast),
    .m0_wstrb(m0_0_wstrb),

    .m0_bid(m0_0_bid),
    .m0_bresp(m0_0_bresp),
    .m0_bvalid(m0_0_bvalid),
    .m0_bready(m0_0_bready),

`ifndef SOCKET_S
    // AXI Master
    .m1_arid(m1_0_arid),
    .m1_araddr(m1_0_araddr),
    .m1_arvalid(m1_0_arvalid),
    .m1_arready(m1_0_arready),
    .m1_arlen(m1_0_arlen),
    .m1_arsize(m1_0_arsize),
    .m1_arburst(m1_0_arburst),

    .m1_rid(m1_0_rid),
    .m1_rdata(m1_0_rdata),
    .m1_rvalid(m1_0_rvalid),
    .m1_rready(m1_0_rready),
    .m1_rlast(m1_0_rlast),
    .m1_rresp(m1_0_rresp),

    .m1_awid(m1_0_awid),
    .m1_awaddr(m1_0_awaddr),
    .m1_awvalid(m1_0_awvalid),
    .m1_awready(m1_0_awready),
    .m1_awlen(m1_0_awlen),
    .m1_awsize(m1_0_awsize),
    .m1_awburst(m1_0_awburst),

    .m1_wid(m1_0_wid),
    .m1_wdata(m1_0_wdata),
    .m1_wvalid(m1_0_wvalid),
    .m1_wready(m1_0_wready),
    .m1_wlast(m1_0_wlast),
    .m1_wstrb(m1_0_wstrb),

    .m1_bid(m1_0_bid),
    .m1_bresp(m1_0_bresp),
    .m1_bvalid(m1_0_bvalid),
    .m1_bready(m1_0_bready),
`endif

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
    .s0_bready(s0_bready)
  );

  socket_manager #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH)
  ) socket_manager (
    .clk(clk),
    .resetn(~rst),

    .m0_arid(s0_arid),
    .m0_araddr(s0_araddr),
    .m0_arvalid(s0_arvalid),
    .m0_arready(s0_arready),
    .m0_arlen(s0_arlen),
    .m0_arsize(s0_arsize),
    .m0_arburst(s0_arburst),

    .m0_rid(s0_rid),
    .m0_rdata(s0_rdata),
    .m0_rvalid(s0_rvalid),
    .m0_rready(s0_rready),
    .m0_rlast(s0_rlast),
    .m0_rresp(s0_rresp),

    .m0_awid(s0_awid),
    .m0_awaddr(s0_awaddr),
    .m0_awvalid(s0_awvalid),
    .m0_awready(s0_awready),
    .m0_awlen(s0_awlen),
    .m0_awsize(s0_awsize),
    .m0_awburst(s0_awburst),

    .m0_wid(s0_wid),
    .m0_wdata(s0_wdata),
    .m0_wvalid(s0_wvalid),
    .m0_wready(s0_wready),
    .m0_wlast(s0_wlast),
    .m0_wstrb(s0_wstrb),

    .m0_bid(s0_bid),
    .m0_bresp(s0_bresp),
    .m0_bvalid(s0_bvalid),
    .m0_bready(s0_bready),

    .s_axi_control_araddr(s_axi_control_araddr),
    .s_axi_control_arvalid(s_axi_control_arvalid),
    .s_axi_control_arready(s_axi_control_arready),

    .s_axi_control_rdata(s_axi_control_rdata),
    .s_axi_control_rvalid(s_axi_control_rvalid),
    .s_axi_control_rready(s_axi_control_rready),
    .s_axi_control_rresp(s_axi_control_rresp),

    .s_axi_control_awaddr(s_axi_control_awaddr),
    .s_axi_control_awvalid(s_axi_control_awvalid),
    .s_axi_control_awready(s_axi_control_awready),

    .s_axi_control_wdata(s_axi_control_wdata),
    .s_axi_control_wvalid(s_axi_control_wvalid),
    .s_axi_control_wready(s_axi_control_wready),
    .s_axi_control_wstrb(s_axi_control_wstrb),

    .s_axi_control_bresp(s_axi_control_bresp),
    .s_axi_control_bvalid(s_axi_control_bvalid),
    .s_axi_control_bready(s_axi_control_bready)

  );

  wire [3:0] s0_0_mem_arid;
  wire [AXI_AWIDTH-1:0] s0_0_mem_araddr;
  wire s0_0_mem_arvalid;
  wire s0_0_mem_arready;
  wire [7:0] s0_0_mem_arlen;
  wire [2:0] s0_0_mem_arsize;
  wire [1:0] s0_0_mem_arburst;
  wire [3:0] s0_0_mem_rid;
  wire [AXI_DWIDTH-1:0] s0_0_mem_rdata;
  wire s0_0_mem_rvalid;
  wire s0_0_mem_rready;
  wire s0_0_mem_rlast;
  wire [1:0] s0_0_mem_rresp;
  wire [3:0] s0_0_mem_awid;
  wire [AXI_AWIDTH-1:0] s0_0_mem_awaddr;
  wire s0_0_mem_awvalid;
  wire s0_0_mem_awready;
  wire [7:0] s0_0_mem_awlen;
  wire [2:0] s0_0_mem_awsize;
  wire [1:0] s0_0_mem_awburst;
  wire [3:0] s0_0_mem_wid;
  wire [AXI_DWIDTH-1:0] s0_0_mem_wdata;
  wire s0_0_mem_wvalid;
  wire s0_0_mem_wready;
  wire s0_0_mem_wlast;
  wire [AXI_DWIDTH/8-1:0] s0_0_mem_wstrb;
  wire [3:0] s0_0_mem_bid;
  wire [1:0] s0_0_mem_bresp;
  wire s0_0_mem_bvalid;
  wire s0_0_mem_bready;
  wire [3:0] s1_0_mem_arid;
  wire [AXI_AWIDTH-1:0] s1_0_mem_araddr;
  wire s1_0_mem_arvalid;
  wire s1_0_mem_arready;
  wire [7:0] s1_0_mem_arlen;
  wire [2:0] s1_0_mem_arsize;
  wire [1:0] s1_0_mem_arburst;
  wire [3:0] s1_0_mem_rid;
  wire [AXI_DWIDTH-1:0] s1_0_mem_rdata;
  wire s1_0_mem_rvalid;
  wire s1_0_mem_rready;
  wire s1_0_mem_rlast;
  wire [1:0] s1_0_mem_rresp;
  wire [3:0] s1_0_mem_awid;
  wire [AXI_AWIDTH-1:0] s1_0_mem_awaddr;
  wire s1_0_mem_awvalid;
  wire s1_0_mem_awready;
  wire [7:0] s1_0_mem_awlen;
  wire [2:0] s1_0_mem_awsize;
  wire [1:0] s1_0_mem_awburst;
  wire [3:0] s1_0_mem_wid;
  wire [AXI_DWIDTH-1:0] s1_0_mem_wdata;
  wire s1_0_mem_wvalid;
  wire s1_0_mem_wready;
  wire s1_0_mem_wlast;
  wire [AXI_DWIDTH/8-1:0] s1_0_mem_wstrb;
  wire [3:0] s1_0_mem_bid;
  wire [1:0] s1_0_mem_bresp;
  wire s1_0_mem_bvalid;
  wire s1_0_mem_bready;

  mem_model_x4 #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .DMEM_AWIDTH(MEM_MODEL_AWIDTH),
    .DMEM_DWIDTH(DMEM_DWIDTH)
  ) mem_model (
    .s0_arid(s0_0_mem_arid),
    .s0_araddr(s0_0_mem_araddr),
    .s0_arvalid(s0_0_mem_arvalid),
    .s0_arready(s0_0_mem_arready),
    .s0_arlen(s0_0_mem_arlen),
    .s0_arsize(s0_0_mem_arsize),
    .s0_arburst(s0_0_mem_arburst),
    .s0_awid(s0_0_mem_awid),
    .s0_awaddr(s0_0_mem_awaddr),
    .s0_awvalid(s0_0_mem_awvalid),
    .s0_awready(s0_0_mem_awready),
    .s0_awlen(s0_0_mem_awlen),
    .s0_awsize(s0_0_mem_awsize),
    .s0_awburst(s0_0_mem_awburst),
    .s0_rid(s0_0_mem_rid),
    .s0_rdata(s0_0_mem_rdata),
    .s0_rvalid(s0_0_mem_rvalid),
    .s0_rready(s0_0_mem_rready),
    .s0_rlast(s0_0_mem_rlast),
    .s0_rresp(s0_0_mem_rresp),
    .s0_wid(s0_0_mem_wid),
    .s0_wdata(s0_0_mem_wdata),
    .s0_wvalid(s0_0_mem_wvalid),
    .s0_wready(s0_0_mem_wready),
    .s0_wlast(s0_0_mem_wlast),
    .s0_wstrb(s0_0_mem_wstrb),
    .s0_bid(s0_0_mem_bid),
    .s0_bresp(s0_0_mem_bresp),
    .s0_bvalid(s0_0_mem_bvalid),
    .s0_bready(s0_0_mem_bready),
    .s1_arid(s1_0_mem_arid),
    .s1_araddr(s1_0_mem_araddr),
    .s1_arvalid(s1_0_mem_arvalid),
    .s1_arready(s1_0_mem_arready),
    .s1_arlen(s1_0_mem_arlen),
    .s1_arsize(s1_0_mem_arsize),
    .s1_arburst(s1_0_mem_arburst),
    .s1_awid(s1_0_mem_awid),
    .s1_awaddr(s1_0_mem_awaddr),
    .s1_awvalid(s1_0_mem_awvalid),
    .s1_awready(s1_0_mem_awready),
    .s1_awlen(s1_0_mem_awlen),
    .s1_awsize(s1_0_mem_awsize),
    .s1_awburst(s1_0_mem_awburst),
    .s1_rid(s1_0_mem_rid),
    .s1_rdata(s1_0_mem_rdata),
    .s1_rvalid(s1_0_mem_rvalid),
    .s1_rready(s1_0_mem_rready),
    .s1_rlast(s1_0_mem_rlast),
    .s1_rresp(s1_0_mem_rresp),
    .s1_wid(s1_0_mem_wid),
    .s1_wdata(s1_0_mem_wdata),
    .s1_wvalid(s1_0_mem_wvalid),
    .s1_wready(s1_0_mem_wready),
    .s1_wlast(s1_0_mem_wlast),
    .s1_wstrb(s1_0_mem_wstrb),
    .s1_bid(s1_0_mem_bid),
    .s1_bresp(s1_0_mem_bresp),
    .s1_bvalid(s1_0_mem_bvalid),
    .s1_bready(s1_0_mem_bready),
    .clk(clk),
    //.clk(clk_h),
    .resetn(~rst)
  );

  localparam NUM_STAGES = 23;
  handshake_pipe_block #(
    .NUM_STAGES(NUM_STAGES),
    .WIDTH(AXI_AWIDTH + 8 + 3 + 2 + 4)
  ) handshake_ar_0_0_block (
    .clk(clk),
    //.clk(clk_h),
    .valid(m0_0_arvalid),
    .ready(s0_0_mem_arready),
    .valid_pipe(s0_0_mem_arvalid),
    .ready_pipe(m0_0_arready),
    .data({m0_0_araddr, m0_0_arlen, m0_0_arsize, m0_0_arburst, m0_0_arid}),
    .data_pipe({s0_0_mem_araddr, s0_0_mem_arlen, s0_0_mem_arsize, s0_0_mem_arburst, s0_0_mem_arid})
  );
  handshake_pipe_block #(
    .NUM_STAGES(NUM_STAGES),
    .WIDTH(AXI_DWIDTH + 1 + 2 + 4)
  ) handshake_r_0_0_block (
    .clk(clk),
    //.clk(clk_h),
    .valid(s0_0_mem_rvalid),
    .ready(m0_0_rready),
    .valid_pipe(m0_0_rvalid),
    .ready_pipe(s0_0_mem_rready),
    .data({s0_0_mem_rdata, s0_0_mem_rlast, s0_0_mem_rresp, s0_0_mem_rid}),
    .data_pipe({m0_0_rdata, m0_0_rlast, m0_0_rresp, m0_0_rid})
  );
  handshake_pipe_block #(
    .NUM_STAGES(NUM_STAGES),
    .WIDTH(AXI_AWIDTH + 8 + 3 + 2 + 4)
  ) handshake_aw_0_0_block (
    .clk(clk),
    //.clk(clk_h),
    .valid(m0_0_awvalid),
    .ready(s0_0_mem_awready),
    .valid_pipe(s0_0_mem_awvalid),
    .ready_pipe(m0_0_awready),
    .data({m0_0_awaddr, m0_0_awlen, m0_0_awsize, m0_0_awburst, m0_0_awid}),
    .data_pipe({s0_0_mem_awaddr, s0_0_mem_awlen, s0_0_mem_awsize, s0_0_mem_awburst, s0_0_mem_awid})
  );
  handshake_pipe_block #(
    .NUM_STAGES(NUM_STAGES),
    .WIDTH(AXI_DWIDTH + 1 + AXI_DWIDTH/8 + 4)
  ) handshake_w_0_0_block (
    .clk(clk),
    //.clk(clk_h),
    .valid(m0_0_wvalid),
    .ready(s0_0_mem_wready),
    .valid_pipe(s0_0_mem_wvalid),
    .ready_pipe(m0_0_wready),
    .data({m0_0_wdata, m0_0_wlast, m0_0_wstrb, m0_0_wid}),
    .data_pipe({s0_0_mem_wdata, s0_0_mem_wlast, s0_0_mem_wstrb, s0_0_mem_wid})
  );
  handshake_pipe_block #(
    .NUM_STAGES(NUM_STAGES),
    .WIDTH(2 + 4)
  ) handshake_b_0_0_block (
    .clk(clk),
    //.clk(clk_h),
    .valid(s0_0_mem_bvalid),
    .ready(m0_0_bready),
    .valid_pipe(m0_0_bvalid),
    .ready_pipe(s0_0_mem_bready),
    .data({s0_0_mem_bresp, s0_0_mem_bid}),
    .data_pipe({m0_0_bresp, m0_0_bid})
  );
  handshake_pipe_block #(
    .NUM_STAGES(NUM_STAGES),
    .WIDTH(AXI_AWIDTH + 8 + 3 + 2 + 4)
  ) handshake_ar_1_0_block (
    .clk(clk),
    //.clk(clk_h),
    .valid(m1_0_arvalid),
    .ready(s1_0_mem_arready),
    .valid_pipe(s1_0_mem_arvalid),
    .ready_pipe(m1_0_arready),
    .data({m1_0_araddr, m1_0_arlen, m1_0_arsize, m1_0_arburst, m1_0_arid}),
    .data_pipe({s1_0_mem_araddr, s1_0_mem_arlen, s1_0_mem_arsize, s1_0_mem_arburst, s1_0_mem_arid})
  );
  handshake_pipe_block #(
    .NUM_STAGES(NUM_STAGES),
    .WIDTH(AXI_DWIDTH + 1 + 2 + 4)
  ) handshake_r_1_0_block (
    .clk(clk),
    //.clk(clk_h),
    .valid(s1_0_mem_rvalid),
    .ready(m1_0_rready),
    .valid_pipe(m1_0_rvalid),
    .ready_pipe(s1_0_mem_rready),
    .data({s1_0_mem_rdata, s1_0_mem_rlast, s1_0_mem_rresp, s1_0_mem_rid}),
    .data_pipe({m1_0_rdata, m1_0_rlast, m1_0_rresp, m1_0_rid})
  );
  handshake_pipe_block #(
    .NUM_STAGES(NUM_STAGES),
    .WIDTH(AXI_AWIDTH + 8 + 3 + 2 + 4)
  ) handshake_aw_1_0_block (
    .clk(clk),
    //.clk(clk_h),
    .valid(m1_0_awvalid),
    .ready(s1_0_mem_awready),
    .valid_pipe(s1_0_mem_awvalid),
    .ready_pipe(m1_0_awready),
    .data({m1_0_awaddr, m1_0_awlen, m1_0_awsize, m1_0_awburst, m1_0_awid}),
    .data_pipe({s1_0_mem_awaddr, s1_0_mem_awlen, s1_0_mem_awsize, s1_0_mem_awburst, s1_0_mem_awid})
  );
  handshake_pipe_block #(
    .NUM_STAGES(NUM_STAGES),
    .WIDTH(AXI_DWIDTH + 1 + AXI_DWIDTH/8 + 4)
  ) handshake_w_1_0_block (
    .clk(clk),
    //.clk(clk_h),
    .valid(m1_0_wvalid),
    .ready(s1_0_mem_wready),
    .valid_pipe(s1_0_mem_wvalid),
    .ready_pipe(m1_0_wready),
    .data({m1_0_wdata, m1_0_wlast, m1_0_wstrb, m1_0_wid}),
    .data_pipe({s1_0_mem_wdata, s1_0_mem_wlast, s1_0_mem_wstrb, s1_0_mem_wid})
  );
  handshake_pipe_block #(
    .NUM_STAGES(NUM_STAGES),
    .WIDTH(2 + 4)
  ) handshake_b_1_0_block (
    .clk(clk),
    //.clk(clk_h),
    .valid(s1_0_mem_bvalid),
    .ready(m1_0_bready),
    .valid_pipe(m1_0_bvalid),
    .ready_pipe(s1_0_mem_bready),
    .data({s1_0_mem_bresp, s1_0_mem_bid}),
    .data_pipe({m1_0_bresp, m1_0_bid})
  );

  wire s_axi_control_awfire = s_axi_control_awvalid & s_axi_control_awready;
  wire s_axi_control_wfire  = s_axi_control_wvalid  & s_axi_control_wready;
  wire s_axi_control_bfire  = s_axi_control_bvalid  & s_axi_control_bready;
  wire s_axi_control_arfire = s_axi_control_arvalid & s_axi_control_arready;
  wire s_axi_control_rfire  = s_axi_control_rvalid  & s_axi_control_rready;

  localparam SOCKET_CSR_OFFSET        = 64;
  localparam EXT_MEM_OFFSET_LO        = 65;
  localparam EXT_MEM_OFFSET_HI        = 66;
  localparam SOCKET_IMEM_ADDR_OFFSET  = 67;
  localparam SOCKET_IMEM_WDATA_OFFSET = 68;
  localparam SOCKET_IMEM_WE_OFFSET    = 69;

  localparam SOCKET_RESET_OFFSET = 256;

  localparam ADDR_CSR = 32'h0;
  localparam ADDR_SOCKET_OFFSET_LO = 32'h10;
  localparam ADDR_SOCKET_OFFSET_HI = 32'h14;
  localparam ADDR_SOCKET_WR_IDLE   = 32'h18;
  localparam ADDR_SOCKET_RDATA     = 32'h1c;
  localparam ADDR_SOCKET_WDATA     = 32'h20;
  localparam ADDR_SOCKET_RCNT      = 32'h24;
  localparam ADDR_SOCKET_WCNT      = 32'h28;

  localparam ADDR_QUEUE_CSR   = 32'h38;
  localparam ADDR_QUEUE_WDATA = 32'h3c;
  localparam ADDR_QUEUE_RDATA = 32'h40;
  localparam ADDR_QUEUE_LEN   = 32'h44;

  task axilite_write;
    input [31:0] addr;
    input [31:0] wdata;
    begin
      s_axi_control_awaddr = addr;
      s_axi_control_awvalid = 1'b1;
      wait (s_axi_control_awfire === 1'b1);
      @(posedge clk); #1;
      s_axi_control_awaddr = 0;
      s_axi_control_awvalid = 1'b0;

      s_axi_control_wdata = wdata;
      s_axi_control_wvalid = 1'b1;
      wait (s_axi_control_wfire === 1'b1);
      @(posedge clk); #1;
      s_axi_control_wdata = 0;
      s_axi_control_wvalid = 1'b0;
      s_axi_control_bready = 1'b1;
      wait (s_axi_control_bfire === 1'b1);
      @(posedge clk); #1;
      s_axi_control_bready = 1'b0;
    end
  endtask 

  task axilite_read;
    input [31:0] addr;
    begin
        s_axi_control_araddr  = addr;
        s_axi_control_arvalid = 1'b1;

        wait (s_axi_control_arfire === 1'b1);

        @(posedge clk); #1;
        s_axi_control_arvalid = 1'b0;
        s_axi_control_rready = 1'b1;

        wait (s_axi_control_rfire === 1'b1);
        @(posedge clk); #1;
        //$display("S_AXILITE_RDATA [%h]: %h", s_axi_control_araddr, s_axi_control_rdata);
        s_axi_control_rready = 1'b0;
    end
  endtask

  reg wr_idle;
  task axilite_check_wr_idle;
    begin
      wr_idle = 1'b0;
      while (wr_idle === 1'b0) begin
        s_axi_control_araddr  = ADDR_SOCKET_WR_IDLE;
        s_axi_control_arvalid = 1'b1;

        wait (s_axi_control_arfire === 1'b1);

        @(posedge clk); #1;
        s_axi_control_arvalid = 1'b0;
        s_axi_control_rready = 1'b1;

        wait (s_axi_control_rfire === 1'b1);
        if (s_axi_control_rdata === 1'b0)
          wr_idle = 1'b1;
        @(posedge clk); #1;
        s_axi_control_rready = 1'b0;
      end
    end
  endtask

  reg done;
  reg rcnt;
  task axilite_check_done;
    begin
      done = 1'b0;
      while (done === 1'b0) begin
        axilite_write(ADDR_SOCKET_RCNT, 0);
        // socket read commit
        axilite_read(ADDR_CSR);
        @(posedge clk); #1;
        rcnt = 0;
        while (rcnt !== 1) begin
          axilite_read(ADDR_SOCKET_RCNT);
          rcnt = s_axi_control_rdata;
        end
        // read socket_rdata
        axilite_read(ADDR_SOCKET_RDATA);
        if (s_axi_control_rdata[1] === 1'b1)
          done = 1'b1;
      end
    end
  endtask

  reg [31:0] cycle_cnt;
  always @(posedge f_clk) begin
    if (rst === 1)
      cycle_cnt <= 0;
    else
      cycle_cnt <= cycle_cnt + 1;
  end

  wire s0_awfire = s0_awvalid & s0_awready;
  wire s0_wfire  = s0_wvalid  & s0_wready;
  wire s0_bfire  = s0_bvalid  & s0_bready;
  wire s0_arfire = s0_arvalid & s0_arready;
  wire s0_rfire  = s0_rvalid  & s0_rready;

  integer i, j;

  initial begin
    rst = 1;

    // Hold reset for a while
    repeat (10) @(posedge clk);

    // Wait for some time to make sure signals propagate properly in the
    // pipe blocks
    repeat (100) @(posedge clk);

    @(negedge clk);
    rst = 0;
  end

  localparam WORD_WIDTH = 64;

  initial begin
    for (i = 0; i < (VERIFY_LEN / (AXI_DWIDTH / WORD_WIDTH)); i = i + 1) begin
      for (j = 0; j < AXI_DWIDTH / WORD_WIDTH; j = j + 1) begin
        mem_model.buffer.mem[i][j * WORD_WIDTH +: WORD_WIDTH] =
          init_mem[i * (AXI_DWIDTH / WORD_WIDTH) + j];
      end
    end
  end

  reg [31:0] num_mismatches = 0;

  initial begin
    num_mismatches = 0;

//    wait (dut.socket_template.controller.mmio.cpu_status_value === 1'b1);
    rst = 1;

    s_axi_control_araddr = 0;
    s_axi_control_arvalid = 1'b0;

    s_axi_control_rready = 1'b0;

    s_axi_control_awaddr = 0;
    s_axi_control_awvalid = 1'b0;

    s_axi_control_wdata = 0;
    s_axi_control_wvalid = 1'b0;
    s_axi_control_wstrb = 4'hF;

    s_axi_control_bready = 1'b0;
    // Hold reset for a while
     repeat (10) @(posedge clk);
    // Wait for some time to make sure signals propagate properly in the
    // pipe blocks
    repeat (100) @(posedge clk);
    @(negedge clk);
    rst = 0;
    repeat (10) @(posedge clk);

    // Reset socket
    axilite_write(ADDR_SOCKET_OFFSET_HI, `SOCKET_BASE(i) >> 32);
    axilite_write(ADDR_SOCKET_OFFSET_LO, `SOCKET_BASE(i) + ((256 + (1<<`SOCKET_MMIO_REG_SPACE)) << LOG2_NUM_BYTES)); // start
    axilite_write(ADDR_CSR, 32'd1);
    axilite_check_wr_idle();

    axilite_write(ADDR_SOCKET_OFFSET_HI, `SOCKET_BASE(i) >> 32);
    axilite_write(ADDR_SOCKET_OFFSET_LO, `SOCKET_BASE(i) + ((EXT_MEM_OFFSET_LO + (1<<`SOCKET_MMIO_REG_SPACE)) << LOG2_NUM_BYTES));
    axilite_write(ADDR_SOCKET_WDATA, 0);
    axilite_write(ADDR_CSR, 32'd1);
    axilite_check_wr_idle();

    axilite_write(ADDR_SOCKET_OFFSET_HI, `SOCKET_BASE(i) >> 32);
    axilite_write(ADDR_SOCKET_OFFSET_LO, `SOCKET_BASE(i) + ((EXT_MEM_OFFSET_HI + (1<<`SOCKET_MMIO_REG_SPACE)) << LOG2_NUM_BYTES));
    //axilite_write(ADDR_SOCKET_WDATA, 32'h000000c0);
    axilite_write(ADDR_SOCKET_WDATA, 0);
    axilite_write(ADDR_CSR, 32'd1);
    axilite_check_wr_idle();

    axilite_write(ADDR_SOCKET_OFFSET_HI, `SOCKET_BASE(i) >> 32);
    axilite_write(ADDR_SOCKET_OFFSET_LO, `SOCKET_BASE(i) + ((SOCKET_CSR_OFFSET + (1<<`SOCKET_MMIO_REG_SPACE)) << LOG2_NUM_BYTES)); // start
    axilite_write(ADDR_SOCKET_WDATA, 1);
    axilite_write(ADDR_CSR, 32'd1);
    axilite_check_wr_idle();

    $display("[%t] Socket started!", $time);

    repeat (10) @(posedge clk);

    // check status
    axilite_check_done();

    $display("Done! #Cycles: %d", cycle_cnt);
    $display("Perfomance counter: %d", dut.socket_template.perf_cnt_value);

    // Wait a few cycles for trailing writes to finish
    repeat (100) @(posedge clk);

    for (i = 0; i < (VERIFY_LEN / (AXI_DWIDTH / WORD_WIDTH)); i = i + 1) begin
      for (j = 0; j < AXI_DWIDTH / WORD_WIDTH; j = j + 1) begin
        if (mem_model.buffer.mem[i][j * WORD_WIDTH +: WORD_WIDTH] !== verify_mem[i * (AXI_DWIDTH / WORD_WIDTH) + j]) begin
          num_mismatches = num_mismatches + 1;
          $display("[%d] %h %h",
            i * (AXI_DWIDTH / WORD_WIDTH) + j,
            mem_model.buffer.mem[i][j * WORD_WIDTH +: WORD_WIDTH],
            verify_mem[i * (AXI_DWIDTH / WORD_WIDTH) + j]);
        end
      end
    end

    if (num_mismatches === 0)
      $display("PASSED!");
    else
      $display("FAILED! Num. mismatches %d", num_mismatches);

    #200;
    $finish();
  end

//  initial begin
//    repeat (TIMEOUT_CYCLE) @(posedge clk);
//    $display("Timeout!");
//    $finish();
//  end

endmodule

