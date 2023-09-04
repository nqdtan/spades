
module branch_comp (
  input br_un,       // 1: Unsigned LT, 0: Signed LT
  input [31:0] br_a,
  input [31:0] br_b,
  output br_eq,
  output br_lt
);

  assign br_eq = (br_a == br_b);
  assign br_lt = (br_un) ? br_a < br_b : $signed(br_a) < $signed(br_b);

endmodule
