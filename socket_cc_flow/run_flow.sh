#!/bin/bash

ts=$(date +"%Y-%m-%d_%H-%M-%S")
project_name=project_socket_cc_${ts}

sed -i "7i \`define EXCLUDE_RG_CL" ../rtl/socket_config.vh

cd ../ulp_design
rm -rf kernel_pack_ff_bridge
make kernel_pack script=ff_bridge
rm -rf kernel_pack_mbufgce_primitive
make kernel_pack script=mbufgce_primitive
rm -rf kernel_pack_lut1_primitive
make kernel_pack script=lut_primitive
rm -rf kernel_pack_socket_top
make kernel_pack script=socket_top top=socket_top
cd ../socket_cc_flow

vivado -mode batch -source script.tcl -tclargs $project_name

FILE=${project_name}/${project_name}.runs/impl_1/socket_cc.dcp
if [ -f "$FILE" ]; then
  cd ${project_name}/${project_name}.runs/impl_1
  rm -rf ext && unzip socket_cc.dcp -d ext
  cd ext/ && rm *.ncr *.nts && cp ../../../../dcp.xml .
  zip socket_cc.dcp * && mv socket_cc.dcp ../ && cd ../
  cp socket_cc.dcp ../../../../checkpoints/
  cp socket_cc.edf ../../../../checkpoints/
fi
