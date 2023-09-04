
`timescale 1ns/1ps
`include "socket_config.vh"

module socket_manager #(
  parameter AXI_AWIDTH = 64,
  parameter AXI_DWIDTH = 256
) (

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

  // AXI bus interface
  // Read address channel
  input [3:0]              s_arid,
  input [AXI_AWIDTH-1:0]   s_araddr,
  input                    s_arvalid,
  output                   s_arready,
  input [7:0]              s_arlen,
  input [2:0]              s_arsize,
  input [1:0]              s_arburst,
  // lock, cache, prot, qos, region, user (unused)

  // Read data channel
  output  [3:0]            s_rid,
  output  [AXI_DWIDTH-1:0] s_rdata,
  output                   s_rvalid,
  input                    s_rready,
  output                   s_rlast,
  output  [1:0]            s_rresp,
  // user (unused)

  // Write address channel
  input [3:0]            s_awid,
  input [AXI_AWIDTH-1:0] s_awaddr,
  input                  s_awvalid,
  output                 s_awready,
  input [7:0]            s_awlen,
  input [2:0]            s_awsize,
  input [1:0]            s_awburst,
  // lock, cache, prot, qos, region, user (unused)

  // Write data channel
  input [3:0]              s_wid,
  input [AXI_DWIDTH-1:0]   s_wdata,
  input                    s_wvalid,
  output                   s_wready,
  input                    s_wlast,
  input [AXI_DWIDTH/8-1:0] s_wstrb,
  // user (unused)

  // Write response channel
  output [3:0] s_bid,
  output [1:0] s_bresp,
  output       s_bvalid,
  input        s_bready,
  // user (unused)

  // AXI-Lite slave interface (for control)
  input [31:0]  s_axi_control_awaddr,
  input         s_axi_control_awvalid,
  output        s_axi_control_awready,
  input [31:0]  s_axi_control_wdata,
  input         s_axi_control_wvalid,
  output        s_axi_control_wready,
  input [3:0]   s_axi_control_wstrb,
  output [1:0]  s_axi_control_bresp,
  output        s_axi_control_bvalid,
  input         s_axi_control_bready,
  input [31:0]  s_axi_control_araddr,
  input         s_axi_control_arvalid,
  output        s_axi_control_arready,
  output [31:0] s_axi_control_rdata,
  output        s_axi_control_rvalid,
  input         s_axi_control_rready,
  output [1:0]  s_axi_control_rresp,

  output mbufgce_ce,

  output mbufgce0_clr_n,
  output mbufgce1_clr_n,
  output mbufgce2_clr_n,
  output mbufgce3_clr_n,
  output mbufgce4_clr_n,
  output mbufgce5_clr_n,
  output mbufgce6_clr_n,
  output mbufgce7_clr_n,
  output mbufgce8_clr_n,
  output mbufgce9_clr_n,
  output mbufgce10_clr_n,
  output mbufgce11_clr_n,

  input clk,
  input resetn
);

  wire m0_awfire = m0_awvalid & m0_awready;
  wire m0_wfire  = m0_wvalid  & m0_wready;
  wire m0_arfire = m0_arvalid & m0_arready;
  wire m0_rfire  = m0_rvalid  & m0_rready;
  wire m0_bfire  = m0_bvalid  & m0_bready;

  // start sockets one-by-one by specifying the offset (socket address)
  // an FSM queries the status of a socket (check 'done')
  localparam LOG2_BYTE_SIZE = $clog2(AXI_DWIDTH / 8); 

  wire [31:0] socket_status;

  s_axi_bus #(
    .AXI_AWIDTH(AXI_AWIDTH),
    .AXI_DWIDTH(AXI_DWIDTH)
  ) s_axi_bus (
    .clk(clk),
    .resetn(resetn),

    .s_arid(s_arid),
    .s_araddr(s_araddr),
    .s_arvalid(s_arvalid),
    .s_arready(s_arready),
    .s_arlen(s_arlen),
    .s_arsize(s_arsize),
    .s_arburst(s_arburst),

    .s_rid(s_rid),
    .s_rdata(s_rdata),
    .s_rvalid(s_rvalid),
    .s_rready(s_rready),
    .s_rlast(s_rlast),
    .s_rresp(s_rresp),

    .s_awid(s_awid),
    .s_awaddr(s_awaddr),
    .s_awvalid(s_awvalid),
    .s_awready(s_awready),
    .s_awlen(s_awlen),
    .s_awsize(s_awsize),
    .s_awburst(s_awburst),

    .s_wid(s_wid),
    .s_wdata(s_wdata),
    .s_wvalid(s_wvalid),
    .s_wready(s_wready),
    .s_wlast(s_wlast),
    .s_wstrb(s_wstrb),

    .s_bid(s_bid),
    .s_bresp(s_bresp),
    .s_bvalid(s_bvalid),
    .s_bready(s_bready),

    .socket_status(socket_status)
  );

  wire [63:0] socket_offset;
  wire socket_write_commit;
  wire socket_read_commit;
  wire [31:0] socket_wdata;
  wire [31:0] socket_wr_idle;
  wire [31:0] socket_rd_idle;

  control control (
    .clk(clk),
    .resetn(resetn),

    .mbufgce_ce(mbufgce_ce),

    .mbufgce0_clr_n(mbufgce0_clr_n),
    .mbufgce1_clr_n(mbufgce1_clr_n),
    .mbufgce2_clr_n(mbufgce2_clr_n),
    .mbufgce3_clr_n(mbufgce3_clr_n),
    .mbufgce4_clr_n(mbufgce4_clr_n),
    .mbufgce5_clr_n(mbufgce5_clr_n),
    .mbufgce6_clr_n(mbufgce6_clr_n),
    .mbufgce7_clr_n(mbufgce7_clr_n),
    .mbufgce8_clr_n(mbufgce8_clr_n),
    .mbufgce9_clr_n(mbufgce9_clr_n),
    .mbufgce10_clr_n(mbufgce10_clr_n),
    .mbufgce11_clr_n(mbufgce11_clr_n),

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
    .s_axi_control_bready(s_axi_control_bready),

    .socket_wr_idle(socket_wr_idle),
    .socket_rd_idle(socket_rd_idle),
    .socket_offset(socket_offset),
    .socket_write_commit(socket_write_commit),
    .socket_read_commit(socket_read_commit),
    .socket_wdata(socket_wdata),
    .socket_rdata(m0_rdata[31:0]),
    .socket_rfire(m0_rfire),
    .socket_wfire(m0_wfire),

    .socket_status(socket_status)
  );

  localparam STATE_W_IDLE = 0;
  localparam STATE_W_REQ  = 1;
  localparam STATE_W_DATA = 2;
  localparam STATE_W_DONE = 3;

  wire [1:0] state_w_value;
  reg  [1:0] state_w_next;
  REGISTER_R #(.N(2), .INIT(STATE_W_IDLE)) state_w_reg (
    .clk(clk),
    .rst(~resetn),
    .d(state_w_next),
    .q(state_w_value)
  );

  localparam STATE_R_IDLE = 0;
  localparam STATE_R_REQ  = 1;
  localparam STATE_R_DATA = 2;
  localparam STATE_R_DONE = 3;

  wire [1:0] state_r_value;
  reg  [1:0] state_r_next;
  REGISTER_R #(.N(2), .INIT(STATE_R_IDLE)) state_r_reg (
    .clk(clk),
    .rst(~resetn),
    .d(state_r_next),
    .q(state_r_value)
  );

  wire state_w_idle = (state_w_value == STATE_W_IDLE);
  wire state_w_req  = (state_w_value == STATE_W_REQ);
  wire state_w_data = (state_w_value == STATE_W_DATA);
  wire state_w_done = (state_w_value == STATE_W_DONE);

  wire state_r_idle = (state_r_value == STATE_R_IDLE);
  wire state_r_req  = (state_r_value == STATE_R_REQ);
  wire state_r_data = (state_r_value == STATE_R_DATA);
  wire state_r_done = (state_r_value == STATE_R_DONE);

  always @(*) begin
    state_w_next = state_w_value;
    case (state_w_value)
      STATE_W_IDLE: begin
        if (socket_write_commit)
          state_w_next = STATE_W_REQ;
      end

      STATE_W_REQ: begin
        if (m0_awfire)
          state_w_next = STATE_W_DATA;
      end

      STATE_W_DATA: begin
        if (m0_wfire)
          state_w_next = STATE_W_DONE;
      end

      STATE_W_DONE: begin
        if (m0_bfire)
          state_w_next = STATE_W_IDLE;
      end
    endcase
  end

  always @(*) begin
    state_r_next = state_r_value;
    case (state_r_value)
      STATE_R_IDLE: begin
        if (socket_read_commit)
          state_r_next = STATE_R_REQ;
      end

      STATE_R_REQ: begin
        if (m0_arfire)
          state_r_next = STATE_R_DATA;
      end

      STATE_R_DATA: begin
        if (m0_rfire)
          state_r_next = STATE_R_DONE;
      end

      STATE_R_DONE: begin
        state_r_next = STATE_R_IDLE;
      end
    endcase
  end

  assign m0_awid = 0;
  assign m0_wid  = 0;
  assign m0_arid = 0;

  assign m0_awaddr  = 64'h0000_0201_0000_0000 + socket_offset;
  assign m0_awvalid = state_w_req;
  assign m0_awlen   = 1 - 1;
  assign m0_awsize  = LOG2_BYTE_SIZE;
  assign m0_awburst = `BURST_INCR;

  assign m0_wdata   = socket_wdata;
  assign m0_wvalid  = state_w_data;
  assign m0_wstrb   = 32'hFFFFFFFF;//8'hFF;//16'hFFFF;
  assign m0_wlast   = state_w_data;
  assign m0_bready  = state_w_done;

  assign m0_araddr  = 64'h0000_0201_0000_0000 + socket_offset;

  assign m0_arvalid = state_r_req;
  assign m0_arlen   = 1 - 1;
  assign m0_arsize  = LOG2_BYTE_SIZE;
  assign m0_arburst = `BURST_INCR;

  assign m0_rready  = state_r_data;

  assign socket_wr_idle = state_w_value;
  assign socket_rd_idle = state_r_value;

