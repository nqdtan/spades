set_property -dict {LOC BUFGCE_X4Y11} [get_cells clk_BUFGCE_inst_LOPT_OOC]
read_xdc /path/to/spades/socket_cl_flow/xdc/constr_ooc_rg_cl_s.xdc
write_checkpoint post_opt.dcp
