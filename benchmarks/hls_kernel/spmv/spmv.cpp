#include "spmv.h"
#include "hls_stream.h"
#include <iostream>
#define SIZE 8192
#define X_LEN 4096
#define Y_LEN 256

DATATYPE compute(DATATYPE local_ind[Y_LEN][(4+SIZE)/4],
                 DATATYPE local_val[Y_LEN][(4+SIZE)/4],
                 DATATYPE local_x[X_LEN],
                 int i, int k0, int n,
                 int j0, int offset, int len, int start, int end, int k[1]) {
#pragma HLS INLINE OFF
  DATATYPE tmp0 = 0;
  DATATYPE tmp1 = 0;
  
  for (int j = j0; j < len; j+=8) {
    #pragma HLS PIPELINE
    int jj0 = (offset + j) / 4;
    if (local_ind[k0][jj0] >= i &&
        local_ind[k0][jj0] < i + X_LEN &&
        local_ind[k0][jj0] < n &&
        start - len + j < end) {
      tmp0 += local_val[k0][jj0] * local_x[local_ind[k0][jj0] - i];
      k[0] = j + 1;
    }
    int jj1 = (offset + j + 4) / 4;
    if (local_ind[k0][jj1] >= i &&
        local_ind[k0][jj1] < i + X_LEN &&
        local_ind[k0][jj1] < n &&
        start - len + (j + 4) < end &&
        j + 4 < len) {
      tmp1 += local_val[k0][jj1] * local_x[local_ind[k0][jj1] - i];
      k[0] = j + 4 + 1;
    }
  }
  return tmp0 + tmp1;
}

void task00_ss_cfg_setup(hls::stream<ap_int<32>> &cfg0,
                         int starts[Y_LEN], int k,
                         int len, int val_offset) {
#pragma HLS INLINE OFF
  // copy val
  int offset_tmp;
  int len_tmp;
  int f;

  f = 0;
  len_tmp = (len + 4 + 8 - 1) / 8;
  if ((val_offset + starts[k]) % 8 >= 4) {
    f = 1;
  }
  offset_tmp = (val_offset + starts[k]) / 8;
  //cfg0.write((val_offset + start) << 3); // m0_offset_lo
  cfg0.write((offset_tmp * 8) << 3); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(0); // seg_stride
  cfg0.write(1); // seg_count
  //cfg0.write((len + 8) / 8); // len
  cfg0.write(len_tmp);
  cfg0.write(1); // mode
}

void task00(hls::stream<ap_int<256>> &ss0_in,
            DATATYPE local_val0[Y_LEN][(4+SIZE)/4],
            DATATYPE local_val1[Y_LEN][(4+SIZE)/4],
            DATATYPE local_val2[Y_LEN][(4+SIZE)/4],
            DATATYPE local_val3[Y_LEN][(4+SIZE)/4],
            int starts[Y_LEN], int k,
            int len, int val_offset) {
#pragma HLS INLINE OFF
  // copy val
  int offset_tmp;
  int len_tmp;
  int f;

  f = 0;
  len_tmp = (len + 4 + 8 - 1) / 8;
  if ((val_offset + starts[k]) % 8 >= 4) {
    f = 1;
  }
//  offset_tmp = (val_offset + start) / 8;
//  //cfg0.write((val_offset + start) << 3); // m0_offset_lo
//  cfg0.write((offset_tmp * 8) << 3); // m0_offset_lo
//  cfg0.write(0); // m0_offset_hi
//  cfg0.write(0); // seg_stride
//  cfg0.write(1); // seg_count
//  //cfg0.write((len + 8) / 8); // len
//  cfg0.write(len_tmp);
//  cfg0.write(1); // mode
  while (ss0_in.empty());
  for (int j = 0; j < len_tmp * 2; j++) {
    #pragma HLS PIPELINE
    //DATATYPE_IF tmp = m0[(val_offset + start) / 4 + j];
    DATATYPE_IF tmp = ss0_in.read();
    if ((f == 0 && j < len_tmp * 2 - 1) ||
        (f == 1 && j > 0)) {
    local_val0[k][j - f] = tmp.range(64*1-1, 64*0);
    local_val1[k][j - f] = tmp.range(64*2-1, 64*1);
    local_val2[k][j - f] = tmp.range(64*3-1, 64*2);
    local_val3[k][j - f] = tmp.range(64*4-1, 64*3);
    }
  }

}

void task01_ss_cfg_setup(hls::stream<ap_int<32>> &cfg0,
                         int starts[Y_LEN], int k,
                         int len, int ind_offset) {
#pragma HLS INLINE OFF
  // copy ind
  int offset_tmp;
  int len_tmp;
  int f;

  f = 0;
  len_tmp = (len + 4 + 8 - 1) / 8;
  if ((ind_offset + starts[k]) % 8 >= 4) {
    f = 1;
  }

  offset_tmp = (ind_offset + starts[k]) / 8;
  //cfg0.write((ind_offset + start) << 3); // m0_offset_lo
  cfg0.write((offset_tmp * 8) << 3); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(0); // seg_stride
  cfg0.write(1); // seg_count
  cfg0.write(len_tmp); // len
  cfg0.write(1); // mode
}

void task01(hls::stream<ap_int<256>> &ss0_in,
            DATATYPE local_ind0[Y_LEN][(4+SIZE)/4],
            DATATYPE local_ind1[Y_LEN][(4+SIZE)/4],
            DATATYPE local_ind2[Y_LEN][(4+SIZE)/4],
            DATATYPE local_ind3[Y_LEN][(4+SIZE)/4],
            int starts[Y_LEN], int k,
            int len, int ind_offset) {
#pragma HLS INLINE OFF
  // copy ind
  int offset_tmp;
  int len_tmp;
  int f;

  f = 0;
  len_tmp = (len + 4 + 8 - 1) / 8;
  if ((ind_offset + starts[k]) % 8 >= 4) {
    f = 1;
  }

//  offset_tmp = (ind_offset + start) / 8;
//  //cfg0.write((ind_offset + start) << 3); // m0_offset_lo
//  cfg0.write((offset_tmp * 8) << 3); // m0_offset_lo
//  cfg0.write(0); // m0_offset_hi
//  cfg0.write(0); // seg_stride
//  cfg0.write(1); // seg_count
//  cfg0.write(len_tmp); // len
//  cfg0.write(1); // mode
  while (ss0_in.empty());
  for (int j = 0; j < len_tmp * 2; j++) {
    #pragma HLS PIPELINE
    //DATATYPE_IF tmp = m0[(ind_offset + start) / 4 + j];
    DATATYPE_IF tmp = ss0_in.read();
    if ((f == 0 && j < len_tmp * 2 - 1) ||
        (f == 1 && j > 0)) {
    local_ind0[k][j - f] = tmp.range(64*1-1, 64*0);
    local_ind1[k][j - f] = tmp.range(64*2-1, 64*1);
    local_ind2[k][j - f] = tmp.range(64*3-1, 64*2);
    local_ind3[k][j - f] = tmp.range(64*4-1, 64*3);
    }
  }
}

void task1(hls::stream<ap_int<256>> &ss0_in,
           hls::stream<ap_int<32>>  &cfg0,
           DATATYPE local_x0[X_LEN],
           DATATYPE local_x1[X_LEN],
           DATATYPE local_x2[X_LEN],
           DATATYPE local_x3[X_LEN],
           int x_offset, int i) {
  // copy x
  cfg0.write((x_offset + i) << 3); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(0); // seg_stride
  cfg0.write(1); // seg_count
  cfg0.write(X_LEN / 8); // len
  cfg0.write(1); // mode
  while (ss0_in.empty());
  for (int j = 0; j < X_LEN / 4; j++) {
    #pragma HLS PIPELINE
    //DATATYPE_IF tmp = m0[(x_offset + i) / 4 + j];
    DATATYPE_IF tmp = ss0_in.read();
    local_x0[4 * j + 0] = tmp.range(64*1-1, 64*0);
    local_x0[4 * j + 1] = tmp.range(64*2-1, 64*1);
    local_x0[4 * j + 2] = tmp.range(64*3-1, 64*2);
    local_x0[4 * j + 3] = tmp.range(64*4-1, 64*3);

    local_x1[4 * j + 0] = tmp.range(64*1-1, 64*0);
    local_x1[4 * j + 1] = tmp.range(64*2-1, 64*1);
    local_x1[4 * j + 2] = tmp.range(64*3-1, 64*2);
    local_x1[4 * j + 3] = tmp.range(64*4-1, 64*3);

    local_x2[4 * j + 0] = tmp.range(64*1-1, 64*0);
    local_x2[4 * j + 1] = tmp.range(64*2-1, 64*1);
    local_x2[4 * j + 2] = tmp.range(64*3-1, 64*2);
    local_x2[4 * j + 3] = tmp.range(64*4-1, 64*3);

    local_x3[4 * j + 0] = tmp.range(64*1-1, 64*0);
    local_x3[4 * j + 1] = tmp.range(64*2-1, 64*1);
    local_x3[4 * j + 2] = tmp.range(64*3-1, 64*2);
    local_x3[4 * j + 3] = tmp.range(64*4-1, 64*3);
  }
}

