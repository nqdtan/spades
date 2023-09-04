#!/bin/bash

app=$1
num_sockets=$2
mat_dim=$3

cd $app
make clean
rm -f control_top.h

sed -i "s/#define NUM_CORES [[:digit:]]*/#define NUM_CORES ${num_sockets}/g" control0.c
sed -i "s/#define MAT_DIM [[:digit:]]*/#define MAT_DIM ${mat_dim}/g" control0.c

make TARGET=control0
for ((c = 1; c < ${num_sockets}; c++))
do
#cp control0.c control${c}.c
sed -i "s/#define CORE_ID [[:digit:]]*/#define CORE_ID $c/g" control${c}.c
sed -i "s/#define NUM_CORES [[:digit:]]*/#define NUM_CORES ${num_sockets}/g" control${c}.c
sed -i "s/#define MAT_DIM [[:digit:]]*/#define MAT_DIM ${mat_dim}/g" control${c}.c
make TARGET=control${c}
done

python3 ../format_mif_to_h.py control ${num_sockets} > control_top.h

echo "#define NUM_SOCKETS ${num_sockets}" >> control_top.h
echo "int control_lens[] = {" >> control_top.h
for ((c = 0; c < ${num_sockets}; c++))
do
echo "  CONTROL${c}_LEN," >> control_top.h
done
echo "};" >> control_top.h
cp control_top.h ../../benchmarks/host_sw/$app
