`include "socket_config.vh"

//(* DONT_TOUCH = "yes" *)
module rg_cl_cdc_intf #(
  parameter RAM_READ_LATENCY = 6
) (
  input socket_reset,
  input lsu0_dp_mode,
  input [31:0] lsu0_ram_start_idx,

  input  [2*12-1:0] lsu0_port0_addr,
  input  [2*64-1:0] lsu0_port0_d,
  output [2*64-1:0] lsu0_port0_q,
  input  [1:0]      lsu0_port0_ce,
  input             lsu0_port0_we,

  input  [2*12-1:0] lsu0_port1_addr,
  input  [2*64-1:0] lsu0_port1_d,
  output [2*64-1:0] lsu0_port1_q,
  input  [1:0]      lsu0_port1_ce,
  input             lsu0_port1_we,

  input  [2*12-1:0] lsu0_port2_addr,
  input  [2*64-1:0] lsu0_port2_d,
  output [2*64-1:0] lsu0_port2_q,
  input  [1:0]      lsu0_port2_ce,
  input             lsu0_port2_we,

  input  [2*12-1:0] lsu0_port3_addr,
  input  [2*64-1:0] lsu0_port3_d,
  output [2*64-1:0] lsu0_port3_q,
  input  [1:0]      lsu0_port3_ce,
  input             lsu0_port3_we,
  input [4:0] lsu0_ram_en,

`ifndef SOCKET_S
  input lsu1_dp_mode,
  input [31:0] lsu1_ram_start_idx,

  input  [2*12-1:0] lsu1_port0_addr,
  input  [2*64-1:0] lsu1_port0_d,
  output [2*64-1:0] lsu1_port0_q,
  input  [1:0]      lsu1_port0_ce,
  input             lsu1_port0_we,

  input  [2*12-1:0] lsu1_port1_addr,
  input  [2*64-1:0] lsu1_port1_d,
  output [2*64-1:0] lsu1_port1_q,
  input  [1:0]      lsu1_port1_ce,
  input             lsu1_port1_we,

  input  [2*12-1:0] lsu1_port2_addr,
  input  [2*64-1:0] lsu1_port2_d,
  output [2*64-1:0] lsu1_port2_q,
  input  [1:0]      lsu1_port2_ce,
  input             lsu1_port2_we,

  input  [2*12-1:0] lsu1_port3_addr,
  input  [2*64-1:0] lsu1_port3_d,
  output [2*64-1:0] lsu1_port3_q,
  input  [1:0]      lsu1_port3_ce,
  input             lsu1_port3_we,
  input [4:0] lsu1_ram_en,
`endif

  output        cl_done,
  input  [11:0] cl_ctrl_addr,
  input  [31:0] cl_ctrl_d,
  output [31:0] cl_ctrl_q,
  input         cl_ctrl_ce,
  input         cl_ctrl_we,

  // cdc
  output [12-1:0] lsu0_port0_addr_cdc,
  output [64-1:0] lsu0_port0_d_cdc,
  input  [64-1:0] lsu0_port0_q_cdc,
  output          lsu0_port0_ce_cdc,
  output          lsu0_port0_we_cdc,

  output [12-1:0] lsu0_port1_addr_cdc,
  output [64-1:0] lsu0_port1_d_cdc,
  input  [64-1:0] lsu0_port1_q_cdc,
  output          lsu0_port1_ce_cdc,
  output          lsu0_port1_we_cdc,

  output [12-1:0] lsu0_port2_addr_cdc,
  output [64-1:0] lsu0_port2_d_cdc,
  input  [64-1:0] lsu0_port2_q_cdc,
  output          lsu0_port2_ce_cdc,
  output          lsu0_port2_we_cdc,

  output [12-1:0] lsu0_port3_addr_cdc,
  output [64-1:0] lsu0_port3_d_cdc,
  input  [64-1:0] lsu0_port3_q_cdc,
  output          lsu0_port3_ce_cdc,
  output          lsu0_port3_we_cdc,
  output [4:0]   lsu0_ram_en_cdc,

`ifndef SOCKET_S
  output [12-1:0] lsu1_port0_addr_cdc,
  output [64-1:0] lsu1_port0_d_cdc,
  input  [64-1:0] lsu1_port0_q_cdc,
  output          lsu1_port0_ce_cdc,
  output          lsu1_port0_we_cdc,

  output [12-1:0] lsu1_port1_addr_cdc,
  output [64-1:0] lsu1_port1_d_cdc,
  input  [64-1:0] lsu1_port1_q_cdc,
  output          lsu1_port1_ce_cdc,
  output          lsu1_port1_we_cdc,

  output [12-1:0] lsu1_port2_addr_cdc,
  output [64-1:0] lsu1_port2_d_cdc,
  input  [64-1:0] lsu1_port2_q_cdc,
  output          lsu1_port2_ce_cdc,
  output          lsu1_port2_we_cdc,

  output [12-1:0] lsu1_port3_addr_cdc,
  output [64-1:0] lsu1_port3_d_cdc,
  input  [64-1:0] lsu1_port3_q_cdc,
  output          lsu1_port3_ce_cdc,
  output          lsu1_port3_we_cdc,
  output [4:0]   lsu1_ram_en_cdc,
