
module handshake_pipe_block #(
  parameter NUM_STAGES = 8,
  parameter WIDTH = 32
) (
  input clk,
  input valid,
  input ready,

  output valid_pipe,
  output ready_pipe,

  input  [WIDTH-1:0] data,
  output [WIDTH-1:0] data_pipe
);

  wire [WIDTH-1:0] enq_data [NUM_STAGES-1:0];
  wire [WIDTH-1:0] deq_data [NUM_STAGES-1:0];
  wire enq_valid [NUM_STAGES-1:0];
  wire enq_ready [NUM_STAGES-1:0];
  wire deq_valid [NUM_STAGES-1:0];
  wire deq_ready [NUM_STAGES-1:0];

  genvar i;
  generate
    for (i = 0; i < NUM_STAGES; i = i + 1) begin
      fifo #(.WIDTH(WIDTH), .LOGDEPTH(1)) fifo_pipe (
        .clk(clk),
        .enq_data(enq_data[i]),
        .enq_valid(enq_valid[i]),
        .enq_ready(enq_ready[i]),

        .deq_data(deq_data[i]),
        .deq_valid(deq_valid[i]),
        .deq_ready(deq_ready[i])
      );

      if (i == 0) begin
        assign enq_data[i]  = data;
        assign enq_valid[i] = valid;
      end
      else begin
        assign enq_data [i]     = deq_data [i - 1];
        assign enq_valid[i]     = deq_valid[i - 1];
        assign deq_ready[i - 1] = enq_ready[i];
      end
    end
  endgenerate

  assign data_pipe = deq_data[NUM_STAGES-1];
  assign deq_ready[NUM_STAGES-1] = ready;

  assign valid_pipe = deq_valid[NUM_STAGES-1];
  assign ready_pipe = enq_ready[0];
endmodule
