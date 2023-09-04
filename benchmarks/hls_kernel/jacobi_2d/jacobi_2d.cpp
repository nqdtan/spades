#include "jacobi_2d.h"
#include "hls_stream.h"
#include <iostream>
#define SIZE 64

void jacobi_2d_compute0(DATATYPE mm0_0[SIZE / 4 + 1][(SIZE + 8)],
                        DATATYPE mm0_1[SIZE / 4 + 1][(SIZE + 8)],
                        DATATYPE mm1[SIZE * SIZE / 2],
                        bool edge_w, bool edge_e,
                        bool edge_n, bool edge_s) {
  DATATYPE tmp_m, tmp_w, tmp_e, tmp_n, tmp_s;
  DATATYPE tmp_m_0 = mm0_0[0][4];
  DATATYPE tmp_m_1;
  for (int iijj = 0; iijj < (SIZE / 2) * SIZE; iijj++) {
    #pragma HLS UNROLL factor=2
    int ii = 0 + (iijj / SIZE);
    int jj = 4 + (iijj % SIZE);
    if (ii % 2 == 0) {
      tmp_m =                                      tmp_m_0;
      tmp_w = (jj == 4            && edge_w) ? 0 : mm0_0[ii/2][(jj - 1)];
      tmp_e = (jj + 1 == SIZE + 4 && edge_e) ? 0 : mm0_0[ii/2][(jj + 1)];
      tmp_n = (ii == 0            && edge_n) ? 0 : mm0_1[ii/2][(jj + 0)];
      tmp_s =                                      mm0_1[ii/2+1][(jj + 0)];
      mm1[ii * SIZE + (jj - 4)] = (tmp_m + tmp_n + tmp_s + tmp_w + tmp_e) / 5;
      tmp_m_0 = tmp_e;
      if (jj == 4)
        tmp_m_1 = tmp_s;
    } else {
      tmp_m =                                      tmp_m_1;
      tmp_w = (jj == 4            && edge_w) ? 0 : mm0_1[ii/2+1][(jj - 1)];
      tmp_e = (jj + 1 == SIZE + 4 && edge_e) ? 0 : mm0_1[ii/2+1][(jj + 1)];
      tmp_n =                                      mm0_0[ii/2][(jj + 0)];
      tmp_s =                                      mm0_0[ii/2+1][(jj + 0)];
      mm1[ii * SIZE + (jj - 4)] = (tmp_m + tmp_n + tmp_s + tmp_w + tmp_e) / 5;
      tmp_m_1 = tmp_e;
      if (jj == 4)
        tmp_m_0 = tmp_s;
    }
  }
}

void jacobi_2d_compute1(DATATYPE mm0_0[SIZE / 4 + 1][(SIZE + 8)],
                        DATATYPE mm0_1[SIZE / 4 + 1][(SIZE + 8)],
                        DATATYPE mm1[SIZE * SIZE / 2],
                        bool edge_w, bool edge_e,
                        bool edge_n, bool edge_s) {
  DATATYPE tmp_m, tmp_w, tmp_e, tmp_n, tmp_s;
  DATATYPE tmp_m_0 = mm0_0[0][4];
  DATATYPE tmp_m_1;
  for (int iijj = 0; iijj < (SIZE / 2) * SIZE; iijj++) {
    #pragma HLS UNROLL factor=2
    int ii = 0 + (iijj / SIZE);
    int jj = 4 + (iijj % SIZE);
    if (ii % 2 == 0) {
      tmp_m =                                          tmp_m_0;
      tmp_w = (jj == 4                && edge_w) ? 0 : mm0_0[ii/2][(jj - 1)];
      tmp_e = (jj + 1 == SIZE + 4     && edge_e) ? 0 : mm0_0[ii/2][(jj + 1)];
      tmp_n =                                          mm0_1[ii/2][(jj + 0)];
      tmp_s = (ii + 1 == SIZE / 2     && edge_s) ? 0 : mm0_1[ii/2+1][(jj + 0)];
      mm1[ii * SIZE + (jj - 4)] = (tmp_m + tmp_n + tmp_s + tmp_w + tmp_e) / 5;
      tmp_m_0 = tmp_e;
      if (jj == 4)
        tmp_m_1 = tmp_s;
    } else {
      tmp_m =                                          tmp_m_1;
      tmp_w = (jj == 4                && edge_w) ? 0 : mm0_1[ii/2+1][(jj - 1)];
      tmp_e = (jj + 1 == SIZE + 4     && edge_e) ? 0 : mm0_1[ii/2+1][(jj + 1)];
      tmp_n =                                          mm0_0[ii/2][(jj + 0)];
      tmp_s = (ii + 1 == SIZE / 2     && edge_s) ? 0 : mm0_0[ii/2+1][(jj + 0)];
      mm1[ii * SIZE + (jj - 4)] = (tmp_m + tmp_n + tmp_s + tmp_w + tmp_e) / 5;
      tmp_m_1 = tmp_e;
      if (jj == 4)
        tmp_m_0 = tmp_s;
    }
  }
}

