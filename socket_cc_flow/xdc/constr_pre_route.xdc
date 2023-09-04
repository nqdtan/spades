
create_pblock pblock_stitch
add_cells_to_pblock [get_pblocks pblock_stitch] [get_cells design_1_i]

resize_pblock pblock_stitch -add {SLICE_X206Y96:SLICE_X235Y187 IRI_QUAD_X131Y412:IRI_QUAD_X147Y779 NOC_NMU512_X2Y2:NOC_NMU512_X2Y3 NOC_NSU512_X2Y2:NOC_NSU512_X2Y3}
resize_pblock pblock_stitch -add {SLICE_X200Y108:SLICE_X205Y166}

resize_pblock pblock_stitch -add {BUFGCE_X4Y0:BUFGCE_X4Y23}
resize_pblock pblock_stitch -add {BUFDIV_LEAF_X74Y64:BUFDIV_LEAF_X74Y95}

set_property CONTAIN_ROUTING 1 [get_pblocks pblock_stitch]
