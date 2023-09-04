create_pblock pblock_util
add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/axi_dbg_fw]
add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/axi_dbg_hub]
add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/axi_gpio_null_user]
add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/axi_ic_user]
add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/axi_ic_user_extend]
add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/axi_register_slice_0]
add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/axi_register_slice_1]
add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/axi_register_slice_2]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/axi_sc_plram]
add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/gate_dbgfw_or]
add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/ip_pipe_dbg_hub_fw_00]
add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/ip_pipe_ext_tog_kernel_00_null]
add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/ip_pipe_ext_tog_kernel_01_null]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/kernel_interrupt]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/kernel_interrupt_xlconcat_0_In0_1_interrupt_concat]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/plram_ctrl]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/plram_ctrl_bram]
add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/reset_controllers]
add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/xlconstant_0]
add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/socket_manager_0]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/axi_noc_h2c]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/axi_noc_kernel0]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/mbufgce_primitive_0]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/mbufgce_primitive_1]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/mbufgce_primitive_2]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/mbufgce_primitive_3]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/mbufgce_primitive_4]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/mbufgce_primitive_5]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/mbufgce_primitive_6]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/mbufgce_primitive_7]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/mbufgce_primitive_8]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/mbufgce_primitive_9]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/mbufgce_primitive_10]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/mbufgce_primitive_11]
#add_cells_to_pblock [get_pblocks pblock_util] [get_cells top_i/ulp/mbufgce_primitive_src]

#resize_pblock pblock_util -add {SLICE_X40Y0:SLICE_X70Y327 SLICE_X4Y264:SLICE_X16Y327 SLICE_X20Y140:SLICE_X35Y327 SLICE_X36Y140:SLICE_X39Y327}
#resize_pblock pblock_util -add {SLICE_X40Y0:SLICE_X75Y187 SLICE_X4Y264:SLICE_X16Y327 SLICE_X20Y140:SLICE_X35Y327 SLICE_X36Y140:SLICE_X39Y187}
#resize_pblock pblock_util -add {SLICE_X40Y0:SLICE_X87Y187 SLICE_X4Y264:SLICE_X16Y327 SLICE_X20Y140:SLICE_X35Y327 SLICE_X36Y140:SLICE_X39Y187}
resize_pblock pblock_util -add {SLICE_X40Y0:SLICE_X87Y327 SLICE_X4Y264:SLICE_X16Y327 SLICE_X20Y140:SLICE_X35Y327 SLICE_X36Y140:SLICE_X39Y327}

#resize_pblock pblock_util -add {SLICE_X40Y0:SLICE_X69Y327 SLICE_X4Y264:SLICE_X16Y327 SLICE_X20Y140:SLICE_X35Y327 SLICE_X36Y140:SLICE_X39Y327}

resize_pblock pblock_util -add {RAMB18_X1Y2:RAMB18_X1Y165 RAMB18_X0Y72:RAMB18_X0Y165}
#resize_pblock pblock_util -add {RAMB18_X1Y0:RAMB18_X1Y95 RAMB18_X0Y72:RAMB18_X0Y165}

resize_pblock pblock_util -add {RAMB36_X1Y1:RAMB36_X1Y82 RAMB36_X0Y36:RAMB36_X0Y82}
#resize_pblock pblock_util -add {RAMB36_X1Y0:RAMB36_X1Y47 RAMB36_X0Y36:RAMB36_X0Y82}

resize_pblock pblock_util -add {URAM288_X1Y1:URAM288_X1Y82 URAM288_X0Y36:URAM288_X0Y82}
#resize_pblock pblock_util -add {URAM288_X1Y0:URAM288_X1Y47 URAM288_X0Y36:URAM288_X0Y82}
resize_pblock pblock_util -add {NOC_NMU512_X0Y0:NOC_NMU512_X0Y4}
resize_pblock pblock_util -add {NOC_NSU512_X0Y0:NOC_NSU512_X0Y1}

