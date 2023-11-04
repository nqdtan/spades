#!/bin/bash

app=$1

ts=$(date +"%Y-%m-%d_%H-%M-%S")
project_name=project_pdi_gen_${app}_${ts}
mkdir -p ${project_name}
cp ../checkpoints/full_design.${app}.dcp ${project_name}/full_design.dcp && cd ${project_name}
rm -rf ext
rm -f full_design_rezip.dcp
unzip full_design.dcp -d ext
python3 ../remove_socket_dest_id.py ext/top_wrapper.ncr
mv tmp.ncr ext/top_wrapper.ncr
cd ext
zip full_design_rezip.dcp *
mv full_design_rezip.dcp ../
cd .. && cp ../script.tcl .
# We may have encrypted IPs
if [ -f ../../rapidwright/full_design_load.tcl ]; then
  cat ../../rapidwright/full_design_load.tcl | while read line
  do
    if [[ $line == *"read_edif"* ]]; then
      cat <(echo "$line") script.tcl > tmp.tcl
      mv tmp.tcl script.tcl
    fi
  done
fi
vivado -mode batch -source script.tcl
