
#include <iostream>
#include "conv3d.h"

#define IFM_DIM 13
#define WT_DIM 3
#define PAD 1
#define OFM_DIM (IFM_DIM + 2 * PAD - WT_DIM + 1)

#define NUM_CONV2D 8

#define IFM_P_DIM (OFM_DIM)
#define P_DIM 3
#define OFM_P_DIM (IFM_P_DIM / 2)


void cl_conv2d(
  DATATYPE_IF ifm[4096],
  DATATYPE_IF wt[4096],
  DATATYPE    ofm[4096],
  int wt_offset,
  int ifm_offset,
  int run
) {
#pragma HLS INTERFACE mode=ap_memory port=ifm latency=3
#pragma HLS INTERFACE mode=ap_memory port=wt latency=3 storage_type=ram_1p
#pragma HLS INTERFACE mode=ap_memory port=ofm latency=3

  DATATYPE local_ifm[WT_DIM][WT_DIM];
#pragma HLS ARRAY_PARTITION variable=local_ifm dim=1 complete
#pragma HLS ARRAY_PARTITION variable=local_ifm dim=2 complete

  DATATYPE local_wt[WT_DIM][WT_DIM];
#pragma HLS ARRAY_PARTITION variable=local_wt dim=1 complete 
#pragma HLS ARRAY_PARTITION variable=local_wt dim=2 complete

  if (!run)
    return;

  // load weight
  for (int m = 0; m < WT_DIM; m++) {
    #pragma HLS UNROLL
    for (int n = 0; n < WT_DIM; n++) {
      #pragma HLS UNROLL
      for (int s = 0; s < WT_DIM - 1; s++) {
        #pragma HLS UNROLL
        local_wt[m][s] = local_wt[m][s + 1];
      }
//      local_wt[m][WT_DIM - 1] = wt[m * WT_DIM + n];
      int ind = m * WT_DIM + n;
      int tmp0 = wt[wt_offset + ind/2].range(31, 0);
      int tmp1 = wt[wt_offset + ind/2].range(63, 32);
      local_wt[m][WT_DIM - 1] = (ind % 2 == 0) ? *(reinterpret_cast<DATATYPE*>(&tmp0)) :
                                                 *(reinterpret_cast<DATATYPE*>(&tmp1));
    }
  }

  //#pragma HLS DATAFLOW
  DATATYPE local_psum [WT_DIM][WT_DIM * OFM_DIM];
#pragma HLS ARRAY_PARTITION variable=local_psum dim=1 complete
#pragma HLS BIND_STORAGE variable=local_psum type=RAM_S2P impl=lutram

  DATATYPE_IF tmp_if;
  int tmp0, tmp1;
  DATATYPE tmp0_f, tmp1_f;

  int cur_psum_w_row[WT_DIM];
  int cur_psum_r_row[WT_DIM];
#pragma HLS ARRAY_PARTITION variable=cur_psum_w_row dim=1 complete
#pragma HLS ARRAY_PARTITION variable=cur_psum_r_row dim=1 complete
  for (int i = 0; i < WT_DIM; i++) {
    #pragma HLS UNROLL
    cur_psum_w_row[i] = 0;
    cur_psum_r_row[i] = 0;
  }

  for (int i = 0; i < IFM_DIM + 2 * PAD; i++) {
    for (int j = 0; j < IFM_DIM + 2 * PAD; j++) {
      #pragma HLS PIPELINE II=1
      #pragma HLS DEPENDENCE variable=ofm inter false

//      DATATYPE ifm_value = (i < PAD || j < PAD || i >= IFM_DIM + PAD || j >= IFM_DIM + PAD) ? 0 :
//        ifm[(i - PAD) * IFM_DIM + j - PAD];

      int ind = (i - PAD) * IFM_DIM + j - PAD;
      int tmp0 = ifm[ifm_offset + ind / 2].range(31, 0);
      int tmp1 = ifm[ifm_offset + ind / 2].range(63, 32);
      DATATYPE ifm_value = (i < PAD || j < PAD || i >= IFM_DIM + PAD || j >= IFM_DIM + PAD) ? 0 :
        (ind % 2 == 0) ? *(reinterpret_cast<DATATYPE*>(&tmp0)) :
                         *(reinterpret_cast<DATATYPE*>(&tmp1));

      // load ifm
      for (int m = 0; m < WT_DIM; m++) {
        if (i >= m && i <= IFM_DIM + 2 * PAD - (WT_DIM - m)) {
          // shift register
          for (int s = 0; s < WT_DIM - 1; s++)
            local_ifm[m][s] = local_ifm[m][s + 1];
          local_ifm[m][WT_DIM - 1] = ifm_value;

        }
      }

      for (int m = 0; m < WT_DIM; m++) {
        if (i >= m && i <= IFM_DIM + 2 * PAD - (WT_DIM - m)) {
          // compute
          if (j >= WT_DIM - 1) {
            DATATYPE tmp = 0;
            for (int n = 0; n < WT_DIM; n++) {
              tmp += local_ifm[m][n] * local_wt[m][n];
            }
            //local_psum[m][(i - m) * OFM_DIM + j - (WT_DIM - 1)] = tmp;
            local_psum[m][cur_psum_w_row[m] + j - (WT_DIM - 1)] = tmp;
            int cur_psum_w_row_tmp = cur_psum_w_row[m] + OFM_DIM;
            cur_psum_w_row[m] = (cur_psum_w_row_tmp == WT_DIM * OFM_DIM) ? 0 : cur_psum_w_row_tmp;
          }
        }
      }

      if (i >= WT_DIM - 1 && j >= WT_DIM - 1) {
        int i1 = i - (WT_DIM - 1);
        int j1 = j - (WT_DIM - 1);
        int ind1 = i1 * OFM_DIM + j1;
        DATATYPE tmp = 0;
        for (int m = 0; m < WT_DIM; m++) {
          tmp += local_psum[m][cur_psum_r_row[m] + j1];
          int cur_psum_r_row_tmp = cur_psum_r_row[m] + OFM_DIM;
          cur_psum_r_row[m] = (cur_psum_r_row_tmp == WT_DIM * OFM_DIM) ? 0 : cur_psum_r_row_tmp;
        }
        ofm[ind1] = tmp;

//        DATATYPE tmp = 0;//ofm[ind1];
//        for (int m = 0; m < WT_DIM; m++) {
//          tmp += local_psum[m][cur_psum_r_row[m] + j1];
//          int cur_psum_r_row_tmp = cur_psum_r_row[m] + OFM_DIM;
//          cur_psum_r_row[m] = (cur_psum_r_row_tmp == WT_DIM * OFM_DIM) ? 0 : cur_psum_r_row_tmp;
//        }
//        ofm[ind1] = tmp;
      } else if (i >= WT_DIM - 1) {
        ofm[0] = 1; // garbage data
      }
    }
  }

}

