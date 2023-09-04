#set_property FIXED_ROUTE { CLE_SLICEL_TOP_0_HQ2_PIN CLE_SLICEL_TOP_0_HQ2 OUT_NN7_BEG3 } [get_nets design_1_i/socket/lut1_primitive_0/inst/O]
set_property FIXED_ROUTE { CLE_SLICEL_TOP_0_HQ_PIN CLE_SLICEL_TOP_0_HQ OUT_SS7_BEG3 } [get_nets design_1_i/socket/lut1_primitive_0/inst/O]

read_xdc /path/to/spades/socket_cc_flow/xdc/constr_pre_route_s.xdc
route_design -auto_delay -nets [get_nets {design_1_i/ff_bridge_0/inst/net_a* design_1_i/ff_bridge_0/inst/net_b*}]

route_design -nets [get_nets {design_1_i/mbufgce_primitive_0/clk_out_o1 design_1_i/mbufgce_primitive_0/clr_n}]

read_xdc /path/to/spades/socket_cc_flow/xdc/constr_pre_route_s1.xdc

write_checkpoint -force post_pre_routed.dcp