void task00_ss_cfg_setup(hls::stream<ap_int<32>> &cfg0,
                         int m_offset0,
                         int m_n_offset, int m_s_offset, int m_w_offset, int m_e_offset,
                         int m0_n_offset, int m0_w_offset, int m0_e_offset,
                         int n, int i, int j) {
#pragma HLS INLINE OFF

  int f = 0;
  if (m_w_offset == 4)
    f = 1;

  int m0_offset_lo;
  m0_offset_lo = (m_offset0 + i * n * SIZE - m_n_offset * n + j * SIZE - m_w_offset) / 8;
  //cfg0.write(((m_offset0 + i * n * SIZE - m_n_offset * n + j * SIZE - m_w_offset) << 3)); // m0_offset_lo
  cfg0.write((m0_offset_lo * 8) << 3); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(n/8); // seg_stride
  cfg0.write(SIZE / 2 + m_n_offset + 1); // seg_count
  int len_tmp;
  len_tmp = (SIZE + m_w_offset + m_e_offset + 8 - 1) / 8;
  if (m_w_offset == 4 && m_e_offset == 4)
    len_tmp += 1;
  cfg0.write(len_tmp); // len
  cfg0.write(1); // mode

  m0_offset_lo = (m_offset0 + (i * n * SIZE - 1 * n + j * SIZE - m_w_offset) + n * SIZE / 2) / 8;
  //cfg0.write(((m_offset0 + (i * n * SIZE - 1 * n + j * SIZE - m_w_offset) + n * SIZE / 2) << 3)); // m0_offset_lo
  cfg0.write((m0_offset_lo * 8) << 3); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(n/8); // seg_stride
  cfg0.write(SIZE / 2 + 1 + m_s_offset); // seg_count
  len_tmp = (SIZE + m_w_offset + m_e_offset + 8 - 1) / 8;
  if (m_w_offset == 4 && m_e_offset == 4)
    len_tmp += 1;
  cfg0.write(len_tmp); // len
  cfg0.write(1); // mode
}

