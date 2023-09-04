#!/bin/bash

# Top-down socket flow (no socket floorplanning constraint)
app=$1
func=$2
num_sockets=$3

rm -rf kernel_pack_socket_manager
rm -rf kernel_pack_socket_top

sed -i "/\`define EXCLUDE_RG_CL/d" ../rtl/socket_config.vh
cp ../socket_cc_flow/ff_bridge/ff_bridge_sim.v ../socket_cc_flow/ff_bridge/ff_bridge.v
make kernel_pack script=socket_top top=socket_top app=${app} func=${func}
make kernel_pack script=socket_manager top=socket_manager
vivado -mode batch -source package_kernel_socket_manager.tcl
make ulp_bd flow=socket num_sockets=${num_sockets}
make rm_project top=socket_${num_sockets} jobs=1
