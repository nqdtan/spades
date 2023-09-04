write_checkpoint -force post_synth.dcp

set_property -dict {LOC BUFGCE_X4Y11} [get_cells design_1_i/mbufgce_primitive_0/inst/MBUFGCE_inst]

set_property -dict {BEL H6LUT} [get_cells design_1_i/socket/lut1_primitive_0/inst/lut1_inst]

#set_property -dict {LOC SLICE_X234Y96} [get_cells design_1_i/socket/lut1_primitive_0/inst/lut1_inst]
# for w=1,h=3
#set_property -dict {LOC SLICE_X166Y0} [get_cells design_1_i/socket/lut1_primitive_0/inst/lut1_inst]
# for sub 
# case w=1,h=1
#set_property -dict {LOC SLICE_X166Y327} [get_cells design_1_i/socket/lut1_primitive_0/inst/lut1_inst]
set_property -dict {LOC SLICE_X234Y284} [get_cells design_1_i/socket/lut1_primitive_0/inst/lut1_inst]
# case w=3,h=1
#set_property -dict {LOC SLICE_X94Y327} [get_cells design_1_i/socket/lut1_primitive_0/inst/lut1_inst]
