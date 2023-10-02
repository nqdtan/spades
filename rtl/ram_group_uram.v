`include "socket_config.vh"
module ram_group_uram #(
  parameter AWIDTH = 12,
  parameter DWIDTH = 64
) (
  input  [AWIDTH-1:0] ram_0_addr0,
  input  [DWIDTH-1:0] ram_0_d0,
  output [DWIDTH-1:0] ram_0_q0,
  input               ram_0_ce0,
  input               ram_0_we0,
  input  [AWIDTH-1:0] ram_0_addr1,
  input  [DWIDTH-1:0] ram_0_d1,
  output [DWIDTH-1:0] ram_0_q1,
  input               ram_0_ce1,
  input               ram_0_we1,
  input  [AWIDTH-1:0] ram_1_addr0,
  input  [DWIDTH-1:0] ram_1_d0,
  output [DWIDTH-1:0] ram_1_q0,
  input               ram_1_ce0,
  input               ram_1_we0,
  input  [AWIDTH-1:0] ram_1_addr1,
  input  [DWIDTH-1:0] ram_1_d1,
  output [DWIDTH-1:0] ram_1_q1,
  input               ram_1_ce1,
  input               ram_1_we1,
  input  [AWIDTH-1:0] ram_2_addr0,
  input  [DWIDTH-1:0] ram_2_d0,
  output [DWIDTH-1:0] ram_2_q0,
  input               ram_2_ce0,
  input               ram_2_we0,
  input  [AWIDTH-1:0] ram_2_addr1,
  input  [DWIDTH-1:0] ram_2_d1,
  output [DWIDTH-1:0] ram_2_q1,
  input               ram_2_ce1,
  input               ram_2_we1,
  input  [AWIDTH-1:0] ram_3_addr0,
  input  [DWIDTH-1:0] ram_3_d0,
  output [DWIDTH-1:0] ram_3_q0,
  input               ram_3_ce0,
  input               ram_3_we0,
  input  [AWIDTH-1:0] ram_3_addr1,
  input  [DWIDTH-1:0] ram_3_d1,
  output [DWIDTH-1:0] ram_3_q1,
  input               ram_3_ce1,
  input               ram_3_we1,
  input clk,
  input rst
);
  wire [AWIDTH-1:0] ram_0_addr0_pipe;
  wire [DWIDTH-1:0] ram_0_d0_pipe;
  wire [DWIDTH-1:0] ram_0_q0_pipe;
  wire              ram_0_ce0_pipe;
  wire              ram_0_we0_pipe;
  wire [AWIDTH-1:0] ram_0_addr1_pipe;
  wire [DWIDTH-1:0] ram_0_d1_pipe;
  wire [DWIDTH-1:0] ram_0_q1_pipe;
  wire              ram_0_ce1_pipe;
  wire              ram_0_we1_pipe;
  pipe_block #(.NUM_STAGES(1), .WIDTH(AWIDTH)) ram_0_addr0_pipe_block (
    .clk(clk),
    .d(ram_0_addr0),
    .q(ram_0_addr0_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_0_d0_pipe_block (
    .clk(clk),
    .d(ram_0_d0),
    .q(ram_0_d0_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_0_ce0_pipe_block (
    .clk(clk),
    .d(ram_0_ce0),
    .q(ram_0_ce0_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_0_we0_pipe_block (
    .clk(clk),
    .d(ram_0_we0),
    .q(ram_0_we0_pipe));
//  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_0_q0_pipe_block (
//    .clk(clk),
//    .d(ram_0_q0_pipe),
//    .q(ram_0_q0));
  pipe_block #(.NUM_STAGES(1), .WIDTH(AWIDTH)) ram_0_addr1_pipe_block (
    .clk(clk),
    .d(ram_0_addr1),
    .q(ram_0_addr1_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_0_d1_pipe_block (
    .clk(clk),
    .d(ram_0_d1),
    .q(ram_0_d1_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_0_ce1_pipe_block (
    .clk(clk),
    .d(ram_0_ce1),
    .q(ram_0_ce1_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_0_we1_pipe_block (
    .clk(clk),
    .d(ram_0_we1),
    .q(ram_0_we1_pipe));
//  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_0_q1_pipe_block (
//    .clk(clk),
//    .d(ram_0_q1_pipe),
//    .q(ram_0_q1));

//  reg [DWIDTH-1:0] ram_0_q0_tmp;
//  always @(posedge clk) begin
//    ram_0_q0_tmp <= ram_0_q0_pipe;
//  end
//  assign ram_0_q0 = ram_0_q0_tmp;
//  reg [DWIDTH-1:0] ram_0_q1_tmp;
//  always @(posedge clk) begin
//    ram_0_q1_tmp <= ram_0_q1_pipe;
//  end
//  assign ram_0_q1 = ram_0_q1_tmp;

  assign ram_0_q0 = ram_0_q0_pipe;
  assign ram_0_q1 = ram_0_q1_pipe;

  SYNC_RAM_DP_URAM #(
    .AWIDTH(AWIDTH),
    .DEPTH(4096),
    .DWIDTH(DWIDTH)
  ) ram_0 (
    .addr0(ram_0_addr0_pipe),
    .d0(ram_0_d0_pipe),
    .q0(ram_0_q0_pipe),
    .we0(ram_0_we0_pipe),
    .en0(ram_0_ce0_pipe),
    .addr1(ram_0_addr1_pipe),
    .d1(ram_0_d1_pipe),
    .q1(ram_0_q1_pipe),
    .we1(ram_0_we1_pipe),
    .en1(ram_0_ce1_pipe),
    .clk(clk)
  );
  wire [AWIDTH-1:0] ram_1_addr0_pipe;
  wire [DWIDTH-1:0] ram_1_d0_pipe;
  wire [DWIDTH-1:0] ram_1_q0_pipe;
  wire              ram_1_ce0_pipe;
  wire              ram_1_we0_pipe;
  wire [AWIDTH-1:0] ram_1_addr1_pipe;
  wire [DWIDTH-1:0] ram_1_d1_pipe;
  wire [DWIDTH-1:0] ram_1_q1_pipe;
  wire              ram_1_ce1_pipe;
  wire              ram_1_we1_pipe;
  pipe_block #(.NUM_STAGES(1), .WIDTH(AWIDTH)) ram_1_addr0_pipe_block (
    .clk(clk),
    .d(ram_1_addr0),
    .q(ram_1_addr0_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_1_d0_pipe_block (
    .clk(clk),
    .d(ram_1_d0),
    .q(ram_1_d0_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_1_ce0_pipe_block (
    .clk(clk),
    .d(ram_1_ce0),
    .q(ram_1_ce0_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_1_we0_pipe_block (
    .clk(clk),
    .d(ram_1_we0),
    .q(ram_1_we0_pipe));
//  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_1_q0_pipe_block (
//    .clk(clk),
//    .d(ram_1_q0_pipe),
//    .q(ram_1_q0));
  pipe_block #(.NUM_STAGES(1), .WIDTH(AWIDTH)) ram_1_addr1_pipe_block (
    .clk(clk),
    .d(ram_1_addr1),
    .q(ram_1_addr1_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_1_d1_pipe_block (
    .clk(clk),
    .d(ram_1_d1),
    .q(ram_1_d1_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_1_ce1_pipe_block (
    .clk(clk),
    .d(ram_1_ce1),
    .q(ram_1_ce1_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_1_we1_pipe_block (
    .clk(clk),
    .d(ram_1_we1),
    .q(ram_1_we1_pipe));
//  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_1_q1_pipe_block (
//    .clk(clk),
//    .d(ram_1_q1_pipe),
//    .q(ram_1_q1));

//  reg [DWIDTH-1:0] ram_1_q0_tmp;
//  always @(posedge clk) begin
//    ram_1_q0_tmp <= ram_1_q0_pipe;
//  end
//  assign ram_1_q0 = ram_1_q0_tmp;
//  reg [DWIDTH-1:0] ram_1_q1_tmp;
//  always @(posedge clk) begin
//    ram_1_q1_tmp <= ram_1_q1_pipe;
//  end
//  assign ram_1_q1 = ram_1_q1_tmp;

  assign ram_1_q0 = ram_1_q0_pipe;
  assign ram_1_q1 = ram_1_q1_pipe;

  SYNC_RAM_DP_URAM #(
    .AWIDTH(AWIDTH),
    .DEPTH(4096),
    .DWIDTH(DWIDTH)
  ) ram_1 (
    .addr0(ram_1_addr0_pipe),
    .d0(ram_1_d0_pipe),
    .q0(ram_1_q0_pipe),
    .we0(ram_1_we0_pipe),
    .en0(ram_1_ce0_pipe),
    .addr1(ram_1_addr1_pipe),
    .d1(ram_1_d1_pipe),
    .q1(ram_1_q1_pipe),
    .we1(ram_1_we1_pipe),
    .en1(ram_1_ce1_pipe),
    .clk(clk)
  );
  wire [AWIDTH-1:0] ram_2_addr0_pipe;
  wire [DWIDTH-1:0] ram_2_d0_pipe;
  wire [DWIDTH-1:0] ram_2_q0_pipe;
  wire              ram_2_ce0_pipe;
  wire              ram_2_we0_pipe;
  wire [AWIDTH-1:0] ram_2_addr1_pipe;
  wire [DWIDTH-1:0] ram_2_d1_pipe;
  wire [DWIDTH-1:0] ram_2_q1_pipe;
  wire              ram_2_ce1_pipe;
  wire              ram_2_we1_pipe;
  pipe_block #(.NUM_STAGES(1), .WIDTH(AWIDTH)) ram_2_addr0_pipe_block (
    .clk(clk),
    .d(ram_2_addr0),
    .q(ram_2_addr0_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_2_d0_pipe_block (
    .clk(clk),
    .d(ram_2_d0),
    .q(ram_2_d0_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_2_ce0_pipe_block (
    .clk(clk),
    .d(ram_2_ce0),
    .q(ram_2_ce0_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_2_we0_pipe_block (
    .clk(clk),
    .d(ram_2_we0),
    .q(ram_2_we0_pipe));
//  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_2_q0_pipe_block (
//    .clk(clk),
//    .d(ram_2_q0_pipe),
//    .q(ram_2_q0));
  pipe_block #(.NUM_STAGES(1), .WIDTH(AWIDTH)) ram_2_addr1_pipe_block (
    .clk(clk),
    .d(ram_2_addr1),
    .q(ram_2_addr1_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_2_d1_pipe_block (
    .clk(clk),
    .d(ram_2_d1),
    .q(ram_2_d1_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_2_ce1_pipe_block (
    .clk(clk),
    .d(ram_2_ce1),
    .q(ram_2_ce1_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_2_we1_pipe_block (
    .clk(clk),
    .d(ram_2_we1),
    .q(ram_2_we1_pipe));
//  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_2_q1_pipe_block (
//    .clk(clk),
//    .d(ram_2_q1_pipe),
//    .q(ram_2_q1));

//  reg [DWIDTH-1:0] ram_2_q0_tmp;
//  always @(posedge clk) begin
//    ram_2_q0_tmp <= ram_2_q0_pipe;
//  end
//  assign ram_2_q0 = ram_2_q0_tmp;
//  reg [DWIDTH-1:0] ram_2_q1_tmp;
//  always @(posedge clk) begin
//    ram_2_q1_tmp <= ram_2_q1_pipe;
//  end
//  assign ram_2_q1 = ram_2_q1_tmp;

  assign ram_2_q0 = ram_2_q0_pipe;
  assign ram_2_q1 = ram_2_q1_pipe;

  SYNC_RAM_DP_URAM #(
    .AWIDTH(AWIDTH),
    .DEPTH(4096),
    .DWIDTH(DWIDTH)
  ) ram_2 (
    .addr0(ram_2_addr0_pipe),
    .d0(ram_2_d0_pipe),
    .q0(ram_2_q0_pipe),
    .we0(ram_2_we0_pipe),
    .en0(ram_2_ce0_pipe),
    .addr1(ram_2_addr1_pipe),
    .d1(ram_2_d1_pipe),
    .q1(ram_2_q1_pipe),
    .we1(ram_2_we1_pipe),
    .en1(ram_2_ce1_pipe),
    .clk(clk)
  );
  wire [AWIDTH-1:0] ram_3_addr0_pipe;
  wire [DWIDTH-1:0] ram_3_d0_pipe;
  wire [DWIDTH-1:0] ram_3_q0_pipe;
  wire              ram_3_ce0_pipe;
  wire              ram_3_we0_pipe;
  wire [AWIDTH-1:0] ram_3_addr1_pipe;
  wire [DWIDTH-1:0] ram_3_d1_pipe;
  wire [DWIDTH-1:0] ram_3_q1_pipe;
  wire              ram_3_ce1_pipe;
  wire              ram_3_we1_pipe;
  pipe_block #(.NUM_STAGES(1), .WIDTH(AWIDTH)) ram_3_addr0_pipe_block (
    .clk(clk),
    .d(ram_3_addr0),
    .q(ram_3_addr0_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_3_d0_pipe_block (
    .clk(clk),
    .d(ram_3_d0),
    .q(ram_3_d0_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_3_ce0_pipe_block (
    .clk(clk),
    .d(ram_3_ce0),
    .q(ram_3_ce0_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_3_we0_pipe_block (
    .clk(clk),
    .d(ram_3_we0),
    .q(ram_3_we0_pipe));
//  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_3_q0_pipe_block (
//    .clk(clk),
//    .d(ram_3_q0_pipe),
//    .q(ram_3_q0));
  pipe_block #(.NUM_STAGES(1), .WIDTH(AWIDTH)) ram_3_addr1_pipe_block (
    .clk(clk),
    .d(ram_3_addr1),
    .q(ram_3_addr1_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_3_d1_pipe_block (
    .clk(clk),
    .d(ram_3_d1),
    .q(ram_3_d1_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_3_ce1_pipe_block (
    .clk(clk),
    .d(ram_3_ce1),
    .q(ram_3_ce1_pipe));
  pipe_block #(.NUM_STAGES(1), .WIDTH(1)) ram_3_we1_pipe_block (
    .clk(clk),
    .d(ram_3_we1),
    .q(ram_3_we1_pipe));
//  pipe_block #(.NUM_STAGES(1), .WIDTH(DWIDTH)) ram_3_q1_pipe_block (
//    .clk(clk),
//    .d(ram_3_q1_pipe),
//    .q(ram_3_q1));

//  reg [DWIDTH-1:0] ram_3_q0_tmp;
//  always @(posedge clk) begin
//    ram_3_q0_tmp <= ram_3_q0_pipe;
//  end
//  assign ram_3_q0 = ram_3_q0_tmp;
//  reg [DWIDTH-1:0] ram_3_q1_tmp;
//  always @(posedge clk) begin
//    ram_3_q1_tmp <= ram_3_q1_pipe;
//  end
//  assign ram_3_q1 = ram_3_q1_tmp;

  assign ram_3_q0 = ram_3_q0_pipe;
  assign ram_3_q1 = ram_3_q1_pipe;

  SYNC_RAM_DP_URAM #(
    .AWIDTH(AWIDTH),
    .DEPTH(4096),
    .DWIDTH(DWIDTH)
  ) ram_3 (
    .addr0(ram_3_addr0_pipe),
    .d0(ram_3_d0_pipe),
    .q0(ram_3_q0_pipe),
    .we0(ram_3_we0_pipe),
    .en0(ram_3_ce0_pipe),
    .addr1(ram_3_addr1_pipe),
    .d1(ram_3_d1_pipe),
    .q1(ram_3_q1_pipe),
    .we1(ram_3_we1_pipe),
    .en1(ram_3_ce1_pipe),
    .clk(clk)
  );
`ifdef DEBUG
  reg [AWIDTH-1:0] ram_0_addr0_pipe1;
  reg [AWIDTH-1:0] ram_0_addr1_pipe1;
  reg ram_0_ren0;
  reg ram_0_ren1;
  always @(posedge clk) begin
    ram_0_addr0_pipe1 <= ram_0_addr0_pipe;
    ram_0_addr1_pipe1 <= ram_0_addr1_pipe;
    ram_0_ren0 <= ram_0_ce0_pipe & (ram_0_we0_pipe == 0);
    ram_0_ren1 <= ram_0_ce1_pipe & (ram_0_we1_pipe == 0);
  end
  always @(posedge clk) begin
    if (ram_0_ce0_pipe === 1'b1 && ram_0_we0_pipe === 1'b1)
      $display("[At %t] [%m] [RAM BANK 0 PORT0 WRITE] addr0=%h, d0=%h", $time, ram_0_addr0_pipe, ram_0_d0_pipe);
    if (ram_0_ce1_pipe === 1'b1 && ram_0_we1_pipe !== 1'b0)
      $display("[At %t] [%m] [RAM BANK 0 PORT1 WRITE] addr1=%h, d1=%h", $time, ram_0_addr1_pipe, ram_0_d1_pipe);
