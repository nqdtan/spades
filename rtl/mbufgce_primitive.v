
module mbufgce_primitive (
  input clk_in,
  input ce,
  input clr_n,
  (* DONT_TOUCH = "yes" *) output clk_out_o1,
  (* DONT_TOUCH = "yes" *) output clk_out_o2
);

  MBUFGCE #(
    .CE_TYPE("SYNC"),
    .IS_CE_INVERTED(1'b0),
    .IS_I_INVERTED(1'b0),
    .MODE("PERFORMANCE"),
    .SIM_DEVICE("VERSAL_AI_CORE"),
    .STARTUP_SYNC("TRUE")
  ) MBUFGCE_inst (
    .CE(ce),
    .CLRB_LEAF(clr_n),
    .I(clk_in),
    .O1(clk_out_o1),
    .O2(clk_out_o2)
  );

endmodule
