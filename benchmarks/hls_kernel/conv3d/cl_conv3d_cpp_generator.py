import sys

def main(argv):
  num_banks = int(argv[0])
#  ifm_dim = int(argv[1])
#  wt_dim = int(argv[2])
#  stride = int(argv[3])
#  pad = int(argv[4])

  ifm_dim = 13
  wt_dim = 3
  stride = 1
  pad = 1

  code = ""

  code += """
#include <ap_int.h>
typedef ap_int<64> DATATYPE_IF;
#include "conv3d.h"

#define IFM_DIM {1}
#define WT_DIM {2}
#define STRIDE {3}
#define PAD {4}
#define OFM_DIM (((IFM_DIM + 2 * PAD - WT_DIM) / STRIDE) + 1)
#define PSUM_LEN (IFM_DIM + 2 * PAD - (WT_DIM - 1))

#define NUM_CONV2D {0}

#define IFM_P_DIM (OFM_DIM)
#define P_DIM 3
#define OFM_P_DIM (IFM_P_DIM / 2)

""".format(num_banks, ifm_dim, wt_dim, stride, pad)

  code += """
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
//#pragma HLS INTERFACE mode=ap_memory port=ofm latency=3 storage_type=ram_1p

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
  DATATYPE local_psum [WT_DIM][WT_DIM * PSUM_LEN];
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
            local_psum[m][cur_psum_w_row[m] + j - (WT_DIM - 1)] = tmp;
            int cur_psum_w_row_tmp = (j - (WT_DIM - 1) == PSUM_LEN - 1) ? (cur_psum_w_row[m] + PSUM_LEN) : (cur_psum_w_row[m]);
            cur_psum_w_row[m] = (cur_psum_w_row_tmp == WT_DIM * PSUM_LEN) ? 0 : cur_psum_w_row_tmp;
          }
        }
      }

      int i1 = i - (WT_DIM - 1);
      int j1 = j - (WT_DIM - 1);
      if (i >= WT_DIM - 1 && j >= WT_DIM - 1) {
        int ind1 = i1 * OFM_DIM + j1;
        DATATYPE tmp = 0;
        for (int m = 0; m < WT_DIM; m++) {
          tmp += local_psum[m][cur_psum_r_row[m] + j1];
          int cur_psum_r_row_tmp = (j1 == PSUM_LEN - 1) ? (cur_psum_r_row[m] + PSUM_LEN) : (cur_psum_r_row[m]);
          cur_psum_r_row[m] = (cur_psum_r_row_tmp == WT_DIM * PSUM_LEN) ? 0 : cur_psum_r_row_tmp;
        }
        ofm[ind1] = tmp;
      } else {
        ofm[0] = 1; // garbage data
      }
    }
  }

}
"""

  code += """
void cl_conv3d(
"""

  for i in range(num_banks):
    code += """
  DATATYPE_IF ifm{0}[4096],
""".format(i)

  for i in range(num_banks):
    code += """
  DATATYPE_IF wt{0}[4096],
""".format(i)

  code += """
  DATATYPE_IF ofm[4096],
  int len, int wt_offset, int ifm_offset, int ofm_offset, int state
) {
"""

  for i in range(num_banks):
    code += """
#pragma HLS INTERFACE mode=ap_memory port=ifm{0} latency=3
""".format(i)

  for i in range(num_banks):
    code += """
#pragma HLS INTERFACE mode=ap_memory port=wt{0} latency=3 storage_type=ram_1p
""".format(i)

  code += """
#pragma HLS INTERFACE mode=ap_memory port=ofm latency=3
"""

  for i in range(num_banks):
    code += """
  DATATYPE ofm{0}[OFM_DIM * OFM_DIM];
""".format(i)

  for i in range(num_banks):
    code += """
  cl_conv2d(ifm{0}, wt{0}, ofm{0}, wt_offset, ifm_offset, len >= {1});
""".format(i, i + 1)

  code += """

  DATATYPE_IF tmp_if;
  int tmp0, tmp1;
  DATATYPE tmp0_f, tmp1_f;
  for (int i = 0; i < OFM_DIM; i++) {
    for (int j = 0; j < WT_DIM - 1 + OFM_DIM; j++) {
      #pragma HLS PIPELINE II=1
      #pragma HLS DEPENDENCE variable=ofm inter false
      int ind = i * OFM_DIM + j;
"""
  for i in range(num_banks):
    code += "      DATATYPE ofm{0}_val = (len >= {1}) ? ofm{0}[ind] : 0;\n".format(i, i + 1)

  code += """
      DATATYPE tmp = """

  for i in range(num_banks):
    code += "ofm{0}_val + ".format(i)

  code += "0;\n"

  code += """
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
"""

  code += """
void cl_conv3d_base(
"""

  for i in range(num_banks):
    code += """
  DATATYPE_IF ifm{0}[4096],
""".format(i)

  for i in range(num_banks):
    code += """
  DATATYPE_IF wt{0}[4096],
""".format(i)

  for i in range(num_banks):
    code += """
  DATATYPE    ofm{0}[4096],
""".format(i)

  code += """
  int len, int wt_offset, int ifm_offset
) {
"""

  for i in range(num_banks):
    code += """
#pragma HLS INTERFACE mode=ap_memory port=ifm{0} latency=3
""".format(i)

  for i in range(num_banks):
    code += """
#pragma HLS INTERFACE mode=ap_memory port=wt{0} latency=3 storage_type=ram_1p
""".format(i)

  for i in range(num_banks):
    code += """
#pragma HLS INTERFACE mode=ap_memory port=ofm{0} latency=3 storage_type=ram_1p
""".format(i)

  for i in range(num_banks):
    code += """
  cl_conv2d(ifm{0}, wt{0}, ofm{0}, wt_offset, ifm_offset, len >= {1});
""".format(i, i + 1)

  code += """
}

void cl_conv3d_acc(
"""
  for i in range(num_banks):
    code += """
  volatile DATATYPE *ofm{0},
""".format(i)

  code += """
  DATATYPE_IF ofm[4096], int ofm_offset) {
"""

  for i in range(num_banks):
    code += """
#pragma HLS INTERFACE mode=ap_vld port=ofm{0}
""".format(i)

  code += """
#pragma HLS INTERFACE mode=ap_memory port=ofm latency=3

  DATATYPE_IF tmp_if;
  int tmp0, tmp1;
  DATATYPE tmp0_f, tmp1_f;
  for (int i = 0; i < IFM_DIM + 2 * PAD; i++) {
    for (int j = 0; j < IFM_DIM + 2 * PAD; j++) {
      #pragma HLS PIPELINE II=1
      #pragma HLS DEPENDENCE variable=ofm inter false
"""

  for i in range(num_banks):
    code += "      DATATYPE ofm{0}_val = *ofm{0};\n".format(i, i + 1)

  code += """
      DATATYPE tmp = """

  for i in range(num_banks):
    code += "ofm{0}_val + ".format(i)

  code += "0;\n"

  code += """
      int i1 = i - (WT_DIM - 1);
      int j1 = j - (WT_DIM - 1);
      if ((i1 >= 0) && (j1 >= 0) && (j % STRIDE == 0) && (i % STRIDE == 0)) {
        int ind = (i1 / STRIDE) * OFM_DIM + (j1 / STRIDE);

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
"""

  code += """
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
"""

  print(code)

if __name__ == '__main__':
    main(sys.argv[1:])
