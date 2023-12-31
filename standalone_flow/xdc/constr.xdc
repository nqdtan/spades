create_clock -period 2.0 -name aclk -add [get_ports aclk]

# 9.943 - 0.077
set_clock_latency -source -max -late 10.628 [get_clocks aclk]

# 8.706 - 0.065 
set_clock_latency -source -min -early 9.3  [get_clocks aclk]

#set_input_jitter [get_clocks aclk] 0.194

create_pblock pblock_util
add_cells_to_pblock [get_pblocks pblock_util] [get_cells -quiet [list design_1_i/socket]]
add_cells_to_pblock [get_pblocks pblock_util] [get_cells -quiet [list design_1_i/mbufgce_primitive_0]]


#w=1,h=1
resize_pblock pblock_util -add {SLICE_X166Y96:SLICE_X235Y187 DSP58_CPLX_X2Y48:DSP58_CPLX_X3Y93 DSP_X4Y48:DSP_X7Y93 IRI_QUAD_X103Y412:IRI_QUAD_X147Y779 NOC_NMU512_X2Y2:NOC_NMU512_X2Y3 NOC_NSU512_X2Y2:NOC_NSU512_X2Y3 RAMB18_X5Y50:RAMB18_X7Y95 RAMB36_X5Y25:RAMB36_X7Y47 URAM288_X3Y25:URAM288_X3Y47 URAM_CAS_DLY_X3Y1:URAM_CAS_DLY_X3Y1} -remove {SLICE_X166Y92:SLICE_X235Y187 DSP58_CPLX_X2Y46:DSP58_CPLX_X3Y93 DSP_X4Y46:DSP_X7Y93 IRI_QUAD_X103Y396:IRI_QUAD_X147Y779 NOC_NMU512_X2Y2:NOC_NMU512_X2Y3 NOC_NSU512_X2Y2:NOC_NSU512_X2Y3 RAMB18_X5Y48:RAMB18_X7Y95 RAMB36_X5Y24:RAMB36_X7Y47 URAM288_X3Y24:URAM288_X3Y47 URAM_CAS_DLY_X3Y1:URAM_CAS_DLY_X3Y1} -locs keep_all

#w=2,h=1
#resize_pblock pblock_util -add {SLICE_X166Y96:SLICE_X307Y187 DSP58_CPLX_X2Y48:DSP58_CPLX_X5Y93 DSP_X4Y48:DSP_X11Y93 IRI_QUAD_X103Y412:IRI_QUAD_X193Y779 NOC_NMU512_X2Y2:NOC_NMU512_X3Y3 NOC_NSU512_X2Y2:NOC_NSU512_X3Y3 RAMB18_X5Y50:RAMB18_X10Y95 RAMB36_X5Y25:RAMB36_X10Y47 URAM288_X3Y25:URAM288_X4Y47 URAM_CAS_DLY_X3Y1:URAM_CAS_DLY_X4Y1} -remove {SLICE_X166Y96:SLICE_X235Y187 DSP58_CPLX_X2Y48:DSP58_CPLX_X3Y93 DSP_X4Y48:DSP_X7Y93 IRI_QUAD_X103Y412:IRI_QUAD_X147Y779 NOC_NMU512_X2Y2:NOC_NMU512_X2Y3 NOC_NSU512_X2Y2:NOC_NSU512_X2Y3 RAMB18_X5Y50:RAMB18_X7Y95 RAMB36_X5Y25:RAMB36_X7Y47 URAM288_X3Y25:URAM288_X3Y47 URAM_CAS_DLY_X3Y1:URAM_CAS_DLY_X3Y1} -locs keep_all

#w=1,h=2
#resize_pblock pblock_util -add {SLICE_X166Y96:SLICE_X235Y283 DSP58_CPLX_X2Y48:DSP58_CPLX_X3Y141 DSP_X4Y48:DSP_X7Y141 IRI_QUAD_X103Y412:IRI_QUAD_X147Y1163 NOC_NMU512_X2Y2:NOC_NMU512_X2Y5 NOC_NSU512_X2Y2:NOC_NSU512_X2Y5 RAMB18_X5Y50:RAMB18_X7Y143 RAMB36_X5Y25:RAMB36_X7Y71 URAM288_X3Y25:URAM288_X3Y71 URAM_CAS_DLY_X3Y1:URAM_CAS_DLY_X3Y2} -remove {SLICE_X166Y96:SLICE_X307Y283 DSP58_CPLX_X2Y48:DSP58_CPLX_X5Y141 DSP_X4Y48:DSP_X11Y141 IRI_QUAD_X103Y412:IRI_QUAD_X193Y1163 NOC_NMU512_X2Y2:NOC_NMU512_X3Y5 NOC_NSU512_X2Y2:NOC_NSU512_X3Y5 RAMB18_X5Y50:RAMB18_X10Y143 RAMB36_X5Y25:RAMB36_X10Y71 URAM288_X3Y25:URAM288_X4Y71 URAM_CAS_DLY_X3Y1:URAM_CAS_DLY_X4Y2} -locs keep_all