void spmv_axi_sub(hls::stream<ap_int<256>> &ss0_in,
                  hls::stream<ap_int<256>> &ss0_out,
                  hls::stream<ap_int<32>>  &cfg0,
                  int n, int row_begin, int row_end) {

#pragma HLS INTERFACE s_axilite port=return bundle=control
#pragma HLS INTERFACE s_axilite port=n bundle=control
#pragma HLS INTERFACE s_axilite port=row_begin bundle=control
#pragma HLS INTERFACE s_axilite port=row_end bundle=control

  int val_offset = 0;
  int ind_offset = n * n;
  int ptr_offset = (n * n) + (n * n);
  int x_offset   = (n * n) + (n * n) + (n + 8);
  int y_offset   = (n * n) + (n * n) + (n + 8) + n;

  DATATYPE local_val0[Y_LEN][(4+SIZE)/4];
  DATATYPE local_val1[Y_LEN][(4+SIZE)/4];
  DATATYPE local_val2[Y_LEN][(4+SIZE)/4];
  DATATYPE local_val3[Y_LEN][(4+SIZE)/4];

  DATATYPE local_ind0[Y_LEN][(4+SIZE)/4];
  DATATYPE local_ind1[Y_LEN][(4+SIZE)/4];
  DATATYPE local_ind2[Y_LEN][(4+SIZE)/4];
  DATATYPE local_ind3[Y_LEN][(4+SIZE)/4];

  DATATYPE local_x0[X_LEN];
  DATATYPE local_x1[X_LEN];
  DATATYPE local_x2[X_LEN];
  DATATYPE local_x3[X_LEN];

  DATATYPE local_y[Y_LEN];
  DATATYPE local_ptr[Y_LEN+4];

#pragma HLS bind_storage variable=local_val0 type=ram_2p impl=uram latency=3
#pragma HLS bind_storage variable=local_val1 type=ram_2p impl=uram latency=3
#pragma HLS bind_storage variable=local_val2 type=ram_2p impl=uram latency=3
#pragma HLS bind_storage variable=local_val3 type=ram_2p impl=uram latency=3
#pragma HLS bind_storage variable=local_ind0 type=ram_2p impl=uram latency=3
#pragma HLS bind_storage variable=local_ind1 type=ram_2p impl=uram latency=3
#pragma HLS bind_storage variable=local_ind2 type=ram_2p impl=uram latency=3
#pragma HLS bind_storage variable=local_ind3 type=ram_2p impl=uram latency=3

#pragma HLS bind_storage variable=local_y type=ram_2p impl=lutram latency=3
#pragma HLS bind_storage variable=local_y type=ram_2p impl=lutram latency=3

  int starts[Y_LEN];
  int ends[Y_LEN];
  int last_k1[Y_LEN];

  // copy y
  cfg0.write((y_offset + row_begin) << 3); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(0); // seg_stride
  cfg0.write(1); // seg_count
  cfg0.write((row_end - row_begin) / 8); // len
  cfg0.write(1); // mode
  while (ss0_in.empty());
  for (int i = 0; i < (row_end - row_begin) / 4; i++) {
    #pragma HLS PIPELINE
    //DATATYPE_IF tmp = m0[(y_offset + row_begin) / 4 + i];
    DATATYPE_IF tmp = ss0_in.read();
    local_y[4 * i + 0] = tmp.range(64*1-1, 64*0);
    local_y[4 * i + 1] = tmp.range(64*2-1, 64*1);
    local_y[4 * i + 2] = tmp.range(64*3-1, 64*2);
    local_y[4 * i + 3] = tmp.range(64*4-1, 64*3);
  }

  // copy ptr
  cfg0.write((ptr_offset + row_begin) << 3); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(0); // seg_stride
  cfg0.write(1); // seg_count
  cfg0.write((row_end - row_begin + 8) / 8); // len
  cfg0.write(1); // mode
  while (ss0_in.empty());
  for (int i = 0; i < (row_end - row_begin + 8) / 4; i++) {
    #pragma HLS PIPELINE
    //DATATYPE_IF tmp = m0[(ptr_offset + row_begin) / 4 + i];
    DATATYPE_IF tmp = ss0_in.read();
    if (i < (row_end - row_begin + 8) / 4 - 1) {
    local_ptr[4 * i + 0] = tmp.range(64*1-1, 64*0);
    local_ptr[4 * i + 1] = tmp.range(64*2-1, 64*1);
    local_ptr[4 * i + 2] = tmp.range(64*3-1, 64*2);
    local_ptr[4 * i + 3] = tmp.range(64*4-1, 64*3);
    }
  }

  for (int i = 0; i < (row_end - row_begin); i++) {
    last_k1[i] = SIZE;
    starts[i]  = local_ptr[i];
    ends[i]    = local_ptr[i + 1];
  }

  for (int i = 0; i < n; i+=X_LEN) {
    task1(ss0_in, cfg0, local_x0, local_x1, local_x2, local_x3, x_offset, i);
    for (int k = 0; k < (row_end - row_begin); k++) {
      int start = local_ptr[k];
      int end   = local_ptr[k + 1];
      int tmp_s = start / 4;
      int tmp_e = (end + 4 - 1) / 4;
      int start_aligned = tmp_s * 4;
      int end_aligned   = tmp_e * 4;
      int segment = end_aligned - start_aligned;
      //int len = SIZE;
      int len = (segment > SIZE) ? SIZE : segment;
      bool run = true;
      while (run) {
        int offset = starts[k] % 4;
        if (last_k1[k] == SIZE) {
          task00_ss_cfg_setup(cfg0, starts, k, len, val_offset);
          task01_ss_cfg_setup(cfg0, starts, k, len, ind_offset);
          task00(ss0_in, local_val0, local_val1, local_val2, local_val3,
                 starts, k, len, val_offset);
          task01(ss0_in, local_ind0, local_ind1, local_ind2, local_ind3,
                 starts, k, len, ind_offset);

          starts[k] += len;
        }
        int k10[1] = {-1};
        int k11[1] = {-1};
        int k12[1] = {-1};
        int k13[1] = {-1};

        int j00, j01, j02, j03;
        if (offset % 4 == 0) {
          j00 = 0;
          j01 = 1;
          j02 = 2;
          j03 = 3;
        } else if (offset % 4 == 1) {
          j00 = 3;
          j01 = 0;
          j02 = 1;
          j03 = 2;
        } else if (offset % 4 == 2) {
          j00 = 2;
          j01 = 3;
          j02 = 0;
          j03 = 1;
        } else if (offset % 4 == 3) {
          j00 = 1;
          j01 = 2;
          j02 = 3;
          j03 = 0;
        }

        DATATYPE tmp0 = compute(local_ind0, local_val0, local_x0, i, k, n, j00, offset, len, starts[k], ends[k], k10);
        DATATYPE tmp1 = compute(local_ind1, local_val1, local_x1, i, k, n, j01, offset, len, starts[k], ends[k], k11);
        DATATYPE tmp2 = compute(local_ind2, local_val2, local_x2, i, k, n, j02, offset, len, starts[k], ends[k], k12);
        DATATYPE tmp3 = compute(local_ind3, local_val3, local_x3, i, k, n, j03, offset, len, starts[k], ends[k], k13);

        local_y[k] += tmp0 + tmp1 + tmp2 + tmp3;
        int k_tmp01 = (k10[0] < k11[0]) ? k11[0] : k10[0];
        int k_tmp23 = (k12[0] < k13[0]) ? k13[0] : k12[0];
        last_k1[k] = (k_tmp01 < k_tmp23) ? k_tmp23 : k_tmp01;
        if (last_k1[k] != SIZE)
          run = false;
      }
    }
  }


  cfg0.write((y_offset + row_begin) << 3); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(0); // seg_stride
  cfg0.write(1); // seg_count
  cfg0.write((row_end - row_begin) / 8); // len
  cfg0.write(2); // mode
  while (ss0_out.full());
  for (int i = 0; i < (row_end - row_begin) / 4; i++) {
    #pragma HLS PIPELINE
    DATATYPE_IF tmp;
    tmp.range(64*1-1, 64*0) = local_y[4 * i + 0];
    tmp.range(64*2-1, 64*1) = local_y[4 * i + 1];
    tmp.range(64*3-1, 64*2) = local_y[4 * i + 2];
    tmp.range(64*4-1, 64*3) = local_y[4 * i + 3];

    //m0[(y_offset + row_begin) / 4 + i] = tmp;
    ss0_out.write(tmp);
  }
}

