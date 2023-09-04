set app [lindex $argv 0]
set hls_func [lindex $argv 1]
cd ${app}

open_project proj
set_top ${hls_func}

add_files ${app}.cpp
#add_files -tb main.cpp

open_solution -reset "solution_${hls_func}"

set_part {xcvc1902-vsva2197-2MP-e-S}

create_clock -period "500MHz"

#config_dataflow -default_channel pingpong
config_array_partition -throughput_driven off
#config_compile -pipeline_loops 1
#config_bind -effort high

#csim_design
csynth_design
#cosim_design -trace_level none -rtl verilog -tool xsim
#export_design -flow impl
#export_design -format ip_catalog
exit
