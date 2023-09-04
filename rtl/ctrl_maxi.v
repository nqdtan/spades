
`timescale 1ns/1ps
`include "socket_config.vh"

module ctrl_maxi #(
  parameter AXI_AWIDTH = 64,
  parameter AXI_DWIDTH = 512//256//64
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

  input         ctrl_maxi_rstart,
  input         ctrl_maxi_wstart,
  output        ctrl_maxi_rdone,
  output        ctrl_maxi_wdone,
  output [31:0] ctrl_maxi_rdata,
  input  [31:0] ctrl_maxi_wdata,
  input  [63:0] ctrl_maxi_socket_offset,
  output        ctrl_maxi_running,
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

  wire ctrl_maxi_wdone_pipe0;
  REGISTER_R_CE #(.N(1), .INIT(0)) ctrl_maxi_wdone_pipe0_reg (
    .clk(clk),
    .rst(~resetn | ctrl_maxi_wdone_pipe0),
    .ce(state_w_done & m0_bfire),
    .d(1'b1),
    .q(ctrl_maxi_wdone_pipe0)
  );

  wire ctrl_maxi_wdone_pipe1;
  REGISTER #(.N(1)) ctrl_maxi_wdone_pipe1_reg (
    .clk(clk),
    .d(ctrl_maxi_wdone_pipe0),
    .q(ctrl_maxi_wdone_pipe1)
  );

  wire ctrl_maxi_rdone_pipe0;
  REGISTER_R_CE #(.N(1), .INIT(0)) ctrl_maxi_rdone_reg (
    .clk(clk),
    .rst(~resetn | ctrl_maxi_rdone_pipe0),
    .ce(state_r_done),
    .d(1'b1),
    .q(ctrl_maxi_rdone_pipe0)
  );

  wire ctrl_maxi_rdone_pipe1;
  REGISTER #(.N(1)) ctrl_maxi_rdone_pipe1_reg (
    .clk(clk),
    .d(ctrl_maxi_rdone_pipe0),
    .q(ctrl_maxi_rdone_pipe1)
  );

  always @(*) begin
    state_w_next = state_w_value;
    case (state_w_value)
      STATE_W_IDLE: begin
        if (ctrl_maxi_wstart)
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
        if (ctrl_maxi_rstart)
          state_r_next = STATE_R_REQ;
      end

      STATE_R_REQ: begin
        if (m0_arfire)
          state_r_next = STATE_R_DATA;
      end

      STATE_R_DATA: begin
        if (m0_rfire & m0_rlast)
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

  assign m0_awaddr  = 64'h0000_0000_0000_0000 + ctrl_maxi_socket_offset;
  assign m0_awvalid = state_w_req;
  assign m0_awlen   = 1 - 1;
  assign m0_awsize  = LOG2_BYTE_SIZE;
  assign m0_awburst = `BURST_INCR;

  assign m0_wdata   = ctrl_maxi_wdata;
  assign m0_wvalid  = state_w_data;
  assign m0_wstrb   = 64'hFFFF_FFFF_FFFF_FFFF;//32'hFFFF_FFFF;//8'hFF;//16'hFFFF;
  assign m0_wlast   = state_w_data;
  assign m0_bready  = state_w_done;

  assign m0_araddr  = 64'h0000_0000_0000_0000 + ctrl_maxi_socket_offset;
  assign m0_arvalid = state_r_req;
  assign m0_arlen   = 1 - 1;
  assign m0_arsize  = LOG2_BYTE_SIZE;
  assign m0_arburst = `BURST_INCR;

  assign m0_rready  = state_r_data;

  assign ctrl_maxi_rdone = ctrl_maxi_rdone_pipe0 | ctrl_maxi_rdone_pipe1;
  assign ctrl_maxi_wdone = ctrl_maxi_wdone_pipe0 | ctrl_maxi_wdone_pipe1;

  wire [AXI_DWIDTH-1:0] m0_rdata_pipe;
  REGISTER_CE #(.N(AXI_DWIDTH)) m0_rdata_reg (
    .clk(clk),
    .ce(m0_rfire & m0_rlast),
    .d(m0_rdata),
    .q(m0_rdata_pipe)
  );
  assign ctrl_maxi_rdata   = m0_rdata_pipe[31:0];
  assign ctrl_maxi_running = (~state_w_idle) | (~state_r_idle);

endmodule
