`include "Opcode.vh"

module alu (
  input [2:0]   alu_sel0,
  input         alu_sel1,
  input [31:0]  alu_a,
  input [31:0]  alu_b,
  output [31:0] alu_out
);

  reg [31:0] alu_out_comb;

  always @(*) begin
    alu_out_comb = 32'b0;
    casez ({alu_sel0, alu_sel1})
      {`FNC_ADD_SUB, 1'b0}: alu_out_comb = alu_a + alu_b;
      {`FNC_ADD_SUB, 1'b1}: alu_out_comb = alu_a - alu_b;
      {`FNC_SLL,     1'b?}: alu_out_comb = alu_a << alu_b[4:0];
      {`FNC_SLT,     1'b?}: alu_out_comb = ($signed(alu_a) < $signed(alu_b)) ? 32'b1 : 32'b0;
      {`FNC_SLTU,    1'b?}: alu_out_comb = (alu_a < alu_b) ? 32'b1 : 32'b0;
      {`FNC_XOR,     1'b?}: alu_out_comb = alu_a ^ alu_b;
      {`FNC_OR,      1'b?}: alu_out_comb = alu_a | alu_b;
      {`FNC_AND,     1'b?}: alu_out_comb = alu_a & alu_b;
      {`FNC_SRL_SRA, 1'b0}: alu_out_comb = alu_a >> alu_b[4:0];
      {`FNC_SRL_SRA, 1'b1}: alu_out_comb = $signed(alu_a) >>> alu_b[4:0];
    endcase
  end

  assign alu_out = alu_out_comb;

endmodule
