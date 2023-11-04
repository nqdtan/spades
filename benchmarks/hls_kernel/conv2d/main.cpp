#include <iostream>
#include <cstring>
#include <iomanip>
#include <cmath>
#include "conv2d.h"
#define PAD 1
#define IFM_DIM 13
#define WT_DIM 3
#define OFM_DIM (IFM_DIM + 2 * PAD - WT_DIM + 1)

#define EPSILON 1e-5

void conv2d_baseline(DATATYPE *ifm, DATATYPE *ofm, DATATYPE *wt,
  int HIn, int WIn, int K, int stride, int pad) {

  int HOut = (HIn + 2 * pad - K + 1);
  int WOut = (WIn + 2 * pad - K + 1);

  for (int i = 0; i < HIn + 2 * pad - K + 1; i++) {
    for (int j = 0; j < WIn + 2 * pad - K + 1; j++) {
      DATATYPE tmp = ofm[i * WOut + j];
      for (int m = 0; m < K; m++) {
        for (int n = 0; n < K; n++) {
          int ii = i + m;
          int jj = j + n;
          DATATYPE ifm_data = (ii < pad || jj < pad || ii >= HIn + pad || jj >= WIn + pad) ? 0 : ifm[(ii - pad) * WIn + jj - pad];
          DATATYPE wt_data = wt[m * K + n];
          tmp += ifm_data * wt_data;
        }
      }
      ofm[i * WOut + j] = tmp;
    }
  }
}

int main() {
  srand(0);

  int wt_size  = ((WT_DIM * WT_DIM + 7) / 8) * 8;
  int ifm_size = ((IFM_DIM * IFM_DIM + 7) / 8) * 8;
  int ofm_size = ((OFM_DIM * OFM_DIM + 7) / 8) * 8;

  //int m_len = IFM_DIM * IFM_DIM + WT_DIM * WT_DIM + OFM_DIM * OFM_DIM;
  int m_len = wt_size + ifm_size + ofm_size;

  DATATYPE *m = new DATATYPE [m_len];
  for (int i = 0; i < m_len; i++)
    m[m_len] = 0;

  DATATYPE *wt  = &m[0];
  DATATYPE *ifm = &m[wt_size];
  DATATYPE *ofm = &m[wt_size + ifm_size];

  DATATYPE *ofm_gold = new DATATYPE [OFM_DIM * OFM_DIM];

  for (int i = 0; i < WT_DIM * WT_DIM; i++)
    wt[i] = i;

  for (int i = 0; i < IFM_DIM * IFM_DIM; i++)
    ifm[i] = i;

  for (int i = 0; i < OFM_DIM * OFM_DIM; i++)
    ofm[i] = i;

//  for (int i = 0; i < m_len; i++) {
//    m[i] = i;
//    //m[i] = i * 1.0f / (i + 1);
//    //m[i] = (rand() % n) * 1.0f / n;
//  }
  int verify_len = m_len;

//  for (int i = 0; i < verify_len; i+=2) {
//    std::cout <<
//      std::hex << std::setw(8) << std::setfill('0') << m[i + 1] <<
//      std::hex << std::setw(8) << std::setfill('0') << m[i] << '\n';
//  }

  for (int i = 0; i < verify_len; i+=2) {
    int tmp0 = *(reinterpret_cast<int*>(&m[i]));
    int tmp1 = *(reinterpret_cast<int*>(&m[i + 1]));

    std::cout <<
      std::hex << std::setw(8) << std::setfill('0') << tmp1 <<
      std::hex << std::setw(8) << std::setfill('0') << tmp0 << '\n';
  }

  memcpy(ofm_gold, ofm, OFM_DIM * OFM_DIM * sizeof(DATATYPE));

  int stride = 1;
  int pad = PAD;
//  conv2d(ifm, ofm, wt,
//    IFM_DIM, IFM_DIM, WT_DIM, stride, pad);

  conv2d_baseline(ifm, ofm, wt,
    IFM_DIM, IFM_DIM, WT_DIM, stride, pad);

  conv2d_baseline(ifm, ofm_gold, wt,
    IFM_DIM, IFM_DIM, WT_DIM, stride, pad);

  // Check result
  int num_errs = 0;
  for (int i = 0; i < OFM_DIM * OFM_DIM; i++) {
    if (abs(ofm[i] - ofm_gold[i]) > EPSILON) {
      num_errs += 1;
      //std::cout << "err at i=" << i << " ofm=" << ofm[i] << ", ofm_gold=" << ofm_gold[i] << '\n';
    }
  }

//  for (int i = 0; i < 20; i++) {
//    std::cout << "i = " << i << ": ofm = " << ofm[i] << ", ofm_gold = " << ofm_gold[i] << '\n';
//  }

  if (num_errs == 0)
    std::cout << "PASSED!\n";
  else
    std::cout << "FAILED! Num. errors: " << num_errs << '\n';

//  for (int i = 0; i < verify_len; i+=2) {
//    std::cout <<
//      std::hex << std::setw(8) << std::setfill('0') << m[i + 1] <<
//      std::hex << std::setw(8) << std::setfill('0') << m[i] << '\n';
//  }

  for (int i = 0; i < verify_len; i+=2) {
    int tmp0 = *(reinterpret_cast<int*>(&m[i]));
    int tmp1 = *(reinterpret_cast<int*>(&m[i + 1]));

    std::cout <<
      std::hex << std::setw(8) << std::setfill('0') << tmp1 <<
      std::hex << std::setw(8) << std::setfill('0') << tmp0 << '\n';
  }

  delete(m);
  delete(ofm_gold);
  return 0;
}
