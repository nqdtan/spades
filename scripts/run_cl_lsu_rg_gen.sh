#!/bin/bash

app=$1

python3 custom_logic_generator.py $app > custom_logic.v
python3 lsu_rg_cl_glue.py $app > lsu_rg_cl_glue.v

cp custom_logic.v ../rtl
cp lsu_rg_cl_glue.v ../rtl