void spmv_axi_sub1(hls::stream<ap_int<256>> &ss0_in,
                  hls::stream<ap_int<256>> &ss0_out,
                  hls::stream<ap_int<32>>  &cfg0,
                  int n, int row_begin, int row_end) {

#pragma HLS INTERFACE s_axilite port=return bundle=control
#pragma HLS INTERFACE s_axilite port=n bundle=control
#pragma HLS INTERFACE s_axilite port=row_begin bundle=control
#pragma HLS INTERFACE s_axilite port=row_end bundle=control

  int val_offset = 0;
  int ind_offset = n * n;
  int ptr_offset = (n * n) + (n * n);
  int x_offset   = (n * n) + (n * n) + (n + 8);
  int y_offset   = (n * n) + (n * n) + (n + 8) + n;

  DATATYPE local_val0[(SIZE + 8)/4];
  DATATYPE local_val1[(SIZE + 8)/4];
  DATATYPE local_val2[(SIZE + 8)/4];
  DATATYPE local_val3[(SIZE + 8)/4];

  DATATYPE local_ind0[(SIZE + 8)/4];
  DATATYPE local_ind1[(SIZE + 8)/4];
  DATATYPE local_ind2[(SIZE + 8)/4];
  DATATYPE local_ind3[(SIZE + 8)/4];

//  DATATYPE local_x0[SIZE];
//  DATATYPE local_x1[SIZE];
//  DATATYPE local_x2[SIZE];
//  DATATYPE local_x3[SIZE];

  DATATYPE local_x0[SIZE/4];
  DATATYPE local_x1[SIZE/4];
  DATATYPE local_x2[SIZE/4];
  DATATYPE local_x3[SIZE/4];

  DATATYPE local_y[Y_LEN];
  DATATYPE local_ptr[Y_LEN+4];

//#pragma HLS bind_storage variable=local_val0 type=ram_2p impl=uram latency=3
//#pragma HLS bind_storage variable=local_val1 type=ram_2p impl=uram latency=3
//#pragma HLS bind_storage variable=local_val2 type=ram_2p impl=uram latency=3
//#pragma HLS bind_storage variable=local_val3 type=ram_2p impl=uram latency=3
//#pragma HLS bind_storage variable=local_ind0 type=ram_2p impl=uram latency=3
//#pragma HLS bind_storage variable=local_ind1 type=ram_2p impl=uram latency=3
//#pragma HLS bind_storage variable=local_ind2 type=ram_2p impl=uram latency=3
//#pragma HLS bind_storage variable=local_ind3 type=ram_2p impl=uram latency=3
//
//#pragma HLS bind_storage variable=local_y type=ram_2p impl=lutram latency=3
//#pragma HLS bind_storage variable=local_y type=ram_2p impl=lutram latency=3

  // copy y
  cfg0.write((y_offset + row_begin) << 3); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(0); // seg_stride
  cfg0.write(1); // seg_count
  cfg0.write((row_end - row_begin) / 8); // len
  cfg0.write(1); // mode
  while (ss0_in.empty());
  for (int i = 0; i < (row_end - row_begin) / 4; i++) {
    #pragma HLS PIPELINE
    //DATATYPE_IF tmp = m0[(y_offset + row_begin) / 4 + i];
    DATATYPE_IF tmp = ss0_in.read();
    local_y[4 * i + 0] = tmp.range(64*1-1, 64*0);
    local_y[4 * i + 1] = tmp.range(64*2-1, 64*1);
    local_y[4 * i + 2] = tmp.range(64*3-1, 64*2);
    local_y[4 * i + 3] = tmp.range(64*4-1, 64*3);
  }

  // copy ptr
  cfg0.write((ptr_offset + row_begin) << 3); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(0); // seg_stride
  cfg0.write(1); // seg_count
  cfg0.write((row_end - row_begin + 8) / 8); // len
  cfg0.write(1); // mode
  while (ss0_in.empty());
  for (int i = 0; i < (row_end - row_begin + 8) / 4; i++) {
    #pragma HLS PIPELINE
    //DATATYPE_IF tmp = m0[(ptr_offset + row_begin) / 4 + i];
    DATATYPE_IF tmp = ss0_in.read();
    if (i < (row_end - row_begin + 8) / 4 - 1) {
    local_ptr[4 * i + 0] = tmp.range(64*1-1, 64*0);
    local_ptr[4 * i + 1] = tmp.range(64*2-1, 64*1);
    local_ptr[4 * i + 2] = tmp.range(64*3-1, 64*2);
    local_ptr[4 * i + 3] = tmp.range(64*4-1, 64*3);
    }
  }

  int k0 = 0;
  int k1;

  while (k0 < (row_end - row_begin)) {
    k1 = row_end - row_begin;
    for (int k = k0 + 1; k < (row_end - row_begin); k++) {
      if (local_ptr[k] >= (local_ptr[k0] + SIZE)) {
        k1 = k;
        break;
      }
    }

    int maxlen = local_ptr[k1] - local_ptr[k0];
    int start = local_ptr[k0];
    for (int s = 0; s < maxlen; s += SIZE) {
      // remaining segment
      if (s != 0)
        k0 = k1 - 1;
      int len1 = (s + SIZE) > maxlen ? (maxlen - s) : SIZE;
      int len1_tmp = (len1 + 15) / 8;
      if (start % 8 == 0)
        len1_tmp = (len1 + 7) / 8;
      int offset_tmp = (val_offset + start + s) / 8;
      cfg0.write((offset_tmp * 8) << 3); // m0_offset_lo
      cfg0.write(0); // m0_offset_hi
      cfg0.write(0); // seg_stride
      cfg0.write(1); // seg_count
      cfg0.write(len1_tmp); // len
      cfg0.write(1); // mode
      while (ss0_in.empty());
      for (int j = 0; j < len1_tmp * 2; j++) {
        #pragma HLS PIPELINE
        DATATYPE_IF tmp = ss0_in.read();
        local_val0[j] = tmp.range(64*1-1, 64*0);
        local_val1[j] = tmp.range(64*2-1, 64*1);
        local_val2[j] = tmp.range(64*3-1, 64*2);
        local_val3[j] = tmp.range(64*4-1, 64*3);
      }

      offset_tmp = (ind_offset + start + s) / 8;
      cfg0.write((offset_tmp * 8) << 3); // m0_offset_lo
      cfg0.write(0); // m0_offset_hi
      cfg0.write(0); // seg_stride
      cfg0.write(1); // seg_count
      cfg0.write(len1_tmp); // len
      cfg0.write(1); // mode
      while (ss0_in.empty());
      for (int j = 0; j < len1_tmp * 2; j++) {
        #pragma HLS PIPELINE
        DATATYPE_IF tmp = ss0_in.read();
        local_ind0[j] = tmp.range(64*1-1, 64*0);
        local_ind1[j] = tmp.range(64*2-1, 64*1);
        local_ind2[j] = tmp.range(64*3-1, 64*2);
        local_ind3[j] = tmp.range(64*4-1, 64*3);
      }

      for (int i = 0; i < n; i += SIZE) {
        // copy x
        cfg0.write((x_offset + i) << 3); // m0_offset_lo
        cfg0.write(0); // m0_offset_hi
        cfg0.write(0); // seg_stride
        cfg0.write(1); // seg_count
        cfg0.write(SIZE / 8); // len
        cfg0.write(1); // mode
        while (ss0_in.empty());
        for (int j = 0; j < SIZE / 4; j++) {
          #pragma HLS PIPELINE
          DATATYPE_IF tmp = ss0_in.read();
          local_x0[j] = tmp.range(64*1-1, 64*0);
          local_x1[j] = tmp.range(64*2-1, 64*1);
          local_x2[j] = tmp.range(64*3-1, 64*2);
          local_x3[j] = tmp.range(64*4-1, 64*3);

//          local_x0[4 * j + 0] = tmp.range(64*1-1, 64*0);
//          local_x0[4 * j + 1] = tmp.range(64*2-1, 64*1);
//          local_x0[4 * j + 2] = tmp.range(64*3-1, 64*2);
//          local_x0[4 * j + 3] = tmp.range(64*4-1, 64*3);
//
//          local_x1[4 * j + 0] = tmp.range(64*1-1, 64*0);
//          local_x1[4 * j + 1] = tmp.range(64*2-1, 64*1);
//          local_x1[4 * j + 2] = tmp.range(64*3-1, 64*2);
//          local_x1[4 * j + 3] = tmp.range(64*4-1, 64*3);
//
//          local_x2[4 * j + 0] = tmp.range(64*1-1, 64*0);
//          local_x2[4 * j + 1] = tmp.range(64*2-1, 64*1);
//          local_x2[4 * j + 2] = tmp.range(64*3-1, 64*2);
//          local_x2[4 * j + 3] = tmp.range(64*4-1, 64*3);
//
//          local_x3[4 * j + 0] = tmp.range(64*1-1, 64*0);
//          local_x3[4 * j + 1] = tmp.range(64*2-1, 64*1);
//          local_x3[4 * j + 2] = tmp.range(64*3-1, 64*2);
//          local_x3[4 * j + 3] = tmp.range(64*4-1, 64*3);
        }

        int offset0 = start % 8;
        int offset = 0;
        for (int r = k0; r < k1; r++) {
          DATATYPE tmp0 = 0;
          DATATYPE tmp1 = 0;
          DATATYPE tmp2 = 0;
          DATATYPE tmp3 = 0;
          int p_range = local_ptr[r + 1] - local_ptr[r];
          if (r == k1 - 1)
            p_range = len1 - offset;
          int z = (offset + offset0) % 4;
          int p0, p1, p2, p3;
          int t0, t1, t2, t3;
          if (z == 0) {
            p0 = 0; p1 = 1; p2 = 2; p3 = 3;
            t0 = 0; t1 = 0; t2 = 0; t3 = 0;
          } else if (z == 1) {
            p0 = 3; p1 = 0; p2 = 1; p3 = 2;
            t0 = 1; t1 = 0; t2 = 0; t3 = 0;
          } else if (z == 2) {
            p0 = 2; p1 = 3; p2 = 0; p3 = 1;
            t0 = 1; t1 = 1; t2 = 0; t3 = 0;
          } else {
            p0 = 1; p1 = 2; p2 = 3; p3 = 0;
            t0 = 1; t1 = 1; t2 = 1; t3 = 0;
          }

          for (int p = 0; p < p_range; p+=4) {
            #pragma HLS PIPELINE II=2
            //#pragma HLS UNROLL factor=2
            int idx0 = (local_ind0[p/4 + t0 + (offset + offset0)/4] - i) / 4;
            int idx1 = (local_ind1[p/4 + t1 + (offset + offset0)/4] - i) / 4;
            int idx2 = (local_ind2[p/4 + t2 + (offset + offset0)/4] - i) / 4;
            int idx3 = (local_ind3[p/4 + t3 + (offset + offset0)/4] - i) / 4;

            DATATYPE x0_tmp0 = local_x0[idx0];
            DATATYPE x0_tmp1 = local_x0[idx1];
            DATATYPE x0_tmp2 = local_x0[idx2];
            DATATYPE x0_tmp3 = local_x0[idx3];

            DATATYPE x1_tmp0 = local_x1[idx0];
            DATATYPE x1_tmp1 = local_x1[idx1];
            DATATYPE x1_tmp2 = local_x1[idx2];
            DATATYPE x1_tmp3 = local_x1[idx3];

            DATATYPE x2_tmp0 = local_x2[idx0];
            DATATYPE x2_tmp1 = local_x2[idx1];
            DATATYPE x2_tmp2 = local_x2[idx2];
            DATATYPE x2_tmp3 = local_x2[idx3];

            DATATYPE x3_tmp0 = local_x3[idx0];
            DATATYPE x3_tmp1 = local_x3[idx1];
            DATATYPE x3_tmp2 = local_x3[idx2];
            DATATYPE x3_tmp3 = local_x3[idx3];

//            if ((p + p0 < p_range) && local_ind0[p/4 + t0 + (offset + offset0)/4] >= i && local_ind0[p/4 + t0 + (offset + offset0)/4] < i + SIZE)
//              tmp0 += local_val0[p/4 + t0 + (offset + offset0)/4] * local_x0[local_ind0[p/4 + t0 + (offset + offset0)/4] - i];
//            if ((p + p1 < p_range) && local_ind1[p/4 + t1 + (offset + offset0)/4] >= i && local_ind1[p/4 + t1 + (offset + offset0)/4] < i + SIZE)
//              tmp0 += local_val1[p/4 + t1 + (offset + offset0)/4] * local_x1[local_ind1[p/4 + t1 + (offset + offset0)/4] - i];
//            if ((p + p2 < p_range) && local_ind2[p/4 + t2 + (offset + offset0)/4] >= i && local_ind2[p/4 + t2 + (offset + offset0)/4] < i + SIZE)
//              tmp0 += local_val2[p/4 + t2 + (offset + offset0)/4] * local_x2[local_ind2[p/4 + t2 + (offset + offset0)/4] - i];
//            if ((p + p3 < p_range) && local_ind3[p/4 + t3 + (offset + offset0)/4] >= i && local_ind3[p/4 + t3 + (offset + offset0)/4] < i + SIZE)
//              tmp0 += local_val3[p/4 + t3 + (offset + offset0)/4] * local_x3[local_ind3[p/4 + t3 + (offset + offset0)/4] - i];

            DATATYPE x_tmp0, x_tmp1, x_tmp2, x_tmp3;
            int rem0 = (local_ind0[p/4 + t0 + (offset + offset0)/4] - i) % 4;
            int rem1 = (local_ind1[p/4 + t1 + (offset + offset0)/4] - i) % 4;
            int rem2 = (local_ind2[p/4 + t2 + (offset + offset0)/4] - i) % 4;
            int rem3 = (local_ind3[p/4 + t3 + (offset + offset0)/4] - i) % 4;
            if (rem0 % 4 == 0)
              x_tmp0 = x0_tmp0;
            else if (rem0 % 4 == 1)
              x_tmp0 = x1_tmp0;
            else if (rem0 % 4 == 2)
              x_tmp0 = x2_tmp0;
            else if (rem0 % 4 == 3)
              x_tmp0 = x3_tmp0;

            if (rem1 % 4 == 0)
              x_tmp1 = x0_tmp1;
            else if (rem1 % 4 == 1)
              x_tmp1 = x1_tmp1;
            else if (rem1 % 4 == 2)
              x_tmp1 = x2_tmp1;
            else if (rem1 % 4 == 3)
              x_tmp1 = x3_tmp1;

            if (rem2 % 4 == 0)
              x_tmp2 = x0_tmp2;
            else if (rem2 % 4 == 1)
              x_tmp2 = x1_tmp2;
            else if (rem2 % 4 == 2)
              x_tmp2 = x2_tmp2;
            else if (rem2 % 4 == 3)
              x_tmp2 = x3_tmp2;

            if (rem3 % 4 == 0)
              x_tmp3 = x0_tmp3;
            else if (rem3 % 4 == 1)
              x_tmp3 = x1_tmp3;
            else if (rem3 % 4 == 2)
              x_tmp3 = x2_tmp3;
            else if (rem3 % 4 == 3)
              x_tmp3 = x3_tmp3;

            if ((p + p0 < p_range) && local_ind0[p/4 + t0 + (offset + offset0)/4] >= i && local_ind0[p/4 + t0 + (offset + offset0)/4] < i + SIZE)
              tmp0 += local_val0[p/4 + t0 + (offset + offset0)/4] * x_tmp0;
            if ((p + p1 < p_range) && local_ind1[p/4 + t1 + (offset + offset0)/4] >= i && local_ind1[p/4 + t1 + (offset + offset0)/4] < i + SIZE)
              tmp1 += local_val1[p/4 + t1 + (offset + offset0)/4] * x_tmp1;
            if ((p + p2 < p_range) && local_ind2[p/4 + t2 + (offset + offset0)/4] >= i && local_ind2[p/4 + t2 + (offset + offset0)/4] < i + SIZE)
              tmp2 += local_val2[p/4 + t2 + (offset + offset0)/4] * x_tmp2;
            if ((p + p3 < p_range) && local_ind3[p/4 + t3 + (offset + offset0)/4] >= i && local_ind3[p/4 + t3 + (offset + offset0)/4] < i + SIZE)
              tmp3 += local_val3[p/4 + t3 + (offset + offset0)/4] * x_tmp3;

          }
          local_y[r] += tmp0 + tmp1 + tmp2 + tmp3;
          offset += p_range;
        }
      }
    }
    k0 = k1;
  }

  cfg0.write((y_offset + row_begin) << 3); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(0); // seg_stride
  cfg0.write(1); // seg_count
  cfg0.write((row_end - row_begin) / 8); // len
  cfg0.write(2); // mode
  while (ss0_out.full());
  for (int i = 0; i < (row_end - row_begin) / 4; i++) {
    #pragma HLS PIPELINE
    DATATYPE_IF tmp;
    tmp.range(64*1-1, 64*0) = local_y[4 * i + 0];
    tmp.range(64*2-1, 64*1) = local_y[4 * i + 1];
    tmp.range(64*3-1, 64*2) = local_y[4 * i + 2];
    tmp.range(64*4-1, 64*3) = local_y[4 * i + 3];

    //m0[(y_offset + row_begin) / 4 + i] = tmp;
    ss0_out.write(tmp);
  }
}