void cl_conv3d(

  DATATYPE_IF ifm0[4096],

  DATATYPE_IF ifm1[4096],

  DATATYPE_IF ifm2[4096],

  DATATYPE_IF ifm3[4096],

  DATATYPE_IF ifm4[4096],

  DATATYPE_IF ifm5[4096],

  DATATYPE_IF ifm6[4096],

  DATATYPE_IF ifm7[4096],

  DATATYPE_IF wt0[4096],

  DATATYPE_IF wt1[4096],

  DATATYPE_IF wt2[4096],

  DATATYPE_IF wt3[4096],

  DATATYPE_IF wt4[4096],

  DATATYPE_IF wt5[4096],

  DATATYPE_IF wt6[4096],

  DATATYPE_IF wt7[4096],

  DATATYPE_IF ofm[4096],
  int len, int wt_offset, int ifm_offset, int ofm_offset, int state
) {

#pragma HLS INTERFACE mode=ap_memory port=ifm0 latency=3

#pragma HLS INTERFACE mode=ap_memory port=ifm1 latency=3

#pragma HLS INTERFACE mode=ap_memory port=ifm2 latency=3

#pragma HLS INTERFACE mode=ap_memory port=ifm3 latency=3

#pragma HLS INTERFACE mode=ap_memory port=ifm4 latency=3

#pragma HLS INTERFACE mode=ap_memory port=ifm5 latency=3

#pragma HLS INTERFACE mode=ap_memory port=ifm6 latency=3

#pragma HLS INTERFACE mode=ap_memory port=ifm7 latency=3

#pragma HLS INTERFACE mode=ap_memory port=wt0 latency=3 storage_type=ram_1p

#pragma HLS INTERFACE mode=ap_memory port=wt1 latency=3 storage_type=ram_1p

#pragma HLS INTERFACE mode=ap_memory port=wt2 latency=3 storage_type=ram_1p

#pragma HLS INTERFACE mode=ap_memory port=wt3 latency=3 storage_type=ram_1p

#pragma HLS INTERFACE mode=ap_memory port=wt4 latency=3 storage_type=ram_1p

#pragma HLS INTERFACE mode=ap_memory port=wt5 latency=3 storage_type=ram_1p

#pragma HLS INTERFACE mode=ap_memory port=wt6 latency=3 storage_type=ram_1p

#pragma HLS INTERFACE mode=ap_memory port=wt7 latency=3 storage_type=ram_1p

#pragma HLS INTERFACE mode=ap_memory port=ofm latency=3

  DATATYPE ofm0[OFM_DIM * OFM_DIM];

  DATATYPE ofm1[OFM_DIM * OFM_DIM];

  DATATYPE ofm2[OFM_DIM * OFM_DIM];

  DATATYPE ofm3[OFM_DIM * OFM_DIM];

  DATATYPE ofm4[OFM_DIM * OFM_DIM];

  DATATYPE ofm5[OFM_DIM * OFM_DIM];

  DATATYPE ofm6[OFM_DIM * OFM_DIM];

  DATATYPE ofm7[OFM_DIM * OFM_DIM];

  cl_conv2d(ifm0, wt0, ofm0, wt_offset, ifm_offset, len >= 1);

  cl_conv2d(ifm1, wt1, ofm1, wt_offset, ifm_offset, len >= 2);

  cl_conv2d(ifm2, wt2, ofm2, wt_offset, ifm_offset, len >= 3);

  cl_conv2d(ifm3, wt3, ofm3, wt_offset, ifm_offset, len >= 4);

  cl_conv2d(ifm4, wt4, ofm4, wt_offset, ifm_offset, len >= 5);

  cl_conv2d(ifm5, wt5, ofm5, wt_offset, ifm_offset, len >= 6);

  cl_conv2d(ifm6, wt6, ofm6, wt_offset, ifm_offset, len >= 7);

  cl_conv2d(ifm7, wt7, ofm7, wt_offset, ifm_offset, len >= 8);


  DATATYPE_IF tmp_if;
  int tmp0, tmp1;
  DATATYPE tmp0_f, tmp1_f;
  for (int i = 0; i < OFM_DIM; i++) {
    for (int j = 0; j < WT_DIM - 1 + OFM_DIM; j++) {
      #pragma HLS PIPELINE II=1
      #pragma HLS DEPENDENCE variable=ofm inter false
      int ind = i * OFM_DIM + j;
      DATATYPE ofm0_val = (len >= 1) ? ofm0[ind] : 0;
      DATATYPE ofm1_val = (len >= 2) ? ofm1[ind] : 0;
      DATATYPE ofm2_val = (len >= 3) ? ofm2[ind] : 0;
      DATATYPE ofm3_val = (len >= 4) ? ofm3[ind] : 0;
      DATATYPE ofm4_val = (len >= 5) ? ofm4[ind] : 0;
      DATATYPE ofm5_val = (len >= 6) ? ofm5[ind] : 0;
      DATATYPE ofm6_val = (len >= 7) ? ofm6[ind] : 0;
      DATATYPE ofm7_val = (len >= 8) ? ofm7[ind] : 0;

      DATATYPE tmp = ofm0_val + ofm1_val + ofm2_val + ofm3_val + ofm4_val + ofm5_val + ofm6_val + ofm7_val + 0;

      if (j < OFM_DIM) {
        //ofm[i * OFM_DIM + j] += ofm0[i * OFM_DIM + j] + ofm1[i * OFM_DIM + j];

        if (ind % 2 == 0) {
          tmp_if = ofm[ofm_offset + ind/2];
          tmp0 = tmp_if.range(31, 0);
          tmp1 = tmp_if.range(63, 32);
          tmp0_f = *(reinterpret_cast<DATATYPE*>(&tmp0));
          tmp1_f = *(reinterpret_cast<DATATYPE*>(&tmp1));
        }

        tmp = tmp + ((ind % 2 == 0) ? tmp0_f : tmp1_f);

        if (ind % 2 == 0) {
          tmp0 = *(reinterpret_cast<int*>(&tmp));
          tmp_if.range(31, 0) = tmp0;
        } else {
          tmp1 = *(reinterpret_cast<int*>(&tmp));
          tmp_if.range(63, 32) = tmp1;
        }

        if (ind % 2 == 1 || ind == OFM_DIM * OFM_DIM - 1) {
          ofm[ofm_offset + ind/2] = tmp_if;
        }
      }
    }
  }

}

