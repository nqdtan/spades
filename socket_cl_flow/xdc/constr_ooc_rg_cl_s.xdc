create_clock -period 2.000 -name clk -waveform {0.000 1.000} -add [get_ports clk]

set_clock_latency -source -max -late 10.628 [get_clocks clk]
set_clock_latency -source -min -early 9.3   [get_clocks clk]

create_pblock pblock_rg_cl
add_cells_to_pblock [get_pblocks pblock_rg_cl] [get_cells custom_logic]
add_cells_to_pblock [get_pblocks pblock_rg_cl] [get_cells lsu_rg_cl_glue]

#resize_pblock pblock_rg_cl -add {SLICE_X166Y96:SLICE_X203Y187 DSP58_CPLX_X2Y48:DSP58_CPLX_X3Y93 DSP_X4Y48:DSP_X7Y93 IRI_QUAD_X103Y412:IRI_QUAD_X127Y779 RAMB18_X5Y50:RAMB18_X5Y95 RAMB36_X5Y25:RAMB36_X5Y47 URAM288_X3Y25:URAM288_X3Y47 URAM_CAS_DLY_X3Y1:URAM_CAS_DLY_X3Y1}
#resize_pblock pblock_rg_cl -add {RAMB36_X6Y25:RAMB36_X7Y47}

resize_pblock pblock_rg_cl -add {SLICE_X166Y284:SLICE_X203Y327 DSP58_CPLX_X2Y142:DSP58_CPLX_X3Y163 DSP_X4Y142:DSP_X7Y163 IRI_QUAD_X103Y1164:IRI_QUAD_X129Y1339 RAMB18_X5Y144:RAMB18_X7Y165 RAMB36_X5Y72:RAMB36_X7Y82 URAM288_X3Y72:URAM288_X3Y82}

set_property CONTAIN_ROUTING 1 [get_pblocks pblock_rg_cl]