//`ifdef DEBUG
//  always @(posedge clk) begin
//    if (m0_arfire === 1'b1) begin
//      $display("[At %t] [%m] [M_AXI READ REQ] m0_araddr=%h, m0_arlen=%h, m0_arsize=%h", $time, m0_araddr, m0_arlen, m0_arsize);
//    end
//    if (m0_rfire === 1'b1) begin
//      $display("[At %t] [%m] [M_AXI READ DATA] m0_rdata=%h", $time, m0_rdata);
//      if (m0_rlast === 1'b1) begin
//        $display("[At %t] [%m] [M_AXI READ DATA LAST!]", $time);
//      end
//    end
//    if (m0_awfire === 1'b1) begin
//      $display("[At %t] [%m] [M_AXI WRITE REQ] m0_awaddr=%h, m0_awlen=%h, m0_awsize=%h", $time, m0_awaddr, m0_awlen, m0_awsize);
//    end
//    if (m0_wfire === 1'b1) begin
//      $display("[At %t] [%m] [M_AXI WRITE DATA] m0_wdata=%h", $time, m0_wdata);
//      if (m0_wlast === 1'b1) begin
//        $display("[At %t] [%m] [M_AXI WRITE DATA LAST!]", $time);
//      end
//    end
//
//    wire s_arfire = s_arvalid & s_arready;
//    wire s_rfire  = s_rvalid  & s_rready;
//    wire s_awfire = s_awvalid & s_awready;
//    wire s_wfire  = s_wvalid  & s_wready;
//    always @(posedge clk) begin
//      // s_axi_adapter
//      if (s_arfire === 1'b1) begin
//        $display("[At %t] [%m] [S_AXI READ REQ] s_araddr=%h, s_arlen=%h, s_arsize=%h", $time, s_araddr, s_arlen, s_arsize);
//      end
//      if (s_rfire === 1'b1) begin
//        $display("[At %t] [%m] [S_AXI READ DATA] s_rdata=%h", $time, s_rdata);
//        if (s_rlast === 1'b1) begin
//          $display("[At %t] [%m] [S_AXI READ DATA LAST!]", $time);
//        end
//      end
//      if (s_awfire === 1'b1) begin
//        $display("[At %t] [%m] [S_AXI WRITE REQ] s_awaddr=%h, s_awlen=%h, s_awsize=%h", $time, s_awaddr, s_awlen, s_awsize);
//      end
//      if (s_wfire === 1'b1) begin
//        $display("[At %t] [%m] [S_AXI WRITE DATA] s_wdata=%h, s_wstrb=%h", $time, s_wdata, s_wstrb);
//        if (s_wlast === 1'b1) begin
//          $display("[At %t] [%m] [S_AXI WRITE DATA LAST!]", $time);
//        end
//      end
//    end
//
//    $display("[At %t] [%m] state_w=%h, state_r=%h, socket_offset=%h", $time, state_w_value, state_r_value, socket_offset);
//  end
//`endif