void cl_conv3d_base(

  DATATYPE_IF ifm0[4096],

  DATATYPE_IF ifm1[4096],

  DATATYPE_IF ifm2[4096],

  DATATYPE_IF ifm3[4096],

  DATATYPE_IF ifm4[4096],

  DATATYPE_IF ifm5[4096],

  DATATYPE_IF ifm6[4096],

  DATATYPE_IF ifm7[4096],

  DATATYPE_IF wt0[4096],

  DATATYPE_IF wt1[4096],

  DATATYPE_IF wt2[4096],

  DATATYPE_IF wt3[4096],

  DATATYPE_IF wt4[4096],

  DATATYPE_IF wt5[4096],

  DATATYPE_IF wt6[4096],

  DATATYPE_IF wt7[4096],

  DATATYPE    ofm0[4096],

  DATATYPE    ofm1[4096],

  DATATYPE    ofm2[4096],

  DATATYPE    ofm3[4096],

  DATATYPE    ofm4[4096],

  DATATYPE    ofm5[4096],

  DATATYPE    ofm6[4096],

  DATATYPE    ofm7[4096],

  int len, int wt_offset, int ifm_offset
) {

#pragma HLS INTERFACE mode=ap_memory port=ifm0 latency=3

#pragma HLS INTERFACE mode=ap_memory port=ifm1 latency=3

#pragma HLS INTERFACE mode=ap_memory port=ifm2 latency=3

#pragma HLS INTERFACE mode=ap_memory port=ifm3 latency=3

#pragma HLS INTERFACE mode=ap_memory port=ifm4 latency=3

#pragma HLS INTERFACE mode=ap_memory port=ifm5 latency=3

#pragma HLS INTERFACE mode=ap_memory port=ifm6 latency=3

#pragma HLS INTERFACE mode=ap_memory port=ifm7 latency=3

#pragma HLS INTERFACE mode=ap_memory port=wt0 latency=3 storage_type=ram_1p

#pragma HLS INTERFACE mode=ap_memory port=wt1 latency=3 storage_type=ram_1p

#pragma HLS INTERFACE mode=ap_memory port=wt2 latency=3 storage_type=ram_1p

#pragma HLS INTERFACE mode=ap_memory port=wt3 latency=3 storage_type=ram_1p

#pragma HLS INTERFACE mode=ap_memory port=wt4 latency=3 storage_type=ram_1p

#pragma HLS INTERFACE mode=ap_memory port=wt5 latency=3 storage_type=ram_1p

#pragma HLS INTERFACE mode=ap_memory port=wt6 latency=3 storage_type=ram_1p

#pragma HLS INTERFACE mode=ap_memory port=wt7 latency=3 storage_type=ram_1p

  cl_conv2d(ifm0, wt0, ofm0, wt_offset, ifm_offset, len >= 1);

  cl_conv2d(ifm1, wt1, ofm1, wt_offset, ifm_offset, len >= 2);

  cl_conv2d(ifm2, wt2, ofm2, wt_offset, ifm_offset, len >= 3);

  cl_conv2d(ifm3, wt3, ofm3, wt_offset, ifm_offset, len >= 4);

  cl_conv2d(ifm4, wt4, ofm4, wt_offset, ifm_offset, len >= 5);

  cl_conv2d(ifm5, wt5, ofm5, wt_offset, ifm_offset, len >= 6);

  cl_conv2d(ifm6, wt6, ofm6, wt_offset, ifm_offset, len >= 7);

  cl_conv2d(ifm7, wt7, ofm7, wt_offset, ifm_offset, len >= 8);

}