void task00(hls::stream<ap_int<256>> &ss0_in,
            hls::stream<ap_int<32>>  &cfg0,
            int64_t mm00_0[SIZE / 4 + 1][(SIZE + 8)],
            int64_t mm00_1[SIZE / 4 + 1][(SIZE + 8)],
            int m_offset0,
            int m_n_offset, int m_s_offset, int m_w_offset, int m_e_offset,
            int m0_n_offset, int m0_w_offset, int m0_e_offset,
            int n, int i, int j) {
#pragma HLS INLINE OFF

  int f = 0;
  if (m_w_offset == 4)
    f = 1;
  int len_tmp;
  len_tmp = (SIZE + m_w_offset + m_e_offset + 8 - 1) / 8;
  if (m_w_offset == 4 && m_e_offset == 4)
    len_tmp += 1;

  int m0_offset_lo;
  m0_offset_lo = (m_offset0 + i * n * SIZE - m_n_offset * n + j * SIZE - m_w_offset) / 8;
  //cfg0.write(((m_offset0 + i * n * SIZE - m_n_offset * n + j * SIZE - m_w_offset) << 3)); // m0_offset_lo
  cfg0.write((m0_offset_lo * 8) << 3); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(n/8); // seg_stride
  cfg0.write(SIZE / 2 + m_n_offset + 1); // seg_count
  cfg0.write(len_tmp); // len
  cfg0.write(1); // mode
  while (ss0_in.empty());
  for (int jj = 0; jj < SIZE / 2 + m_n_offset + 1; jj++) {
    for (int ii = 0; ii < len_tmp * 2; ii++) {
      #pragma HLS PIPELINE
      #pragma HLS DEPENDENCE variable=mm00_0 inter false
      #pragma HLS DEPENDENCE variable=mm00_1 inter false
     // mm00[m0_n_offset * (SIZE + 8) + m0_w_offset + jj * (SIZE + m_w_offset + m_e_offset + m0_w_offset + m0_e_offset) + ii] =
     //   m0[m_offset0 + (i * n * SIZE - m_n_offset * n + j * SIZE - m_w_offset) + jj * n + ii];
      //DATATYPE_IF tmp = m0[(m_offset0 + (i * n * SIZE - m_n_offset * n + j * SIZE - m_w_offset) + jj * n) / 4 + ii];
      DATATYPE_IF tmp = ss0_in.read();
      if ((m_w_offset == 0 && ii < len_tmp * 2 - 1) ||
          (m_w_offset == 4 && m_e_offset == 0 && ii > 0) ||
          (m_w_offset == 4 && m_e_offset == 4 && ii > 0 && ii < len_tmp * 2 - 1)) { 
      if ((jj + m0_n_offset) % 2 == 1) {
        mm00_0[jj/2][m0_w_offset + 4 * (ii - f) + 0] = tmp.range(64*1-1, 64*0);
        mm00_0[jj/2][m0_w_offset + 4 * (ii - f) + 1] = tmp.range(64*2-1, 64*1);
        mm00_0[jj/2][m0_w_offset + 4 * (ii - f) + 2] = tmp.range(64*3-1, 64*2);
        mm00_0[jj/2][m0_w_offset + 4 * (ii - f) + 3] = tmp.range(64*4-1, 64*3);
      } else {
        mm00_1[(m0_n_offset + jj)/2][m0_w_offset + 4 * (ii - f) + 0] = tmp.range(64*1-1, 64*0);
        mm00_1[(m0_n_offset + jj)/2][m0_w_offset + 4 * (ii - f) + 1] = tmp.range(64*2-1, 64*1);
        mm00_1[(m0_n_offset + jj)/2][m0_w_offset + 4 * (ii - f) + 2] = tmp.range(64*3-1, 64*2);
        mm00_1[(m0_n_offset + jj)/2][m0_w_offset + 4 * (ii - f) + 3] = tmp.range(64*4-1, 64*3);
      }
      }
    }
  }
}

void task01_ss_cfg_setup(hls::stream<ap_int<32>> &cfg0,
                         int m_offset0,
                         int m_n_offset, int m_s_offset, int m_w_offset, int m_e_offset,
                         int m0_n_offset, int m0_w_offset, int m0_e_offset,
                         int n, int i, int j) {
#pragma HLS INLINE OFF
  int f = 0;
  if (m_w_offset == 4)
    f = 1;

  int m0_offset_lo;
  m0_offset_lo = (m_offset0 + (i * n * SIZE - 1 * n + j * SIZE - m_w_offset) + n * SIZE / 2) / 8;
  //cfg0.write(((m_offset0 + (i * n * SIZE - 1 * n + j * SIZE - m_w_offset) + n * SIZE / 2) << 3)); // m0_offset_lo
  cfg0.write((m0_offset_lo * 8) << 3); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(n/8); // seg_stride
  cfg0.write(SIZE / 2 + 1 + m_s_offset); // seg_count
  int len_tmp = (SIZE + m_w_offset + m_e_offset + 8 - 1) / 8;
  if (m_w_offset == 4 && m_e_offset == 4)
    len_tmp += 1;
  cfg0.write(len_tmp); // len
  cfg0.write(1); // mode
}

