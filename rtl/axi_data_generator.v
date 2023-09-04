`include "socket_config.vh"

// Used for system_sim_socket.tcl
module axi_data_generator #(
  parameter AXI_AWIDTH = 64,
  parameter AXI_DWIDTH = 512,//64,
  parameter AXI_MAX_BURST_LEN = 16,//256,
  parameter DMEM_AWIDTH = 30,
  parameter DMEM_DWIDTH = 512,//64,
  parameter MEM_LEN     = 16,
  parameter MEM_INIT_FILE = "dmem_data.mif"
) (
  input clk,
  input resetn,

  output [3:0]              m_arid,
  output [AXI_AWIDTH-1:0]   m_araddr,
  output                    m_arvalid,
  input                     m_arready,
  output [7:0]              m_arlen,
  output [2:0]              m_arsize,
  output [1:0]              m_arburst,
  input  [3:0]              m_rid,
  input  [AXI_DWIDTH-1:0]   m_rdata,
  input                     m_rvalid,
  output                    m_rready,
  input                     m_rlast,
  input  [1:0]              m_rresp,
  output [3:0]              m_awid,
  output [AXI_AWIDTH-1:0]   m_awaddr,
  output                    m_awvalid,
  input                     m_awready,
  output [7:0]              m_awlen,
  output [2:0]              m_awsize,
  output [1:0]              m_awburst,
  output [3:0]              m_wid,
  output [AXI_DWIDTH-1:0]   m_wdata,
  output                    m_wvalid,
  input                     m_wready,
  output                    m_wlast,
  output [AXI_DWIDTH/8-1:0] m_wstrb,
  input  [3:0]              m_bid,
  input  [1:0]              m_bresp,
  input                     m_bvalid,
  output                    m_bready,

  input [31:0] mem_len,
  input [63:0] ddr_addr,
  input [63:0] ram_addr,
  input  start_read,
  output done_read,
  input  start_write,
  output done_write,

  input dump_mem
);

  localparam BYTE_SIZE      = AXI_DWIDTH / 8;
  localparam LOG2_BYTE_SIZE = $clog2(BYTE_SIZE);

  wire [DMEM_AWIDTH-1:0] dmem_addr0;
  wire [DMEM_DWIDTH-1:0] dmem_din0;
  wire [DMEM_DWIDTH-1:0] dmem_dout0;
  wire dmem_en0;
  wire [DMEM_DWIDTH/8-1:0] dmem_we0;
  wire [DMEM_AWIDTH-1:0] dmem_addr1;
  wire [DMEM_DWIDTH-1:0] dmem_din1;
  wire [DMEM_DWIDTH-1:0] dmem_dout1;
  wire dmem_en1;
  wire [DMEM_DWIDTH/8-1:0] dmem_we1;

  assign dmem_addr1 = 0;
  assign dmem_din1  = 0;
  assign dmem_we1   = 0;
  assign dmem_en1   = 1'b0;

  SYNC_RAM_DP_WBE #(
    .AWIDTH(DMEM_AWIDTH),
    .DWIDTH(DMEM_DWIDTH),
    .DEPTH(MEM_LEN)
    //.MIF_HEX(MEM_INIT_FILE)
  ) ram0 (
    .addr0(dmem_addr0),
    .d0(dmem_din0),
    .q0(dmem_dout0),
    .wbe0(dmem_we0),
    .en0(dmem_en0),
    .addr1(dmem_addr1),
    .d1(dmem_din1),
    .q1(dmem_dout1),
    .wbe1(dmem_we1),
    .en1(dmem_en1),
    .clk(clk)
  );

  localparam WORD_WIDTH = 64;
  reg [WORD_WIDTH-1:0] init_mem [MEM_LEN-1:0];
  initial begin
    $readmemh(MEM_INIT_FILE, init_mem);
  end
  integer i, j;
  initial begin
    for (i = 0; i < (MEM_LEN / (AXI_DWIDTH / WORD_WIDTH)); i = i + 1) begin
      for (j = 0; j < AXI_DWIDTH / WORD_WIDTH; j = j + 1) begin
        ram0.mem[i][j * WORD_WIDTH +: WORD_WIDTH] =
          init_mem[i * (AXI_DWIDTH / WORD_WIDTH) + j];
      end
    end
  end

  wire m_read_request_valid;
  wire m_read_request_ready;
  wire [AXI_AWIDTH-1:0] m_read_addr;
  wire [31:0] m_read_len;
  wire [2:0] m_read_size;
  wire [1:0] m_read_burst;
  wire [AXI_DWIDTH-1:0] m_read_data;
  wire m_read_data_valid;
  wire m_read_data_ready;
  wire m_write_request_valid;
  wire m_write_request_ready;
  wire [AXI_AWIDTH-1:0] m_write_addr;
  wire [31:0] m_write_len;
  wire [2:0] m_write_size;
  wire [1:0] m_write_burst;
  wire [AXI_DWIDTH-1:0] m_write_data;
  wire m_write_data_valid;
  wire m_write_data_ready;
  wire m_write_resp_ok;
  m_axi_adapter #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .AXI_MAX_BURST_LEN(AXI_MAX_BURST_LEN)
  ) m_axi_m_adapter (
    .clk(clk),
    .resetn(resetn),
    .m_arid(m_arid),
    .m_araddr(m_araddr),
    .m_arvalid(m_arvalid),
    .m_arready(m_arready),
    .m_arlen(m_arlen),
    .m_arsize(m_arsize),
    .m_arburst(m_arburst),
    .m_rid(m_rid),
    .m_rdata(m_rdata),
    .m_rvalid(m_rvalid),
    .m_rready(m_rready),
    .m_rlast(m_rlast),
    .m_rresp(m_rresp),
    .m_awid(m_awid),
    .m_awaddr(m_awaddr),
    .m_awvalid(m_awvalid),
    .m_awready(m_awready),
    .m_awlen(m_awlen),
    .m_awsize(m_awsize),
    .m_awburst(m_awburst),
    .m_wid(m_wid),
    .m_wdata(m_wdata),
    .m_wvalid(m_wvalid),
    .m_wready(m_wready),
    .m_wlast(m_wlast),
    .m_wstrb(m_wstrb),
    .m_bid(m_bid),
    .m_bresp(m_bresp),
    .m_bvalid(m_bvalid),
    .m_bready(m_bready),
    .core_read_request_valid(m_read_request_valid),   // input
    .core_read_request_ready(m_read_request_ready),   // output
    .core_read_addr(m_read_addr),                     // input
    .core_read_len(m_read_len),                       // input
    .core_read_size(m_read_size),                     // input
    .core_read_burst(m_read_burst),                   // input
    .core_read_data(m_read_data),                     // output
    .core_read_data_valid(m_read_data_valid),         // output
    .core_read_data_ready(m_read_data_ready),         // input
    .core_write_request_valid(m_write_request_valid), // input
    .core_write_request_ready(m_write_request_ready), // output
    .core_write_addr(m_write_addr),                   // input
    .core_write_len(m_write_len),                     // input
    .core_write_size(m_write_size),                   // input
    .core_write_burst(m_write_burst),                 // input
    .core_write_data(m_write_data),                   // input
    .core_write_data_valid(m_write_data_valid),       // input
    .core_write_data_ready(m_write_data_ready),       // output
    .core_write_resp_ok(m_write_resp_ok)              // output
  );
  wire dma_read_request_valid;
  wire dma_read_request_ready;
  wire [AXI_AWIDTH-1:0] dma_read_addr;
  wire [31:0] dma_read_len;
  wire [2:0] dma_read_size;
  wire [1:0] dma_read_burst;
  wire [AXI_DWIDTH-1:0] dma_read_data;
  wire dma_read_data_valid;
  wire dma_read_data_ready;
  wire dma_write_request_valid;
  wire dma_write_request_ready;
  wire [AXI_AWIDTH-1:0] dma_write_addr;
  wire [31:0] dma_write_len;
  wire [2:0] dma_write_size;
  wire [1:0] dma_write_burst;
  wire [AXI_DWIDTH-1:0] dma_write_data;
  wire dma_write_data_valid;
  wire dma_write_data_ready;
  wire dma_write_resp_ok;
  wire dma_start, dma_done, dma_idle;
  wire dma_enqueue;
  wire [1:0] dma_mode;
  wire [63:0] dma_int_addr, dma_ext_addr;
  wire [31:0] dma_len, dma_stride, dma_offset;
  wire [31:0] dma_seg_stride, dma_seg_count;
  wire [31:0] dma_wval;
  wire dma_queue_full;
  wire dma_wait;
  wire dmem_we0_tmp;
//  assign dmem_we0 = {8{dmem_we0_tmp}}; // 64b
  assign dmem_we0 = {64{dmem_we0_tmp}}; // 512b

  dma_engine #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH),
    .DMEM_AWIDTH(DMEM_AWIDTH),
    .DMEM_DWIDTH(DMEM_DWIDTH),
    .MEMORY_UNIT_LATENCY(1)
  ) dma_engine (
    .clk(clk),
    .resetn(resetn),
    .dma_read_request_valid(dma_read_request_valid),
    .dma_read_request_ready(dma_read_request_ready),
    .dma_read_addr(dma_read_addr),
    .dma_read_len(dma_read_len),
    .dma_read_size(dma_read_size),
    .dma_read_burst(dma_read_burst),
    .dma_read_data(dma_read_data),
    .dma_read_data_valid(dma_read_data_valid),
    .dma_read_data_ready(dma_read_data_ready),
    .dma_write_request_valid(dma_write_request_valid),
    .dma_write_request_ready(dma_write_request_ready),
    .dma_write_addr(dma_write_addr),
    .dma_write_len(dma_write_len),
    .dma_write_size(dma_write_size),
    .dma_write_burst(dma_write_burst),
    .dma_write_data(dma_write_data),
    .dma_write_data_valid(dma_write_data_valid),
    .dma_write_data_ready(dma_write_data_ready),
    .dma_write_resp_ok(dma_write_resp_ok),
    .dma_start(dma_start),
    .dma_done(dma_done),
    .dma_idle(dma_idle),
    .dma_enqueue(dma_enqueue),
    .dma_mode(dma_mode),
    .dma_int_addr(dma_int_addr),
    .dma_ext_addr(dma_ext_addr),
    .dma_len(dma_len),
    .dma_stride(dma_stride),
    .dma_offset(dma_offset),
    .dma_seg_stride(dma_seg_stride),
    .dma_seg_count(dma_seg_count),
    .dma_wval(dma_wval),
    .dma_queue_full(dma_queue_full),
    .dma_wait(dma_wait),

    .dmem_addr(dmem_addr0),
    .dmem_din(dmem_din0),
    .dmem_dout(dmem_dout0),
    .dmem_we(dmem_we0_tmp),
    .dmem_en(dmem_en0)
  );

  assign m_write_request_valid = dma_write_request_valid;
  assign dma_write_request_ready = m_write_request_ready;
  assign m_write_addr = dma_write_addr;
  assign m_write_len = dma_write_len;
  assign m_write_size = dma_write_size;
  assign m_write_burst = dma_write_burst;
  assign m_write_data = dma_write_data;
  assign m_write_data_valid = dma_write_data_valid;
  assign dma_write_data_ready = m_write_data_ready;
  assign dma_write_resp_ok = m_write_resp_ok;
  assign m_read_request_valid = dma_read_request_valid;
  assign dma_read_request_ready = m_read_request_ready;
  assign m_read_addr = dma_read_addr;
  assign m_read_len = dma_read_len;
  assign m_read_size = dma_read_size;
  assign m_read_burst = dma_read_burst;
  assign dma_read_data = m_read_data;
  assign dma_read_data_valid = m_read_data_valid;
  assign m_read_data_ready = dma_read_data_ready;

//    .dma_wait(dma_wait),
//    .dma_start(dma_start),
//    .dma_done(dma_done),
//    .dma_enqueue(dma_enqueue),
//    .dma_mode(dma_mode),
//    .dma_int_addr(dma_int_addr),
//    .dma_ext_addr(dma_ext_addr),
//    .dma_len(dma_len),
//    .dma_stride(dma_stride),
//    .dma_offset(dma_offset),
//    .dma_seg_stride(dma_seg_stride),
//    .dma_seg_count(dma_seg_count),


  localparam STATE_IDLE              = 0;
  localparam STATE_WRITE_EXT_ENQUEUE = 1;
  localparam STATE_WRITE_EXT_START   = 2;
  localparam STATE_WRITE_EXT_DONE    = 3;
  localparam STATE_READ_EXT_ENQUEUE  = 4;
  localparam STATE_READ_EXT_START    = 5;
  localparam STATE_READ_EXT_DONE     = 6;

  wire [2:0] state_value;
  reg  [2:0] state_next;

  REGISTER_R #(.N(3), .INIT(STATE_IDLE)) state_reg (
    .clk(clk),
    .d(state_next),
    .q(state_value)
  );

  wire st_idle              = (state_value == STATE_IDLE);
  wire st_write_ext_enqueue = (state_value == STATE_WRITE_EXT_ENQUEUE);
  wire st_write_ext_start   = (state_value == STATE_WRITE_EXT_START);
  wire st_write_ext_done    = (state_value == STATE_WRITE_EXT_DONE);
  wire st_read_ext_enqueue  = (state_value == STATE_READ_EXT_ENQUEUE);
  wire st_read_ext_start    = (state_value == STATE_READ_EXT_START);
  wire st_read_ext_done     = (state_value == STATE_READ_EXT_DONE);

  always @(*) begin
    state_next = state_value;
    case (state_value)
      STATE_IDLE: begin
        if (start_write)
          state_next = STATE_WRITE_EXT_ENQUEUE;
        else if (start_read)
          state_next = STATE_READ_EXT_ENQUEUE;
      end

      STATE_WRITE_EXT_ENQUEUE: begin
        state_next = STATE_WRITE_EXT_START;
      end

      STATE_WRITE_EXT_START: begin
        state_next = STATE_WRITE_EXT_DONE;
      end

      STATE_WRITE_EXT_DONE: begin
        if (dma_done)
          state_next = STATE_IDLE;
      end

      STATE_READ_EXT_ENQUEUE: begin
        state_next = STATE_READ_EXT_START;
      end

      STATE_READ_EXT_START: begin
        state_next = STATE_READ_EXT_DONE;
      end

      STATE_READ_EXT_DONE: begin
        if (dma_done)
          state_next = STATE_IDLE;
      end
    endcase
  end

  assign dma_mode = (st_write_ext_enqueue) ? 2'h1 : 2'h0;
  assign dma_len  = MEM_LEN / (AXI_DWIDTH / WORD_WIDTH);//mem_len;
  assign dma_offset = 32'd0;
  assign dma_stride = 32'd1;
  assign dma_seg_count  = 32'd1;
  assign dma_seg_stride = 32'd0;

  assign dma_int_addr = ram_addr;
  assign dma_ext_addr = ddr_addr;

  assign dma_enqueue = st_write_ext_enqueue | st_read_ext_enqueue;
  assign dma_start   = st_write_ext_start   | st_read_ext_start;

  assign done_read  = st_read_ext_done  & dma_done;
  assign done_write = st_write_ext_done & dma_done;

  always @(posedge clk) begin
    if (dump_mem === 1'b1) begin
      $writememh("dmem_data_out.mif", ram0.mem, 0, MEM_LEN-1);
    end
  end

`ifdef DEBUG
  wire m_arfire = m_arvalid & m_arready;
  wire m_rfire  = m_rvalid  & m_rready;
  wire m_awfire = m_awvalid & m_awready;
  wire m_wfire  = m_wvalid  & m_wready;
  always @(posedge clk) begin
    if (m_arfire === 1'b1) begin
      $display("[At %t] [%m] [M_AXI READ REQ] m_araddr=%h, m_arlen=%h, m_arsize=%h", $time, m_araddr, m_arlen, m_arsize);
    end
    if (m_rfire === 1'b1) begin
      $display("[At %t] [%m] [M_AXI READ DATA] m_rdata=%h", $time, m_rdata);
      if (m_rlast === 1'b1) begin
        $display("[At %t] [%m] [M_AXI READ DATA LAST!]", $time);
      end
    end
    if (m_awfire === 1'b1) begin
      $display("[At %t] [%m] [M_AXI WRITE REQ] m_awaddr=%h, m_awlen=%h, m_awsize=%h", $time, m_awaddr, m_awlen, m_awsize);
    end
    if (m_wfire === 1'b1) begin
      $display("[At %t] [%m] [M_AXI WRITE DATA] m_wdata=%h", $time, m_wdata);
      if (m_wlast === 1'b1) begin
        $display("[At %t] [%m] [M_AXI WRITE DATA LAST!]", $time);
      end
    end
  end
`endif
endmodule

