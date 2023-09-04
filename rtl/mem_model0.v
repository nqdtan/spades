`include "axi_consts.vh"
`include "socket_config.vh"

module mem_model0 #(
  parameter AXI_AWIDTH  = 64,
  parameter AXI_DWIDTH  = 64,
  parameter DMEM_AWIDTH = 20, // 1 MB
  parameter DMEM_DWIDTH = 64
) (
  input clk,
  input resetn, // active-low reset

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

  output [DMEM_AWIDTH-1:0] dmem_addr0,
  input  [DMEM_DWIDTH-1:0] dmem_dout0,
  output [DMEM_DWIDTH-1:0] dmem_din0,
  output dmem_en0,
  output dmem_we0,

  output [DMEM_AWIDTH-1:0] dmem_addr1,
  input  [DMEM_DWIDTH-1:0] dmem_dout1,
  output [DMEM_DWIDTH-1:0] dmem_din1,
  output dmem_en1,
  output dmem_we1
);

  localparam BYTE_SIZE      = AXI_DWIDTH / 8;
  localparam LOG2_BYTE_SIZE = $clog2(BYTE_SIZE);
  localparam FIFO_LOGDEPTH = 3;

  wire [DMEM_AWIDTH-1:0] dmem_addr0;
  wire [DMEM_DWIDTH-1:0] dmem_dout0, dmem_din0;
  wire                   dmem_en0, dmem_we0;
  wire [DMEM_AWIDTH-1:0] dmem_addr1;
  wire [DMEM_DWIDTH-1:0] dmem_dout1, dmem_din1;
  wire                   dmem_en1, dmem_we1;

