#ifndef _MATMUL_H_
#define _MATMUL_H_

#include <stdlib.h>
#include <stdint.h>
#include <ap_int.h>

typedef ap_int<256> DATATYPE;
typedef ap_int<256> DATATYPE_IF;

void matmul(DATATYPE *m0, DATATYPE *m1, DATATYPE *m2,
            int a_offset, int b_offset, int c_offset, int n);

#endif