void task01(hls::stream<ap_int<256>> &ss0_in,
            hls::stream<ap_int<32>>  &cfg0,
            int64_t mm01_0[SIZE / 4 + 1][(SIZE + 8)],
            int64_t mm01_1[SIZE / 4 + 1][(SIZE + 8)],
            int m_offset0,
            int m_n_offset, int m_s_offset, int m_w_offset, int m_e_offset,
            int m0_n_offset, int m0_w_offset, int m0_e_offset,
            int n, int i, int j) {
#pragma HLS INLINE OFF

  int f = 0;
  if (m_w_offset == 4)
    f = 1;
  int len_tmp = (SIZE + m_w_offset + m_e_offset + 8 - 1) / 8;
  if (m_w_offset == 4 && m_e_offset == 4)
    len_tmp += 1;

  int m0_offset_lo;
  m0_offset_lo = (m_offset0 + (i * n * SIZE - 1 * n + j * SIZE - m_w_offset) + n * SIZE / 2) / 8;
  //cfg0.write(((m_offset0 + (i * n * SIZE - 1 * n + j * SIZE - m_w_offset) + n * SIZE / 2) << 3)); // m0_offset_lo
  cfg0.write((m0_offset_lo * 8) << 3); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(n/8); // seg_stride
  cfg0.write(SIZE / 2 + 1 + m_s_offset); // seg_count
  cfg0.write(len_tmp); // len
  cfg0.write(1); // mode
  while (ss0_in.empty());
  for (int jj = 0; jj < SIZE / 2 + 1 + m_s_offset; jj++) {
    for (int ii = 0; ii < len_tmp * 2; ii++) {
      #pragma HLS PIPELINE
      #pragma HLS DEPENDENCE variable=mm01_0 inter false
      #pragma HLS DEPENDENCE variable=mm01_1 inter false
      //mm01[0 * (SIZE + 8) + m0_w_offset + jj * (SIZE + m_w_offset + m_e_offset + m0_w_offset + m0_e_offset) + ii] =
      //  m0[m_offset0 + (i * n * SIZE - 1 * n + j * SIZE - m_w_offset) + n * SIZE / 2 + jj * n + ii];
      //DATATYPE_IF tmp = m0[(m_offset0 + (i * n * SIZE - 1 * n + j * SIZE - m_w_offset) + n * SIZE / 2 + jj * n) / 4 + ii];
      DATATYPE_IF tmp = ss0_in.read();
      if ((m_w_offset == 0 && ii < len_tmp * 2 - 1) ||
          (m_w_offset == 4 && m_e_offset == 0 && ii > 0) ||
          (m_w_offset == 4 && m_e_offset == 4 && ii > 0 && ii < len_tmp * 2 - 1)) { 
      if (jj % 2 == 1) {
        mm01_0[jj/2][m0_w_offset + 4 * (ii - f) + 0] = tmp.range(64*1-1, 64*0);
        mm01_0[jj/2][m0_w_offset + 4 * (ii - f) + 1] = tmp.range(64*2-1, 64*1);
        mm01_0[jj/2][m0_w_offset + 4 * (ii - f) + 2] = tmp.range(64*3-1, 64*2);
        mm01_0[jj/2][m0_w_offset + 4 * (ii - f) + 3] = tmp.range(64*4-1, 64*3);
      } else {
        mm01_1[jj/2][m0_w_offset + 4 * (ii - f) + 0] = tmp.range(64*1-1, 64*0);
        mm01_1[jj/2][m0_w_offset + 4 * (ii - f) + 1] = tmp.range(64*2-1, 64*1);
        mm01_1[jj/2][m0_w_offset + 4 * (ii - f) + 2] = tmp.range(64*3-1, 64*2);
        mm01_1[jj/2][m0_w_offset + 4 * (ii - f) + 3] = tmp.range(64*4-1, 64*3);
      }
      }
    }
  }

}

void task10(hls::stream<ap_int<256>> &ss0_out,
            hls::stream<ap_int<32>>  &cfg0,
            int64_t mm10[SIZE * SIZE / 2],
            int m_offset1,
            int n, int i, int j) {
#pragma HLS INLINE OFF

  cfg0.write(((m_offset1 + (i * n * SIZE + j * SIZE)) << 3)); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(n/8); // seg_stride
  cfg0.write(SIZE / 2); // seg_count
  cfg0.write(SIZE / 8); // len
  cfg0.write(2); // mode
  while (ss0_out.full());
  for (int jj = 0; jj < SIZE / 2; jj++) {
    for (int ii = 0; ii < SIZE / 4; ii++) {
      #pragma HLS PIPELINE
      //m0[m_offset1 + (i * n * SIZE + j * SIZE) + jj * n + ii] = mm10[jj * SIZE + ii];
      DATATYPE_IF tmp;
      tmp.range(64*1-1, 64*0) = mm10[jj * SIZE + 4 * ii + 0];
      tmp.range(64*2-1, 64*1) = mm10[jj * SIZE + 4 * ii + 1];
      tmp.range(64*3-1, 64*2) = mm10[jj * SIZE + 4 * ii + 2];
      tmp.range(64*4-1, 64*3) = mm10[jj * SIZE + 4 * ii + 3];
      //m0[(m_offset1 + (i * n * SIZE + j * SIZE) + jj * n) / 4 + ii] = tmp;
      ss0_out.write(tmp);
    }
  }
}

