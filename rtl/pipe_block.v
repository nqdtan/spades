
module pipe_block #(
  parameter NUM_STAGES = 8,
  parameter WIDTH     = 64
) (
  input clk,
  input  [WIDTH-1:0] d,
  output [WIDTH-1:0] q
);

  wire [WIDTH-1:0] in_pipe_next  [NUM_STAGES-1:0];
  wire [WIDTH-1:0] in_pipe_value [NUM_STAGES-1:0];

  genvar i;
  generate
    for (i = 0; i < NUM_STAGES; i = i + 1) begin
      REGISTER #(.N(WIDTH)) pipe_reg (
        .clk(clk),
        .d(in_pipe_next[i]),
        .q(in_pipe_value[i])
      );

      if (i == 0)
        assign in_pipe_next[i] = d;
      else
        assign in_pipe_next[i] = in_pipe_value[i - 1];
    end

    if (NUM_STAGES == 0)
      assign q = d;
    else
      assign q = in_pipe_value[NUM_STAGES-1];
  endgenerate

endmodule

module pipe_block_ce #(
  parameter NUM_STAGES = 8,
  parameter WIDTH     = 64
) (
  input clk,
  input  [WIDTH-1:0] d,
  output [WIDTH-1:0] q,
  input  [NUM_STAGES-1:0] ce
);

  wire [WIDTH-1:0] in_pipe_next  [NUM_STAGES-1:0];
  wire [WIDTH-1:0] in_pipe_value [NUM_STAGES-1:0];

  genvar i;
  generate
    for (i = 0; i < NUM_STAGES; i = i + 1) begin
      REGISTER_CE #(.N(WIDTH)) pipe_reg (
        .clk(clk),
        .ce(ce[i]),
        .d(in_pipe_next[i]),
        .q(in_pipe_value[i])
      );

      if (i == 0)
        assign in_pipe_next[i] = d;
      else
        assign in_pipe_next[i] = in_pipe_value[i - 1];
    end

    if (NUM_STAGES == 0)
      assign q = d;
    else
      assign q = in_pipe_value[NUM_STAGES-1];
  endgenerate

endmodule

module pipe_block_ce1 #(
  parameter NUM_STAGES = 8,
  parameter WIDTH     = 64
) (
  input  clk,
  input  [WIDTH-1:0] d,
  output [WIDTH-1:0] q,
  input  ce
);

  wire [WIDTH-1:0] in_pipe_next  [NUM_STAGES-1:0];
  wire [WIDTH-1:0] in_pipe_value [NUM_STAGES-1:0];

  genvar i;
  generate
    for (i = 0; i < NUM_STAGES; i = i + 1) begin
      REGISTER_CE #(.N(WIDTH)) pipe_reg (
        .clk(clk),
        .ce(ce),
        .d(in_pipe_next[i]),
        .q(in_pipe_value[i])
      );

      if (i == 0)
        assign in_pipe_next[i] = d;
      else
        assign in_pipe_next[i] = in_pipe_value[i - 1];
    end

    if (NUM_STAGES == 0)
      assign q = d;
    else
      assign q = in_pipe_value[NUM_STAGES-1];
  endgenerate

endmodule