`endif
  input         cl_done_cdc,
  output [11:0] cl_ctrl_addr_cdc,
  output [31:0] cl_ctrl_d_cdc,
  input  [31:0] cl_ctrl_q_cdc,
  output        cl_ctrl_ce_cdc,
  output        cl_ctrl_we_cdc,

  output socket_reset_cdc,

  input f_clk,
  input clk
);

  assign socket_reset_cdc = socket_reset;

  wire [2*12-1:0] lsu0_port0_addr_cdc_tmp = lsu0_port0_addr;
  wire [2*64-1:0] lsu0_port0_d_cdc_tmp    = lsu0_port0_d;
  wire [1:0] lsu0_port0_ce_cdc_tmp = lsu0_port0_ce;
  wire lsu0_port0_we_cdc_tmp = lsu0_port0_we;
  wire [2*64-1:0] lsu0_port0_q_pipe0;
  assign lsu0_port0_q = lsu0_port0_q_pipe0;
  wire [2*12-1:0] lsu0_port1_addr_cdc_tmp = lsu0_port1_addr;
  wire [2*64-1:0] lsu0_port1_d_cdc_tmp    = lsu0_port1_d;
  wire [1:0] lsu0_port1_ce_cdc_tmp = lsu0_port1_ce;
  wire lsu0_port1_we_cdc_tmp = lsu0_port1_we;
  wire [2*64-1:0] lsu0_port1_q_pipe0;
  assign lsu0_port1_q = lsu0_port1_q_pipe0;
  wire [2*12-1:0] lsu0_port2_addr_cdc_tmp = lsu0_port2_addr;
  wire [2*64-1:0] lsu0_port2_d_cdc_tmp    = lsu0_port2_d;
  wire [1:0] lsu0_port2_ce_cdc_tmp = lsu0_port2_ce;
  wire lsu0_port2_we_cdc_tmp = lsu0_port2_we;
  wire [2*64-1:0] lsu0_port2_q_pipe0;
  assign lsu0_port2_q = lsu0_port2_q_pipe0;
  wire [2*12-1:0] lsu0_port3_addr_cdc_tmp = lsu0_port3_addr;
  wire [2*64-1:0] lsu0_port3_d_cdc_tmp    = lsu0_port3_d;
  wire [1:0] lsu0_port3_ce_cdc_tmp = lsu0_port3_ce;
  wire lsu0_port3_we_cdc_tmp = lsu0_port3_we;
  wire [2*64-1:0] lsu0_port3_q_pipe0;
  assign lsu0_port3_q = lsu0_port3_q_pipe0;

`ifndef SOCKET_S
  wire [2*12-1:0] lsu1_port0_addr_cdc_tmp = lsu1_port0_addr;
  wire [2*64-1:0] lsu1_port0_d_cdc_tmp    = lsu1_port0_d;
  wire [1:0] lsu1_port0_ce_cdc_tmp = lsu1_port0_ce;
  wire lsu1_port0_we_cdc_tmp = lsu1_port0_we;
  wire [2*64-1:0] lsu1_port0_q_pipe0;
  assign lsu1_port0_q = lsu1_port0_q_pipe0;
  wire [2*12-1:0] lsu1_port1_addr_cdc_tmp = lsu1_port1_addr;
  wire [2*64-1:0] lsu1_port1_d_cdc_tmp    = lsu1_port1_d;
  wire [1:0] lsu1_port1_ce_cdc_tmp = lsu1_port1_ce;
  wire lsu1_port1_we_cdc_tmp = lsu1_port1_we;
  wire [2*64-1:0] lsu1_port1_q_pipe0;
  assign lsu1_port1_q = lsu1_port1_q_pipe0;
  wire [2*12-1:0] lsu1_port2_addr_cdc_tmp = lsu1_port2_addr;
  wire [2*64-1:0] lsu1_port2_d_cdc_tmp    = lsu1_port2_d;
  wire [1:0] lsu1_port2_ce_cdc_tmp = lsu1_port2_ce;
  wire lsu1_port2_we_cdc_tmp = lsu1_port2_we;
  wire [2*64-1:0] lsu1_port2_q_pipe0;
  assign lsu1_port2_q = lsu1_port2_q_pipe0;
  wire [2*12-1:0] lsu1_port3_addr_cdc_tmp = lsu1_port3_addr;
  wire [2*64-1:0] lsu1_port3_d_cdc_tmp    = lsu1_port3_d;
  wire [1:0] lsu1_port3_ce_cdc_tmp = lsu1_port3_ce;
  wire lsu1_port3_we_cdc_tmp = lsu1_port3_we;
  wire [2*64-1:0] lsu1_port3_q_pipe0;
  assign lsu1_port3_q = lsu1_port3_q_pipe0;

  assign lsu1_ram_en_cdc = lsu1_ram_en;