void task11(hls::stream<ap_int<256>> &ss0_out,
            hls::stream<ap_int<32>>  &cfg0,
            int64_t mm11[SIZE * SIZE / 2],
            int m_offset1,
            int n, int i, int j) {
#pragma HLS INLINE OFF

  cfg0.write(((m_offset1 + (i * n * SIZE + j * SIZE + n * SIZE / 2)) << 3)); // m0_offset_lo
  cfg0.write(0); // m0_offset_hi
  cfg0.write(n/8); // seg_stride
  cfg0.write(SIZE / 2); // seg_count
  cfg0.write(SIZE / 8); // len
  cfg0.write(2); // mode
  while (ss0_out.full());
  for (int jj = 0; jj < SIZE / 2; jj++) {
    for (int ii = 0; ii < SIZE / 4; ii++) {
      #pragma HLS PIPELINE
      //m0[m_offset1 + (i * n * SIZE + j * SIZE + n * SIZE / 2) + jj * n + ii] = mm11[jj * SIZE + ii];
      DATATYPE_IF tmp;
      tmp.range(64*1-1, 64*0) = mm11[jj * SIZE + 4 * ii + 0];
      tmp.range(64*2-1, 64*1) = mm11[jj * SIZE + 4 * ii + 1];
      tmp.range(64*3-1, 64*2) = mm11[jj * SIZE + 4 * ii + 2];
      tmp.range(64*4-1, 64*3) = mm11[jj * SIZE + 4 * ii + 3];
      //m0[(m_offset1 + (i * n * SIZE + j * SIZE + n * SIZE / 2) + jj * n) / 4 + ii] = tmp;
      ss0_out.write(tmp);
    }
  }
}

void jacobi_2d_axi_sub(hls::stream<ap_int<256>> &ss0_in,
                       hls::stream<ap_int<256>> &ss0_out,
                       hls::stream<ap_int<32>>  &cfg0,
                       int n, int iter_no, int i, int j) {
#pragma HLS INLINE OFF

  int64_t mm00_0[SIZE / 4 + 1][(SIZE + 8)];
  int64_t mm00_1[SIZE / 4 + 1][(SIZE + 8)];

  int64_t mm01_0[SIZE / 4 + 1][(SIZE + 8)];
  int64_t mm01_1[SIZE / 4 + 1][(SIZE + 8)];

  int64_t mm10[SIZE * SIZE / 2];
  int64_t mm11[SIZE * SIZE / 2];


#pragma HLS bind_storage variable=mm00_0 type=ram_t2p impl=bram
#pragma HLS bind_storage variable=mm00_1 type=ram_t2p impl=bram
#pragma HLS bind_storage variable=mm01_0 type=ram_t2p impl=bram
#pragma HLS bind_storage variable=mm01_1 type=ram_t2p impl=bram
#pragma HLS bind_storage variable=mm10   type=ram_2p impl=bram
#pragma HLS bind_storage variable=mm11   type=ram_2p impl=bram

  int m_offset0, m_offset1;
  int t = iter_no;
  if (t % 2 == 0) {
    m_offset0 = 0;
    m_offset1 = n * n;
  } else {
    m_offset0 = n * n;
    m_offset1 = 0;
  }

  bool edge_w = (j == 0);
  bool edge_e = (j == (n / SIZE - 1));
  bool edge_n = (i == 0);
  bool edge_s = (i == (n / SIZE - 1));

  int m0_w_offset = 0;
  int m0_n_offset = 0;
  int m0_e_offset = 0;

  int m_w_offset = 4;
  int m_e_offset = 4;
  int m_n_offset = 1;
  int m_s_offset = 1;

  if (edge_w) {
    m0_w_offset = 4;
    m_w_offset = 0;
  }

  if (edge_n) {
    m0_n_offset = 1;
    m_n_offset = 0;
  }

  if (edge_e) {
    m0_e_offset = 4;
    m_e_offset = 0;
  }

  if (edge_s)
    m_s_offset = 0;

//  task00_ss_cfg_setup(cfg0, m_offset0, m_n_offset,
//    m_s_offset, m_w_offset, m_e_offset,
//    m0_n_offset, m0_w_offset, m0_e_offset, n, i, j);
//  task01_ss_cfg_setup(cfg0, m_offset0, m_n_offset,
//    m_s_offset, m_w_offset, m_e_offset,
//    m0_n_offset, m0_w_offset, m0_e_offset, n, i, j);
  task00(ss0_in, cfg0, mm00_0, mm00_1, m_offset0, m_n_offset, m_s_offset, m_w_offset, m_e_offset,
         m0_n_offset, m0_w_offset, m0_e_offset, n, i, j);
  task01(ss0_in, cfg0, mm01_0, mm01_1, m_offset0, m_n_offset, m_s_offset, m_w_offset, m_e_offset,
         m0_n_offset, m0_w_offset, m0_e_offset, n, i, j);
  jacobi_2d_compute0(mm00_0, mm00_1, mm10, edge_w, edge_e, edge_n, edge_s);
  jacobi_2d_compute1(mm01_0, mm01_1, mm11, edge_w, edge_e, edge_n, edge_s);
  task10(ss0_out, cfg0, mm10, m_offset1, n, i, j);
  task11(ss0_out, cfg0, mm11, m_offset1, n, i, j);
}

