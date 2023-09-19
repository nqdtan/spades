set project_name [lindex $argv 0]

create_project -force $project_name $project_name -part xcvc1902-vsvd1760-2MP-e-S
set_property board_part xilinx.com:vck5000:part0:1.0 [current_project]

add_files -fileset constrs_1 xdc/constr_s.xdc

#source socket_top_bd.tcl
source socket_bd_s.tcl
update_compile_order -fileset sources_1

save_bd_design
set_param noc.enableCompilerHiEffort true
validate_bd_design

set bdfname ${project_name}/${project_name}.srcs/sources_1/bd/design_1/design_1.bd
generate_target all [get_files $bdfname]
set iplist [get_ips -all]
foreach ip $iplist {
  catch { config_ip_cache -export $ip }
}

export_ip_user_files -of_objects [get_files $bdfname] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $bdfname]
set_param tcl.collectionResultDisplayLimit 0
launch_runs [get_runs *_synth_1] -jobs 1 -quiet
foreach run [get_runs *_synth_1] {
  wait_on_run $run
}

make_wrapper -files [get_files $bdfname] -top
add_files -norecurse ${project_name}/${project_name}.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v
set_property top design_1_wrapper [current_fileset]
update_compile_order -fileset sources_1

add_files -fileset utils_1 -norecurse tcl_hooks/pre_opt_s.tcl
add_files -fileset utils_1 -norecurse tcl_hooks/post_opt.tcl
add_files -fileset utils_1 -norecurse tcl_hooks/pre_place.tcl
add_files -fileset utils_1 -norecurse tcl_hooks/post_place.tcl
add_files -fileset utils_1 -norecurse tcl_hooks/pre_route_s.tcl
add_files -fileset utils_1 -norecurse tcl_hooks/post_route.tcl

set_property -name STEPS.OPT_DESIGN.TCL.PRE -value [get_files -of_object [get_filesets utils_1] pre_opt_s.tcl] -objects [get_runs impl_1]
set_property -name STEPS.OPT_DESIGN.TCL.POST -value [get_files -of_object [get_filesets utils_1] post_opt.tcl] -objects [get_runs impl_1]
set_property -name STEPS.PLACE_DESIGN.TCL.PRE -value [get_files -of_object [get_filesets utils_1] pre_place.tcl] -objects [get_runs impl_1]
set_property -name STEPS.PLACE_DESIGN.TCL.POST -value [get_files -of_object [get_filesets utils_1] post_place.tcl] -objects [get_runs impl_1]
set_property -name STEPS.ROUTE_DESIGN.TCL.PRE -value [get_files -of_object [get_filesets utils_1] pre_route_s.tcl] -objects [get_runs impl_1]
set_property -name STEPS.ROUTE_DESIGN.TCL.POST -value [get_files -of_object [get_filesets utils_1] post_route.tcl] -objects [get_runs impl_1]
set_property -name STEPS.WRITE_DEVICE_IMAGE.TCL.PRE -value [get_files -of_object [get_filesets utils_1] pre_write_device_image.tcl] -objects [get_runs impl_1]
set_property -name STEPS.WRITE_DEVICE_IMAGE.TCL.POST -value [get_files -of_object [get_filesets utils_1] post_write_device_image.tcl] -objects [get_runs impl_1]

set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
#set_property STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE AreaOptimized_high [get_runs synth_1]
#set_property strategy Flow_AreaOptimized_high [get_runs synth_1]
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context -verilog_define FF_BRIDGE_BB=1} -objects [get_runs synth_1]
#set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context -directive sdx_optimization_effort_high} -objects [get_runs synth_1]
#set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]
#set_property strategy Performance_ExtraTimingOpt [get_runs impl_1]
set_param logicopt.enableBUFGinsertCLK 0

set_param general.maxThreads 32
#set_param place.sliceLegEffortLimit 2000

#set_property STEPS.SYNTH_DESIGN.ARGS.CONTROL_SET_OPT_THRESHOLD 16 [get_runs synth_1]
set_property -name {STEPS.ROUTE_DESIGN.ARGS.MORE OPTIONS} -value -preserve -objects [get_runs impl_1]

launch_runs synth_1 -jobs 16
wait_on_run synth_1 -verbose

#open_run synth_1
#write_checkpoint post_synth.dcp

launch_runs impl_1 -to_step route_design -jobs 16
wait_on_run impl_1 -verbose
