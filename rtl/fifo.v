`timescale 1ns/1ps

module fifo #(
  parameter WIDTH    = 32, // data width is 32-bit
  parameter LOGDEPTH = 3   // 2^3 = 8 entries
) (
  input clk,
  input rst,

  // Write interface (enqueue)
  input  enq_valid,
  input  [WIDTH-1:0] enq_data,
  output enq_ready,

  // Read interface (dequeue)
  output deq_valid,
  output [WIDTH-1:0] deq_data,
  input deq_ready
);

  // For simplicity, we deal with FIFO with depth values of power of two.

  // Dual-port Memory
  // Use port0 for write, port1 for read
  wire [LOGDEPTH-1:0] buffer_addr0, buffer_addr1;
  wire [WIDTH-1:0] buffer_din0, buffer_din1, buffer_dout0, buffer_dout1;
  wire buffer_we0, buffer_we1;

  ASYNC_RAM_DP #(
    .AWIDTH(LOGDEPTH),
    .DWIDTH(WIDTH)
  ) buffer (
    .clk(clk),

    // Port 0
    .q0(buffer_dout0),
    .d0(buffer_din0),
    .addr0(buffer_addr0),
    .we0(buffer_we0),

    // Port 1
    .q1(buffer_dout1),
    .d1(buffer_din1),
    .addr1(buffer_addr1),
    .we1(buffer_we1)
  );

  // Disable write on port1
  assign buffer_we1  = 1'b0;
  assign buffer_din1 = 0;

  wire [LOGDEPTH-1:0] read_ptr_value, read_ptr_next;
  wire read_ptr_ce;
  wire [LOGDEPTH-1:0] write_ptr_value, write_ptr_next;
  wire write_ptr_ce;

  REGISTER_R_CE #(.N(LOGDEPTH)) read_ptr_reg  (
    .q(read_ptr_value),
    .d(read_ptr_next),
    .ce(read_ptr_ce),
    .rst(rst),
    .clk(clk)
  );

  REGISTER_R_CE #(.N(LOGDEPTH)) write_ptr_reg (
    .q(write_ptr_value),
    .d(write_ptr_next),
    .ce(write_ptr_ce),
    .rst(rst),
    .clk(clk)
  );

  wire empty, full;
  assign enq_ready = (~full) | (full & deq_ready);
  assign deq_valid = ~empty;

  wire enq_fire = enq_valid & enq_ready;
  wire deq_fire = deq_valid & deq_ready;

  assign read_ptr_next = read_ptr_value + 1;
  assign read_ptr_ce   = deq_fire;

  assign write_ptr_next = write_ptr_value + 1;
  assign write_ptr_ce   = enq_fire;

  wire last_write;
  REGISTER_R_CE #(.N(1)) last_write_reg (
    .clk(clk),
    .d(1'b1),
    .ce(enq_fire),
    .rst(rst | (deq_fire & (~enq_fire))),
    .q(last_write)
  );

  assign full  = (read_ptr_value == write_ptr_value) & last_write;
  assign empty = (read_ptr_value == write_ptr_value) & (~last_write);

  assign buffer_addr0 = write_ptr_value;
  assign buffer_din0  = enq_data;
  assign buffer_we0   = enq_fire;

  assign buffer_addr1 = read_ptr_value;
  assign deq_data     = empty ? 0 : buffer_dout1;

endmodule

// FIFO with almost-full pin
module fifo_af #(
  parameter WIDTH    = 32, // data width is 32-bit
  parameter LOGDEPTH = 3   // 2^3 = 8 entries
) (
  input clk,
  input rst,

  // Write interface (enqueue)
  input  enq_valid,
  input  [WIDTH-1:0] enq_data,
  output enq_ready,
  output almost_full,

  // Read interface (dequeue)
  output deq_valid,
  output [WIDTH-1:0] deq_data,
  input deq_ready
);

  localparam AF_THRESHOLD = (1 << (LOGDEPTH - 1));

  // For simplicity, we deal with FIFO with depth values of power of two.

  // Dual-port Memory
  // Use port0 for write, port1 for read
  wire [LOGDEPTH-1:0] buffer_addr0, buffer_addr1;
  wire [WIDTH-1:0] buffer_din0, buffer_din1, buffer_dout0, buffer_dout1;
  wire buffer_we0, buffer_we1;

  ASYNC_RAM_DP #(
    .AWIDTH(LOGDEPTH),
    .DWIDTH(WIDTH)
  ) buffer (
    .clk(clk),

    // Port 0
    .q0(buffer_dout0),
    .d0(buffer_din0),
    .addr0(buffer_addr0),
    .we0(buffer_we0),

    // Port 1
    .q1(buffer_dout1),
    .d1(buffer_din1),
    .addr1(buffer_addr1),
    .we1(buffer_we1)
  );

  // Disable write on port1
  assign buffer_we1  = 1'b0;
  assign buffer_din1 = 0;

  wire [LOGDEPTH-1:0] read_ptr_value, read_ptr_next;
  wire read_ptr_ce;
  wire [LOGDEPTH-1:0] write_ptr_value, write_ptr_next;
  wire write_ptr_ce;

  REGISTER_R_CE #(.N(LOGDEPTH)) read_ptr_reg  (
    .q(read_ptr_value),
    .d(read_ptr_next),
    .ce(read_ptr_ce),
    .rst(rst),
    .clk(clk)
  );

  REGISTER_R_CE #(.N(LOGDEPTH)) write_ptr_reg (
    .q(write_ptr_value),
    .d(write_ptr_next),
    .ce(write_ptr_ce),
    .rst(rst),
    .clk(clk)
  );

//  wire empty, full;
//  assign enq_ready = (~full) | (full & deq_ready);
//  assign deq_valid = ~empty;

  wire enq_fire = enq_valid & enq_ready;
  wire deq_fire = deq_valid & deq_ready;

  assign read_ptr_next = read_ptr_value + 1;
  assign read_ptr_ce   = deq_fire;

  assign write_ptr_next = write_ptr_value + 1;
  assign write_ptr_ce   = enq_fire;

  wire empty, full;
  assign enq_ready = (~full) | (full & deq_ready);
  assign deq_valid = ~empty;

  wire last_write;
  REGISTER_R_CE #(.N(1)) last_write_reg (
    .clk(clk),
    .d(1'b1),
    .ce(enq_fire),
    .rst(rst | (deq_fire & (~enq_fire))),
    .q(last_write)
  );

  assign full  = (read_ptr_value == write_ptr_value) & last_write;
  assign empty = (read_ptr_value == write_ptr_value) & (~last_write);

  wire [LOGDEPTH:0] len;
  wire [LOGDEPTH:0] len_next = len + (enq_fire ? 1 : 0) - (deq_fire ? 1 : 0);
  REGISTER_R_CE #(.N(LOGDEPTH + 1)) len_reg (
    .clk(clk),
    .rst(rst),
    .ce(enq_fire | deq_fire),
    .d(len_next),
    .q(len)
  );

  wire almost_full;

  REGISTER_R_CE #(.N(1)) almost_full_reg (
    .clk(clk),
    .rst(len < AF_THRESHOLD),
    .ce(len >= AF_THRESHOLD),
    .d(1'b1),
    .q(almost_full)
  );

  assign buffer_addr0 = write_ptr_value;
  assign buffer_din0  = enq_data;
  assign buffer_we0   = enq_fire;

  assign buffer_addr1 = read_ptr_value;
  assign deq_data     = empty ? 0 : buffer_dout1;

endmodule