#resize_pblock [get_pblocks pblock_util] -add {BUFGCE_X4Y0:BUFGCE_X4Y23}

set_property PARENT pblock_dynamic_region [get_pblocks pblock_util]

#set_property -dict {LOC NOC_NMU512_X0Y0} [get_cells top_i/ulp/axi_noc_kernel0/inst/S00_AXI_nmu/bd_*_S00_AXI_nmu_0_top_INST/NOC_NMU512_INST]
#set_property -dict {LOC NOC_NMU512_X0Y1} [get_cells top_i/ulp/axi_noc_kernel0/inst/S01_AXI_nmu/bd_*_S01_AXI_nmu_0_top_INST/NOC_NMU512_INST]
#set_property -dict {LOC NOC_NMU512_X0Y2} [get_cells top_i/ulp/axi_noc_kernel0/inst/S02_AXI_nmu/bd_*_S02_AXI_nmu_0_top_INST/NOC_NMU512_INST]
set_property -dict {LOC NOC_NMU512_X0Y1} [get_cells top_i/ulp/axi_noc_kernel0/inst/S00_AXI_nmu/bd_*_S00_AXI_nmu_0_top_INST/NOC_NMU512_INST]
set_property -dict {LOC NOC_NMU512_X0Y0} [get_cells top_i/ulp/axi_noc_kernel0/inst/M01_INI_stub_nmu/bd_0ad1_M01_INI_stub_nmu_0_top_INST/NOC_NMU512_INST]
set_property -dict {LOC NOC_NMU512_X0Y2} [get_cells top_i/ulp/axi_noc_kernel0/inst/M02_INI_stub_nmu/bd_0ad1_M02_INI_stub_nmu_0_top_INST/NOC_NMU512_INST]

resize_pblock [get_pblocks pblock_dynamic_region] -add {BUFGCE_X4Y0:BUFGCE_X4Y23}

set_property -dict {CLOCK_REGION X4Y0} [get_cells top_i/ulp/mbufgce_primitive_0/inst/MBUFGCE_inst]
set_property -dict {CLOCK_REGION X4Y0} [get_cells top_i/ulp/mbufgce_primitive_1/inst/MBUFGCE_inst]
set_property -dict {CLOCK_REGION X4Y0} [get_cells top_i/ulp/mbufgce_primitive_2/inst/MBUFGCE_inst]
set_property -dict {CLOCK_REGION X4Y0} [get_cells top_i/ulp/mbufgce_primitive_3/inst/MBUFGCE_inst]
set_property -dict {CLOCK_REGION X4Y0} [get_cells top_i/ulp/mbufgce_primitive_4/inst/MBUFGCE_inst]
set_property -dict {CLOCK_REGION X4Y0} [get_cells top_i/ulp/mbufgce_primitive_5/inst/MBUFGCE_inst]
set_property -dict {CLOCK_REGION X4Y0} [get_cells top_i/ulp/mbufgce_primitive_6/inst/MBUFGCE_inst]
set_property -dict {CLOCK_REGION X4Y0} [get_cells top_i/ulp/mbufgce_primitive_7/inst/MBUFGCE_inst]
set_property -dict {CLOCK_REGION X4Y0} [get_cells top_i/ulp/mbufgce_primitive_8/inst/MBUFGCE_inst]
set_property -dict {CLOCK_REGION X4Y0} [get_cells top_i/ulp/mbufgce_primitive_9/inst/MBUFGCE_inst]
set_property -dict {CLOCK_REGION X4Y0} [get_cells top_i/ulp/mbufgce_primitive_10/inst/MBUFGCE_inst]
set_property -dict {CLOCK_REGION X4Y0} [get_cells top_i/ulp/mbufgce_primitive_11/inst/MBUFGCE_inst]
set_property -dict {CLOCK_REGION X4Y0} [get_cells top_i/ulp/mbufgce_primitive_src/inst/MBUFGCE_inst]

