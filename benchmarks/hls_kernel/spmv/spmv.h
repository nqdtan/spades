#ifndef _MATMUL_H_
#define _MATMUL_H_

#include <stdlib.h>
#include <stdint.h>
#include <ap_int.h>

typedef int64_t DATATYPE;
typedef ap_int<256> DATATYPE_IF;

//void spmv(DATATYPE *m0, int n);
void spmv_axi(DATATYPE *m0, DATATYPE *m1, int n, int row_begin, int row_end);

#endif
