`timescale 1ns/1ps
`include "socket_config.vh"

module system_socket_tb();
  reg clk;

  parameter CLOCK_PERIOD = 10;
  initial clk = 0;
  always #(CLOCK_PERIOD/2) clk = ~clk;

  parameter SYS_CLK_PERIOD = 5;

  reg sys_clk_clk_n;
  initial sys_clk_clk_n = 0;
  always #(SYS_CLK_PERIOD/2) sys_clk_clk_n = ~sys_clk_clk_n;
  wire sys_clk_clk_p = ~sys_clk_clk_n;

  localparam TIMEOUT_CYCLE = 50_000_000;
  localparam NUM_SOCKETS = 2;
  localparam AXI_DWIDTH     = 512;
  localparam LOG2_NUM_BYTES = $clog2(AXI_DWIDTH / 8);

  wire [0:0] CH0_DDR4_act_n;
  wire [16:0] CH0_DDR4_adr;
  wire [1:0] CH0_DDR4_ba;
  wire [1:0] CH0_DDR4_bg;
  wire [0:0] CH0_DDR4_ck_c;
  wire [0:0] CH0_DDR4_ck_t;
  wire [0:0] CH0_DDR4_cke;
  wire [0:0] CH0_DDR4_cs_n;
  wire [7:0] CH0_DDR4_dm_n;
  wire [63:0] CH0_DDR4_dq;
  wire [7:0] CH0_DDR4_dqs_c;
  wire [7:0] CH0_DDR4_dqs_t;
  wire [0:0] CH0_DDR4_odt;
  wire [0:0] CH0_DDR4_reset_n;

  reg [31:0] mem_len;
  reg [63:0] ddr_addr, ram_addr;
  reg start_write, start_read;
  wire done_write, done_read;
  reg dump_mem;

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

  wire user_clk;

  reg resetn;
  reg clkwiz_reset;
  reg clkwiz_clk_out1_ce;
  reg clkwiz_clk_out1_clr_n;

  design_1_wrapper_sim_wrapper dut (
    .CH0_DDR4_act_n(CH0_DDR4_act_n),
    .CH0_DDR4_adr(CH0_DDR4_adr),
    .CH0_DDR4_ba(CH0_DDR4_ba),
    .CH0_DDR4_bg(CH0_DDR4_bg),
    .CH0_DDR4_ck_c(CH0_DDR4_ck_c),
    .CH0_DDR4_ck_t(CH0_DDR4_ck_t),
    .CH0_DDR4_cke(CH0_DDR4_cke),
    .CH0_DDR4_cs_n(CH0_DDR4_cs_n),
    .CH0_DDR4_dm_n(CH0_DDR4_dm_n),
    .CH0_DDR4_dq(CH0_DDR4_dq),
    .CH0_DDR4_dqs_c(CH0_DDR4_dqs_c),
    .CH0_DDR4_dqs_t(CH0_DDR4_dqs_t),
    .CH0_DDR4_odt(CH0_DDR4_odt),
    .CH0_DDR4_reset_n(CH0_DDR4_reset_n),
    .sys_clk_clk_n(sys_clk_clk_n),
    .sys_clk_clk_p(sys_clk_clk_p),
    .clkwiz_clk_in1(clk),
    .clkwiz_reset(clkwiz_reset),
    .clkwiz_clk_out1_ce(clkwiz_clk_out1_ce),
    .clkwiz_clk_out1_clr_n(clkwiz_clk_out1_clr_n),
    .user_clk(user_clk),
    .resetn(resetn),

    // axi_data_generator
    .mem_len(mem_len),
    .ddr_addr(ddr_addr),
    .ram_addr(ram_addr),
    .start_write(start_write),
    .done_write(done_write),
    .start_read(start_read),
    .done_read(done_read),
    .dump_mem(dump_mem),

    // core logic
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

//  wire user_clk  = dut.design_1_wrapper_i.design_1_i.clk_wizard_0.clk_out1_o1;
  wire user_rstn = dut.design_1_wrapper_i.design_1_i.socket_manager_0.resetn;

  reg all_done;

  reg [31:0] cycle_cnt;
  always @(posedge user_clk) begin
    if (user_rstn === 0)
      cycle_cnt <= 0;
    else
      cycle_cnt <= cycle_cnt + 1;
  end

  wire s_axi_control_awfire = s_axi_control_awvalid & s_axi_control_awready;
  wire s_axi_control_wfire  = s_axi_control_wvalid  & s_axi_control_wready;
  wire s_axi_control_bfire  = s_axi_control_bvalid  & s_axi_control_bready;
  wire s_axi_control_arfire = s_axi_control_arvalid & s_axi_control_arready;
  wire s_axi_control_rfire  = s_axi_control_rvalid  & s_axi_control_rready;

  integer i, j;

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

  localparam ADDR_SOCKET_QUEUE_ENQ = 32'h38;
  localparam ADDR_SOCKET_QUEUE_DEQ = 32'h3c;
  localparam ADDR_SOCKET_STATUS = 32'h40;

  task axilite_write;
    input [31:0] addr;
    input [31:0] wdata;
    begin
      s_axi_control_awaddr = addr;
      s_axi_control_awvalid = 1'b1;
      wait (s_axi_control_awfire === 1'b1);
      @(posedge user_clk); #1;
      s_axi_control_awaddr = 0;
      s_axi_control_awvalid = 1'b0;

      s_axi_control_wdata = wdata;
      s_axi_control_wvalid = 1'b1;
      wait (s_axi_control_wfire === 1'b1);
      @(posedge user_clk); #1;
      s_axi_control_wdata = 0;
      s_axi_control_wvalid = 1'b0;
      s_axi_control_bready = 1'b1;
      wait (s_axi_control_bfire === 1'b1);
      @(posedge user_clk); #1;
      s_axi_control_bready = 1'b0;
      //$display("[%t] [SOCKET_MANAGER] AXILITE_WDATA [%h]: %h", $time, addr, wdata);
    end
  endtask 

  reg done;
  reg [31:0] tmp_read;
  task axilite_check_done;
    begin
      done = 1'b0;
      while (done === 1'b0) begin
        axilite_write(ADDR_SOCKET_RCNT, 0);
        // socket read commit
        axilite_read(ADDR_CSR, tmp_read);
        @(posedge clk); #1;
        tmp_read = 0;
        while (tmp_read !== 1) begin
          axilite_read(ADDR_SOCKET_RCNT, tmp_read);
          tmp_read = s_axi_control_rdata;
        end
        // read socket_rdata
        axilite_read(ADDR_SOCKET_RDATA, tmp_read);
        if (s_axi_control_rdata[1] === 1'b1)
          done = 1'b1;
      end
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

        @(posedge user_clk); #1;
        s_axi_control_arvalid = 1'b0;
        s_axi_control_rready = 1'b1;

        wait (s_axi_control_rfire === 1'b1);
        if (s_axi_control_rdata === 1'b0)
          wr_idle = 1'b1;
        @(posedge user_clk); #1;
        s_axi_control_rready = 1'b0;
      end
    end
  endtask

  task axilite_read;
    input [31:0] addr;
    output [31:0] rvalue;
    begin
        s_axi_control_araddr  = addr;
        s_axi_control_arvalid = 1'b1;

        wait (s_axi_control_arfire === 1'b1);

        @(posedge user_clk); #1;
        s_axi_control_arvalid = 1'b0;
        s_axi_control_rready = 1'b1;

        wait (s_axi_control_rfire === 1'b1);
        rvalue = s_axi_control_rdata;
        @(posedge user_clk); #1;
        //$display("S_AXILITE_RDATA [%h]: %h", s_axi_control_araddr, s_axi_control_rdata);
        s_axi_control_rready = 1'b0;
    end
  endtask

  reg [31:0] tmp = 0;
  initial begin
    #0;
    all_done = 1'b0;

    resetn = 1'b0;
    clkwiz_reset = 1'b0;
    clkwiz_clk_out1_ce = 1'b1;
    clkwiz_clk_out1_clr_n = 1'b1;

    mem_len = 0;
    ddr_addr = 0;
    ram_addr = 0;
    dump_mem = 1'b0;

    start_write = 1'b0;
    start_read  = 1'b0;

    s_axi_control_araddr = 0;
    s_axi_control_arvalid = 1'b0;

    s_axi_control_rready = 1'b0;

    s_axi_control_awaddr = 0;
    s_axi_control_awvalid = 1'b0;

    s_axi_control_wdata = 0;
    s_axi_control_wvalid = 1'b0;
    s_axi_control_wstrb = 4'hF;

    s_axi_control_bready = 1'b0;

    repeat (10) @(posedge user_clk);
    @(negedge user_clk);
    resetn = 1'b1;

    repeat (100) @(posedge user_clk);
    // Write init data to DDR
    @(negedge user_clk);
    start_write = 1'b1;

    @(negedge user_clk);
    start_write = 1'b0;

    wait (done_write === 1);

    $display("[Cycle %d] DDR Init done!", cycle_cnt);

    repeat (10) @(posedge user_clk);

    // set ctrl
    for (i = 0; i < NUM_SOCKETS; i = i + 1) begin
      // Reset core
      $display("[Cycle %d] Core %d reseting", cycle_cnt, i);
      axilite_write(ADDR_SOCKET_OFFSET_HI, `SOCKET_BASE(i) >> 32);
      axilite_write(ADDR_SOCKET_OFFSET_LO, `SOCKET_BASE(i) + ((SOCKET_RESET_OFFSET + (1 <<`SOCKET_MMIO_REG_SPACE)) << LOG2_NUM_BYTES)); // reset
      axilite_write(ADDR_SOCKET_WDATA, 1);
      axilite_write(ADDR_CSR, 32'd1);
      axilite_check_wr_idle();

      axilite_write(ADDR_SOCKET_OFFSET_HI, `SOCKET_BASE(i) >> 32);
      axilite_write(ADDR_SOCKET_OFFSET_LO, `SOCKET_BASE(i) + ((EXT_MEM_OFFSET_LO + (1<<`SOCKET_MMIO_REG_SPACE)) << LOG2_NUM_BYTES));
      axilite_write(ADDR_SOCKET_WDATA, 0);
      axilite_write(ADDR_CSR, 32'd1);
      axilite_check_wr_idle();

      axilite_write(ADDR_SOCKET_OFFSET_HI, `SOCKET_BASE(i) >> 32);
      axilite_write(ADDR_SOCKET_OFFSET_LO, `SOCKET_BASE(i) + ((EXT_MEM_OFFSET_HI + (1<<`SOCKET_MMIO_REG_SPACE)) << LOG2_NUM_BYTES));
      //axilite_write(ADDR_SOCKET_WDATA, 32'hc0);
      axilite_write(ADDR_SOCKET_WDATA, 32'h0);
      axilite_write(ADDR_CSR, 32'd1);
      axilite_check_wr_idle();
    end

    axilite_write(ADDR_SOCKET_WDATA, 1);

    axilite_write(ADDR_SOCKET_STATUS, 0);

    for (i = 0; i < NUM_SOCKETS; i = i + 1) begin
      // enqueue socket offsets
      axilite_write(ADDR_SOCKET_OFFSET_HI, `SOCKET_BASE(i) >> 32);
      axilite_write(ADDR_SOCKET_OFFSET_LO, `SOCKET_BASE(i) + ((SOCKET_CSR_OFFSET + (1<<`SOCKET_MMIO_REG_SPACE)) << LOG2_NUM_BYTES));
      axilite_write(ADDR_SOCKET_QUEUE_ENQ, 32'd1);
    end

    // Start all sockets
    axilite_write(ADDR_SOCKET_QUEUE_DEQ, 32'd1);
    $display("[Cycle %d] Starting %d sockets", cycle_cnt, NUM_SOCKETS);

    repeat (100) @(posedge user_clk);
    // check status
    while (tmp[NUM_SOCKETS-1:0] !== {NUM_SOCKETS{1'b1}}) begin
      axilite_read(ADDR_SOCKET_STATUS, tmp);
    end
    repeat (10) @(posedge user_clk);

    // Read final data from DDR
    @(negedge user_clk);
    start_read = 1'b1;

    @(negedge user_clk);
    start_read = 1'b0;

    wait (done_read === 1);

    $display("[Cycle %d] DDR Final Read done", cycle_cnt);

    repeat (10) @(posedge user_clk);

    $display("Done in %d cycles!", cycle_cnt);

    dump_mem = 1'b1;
    //$writememh("dmem_data_out.mif", dut.design_1_wrapper_i.design_1_i.axi_data_generator_0.inst.ram0.mem);
    repeat (100) @(posedge user_clk);

    $finish();
  end

  initial begin
    repeat (TIMEOUT_CYCLE) @(posedge user_clk);
    $display("Timeout!");
    $finish();
  end

endmodule