# clock track 0 is utilized by top_i/blp/blp_logic/ulp_clocking/shell_utils_ucc/inst/genblk1[0].aclk_kernel_inst/clock_throttling_aclk_kernel_00/ICCLK_0
set_property PROHIBIT 1 [get_sites BUFGCE_X4Y0]
# clock track 1 is utilized by top_i/blp/blp_logic/ulp_clocking/shell_utils_ucc/inst/genblk1[0].aclk_kernel_inst/clock_throttling_aclk_kernel_00/aclk_kernel_00
set_property PROHIBIT 1 [get_sites BUFGCE_X4Y1]
# clock track 3 is utilized by top_i/blp/blp_logic/ulp_clocking/shell_utils_ucc/inst/genblk1[1].aclk_kernel_inst/clock_throttling_aclk_kernel_00/aclk_kernel_cont_01
set_property PROHIBIT 1 [get_sites BUFGCE_X4Y3]
# clock track 7 is utilized by top_i/blp/cips/inst/pspmc_0/inst/pl0_ref_clk
set_property PROHIBIT 1 [get_sites BUFGCE_X4Y7]
# clock track 8 is utilized by top_i/blp/blp_logic/ulp_clocking/shell_utils_ucc/inst/genblk1[1].aclk_kernel_inst/clock_throttling_aclk_kernel_00/ICCLK_0
set_property PROHIBIT 1 [get_sites BUFGCE_X4Y8]
# clock track 10 is utilized by top_i/blp/cips/inst/pspmc_0/inst/pl1_ref_clk
set_property PROHIBIT 1 [get_sites BUFGCE_X4Y10]
# clock track 11 is utilized by top_i/blp/cips/inst/pspmc_0/inst/pl2_ref_clk
set_property PROHIBIT 1 [get_sites BUFGCE_X4Y11]
# clock track 12 is utilized by top_i/blp/blp_logic/ulp_clocking/shell_utils_ucc/inst/genblk1[1].aclk_kernel_inst/clock_throttling_aclk_kernel_00/aclk_kernel_01
set_property PROHIBIT 1 [get_sites BUFGCE_X4Y12]
# clock track 23 is utilized by top_i/blp/blp_logic/ulp_clocking/shell_utils_ucc/inst/genblk1[0].aclk_kernel_inst/clock_throttling_aclk_kernel_00/aclk_kernel_cont_00
set_property PROHIBIT 1 [get_sites BUFGCE_X4Y23]

set_false_path -to [get_pins top_i/ulp/mbufgce_primitive_0/inst/MBUFGCE_inst/CE]
set_false_path -to [get_pins top_i/ulp/mbufgce_primitive_1/inst/MBUFGCE_inst/CE]
set_false_path -to [get_pins top_i/ulp/mbufgce_primitive_2/inst/MBUFGCE_inst/CE]
set_false_path -to [get_pins top_i/ulp/mbufgce_primitive_3/inst/MBUFGCE_inst/CE]
set_false_path -to [get_pins top_i/ulp/mbufgce_primitive_4/inst/MBUFGCE_inst/CE]
set_false_path -to [get_pins top_i/ulp/mbufgce_primitive_5/inst/MBUFGCE_inst/CE]
set_false_path -to [get_pins top_i/ulp/mbufgce_primitive_6/inst/MBUFGCE_inst/CE]
set_false_path -to [get_pins top_i/ulp/mbufgce_primitive_7/inst/MBUFGCE_inst/CE]
set_false_path -to [get_pins top_i/ulp/mbufgce_primitive_8/inst/MBUFGCE_inst/CE]
set_false_path -to [get_pins top_i/ulp/mbufgce_primitive_9/inst/MBUFGCE_inst/CE]
set_false_path -to [get_pins top_i/ulp/mbufgce_primitive_10/inst/MBUFGCE_inst/CE]
set_false_path -to [get_pins top_i/ulp/mbufgce_primitive_11/inst/MBUFGCE_inst/CE]

set_property CONTAIN_ROUTING 1 [get_pblocks pblock_util]