//  SYNC_RAM_DP #(
//    .AWIDTH(DMEM_AWIDTH),
//    .DWIDTH(DMEM_DWIDTH)
//  ) buffer (
//    .clk(clk),
//
//    // for read
//    .addr0(dmem_addr0),
//    .d0(dmem_din0),
//    .q0(dmem_dout0),
//    .we0(dmem_we0),
//    .en0(dmem_en0),
//
//    // for write
//    .addr1(dmem_addr1),
//    .d1(dmem_din1),
//    .q1(dmem_dout1),
//    .we1(dmem_we1),
//    .en1(dmem_en1)
//  );

  localparam STATE_W_IDLE = 0;
  localparam STATE_W_DATA = 1;
  localparam STATE_W_RESP = 2;
  localparam STATE_W_DONE = 3;

  wire [1:0] state_w_value;
  reg  [1:0] state_w_next;

  REGISTER_R #(.N(2), .INIT(STATE_W_IDLE)) state_w_reg (
    .clk(clk),
    .d(state_w_next),
    .q(state_w_value),
    .rst(~resetn)
  );

  localparam STATE_R_IDLE     = 0;
  localparam STATE_R_DATA_DLY = 1;
  localparam STATE_R_DATA     = 2;
  localparam STATE_R_DONE     = 3;

  wire [1:0] state_r_value;
  reg  [1:0] state_r_next;

  REGISTER_R #(.N(2), .INIT(STATE_R_IDLE)) state_r_reg (
    .clk(clk),
    .d(state_r_next),
    .q(state_r_value),
    .rst(~resetn)
  );

  wire [63:0] rbeat_cnt_value, rbeat_cnt_next;
  wire rbeat_cnt_ce, rbeat_cnt_rst;

  REGISTER_R_CE #(.N(64), .INIT(0)) rbeat_cnt_reg (
    .clk(clk),
    .d(rbeat_cnt_next),
    .q(rbeat_cnt_value),
    .ce(rbeat_cnt_ce),
    .rst(rbeat_cnt_rst)
  );

  wire [63:0] wbeat_cnt_value, wbeat_cnt_next;
  wire wbeat_cnt_ce, wbeat_cnt_rst;

  REGISTER_R_CE #(.N(64), .INIT(0)) wbeat_cnt_reg (
    .clk(clk),
    .d(wbeat_cnt_next),
    .q(wbeat_cnt_value),
    .ce(wbeat_cnt_ce),
    .rst(wbeat_cnt_rst)
  );

  wire [AXI_AWIDTH-1:0] raddr_next, raddr_value;
  wire raddr_ce, raddr_rst;

  REGISTER_R_CE #(.N(AXI_AWIDTH), .INIT(0)) raddr_reg (
    .clk(clk),
    .d(raddr_next),
    .q(raddr_value),
    .ce(raddr_ce),
    .rst(raddr_rst)
  );
 
  wire [AXI_AWIDTH-1:0] waddr_next, waddr_value;
  wire waddr_ce, waddr_rst;

  REGISTER_R_CE #(.N(AXI_AWIDTH), .INIT(0)) waddr_reg (
    .clk(clk),
    .d(waddr_next),
    .q(waddr_value),
    .ce(waddr_ce),
    .rst(waddr_rst)
  );

  wire [63:0] rlen_next, rlen_value;
  wire rlen_ce, rlen_rst;

  REGISTER_R_CE #(.N(64), .INIT(0)) rlen_reg (
    .clk(clk),
    .d(rlen_next),
    .q(rlen_value),
    .ce(rlen_ce),
    .rst(rlen_rst)
  );

  wire [63:0] wlen_next, wlen_value;
  wire wlen_ce, wlen_rst;

  REGISTER_R_CE #(.N(64), .INIT(0)) wlen_reg (
    .clk(clk),
    .d(wlen_next),
    .q(wlen_value),
    .ce(wlen_ce),
    .rst(wlen_rst)
  );

  wire [AXI_AWIDTH-1:0] ff_raddr_enq_data, ff_raddr_deq_data;
  wire ff_raddr_enq_valid, ff_raddr_enq_ready;
  wire ff_raddr_deq_valid, ff_raddr_deq_ready;

  fifo #(
    .WIDTH(AXI_AWIDTH),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_raddr (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_raddr_enq_data),
    .enq_valid(ff_raddr_enq_valid),
    .enq_ready(ff_raddr_enq_ready),

    .deq_data(ff_raddr_deq_data),
    .deq_valid(ff_raddr_deq_valid),
    .deq_ready(ff_raddr_deq_ready)
  );

  wire [AXI_AWIDTH-1:0] ff_waddr_enq_data, ff_waddr_deq_data;
  wire ff_waddr_enq_valid, ff_waddr_enq_ready;
  wire ff_waddr_deq_valid, ff_waddr_deq_ready;

  fifo #(
    .WIDTH(AXI_AWIDTH),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_waddr (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_waddr_enq_data),
    .enq_valid(ff_waddr_enq_valid),
    .enq_ready(ff_waddr_enq_ready),

    .deq_data(ff_waddr_deq_data),
    .deq_valid(ff_waddr_deq_valid),
    .deq_ready(ff_waddr_deq_ready)
  );

  wire [7:0] ff_rlen_enq_data, ff_rlen_deq_data;
  wire ff_rlen_enq_valid, ff_rlen_enq_ready;
  wire ff_rlen_deq_valid, ff_rlen_deq_ready;

  fifo #(
    .WIDTH(8),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_rlen (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_rlen_enq_data),
    .enq_valid(ff_rlen_enq_valid),
    .enq_ready(ff_rlen_enq_ready),

    .deq_data(ff_rlen_deq_data),
    .deq_valid(ff_rlen_deq_valid),
    .deq_ready(ff_rlen_deq_ready)
  );

  wire [7:0] ff_wlen_enq_data, ff_wlen_deq_data;
  wire ff_wlen_enq_valid, ff_wlen_enq_ready;
  wire ff_wlen_deq_valid, ff_wlen_deq_ready;

  fifo #(
    .WIDTH(8),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_wlen (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_wlen_enq_data),
    .enq_valid(ff_wlen_enq_valid),
    .enq_ready(ff_wlen_enq_ready),

    .deq_data(ff_wlen_deq_data),
    .deq_valid(ff_wlen_deq_valid),
    .deq_ready(ff_wlen_deq_ready)
  );

  wire [2:0] ff_rsize_enq_data, ff_rsize_deq_data;
  wire ff_rsize_enq_valid, ff_rsize_enq_ready;
  wire ff_rsize_deq_valid, ff_rsize_deq_ready;

  fifo #(
    .WIDTH(3),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_rsize (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_rsize_enq_data),
    .enq_valid(ff_rsize_enq_valid),
    .enq_ready(ff_rsize_enq_ready),

    .deq_data(ff_rsize_deq_data),
    .deq_valid(ff_rsize_deq_valid),
    .deq_ready(ff_rsize_deq_ready)
  );

  wire [2:0] ff_wsize_enq_data, ff_wsize_deq_data;
  wire ff_wsize_enq_valid, ff_wsize_enq_ready;
  wire ff_wsize_deq_valid, ff_wsize_deq_ready;

  fifo #(
    .WIDTH(3),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_wsize (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_wsize_enq_data),
    .enq_valid(ff_wsize_enq_valid),
    .enq_ready(ff_wsize_enq_ready),

    .deq_data(ff_wsize_deq_data),
    .deq_valid(ff_wsize_deq_valid),
    .deq_ready(ff_wsize_deq_ready)
  );

  wire [1:0] ff_rburst_enq_data, ff_rburst_deq_data;
  wire ff_rburst_enq_valid, ff_rburst_enq_ready;
  wire ff_rburst_deq_valid, ff_rburst_deq_ready;

  fifo #(
    .WIDTH(2),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_rburst (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_rburst_enq_data),
    .enq_valid(ff_rburst_enq_valid),
    .enq_ready(ff_rburst_enq_ready),

    .deq_data(ff_rburst_deq_data),
    .deq_valid(ff_rburst_deq_valid),
    .deq_ready(ff_rburst_deq_ready)
  );

  wire [1:0] ff_wburst_enq_data, ff_wburst_deq_data;
  wire ff_wburst_enq_valid, ff_wburst_enq_ready;
  wire ff_wburst_deq_valid, ff_wburst_deq_ready;

  fifo #(
    .WIDTH(2),
    .LOGDEPTH(FIFO_LOGDEPTH)
  ) ff_wburst (
    .clk(clk),
    .rst(~resetn),

    .enq_data(ff_wburst_enq_data),
    .enq_valid(ff_wburst_enq_valid),
    .enq_ready(ff_wburst_enq_ready),

    .deq_data(ff_wburst_deq_data),
    .deq_valid(ff_wburst_deq_valid),
    .deq_ready(ff_wburst_deq_ready)
  );

  wire s_arfire = s_arvalid & s_arready;
  wire s_rfire  = s_rvalid  & s_rready;
  wire s_awfire = s_awvalid & s_awready;
  wire s_wfire  = s_wvalid  & s_wready;
  wire s_bfire  = s_bvalid  & s_bready;

  wire ff_raddr_enq_fire  = ff_raddr_enq_valid  & ff_raddr_enq_ready;
  wire ff_rlen_enq_fire   = ff_rlen_enq_valid   & ff_rlen_enq_ready;
  wire ff_rsize_enq_fire  = ff_rsize_enq_valid  & ff_rsize_enq_ready;
  wire ff_rburst_enq_fire = ff_rburst_enq_valid & ff_rburst_enq_ready;
  wire ff_waddr_enq_fire  = ff_waddr_enq_valid  & ff_waddr_enq_ready;
  wire ff_wlen_enq_fire   = ff_wlen_enq_valid   & ff_wlen_enq_ready;
  wire ff_wsize_enq_fire  = ff_wsize_enq_valid  & ff_wsize_enq_ready;
  wire ff_wburst_enq_fire = ff_wburst_enq_valid & ff_wburst_enq_ready;

  wire ff_raddr_deq_fire  = ff_raddr_deq_valid  & ff_raddr_deq_ready;
  wire ff_rlen_deq_fire   = ff_rlen_deq_valid   & ff_rlen_deq_ready;
  wire ff_rsize_deq_fire  = ff_rsize_deq_valid  & ff_rsize_deq_ready;
  wire ff_rburst_deq_fire = ff_rburst_deq_valid & ff_rburst_deq_ready;
  wire ff_waddr_deq_fire  = ff_waddr_deq_valid  & ff_waddr_deq_ready;
  wire ff_wlen_deq_fire   = ff_wlen_deq_valid   & ff_wlen_deq_ready;
  wire ff_wsize_deq_fire  = ff_wsize_deq_valid  & ff_wsize_deq_ready;
  wire ff_wburst_deq_fire = ff_wburst_deq_valid & ff_wburst_deq_ready;

  always @(*) begin
    state_r_next = state_r_value;
    case (state_r_value)
      STATE_R_IDLE: begin
        if (ff_raddr_deq_fire)
          state_r_next = STATE_R_DATA_DLY;
      end

      STATE_R_DATA_DLY: begin
        state_r_next = STATE_R_DATA;
      end

      STATE_R_DATA: begin
        if (s_rlast && s_rfire)
          state_r_next = STATE_R_DONE;
      end

      STATE_R_DONE: begin
        state_r_next = STATE_R_IDLE;
      end
    endcase
  end

  always @(*) begin
    state_w_next = state_w_value;
    case (state_w_value)
      STATE_W_IDLE: begin
        if (ff_waddr_deq_fire)
          state_w_next = STATE_W_DATA;
      end

      STATE_W_DATA: begin
        if (s_wlast && s_wfire)
          state_w_next = STATE_W_RESP;
      end

      STATE_W_RESP: begin
        if (s_bfire)
          state_w_next = STATE_W_DONE;
      end

      STATE_W_DONE: begin
        state_w_next = STATE_W_IDLE;
      end
    endcase
  end

  wire st_w_idle     = (state_w_value == STATE_W_IDLE);
  wire st_w_data     = (state_w_value == STATE_W_DATA);
  wire st_w_resp     = (state_w_value == STATE_W_RESP);
  wire st_w_done     = (state_w_value == STATE_W_DONE);

  wire st_r_idle     = (state_r_value == STATE_R_IDLE);
  wire st_r_data_dly = (state_r_value == STATE_R_DATA_DLY);
  wire st_r_data     = (state_r_value == STATE_R_DATA);
  wire st_r_done     = (state_r_value == STATE_R_DONE);

  assign s_arready = ff_raddr_enq_ready;
  assign s_awready = ff_waddr_enq_ready;

  assign ff_raddr_enq_data  = s_araddr;
  assign ff_raddr_enq_valid = s_arvalid;

  assign ff_rlen_enq_data    = s_arlen;
  assign ff_rlen_enq_valid   = s_arvalid;

  assign ff_rsize_enq_data   = s_arsize;
  assign ff_rsize_enq_valid  = s_arvalid;

  assign ff_rburst_enq_data  = s_arburst;
  assign ff_rburst_enq_valid = s_arvalid;

  assign ff_waddr_enq_data  = s_awaddr;
  assign ff_waddr_enq_valid = s_awvalid;

  assign ff_wlen_enq_data    = s_awlen;
  assign ff_wlen_enq_valid   = s_awvalid;

  assign ff_wsize_enq_data   = s_awsize;
  assign ff_wsize_enq_valid  = s_awvalid;

  assign ff_wburst_enq_data  = s_awburst;
  assign ff_wburst_enq_valid = s_awvalid;

  assign ff_raddr_deq_ready  = st_r_idle;
  assign ff_rlen_deq_ready   = st_r_idle;
  assign ff_rsize_deq_ready  = st_r_idle;
  assign ff_rburst_deq_ready = st_r_idle;

  assign ff_waddr_deq_ready  = st_w_idle;
  assign ff_wlen_deq_ready   = st_w_idle;
  assign ff_wsize_deq_ready  = st_w_idle;
  assign ff_wburst_deq_ready = st_w_idle;

  assign raddr_next = {ff_raddr_deq_data >> LOG2_BYTE_SIZE};
  assign raddr_ce   = ff_raddr_deq_fire;
  assign raddr_rst  = ~resetn;

  assign waddr_next = {ff_waddr_deq_data >> LOG2_BYTE_SIZE};
  assign waddr_ce   = ff_waddr_deq_fire;
  assign waddr_rst  = ~resetn;

  assign rlen_next = ff_rlen_deq_data + 1;
  assign rlen_ce   = ff_rlen_deq_fire;
  assign rlen_rst  = ~resetn;

  assign wlen_next = ff_wlen_deq_data + 1;
  assign wlen_ce   = ff_wlen_deq_fire;
  assign wlen_rst  = ~resetn;

  assign rbeat_cnt_next = rbeat_cnt_value + 1;
  assign rbeat_cnt_ce   = (st_r_data_dly) | (st_r_data & s_rfire);
  assign rbeat_cnt_rst  = ~resetn | st_r_done;

  assign wbeat_cnt_next = wbeat_cnt_value + 1;
  assign wbeat_cnt_ce   = st_w_data & s_wfire;
  assign wbeat_cnt_rst  = ~resetn | st_w_done;

  wire [DMEM_AWIDTH-1:0] raddr = raddr_value + rbeat_cnt_value;
  wire [DMEM_AWIDTH-1:0] waddr = waddr_value + wbeat_cnt_value;

  assign dmem_addr0 = raddr;
  assign dmem_din0  = 0;
  assign dmem_we0   = 1'b0;
  assign dmem_en0   = (st_r_data_dly) | (st_r_data & s_rfire);

  assign dmem_addr1 = waddr;
  assign dmem_din1  = s_wdata;
  assign dmem_we1   = st_w_data & s_wfire;
  assign dmem_en1   = st_w_data & s_wfire;

  assign s_rdata  = dmem_dout0;
  assign s_rlast  = (rbeat_cnt_value == rlen_value);

  assign s_wready = st_w_data;
  assign s_bvalid = st_w_resp;

  assign s_rvalid  = st_r_data;

  assign s_bresp = `RESP_OKAY;
  assign s_rresp = `RESP_OKAY;


endmodule
