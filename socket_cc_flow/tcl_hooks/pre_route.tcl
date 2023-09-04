set_property FIXED_ROUTE { CLE_SLICEL_TOP_0_HQ2_PIN CLE_SLICEL_TOP_0_HQ2 OUT_NN7_BEG3 } [get_nets design_1_i/socket/lut1_primitive_0/inst/O]
read_xdc /path/to/spades/socket_cc_flow/xdc/constr_pre_route.xdc

route_design -nets [get_nets {design_1_i/mbufgce_primitive_0/clk_out_o1 design_1_i/mbufgce_primitive_0/clr_n}]

read_xdc /path/to/spades/socket_cc_flow/xdc/constr_pre_route1.xdc

write_checkpoint -force post_pre_routed.dcp
