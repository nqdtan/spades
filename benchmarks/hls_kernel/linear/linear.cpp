
#include <iostream>
#include "linear.h"
#include <ap_int.h>
typedef ap_int<64> DATATYPE_IF;

#define IFM_BLK_LEN 32
#define OFM_BLK_LEN 64

//void cl_linear0(DATATYPE_IF ifm[4096], DATATYPE_IF ofm[4096], DATATYPE_IF wt[4096],
//  int ifm_len, int ofm_len, int init_ofm, int ofm_offset) {
//#pragma HLS INTERFACE mode=ap_memory port=ifm latency=3
//#pragma HLS INTERFACE mode=ap_memory port=ofm latency=3
//#pragma HLS INTERFACE mode=ap_memory port=wt  latency=3
//
//  DATATYPE local_ifm[4096];
//  DATATYPE local_ofm[4096];
//  DATATYPE local_wt[4096];
//
//  for (int i = 0; i < ifm_len; i++) {
//    if (i % 2 == 0)
//      local_ifm[i] = ifm[i/2].range(31, 0);
//    else
//      local_ifm[i] = ifm[i/2].range(63, 32);
//  }
//
//  for (int c = 0; c < ofm_len; c++) {
//    for (int i = 0; i < ifm_len; i++) {
//      int ind = c * ifm_len + i;
//      if (ind % 2 == 0)
//        local_wt[ind] = wt[ind/2].range(31, 0);
//      else
//        local_wt[ind] = wt[ind/2].range(63, 32);
//    }
//  }
//
//  for (int i = 0; i < ofm_len; i++) {
//    if (i % 2 == 0)
//      local_ofm[i] = ofm[i/2].range(31, 0);
//    else
//      local_ofm[i] = ofm[i/2].range(63, 32);
//  }
//
//  for (int c = 0; c < ofm_len; c++) {
//    DATATYPE tmp = 0;
//    for (int i = 0; i < ifm_len; i++) {
//      tmp += local_ifm[i] * local_wt[c * ifm_len + i];
//    }
//    local_ofm[c] = tmp;
//  }
//
//  DATATYPE_IF tmp_if;
//  for (int i = 0; i < ofm_len; i++) {
//    if (i % 2 == 0) {
//      if (init_ofm) {
//        tmp_if.range(31, 0) = 0;
//        tmp_if.range(63, 32) = 0;
//      } else
//        tmp_if = ofm[ofm_offset + i/2];
//      tmp_if.range(31, 0) = tmp_if.range(31, 0) + local_ofm[i];
//    } else
//      tmp_if.range(63, 32) = tmp_if.range(63, 32) + local_ofm[i];
//
//    if (i % 2 == 1 || i == ofm_len - 1)
//      ofm[ofm_offset + i/2] = tmp_if;
//  }
//}

