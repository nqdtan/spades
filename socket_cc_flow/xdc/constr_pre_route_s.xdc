
create_pblock pblock_stitch
#add_cells_to_pblock [get_pblocks pblock_stitch] [get_cells design_1_i]
add_cells_to_pblock [get_pblocks pblock_stitch] [get_cells design_1_i/socket]
add_cells_to_pblock [get_pblocks pblock_stitch] [get_cells design_1_i/ff_bridge_0]

#resize_pblock pblock_stitch -add {SLICE_X206Y96:SLICE_X235Y187 IRI_QUAD_X131Y412:IRI_QUAD_X147Y779 NOC_NMU512_X2Y2:NOC_NMU512_X2Y3 NOC_NSU512_X2Y2:NOC_NSU512_X2Y3}
resize_pblock pblock_stitch -add {SLICE_X206Y284:SLICE_X235Y327 IRI_QUAD_X131Y1164:IRI_QUAD_X147Y1339 NOC_NMU512_X2Y6:NOC_NMU512_X2Y6 NOC_NSU512_X2Y6:NOC_NSU512_X2Y6} 
#resize_pblock pblock_stitch -add {SLICE_X206Y284:SLICE_X237Y327 IRI_QUAD_X131Y1164:IRI_QUAD_X148Y1339 NOC_NMU512_X2Y6:NOC_NMU512_X2Y6 NOC_NSU512_X2Y6:NOC_NSU512_X2Y6}
#resize_pblock pblock_stitch -add {SLICE_X208Y284:SLICE_X235Y327 IRI_QUAD_X132Y1164:IRI_QUAD_X147Y1339 NOC_NMU512_X2Y6:NOC_NMU512_X2Y6 NOC_NSU512_X2Y6:NOC_NSU512_X2Y6}

#resize_pblock pblock_stitch -add {SLICE_X206Y284:SLICE_X239Y327 IRI_QUAD_X131Y1164:IRI_QUAD_X149Y1339 NOC_NMU512_X2Y6:NOC_NMU512_X2Y6 NOC_NSU512_X2Y6:NOC_NSU512_X2Y6}
#resize_pblock pblock_stitch -add {SLICE_X206Y236:SLICE_X235Y283 IRI_QUAD_X131Y972:IRI_QUAD_X147Y1163 NOC_NMU512_X2Y5:NOC_NMU512_X2Y5 NOC_NSU512_X2Y5:NOC_NSU512_X2Y5}

resize_pblock pblock_stitch -add {SLICE_X200Y292:SLICE_X205Y315}
#resize_pblock pblock_stitch -add {SLICE_X192Y292:SLICE_X205Y315}
#resize_pblock pblock_stitch -add {SLICE_X196Y292:SLICE_X205Y315}
#resize_pblock pblock_stitch -add {SLICE_X204Y292:SLICE_X205Y315}

resize_pblock pblock_stitch -add {BUFGCE_X4Y0:BUFGCE_X4Y23}
#resize_pblock pblock_stitch -add {BUFDIV_LEAF_X74Y64:BUFDIV_LEAF_X74Y95}

set_property CONTAIN_ROUTING 1 [get_pblocks pblock_stitch]

#create_pblock pblock_stitch0
#add_cells_to_pblock [get_pblocks pblock_stitch0] [get_cells design_1_i/socket]
#resize_pblock pblock_stitch0 -add {SLICE_X206Y284:SLICE_X235Y327 IRI_QUAD_X131Y1164:IRI_QUAD_X147Y1339 NOC_NMU512_X2Y6:NOC_NMU512_X2Y6 NOC_NSU512_X2Y6:NOC_NSU512_X2Y6} 
#resize_pblock pblock_stitch0 -add {BUFGCE_X4Y0:BUFGCE_X4Y23}
#set_property CONTAIN_ROUTING 1 [get_pblocks pblock_stitch0]
