#!/bin/bash

dcp_file=$1
rm -rf ext_tmp
unzip $dcp_file -d ext_tmp
cd ext_tmp
rm -f RW_HIER
zip $dcp_file * && mv $dcp_file ../