//    if (ram_0_ren0 === 1'b1)
//      $display("[At %t] [%m] [RAM BANK 0 PORT0 READ] addr0_pipe1=%h, q0=%h", $time, ram_0_addr0_pipe1, ram_0_q0_pipe);
//    if (ram_0_ren1 === 1'b1)
//      $display("[At %t] [%m] [RAM BANK 0 PORT1 READ] addr1_pipe1=%h, q1=%h", $time, ram_0_addr1_pipe1, ram_0_q1_pipe);
  end
  reg [AWIDTH-1:0] ram_1_addr0_pipe1;
  reg [AWIDTH-1:0] ram_1_addr1_pipe1;
  reg ram_1_ren0;
  reg ram_1_ren1;
  always @(posedge clk) begin
    ram_1_addr0_pipe1 <= ram_1_addr0_pipe;
    ram_1_addr1_pipe1 <= ram_1_addr1_pipe;
    ram_1_ren0 <= ram_1_ce0_pipe & (ram_1_we0_pipe == 0);
    ram_1_ren1 <= ram_1_ce1_pipe & (ram_1_we1_pipe == 0);
  end
  always @(posedge clk) begin
    if (ram_1_ce0_pipe === 1'b1 && ram_1_we0_pipe === 1'b1)
      $display("[At %t] [%m] [RAM BANK 1 PORT0 WRITE] addr0=%h, d0=%h", $time, ram_1_addr0_pipe, ram_1_d0_pipe);
    if (ram_1_ce1_pipe === 1'b1 && ram_1_we1_pipe !== 1'b0)
      $display("[At %t] [%m] [RAM BANK 1 PORT1 WRITE] addr1=%h, d1=%h", $time, ram_1_addr1_pipe, ram_1_d1_pipe);