void jacobi_2d_axi(hls::stream<ap_int<256>> &ss0_in,
                   hls::stream<ap_int<256>> &ss0_out,
                   hls::stream<ap_int<32>>  &cfg0,
                   hls::stream<ap_int<256>> &ss1_in,
                   hls::stream<ap_int<256>> &ss1_out,
                   hls::stream<ap_int<32>>  &cfg1,
                   int n, int iter_no, int i, int j) {

#pragma HLS INTERFACE s_axilite port=return bundle=control
#pragma HLS INTERFACE s_axilite port=n bundle=control
#pragma HLS INTERFACE s_axilite port=iter_no bundle=control
#pragma HLS INTERFACE s_axilite port=i bundle=control
#pragma HLS INTERFACE s_axilite port=j bundle=control

  jacobi_2d_axi_sub(ss0_in, ss0_out, cfg0, n, iter_no, i, 2 * j + 0);
  jacobi_2d_axi_sub(ss1_in, ss1_out, cfg1, n, iter_no, i, 2 * j + 1);
}

void cl_jacobi_2d_sub(DATATYPE local_a0[SIZE / 4 + 1][(SIZE + 16) / 2],
                      DATATYPE local_a1[SIZE / 4 + 1][(SIZE + 16) / 2],
                      DATATYPE local_b0[SIZE / 4 + 1][(SIZE + 16) / 2],
                      DATATYPE local_b1[SIZE / 4 + 1][(SIZE + 16) / 2],
                      DATATYPE local_c0[SIZE * SIZE / 4],
                      DATATYPE local_c1[SIZE * SIZE / 4],
                      bool edge_w, bool edge_e,
                      bool edge_n, bool edge_s) {
  DATATYPE tmp_c0, tmp_w0, tmp_e0, tmp_n0, tmp_s0;
  DATATYPE tmp_c1, tmp_w1, tmp_e1, tmp_n1, tmp_s1;

  DATATYPE tmp_a = local_a0[0][4];
  DATATYPE tmp_b;
  for (int iijj = 0; iijj < (SIZE / 2) * SIZE; iijj+=2) {
    #pragma HLS PIPELINE II=1
    #pragma HLS DEPENDENCE variable=local_c0 inter false
    #pragma HLS DEPENDENCE variable=local_c1 inter false

    //#pragma HLS UNROLL factor=2
    int ii = 0 + (iijj / SIZE);
    int jj = 8 + (iijj % SIZE);
    if (ii % 2 == 0) {
      tmp_c0 =                                      tmp_a;
      tmp_w0 = (jj == 8            && edge_w) ? 0 : local_a1[ii/2][jj/2-1];
      tmp_e0 =                                      local_a1[ii/2][jj/2];
      tmp_n0 = (ii == 0            && edge_n) ? 0 : local_b0[ii/2][jj/2];
      tmp_s0 =                                      local_b0[ii/2+1][jj/2];

      tmp_c1 =                                      tmp_e0;
      tmp_w1 =                                      tmp_a;
      tmp_e1 = (jj + 2 == SIZE + 8 && edge_e) ? 0 : local_a0[ii/2][jj/2+1];
      tmp_n1 = (ii == 0            && edge_n) ? 0 : local_b1[ii/2][jj/2];
      tmp_s1 =                                      local_b1[ii/2+1][jj/2];

      local_c0[ii * SIZE/2 + (jj/2 - 4)] = (tmp_c0 + tmp_n0 + tmp_s0 + tmp_w0 + tmp_e0) / 5;
      local_c1[ii * SIZE/2 + (jj/2 - 4)] = (tmp_c1 + tmp_n1 + tmp_s1 + tmp_w1 + tmp_e1) / 5;

      tmp_a = tmp_e1;
      if (jj == 8)
        tmp_b = tmp_s0;
    } else {
      tmp_c0 =                                      tmp_b;
      tmp_w0 = (jj == 8            && edge_w) ? 0 : local_b1[ii/2+1][jj/2-1];
      tmp_e0 =                                      local_b1[ii/2+1][jj/2];
      tmp_n0 =                                      local_a0[ii/2][jj/2];
      tmp_s0 = (ii + 1 == SIZE / 2 && edge_s) ? 0 : local_a0[ii/2+1][jj/2];

      tmp_c1 =                                      tmp_e0;
      tmp_w1 =                                      tmp_b;
      tmp_e1 = (jj + 2 == SIZE + 8 && edge_e) ? 0 : local_b0[ii/2+1][jj/2+1];
      tmp_n1 =                                      local_a1[ii/2][jj/2];
      tmp_s1 = (ii + 1 == SIZE / 2 && edge_s) ? 0 : local_a1[ii/2+1][jj/2];

      local_c0[ii * SIZE/2 + (jj/2 - 4)] = (tmp_c0 + tmp_n0 + tmp_s0 + tmp_w0 + tmp_e0) / 5;
      local_c1[ii * SIZE/2 + (jj/2 - 4)] = (tmp_c1 + tmp_n1 + tmp_s1 + tmp_w1 + tmp_e1) / 5;

      tmp_b = tmp_e1;
      if (jj == 8)
        tmp_a = tmp_s0;
    }
  }
}

