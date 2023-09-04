
open_checkpoint full_design_rezip.dcp
update_noc_qos

create_generated_clock -name clkwiz_aclk_kernel_00_clk_out1 -divide_by 10 -multiply_by 150 -source top_i/blp/blp_logic/ulp_clocking/clkwiz_aclk_kernel_00/inst/clock_primitive_inst/MMCME5_inst/CLKIN1 top_i/blp/blp_logic/ulp_clocking/clkwiz_aclk_kernel_00/inst/clock_primitive_inst/MMCME5_inst/CLKOUT0

write_checkpoint -force top_wrapper_final.dcp
write_edif -force top_wrapper_final.edf
write_checkpoint -force -cell [get_cells top_i/ulp] ulp_final.dcp

report_utilization -file hw_bb_locked_utilization_placed.rpt
report_route_status -file hw_bb_locked_route_status.rpt
report_timing_summary -max_paths 10 -report_unconstrained -file hw_bb_locked_timing_summary_routed.rpt -warn_on_violation
report_bus_skew -warn_on_violation -file hw_bb_locked_bus_skew_routed.rpt
report_clock_utilization -file hw_bb_locked_clock_utilization_routed.rpt
report_drc -file hw_bb_locked_drc.rpt

set_property HD.PLATFORM_WRAPPER 1 [get_cells top_i/ulp]
write_device_image -force -cell top_i/ulp -file top_i_ulp_my_rm_partial