endmodule


module control (
  input [31:0]  s_axi_control_awaddr,
  input         s_axi_control_awvalid,
  output        s_axi_control_awready,
  input [31:0]  s_axi_control_wdata,
  input         s_axi_control_wvalid,
  output        s_axi_control_wready,
  input [3:0]   s_axi_control_wstrb,
  output [1:0]  s_axi_control_bresp,
  output        s_axi_control_bvalid,
  input         s_axi_control_bready,
  input [31:0]  s_axi_control_araddr,
  input         s_axi_control_arvalid,
  output        s_axi_control_arready,
  output [31:0] s_axi_control_rdata,
  output        s_axi_control_rvalid,
  input         s_axi_control_rready,
  output [1:0]  s_axi_control_rresp,
  output [63:0] socket_offset,
  output [31:0] socket_wdata,
  input [31:0] socket_rdata,
  input        socket_rfire,
  input        socket_wfire,

  input [31:0] socket_wr_idle,
  input [31:0] socket_rd_idle,

  input [31:0] socket_status,

  output socket_write_commit,
  output socket_read_commit,

  output mbufgce_ce,

  output mbufgce0_clr_n,
  output mbufgce1_clr_n,
  output mbufgce2_clr_n,
  output mbufgce3_clr_n,
  output mbufgce4_clr_n,
  output mbufgce5_clr_n,
  output mbufgce6_clr_n,
  output mbufgce7_clr_n,
  output mbufgce8_clr_n,
  output mbufgce9_clr_n,
  output mbufgce10_clr_n,
  output mbufgce11_clr_n,

  input clk,
  input resetn
);
  localparam ADDR_SOCKET_CSR       = 32'h0;
  localparam ADDR_SOCKET_OFFSET_LO = 32'h10;
  localparam ADDR_SOCKET_OFFSET_HI = 32'h14;
  localparam ADDR_SOCKET_WR_IDLE   = 32'h18;
  localparam ADDR_SOCKET_RDATA     = 32'h1c;
  localparam ADDR_SOCKET_WDATA     = 32'h20;
  localparam ADDR_SOCKET_RCNT      = 32'h24;
  localparam ADDR_SOCKET_WCNT      = 32'h28;
  localparam ADDR_SOCKET_RD_IDLE   = 32'h2c;

  localparam ADDR_MBUFGCE_CE  = 32'h30;
  localparam ADDR_MBUFGCE_CLR = 32'h34;

  localparam ADDR_SOCKET_QUEUE_ENQ = 32'h38; // enqueue socket offsets
  localparam ADDR_SOCKET_QUEUE_DEQ = 32'h3c; // dequeue all

  localparam ADDR_SOCKET_STATUS = 32'h40;

  wire [63:0] ff_socket_offset_enq_data, ff_socket_offset_deq_data;
  wire ff_socket_offset_enq_valid, ff_socket_offset_enq_ready;
  wire ff_socket_offset_deq_valid, ff_socket_offset_deq_ready;

  fifo #(
    .WIDTH(64),
    .LOGDEPTH(4)
  ) ff_socket_offset (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_socket_offset_enq_data),
    .enq_valid(ff_socket_offset_enq_valid),
    .enq_ready(ff_socket_offset_enq_ready),

    .deq_data(ff_socket_offset_deq_data),
    .deq_valid(ff_socket_offset_deq_valid),
    .deq_ready(ff_socket_offset_deq_ready)
  );

  wire [31:0] socket_offset_lo_next, socket_offset_lo_value;
  wire socket_offset_lo_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) socket_offset_lo_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(socket_offset_lo_ce),
    .d(socket_offset_lo_next),
    .q(socket_offset_lo_value)
  );

  wire [31:0] socket_offset_hi_next, socket_offset_hi_value;
  wire socket_offset_hi_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) socket_offset_hi_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(socket_offset_hi_ce),
    .d(socket_offset_hi_next),
    .q(socket_offset_hi_value)
  );

  wire [31:0] socket_wdata_next, socket_wdata_value;
  wire socket_wdata_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) socket_wdata_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(socket_wdata_ce),
    .d(socket_wdata_next),
    .q(socket_wdata_value)
  );

  wire [31:0] socket_rdata_next, socket_rdata_value;
  wire socket_rdata_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) socket_rdata_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(socket_rdata_ce),
    .d(socket_rdata_next),
    .q(socket_rdata_value)
  );

  wire [31:0] socket_rcnt_next, socket_rcnt_value;
  wire socket_rcnt_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) socket_rcnt_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(socket_rcnt_ce),
    .d(socket_rcnt_next),
    .q(socket_rcnt_value)
  );

  wire [31:0] socket_wcnt_next, socket_wcnt_value;
  wire socket_wcnt_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) socket_wcnt_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(socket_wcnt_ce),
    .d(socket_wcnt_next),
    .q(socket_wcnt_value)
  );

  wire [31:0] socket_status_next, socket_status_value;
  wire socket_status_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) socket_status_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(socket_status_ce),
    .d(socket_status_next),
    .q(socket_status_value)
  );

  wire [31:0] mbufgce_ce_next, mbufgce_ce_value;
  wire mbufgce_ce_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) mbufgce_ce_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(mbufgce_ce_ce),
    .d(mbufgce_ce_next),
    .q(mbufgce_ce_value)
  );

  wire [31:0] mbufgce_clr_next, mbufgce_clr_value;
  wire mbufgce_clr_ce;
  REGISTER_R_CE #(.N(32), .INIT(0)) mbufgce_clr_reg (
    .clk(clk),
    .rst(~resetn),
    .ce(mbufgce_clr_ce),
    .d(mbufgce_clr_next),
    .q(mbufgce_clr_value)
  );

  wire s_axi_control_awfire = s_axi_control_awvalid & s_axi_control_awready;
  wire s_axi_control_arfire = s_axi_control_arvalid & s_axi_control_arready;
  wire s_axi_control_wfire  = s_axi_control_wvalid & s_axi_control_wready;
  wire s_axi_control_rfire  = s_axi_control_rvalid & s_axi_control_rready;
  wire s_axi_control_bfire  = s_axi_control_bvalid & s_axi_control_bready;

  localparam STATE_W_CTRL_IDLE = 0;
  localparam STATE_W_CTRL_RUN  = 1;
  localparam STATE_W_CTRL_DONE = 2;

  localparam STATE_R_CTRL_IDLE = 0;
  localparam STATE_R_CTRL_RUN  = 1;
  localparam STATE_R_CTRL_DONE = 2;

  wire [1:0] state_w_value;
  reg  [1:0] state_w_next;

  REGISTER_R #(.N(2), .INIT(STATE_W_CTRL_IDLE)) state_w_reg (
    .clk(clk),
    .rst(~resetn),
    .d(state_w_next),
    .q(state_w_value)
  );

  wire [1:0] state_r_value;
  reg  [1:0] state_r_next;

  REGISTER_R #(.N(2), .INIT(STATE_R_CTRL_IDLE)) state_r_reg (
    .clk(clk),
    .rst(~resetn),
    .d(state_r_next),
    .q(state_r_value)
  );

  wire [31:0] waddr_pipe;
  REGISTER_CE #(.N(32)) waddr_pipe_reg (
    .clk(clk),
    .ce(s_axi_control_awfire),
    .d(s_axi_control_awaddr),
    .q(waddr_pipe)
  );

  wire [31:0] raddr_pipe;
  REGISTER_CE #(.N(32)) raddr_pipe_reg (
    .clk(clk),
    .ce(s_axi_control_arfire),
    .d(s_axi_control_araddr),
    .q(raddr_pipe)
  );

  wire st_w_ctrl_idle = (state_w_value == STATE_W_CTRL_IDLE);
  wire st_w_ctrl_run  = (state_w_value == STATE_W_CTRL_RUN);
  wire st_w_ctrl_done = (state_w_value == STATE_W_CTRL_DONE);
  wire st_r_ctrl_idle = (state_r_value == STATE_R_CTRL_IDLE);
  wire st_r_ctrl_run  = (state_r_value == STATE_R_CTRL_RUN);
  wire st_r_ctrl_done = (state_r_value == STATE_R_CTRL_DONE);

  always @(*) begin
    state_w_next = state_w_value;
    case (state_w_value)
      STATE_W_CTRL_IDLE: begin
        if (s_axi_control_awfire)
          state_w_next = STATE_W_CTRL_RUN;
      end

      STATE_W_CTRL_RUN: begin
        if (s_axi_control_wfire)
          state_w_next = STATE_W_CTRL_DONE;
      end

      STATE_W_CTRL_DONE: begin
        if (s_axi_control_bfire)
          state_w_next = STATE_W_CTRL_IDLE;
      end
    endcase
  end

  always @(*) begin
    state_r_next = state_r_value;
    case (state_r_value)
      STATE_R_CTRL_IDLE: begin
        if (s_axi_control_arfire)
          state_r_next = STATE_R_CTRL_RUN;
      end

      STATE_R_CTRL_RUN: begin
        if (s_axi_control_rfire)
          state_r_next = STATE_R_CTRL_DONE;
      end

      STATE_R_CTRL_DONE: begin
        state_r_next = STATE_R_CTRL_IDLE;
      end
    endcase
  end

  assign s_axi_control_awready = st_w_ctrl_idle;
  assign s_axi_control_wready  = st_w_ctrl_run;
  assign s_axi_control_bvalid  = st_w_ctrl_done;

  assign s_axi_control_arready = st_r_ctrl_idle;
  assign s_axi_control_rvalid  = st_r_ctrl_run;

  assign s_axi_control_rdata =
    (raddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_OFFSET_LO & {`MMIO_AW{1'b1}}))   ? socket_offset_lo_value :
    (raddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_OFFSET_HI & {`MMIO_AW{1'b1}}))   ? socket_offset_hi_value :
    (raddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_WR_IDLE & {`MMIO_AW{1'b1}}))     ? socket_wr_idle         :
    (raddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_RD_IDLE & {`MMIO_AW{1'b1}}))     ? socket_rd_idle         :
    (raddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_RDATA & {`MMIO_AW{1'b1}}))       ? socket_rdata_value     :
    (raddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_WDATA & {`MMIO_AW{1'b1}}))       ? socket_wdata_value     :
    (raddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_RCNT & {`MMIO_AW{1'b1}}))        ? socket_rcnt_value      :
    (raddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_WCNT & {`MMIO_AW{1'b1}}))        ? socket_wcnt_value      :
    (raddr_pipe[`MMIO_AW-1:0] == (ADDR_MBUFGCE_CE & {`MMIO_AW{1'b1}}))         ? mbufgce_ce_value       :
    (raddr_pipe[`MMIO_AW-1:0] == (ADDR_MBUFGCE_CLR & {`MMIO_AW{1'b1}}))        ? mbufgce_clr_value      :
    (raddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_STATUS & {`MMIO_AW{1'b1}}))      ? socket_status_value    : 0;

  wire socket_queue_enq = s_axi_control_wfire & (waddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_QUEUE_ENQ & {`MMIO_AW{1'b1}}));
  wire socket_queue_deq = s_axi_control_wfire & (waddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_QUEUE_DEQ & {`MMIO_AW{1'b1}}));
  wire socket_queue_deq_pipe;
  REGISTER_R_CE #(.N(1)) socket_queue_deq_pipe_reg (
    .clk(clk),
    .rst(~resetn | ~ff_socket_offset_deq_valid),
    .ce(socket_queue_deq),
    .d(1'b1),
    .q(socket_queue_deq_pipe)
  );
  wire [63:0] ff_socket_offset_deq_data_pipe;
  REGISTER_CE #(.N(64)) ff_socket_offset_deq_data_pipe_reg (
    .clk(clk),
    .ce(ff_socket_offset_deq_valid & ff_socket_offset_deq_ready),
    .d(ff_socket_offset_deq_data),
    .q(ff_socket_offset_deq_data_pipe)
  );

  assign ff_socket_offset_enq_data  = socket_offset;
  assign ff_socket_offset_enq_valid = socket_queue_enq;
  assign ff_socket_offset_deq_ready = (socket_wr_idle == 0) & socket_queue_deq_pipe;

  assign socket_read_commit  = s_axi_control_rfire & (raddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_CSR & {`MMIO_AW{1'b1}}));
  assign socket_write_commit = (s_axi_control_wfire & (waddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_CSR & {`MMIO_AW{1'b1}}))) |
                               (ff_socket_offset_deq_valid & ff_socket_offset_deq_ready);

  assign socket_offset_lo_next = s_axi_control_wdata;
  assign socket_offset_lo_ce   = s_axi_control_wfire & (waddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_OFFSET_LO & {`MMIO_AW{1'b1}}));
  assign socket_offset_hi_next = s_axi_control_wdata;
  assign socket_offset_hi_ce   = s_axi_control_wfire & (waddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_OFFSET_HI & {`MMIO_AW{1'b1}}));

  assign socket_wdata_next = s_axi_control_wdata;
  assign socket_wdata_ce   = s_axi_control_wfire & (waddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_WDATA & {`MMIO_AW{1'b1}}));

  wire socket_wcnt_s_axi_wr = s_axi_control_wfire & (waddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_WCNT & {`MMIO_AW{1'b1}}));
  assign socket_wcnt_next = (socket_wcnt_s_axi_wr) ? s_axi_control_wdata : (socket_wcnt_value + 1);
  assign socket_wcnt_ce   = socket_wcnt_s_axi_wr | socket_wfire;

  wire socket_rcnt_s_axi_wr = s_axi_control_wfire & (waddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_RCNT & {`MMIO_AW{1'b1}}));
  assign socket_rcnt_next = (socket_rcnt_s_axi_wr) ? s_axi_control_wdata : (socket_rcnt_value + 1);
  assign socket_rcnt_ce   = socket_rcnt_s_axi_wr | socket_rfire;

  assign socket_offset = socket_queue_deq_pipe ? ff_socket_offset_deq_data_pipe :
                                                 {socket_offset_hi_value, socket_offset_lo_value};

  assign socket_rdata_next = socket_rdata[31:0];
  assign socket_rdata_ce   = socket_rfire;

  assign socket_wdata = socket_wdata_value;

  wire socket_status_s_axi_wr = s_axi_control_wfire & (waddr_pipe[`MMIO_AW-1:0] == (ADDR_SOCKET_STATUS & {`MMIO_AW{1'b1}}));
  assign socket_status_next = (socket_status_s_axi_wr) ? s_axi_control_wdata : (socket_status_value | socket_status);
  assign socket_status_ce   = socket_status_s_axi_wr | (|socket_status);

//  always @(posedge clk) begin
//    $display("[%t] [%m] socket_status=%h, socket_status_value=%h",
//      $time, socket_status, socket_status_value);
//  end

  assign mbufgce_ce_next = s_axi_control_wdata;
  assign mbufgce_ce_ce   = s_axi_control_wfire & (waddr_pipe[`MMIO_AW-1:0] == (ADDR_MBUFGCE_CE & {`MMIO_AW{1'b1}}));

  assign mbufgce_clr_next = s_axi_control_wdata;
  assign mbufgce_clr_ce   = s_axi_control_wfire & (waddr_pipe[`MMIO_AW-1:0] == (ADDR_MBUFGCE_CLR & {`MMIO_AW{1'b1}}));

  wire mbufgce_ce_pipe;
  pipe_block #(
    .NUM_STAGES(4),
    .WIDTH(1)
  ) mbufgce_ce_pipe_block (
    .clk(clk),
    .d(mbufgce_ce_value[0]),
    .q(mbufgce_ce_pipe)
  );

  assign mbufgce_ce = mbufgce_ce_pipe;

  assign mbufgce0_clr_n = ~mbufgce_clr_value[0];
  assign mbufgce1_clr_n = ~mbufgce_clr_value[1];
  assign mbufgce2_clr_n = ~mbufgce_clr_value[2];
  assign mbufgce3_clr_n = ~mbufgce_clr_value[3];
  assign mbufgce4_clr_n = ~mbufgce_clr_value[4];
  assign mbufgce5_clr_n = ~mbufgce_clr_value[5];
  assign mbufgce6_clr_n = ~mbufgce_clr_value[6];
  assign mbufgce7_clr_n = ~mbufgce_clr_value[7];
  assign mbufgce8_clr_n = ~mbufgce_clr_value[8];
  assign mbufgce9_clr_n = ~mbufgce_clr_value[9];
  assign mbufgce10_clr_n = ~mbufgce_clr_value[10];
  assign mbufgce11_clr_n = ~mbufgce_clr_value[11];

endmodule

module s_axi_bus #(
  parameter AXI_AWIDTH = 64,
  parameter AXI_DWIDTH = 256,
  parameter DMEM_AWIDTH = 12,
  parameter DMEM_DWIDTH = 256,
  parameter NUM_SOCKETS = 16
) (
  // AXI bus interface
  // Read address channel
  input [3:0]              s_arid,
  input [AXI_AWIDTH-1:0]   s_araddr,
  input                    s_arvalid,
  output                   s_arready,
  input [7:0]              s_arlen,
  input [2:0]              s_arsize,
  input [1:0]              s_arburst,
  // lock, cache, prot, qos, region, user (unused)

  // Read data channel
  output  [3:0]            s_rid,
  output  [AXI_DWIDTH-1:0] s_rdata,
  output                   s_rvalid,
  input                    s_rready,
  output                   s_rlast,
  output  [1:0]            s_rresp,
  // user (unused)

  // Write address channel
  input [3:0]            s_awid,
  input [AXI_AWIDTH-1:0] s_awaddr,
  input                  s_awvalid,
  output                 s_awready,
  input [7:0]            s_awlen,
  input [2:0]            s_awsize,
  input [1:0]            s_awburst,
  // lock, cache, prot, qos, region, user (unused)

  // Write data channel
  input [3:0]              s_wid,
  input [AXI_DWIDTH-1:0]   s_wdata,
  input                    s_wvalid,
  output                   s_wready,
  input                    s_wlast,
  input [AXI_DWIDTH/8-1:0] s_wstrb,
  // user (unused)

  // Write response channel
  output [3:0] s_bid,
  output [1:0] s_bresp,
  output       s_bvalid,
  input        s_bready,
  // user (unused)

  output [31:0] socket_status,

  input clk,
  input resetn
);

  localparam SOCKET_MMIO_REG_SPACE = `SOCKET_MMIO_REG_SPACE;
  localparam SOCKET_STATUS_OFFSET  = 128;

  localparam BYTE_SIZE      = AXI_DWIDTH / 8;
  localparam LOG2_BYTE_SIZE = $clog2(BYTE_SIZE);

  localparam STATE_IDLE       = 0;
  localparam STATE_W_DATA     = 1;
  localparam STATE_W_RESP     = 2;
  localparam STATE_R_DATA     = 3;

  wire [2:0] state_value;
  reg  [2:0] state_next;

  REGISTER #(.N(3)) state_reg (
    .clk(clk),
    .d(state_next),
    .q(state_value)
  );

  wire [31:0] beat_cnt_value, beat_cnt_next;
  wire beat_cnt_ce, beat_cnt_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) beat_cnt_reg (
    .clk(clk),
    .d(beat_cnt_next),
    .q(beat_cnt_value),
    .ce(beat_cnt_ce),
    .rst(beat_cnt_rst)
  );

  wire [AXI_AWIDTH-1:0] addr_next, addr_value;
  wire addr_ce, addr_rst;

  REGISTER_R_CE #(.N(AXI_AWIDTH), .INIT(0)) addr_reg (
    .clk(clk),
    .d(addr_next),
    .q(addr_value),
    .ce(addr_ce),
    .rst(addr_rst)
  );
 
  wire [31:0] len_next, len_value;
  wire len_ce, len_rst;

  REGISTER_R_CE #(.N(32), .INIT(0)) len_reg (
    .clk(clk),
    .d(len_next),
    .q(len_value),
    .ce(len_ce),
    .rst(len_rst)
  );

  localparam FIFO_LOGDEPTH = 3;

  wire [AXI_AWIDTH-1:0] ff_addr_enq_data, ff_addr_deq_data;
  wire ff_addr_enq_valid, ff_addr_enq_ready;
  wire ff_addr_deq_valid, ff_addr_deq_ready;

  fifo #(
    .WIDTH(AXI_AWIDTH),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_addr (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_addr_enq_data),
    .enq_valid(ff_addr_enq_valid),
    .enq_ready(ff_addr_enq_ready),

    .deq_data(ff_addr_deq_data),
    .deq_valid(ff_addr_deq_valid),
    .deq_ready(ff_addr_deq_ready)
  );

  wire [7:0] ff_len_enq_data, ff_len_deq_data;
  wire ff_len_enq_valid, ff_len_enq_ready;
  wire ff_len_deq_valid, ff_len_deq_ready;

  fifo #(
    .WIDTH(8),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_len (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_len_enq_data),
    .enq_valid(ff_len_enq_valid),
    .enq_ready(ff_len_enq_ready),

    .deq_data(ff_len_deq_data),
    .deq_valid(ff_len_deq_valid),
    .deq_ready(ff_len_deq_ready)
  );

  wire [2:0] ff_size_enq_data, ff_size_deq_data;
  wire ff_size_enq_valid, ff_size_enq_ready;
  wire ff_size_deq_valid, ff_size_deq_ready;

  fifo #(
    .WIDTH(3),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_size (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_size_enq_data),
    .enq_valid(ff_size_enq_valid),
    .enq_ready(ff_size_enq_ready),

    .deq_data(ff_size_deq_data),
    .deq_valid(ff_size_deq_valid),
    .deq_ready(ff_size_deq_ready)
  );

  wire [1:0] ff_burst_enq_data, ff_burst_deq_data;
  wire ff_burst_enq_valid, ff_burst_enq_ready;
  wire ff_burst_deq_valid, ff_burst_deq_ready;

  fifo #(
    .WIDTH(2),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_burst (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_burst_enq_data),
    .enq_valid(ff_burst_enq_valid),
    .enq_ready(ff_burst_enq_ready),

    .deq_data(ff_burst_deq_data),
    .deq_valid(ff_burst_deq_valid),
    .deq_ready(ff_burst_deq_ready)
  );

  wire ff_wen_enq_data, ff_wen_deq_data;
  wire ff_wen_enq_valid, ff_wen_enq_ready;
  wire ff_wen_deq_valid, ff_wen_deq_ready;

  fifo #(
    .WIDTH(1),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_wen (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_wen_enq_data),
    .enq_valid(ff_wen_enq_valid),
    .enq_ready(ff_wen_enq_ready),

    .deq_data(ff_wen_deq_data),
    .deq_valid(ff_wen_deq_valid),
    .deq_ready(ff_wen_deq_ready)
  );

  wire s_arfire = s_arvalid & s_arready;
  wire s_rfire  = s_rvalid  & s_rready;
  wire s_awfire = s_awvalid & s_awready;
  wire s_wfire  = s_wvalid  & s_wready;
  wire s_bfire  = s_bvalid  & s_bready;

  wire ff_addr_enq_fire  = ff_addr_enq_valid  & ff_addr_enq_ready;
  wire ff_len_enq_fire   = ff_len_enq_valid   & ff_len_enq_ready;
  wire ff_size_enq_fire  = ff_size_enq_valid  & ff_size_enq_ready;
  wire ff_burst_enq_fire = ff_burst_enq_valid & ff_burst_enq_ready;
  wire ff_wen_enq_fire   = ff_wen_enq_valid   & ff_wen_enq_ready;

  wire ff_addr_deq_fire  = ff_addr_deq_valid  & ff_addr_deq_ready;
  wire ff_len_deq_fire   = ff_len_deq_valid   & ff_len_deq_ready;
  wire ff_size_deq_fire  = ff_size_deq_valid  & ff_size_deq_ready;
  wire ff_burst_deq_fire = ff_burst_deq_valid & ff_burst_deq_ready;
  wire ff_wen_deq_fire   = ff_wen_deq_valid   & ff_wen_deq_ready;

  always @(*) begin
    state_next = state_value;
    case (state_value)
      STATE_IDLE: begin
        if (ff_wen_deq_fire && ff_wen_deq_data)
          state_next = STATE_W_DATA;
        else if (ff_wen_deq_fire && ~ff_wen_deq_data)
          state_next = STATE_R_DATA;
      end

      STATE_W_DATA: begin
        if (s_wlast && s_wfire)
          state_next = STATE_W_RESP;
      end

      STATE_W_RESP: begin
        if (s_bfire)
          state_next = STATE_IDLE;
      end

      STATE_R_DATA: begin
        if (s_rlast && s_rfire)
          state_next = STATE_IDLE;
      end
    endcase
  end

  wire st_idle       = (state_value == STATE_IDLE);
  wire st_w_data     = (state_value == STATE_W_DATA);
  wire st_w_resp     = (state_value == STATE_W_RESP);
  wire st_r_data     = (state_value == STATE_R_DATA);

  assign ff_wen_enq_data  = s_awvalid ? 1'b1 : 1'b0;
  assign ff_wen_enq_valid = s_awvalid | s_arvalid;
  // Write is prioritized
  assign s_arready        = ~s_awvalid & ff_wen_enq_ready;
  assign s_awready        = ff_wen_enq_ready;

  assign ff_addr_enq_data  = s_awvalid ? s_awaddr : s_araddr;
  assign ff_addr_enq_valid = s_awvalid | s_arvalid;

  assign ff_len_enq_data    = s_awvalid ? s_awlen : s_arlen;
  assign ff_len_enq_valid   = s_awvalid | s_arvalid;

  assign ff_size_enq_data   = s_awvalid ? s_awsize : s_arsize;
  assign ff_size_enq_valid  = s_awvalid | s_arvalid;

  assign ff_burst_enq_data  = s_awvalid ? s_awburst : s_arburst;
  assign ff_burst_enq_valid = s_awvalid | s_arvalid;

  assign ff_wen_deq_ready   = st_idle;
  assign ff_addr_deq_ready  = st_idle;
  assign ff_len_deq_ready   = st_idle;
  assign ff_size_deq_ready  = st_idle;
  assign ff_burst_deq_ready = st_idle;

//  assign addr_next = {ff_addr_deq_data >> LOG2_BYTE_SIZE};
  assign addr_next = {ff_addr_deq_data >> 6};
  assign addr_ce   = ff_wen_deq_fire;
  assign addr_rst  = ~resetn;

  assign len_next = ff_len_deq_data + 1;
  assign len_ce   = ff_wen_deq_fire;
  assign len_rst  = ~resetn;

  assign beat_cnt_next = beat_cnt_value + 1;
  assign beat_cnt_ce   = (st_w_data & s_wfire) |
                         (st_r_data & s_rfire);
  assign beat_cnt_rst = st_idle;

  wire socket_status_read =
    addr_value[SOCKET_MMIO_REG_SPACE] &
   (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == SOCKET_STATUS_OFFSET) & s_rfire;

  assign socket_status[31:NUM_SOCKETS] = 1'b0;
  genvar i;
  generate
    for (i = 0; i < NUM_SOCKETS; i = i + 1) begin
      assign socket_status[i] =
        addr_value[SOCKET_MMIO_REG_SPACE] &
        (addr_value[SOCKET_MMIO_REG_SPACE-1:0] == SOCKET_STATUS_OFFSET + i) & st_w_data;
    end
  endgenerate

  assign s_rdata  = socket_status_read ? {32'h0, socket_status[31:0]} : 32'hFFFFFFFF;
  assign s_rvalid = st_r_data;

  assign s_rlast  = (beat_cnt_value == len_value - 1);
  assign s_wready = st_w_data;
  assign s_bvalid = st_w_resp;

  assign s_bresp = `RESP_OKAY;
  assign s_rresp = `RESP_OKAY;

  wire [31:0] write_mask = {{8{s_wstrb[3]}},
                            {8{s_wstrb[2]}},
                            {8{s_wstrb[1]}},
                            {8{s_wstrb[0]}}};

//  always @(posedge clk) begin
//    // s_axi_adapter
//    if (s_arfire === 1'b1) begin
//      $display("[At %t] [%m] [S_AXI READ REQ] s_araddr=%h, s_arlen=%h, s_arsize=%h", $time, s_araddr, s_arlen, s_arsize);
//    end
//    if (s_rfire === 1'b1) begin
//      $display("[At %t] [%m] [S_AXI READ DATA] s_rdata=%h", $time, s_rdata);
//      if (s_rlast === 1'b1) begin
//        $display("[At %t] [%m] [S_AXI READ DATA LAST!]", $time);
//      end
//    end
//    if (s_awfire === 1'b1) begin
//      $display("[At %t] [%m] [S_AXI WRITE REQ] s_awaddr=%h, s_awlen=%h, s_awsize=%h", $time, s_awaddr, s_awlen, s_awsize);
//    end
//    if (s_wfire === 1'b1) begin
//      $display("[At %t] [%m] [S_AXI WRITE DATA] s_wdata=%h, s_wstrb=%h", $time, s_wdata, s_wstrb);
//      if (s_wlast === 1'b1) begin
//        $display("[At %t] [%m] [S_AXI WRITE DATA LAST!]", $time);
//      end
//    end
//    //$display("[%t] [%m] state=%h, addr_value=%h [%b %h]", $time, state_value,
//    //  addr_value, addr_value[SOCKET_MMIO_REG_SPACE],
//    //  addr_value[SOCKET_MMIO_REG_SPACE-1:0]);
//  end

endmodule
