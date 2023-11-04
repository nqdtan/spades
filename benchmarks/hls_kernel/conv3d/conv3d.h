#ifndef _MATMUL_H_
#define _MATMUL_H_

#include <stdlib.h>
#include <stdint.h>
#include <ap_int.h>
typedef ap_int<64> DATATYPE_IF;

typedef float DATATYPE;
//typedef int DATATYPE;

void conv3d(DATATYPE *ifm, DATATYPE *ofm, DATATYPE *wt,
  int HIn, int WIn, int Cin, int Cout, int K, int stride, int pad);

#endif
