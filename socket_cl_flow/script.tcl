set project_name [lindex $argv 0]
set app [lindex $argv 1]
set src_dir ../rtl

create_project -force ${project_name} ${project_name} -part xcvc1902-vsvd1760-2MP-e-S
set_property board_part xilinx.com:vck5000:part0:1.0 [current_project]

# Add source files
add_files -norecurse ${src_dir}/rg_cl_wrapper.v
add_files -norecurse [glob ../benchmarks/hls_kernel/${app}/proj/solution_cl_${app}/syn/verilog/*.v]
add_files -norecurse ${src_dir}/custom_logic.v
add_files -norecurse ${src_dir}/lsu_rg_cl_glue.v
add_files -norecurse ${src_dir}/ram_group.v
add_files -norecurse ${src_dir}/ram_group_lutram.v
add_files -norecurse ${src_dir}/ram_group_uram.v
add_files -norecurse ${src_dir}/regmem_lib.v
add_files -norecurse ${src_dir}/pipe_block.v

add_files -norecurse ../socket_cc_flow/ff_bridge/ff_bridge_bb_with_stub_net.v
import_files -norecurse ../socket_cc_flow/ff_bridge/ff_bridge_extracted_fixed.dcp

update_compile_order -fileset sources_1

check_syntax

set_property top rg_cl_wrapper [current_fileset]

add_files -fileset utils_1 -norecurse tcl_hooks/pre_opt.tcl
add_files -fileset utils_1 -norecurse tcl_hooks/post_opt.tcl
add_files -fileset utils_1 -norecurse tcl_hooks/pre_route.tcl
add_files -fileset utils_1 -norecurse tcl_hooks/post_route.tcl

update_compile_order -fileset sources_1

set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context -verilog_define FF_BRIDGE_WITH_STUB_NET=1} -objects [get_runs synth_1]
#set_param logicopt.enableBUFGinsertCLK 0
set_property -name STEPS.OPT_DESIGN.TCL.PRE -value [get_files -of_object [get_filesets utils_1] pre_opt.tcl] -objects [get_runs impl_1]
set_property -name STEPS.OPT_DESIGN.TCL.POST -value [get_files -of_object [get_filesets utils_1] post_opt.tcl] -objects [get_runs impl_1]
set_property -name STEPS.ROUTE_DESIGN.TCL.PRE -value [get_files -of_object [get_filesets utils_1] pre_route.tcl] -objects [get_runs impl_1]
set_property -name STEPS.ROUTE_DESIGN.TCL.POST -value [get_files -of_object [get_filesets utils_1] post_route.tcl] -objects [get_runs impl_1]

set_param general.maxThreads 32

reset_run synth_1
launch_runs synth_1
wait_on_run synth_1 -verbose

reset_run impl_1
launch_runs impl_1
wait_on_run impl_1 -verbose