void spmv_axi(hls::stream<ap_int<256>> &ss0_in,
              hls::stream<ap_int<256>> &ss0_out,
              hls::stream<ap_int<32>>  &cfg0,
              hls::stream<ap_int<256>> &ss1_in,
              hls::stream<ap_int<256>> &ss1_out,
              hls::stream<ap_int<32>>  &cfg1,
              int n, int row_begin, int row_end) {

#pragma HLS INTERFACE s_axilite port=return bundle=control
#pragma HLS INTERFACE s_axilite port=n bundle=control
#pragma HLS INTERFACE s_axilite port=row_begin bundle=control
#pragma HLS INTERFACE s_axilite port=row_end bundle=control
  int row_half = row_begin + (row_end - row_begin) / 2;
//  spmv_axi_sub(ss0_in, ss0_out, cfg0, n, row_begin, row_half);
//  spmv_axi_sub(ss1_in, ss1_out, cfg1, n, row_half, row_end);
  spmv_axi_sub1(ss0_in, ss0_out, cfg0, n, row_begin, row_half);
  spmv_axi_sub1(ss1_in, ss1_out, cfg1, n, row_half, row_end);

}

void cl_spmv_sub(DATATYPE local_val0[(SIZE + 8)/4],
             DATATYPE local_val1[(SIZE + 8)/4],
             DATATYPE local_val2[(SIZE + 8)/4],
             DATATYPE local_val3[(SIZE + 8)/4],
             DATATYPE local_ind0[(SIZE + 8)/4],
             DATATYPE local_ind1[(SIZE + 8)/4],
             DATATYPE local_ind2[(SIZE + 8)/4],
             DATATYPE local_ind3[(SIZE + 8)/4],
             DATATYPE local_x0[SIZE/4],
             DATATYPE local_x1[SIZE/4],
             DATATYPE local_x2[SIZE/4],
             DATATYPE local_x3[SIZE/4],
             DATATYPE local_y[Y_LEN],
             DATATYPE local_ptr[Y_LEN+4],
             int n, int len1, int i,
             int k1, int offset, int offset0, int row_begin, int row_end
) {
  for (int r = row_begin; r < row_end; r++) {
    DATATYPE tmp0 = 0;
    DATATYPE tmp1 = 0;
    DATATYPE tmp2 = 0;
    DATATYPE tmp3 = 0;

    int p_range = local_ptr[r + 1] - local_ptr[r];
    if (r == k1 - 1)
      p_range = len1 - offset;
    int z = (offset + offset0) % 4;
    int p0, p1, p2, p3;
    int t0, t1, t2, t3;
    if (z == 0) {
      p0 = 0; p1 = 1; p2 = 2; p3 = 3;
      t0 = 0; t1 = 0; t2 = 0; t3 = 0;
    } else if (z == 1) {
      p0 = 3; p1 = 0; p2 = 1; p3 = 2;
      t0 = 1; t1 = 0; t2 = 0; t3 = 0;
    } else if (z == 2) {
      p0 = 2; p1 = 3; p2 = 0; p3 = 1;
      t0 = 1; t1 = 1; t2 = 0; t3 = 0;
    } else {
      p0 = 1; p1 = 2; p2 = 3; p3 = 0;
      t0 = 1; t1 = 1; t2 = 1; t3 = 0;
    }

    for (int p = 0; p < p_range; p+=4) {
      //#pragma HLS PIPELINE II=2
      //#pragma HLS UNROLL factor=2
      int idx0 = (local_ind0[p/4 + t0 + (offset + offset0)/4] - i) / 4;
      int idx1 = (local_ind1[p/4 + t1 + (offset + offset0)/4] - i) / 4;
      int idx2 = (local_ind2[p/4 + t2 + (offset + offset0)/4] - i) / 4;
      int idx3 = (local_ind3[p/4 + t3 + (offset + offset0)/4] - i) / 4;

      DATATYPE x0_tmp0 = local_x0[idx0];
      DATATYPE x0_tmp1 = local_x0[idx1];
      DATATYPE x0_tmp2 = local_x0[idx2];
      DATATYPE x0_tmp3 = local_x0[idx3];

      DATATYPE x1_tmp0 = local_x1[idx0];
      DATATYPE x1_tmp1 = local_x1[idx1];
      DATATYPE x1_tmp2 = local_x1[idx2];
      DATATYPE x1_tmp3 = local_x1[idx3];

      DATATYPE x2_tmp0 = local_x2[idx0];
      DATATYPE x2_tmp1 = local_x2[idx1];
      DATATYPE x2_tmp2 = local_x2[idx2];
      DATATYPE x2_tmp3 = local_x2[idx3];

      DATATYPE x3_tmp0 = local_x3[idx0];
      DATATYPE x3_tmp1 = local_x3[idx1];
      DATATYPE x3_tmp2 = local_x3[idx2];
      DATATYPE x3_tmp3 = local_x3[idx3];

      DATATYPE x_tmp0, x_tmp1, x_tmp2, x_tmp3;
      int rem0 = (local_ind0[p/4 + t0 + (offset + offset0)/4] - i) % 4;
      int rem1 = (local_ind1[p/4 + t1 + (offset + offset0)/4] - i) % 4;
      int rem2 = (local_ind2[p/4 + t2 + (offset + offset0)/4] - i) % 4;
      int rem3 = (local_ind3[p/4 + t3 + (offset + offset0)/4] - i) % 4;
      if (rem0 % 4 == 0)
        x_tmp0 = x0_tmp0;
      else if (rem0 % 4 == 1)
        x_tmp0 = x1_tmp0;
      else if (rem0 % 4 == 2)
        x_tmp0 = x2_tmp0;
      else if (rem0 % 4 == 3)
        x_tmp0 = x3_tmp0;

      if (rem1 % 4 == 0)
        x_tmp1 = x0_tmp1;
      else if (rem1 % 4 == 1)
        x_tmp1 = x1_tmp1;
      else if (rem1 % 4 == 2)
        x_tmp1 = x2_tmp1;
      else if (rem1 % 4 == 3)
        x_tmp1 = x3_tmp1;

      if (rem2 % 4 == 0)
        x_tmp2 = x0_tmp2;
      else if (rem2 % 4 == 1)
        x_tmp2 = x1_tmp2;
      else if (rem2 % 4 == 2)
        x_tmp2 = x2_tmp2;
      else if (rem2 % 4 == 3)
        x_tmp2 = x3_tmp2;

      if (rem3 % 4 == 0)
        x_tmp3 = x0_tmp3;
      else if (rem3 % 4 == 1)
        x_tmp3 = x1_tmp3;
      else if (rem3 % 4 == 2)
        x_tmp3 = x2_tmp3;
      else if (rem3 % 4 == 3)
        x_tmp3 = x3_tmp3;

      if ((p + p0 < p_range) && (local_ind0[p/4 + t0 + (offset + offset0)/4] >= i) && (local_ind0[p/4 + t0 + (offset + offset0)/4] < i + SIZE))
        tmp0 += local_val0[p/4 + t0 + (offset + offset0)/4] * x_tmp0;
      if ((p + p1 < p_range) && (local_ind1[p/4 + t1 + (offset + offset0)/4] >= i) && (local_ind1[p/4 + t1 + (offset + offset0)/4] < i + SIZE))
        tmp1 += local_val1[p/4 + t1 + (offset + offset0)/4] * x_tmp1;
      if ((p + p2 < p_range) && (local_ind2[p/4 + t2 + (offset + offset0)/4] >= i) && (local_ind2[p/4 + t2 + (offset + offset0)/4] < i + SIZE))
        tmp2 += local_val2[p/4 + t2 + (offset + offset0)/4] * x_tmp2;
      if ((p + p3 < p_range) && (local_ind3[p/4 + t3 + (offset + offset0)/4] >= i) && (local_ind3[p/4 + t3 + (offset + offset0)/4] < i + SIZE))
        tmp3 += local_val3[p/4 + t3 + (offset + offset0)/4] * x_tmp3;
    }

    local_y[r] += tmp0 + tmp1 + tmp2 + tmp3;
  }
}

