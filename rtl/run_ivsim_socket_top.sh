#!/bin/bash

ROOTDIR=/path/to/spades
APPDIR=${ROOTDIR}/benchmarks/hls_kernel
app=$1
mat_dim=$2
verify_len=$2
kernel=$1

sed -i "/\`define EXCLUDE_RG_CL/d" socket_config.vh
sed -i "s/  localparam VERIFY_LEN = [[:digit:]]*;/  localparam VERIFY_LEN = ${verify_len};/g" testbenches/socket_top_tb.v

cp ${APPDIR}/${app}/${app}_init.mif.${verify_len} .
cp ${APPDIR}/${app}/${app}_result.mif.${verify_len} .
cp ${APPDIR}/${app}/${app}_init.mif.${verify_len} dmem_data.mif
make iverilog-sim top=socket_top_tb sw=${app} kernel=${kernel} size=${verify_len}
