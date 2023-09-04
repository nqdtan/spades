set_property -dict {LOC BUFGCE_X4Y11} [get_cells clk_BUFGCE_inst_LOPT_OOC]
read_xdc /path/to/spades/socket_cl_flow/xdc/constr_ooc_rg_cl.xdc
set_property USER_CLOCK_ROOT X5Y2 [get_nets clk]
write_checkpoint post_opt.dcp