`endif

  assign lsu0_ram_en_cdc = lsu0_ram_en;

  localparam READ_LATENCY = 7;

  wire lsu0_port0_clk_cnt0;
  REGISTER_R_CE #(.N(1)) lsu0_port0_clk_cnt0_reg (
    .clk(f_clk),
    .rst(lsu0_port0_clk_cnt0),
    .ce(~lsu0_port0_clk_cnt0 & (|lsu0_port0_ce_cdc_tmp)),
    .d(1'b1),
    .q(lsu0_port0_clk_cnt0)
  );
  wire [1:0] lsu0_port0_ce_pipe;
  pipe_block #(.WIDTH(2), .NUM_STAGES(READ_LATENCY)) lsu0_port0_read_valid_pb (
    .clk(f_clk),
    .d(lsu0_port0_ce),
    .q(lsu0_port0_ce_pipe)
  );
  wire lsu0_port0_clk_cnt1;
  wire lsu0_port1_clk_cnt1;
  wire lsu0_port2_clk_cnt1;
  wire lsu0_port3_clk_cnt1;

  REGISTER_R_CE #(.N(1)) lsu0_port0_clk_cnt1_reg (
    .clk(f_clk),
    .rst(lsu0_port0_clk_cnt1),
    .ce(~lsu0_port0_clk_cnt1 & (|lsu0_port0_ce_pipe)),
    .d(1'b1),
    .q(lsu0_port0_clk_cnt1)
  );
  wire [63:0] lsu0_port0_q_cdc_pipe0;
  REGISTER #(.N(64)) lsu0_port0_q_cdc_pipe0_reg (
    .clk(f_clk),
    .d(lsu0_port0_q_cdc),
    .q(lsu0_port0_q_cdc_pipe0)
  );
  REGISTER_CE #(.N(2*64)) lsu0_port0_q_pipe0_reg (
    .clk(f_clk),
    .ce(lsu0_port0_clk_cnt1 | (lsu0_dp_mode & lsu0_port2_clk_cnt1)),
    .d({lsu0_port0_q_cdc, lsu0_port0_q_cdc_pipe0}),
    .q(lsu0_port0_q_pipe0)
  );

  always @(posedge f_clk) begin
  end

  wire lsu0_port1_clk_cnt0;
  REGISTER_R_CE #(.N(1)) lsu0_port1_clk_cnt0_reg (
    .clk(f_clk),
    .rst(lsu0_port1_clk_cnt0),
    .ce(~lsu0_port1_clk_cnt0 & (|lsu0_port1_ce_cdc_tmp)),
    .d(1'b1),
    .q(lsu0_port1_clk_cnt0)
  );
  wire [1:0] lsu0_port1_ce_pipe;
  pipe_block #(.WIDTH(2), .NUM_STAGES(READ_LATENCY)) lsu0_port1_read_valid_pb (
    .clk(f_clk),
    .d(lsu0_port1_ce),
    .q(lsu0_port1_ce_pipe)
  );
  REGISTER_R_CE #(.N(1)) lsu0_port1_clk_cnt1_reg (
    .clk(f_clk),
    .rst(lsu0_port1_clk_cnt1),
    .ce(~lsu0_port1_clk_cnt1 & (|lsu0_port1_ce_pipe)),
    .d(1'b1),
    .q(lsu0_port1_clk_cnt1)
  );
  wire [63:0] lsu0_port1_q_cdc_pipe0;
  REGISTER #(.N(64)) lsu0_port1_q_cdc_pipe0_reg (
    .clk(f_clk),
    .d(lsu0_port1_q_cdc),
    .q(lsu0_port1_q_cdc_pipe0)
  );
  REGISTER_CE #(.N(2*64)) lsu0_port1_q_pipe0_reg (
    .clk(f_clk),
    .ce(lsu0_port1_clk_cnt1 | (lsu0_dp_mode & lsu0_port3_clk_cnt1)),
    .d({lsu0_port1_q_cdc, lsu0_port1_q_cdc_pipe0}),
    .q(lsu0_port1_q_pipe0)
  );
  wire lsu0_port2_clk_cnt0;
  REGISTER_R_CE #(.N(1)) lsu0_port2_clk_cnt0_reg (
    .clk(f_clk),
    .rst(lsu0_port2_clk_cnt0),
    .ce(~lsu0_port2_clk_cnt0 & (|lsu0_port2_ce_cdc_tmp)),
    .d(1'b1),
    .q(lsu0_port2_clk_cnt0)
  );
  wire [1:0] lsu0_port2_ce_pipe;
  pipe_block #(.WIDTH(2), .NUM_STAGES(READ_LATENCY)) lsu0_port2_read_valid_pb (
    .clk(f_clk),
    .d(lsu0_port2_ce),
    .q(lsu0_port2_ce_pipe)
  );
  REGISTER_R_CE #(.N(1)) lsu0_port2_clk_cnt1_reg (
    .clk(f_clk),
    .rst(lsu0_port2_clk_cnt1),
    .ce(~lsu0_port2_clk_cnt1 & (|lsu0_port2_ce_pipe)),
    .d(1'b1),
    .q(lsu0_port2_clk_cnt1)
  );
  wire [63:0] lsu0_port2_q_cdc_pipe0;
  REGISTER #(.N(64)) lsu0_port2_q_cdc_pipe0_reg (
    .clk(f_clk),
    .d(lsu0_port2_q_cdc),
    .q(lsu0_port2_q_cdc_pipe0)
  );
  REGISTER_CE #(.N(2*64)) lsu0_port2_q_pipe0_reg (
    .clk(f_clk),
    .ce(lsu0_port2_clk_cnt1 | (lsu0_dp_mode & lsu0_port0_clk_cnt1)),
    .d({lsu0_port2_q_cdc[63:0], lsu0_port2_q_cdc_pipe0}),
    .q(lsu0_port2_q_pipe0)
  );
  wire lsu0_port3_clk_cnt0;
  REGISTER_R_CE #(.N(1)) lsu0_port3_clk_cnt0_reg (
    .clk(f_clk),
    .rst(lsu0_port3_clk_cnt0),
    .ce(~lsu0_port3_clk_cnt0 & (|lsu0_port3_ce_cdc_tmp)),
    .d(1'b1),
    .q(lsu0_port3_clk_cnt0)
  );
  wire [1:0] lsu0_port3_ce_pipe;
  pipe_block #(.WIDTH(2), .NUM_STAGES(READ_LATENCY)) lsu0_port3_read_valid_pb (
    .clk(f_clk),
    .d(lsu0_port3_ce),
    .q(lsu0_port3_ce_pipe)
  );
  REGISTER_R_CE #(.N(1)) lsu0_port3_clk_cnt1_reg (
    .clk(f_clk),
    .rst(lsu0_port3_clk_cnt1),
    .ce(~lsu0_port3_clk_cnt1 & (|lsu0_port3_ce_pipe)),
    .d(1'b1),
    .q(lsu0_port3_clk_cnt1)
  );
  wire [63:0] lsu0_port3_q_cdc_pipe0;
  REGISTER #(.N(64)) lsu0_port3_q_cdc_pipe0_reg (
    .clk(f_clk),
    .d(lsu0_port3_q_cdc),
    .q(lsu0_port3_q_cdc_pipe0)
  );
  REGISTER_CE #(.N(2*64)) lsu0_port3_q_pipe0_reg (
    .clk(f_clk),
    .ce(lsu0_port3_clk_cnt1 | (lsu0_dp_mode & lsu0_port1_clk_cnt1)),
    .d({lsu0_port3_q_cdc, lsu0_port3_q_cdc_pipe0}),
    .q(lsu0_port3_q_pipe0)
  );

`ifndef SOCKET_S
  wire lsu1_port0_clk_cnt0;
  REGISTER_R_CE #(.N(1)) lsu1_port0_clk_cnt0_reg (
    .clk(f_clk),
    .rst(lsu1_port0_clk_cnt0),
    .ce(~lsu1_port0_clk_cnt0 & (|lsu1_port0_ce_cdc_tmp)),
    .d(1'b1),
    .q(lsu1_port0_clk_cnt0)
  );
  wire [1:0] lsu1_port0_ce_pipe;
  pipe_block #(.WIDTH(2), .NUM_STAGES(READ_LATENCY)) lsu1_port0_read_valid_pb (
    .clk(f_clk),
    .d(lsu1_port0_ce),
    .q(lsu1_port0_ce_pipe)
  );
  wire lsu1_port0_clk_cnt1;
  wire lsu1_port1_clk_cnt1;
  wire lsu1_port2_clk_cnt1;
  wire lsu1_port3_clk_cnt1;
  REGISTER_R_CE #(.N(1)) lsu1_port0_clk_cnt1_reg (
    .clk(f_clk),
    .rst(lsu1_port0_clk_cnt1),
    .ce(~lsu1_port0_clk_cnt1 & (|lsu1_port0_ce_pipe)),
    .d(1'b1),
    .q(lsu1_port0_clk_cnt1)
  );
  wire [63:0] lsu1_port0_q_cdc_pipe0;
  REGISTER #(.N(64)) lsu1_port0_q_cdc_pipe0_reg (
    .clk(f_clk),
    .d(lsu1_port0_q_cdc),
    .q(lsu1_port0_q_cdc_pipe0)
  );
  REGISTER_CE #(.N(2*64)) lsu1_port0_q_pipe0_reg (
    .clk(f_clk),
    .ce(lsu1_port0_clk_cnt1 | (lsu1_dp_mode & lsu1_port2_clk_cnt1)),
    .d({lsu1_port0_q_cdc, lsu1_port0_q_cdc_pipe0}),
    .q(lsu1_port0_q_pipe0)
  );
  wire lsu1_port1_clk_cnt0;
  REGISTER_R_CE #(.N(1)) lsu1_port1_clk_cnt0_reg (
    .clk(f_clk),
    .rst(lsu1_port1_clk_cnt0),
    .ce(~lsu1_port1_clk_cnt0 & (|lsu1_port1_ce_cdc_tmp)),
    .d(1'b1),
    .q(lsu1_port1_clk_cnt0)
  );
  wire [1:0] lsu1_port1_ce_pipe;
  pipe_block #(.WIDTH(2), .NUM_STAGES(READ_LATENCY)) lsu1_port1_read_valid_pb (
    .clk(f_clk),
    .d(lsu1_port1_ce),
    .q(lsu1_port1_ce_pipe)
  );
  REGISTER_R_CE #(.N(1)) lsu1_port1_clk_cnt1_reg (
    .clk(f_clk),
    .rst(lsu1_port1_clk_cnt1),
    .ce(~lsu1_port1_clk_cnt1 & (|lsu1_port1_ce_pipe)),
    .d(1'b1),
    .q(lsu1_port1_clk_cnt1)
  );
  wire [63:0] lsu1_port1_q_cdc_pipe0;
  REGISTER #(.N(64)) lsu1_port1_q_cdc_pipe0_reg (
    .clk(f_clk),
    .d(lsu1_port1_q_cdc),
    .q(lsu1_port1_q_cdc_pipe0)
  );
  REGISTER_CE #(.N(2*64)) lsu1_port1_q_pipe0_reg (
    .clk(f_clk),
    .ce(lsu1_port1_clk_cnt1 | (lsu1_dp_mode & lsu1_port3_clk_cnt1)),
    .d({lsu1_port1_q_cdc, lsu1_port1_q_cdc_pipe0}),
    .q(lsu1_port1_q_pipe0)
  );
  wire lsu1_port2_clk_cnt0;
  REGISTER_R_CE #(.N(1)) lsu1_port2_clk_cnt0_reg (
    .clk(f_clk),
    .rst(lsu1_port2_clk_cnt0),
    .ce(~lsu1_port2_clk_cnt0 & (|lsu1_port2_ce_cdc_tmp)),
    .d(1'b1),
    .q(lsu1_port2_clk_cnt0)
  );
  wire [1:0] lsu1_port2_ce_pipe;
  pipe_block #(.WIDTH(2), .NUM_STAGES(READ_LATENCY)) lsu1_port2_read_valid_pb (
    .clk(f_clk),
    .d(lsu1_port2_ce),
    .q(lsu1_port2_ce_pipe)
  );
  REGISTER_R_CE #(.N(1)) lsu1_port2_clk_cnt1_reg (
    .clk(f_clk),
    .rst(lsu1_port2_clk_cnt1),
    .ce(~lsu1_port2_clk_cnt1 & (|lsu1_port2_ce_pipe)),
    .d(1'b1),
    .q(lsu1_port2_clk_cnt1)
  );
  wire [63:0] lsu1_port2_q_cdc_pipe0;
  REGISTER #(.N(64)) lsu1_port2_q_cdc_pipe0_reg (
    .clk(f_clk),
    .d(lsu1_port2_q_cdc),
    .q(lsu1_port2_q_cdc_pipe0)
  );
  REGISTER_CE #(.N(2*64)) lsu1_port2_q_pipe0_reg (
    .clk(f_clk),
    .ce(lsu1_port2_clk_cnt1 | (lsu1_dp_mode & lsu1_port0_clk_cnt1)),
    .d({lsu1_port2_q_cdc, lsu1_port2_q_cdc_pipe0}),
    .q(lsu1_port2_q_pipe0)
  );
  wire lsu1_port3_clk_cnt0;
  REGISTER_R_CE #(.N(1)) lsu1_port3_clk_cnt0_reg (
    .clk(f_clk),
    .rst(lsu1_port3_clk_cnt0),
    .ce(~lsu1_port3_clk_cnt0 & (|lsu1_port3_ce_cdc_tmp)),
    .d(1'b1),
    .q(lsu1_port3_clk_cnt0)
  );
  wire [1:0] lsu1_port3_ce_pipe;
  pipe_block #(.WIDTH(2), .NUM_STAGES(READ_LATENCY)) lsu1_port3_read_valid_pb (
    .clk(f_clk),
    .d(lsu1_port3_ce),
    .q(lsu1_port3_ce_pipe)
  );
  REGISTER_R_CE #(.N(1)) lsu1_port3_clk_cnt1_reg (
    .clk(f_clk),
    .rst(lsu1_port3_clk_cnt1),
    .ce(~lsu1_port3_clk_cnt1 & (|lsu1_port3_ce_pipe)),
    .d(1'b1),
    .q(lsu1_port3_clk_cnt1)
  );
  wire [63:0] lsu1_port3_q_cdc_pipe0;
  REGISTER #(.N(64)) lsu1_port3_q_cdc_pipe0_reg (
    .clk(f_clk),
    .d(lsu1_port3_q_cdc),
    .q(lsu1_port3_q_cdc_pipe0)
  );
  REGISTER_CE #(.N(2*64)) lsu1_port3_q_pipe0_reg (
    .clk(f_clk),
    .ce(lsu1_port3_clk_cnt1 | (lsu1_dp_mode & lsu1_port1_clk_cnt1)),
    .d({lsu1_port3_q_cdc, lsu1_port3_q_cdc_pipe0}),
    .q(lsu1_port3_q_pipe0)
  );