void cl_conv3d_acc(

  volatile DATATYPE *ofm0,

  volatile DATATYPE *ofm1,

  volatile DATATYPE *ofm2,

  volatile DATATYPE *ofm3,

  volatile DATATYPE *ofm4,

  volatile DATATYPE *ofm5,

  volatile DATATYPE *ofm6,

  volatile DATATYPE *ofm7,

  DATATYPE_IF ofm[4096], int ofm_offset) {

#pragma HLS INTERFACE mode=ap_vld port=ofm0

#pragma HLS INTERFACE mode=ap_vld port=ofm1

#pragma HLS INTERFACE mode=ap_vld port=ofm2

#pragma HLS INTERFACE mode=ap_vld port=ofm3

#pragma HLS INTERFACE mode=ap_vld port=ofm4

#pragma HLS INTERFACE mode=ap_vld port=ofm5

#pragma HLS INTERFACE mode=ap_vld port=ofm6

#pragma HLS INTERFACE mode=ap_vld port=ofm7

#pragma HLS INTERFACE mode=ap_memory port=ofm latency=3

  DATATYPE_IF tmp_if;
  int tmp0, tmp1;
  DATATYPE tmp0_f, tmp1_f;
  for (int i = 0; i < OFM_DIM; i++) {
    for (int j = 0; j < WT_DIM - 1 + OFM_DIM; j++) {
      #pragma HLS PIPELINE II=1
      #pragma HLS DEPENDENCE variable=ofm inter false
      DATATYPE ofm0_val = *ofm0;
      DATATYPE ofm1_val = *ofm1;
      DATATYPE ofm2_val = *ofm2;
      DATATYPE ofm3_val = *ofm3;
      DATATYPE ofm4_val = *ofm4;
      DATATYPE ofm5_val = *ofm5;
      DATATYPE ofm6_val = *ofm6;
      DATATYPE ofm7_val = *ofm7;

      DATATYPE tmp = ofm0_val + ofm1_val + ofm2_val + ofm3_val + ofm4_val + ofm5_val + ofm6_val + ofm7_val + 0;

      if (j < OFM_DIM) {
        int ind = i * OFM_DIM + j;

        if (ind % 2 == 0) {
          tmp_if = ofm[ofm_offset + ind/2];
          tmp0 = tmp_if.range(31, 0);
          tmp1 = tmp_if.range(63, 32);
          tmp0_f = *(reinterpret_cast<DATATYPE*>(&tmp0));
          tmp1_f = *(reinterpret_cast<DATATYPE*>(&tmp1));
        }

        tmp = tmp + ((ind % 2 == 0) ? tmp0_f : tmp1_f);

        if (ind % 2 == 0) {
          tmp0 = *(reinterpret_cast<int*>(&tmp));
          tmp_if.range(31, 0) = tmp0;
        } else {
          tmp1 = *(reinterpret_cast<int*>(&tmp));
          tmp_if.range(63, 32) = tmp1;
        }

        if (ind % 2 == 1 || ind == OFM_DIM * OFM_DIM - 1) {
          ofm[ofm_offset + ind/2] = tmp_if;
        }
      }
    }
  }
}

