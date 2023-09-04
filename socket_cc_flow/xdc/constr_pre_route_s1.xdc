create_pblock pblock_stitch0
add_cells_to_pblock [get_pblocks pblock_stitch0] [get_cells design_1_i/socket]
resize_pblock pblock_stitch0 -add {SLICE_X206Y284:SLICE_X235Y327 IRI_QUAD_X131Y1164:IRI_QUAD_X147Y1339 NOC_NMU512_X2Y6:NOC_NMU512_X2Y6 NOC_NSU512_X2Y6:NOC_NSU512_X2Y6} 
resize_pblock pblock_stitch0 -add {BUFGCE_X4Y0:BUFGCE_X4Y23}
set_property CONTAIN_ROUTING 1 [get_pblocks pblock_stitch0]
