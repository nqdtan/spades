
module imm_gen (
  input  [2:0]  imm_sel,
  input  [31:0] cpu_inst,
  output [31:0] imm_out
);

  reg [31:0] imm_out_comb;
  always @(*) begin
    imm_out_comb = 32'b0;
    case (imm_sel)
      3'b000: imm_out_comb = {{21{cpu_inst[31]}}, cpu_inst[30:25], cpu_inst[24:20]};                     // I-type
      3'b001: imm_out_comb = {{21{cpu_inst[31]}}, cpu_inst[30:25], cpu_inst[11:7]};                      // S-type
      3'b010: imm_out_comb = {{20{cpu_inst[31]}}, cpu_inst[7], cpu_inst[30:25], cpu_inst[11:8], 1'b0};   // B-type
      3'b011: imm_out_comb = {{12{cpu_inst[31]}}, cpu_inst[19:12], cpu_inst[20], cpu_inst[30:21], 1'b0}; // J-type
      3'b100: imm_out_comb = {cpu_inst[31:12], 12'b0};                                                   // U-type
    endcase
  end

  assign imm_out = imm_out_comb;
endmodule