void subtask0(
   DATATYPE local_val0[(SIZE + 8)/4],
   DATATYPE local_val1[(SIZE + 8)/4],
   DATATYPE local_val2[(SIZE + 8)/4],
   DATATYPE local_val3[(SIZE + 8)/4],
   DATATYPE local_ind0[(SIZE + 8)/4],
   DATATYPE local_ind1[(SIZE + 8)/4],
   DATATYPE local_ind2[(SIZE + 8)/4],
   DATATYPE local_ind3[(SIZE + 8)/4],
   DATATYPE local_x0[X_LEN/4],
   DATATYPE local_x1[X_LEN/4],
   DATATYPE local_x2[X_LEN/4],
   DATATYPE local_x3[X_LEN/4],
   DATATYPE local_y[Y_LEN],
   DATATYPE local_ptr[Y_LEN + 8],
   DATATYPE last_ind[Y_LEN],
   int cur_ptr, int k0, int k1, int i, int len1, int maxlen
) {
  if (cur_ptr >= maxlen)
    return;

  int offset0 = cur_ptr % 8;
  int offset = 0;
  int p_init = cur_ptr - local_ptr[k0];
  for (int r = k0; r <= k1; r++) {
    DATATYPE tmp0 = 0;
    DATATYPE tmp1 = 0;
    DATATYPE tmp2 = 0;
    DATATYPE tmp3 = 0;

    int p_range = local_ptr[r + 1] - local_ptr[r];
    if (r == k1)
      p_range = len1 - offset;
    if (r == k0)
      p_range = local_ptr[r + 1] - local_ptr[r] - p_init;
    p_range = (p_range > SIZE) ? SIZE : p_range;

    int z = (offset + offset0) % 4;
    int p0, p1, p2, p3;
    int t0, t1, t2, t3;
    if (z == 0) {
      p0 = 0; p1 = 1; p2 = 2; p3 = 3;
      t0 = 0; t1 = 0; t2 = 0; t3 = 0;
    } else if (z == 1) {
      p0 = 3; p1 = 0; p2 = 1; p3 = 2;
      t0 = 1; t1 = 0; t2 = 0; t3 = 0;
    } else if (z == 2) {
      p0 = 2; p1 = 3; p2 = 0; p3 = 1;
      t0 = 1; t1 = 1; t2 = 0; t3 = 0;
    } else {
      p0 = 1; p1 = 2; p2 = 3; p3 = 0;
      t0 = 1; t1 = 1; t2 = 1; t3 = 0;
    }

    int last_ind_tmp0 = last_ind[r];
    int last_ind_tmp1 = last_ind[r];
    int last_ind_tmp2 = last_ind[r];
    int last_ind_tmp3 = last_ind[r];

    for (int p = last_ind[r]; p < p_range; p+=4) {
      #pragma HLS PIPELINE II=2
//      int idx0 = (local_ind0[p/4 + t0 + (offset + offset0)/4] - i);
//      int idx1 = (local_ind1[p/4 + t1 + (offset + offset0)/4] - i);
//      int idx2 = (local_ind2[p/4 + t2 + (offset + offset0)/4] - i);
//      int idx3 = (local_ind3[p/4 + t3 + (offset + offset0)/4] - i);
//
//      DATATYPE x0_tmp = local_x0[idx0];
//      DATATYPE x1_tmp = local_x1[idx1];
//      DATATYPE x2_tmp = local_x2[idx2];
//      DATATYPE x3_tmp = local_x3[idx3];

      int idx0 = (local_ind0[p/4 + t0 + (offset + offset0)/4] - i) / 4;
      int idx1 = (local_ind1[p/4 + t1 + (offset + offset0)/4] - i) / 4;
      int idx2 = (local_ind2[p/4 + t2 + (offset + offset0)/4] - i) / 4;
      int idx3 = (local_ind3[p/4 + t3 + (offset + offset0)/4] - i) / 4;

      DATATYPE x0_tmp0 = local_x0[idx0];
      DATATYPE x0_tmp1 = local_x0[idx1];
      DATATYPE x0_tmp2 = local_x0[idx2];
      DATATYPE x0_tmp3 = local_x0[idx3];

      DATATYPE x1_tmp0 = local_x1[idx0];
      DATATYPE x1_tmp1 = local_x1[idx1];
      DATATYPE x1_tmp2 = local_x1[idx2];
      DATATYPE x1_tmp3 = local_x1[idx3];

      DATATYPE x2_tmp0 = local_x2[idx0];
      DATATYPE x2_tmp1 = local_x2[idx1];
      DATATYPE x2_tmp2 = local_x2[idx2];
      DATATYPE x2_tmp3 = local_x2[idx3];

      DATATYPE x3_tmp0 = local_x3[idx0];
      DATATYPE x3_tmp1 = local_x3[idx1];
      DATATYPE x3_tmp2 = local_x3[idx2];
      DATATYPE x3_tmp3 = local_x3[idx3];

      DATATYPE x_tmp0, x_tmp1, x_tmp2, x_tmp3;
      int rem0 = (local_ind0[p/4 + t0 + (offset + offset0)/4] - i) % 4;
      int rem1 = (local_ind1[p/4 + t1 + (offset + offset0)/4] - i) % 4;
      int rem2 = (local_ind2[p/4 + t2 + (offset + offset0)/4] - i) % 4;
      int rem3 = (local_ind3[p/4 + t3 + (offset + offset0)/4] - i) % 4;

      if (rem0 % 4 == 0)
        x_tmp0 = x0_tmp0;
      else if (rem0 % 4 == 1)
        x_tmp0 = x1_tmp0;
      else if (rem0 % 4 == 2)
        x_tmp0 = x2_tmp0;
      else if (rem0 % 4 == 3)
        x_tmp0 = x3_tmp0;

      if (rem1 % 4 == 0)
        x_tmp1 = x0_tmp1;
      else if (rem1 % 4 == 1)
        x_tmp1 = x1_tmp1;
      else if (rem1 % 4 == 2)
        x_tmp1 = x2_tmp1;
      else if (rem1 % 4 == 3)
        x_tmp1 = x3_tmp1;

      if (rem2 % 4 == 0)
        x_tmp2 = x0_tmp2;
      else if (rem2 % 4 == 1)
        x_tmp2 = x1_tmp2;
      else if (rem2 % 4 == 2)
        x_tmp2 = x2_tmp2;
      else if (rem2 % 4 == 3)
        x_tmp2 = x3_tmp2;

      if (rem3 % 4 == 0)
        x_tmp3 = x0_tmp3;
      else if (rem3 % 4 == 1)
        x_tmp3 = x1_tmp3;
      else if (rem3 % 4 == 2)
        x_tmp3 = x2_tmp3;
      else if (rem3 % 4 == 3)
        x_tmp3 = x3_tmp3;

      if ((p + p0 < p_range) && (local_ind0[p/4 + t0 + (offset + offset0)/4] >= i) && (local_ind0[p/4 + t0 + (offset + offset0)/4] < i + X_LEN)) {
        tmp0 += local_val0[p/4 + t0 + (offset + offset0)/4] * x_tmp0;
        last_ind_tmp0 = p;
      }
      if ((p + p1 < p_range) && (local_ind1[p/4 + t1 + (offset + offset0)/4] >= i) && (local_ind1[p/4 + t1 + (offset + offset0)/4] < i + X_LEN)) {
        tmp1 += local_val1[p/4 + t1 + (offset + offset0)/4] * x_tmp1;
        last_ind_tmp1 = p;
      }
      if ((p + p2 < p_range) && (local_ind2[p/4 + t2 + (offset + offset0)/4] >= i) && (local_ind2[p/4 + t2 + (offset + offset0)/4] < i + X_LEN)) {
        tmp2 += local_val2[p/4 + t2 + (offset + offset0)/4] * x_tmp2;
        last_ind_tmp2 = p;
      }
      if ((p + p3 < p_range) && (local_ind3[p/4 + t3 + (offset + offset0)/4] >= i) && (local_ind3[p/4 + t3 + (offset + offset0)/4] < i + X_LEN)) {
        tmp3 += local_val3[p/4 + t3 + (offset + offset0)/4] * x_tmp3;
        last_ind_tmp3 = p;
      }

      int max01 = (last_ind_tmp0 > last_ind_tmp1) ? last_ind_tmp0 : last_ind_tmp1;
      int max23 = (last_ind_tmp2 > last_ind_tmp3) ? last_ind_tmp2 : last_ind_tmp3;
      int max_last_ind = (max01 > max23) ? max01 : max23;
      last_ind[r] = max_last_ind;
    }

    local_y[r] += tmp0 + tmp1 + tmp2 + tmp3;
    offset += p_range;
  }
}

