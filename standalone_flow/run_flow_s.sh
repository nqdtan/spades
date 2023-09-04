#!/bin/bash

app=$1

ts=$(date +"%Y-%m-%d_%H-%M-%S")
project_name=project_socket_${app}_${ts}

sed -i "/\`define EXCLUDE_RG_CL/d" ../rtl/socket_config.vh
cd ../ulp_design
rm -rf kernel_pack_socket_top_s
make kernel_pack top=socket_top_s app=$app
cd ../standalone_ooc_flow

vivado -mode batch -source script_s.tcl -tclargs $project_name

FILE=${project_name}/${project_name}.runs/impl_1/socket_ooc.dcp
if [ -f "$FILE" ]; then
  cd ${project_name}/${project_name}.runs/impl_1
  rm -rf ext && unzip socket_ooc.dcp -d ext
  cd ext/ && rm *.ncr *.nts && cp ~/socket/standalone_ooc_flow/dcp.xml .
  zip socket_ooc.dcp * && mv socket_ooc.dcp ../
fi
