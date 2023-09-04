open_checkpoint socket_rg_cl.dcp
set_property DONT_TOUCH 0 [get_nets ff_bridge/net_a*]
set_property DONT_TOUCH 0 [get_nets ff_bridge/net_b*]
set_property DONT_TOUCH 0 [get_nets ff_bridge/clk0]
set_property DONT_TOUCH 0 [get_cells ff_bridge/cell_c*]
remove_cell ff_bridge/cell_c*

write_checkpoint -force socket_rg_cl.dcp
write_edif -force socket_rg_cl.edf

