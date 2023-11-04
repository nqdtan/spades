#ifndef _MATMUL_H_
#define _MATMUL_H_

#include <stdlib.h>
#include <stdint.h>
#include <ap_int.h>

typedef float DATATYPE;
//typedef int DATATYPE;
typedef ap_int<64> DATATYPE_IF;

void conv2d(DATATYPE *ifm, DATATYPE *ofm, DATATYPE *wt,
  int HIn, int WIn, int K, int stride, int pad);

#endif
