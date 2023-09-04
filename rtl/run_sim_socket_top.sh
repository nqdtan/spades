#!/bin/bash

ROOTDIR=/path/to/spades
APPDIR=${ROOTDIR}/benchmarks/hls_kernel

app=$1
mat_dim=$2
verify_len=$2
kernel=$1
num_sockets=$3
num_m_ram_ports_pc=2
ts=$(date +"%Y-%m-%d_%H-%M-%S")
project_name=project_system_sim_socket_$ts

sed -i "/\`define EXCLUDE_RG_CL/d" socket_config.vh
sed -i "s/  localparam NUM_SOCKETS = [[:digit:]]*;/  localparam NUM_SOCKETS = ${num_sockets};/g" testbenches/system_socket_tb.v

cd ../controller_software/${app}
make clean
make TARGET=control0
for ((c = 1; c < ${num_sockets}; c++))
do
make TARGET=control${c}
done
cd ../../rtl

cp ${APPDIR}/${app}/${app}_init.mif.${verify_len} .
cp ${APPDIR}/${app}/${app}_result.mif.${verify_len} .
cp ${APPDIR}/${app}/${app}_init.mif.${verify_len} dmem_data.mif
cp ${app}_init.mif.${verify_len} dmem_data.mif
vivado -mode batch -source system_sim_socket.tcl -nojou -tclargs ${num_sockets} ${num_m_ram_ports_pc} ${verify_len} ${project_name} ${app}
python3 check_mif.py ${project_name}/${project_name}.sim/sim_1/behav/xsim/dmem_data_out.mif ${app}_result.mif.${verify_len} ${verify_len}
