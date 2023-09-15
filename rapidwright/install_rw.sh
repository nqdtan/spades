#!/bin/bash

wget https://github.com/Xilinx/RapidWright/releases/download/v2023.1.2-beta/rapidwright-2023.1.2-standalone-lin64.jar
wget https://github.com/Xilinx/RapidWright/releases/download/v2023.1.2-beta/rapidwright-api-lib-2023.1.2-javadoc.jar
wget https://github.com/Xilinx/RapidWright/releases/download/v2023.1.2-beta/gnl_timing_designs.zip
wget https://github.com/Xilinx/RapidWright/releases/download/v2023.1.2-beta/rapidwright_data.zip
wget https://github.com/Xilinx/RapidWright/releases/download/v2023.1.2-beta/rapidwright_jars.zip
wget https://github.com/Xilinx/RapidWright/archive/refs/tags/v2023.1.2-beta.zip

unzip v2023.1.2-beta.zip  -d .
unzip rapidwright_jars.zip -d .
unzip rapidwright_data.zip -d .
unzip gnl_timing_designs.zip -d .
mv RapidWright-*/* . && rm -rf RapidWright-*
mv *.jars jars/
patch src/com/xilinx/rapidwright/edif/EDIFNetlist.java edifnetlist.patch
mv spades src/com/xilinx/rapidwright/
export RAPIDWRIGHT_PATH=/path/to/spades/rapidwright
export CLASSPATH=$RAPIDWRIGHT_PATH/bin:$(echo $RAPIDWRIGHT_PATH/jars/*.jar | tr ' ' ':')
make compile
