
#include <stdlib.h>
#include <stdint.h>
#include <ap_int.h>

#define BHA 64
#define BWA 24
#define BWB 64
void cl_matmul(
  int64_t local_a0[BHA][2],
  int64_t local_a1[BHA][2],
  int64_t local_a2[BHA][2],
  int64_t local_a3[BHA][2],
  int64_t local_a4[BHA][2],
  int64_t local_a5[BHA][2],
  int64_t local_a6[BHA][2],
  int64_t local_a7[BHA][2],
  int64_t local_a8[BHA][2],
  int64_t local_a9[BHA][2],
  int64_t local_a10[BHA][2],
  int64_t local_a11[BHA][2],
  int64_t local_b0[2][BWB],
  int64_t local_b1[2][BWB],
  int64_t local_b2[2][BWB],
  int64_t local_b3[2][BWB],
  int64_t local_b4[2][BWB],
  int64_t local_b5[2][BWB],
  int64_t local_b6[2][BWB],
  int64_t local_b7[2][BWB],
  int64_t local_b8[2][BWB],
  int64_t local_b9[2][BWB],
  int64_t local_b10[2][BWB],
  int64_t local_b11[2][BWB],

  int64_t local_c0[BHA][BWB/4],
  int64_t local_c1[BHA][BWB/4],
  int64_t local_c2[BHA][BWB/4],
  int64_t local_c3[BHA][BWB/4],
  int len, int pp) {
#pragma HLS INTERFACE mode=ap_memory port=local_a0 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a1 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a2 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a3 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a4 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a5 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a6 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a7 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a8 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a9 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a10 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a11 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b0 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b1 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b2 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b3 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b4 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b5 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b6 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b7 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b8 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b9 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b10 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b11 latency=3

#pragma HLS INTERFACE mode=ap_memory port=local_c0 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_c1 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_c2 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_c3 latency=3

  int ii = 0;
  int jj = 0;
  for (int iijj = 0; iijj < BHA * BWB; iijj++) {
    #pragma HLS PIPELINE
    #pragma HLS DEPENDENCE variable=local_c0 inter false
    #pragma HLS DEPENDENCE variable=local_c1 inter false
    #pragma HLS DEPENDENCE variable=local_c2 inter false
    #pragma HLS DEPENDENCE variable=local_c3 inter false

    int ii = iijj / BWB;
    int jj = iijj % BWB;
    int64_t tmp = jj % 4 == 0 ? local_c0[ii][jj/4] :
                  jj % 4 == 1 ? local_c1[ii][jj/4] :
                  jj % 4 == 2 ? local_c2[ii][jj/4] :
                                local_c3[ii][jj/4];

    for (int t = 0; t < 2; t++) {
      int64_t tmp_local_a0 = local_a0[ii][t];
      int64_t tmp_local_a1 = local_a1[ii][t];
      int64_t tmp_local_a2 = local_a2[ii][t];
      int64_t tmp_local_a3 = local_a3[ii][t];
      int64_t tmp_local_a4 = local_a4[ii][t];
      int64_t tmp_local_a5 = local_a5[ii][t];
      int64_t tmp_local_a6 = local_a6[ii][t];
      int64_t tmp_local_a7 = local_a7[ii][t];
      int64_t tmp_local_a8 = local_a8[ii][t];
      int64_t tmp_local_a9 = local_a9[ii][t];
      int64_t tmp_local_a10 = local_a10[ii][t];
      int64_t tmp_local_a11 = local_a11[ii][t];
      int64_t tmp_local_b0 = local_b0[t][jj];
      int64_t tmp_local_b1 = local_b1[t][jj];
      int64_t tmp_local_b2 = local_b2[t][jj];
      int64_t tmp_local_b3 = local_b3[t][jj];
      int64_t tmp_local_b4 = local_b4[t][jj];
      int64_t tmp_local_b5 = local_b5[t][jj];
      int64_t tmp_local_b6 = local_b6[t][jj];
      int64_t tmp_local_b7 = local_b7[t][jj];
      int64_t tmp_local_b8 = local_b8[t][jj];
      int64_t tmp_local_b9 = local_b9[t][jj];
      int64_t tmp_local_b10 = local_b10[t][jj];
      int64_t tmp_local_b11 = local_b11[t][jj];
      tmp += (len <= 2*0) ? 0 : tmp_local_a0 * tmp_local_b0;
      tmp += (len <= 2*1) ? 0 : tmp_local_a1 * tmp_local_b1;
      tmp += (len <= 2*2) ? 0 : tmp_local_a2 * tmp_local_b2;
      tmp += (len <= 2*3) ? 0 : tmp_local_a3 * tmp_local_b3;
      tmp += (len <= 2*4) ? 0 : tmp_local_a4 * tmp_local_b4;
      tmp += (len <= 2*5) ? 0 : tmp_local_a5 * tmp_local_b5;
      tmp += (len <= 2*6) ? 0 : tmp_local_a6 * tmp_local_b6;
      tmp += (len <= 2*7) ? 0 : tmp_local_a7 * tmp_local_b7;
      tmp += (len <= 2*8) ? 0 : tmp_local_a8 * tmp_local_b8;
      tmp += (len <= 2*9) ? 0 : tmp_local_a9 * tmp_local_b9;
      tmp += (len <= 2*10) ? 0 : tmp_local_a10 * tmp_local_b10;
      tmp += (len <= 2*11) ? 0 : tmp_local_a11 * tmp_local_b11;

    }
    if (jj % 4 == 0)
      local_c0[ii][jj/4] = tmp;
    else if (jj % 4 == 1)
      local_c1[ii][jj/4] = tmp;
    else if (jj % 4 == 2)
      local_c2[ii][jj/4] = tmp;
    else
      local_c3[ii][jj/4] = tmp;
  }
}

