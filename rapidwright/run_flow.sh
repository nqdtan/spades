#!/bin/bash

app=$1
config=$2

cd ../checkpoints
cp socket_rg_cl.${app}.dcp socket_rg_cl.dcp
cp socket_rg_cl.${app}.edf socket_rg_cl.edf
vivado -mode batch -source remove_stub_cells.tcl
cd ../rapidwright
./run_rw.sh SocketStitch
cd ../checkpoints
./remove_rw_hier_from_dcp.sh socket_rw_full_v0.dcp
cp socket_rw_full_v0.dcp socket_rw_full_v0.${app}.dcp
cp socket_rw_full_v0.edf socket_rw_full_v0.${app}.edf
cd ../rapidwright
./run_rw.sh SpadesFlow ${config}
cp ../checkpoints/full_design.dcp ../checkpoints/full_design.${app}.dcp
cp ../checkpoints/full_design.edf ../checkpoints/full_design.${app}.edf
