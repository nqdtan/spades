#include <iostream>
#include "conv2d.h"

void conv2d_0(DATATYPE *ifm, DATATYPE *ofm, DATATYPE *wt,
  int HIn, int WIn, int K, int stride, int pad) {
#pragma HLS INTERFACE mode=m_axi port=ifm offset=slave bundle=ifm
#pragma HLS INTERFACE mode=m_axi port=ofm offset=slave bundle=ofm
#pragma HLS INTERFACE mode=m_axi port=wt offset=slave bundle=wt

#pragma HLS INTERFACE s_axilite port=return bundle=control
#pragma HLS INTERFACE s_axilite port=ifm bundle=control
#pragma HLS INTERFACE s_axilite port=ofm bundle=control
#pragma HLS INTERFACE s_axilite port=wt bundle=control
#pragma HLS INTERFACE s_axilite port=HIn bundle=control
#pragma HLS INTERFACE s_axilite port=WIn bundle=control
#pragma HLS INTERFACE s_axilite port=K bundle=control
#pragma HLS INTERFACE s_axilite port=stride bundle=control
#pragma HLS INTERFACE s_axilite port=pad bundle=control

  int HOut = (HIn + 2 * pad - K + 1);
  int WOut = (WIn + 2 * pad - K + 1);

  for (int i = 0; i < HIn + 2 * pad - K + 1; i++) {
    for (int j = 0; j < WIn + 2 * pad - K + 1; j++) {
      int tmp = ofm[i * WOut + j];
      for (int m = 0; m < K; m++) {
        for (int n = 0; n < K; n++) {
          int ii = i + m;
          int jj = j + n;
          int ifm_data = (ii < pad || jj < pad || ii >= HIn + pad || jj >= WIn + pad) ? 0 : ifm[(ii - pad) * WIn + jj - pad];
          int wt_data = wt[m * K + n];
          tmp += ifm_data * wt_data;
        }
      }
      ofm[i * WOut + j] = tmp;
    }
  }
}

#define IFM_DIM 13
#define WT_DIM 3
#define PAD 1
#define OFM_DIM (IFM_DIM + 2 * PAD - WT_DIM + 1)

#define WT_OFFSET 0
#define IFM_OFFSET (((WT_DIM * WT_DIM + 7) / 8) * 8)

void cl_conv2d(
  DATATYPE_IF input_data[1024],
  DATATYPE_IF output_data[1024]) {
#pragma HLS INTERFACE mode=ap_memory port=input_data latency=3
#pragma HLS INTERFACE mode=ap_memory port=output_data latency=3

  DATATYPE local_ifm[WT_DIM][WT_DIM];
#pragma HLS ARRAY_PARTITION variable=local_ifm dim=1 complete
#pragma HLS ARRAY_PARTITION variable=local_ifm dim=2 complete

  DATATYPE local_wt[WT_DIM][WT_DIM];
#pragma HLS ARRAY_PARTITION variable=local_wt dim=1 complete
#pragma HLS ARRAY_PARTITION variable=local_wt dim=2 complete

  // load weight
  for (int m = 0; m < WT_DIM; m++) {
    #pragma HLS UNROLL
    for (int n = 0; n < WT_DIM; n++) {
      #pragma HLS UNROLL
      for (int s = 0; s < WT_DIM - 1; s++) {
        #pragma HLS UNROLL
        local_wt[m][s] = local_wt[m][s + 1];
      }
      //local_wt[m][WT_DIM - 1] = input_data[WT_OFFSET + m * WT_DIM + n];
      int ind = WT_OFFSET + m * WT_DIM + n;
      int tmp0 = input_data[ind/2].range(31, 0);
      int tmp1 = input_data[ind/2].range(63, 32);
      local_wt[m][WT_DIM - 1] = (ind % 2 == 0) ? *(reinterpret_cast<float*>(&tmp0)) :
                                                 *(reinterpret_cast<float*>(&tmp1));
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
      #pragma HLS DEPENDENCE variable=output_data inter false

      //DATATYPE ifm_value = (i < PAD || j < PAD || i >= IFM_DIM + PAD || j >= IFM_DIM + PAD) ? 0 : input_data[IFM_OFFSET + (i - PAD) * IFM_DIM + j - PAD];

      int ind = IFM_OFFSET + (i - PAD) * IFM_DIM + j - PAD;
      int tmp0 = input_data[ind / 2].range(31, 0);
      int tmp1 = input_data[ind / 2].range(63, 32);
      DATATYPE ifm_value = (i < PAD || j < PAD || i >= IFM_DIM + PAD || j >= IFM_DIM + PAD) ? 0 :
        (ind % 2 == 0) ? *(reinterpret_cast<float*>(&tmp0)) :
                         *(reinterpret_cast<float*>(&tmp1));

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
        if (ind1 % 2 == 0) {
          tmp_if = output_data[ind1/2];
          tmp0 = tmp_if.range(31, 0);
          tmp1 = tmp_if.range(63, 32);
          tmp0_f = *(reinterpret_cast<float*>(&tmp0));
          tmp1_f = *(reinterpret_cast<float*>(&tmp1));
        }

        DATATYPE tmp = (ind1 % 2 == 0) ? tmp0_f : tmp1_f;
        for (int m = 0; m < WT_DIM; m++) {
          tmp += local_psum[m][cur_psum_r_row[m] + j1];
          int cur_psum_r_row_tmp = cur_psum_r_row[m] + OFM_DIM;
          cur_psum_r_row[m] = (cur_psum_r_row_tmp == WT_DIM * OFM_DIM) ? 0 : cur_psum_r_row_tmp;
        }
        if (ind1 % 2 == 0) {
          tmp0 = *(reinterpret_cast<int*>(&tmp));
          tmp_if.range(31, 0) = tmp0;
        } else {
          tmp1 = *(reinterpret_cast<int*>(&tmp));
          tmp_if.range(63, 32) = tmp1;
        }

        if (ind1 % 2 == 1 || ind1 == OFM_DIM * OFM_DIM - 1)
          output_data[ind1/2] = tmp_if;

      }
    }
  }

}

//void conv2d(DATATYPE *ifm, DATATYPE *ofm, DATATYPE *wt,
//  int HIn, int WIn, int K, int stride, int pad) {
//
//  DATATYPE input_data_buffer[WT_DIM * WT_DIM + IFM_DIM * IFM_DIM];
//  DATATYPE output_data_buffer[OFM_DIM * OFM_DIM];
//
//  for (int i = 0; i < WT_DIM * WT_DIM; i++) {
//    input_data_buffer[WT_OFFSET + i] = wt[i];
//  }
//  for (int i = 0; i < IFM_DIM * IFM_DIM; i++) {
//    input_data_buffer[IFM_OFFSET + i] = ifm[i];
//  }
//
//  for (int i = 0; i < OFM_DIM * OFM_DIM; i++) {
//    output_data_buffer[i] = ofm[i];
//  }
//
//  cl_conv2d(input_data_buffer, output_data_buffer);
//
//  for (int i = 0; i < OFM_DIM * OFM_DIM; i++) {
//    ofm[i] = output_data_buffer[i];
//  }
//}
