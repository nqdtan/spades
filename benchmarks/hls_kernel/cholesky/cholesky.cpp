
#include "cholesky.h"

#define SIZE 16
int64_t dot_product(
  int64_t a0,
  int64_t a1,
  int64_t a2,
  int64_t a3,
  int64_t a4,
  int64_t a5,
  int64_t a6,
  int64_t a7,
  int64_t a8,
  int64_t a9,
  int64_t a10,
  int64_t a11,
  int64_t a12,
  int64_t a13,
  int64_t a14,
  int64_t a15,
  int64_t b0,
  int64_t b1,
  int64_t b2,
  int64_t b3,
  int64_t b4,
  int64_t b5,
  int64_t b6,
  int64_t b7,
  int64_t b8,
  int64_t b9,
  int64_t b10,
  int64_t b11,
  int64_t b12,
  int64_t b13,
  int64_t b14,
  int64_t b15) {
#pragma HLS INLINE OFF
  int64_t tmp = 0;
  tmp += a0 * b0;
  tmp += a1 * b1;
  tmp += a2 * b2;
  tmp += a3 * b3;
  tmp += a4 * b4;
  tmp += a5 * b5;
  tmp += a6 * b6;
  tmp += a7 * b7;
  tmp += a8 * b8;
  tmp += a9 * b9;
  tmp += a10 * b10;
  tmp += a11 * b11;
  tmp += a12 * b12;
  tmp += a13 * b13;
  tmp += a14 * b14;
  tmp += a15 * b15;

  return tmp;
}
void cl_cholesky(
  int64_t local_a0[SIZE][2],
  int64_t local_a1[SIZE][2],
  int64_t local_a2[SIZE][2],
  int64_t local_a3[SIZE][2],
  int64_t local_a4[SIZE][2],
  int64_t local_a5[SIZE][2],
  int64_t local_a6[SIZE][2],
  int64_t local_a7[SIZE][2],
  int64_t local_a8[SIZE],
  int64_t local_a9[SIZE],
  int64_t local_a10[SIZE],
  int64_t local_a11[SIZE],
  int64_t local_a12[SIZE],
  int64_t local_a13[SIZE],
  int64_t local_a14[SIZE],
  int64_t local_a15[SIZE],
  int64_t local_b0[SIZE][2],
  int64_t local_b1[SIZE][2],
  int64_t local_b2[SIZE][2],
  int64_t local_b3[SIZE][2],
  int64_t local_b4[SIZE][2],
  int64_t local_b5[SIZE][2],
  int64_t local_b6[SIZE][2],
  int64_t local_b7[SIZE][2],
  int64_t local_c[SIZE * SIZE], // local_l1

  int64_t local_d0[SIZE * SIZE/4], // mm2
  int64_t local_d1[SIZE * SIZE/4], // mm2
  int64_t local_d2[SIZE * SIZE/4], // mm2
  int64_t local_d3[SIZE * SIZE/4], // mm2

  int state, int pp) {
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
#pragma HLS INTERFACE mode=ap_memory port=local_a12 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a13 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a14 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a15 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b0 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b1 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b2 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b3 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b4 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b5 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b6 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b7 latency=3

#pragma HLS INTERFACE mode=ap_memory port=local_c storage_type=ram_s2p latency=3

#pragma hls interface mode=ap_memory port=local_d0 latency=3
#pragma hls interface mode=ap_memory port=local_d1 latency=3
#pragma hls interface mode=ap_memory port=local_d2 latency=3
#pragma hls interface mode=ap_memory port=local_d3 latency=3

  int64_t tmp_mul;
  int64_t op0[16], op1[16];
#pragma HLS ARRAY_PARTITION variable=op0 dim=1 complete
#pragma HLS ARRAY_PARTITION variable=op1 dim=1 complete

  if (state == 0 || state == 2) {
    for (int jjii = 0; jjii < SIZE*SIZE; jjii++) {
      #pragma HLS PIPELINE II=1
      #pragma HLS DEPENDENCE variable=local_c inter false
      int ii = jjii % SIZE;
      int jj = jjii / SIZE;
      tmp_mul = local_c[ii * SIZE + jj];
      op0[0]  = local_b0[ii][0];
      op0[1]  = local_b0[ii][1];
      op0[2]  = local_b1[ii][0];
      op0[3]  = local_b1[ii][1];
      op0[4]  = local_b2[ii][0];
      op0[5]  = local_b2[ii][1];
      op0[6]  = local_b3[ii][0];
      op0[7]  = local_b3[ii][1];
      op0[8]  = local_b4[ii][0];
      op0[9]  = local_b4[ii][1];
      op0[10]  = local_b5[ii][0];
      op0[11]  = local_b5[ii][1];
      op0[12]  = local_b6[ii][0];
      op0[13]  = local_b6[ii][1];
      op0[14]  = local_b7[ii][0];
      op0[15]  = local_b7[ii][1];
      op1[0]  = local_a0[jj][0];
      op1[1]  = local_a0[jj][1];
      op1[2]  = local_a1[jj][0];
      op1[3]  = local_a1[jj][1];
      op1[4]  = local_a2[jj][0];
      op1[5]  = local_a2[jj][1];
      op1[6]  = local_a3[jj][0];
      op1[7]  = local_a3[jj][1];
      op1[8]  = local_a4[jj][0];
      op1[9]  = local_a4[jj][1];
      op1[10]  = local_a5[jj][0];
      op1[11]  = local_a5[jj][1];
      op1[12]  = local_a6[jj][0];
      op1[13]  = local_a6[jj][1];
      op1[14]  = local_a7[jj][0];
      op1[15]  = local_a7[jj][1];
      tmp_mul += dot_product(
        op0[0], op0[1], op0[2], op0[3], op0[4], op0[5], op0[6], op0[7], op0[8], op0[9], op0[10], op0[11], op0[12], op0[13], op0[14], op0[15], 
        op1[0], op1[1], op1[2], op1[3], op1[4], op1[5], op1[6], op1[7], op1[8], op1[9], op1[10], op1[11], op1[12], op1[13], op1[14], op1[15]);
      local_c[ii * SIZE + jj] = (ii < jj && state == 0) ? 0 : tmp_mul;

    }
  } else if (state == 1 || state == 3) {
    int sel = 1;
    int s1 = 0;
    for (int jj = 0; jj < SIZE; jj++) {
      bool sel0  = (sel >> 0)  & 0x1;
      bool sel1  = (sel >> 1)  & 0x1;
      bool sel2  = (sel >> 2)  & 0x1;
      bool sel3  = (sel >> 3)  & 0x1;
      bool sel4  = (sel >> 4)  & 0x1;
      bool sel5  = (sel >> 5)  & 0x1;
      bool sel6  = (sel >> 6)  & 0x1;
      bool sel7  = (sel >> 7)  & 0x1;
      bool sel8  = (sel >> 8)  & 0x1;
      bool sel9  = (sel >> 9)  & 0x1;
      bool sel10  = (sel >> 10)  & 0x1;
      bool sel11  = (sel >> 11)  & 0x1;
      bool sel12  = (sel >> 12)  & 0x1;
      bool sel13  = (sel >> 13)  & 0x1;
      bool sel14  = (sel >> 14)  & 0x1;
      bool sel15  = (sel >> 15)  & 0x1;
      bool s1_0  = (s1 >> 0)  & 0x1;
      bool s1_1  = (s1 >> 1)  & 0x1;
      bool s1_2  = (s1 >> 2)  & 0x1;
      bool s1_3  = (s1 >> 3)  & 0x1;
      bool s1_4  = (s1 >> 4)  & 0x1;
      bool s1_5  = (s1 >> 5)  & 0x1;
      bool s1_6  = (s1 >> 6)  & 0x1;
      bool s1_7  = (s1 >> 7)  & 0x1;
      bool s1_8  = (s1 >> 8)  & 0x1;
      bool s1_9  = (s1 >> 9)  & 0x1;
      bool s1_10  = (s1 >> 10)  & 0x1;
      bool s1_11  = (s1 >> 11)  & 0x1;
      bool s1_12  = (s1 >> 12)  & 0x1;
      bool s1_13  = (s1 >> 13)  & 0x1;
      bool s1_14  = (s1 >> 14)  & 0x1;
      bool s1_15  = (s1 >> 15)  & 0x1;
      tmp_mul = local_c[jj * SIZE + jj];
      op0[0]  = s1_0  ? (state == 1 ? local_a0[jj/2][jj%2]  : local_b0[jj][0]) : 0;
      op0[1]  = s1_1  ? (state == 1 ? local_a1[jj/2][jj%2]  : local_b0[jj][1]) : 0;
      op0[2]  = s1_2  ? (state == 1 ? local_a2[jj/2][jj%2]  : local_b1[jj][0]) : 0;
      op0[3]  = s1_3  ? (state == 1 ? local_a3[jj/2][jj%2]  : local_b1[jj][1]) : 0;
      op0[4]  = s1_4  ? (state == 1 ? local_a4[jj/2][jj%2]  : local_b2[jj][0]) : 0;
      op0[5]  = s1_5  ? (state == 1 ? local_a5[jj/2][jj%2]  : local_b2[jj][1]) : 0;
      op0[6]  = s1_6  ? (state == 1 ? local_a6[jj/2][jj%2]  : local_b3[jj][0]) : 0;
      op0[7]  = s1_7  ? (state == 1 ? local_a7[jj/2][jj%2]  : local_b3[jj][1]) : 0;
      op0[8]  = s1_8  ? (state == 1 ? local_a8[jj] : local_b4[jj][0]) : 0;
      op0[9]  = s1_9  ? (state == 1 ? local_a9[jj] : local_b4[jj][1]) : 0;
      op0[10]  = s1_10  ? (state == 1 ? local_a10[jj] : local_b5[jj][0]) : 0;
      op0[11]  = s1_11  ? (state == 1 ? local_a11[jj] : local_b5[jj][1]) : 0;
      op0[12]  = s1_12  ? (state == 1 ? local_a12[jj] : local_b6[jj][0]) : 0;
      op0[13]  = s1_13  ? (state == 1 ? local_a13[jj] : local_b6[jj][1]) : 0;
      op0[14]  = s1_14  ? (state == 1 ? local_a14[jj] : local_b7[jj][0]) : 0;
      op0[15]  = s1_15  ? (state == 1 ? local_a15[jj] : local_b7[jj][1]) : 0;
      s1 = (s1 << 1) | 0x1;

      int64_t tmp0;

      if (state == 1) {
        tmp_mul += dot_product(
          op0[0], op0[1], op0[2], op0[3], op0[4], op0[5], op0[6], op0[7], op0[8], op0[9], op0[10], op0[11], op0[12], op0[13], op0[14], op0[15], 
          op0[0], op0[1], op0[2], op0[3], op0[4], op0[5], op0[6], op0[7], op0[8], op0[9], op0[10], op0[11], op0[12], op0[13], op0[14], op0[15]);

        int64_t tmp_local_d = (jj % 4 == 0) ? local_d0[jj * SIZE/4 + (jj / 4)] :
                              (jj % 4 == 1) ? local_d1[jj * SIZE/4 + (jj / 4)] :
                              (jj % 4 == 2) ? local_d2[jj * SIZE/4 + (jj / 4)] :
                                              local_d3[jj * SIZE/4 + (jj / 4)];
        //tmp0 = (local_d[jj * SIZE + jj] - tmp_mul);
        tmp0 = (tmp_local_d - tmp_mul);
        if (sel0) local_a0[jj/2][jj%2] = tmp0;
        if (sel1) local_a1[jj/2][jj%2] = tmp0;
        if (sel2) local_a2[jj/2][jj%2] = tmp0;
        if (sel3) local_a3[jj/2][jj%2] = tmp0;
        if (sel4) local_a4[jj/2][jj%2] = tmp0;
        if (sel5) local_a5[jj/2][jj%2] = tmp0;
        if (sel6) local_a6[jj/2][jj%2] = tmp0;
        if (sel7) local_a7[jj/2][jj%2] = tmp0;
        if (sel8) local_a8[jj] = tmp0;
        if (sel9) local_a9[jj] = tmp0;
        if (sel10) local_a10[jj] = tmp0;
        if (sel11) local_a11[jj] = tmp0;
        if (sel12) local_a12[jj] = tmp0;
        if (sel13) local_a13[jj] = tmp0;
        if (sel14) local_a14[jj] = tmp0;
        if (sel15) local_a15[jj] = tmp0;

      } else {
        tmp0 =
          sel0 ? local_b0[jj][0] :
          sel1 ? local_b0[jj][1] :
          sel2 ? local_b1[jj][0] :
          sel3 ? local_b1[jj][1] :
          sel4 ? local_b2[jj][0] :
          sel5 ? local_b2[jj][1] :
          sel6 ? local_b3[jj][0] :
          sel7 ? local_b3[jj][1] :
          sel8 ? local_b4[jj][0] :
          sel9 ? local_b4[jj][1] :
          sel10 ? local_b5[jj][0] :
          sel11 ? local_b5[jj][1] :
          sel12 ? local_b6[jj][0] :
          sel13 ? local_b6[jj][1] :
          sel14 ? local_b7[jj][0] :
          sel15 ? local_b7[jj][1] :
          0;

      }
      int start_ii = (state == 1) ? (jj + 1) : 0;
      for (int ii = start_ii; ii < SIZE; ii++) {
        #pragma HLS PIPELINE II=1
        #pragma HLS DEPENDENCE variable=local_a0 inter false
        #pragma HLS DEPENDENCE variable=local_a1 inter false
        #pragma HLS DEPENDENCE variable=local_a2 inter false
        #pragma HLS DEPENDENCE variable=local_a3 inter false
        #pragma HLS DEPENDENCE variable=local_a4 inter false
        #pragma HLS DEPENDENCE variable=local_a5 inter false
        #pragma HLS DEPENDENCE variable=local_a6 inter false
        #pragma HLS DEPENDENCE variable=local_a7 inter false
        #pragma HLS DEPENDENCE variable=local_a8 inter false
        #pragma HLS DEPENDENCE variable=local_a9 inter false
        #pragma HLS DEPENDENCE variable=local_a10 inter false
        #pragma HLS DEPENDENCE variable=local_a11 inter false
        #pragma HLS DEPENDENCE variable=local_a12 inter false
        #pragma HLS DEPENDENCE variable=local_a13 inter false
        #pragma HLS DEPENDENCE variable=local_a14 inter false
        #pragma HLS DEPENDENCE variable=local_a15 inter false
        tmp_mul = local_c[ii * SIZE + jj];
        int64_t tmp_a0  = local_a0[ii/2][ii%2];
        int64_t tmp_a1  = local_a1[ii/2][ii%2];
        int64_t tmp_a2  = local_a2[ii/2][ii%2];
        int64_t tmp_a3  = local_a3[ii/2][ii%2];
        int64_t tmp_a4  = local_a4[ii/2][ii%2];
        int64_t tmp_a5  = local_a5[ii/2][ii%2];
        int64_t tmp_a6  = local_a6[ii/2][ii%2];
        int64_t tmp_a7  = local_a7[ii/2][ii%2];
        int64_t tmp_a8  = local_a8[ii];
        int64_t tmp_a9  = local_a9[ii];
        int64_t tmp_a10  = local_a10[ii];
        int64_t tmp_a11  = local_a11[ii];
        int64_t tmp_a12  = local_a12[ii];
        int64_t tmp_a13  = local_a13[ii];
        int64_t tmp_a14  = local_a14[ii];
        int64_t tmp_a15  = local_a15[ii];
        op1[0]  = tmp_a0;
        op1[1]  = tmp_a1;
        op1[2]  = tmp_a2;
        op1[3]  = tmp_a3;
        op1[4]  = tmp_a4;
        op1[5]  = tmp_a5;
        op1[6]  = tmp_a6;
        op1[7]  = tmp_a7;
        op1[8]  = tmp_a8;
        op1[9]  = tmp_a9;
        op1[10]  = tmp_a10;
        op1[11]  = tmp_a11;
        op1[12]  = tmp_a12;
        op1[13]  = tmp_a13;
        op1[14]  = tmp_a14;
        op1[15]  = tmp_a15;
        tmp_mul += dot_product(
          op0[0], op0[1], op0[2], op0[3], op0[4], op0[5], op0[6], op0[7], op0[8], op0[9], op0[10], op0[11], op0[12], op0[13], op0[14], op0[15], 
          op1[0], op1[1], op1[2], op1[3], op1[4], op1[5], op1[6], op1[7], op1[8], op1[9], op1[10], op1[11], op1[12], op1[13], op1[14], op1[15]);

        int64_t tmp_local_d = (jj % 4 == 0) ? local_d0[ii * SIZE/4 + (jj / 4)] :
                              (jj % 4 == 1) ? local_d1[ii * SIZE/4 + (jj / 4)] :
                              (jj % 4 == 2) ? local_d2[ii * SIZE/4 + (jj / 4)] :
                                              local_d3[ii * SIZE/4 + (jj / 4)];

        //int64_t tmp1 = (local_d[ii * SIZE + jj] - tmp_mul) * tmp0;
        int64_t tmp1 = (tmp_local_d - tmp_mul) * tmp0;
        if (sel0) local_a0[ii/2][ii%2] = tmp1;
        if (sel1) local_a1[ii/2][ii%2] = tmp1;
        if (sel2) local_a2[ii/2][ii%2] = tmp1;
        if (sel3) local_a3[ii/2][ii%2] = tmp1;
        if (sel4) local_a4[ii/2][ii%2] = tmp1;
        if (sel5) local_a5[ii/2][ii%2] = tmp1;
        if (sel6) local_a6[ii/2][ii%2] = tmp1;
        if (sel7) local_a7[ii/2][ii%2] = tmp1;
        if (sel8) local_a8[ii] = tmp1;
        if (sel9) local_a9[ii] = tmp1;
        if (sel10) local_a10[ii] = tmp1;
        if (sel11) local_a11[ii] = tmp1;
        if (sel12) local_a12[ii] = tmp1;
        if (sel13) local_a13[ii] = tmp1;
        if (sel14) local_a14[ii] = tmp1;
        if (sel15) local_a15[ii] = tmp1;

      }
      sel = sel << 1;
    }
    if (state == 1) {
      sel = 0xFFFE;
      for (int ii = 0; ii < SIZE; ii++) {
        #pragma HLS PIPELINE
        #pragma HLS DEPENDENCE variable=local_a0  inter false
        #pragma HLS DEPENDENCE variable=local_a1  inter false
        #pragma HLS DEPENDENCE variable=local_a2  inter false
        #pragma HLS DEPENDENCE variable=local_a3  inter false
        #pragma HLS DEPENDENCE variable=local_a4  inter false
        #pragma HLS DEPENDENCE variable=local_a5  inter false
        #pragma HLS DEPENDENCE variable=local_a6  inter false
        #pragma HLS DEPENDENCE variable=local_a7  inter false
        #pragma HLS DEPENDENCE variable=local_a8  inter false
        #pragma HLS DEPENDENCE variable=local_a9  inter false
        #pragma HLS DEPENDENCE variable=local_a10  inter false
        #pragma HLS DEPENDENCE variable=local_a11  inter false
        #pragma HLS DEPENDENCE variable=local_a12  inter false
        #pragma HLS DEPENDENCE variable=local_a13  inter false
        #pragma HLS DEPENDENCE variable=local_a14  inter false
        #pragma HLS DEPENDENCE variable=local_a15  inter false
        bool sel0  = (sel >> 0) & 0x1;
        bool sel1  = (sel >> 1) & 0x1;
        bool sel2  = (sel >> 2) & 0x1;
        bool sel3  = (sel >> 3) & 0x1;
        bool sel4  = (sel >> 4) & 0x1;
        bool sel5  = (sel >> 5) & 0x1;
        bool sel6  = (sel >> 6) & 0x1;
        bool sel7  = (sel >> 7) & 0x1;
        bool sel8  = (sel >> 8) & 0x1;
        bool sel9  = (sel >> 9) & 0x1;
        bool sel10  = (sel >> 10) & 0x1;
        bool sel11  = (sel >> 11) & 0x1;
        bool sel12  = (sel >> 12) & 0x1;
        bool sel13  = (sel >> 13) & 0x1;
        bool sel14  = (sel >> 14) & 0x1;
        bool sel15  = (sel >> 15) & 0x1;
        if (sel0) local_a0[ii/2][ii%2] = 0;
        if (sel1) local_a1[ii/2][ii%2] = 0;
        if (sel2) local_a2[ii/2][ii%2] = 0;
        if (sel3) local_a3[ii/2][ii%2] = 0;
        if (sel4) local_a4[ii/2][ii%2] = 0;
        if (sel5) local_a5[ii/2][ii%2] = 0;
        if (sel6) local_a6[ii/2][ii%2] = 0;
        if (sel7) local_a7[ii/2][ii%2] = 0;
        if (sel8) local_a8[ii] = 0;
        if (sel9) local_a9[ii] = 0;
        if (sel10) local_a10[ii] = 0;
        if (sel11) local_a11[ii] = 0;
        if (sel12) local_a12[ii] = 0;
        if (sel13) local_a13[ii] = 0;
        if (sel14) local_a14[ii] = 0;
        if (sel15) local_a15[ii] = 0;

        sel = sel << 1;
     }
   }
  } else if (state == 4) {
    for (int jj = 0; jj < SIZE; jj++) {
      for (int ii = jj; ii < SIZE; ii++) {
        local_c[ii * SIZE + jj] = 0;
      }
    }
  } else if (state == 5) {
    for (int jj = 0; jj < SIZE; jj++) {
      for (int ii = 0; ii < SIZE; ii++) {
        local_c[ii * SIZE + jj] = 0;
      }
    }
  }
}