void subtask1(
   DATATYPE local_val0[(SIZE + 8)/4],
   DATATYPE local_val1[(SIZE + 8)/4],
   DATATYPE local_val2[(SIZE + 8)/4],
   DATATYPE local_val3[(SIZE + 8)/4],
   DATATYPE local_ind0[(SIZE + 8)/4],
   DATATYPE local_ind1[(SIZE + 8)/4],
   DATATYPE local_ind2[(SIZE + 8)/4],
   DATATYPE local_ind3[(SIZE + 8)/4],
   DATATYPE local_x0[X_LEN/4],
   DATATYPE local_x1[X_LEN/4],
   DATATYPE local_x2[X_LEN/4],
   DATATYPE local_x3[X_LEN/4],
   DATATYPE local_y[Y_LEN],
   DATATYPE local_ptr[Y_LEN + 8],
   DATATYPE last_ind[Y_LEN],
   int cur_ptr, int k0, int k1, int i, int len1, int maxlen
) {
  if (cur_ptr >= maxlen)
    return;

  int offset0 = cur_ptr % 8;
  int offset = 0;
  int p_init = cur_ptr - local_ptr[k0];
  for (int r = k0; r <= k1; r++) {
    DATATYPE tmp0 = 0;
    DATATYPE tmp1 = 0;
    DATATYPE tmp2 = 0;
    DATATYPE tmp3 = 0;

    int p_range = local_ptr[r + 1] - local_ptr[r];
    if (r == k1)
      p_range = len1 - offset;
    if (r == k0)
      p_range = local_ptr[r + 1] - local_ptr[r] - p_init;
    p_range = (p_range > SIZE) ? SIZE : p_range;

    int z = (offset + offset0) % 4;
    int p0, p1, p2, p3;
    int t0, t1, t2, t3;
    if (z == 0) {
      p0 = 0; p1 = 1; p2 = 2; p3 = 3;
      t0 = 0; t1 = 0; t2 = 0; t3 = 0;
    } else if (z == 1) {
      p0 = 3; p1 = 0; p2 = 1; p3 = 2;
      t0 = 1; t1 = 0; t2 = 0; t3 = 0;
    } else if (z == 2) {
      p0 = 2; p1 = 3; p2 = 0; p3 = 1;
      t0 = 1; t1 = 1; t2 = 0; t3 = 0;
    } else {
      p0 = 1; p1 = 2; p2 = 3; p3 = 0;
      t0 = 1; t1 = 1; t2 = 1; t3 = 0;
    }

    int last_ind_tmp0 = last_ind[r];
    int last_ind_tmp1 = last_ind[r];
    int last_ind_tmp2 = last_ind[r];
    int last_ind_tmp3 = last_ind[r];

    for (int p = last_ind[r]; p < p_range; p+=4) {
      #pragma HLS PIPELINE II=2
//      int idx0 = (local_ind0[p/4 + t0 + (offset + offset0)/4] - i);
//      int idx1 = (local_ind1[p/4 + t1 + (offset + offset0)/4] - i);
//      int idx2 = (local_ind2[p/4 + t2 + (offset + offset0)/4] - i);
//      int idx3 = (local_ind3[p/4 + t3 + (offset + offset0)/4] - i);
//
//      DATATYPE x0_tmp = local_x0[idx0];
//      DATATYPE x1_tmp = local_x1[idx1];
//      DATATYPE x2_tmp = local_x2[idx2];
//      DATATYPE x3_tmp = local_x3[idx3];

      int idx0 = (local_ind0[p/4 + t0 + (offset + offset0)/4] - i) / 4;
      int idx1 = (local_ind1[p/4 + t1 + (offset + offset0)/4] - i) / 4;
      int idx2 = (local_ind2[p/4 + t2 + (offset + offset0)/4] - i) / 4;
      int idx3 = (local_ind3[p/4 + t3 + (offset + offset0)/4] - i) / 4;

      DATATYPE x0_tmp0 = local_x0[idx0];
      DATATYPE x0_tmp1 = local_x0[idx1];
      DATATYPE x0_tmp2 = local_x0[idx2];
      DATATYPE x0_tmp3 = local_x0[idx3];

      DATATYPE x1_tmp0 = local_x1[idx0];
      DATATYPE x1_tmp1 = local_x1[idx1];
      DATATYPE x1_tmp2 = local_x1[idx2];
      DATATYPE x1_tmp3 = local_x1[idx3];

      DATATYPE x2_tmp0 = local_x2[idx0];
      DATATYPE x2_tmp1 = local_x2[idx1];
      DATATYPE x2_tmp2 = local_x2[idx2];
      DATATYPE x2_tmp3 = local_x2[idx3];

      DATATYPE x3_tmp0 = local_x3[idx0];
      DATATYPE x3_tmp1 = local_x3[idx1];
      DATATYPE x3_tmp2 = local_x3[idx2];
      DATATYPE x3_tmp3 = local_x3[idx3];

      DATATYPE x_tmp0, x_tmp1, x_tmp2, x_tmp3;
      int rem0 = (local_ind0[p/4 + t0 + (offset + offset0)/4] - i) % 4;
      int rem1 = (local_ind1[p/4 + t1 + (offset + offset0)/4] - i) % 4;
      int rem2 = (local_ind2[p/4 + t2 + (offset + offset0)/4] - i) % 4;
      int rem3 = (local_ind3[p/4 + t3 + (offset + offset0)/4] - i) % 4;

      if (rem0 % 4 == 0)
        x_tmp0 = x0_tmp0;
      else if (rem0 % 4 == 1)
        x_tmp0 = x1_tmp0;
      else if (rem0 % 4 == 2)
        x_tmp0 = x2_tmp0;
      else if (rem0 % 4 == 3)
        x_tmp0 = x3_tmp0;

      if (rem1 % 4 == 0)
        x_tmp1 = x0_tmp1;
      else if (rem1 % 4 == 1)
        x_tmp1 = x1_tmp1;
      else if (rem1 % 4 == 2)
        x_tmp1 = x2_tmp1;
      else if (rem1 % 4 == 3)
        x_tmp1 = x3_tmp1;

      if (rem2 % 4 == 0)
        x_tmp2 = x0_tmp2;
      else if (rem2 % 4 == 1)
        x_tmp2 = x1_tmp2;
      else if (rem2 % 4 == 2)
        x_tmp2 = x2_tmp2;
      else if (rem2 % 4 == 3)
        x_tmp2 = x3_tmp2;

      if (rem3 % 4 == 0)
        x_tmp3 = x0_tmp3;
      else if (rem3 % 4 == 1)
        x_tmp3 = x1_tmp3;
      else if (rem3 % 4 == 2)
        x_tmp3 = x2_tmp3;
      else if (rem3 % 4 == 3)
        x_tmp3 = x3_tmp3;

      if ((p + p0 < p_range) && (local_ind0[p/4 + t0 + (offset + offset0)/4] >= i) && (local_ind0[p/4 + t0 + (offset + offset0)/4] < i + X_LEN)) {
        tmp0 += local_val0[p/4 + t0 + (offset + offset0)/4] * x_tmp0;
        last_ind_tmp0 = p;
      }
      if ((p + p1 < p_range) && (local_ind1[p/4 + t1 + (offset + offset0)/4] >= i) && (local_ind1[p/4 + t1 + (offset + offset0)/4] < i + X_LEN)) {
        tmp1 += local_val1[p/4 + t1 + (offset + offset0)/4] * x_tmp1;
        last_ind_tmp1 = p;
      }
      if ((p + p2 < p_range) && (local_ind2[p/4 + t2 + (offset + offset0)/4] >= i) && (local_ind2[p/4 + t2 + (offset + offset0)/4] < i + X_LEN)) {
        tmp2 += local_val2[p/4 + t2 + (offset + offset0)/4] * x_tmp2;
        last_ind_tmp2 = p;
      }
      if ((p + p3 < p_range) && (local_ind3[p/4 + t3 + (offset + offset0)/4] >= i) && (local_ind3[p/4 + t3 + (offset + offset0)/4] < i + X_LEN)) {
        tmp3 += local_val3[p/4 + t3 + (offset + offset0)/4] * x_tmp3;
        last_ind_tmp3 = p;
      }

      int max01 = (last_ind_tmp0 > last_ind_tmp1) ? last_ind_tmp0 : last_ind_tmp1;
      int max23 = (last_ind_tmp2 > last_ind_tmp3) ? last_ind_tmp2 : last_ind_tmp3;
      int max_last_ind = (max01 > max23) ? max01 : max23;
      last_ind[r] = max_last_ind;
    }

    local_y[r] += tmp0 + tmp1 + tmp2 + tmp3;
    offset += p_range;
  }
}