//    if (ram_1_ren0 === 1'b1)
//      $display("[At %t] [%m] [RAM BANK 1 PORT0 READ] addr0_pipe1=%h, q0=%h", $time, ram_1_addr0_pipe1, ram_1_q0_pipe);
//    if (ram_1_ren1 === 1'b1)
//      $display("[At %t] [%m] [RAM BANK 1 PORT1 READ] addr1_pipe1=%h, q1=%h", $time, ram_1_addr1_pipe1, ram_1_q1_pipe);
  end
  reg [AWIDTH-1:0] ram_2_addr0_pipe1;
  reg [AWIDTH-1:0] ram_2_addr1_pipe1;
  reg ram_2_ren0;
  reg ram_2_ren1;
  always @(posedge clk) begin
    ram_2_addr0_pipe1 <= ram_2_addr0_pipe;
    ram_2_addr1_pipe1 <= ram_2_addr1_pipe;
    ram_2_ren0 <= ram_2_ce0_pipe & (ram_2_we0_pipe == 0);
    ram_2_ren1 <= ram_2_ce1_pipe & (ram_2_we1_pipe == 0);
  end
  always @(posedge clk) begin
    if (ram_2_ce0_pipe === 1'b1 && ram_2_we0_pipe === 1'b1)
      $display("[At %t] [%m] [RAM BANK 2 PORT0 WRITE] addr0=%h, d0=%h", $time, ram_2_addr0_pipe, ram_2_d0_pipe);
    if (ram_2_ce1_pipe === 1'b1 && ram_2_we1_pipe !== 1'b0)
      $display("[At %t] [%m] [RAM BANK 2 PORT1 WRITE] addr1=%h, d1=%h", $time, ram_2_addr1_pipe, ram_2_d1_pipe);