#w=1,h=3
#resize_pblock pblock_util -add {SLICE_X166Y0:SLICE_X235Y283 DSP58_CPLX_X2Y0:DSP58_CPLX_X3Y141 DSP_X4Y0:DSP_X7Y141 IRI_QUAD_X103Y28:IRI_QUAD_X147Y1163 NOC_NMU512_X2Y0:NOC_NMU512_X2Y5 NOC_NSU512_X2Y0:NOC_NSU512_X2Y5 RAMB18_X5Y2:RAMB18_X7Y143 RAMB36_X5Y1:RAMB36_X7Y71 URAM288_X3Y1:URAM288_X3Y71 URAM_CAS_DLY_X3Y0:URAM_CAS_DLY_X3Y2} -remove {SLICE_X166Y0:SLICE_X235Y283 DSP58_CPLX_X2Y0:DSP58_CPLX_X3Y141 DSP_X4Y0:DSP_X7Y141 IRI_QUAD_X103Y0:IRI_QUAD_X147Y1163 NOC_NMU512_X2Y0:NOC_NMU512_X2Y5 NOC_NSU512_X2Y0:NOC_NSU512_X2Y5 RAMB18_X5Y0:RAMB18_X7Y143 RAMB36_X5Y0:RAMB36_X7Y71 URAM288_X3Y0:URAM288_X3Y71 URAM_CAS_DLY_X3Y0:URAM_CAS_DLY_X3Y2} -locs keep_all

#w=3,h=1
#resize_pblock pblock_util -add {SLICE_X94Y96:SLICE_X307Y187 DSP58_CPLX_X0Y48:DSP58_CPLX_X5Y93 DSP_X0Y48:DSP_X11Y93 IRI_QUAD_X57Y412:IRI_QUAD_X193Y779 NOC_NMU512_X1Y2:NOC_NMU512_X3Y3 NOC_NSU512_X1Y2:NOC_NSU512_X3Y3 RAMB18_X2Y50:RAMB18_X10Y95 RAMB36_X2Y25:RAMB36_X10Y47 URAM288_X2Y25:URAM288_X4Y47 URAM_CAS_DLY_X2Y1:URAM_CAS_DLY_X4Y1} -remove {SLICE_X96Y96:SLICE_X307Y187 DSP58_CPLX_X0Y48:DSP58_CPLX_X5Y93 DSP_X0Y48:DSP_X11Y93 IRI_QUAD_X58Y412:IRI_QUAD_X193Y779 NOC_NMU512_X1Y2:NOC_NMU512_X3Y3 NOC_NSU512_X1Y2:NOC_NSU512_X3Y3 RAMB18_X2Y50:RAMB18_X10Y95 RAMB36_X2Y25:RAMB36_X10Y47 URAM288_X2Y25:URAM288_X4Y47 URAM_CAS_DLY_X2Y1:URAM_CAS_DLY_X4Y1} -locs keep_all

#w=2,h=2
#resize_pblock pblock_util -add {SLICE_X166Y96:SLICE_X307Y283 DSP58_CPLX_X2Y48:DSP58_CPLX_X5Y141 DSP_X4Y48:DSP_X11Y141 IRI_QUAD_X103Y412:IRI_QUAD_X193Y1163 NOC_NMU512_X2Y2:NOC_NMU512_X3Y5 NOC_NSU512_X2Y2:NOC_NSU512_X3Y5 RAMB18_X5Y50:RAMB18_X10Y143 RAMB36_X5Y25:RAMB36_X10Y71 URAM288_X3Y25:URAM288_X4Y71 URAM_CAS_DLY_X3Y1:URAM_CAS_DLY_X4Y2} -remove {SLICE_X166Y96:SLICE_X307Y281 DSP58_CPLX_X2Y48:DSP58_CPLX_X5Y140 DSP_X4Y48:DSP_X11Y140 IRI_QUAD_X103Y412:IRI_QUAD_X193Y1155 NOC_NMU512_X2Y2:NOC_NMU512_X3Y5 NOC_NSU512_X2Y2:NOC_NSU512_X3Y5 RAMB18_X5Y50:RAMB18_X10Y141 RAMB36_X5Y25:RAMB36_X10Y70 URAM288_X3Y25:URAM288_X4Y70 URAM_CAS_DLY_X3Y1:URAM_CAS_DLY_X4Y1} -locs keep_all

resize_pblock pblock_util -add {BUFDIV_LEAF_X58Y64:BUFDIV_LEAF_X58Y95}
resize_pblock pblock_util -add {BUFGCE_X4Y0:BUFGCE_X4Y23}

set_property IS_SOFT FALSE [get_pblocks pblock_util]

set_property -dict {LOC NOC_NMU512_X2Y2} [get_cells design_1_i/socket/axi_noc_0/inst/S00_AXI_nmu/bd_*_S00_AXI_nmu_0_top_INST/NOC_NMU512_INST]
set_property -dict {LOC NOC_NMU512_X2Y3} [get_cells design_1_i/socket/axi_noc_0/inst/S01_AXI_nmu/bd_*_S01_AXI_nmu_0_top_INST/NOC_NMU512_INST]
set_property -dict {LOC NOC_NSU512_X2Y2} [get_cells design_1_i/socket/axi_noc_0/inst/M00_AXI_nsu/bd_*_M00_AXI_nsu_0_top_INST/NOC_NSU512_INST]
# for w=1,h=3
#set_property -dict {LOC NOC_NMU512_X2Y0} [get_cells design_1_i/socket/axi_noc_0/inst/S00_AXI_nmu/bd_*_S00_AXI_nmu_0_top_INST/NOC_NMU512_INST]
##set_property -dict {LOC NOC_NMU512_X2Y1} [get_cells design_1_i/socket/axi_noc_0/inst/S01_AXI_nmu/bd_*_S01_AXI_nmu_0_top_INST/NOC_NMU512_INST]
#set_property -dict {LOC NOC_NMU512_X2Y2} [get_cells design_1_i/socket/axi_noc_0/inst/S01_AXI_nmu/bd_*_S01_AXI_nmu_0_top_INST/NOC_NMU512_INST]
#set_property -dict {LOC NOC_NSU512_X2Y0} [get_cells design_1_i/socket/axi_noc_0/inst/M00_AXI_nsu/bd_*_M00_AXI_nsu_0_top_INST/NOC_NSU512_INST]

set_property CONTAIN_ROUTING 1 [get_pblocks pblock_util]
