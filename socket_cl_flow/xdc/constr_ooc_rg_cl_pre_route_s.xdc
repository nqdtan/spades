create_pblock pblock_stitch
add_cells_to_pblock [get_pblocks pblock_stitch] [get_cells custom_logic]
add_cells_to_pblock [get_pblocks pblock_stitch] [get_cells lsu_rg_cl_glue]
add_cells_to_pblock [get_pblocks pblock_stitch] [get_cells ff_bridge]
#resize_pblock pblock_stitch -add {SLICE_X166Y96:SLICE_X203Y187 DSP58_CPLX_X2Y48:DSP58_CPLX_X3Y93 DSP_X4Y48:DSP_X7Y93 IRI_QUAD_X103Y412:IRI_QUAD_X127Y779 RAMB18_X5Y50:RAMB18_X5Y95 RAMB36_X5Y25:RAMB36_X5Y47 URAM288_X3Y25:URAM288_X3Y47 URAM_CAS_DLY_X3Y1:URAM_CAS_DLY_X3Y1}
#resize_pblock pblock_stitch -add {RAMB36_X6Y25:RAMB36_X7Y47}

resize_pblock pblock_stitch -add {SLICE_X166Y284:SLICE_X203Y327 DSP58_CPLX_X2Y142:DSP58_CPLX_X3Y163 DSP_X4Y142:DSP_X7Y163 IRI_QUAD_X103Y1164:IRI_QUAD_X129Y1339 RAMB18_X5Y144:RAMB18_X7Y165 RAMB36_X5Y72:RAMB36_X7Y82 URAM288_X3Y72:URAM288_X3Y82}

set_property CONTAIN_ROUTING 1 [get_pblocks pblock_stitch]