//    if (ram_2_ren0 === 1'b1)
//      $display("[At %t] [%m] [RAM BANK 2 PORT0 READ] addr0_pipe1=%h, q0=%h", $time, ram_2_addr0_pipe1, ram_2_q0_pipe);
//    if (ram_2_ren1 === 1'b1)
//      $display("[At %t] [%m] [RAM BANK 2 PORT1 READ] addr1_pipe1=%h, q1=%h", $time, ram_2_addr1_pipe1, ram_2_q1_pipe);
  end
  reg [AWIDTH-1:0] ram_3_addr0_pipe1;
  reg [AWIDTH-1:0] ram_3_addr1_pipe1;
  reg ram_3_ren0;
  reg ram_3_ren1;
  always @(posedge clk) begin
    ram_3_addr0_pipe1 <= ram_3_addr0_pipe;
    ram_3_addr1_pipe1 <= ram_3_addr1_pipe;
    ram_3_ren0 <= ram_3_ce0_pipe & (ram_3_we0_pipe == 0);
    ram_3_ren1 <= ram_3_ce1_pipe & (ram_3_we1_pipe == 0);
  end
  always @(posedge clk) begin
    if (ram_3_ce0_pipe === 1'b1 && ram_3_we0_pipe === 1'b1)
      $display("[At %t] [%m] [RAM BANK 3 PORT0 WRITE] addr0=%h, d0=%h", $time, ram_3_addr0_pipe, ram_3_d0_pipe);
    if (ram_3_ce1_pipe === 1'b1 && ram_3_we1_pipe !== 1'b0)
      $display("[At %t] [%m] [RAM BANK 3 PORT1 WRITE] addr1=%h, d1=%h", $time, ram_3_addr1_pipe, ram_3_d1_pipe);
//    if (ram_3_ren0 === 1'b1)
//      $display("[At %t] [%m] [RAM BANK 3 PORT0 READ] addr0_pipe1=%h, q0=%h", $time, ram_3_addr0_pipe1, ram_3_q0_pipe);
//    if (ram_3_ren1 === 1'b1)
//      $display("[At %t] [%m] [RAM BANK 3 PORT1 READ] addr1_pipe1=%h, q1=%h", $time, ram_3_addr1_pipe1, ram_3_q1_pipe);
  end
`endif
endmodule

