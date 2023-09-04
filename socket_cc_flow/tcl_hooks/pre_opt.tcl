read_checkpoint /path/to/spades/socket_cc_flow/ff_bridge/ff_bridge_fixed.dcp

refresh_design

set_property -dict {LOC BUFGCE_X4Y11} [get_cells design_1_i/mbufgce_primitive_0/inst/MBUFGCE_inst]

set_property -dict {BEL H6LUT} [get_cells design_1_i/socket/lut1_primitive_0/inst/lut1_inst]
set_property -dict {LOC SLICE_X234Y96} [get_cells design_1_i/socket/lut1_primitive_0/inst/lut1_inst]

write_checkpoint -force post_synth.dcp