void cl_linear(
  DATATYPE_IF ifm[4096],
  DATATYPE_IF ofm[4096],

  DATATYPE_IF wt00[4096],
  DATATYPE_IF wt01[4096],
  DATATYPE_IF wt02[4096],
  DATATYPE_IF wt03[4096],
  DATATYPE_IF wt04[4096],
  DATATYPE_IF wt05[4096],
  DATATYPE_IF wt06[4096],
  DATATYPE_IF wt07[4096],

  DATATYPE_IF wt10[4096],
  DATATYPE_IF wt11[4096],
  DATATYPE_IF wt12[4096],
  DATATYPE_IF wt13[4096],
  DATATYPE_IF wt14[4096],
  DATATYPE_IF wt15[4096],
  DATATYPE_IF wt16[4096],
  DATATYPE_IF wt17[4096],

  DATATYPE_IF wt20[4096],
  DATATYPE_IF wt21[4096],
  DATATYPE_IF wt22[4096],
  DATATYPE_IF wt23[4096],
  DATATYPE_IF wt24[4096],
  DATATYPE_IF wt25[4096],
  DATATYPE_IF wt26[4096],
  DATATYPE_IF wt27[4096],

  DATATYPE_IF wt30[4096],
  DATATYPE_IF wt31[4096],
  DATATYPE_IF wt32[4096],
  DATATYPE_IF wt33[4096],
  DATATYPE_IF wt34[4096],
  DATATYPE_IF wt35[4096],
  DATATYPE_IF wt36[4096],
  DATATYPE_IF wt37[4096],

  int ifm_len, int ofm_len, int init_ofm, int ifm_offset, int ofm_offset) {
#pragma HLS INTERFACE mode=ap_memory port=ifm latency=3 storage_type=ram_1p
#pragma HLS INTERFACE mode=ap_memory port=ofm latency=3

#pragma HLS INTERFACE mode=ap_memory port=wt00 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt01 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt02 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt03 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt04 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt05 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt06 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt07 latency=3

#pragma HLS INTERFACE mode=ap_memory port=wt10 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt11 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt12 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt13 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt14 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt15 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt16 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt17 latency=3

#pragma HLS INTERFACE mode=ap_memory port=wt20 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt21 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt22 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt23 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt24 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt25 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt26 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt27 latency=3

#pragma HLS INTERFACE mode=ap_memory port=wt30 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt31 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt32 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt33 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt34 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt35 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt36 latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt37 latency=3

  DATATYPE local_ifm[IFM_BLK_LEN];
#pragma HLS ARRAY_PARTITION variable=local_ifm dim=1 complete

  DATATYPE local_ofm[OFM_BLK_LEN/2][4];
#pragma HLS ARRAY_PARTITION variable=local_ofm dim=2 complete
//#pragma HLS BIND_STORAGE variable=local_ofm type=RAM_2P impl=lutram

  int tmp0, tmp1;
  DATATYPE tmp0_f, tmp1_f;
  for (int i = 0; i < IFM_BLK_LEN/2; i+=1) {
    if (i < ifm_len / 2) {
      #pragma HLS UNROLL
      tmp0 = ifm[ifm_offset + i].range(31, 0);
      tmp1 = ifm[ifm_offset + i].range(63, 32);
      local_ifm[2*i+0] = *(reinterpret_cast<DATATYPE*>(&tmp0));
      local_ifm[2*i+1] = *(reinterpret_cast<DATATYPE*>(&tmp1));
    } else {
      local_ifm[2*i+0] = 0;
      local_ifm[2*i+1] = 0;
    }
  }

//  for (int j = 0; j < ofm_len/2; j+=2) {
  for (int j = 0; j < OFM_BLK_LEN/2; j+=2) {
    #pragma HLS PIPELINE II=1
    tmp0 = wt00[j].range(31, 0);
    tmp1 = wt00[j].range(63, 32);
    DATATYPE wt00_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt00_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt01[j].range(31, 0);
    tmp1 = wt01[j].range(63, 32);
    DATATYPE wt01_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt01_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt02[j].range(31, 0);
    tmp1 = wt02[j].range(63, 32);
    DATATYPE wt02_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt02_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt03[j].range(31, 0);
    tmp1 = wt03[j].range(63, 32);
    DATATYPE wt03_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt03_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt04[j].range(31, 0);
    tmp1 = wt04[j].range(63, 32);
    DATATYPE wt04_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt04_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt05[j].range(31, 0);
    tmp1 = wt05[j].range(63, 32);
    DATATYPE wt05_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt05_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt06[j].range(31, 0);
    tmp1 = wt06[j].range(63, 32);
    DATATYPE wt06_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt06_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt07[j].range(31, 0);
    tmp1 = wt07[j].range(63, 32);
    DATATYPE wt07_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt07_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));

    local_ofm[j][0] = local_ifm[2*0+0] * wt00_val0 + local_ifm[2*0+1] * wt00_val1 +
                      local_ifm[2*1+0] * wt01_val0 + local_ifm[2*1+1] * wt01_val1 +
                      local_ifm[2*2+0] * wt02_val0 + local_ifm[2*2+1] * wt02_val1 +
                      local_ifm[2*3+0] * wt03_val0 + local_ifm[2*3+1] * wt03_val1 +
                      local_ifm[2*4+0] * wt04_val0 + local_ifm[2*4+1] * wt04_val1 +
                      local_ifm[2*5+0] * wt05_val0 + local_ifm[2*5+1] * wt05_val1 +
                      local_ifm[2*6+0] * wt06_val0 + local_ifm[2*6+1] * wt06_val1 +
                      local_ifm[2*7+0] * wt07_val0 + local_ifm[2*7+1] * wt07_val1;

    tmp0 = wt00[j+1].range(31, 0);
    tmp1 = wt00[j+1].range(63, 32);
    wt00_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt00_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt01[j+1].range(31, 0);
    tmp1 = wt01[j+1].range(63, 32);
    wt01_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt01_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt02[j+1].range(31, 0);
    tmp1 = wt02[j+1].range(63, 32);
    wt02_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt02_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt03[j+1].range(31, 0);
    tmp1 = wt03[j+1].range(63, 32);
    wt03_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt03_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt04[j+1].range(31, 0);
    tmp1 = wt04[j+1].range(63, 32);
    wt04_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt04_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt05[j+1].range(31, 0);
    tmp1 = wt05[j+1].range(63, 32);
    wt05_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt05_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt06[j+1].range(31, 0);
    tmp1 = wt06[j+1].range(63, 32);
    wt06_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt06_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt07[j+1].range(31, 0);
    tmp1 = wt07[j+1].range(63, 32);
    wt07_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt07_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));

    local_ofm[j+1][0] = local_ifm[2*0+0] * wt00_val0 + local_ifm[2*0+1] * wt00_val1 +
                      local_ifm[2*1+0] * wt01_val0 + local_ifm[2*1+1] * wt01_val1 +
                      local_ifm[2*2+0] * wt02_val0 + local_ifm[2*2+1] * wt02_val1 +
                      local_ifm[2*3+0] * wt03_val0 + local_ifm[2*3+1] * wt03_val1 +
                      local_ifm[2*4+0] * wt04_val0 + local_ifm[2*4+1] * wt04_val1 +
                      local_ifm[2*5+0] * wt05_val0 + local_ifm[2*5+1] * wt05_val1 +
                      local_ifm[2*6+0] * wt06_val0 + local_ifm[2*6+1] * wt06_val1 +
                      local_ifm[2*7+0] * wt07_val0 + local_ifm[2*7+1] * wt07_val1;

    tmp0 = wt10[j].range(31, 0);
    tmp1 = wt10[j].range(63, 32);
    DATATYPE wt10_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt10_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt11[j].range(31, 0);
    tmp1 = wt11[j].range(63, 32);
    DATATYPE wt11_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt11_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt12[j].range(31, 0);
    tmp1 = wt12[j].range(63, 32);
    DATATYPE wt12_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt12_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt13[j].range(31, 0);
    tmp1 = wt13[j].range(63, 32);
    DATATYPE wt13_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt13_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt14[j].range(31, 0);
    tmp1 = wt14[j].range(63, 32);
    DATATYPE wt14_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt14_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt15[j].range(31, 0);
    tmp1 = wt15[j].range(63, 32);
    DATATYPE wt15_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt15_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt16[j].range(31, 0);
    tmp1 = wt16[j].range(63, 32);
    DATATYPE wt16_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt16_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt17[j].range(31, 0);
    tmp1 = wt17[j].range(63, 32);
    DATATYPE wt17_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt17_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));

    local_ofm[j][1] = local_ifm[2*0+0] * wt10_val0 + local_ifm[2*0+1] * wt10_val1 +
                      local_ifm[2*1+0] * wt11_val0 + local_ifm[2*1+1] * wt11_val1 +
                      local_ifm[2*2+0] * wt12_val0 + local_ifm[2*2+1] * wt12_val1 +
                      local_ifm[2*3+0] * wt13_val0 + local_ifm[2*3+1] * wt13_val1 +
                      local_ifm[2*4+0] * wt14_val0 + local_ifm[2*4+1] * wt14_val1 +
                      local_ifm[2*5+0] * wt15_val0 + local_ifm[2*5+1] * wt15_val1 +
                      local_ifm[2*6+0] * wt16_val0 + local_ifm[2*6+1] * wt16_val1 +
                      local_ifm[2*7+0] * wt17_val0 + local_ifm[2*7+1] * wt17_val1;

    tmp0 = wt10[j+1].range(31, 0);
    tmp1 = wt10[j+1].range(63, 32);
    wt10_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt10_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt11[j+1].range(31, 0);
    tmp1 = wt11[j+1].range(63, 32);
    wt11_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt11_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt12[j+1].range(31, 0);
    tmp1 = wt12[j+1].range(63, 32);
    wt12_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt12_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt13[j+1].range(31, 0);
    tmp1 = wt13[j+1].range(63, 32);
    wt13_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt13_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt14[j+1].range(31, 0);
    tmp1 = wt14[j+1].range(63, 32);
    wt14_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt14_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt15[j+1].range(31, 0);
    tmp1 = wt15[j+1].range(63, 32);
    wt15_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt15_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt16[j+1].range(31, 0);
    tmp1 = wt16[j+1].range(63, 32);
    wt16_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt16_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt17[j+1].range(31, 0);
    tmp1 = wt17[j+1].range(63, 32);
    wt17_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt17_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));

    local_ofm[j+1][1] = local_ifm[2*0+0] * wt10_val0 + local_ifm[2*0+1] * wt10_val1 +
                      local_ifm[2*1+0] * wt11_val0 + local_ifm[2*1+1] * wt11_val1 +
                      local_ifm[2*2+0] * wt12_val0 + local_ifm[2*2+1] * wt12_val1 +
                      local_ifm[2*3+0] * wt13_val0 + local_ifm[2*3+1] * wt13_val1 +
                      local_ifm[2*4+0] * wt14_val0 + local_ifm[2*4+1] * wt14_val1 +
                      local_ifm[2*5+0] * wt15_val0 + local_ifm[2*5+1] * wt15_val1 +
                      local_ifm[2*6+0] * wt16_val0 + local_ifm[2*6+1] * wt16_val1 +
                      local_ifm[2*7+0] * wt17_val0 + local_ifm[2*7+1] * wt17_val1;

    tmp0 = wt20[j].range(31, 0);
    tmp1 = wt20[j].range(63, 32);
    DATATYPE wt20_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt20_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt21[j].range(31, 0);
    tmp1 = wt21[j].range(63, 32);
    DATATYPE wt21_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt21_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt22[j].range(31, 0);
    tmp1 = wt22[j].range(63, 32);
    DATATYPE wt22_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt22_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt23[j].range(31, 0);
    tmp1 = wt23[j].range(63, 32);
    DATATYPE wt23_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt23_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt24[j].range(31, 0);
    tmp1 = wt24[j].range(63, 32);
    DATATYPE wt24_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt24_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt25[j].range(31, 0);
    tmp1 = wt25[j].range(63, 32);
    DATATYPE wt25_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt25_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt26[j].range(31, 0);
    tmp1 = wt26[j].range(63, 32);
    DATATYPE wt26_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt26_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt27[j].range(31, 0);
    tmp1 = wt27[j].range(63, 32);
    DATATYPE wt27_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt27_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));

    local_ofm[j][2] = local_ifm[2*0+0] * wt20_val0 + local_ifm[2*0+1] * wt20_val1 +
                      local_ifm[2*1+0] * wt21_val0 + local_ifm[2*1+1] * wt21_val1 +
                      local_ifm[2*2+0] * wt22_val0 + local_ifm[2*2+1] * wt22_val1 +
                      local_ifm[2*3+0] * wt23_val0 + local_ifm[2*3+1] * wt23_val1 +
                      local_ifm[2*4+0] * wt24_val0 + local_ifm[2*4+1] * wt24_val1 +
                      local_ifm[2*5+0] * wt25_val0 + local_ifm[2*5+1] * wt25_val1 +
                      local_ifm[2*6+0] * wt26_val0 + local_ifm[2*6+1] * wt26_val1 +
                      local_ifm[2*7+0] * wt27_val0 + local_ifm[2*7+1] * wt27_val1;

    tmp0 = wt20[j+1].range(31, 0);
    tmp1 = wt20[j+1].range(63, 32);
    wt20_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt20_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt21[j+1].range(31, 0);
    tmp1 = wt21[j+1].range(63, 32);
    wt21_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt21_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt22[j+1].range(31, 0);
    tmp1 = wt22[j+1].range(63, 32);
    wt22_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt22_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt23[j+1].range(31, 0);
    tmp1 = wt23[j+1].range(63, 32);
    wt23_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt23_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt24[j+1].range(31, 0);
    tmp1 = wt24[j+1].range(63, 32);
    wt24_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt24_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt25[j+1].range(31, 0);
    tmp1 = wt25[j+1].range(63, 32);
    wt25_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt25_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt26[j+1].range(31, 0);
    tmp1 = wt26[j+1].range(63, 32);
    wt26_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt26_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt27[j+1].range(31, 0);
    tmp1 = wt27[j+1].range(63, 32);
    wt27_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt27_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));

    local_ofm[j+1][2] = local_ifm[2*0+0] * wt20_val0 + local_ifm[2*0+1] * wt20_val1 +
                      local_ifm[2*1+0] * wt21_val0 + local_ifm[2*1+1] * wt21_val1 +
                      local_ifm[2*2+0] * wt22_val0 + local_ifm[2*2+1] * wt22_val1 +
                      local_ifm[2*3+0] * wt23_val0 + local_ifm[2*3+1] * wt23_val1 +
                      local_ifm[2*4+0] * wt24_val0 + local_ifm[2*4+1] * wt24_val1 +
                      local_ifm[2*5+0] * wt25_val0 + local_ifm[2*5+1] * wt25_val1 +
                      local_ifm[2*6+0] * wt26_val0 + local_ifm[2*6+1] * wt26_val1 +
                      local_ifm[2*7+0] * wt27_val0 + local_ifm[2*7+1] * wt27_val1;

    tmp0 = wt30[j].range(31, 0);
    tmp1 = wt30[j].range(63, 32);
    DATATYPE wt30_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt30_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt31[j].range(31, 0);
    tmp1 = wt31[j].range(63, 32);
    DATATYPE wt31_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt31_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt32[j].range(31, 0);
    tmp1 = wt32[j].range(63, 32);
    DATATYPE wt32_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt32_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt33[j].range(31, 0);
    tmp1 = wt33[j].range(63, 32);
    DATATYPE wt33_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt33_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt34[j].range(31, 0);
    tmp1 = wt34[j].range(63, 32);
    DATATYPE wt34_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt34_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt35[j].range(31, 0);
    tmp1 = wt35[j].range(63, 32);
    DATATYPE wt35_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt35_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt36[j].range(31, 0);
    tmp1 = wt36[j].range(63, 32);
    DATATYPE wt36_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt36_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt37[j].range(31, 0);
    tmp1 = wt37[j].range(63, 32);
    DATATYPE wt37_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    DATATYPE wt37_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));

    local_ofm[j][3] = local_ifm[2*0+0] * wt30_val0 + local_ifm[2*0+1] * wt30_val1 +
                      local_ifm[2*1+0] * wt31_val0 + local_ifm[2*1+1] * wt31_val1 +
                      local_ifm[2*2+0] * wt32_val0 + local_ifm[2*2+1] * wt32_val1 +
                      local_ifm[2*3+0] * wt33_val0 + local_ifm[2*3+1] * wt33_val1 +
                      local_ifm[2*4+0] * wt34_val0 + local_ifm[2*4+1] * wt34_val1 +
                      local_ifm[2*5+0] * wt35_val0 + local_ifm[2*5+1] * wt35_val1 +
                      local_ifm[2*6+0] * wt36_val0 + local_ifm[2*6+1] * wt36_val1 +
                      local_ifm[2*7+0] * wt37_val0 + local_ifm[2*7+1] * wt37_val1;

    tmp0 = wt30[j+1].range(31, 0);
    tmp1 = wt30[j+1].range(63, 32);
    wt30_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt30_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt31[j+1].range(31, 0);
    tmp1 = wt31[j+1].range(63, 32);
    wt31_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt31_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt32[j+1].range(31, 0);
    tmp1 = wt32[j+1].range(63, 32);
    wt32_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt32_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt33[j+1].range(31, 0);
    tmp1 = wt33[j+1].range(63, 32);
    wt33_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt33_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt34[j+1].range(31, 0);
    tmp1 = wt34[j+1].range(63, 32);
    wt34_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt34_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt35[j+1].range(31, 0);
    tmp1 = wt35[j+1].range(63, 32);
    wt35_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt35_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt36[j+1].range(31, 0);
    tmp1 = wt36[j+1].range(63, 32);
    wt36_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt36_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));
    tmp0 = wt37[j+1].range(31, 0);
    tmp1 = wt37[j+1].range(63, 32);
    wt37_val0 = *(reinterpret_cast<DATATYPE*>(&tmp0));
    wt37_val1 = *(reinterpret_cast<DATATYPE*>(&tmp1));

    local_ofm[j+1][3] = local_ifm[2*0+0] * wt30_val0 + local_ifm[2*0+1] * wt30_val1 +
                      local_ifm[2*1+0] * wt31_val0 + local_ifm[2*1+1] * wt31_val1 +
                      local_ifm[2*2+0] * wt32_val0 + local_ifm[2*2+1] * wt32_val1 +
                      local_ifm[2*3+0] * wt33_val0 + local_ifm[2*3+1] * wt33_val1 +
                      local_ifm[2*4+0] * wt34_val0 + local_ifm[2*4+1] * wt34_val1 +
                      local_ifm[2*5+0] * wt35_val0 + local_ifm[2*5+1] * wt35_val1 +
                      local_ifm[2*6+0] * wt36_val0 + local_ifm[2*6+1] * wt36_val1 +
                      local_ifm[2*7+0] * wt37_val0 + local_ifm[2*7+1] * wt37_val1;
  }

  DATATYPE_IF tmp_if;
  for (int i = 0; i < ofm_len; i++) {
    #pragma HLS PIPELINE II=1
    #pragma HLS DEPENDENCE variable=ofm inter false
//    DATATYPE local_ofm_tmp = ((i % 2 == 0) && (i < ofm_len/2)) ? local_ofm[i/2][0] :
//                             ((i % 2 == 1) && (i < ofm_len/2)) ? local_ofm[i/2][1] :
//                             ((i % 2 == 0) && (i >= ofm_len/2))? local_ofm[(i-ofm_len/2)/2][2] :
//                                                                 local_ofm[(i-ofm_len/2)/2][3];

    DATATYPE local_ofm_tmp = ((i % 2 == 0) && (i < OFM_BLK_LEN/2)) ? local_ofm[i/2][0] :
                             ((i % 2 == 1) && (i < OFM_BLK_LEN/2)) ? local_ofm[i/2][1] :
                             ((i % 2 == 0) && (i >= OFM_BLK_LEN/2))? local_ofm[(i-OFM_BLK_LEN/2)/2][2] :
                                                                     local_ofm[(i-OFM_BLK_LEN/2)/2][3];

    if (i % 2 == 0) {
      if (init_ofm) {
        tmp_if.range(31, 0) = 0;
        tmp_if.range(63, 32) = 0;
      } else
        tmp_if = ofm[ofm_offset + i/2];
      tmp0 = tmp_if.range(31, 0);
      tmp1 = tmp_if.range(63, 32);
      tmp0_f = *(reinterpret_cast<DATATYPE*>(&tmp0));
      tmp1_f = *(reinterpret_cast<DATATYPE*>(&tmp1));
    }

    local_ofm_tmp = local_ofm_tmp + ((i % 2 == 0) ? tmp0_f : tmp1_f);

    if (i % 2 == 0) {
      tmp0 = *(reinterpret_cast<int*>(&local_ofm_tmp));
      tmp_if.range(31, 0) = tmp0;
    } else {
      tmp1 = *(reinterpret_cast<int*>(&local_ofm_tmp));
      tmp_if.range(63, 32) = tmp1;
    }

    if (i % 2 == 1 || i == ofm_len - 1)
      ofm[ofm_offset + i/2] = tmp_if;
  }
}