void cl_jacobi_2d(DATATYPE local_a0[SIZE / 4 + 1][(SIZE + 16) / 2],
                  DATATYPE local_a1[SIZE / 4 + 1][(SIZE + 16) / 2],
                  DATATYPE local_b0[SIZE / 4 + 1][(SIZE + 16) / 2],
                  DATATYPE local_b1[SIZE / 4 + 1][(SIZE + 16) / 2],
                  DATATYPE local_c0[SIZE * SIZE / 4],
                  DATATYPE local_c1[SIZE * SIZE / 4],

                  DATATYPE local_a2[SIZE / 4 + 1][(SIZE + 16) / 2],
                  DATATYPE local_a3[SIZE / 4 + 1][(SIZE + 16) / 2],
                  DATATYPE local_b2[SIZE / 4 + 1][(SIZE + 16) / 2],
                  DATATYPE local_b3[SIZE / 4 + 1][(SIZE + 16) / 2],
                  DATATYPE local_c2[SIZE * SIZE / 4],
                  DATATYPE local_c3[SIZE * SIZE / 4],

                  bool edge_w, bool edge_e,
                  bool edge_n, bool edge_s,
                  int pp) {
#pragma HLS INTERFACE mode=ap_memory port=local_a0 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a1 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b0 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b1 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_c0 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_c1 latency=3

#pragma HLS INTERFACE mode=ap_memory port=local_a2 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_a3 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b2 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_b3 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_c2 latency=3
#pragma HLS INTERFACE mode=ap_memory port=local_c3 latency=3

  cl_jacobi_2d_sub(local_a0, local_a1, local_b0, local_b1, local_c0, local_c1,
                   edge_w, 0, edge_n, edge_s);
  cl_jacobi_2d_sub(local_a2, local_a3, local_b2, local_b3, local_c2, local_c3,
                   0, edge_e, edge_n, edge_s);
}