void cl_maxpool(
  DATATYPE_IF ifm[4096],
  DATATYPE_IF ofm[4096],
  int ifm_offset,
  int ofm_offset
) {
#pragma HLS INTERFACE mode=ap_memory port=ifm latency=3
#pragma HLS INTERFACE mode=ap_memory port=ofm latency=3

  DATATYPE local_max_value [WT_DIM][WT_DIM * IFM_P_DIM];
#pragma HLS ARRAY_PARTITION variable=local_max_value dim=1 complete
#pragma HLS BIND_STORAGE variable=local_max_value type=RAM_S2P impl=lutram

  DATATYPE local_ifm[P_DIM][P_DIM];
#pragma HLS ARRAY_PARTITION variable=local_ifm dim=1 complete
#pragma HLS ARRAY_PARTITION variable=local_ifm dim=2 complete

  DATATYPE_IF tmp_if;
  int tmp0, tmp1;
  DATATYPE tmp0_f, tmp1_f;

  int cur_max_value_w_row[P_DIM];
  int cur_max_value_r_row[P_DIM];
#pragma HLS ARRAY_PARTITION variable=cur_max_value_w_row dim=1 complete
#pragma HLS ARRAY_PARTITION variable=cur_max_value_r_row dim=1 complete
  for (int i = 0; i < P_DIM; i++) {
    #pragma HLS UNROLL
    cur_max_value_w_row[i] = 0;
    cur_max_value_r_row[i] = 0;
  }

  for (int i = 0; i < IFM_P_DIM; i++) {
    for (int j = 0; j < IFM_P_DIM; j++) {
      #pragma HLS PIPELINE II=1
      #pragma HLS DEPENDENCE variable=ofm inter false

      int ind = i * IFM_P_DIM + j;
      int tmp0 = ifm[ifm_offset + ind / 2].range(31, 0);
      int tmp1 = ifm[ifm_offset + ind / 2].range(63, 32);
      DATATYPE ifm_value =
        (ind % 2 == 0) ? *(reinterpret_cast<DATATYPE*>(&tmp0)) :
                         *(reinterpret_cast<DATATYPE*>(&tmp1));

      // load ifm
      for (int m = 0; m < P_DIM; m++) {
        if (i >= m && i <= IFM_P_DIM - (P_DIM - m)) {
          // shift register
          for (int s = 0; s < P_DIM - 1; s++)
            local_ifm[m][s] = local_ifm[m][s + 1];
          local_ifm[m][P_DIM - 1] = ifm_value;

        }
      }

      for (int m = 0; m < P_DIM; m++) {
        if (i >= m && i <= IFM_P_DIM - (P_DIM - m)) {
          // compute
          if (j >= P_DIM - 1) {
            DATATYPE max_value = local_ifm[m][0];
            for (int n = 0; n < P_DIM; n++) {
              if (max_value < local_ifm[m][n])
                max_value = local_ifm[m][n];
            }
            local_max_value[m][cur_max_value_w_row[m] + j - (P_DIM - 1)] = max_value;
            int cur_max_value_w_row_tmp = cur_max_value_w_row[m] + IFM_P_DIM;
            cur_max_value_w_row[m] = (cur_max_value_w_row_tmp == P_DIM * IFM_P_DIM) ? 0 : cur_max_value_w_row_tmp;
          }
        }
      }

      if (i >= P_DIM - 1 && j >= P_DIM - 1) {
        int i1 = i - (P_DIM - 1);
        int j1 = j - (P_DIM - 1);
        int ind1 = i1 * OFM_P_DIM + j1;
        int ind1_h = ind1 / 2;

        DATATYPE max_value = local_max_value[0][cur_max_value_r_row[0] + j1];
        for (int m = 0; m < P_DIM; m++) {
          if (max_value < local_max_value[m][cur_max_value_r_row[m] + j1])
            max_value = local_max_value[m][cur_max_value_r_row[m] + j1];
          int cur_max_value_r_row_tmp = cur_max_value_r_row[m] + IFM_P_DIM;
          cur_max_value_r_row[m] = (cur_max_value_r_row_tmp == P_DIM * IFM_P_DIM) ? 0 : cur_max_value_r_row_tmp;
        }
        if (i1 % 2 == 0 && j1 % 2 == 0) {
          if (ind1_h % 2 == 0) {
            tmp0 = *(reinterpret_cast<int*>(&max_value));
            tmp_if.range(31, 0) = tmp0;
          } else {
            tmp1 = *(reinterpret_cast<int*>(&max_value));
            tmp_if.range(63, 32) = tmp1;
          }

          if (ind1_h % 2 == 1 || ind1_h == OFM_P_DIM * OFM_P_DIM - 1)
            ofm[ofm_offset + ind1_h/2] = tmp_if;
        }
      }
    }
  }

}

