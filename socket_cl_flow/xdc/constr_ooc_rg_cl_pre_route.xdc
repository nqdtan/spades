create_pblock pblock_stitch
add_cells_to_pblock [get_pblocks pblock_stitch] [get_cells custom_logic]
add_cells_to_pblock [get_pblocks pblock_stitch] [get_cells lsu_rg_cl_glue]
add_cells_to_pblock [get_pblocks pblock_stitch] [get_cells ff_bridge]

# w=1, h=1
resize_pblock pblock_stitch -add {SLICE_X166Y96:SLICE_X203Y187 DSP58_CPLX_X2Y48:DSP58_CPLX_X3Y93 DSP_X4Y48:DSP_X7Y93 IRI_QUAD_X103Y412:IRI_QUAD_X127Y779 RAMB18_X5Y50:RAMB18_X5Y95 RAMB36_X5Y25:RAMB36_X5Y47 URAM288_X3Y25:URAM288_X3Y47 URAM_CAS_DLY_X3Y1:URAM_CAS_DLY_X3Y1}
resize_pblock pblock_stitch -add {RAMB36_X6Y25:RAMB36_X7Y47}

# w=2, h=1
#resize_pblock pblock_stitch -add {SLICE_X94Y96:SLICE_X203Y187 DSP58_CPLX_X0Y48:DSP58_CPLX_X3Y93 DSP_X0Y48:DSP_X7Y93 IRI_QUAD_X57Y412:IRI_QUAD_X127Y779 NOC_NMU512_X1Y2:NOC_NMU512_X1Y3 NOC_NSU512_X1Y2:NOC_NSU512_X1Y3 RAMB18_X2Y50:RAMB18_X5Y95 RAMB36_X2Y25:RAMB36_X5Y47 URAM288_X2Y25:URAM288_X3Y47 URAM_CAS_DLY_X2Y1:URAM_CAS_DLY_X3Y1}
#resize_pblock pblock_stitch -add {RAMB36_X6Y25:RAMB36_X7Y47}

# w=1, h=2
#resize_pblock pblock_stitch -add {SLICE_X166Y96:SLICE_X203Y187 DSP58_CPLX_X2Y48:DSP58_CPLX_X3Y93 DSP_X4Y48:DSP_X7Y93 IRI_QUAD_X103Y412:IRI_QUAD_X127Y779 RAMB18_X5Y50:RAMB18_X5Y95 RAMB36_X5Y25:RAMB36_X5Y47 URAM288_X3Y25:URAM288_X3Y47 URAM_CAS_DLY_X3Y1:URAM_CAS_DLY_X3Y1}
#resize_pblock pblock_stitch -add {RAMB36_X6Y25:RAMB36_X7Y47}
#resize_pblock pblock_stitch -add {SLICE_X166Y188:SLICE_X203Y283 DSP58_CPLX_X2Y94:DSP58_CPLX_X3Y141 DSP_X4Y94:DSP_X7Y141 IRI_QUAD_X103Y780:IRI_QUAD_X128Y1163 RAMB18_X5Y96:RAMB18_X7Y143 RAMB36_X5Y48:RAMB36_X7Y71 URAM288_X3Y48:URAM288_X3Y71 URAM_CAS_DLY_X3Y2:URAM_CAS_DLY_X3Y2}
#resize_pblock pblock_stitch -add {SLICE_X204Y188:SLICE_X235Y283 IRI_QUAD_X130Y780:IRI_QUAD_X147Y1163 NOC_NMU512_X2Y4:NOC_NMU512_X2Y5 NOC_NSU512_X2Y4:NOC_NSU512_X2Y5}

set_property CONTAIN_ROUTING 1 [get_pblocks pblock_stitch]
