#!/bin/bash

# Set the path to this repository
ROOTDIR=/my/spades

sed -i "s|/path/to/spades|"${ROOTDIR}"|g" ./rapidwright/run_rw.sh
sed -i "s|/path/to/spades|"${ROOTDIR}"|g" ./rtl/run_sim_socket_top.sh
sed -i "s|/path/to/spades|"${ROOTDIR}"|g" ./rtl/run_ivsim_socket_top.sh
sed -i "s|/path/to/spades|"${ROOTDIR}"|g" ./rtl/system_sim_socket.tcl
sed -i "s|/path/to/spades|"${ROOTDIR}"|g" ./socket_cl_flow/tcl_hooks/post_opt.tcl
sed -i "s|/path/to/spades|"${ROOTDIR}"|g" ./socket_cl_flow/tcl_hooks/pre_route_s.tcl
sed -i "s|/path/to/spades|"${ROOTDIR}"|g" ./socket_cl_flow/tcl_hooks/pre_route.tcl
sed -i "s|/path/to/spades|"${ROOTDIR}"|g" ./socket_cl_flow/tcl_hooks/post_opt_s.tcl
sed -i "s|/path/to/spades|"${ROOTDIR}"|g" ./ulp_design/tcl_hooks/post_opt.tcl
sed -i "s|/path/to/spades|"${ROOTDIR}"|g" ./socket_cc_flow/tcl_hooks/pre_opt_s.tcl
sed -i "s|/path/to/spades|"${ROOTDIR}"|g" ./socket_cc_flow/tcl_hooks/pre_route_s.tcl
sed -i "s|/path/to/spades|"${ROOTDIR}"|g" ./socket_cc_flow/tcl_hooks/pre_route.tcl
sed -i "s|/path/to/spades|"${ROOTDIR}"|g" ./socket_cc_flow/tcl_hooks/pre_opt.tcl
