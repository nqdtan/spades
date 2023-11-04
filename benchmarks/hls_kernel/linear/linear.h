#ifndef _MATMUL_H_
#define _MATMUL_H_

#include <stdlib.h>
#include <stdint.h>
#include <ap_int.h>
typedef ap_int<64> DATATYPE_IF;

typedef float DATATYPE;
//typedef int DATATYPE;

void linear_baseline(DATATYPE *ifm, DATATYPE *ofm, DATATYPE *wt,
  int ifm_len, int ofm_len, int ifm_size, int ofm_size);

#endif