`endif

  assign cl_done          = cl_done_cdc;
  assign cl_ctrl_addr_cdc = cl_ctrl_addr;
  assign cl_ctrl_d_cdc    = cl_ctrl_d;
  assign cl_ctrl_ce_cdc   = cl_ctrl_ce;
  assign cl_ctrl_we_cdc   = cl_ctrl_we;
  assign cl_ctrl_q        = cl_ctrl_q_cdc;

  wire [31:0] lsu0_ram_start_idx_cdc = lsu0_ram_start_idx;

  wire lsu0_dp_base0 = lsu0_dp_mode & ((lsu0_ram_start_idx_cdc & 2'b11) == 0);
  wire lsu0_dp_base2 = lsu0_dp_mode & ((lsu0_ram_start_idx_cdc & 2'b11) == 2);

`ifndef SOCKET_S
  wire [31:0] lsu1_ram_start_idx_cdc = lsu1_ram_start_idx;
  wire lsu1_dp_base0 = lsu1_dp_mode & ((lsu1_ram_start_idx_cdc & 2'b11) == 0);
  wire lsu1_dp_base2 = lsu1_dp_mode & ((lsu1_ram_start_idx_cdc & 2'b11) == 2);
`endif

  assign lsu0_port0_addr_cdc = ((lsu0_dp_base2 & ~lsu0_port2_clk_cnt0) | (~lsu0_dp_base2 & ~lsu0_port0_clk_cnt0)) ? lsu0_port0_addr_cdc_tmp[11:0] : lsu0_port0_addr_cdc_tmp[23:12];
  assign lsu0_port0_d_cdc    = ((lsu0_dp_base2 & ~lsu0_port2_clk_cnt0) | (~lsu0_dp_base2 & ~lsu0_port0_clk_cnt0)) ? lsu0_port0_d_cdc_tmp[63:0]    : lsu0_port0_d_cdc_tmp[127:64];
  assign lsu0_port0_ce_cdc   = ~lsu0_port0_clk_cnt0 ? lsu0_port0_ce_cdc_tmp[0]      : lsu0_port0_ce_cdc_tmp[1];
  assign lsu0_port0_we_cdc   = lsu0_port0_we_cdc_tmp;

  assign lsu0_port1_addr_cdc = ((lsu0_dp_base2 & ~lsu0_port3_clk_cnt0) | (~lsu0_dp_base2 & ~lsu0_port1_clk_cnt0)) ? lsu0_port1_addr_cdc_tmp[11:0] : lsu0_port1_addr_cdc_tmp[23:12];
  assign lsu0_port1_d_cdc    = ((lsu0_dp_base2 & ~lsu0_port3_clk_cnt0) | (~lsu0_dp_base2 & ~lsu0_port1_clk_cnt0)) ? lsu0_port1_d_cdc_tmp[63:0]    : lsu0_port1_d_cdc_tmp[127:64];
  assign lsu0_port1_ce_cdc   = ~lsu0_port1_clk_cnt0 ? lsu0_port1_ce_cdc_tmp[0]      : lsu0_port1_ce_cdc_tmp[1];
  assign lsu0_port1_we_cdc   = lsu0_port1_we_cdc_tmp;

  assign lsu0_port2_addr_cdc = ((lsu0_dp_base0 & ~lsu0_port0_clk_cnt0) | (~lsu0_dp_base0 & ~lsu0_port2_clk_cnt0)) ? lsu0_port2_addr_cdc_tmp[11:0] : lsu0_port2_addr_cdc_tmp[23:12];
  assign lsu0_port2_d_cdc    = ((lsu0_dp_base0 & ~lsu0_port0_clk_cnt0) | (~lsu0_dp_base0 & ~lsu0_port2_clk_cnt0)) ? lsu0_port2_d_cdc_tmp[63:0]    : lsu0_port2_d_cdc_tmp[127:64];
  assign lsu0_port2_ce_cdc   = ~lsu0_port2_clk_cnt0 ? lsu0_port2_ce_cdc_tmp[0]      : lsu0_port2_ce_cdc_tmp[1];
  assign lsu0_port2_we_cdc   = lsu0_port2_we_cdc_tmp;

  assign lsu0_port3_addr_cdc = ((lsu0_dp_base0 & ~lsu0_port1_clk_cnt0) | (~lsu0_dp_base0 & ~lsu0_port3_clk_cnt0)) ? lsu0_port3_addr_cdc_tmp[11:0] : lsu0_port3_addr_cdc_tmp[23:12];
  assign lsu0_port3_d_cdc    = ((lsu0_dp_base0 & ~lsu0_port1_clk_cnt0) | (~lsu0_dp_base0 & ~lsu0_port3_clk_cnt0)) ? lsu0_port3_d_cdc_tmp[63:0]    : lsu0_port3_d_cdc_tmp[127:64];
  assign lsu0_port3_ce_cdc   = ~lsu0_port3_clk_cnt0 ? lsu0_port3_ce_cdc_tmp[0]      : lsu0_port3_ce_cdc_tmp[1];
  assign lsu0_port3_we_cdc   = lsu0_port3_we_cdc_tmp;

`ifndef SOCKET_S
  assign lsu1_port0_addr_cdc = ((lsu1_dp_base2 & ~lsu1_port2_clk_cnt0) | (~lsu1_dp_base2 & ~lsu1_port0_clk_cnt0)) ? lsu1_port0_addr_cdc_tmp[11:0] : lsu1_port0_addr_cdc_tmp[23:12];
  assign lsu1_port0_d_cdc    = ((lsu1_dp_base2 & ~lsu1_port2_clk_cnt0) | (~lsu1_dp_base2 & ~lsu1_port0_clk_cnt0)) ? lsu1_port0_d_cdc_tmp[63:0]    : lsu1_port0_d_cdc_tmp[127:64];
  assign lsu1_port0_ce_cdc   = ~lsu1_port0_clk_cnt0 ? lsu1_port0_ce_cdc_tmp[0]      : lsu1_port0_ce_cdc_tmp[1];
  assign lsu1_port0_we_cdc   = lsu1_port0_we_cdc_tmp;

  assign lsu1_port1_addr_cdc = ((lsu1_dp_base2 & ~lsu1_port3_clk_cnt0) | (~lsu1_dp_base2 & ~lsu1_port1_clk_cnt0)) ? lsu1_port1_addr_cdc_tmp[11:0] : lsu1_port1_addr_cdc_tmp[23:12];
  assign lsu1_port1_d_cdc    = ((lsu1_dp_base2 & ~lsu1_port3_clk_cnt0) | (~lsu1_dp_base2 & ~lsu1_port1_clk_cnt0)) ? lsu1_port1_d_cdc_tmp[63:0]    : lsu1_port1_d_cdc_tmp[127:64];
  assign lsu1_port1_ce_cdc   = ~lsu1_port1_clk_cnt0 ? lsu1_port1_ce_cdc_tmp[0]      : lsu1_port1_ce_cdc_tmp[1];
  assign lsu1_port1_we_cdc   = lsu1_port1_we_cdc_tmp;

  assign lsu1_port2_addr_cdc = ((lsu1_dp_base0 & ~lsu1_port0_clk_cnt0) | (~lsu1_dp_base0 & ~lsu1_port2_clk_cnt0)) ? lsu1_port2_addr_cdc_tmp[11:0] : lsu1_port2_addr_cdc_tmp[23:12];
  assign lsu1_port2_d_cdc    = ((lsu1_dp_base0 & ~lsu1_port0_clk_cnt0) | (~lsu1_dp_base0 & ~lsu1_port2_clk_cnt0)) ? lsu1_port2_d_cdc_tmp[63:0]    : lsu1_port2_d_cdc_tmp[127:64];
  assign lsu1_port2_ce_cdc   = ~lsu1_port2_clk_cnt0 ? lsu1_port2_ce_cdc_tmp[0]      : lsu1_port2_ce_cdc_tmp[1];
  assign lsu1_port2_we_cdc   = lsu1_port2_we_cdc_tmp;

  assign lsu1_port3_addr_cdc = ((lsu1_dp_base0 & ~lsu1_port1_clk_cnt0) | (~lsu1_dp_base0 & ~lsu1_port3_clk_cnt0)) ? lsu1_port3_addr_cdc_tmp[11:0] : lsu1_port3_addr_cdc_tmp[23:12];
  assign lsu1_port3_d_cdc    = ((lsu1_dp_base0 & ~lsu1_port1_clk_cnt0) | (~lsu1_dp_base0 & ~lsu1_port3_clk_cnt0)) ? lsu1_port3_d_cdc_tmp[63:0]    : lsu1_port3_d_cdc_tmp[127:64];
  assign lsu1_port3_ce_cdc   = ~lsu1_port3_clk_cnt0 ? lsu1_port3_ce_cdc_tmp[0]      : lsu1_port3_ce_cdc_tmp[1];
  assign lsu1_port3_we_cdc   = lsu1_port3_we_cdc_tmp;
`endif

endmodule