void cl_spmv(DATATYPE local_val00[(SIZE + 8)/4],
             DATATYPE local_val10[(SIZE + 8)/4],
             DATATYPE local_val20[(SIZE + 8)/4],
             DATATYPE local_val30[(SIZE + 8)/4],
             DATATYPE local_ind00[(SIZE + 8)/4],
             DATATYPE local_ind10[(SIZE + 8)/4],
             DATATYPE local_ind20[(SIZE + 8)/4],
             DATATYPE local_ind30[(SIZE + 8)/4],
             DATATYPE local_x00[X_LEN/4],
             DATATYPE local_x10[X_LEN/4],
             DATATYPE local_x20[X_LEN/4],
             DATATYPE local_x30[X_LEN/4],
             DATATYPE local_y0[Y_LEN],
             DATATYPE local_ptr0[Y_LEN+8],

             DATATYPE local_val01[(SIZE + 8)/4],
             DATATYPE local_val11[(SIZE + 8)/4],
             DATATYPE local_val21[(SIZE + 8)/4],
             DATATYPE local_val31[(SIZE + 8)/4],
             DATATYPE local_ind01[(SIZE + 8)/4],
             DATATYPE local_ind11[(SIZE + 8)/4],
             DATATYPE local_ind21[(SIZE + 8)/4],
             DATATYPE local_ind31[(SIZE + 8)/4],
             DATATYPE local_x01[X_LEN/4],
             DATATYPE local_x11[X_LEN/4],
             DATATYPE local_x21[X_LEN/4],
             DATATYPE local_x31[X_LEN/4],
             DATATYPE local_y1[Y_LEN],
             DATATYPE local_ptr1[Y_LEN+8],

             DATATYPE last_ind0[Y_LEN],
             DATATYPE last_ind1[Y_LEN],
             int n, int row_begin, int row_end,
             int len1, int len2, int i,
             int k0, int *k1, int *k2, int *maxlen, int *cur_ptr,
             int state, int pp
) {
#pragma HLS INTERFACE mode=ap_memory port=local_y0 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_ptr0 storage_type=ram_1p latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_val00 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_val10 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_val20 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_val30 latency=3

#pragma HLS INTERFACE mode=ap_memory port=local_ind00 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_ind10 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_ind20 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_ind30 latency=3

#pragma HLS INTERFACE mode=ap_memory port=local_x00 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_x10 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_x20 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_x30 latency=3

#pragma HLS INTERFACE mode=ap_memory port=local_y1 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_ptr1 storage_type=ram_1p latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_val01 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_val11 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_val21 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_val31 latency=3

#pragma HLS INTERFACE mode=ap_memory port=local_ind01 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_ind11 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_ind21 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_ind31 latency=3

#pragma HLS INTERFACE mode=ap_memory port=local_x01 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_x11 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_x21 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_x31 latency=3

#pragma HLS INTERFACE mode=ap_memory port=last_ind0 latency=3
#pragma HLS INTERFACE mode=ap_memory port=last_ind1 latency=3

  //int last_ind0[Y_LEN];
  //int last_ind1[Y_LEN];

  if (state == 5) {
    for (int r = 0; r < (row_end - row_begin); r++) {
      local_y1[r] = 0;
    }
  } else if (state ==3) {
    *cur_ptr = local_ptr0[k0];
    *maxlen = local_ptr0[row_end - row_begin];
  } else if (state == 0) {
    *k1 = row_end - row_begin;
    *k2 = row_end - row_begin;
    for (int k = k0 + 1; k < (row_end - row_begin); k++) {
      if ((local_ptr0[k] >= (*cur_ptr + SIZE)) && (k < *k1)) {
        *k1 = k;
        //break;
      }
      if ((local_ptr0[k] >= (*cur_ptr + SIZE * 2)) && (k < *k2)) {
        *k2 = k;
        //break;
      }
    }
    *k1 = *k1 - 1;
    *k2 = *k2 - 1;
   
  } else if (state == 2) {
    for (int r = k0; r <= *k1; r++) {
      last_ind0[r] = 0;
    }
    for (int r = *k1; r <= *k2; r++) {
      last_ind1[r] = 0;
    }

  } else if (state == 1) {
    int cur_ptr1_val = *cur_ptr;
    int cur_ptr2_val = *cur_ptr + len1;
    int k1_val = *k1;
    int k2_val = *k2;
    int maxlen_val = *maxlen;

    subtask0(local_val00, local_val10, local_val20, local_val30,
             local_ind00, local_ind10, local_ind20, local_ind30,
             local_x00, local_x10, local_x20, local_x30, local_y0,
             local_ptr0, last_ind0,
             cur_ptr1_val, k0, k1_val, i, len1, maxlen_val);

    subtask1(local_val01, local_val11, local_val21, local_val31,
             local_ind01, local_ind11, local_ind21, local_ind31,
             local_x01, local_x11, local_x21, local_x31, local_y1,
             local_ptr1, last_ind1,
             cur_ptr2_val, k1_val, k2_val, i, len2, maxlen_val);
  } else if (state == 4) {
    for (int r = 0; r < (row_end - row_begin); r++) {
      local_y0[r] += local_y1[r];
    }
  }
}

