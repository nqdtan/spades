#!/bin/bash

app=$1
cd ../scripts
./run_cl_lsu_rg_gen.sh ${app}
cd ../socket_cl_flow

ts=$(date +"%Y-%m-%d_%H-%M-%S")
project_name=project_cl_${app}_${ts}

vivado -mode batch -source script_s.tcl -tclargs $project_name $app
cp ${project_name}/${project_name}.runs/impl_1/socket_rg_cl.dcp ../checkpoints/socket_rg_cl.${app}.dcp
cp ${project_name}/${project_name}.runs/impl_1/socket_rg_cl.edf ../checkpoints/socket_rg_cl.${app}.edf
