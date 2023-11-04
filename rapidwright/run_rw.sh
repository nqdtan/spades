#!/bin/bash

export RAPIDWRIGHT_PATH=/path/to/spades/rapidwright
export CLASSPATH=$RAPIDWRIGHT_PATH/bin:$(echo $RAPIDWRIGHT_PATH/jars/*.jar | tr ' ' ':')
rm -f *_load.tcl
#make compile
make compile && java -Xmx16g -ea com.xilinx.rapidwright.spades.$1 $2 $3
