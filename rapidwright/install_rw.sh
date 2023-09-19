#!/bin/bash

wget https://github.com/Xilinx/RapidWright/releases/download/v2022.2.3-beta/rapidwright-2022.2.3-standalone-lin64.jar
wget https://github.com/Xilinx/RapidWright/releases/download/v2022.2.3-beta/rapidwright-api-lib-2022.2.3-javadoc.jar
wget https://github.com/Xilinx/RapidWright/releases/download/v2022.2.3-beta/gnl_timing_designs.zip
wget https://github.com/Xilinx/RapidWright/releases/download/v2022.2.3-beta/rapidwright_data.zip
wget https://github.com/Xilinx/RapidWright/releases/download/v2022.2.3-beta/rapidwright_jars.zip
wget https://github.com/Xilinx/RapidWright/archive/refs/tags/v2022.2.3-beta.zip

unzip v2022.2.3-beta.zip  -d .
unzip rapidwright_jars.zip -d .
unzip rapidwright_data.zip -d .
unzip gnl_timing_designs.zip -d .
cp -R RapidWright-*/* . && rm -rf RapidWright-*
mv *.jars jars/
patch src/com/xilinx/rapidwright/edif/EDIFNetlist.java edifnetlist.patch
export RAPIDWRIGHT_PATH=/path/to/spades/rapidwright
export CLASSPATH=$RAPIDWRIGHT_PATH/bin:$(echo $RAPIDWRIGHT_PATH/jars/*.jar | tr ' ' ':')
make compile
