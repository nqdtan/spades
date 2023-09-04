
(* DONT_TOUCH = "yes" *) module lut1_primitive #(
  parameter INIT = 2'h1
) (
  input I0,
  output O
);
  LUT1 #(
    .INIT(INIT)
  ) lut1_inst (
    .I0(I0),
    .O(O)
  );

endmodule
