#!/bin/bash

app=$1
func=$2

ts=$(date +"%Y-%m-%d_%H-%M-%S")
project_name=project_socket_${app}_${ts}

sed -i "/\`define EXCLUDE_RG_CL/d" ../rtl/socket_config.vh
cp ../socket_cc_flow/ff_bridge/ff_bridge_sim.v ../socket_cc_flow/ff_bridge/ff_bridge.v

cd ../ulp_design
rm -rf kernel_pack_socket_top
make kernel_pack script=socket_top top=socket_top app=$app func=$func
cd ../standalone_flow

vivado -mode batch -source script.tcl -tclargs $project_name

FILE=${project_name}/${project_name}.runs/impl_1/socket_standalone.dcp
if [ -f "$FILE" ]; then
  cd ${project_name}/${project_name}.runs/impl_1
  rm -rf ext && unzip socket_standalone.dcp -d ext
  cd ext/ && rm *.ncr *.nts && cp ~/socket/standalone_flow/dcp.xml .
  zip socket_standalone.dcp * && mv socket_standalone.dcp ../
fi
