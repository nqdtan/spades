#include <iostream>
#include <cstring>
#include <iomanip>
#include <cmath>
#include "conv3d.h"
#define PAD 1
#define IFM0_DIM 13
#define WT0_DIM 3
#define OFM0_DIM (IFM0_DIM + 2 * PAD - WT0_DIM + 1)
#define IFM0_CHN 2//32
#define OFM0_CHN 2//16
#define P0_DIM 3

//#define IFM1_DIM 13
//#define WT1_DIM 3
//#define OFM1_DIM (IFM1_DIM + 2 * PAD - WT1_DIM + 1)
//#define IFM1_CHN 16
//#define OFM1_CHN 8

#define IFM1_DIM (OFM0_DIM)
#define WT1_DIM 0
#define P1_DIM 3
#define OFM1_DIM (IFM1_DIM / 2)
#define IFM1_CHN (OFM0_CHN)
#define OFM1_CHN (IFM1_CHN)

#define STREAM 1

#define EPSILON 1e-5

void maxpool_baseline(DATATYPE *ifm, DATATYPE *ofm,
  int HIn, int WIn, int C, int P, int ifm_size, int ofm_size,
  int stride) {

  int HOut = HIn / 2;
  int WOut = WIn / 2;

  for (int c = 0; c < C; c++) {
    for (int i = 0; i < HIn - P + 1; i+=2) {
      for (int j = 0; j < WIn - P + 1; j+=2) {
        DATATYPE max_value = ifm[c * ifm_size + i * WIn + j];
        for (int m = 0; m < P; m++) {
          for (int n = 0; n < P; n++) {
            int ii = i + m;
            int jj = j + n;
            if (ifm[c * ifm_size + ii * WIn + jj] > max_value)
              max_value = ifm[c * ifm_size + ii * WIn + jj];
          }
        }
        ofm[c * ofm_size + (i / 2) * WOut + (j / 2)] = max_value;
      }
    }
  }
}

void conv3d_baseline(DATATYPE *ifm, DATATYPE *ofm, DATATYPE *wt,
  int HIn, int WIn, int CIn, int COut, int K, int P, int ifm_size, int wt_size, int ofm_size,
  int stride, int pad, bool relu, bool maxpool) {

  int HOut = (HIn + 2 * pad - K + 1);
  int WOut = (WIn + 2 * pad - K + 1);

  for (int co = 0; co < COut; co++) {
    for (int ci = 0; ci < CIn; ci++) {
      for (int i = 0; i < HIn + 2 * pad - K + 1; i++) {
        for (int j = 0; j < WIn + 2 * pad - K + 1; j++) {
          DATATYPE tmp = 0;
          for (int m = 0; m < K; m++) {
            for (int n = 0; n < K; n++) {
              int ii = i + m;
              int jj = j + n;
              DATATYPE ifm_data = (ii < pad || jj < pad || ii >= HIn + pad || jj >= WIn + pad) ? 0 :
                ifm[ci * ifm_size + (ii - pad) * WIn + jj - pad];
              DATATYPE wt_data = wt[co * CIn * wt_size + ci * wt_size + m * K + n];
              tmp += ifm_data * wt_data;
            }
          }
          ofm[co * ofm_size + i * WOut + j] += tmp;
        }
      }
    }

    if (relu) {
      for (int i = 0; i < HOut; i++) {
        for (int j = 0; j < WOut; j++) {
          if (ofm[co * ofm_size + i * WOut + j] < 0)
            ofm[co * ofm_size + i * WOut + j] = 0;
        }
      }
    }
  }

  if (maxpool)
    maxpool_baseline(ofm, ofm, HOut, WOut, COut, P, ifm_size, ifm_size, stride);
}

int main() {
  srand(0);

  int wt0_size  = ((WT0_DIM * WT0_DIM + 7) / 8) * 8;
  int ifm0_size = ((IFM0_DIM * IFM0_DIM + 7) / 8) * 8;
  int ofm0_size = ((OFM0_DIM * OFM0_DIM + 7) / 8) * 8;
//  int wt1_size  = ((WT1_DIM * WT1_DIM + 7) / 8) * 8;
//  int ifm1_size = ((IFM1_DIM * IFM1_DIM + 7) / 8) * 8;
//  int ofm1_size = ((OFM1_DIM * OFM1_DIM + 7) / 8) * 8;

  int wt0_len  = OFM0_CHN * IFM0_CHN * wt0_size; 
  int ifm0_len = IFM0_CHN * ifm0_size;
  int ofm0_len = OFM0_CHN * ofm0_size;
//  int wt1_len  = OFM1_CHN * IFM1_CHN * wt1_size; 
//  int ifm1_len = IFM1_CHN * ifm1_size;
//  int ofm1_len = OFM1_CHN * ofm1_size;

  int m_len = wt0_len + ifm0_len + ofm0_len;// + wt1_len + ofm1_len;

  DATATYPE *m = new DATATYPE [m_len];
  for (int i = 0; i < m_len; i++)
    m[m_len] = 0;

  DATATYPE *wt0  = &m[0];
  DATATYPE *ifm0 = &m[wt0_len];
  DATATYPE *ofm0 = &m[wt0_len + ifm0_len];

//  DATATYPE *wt1  = &m[wt0_len + ifm0_len + ofm0_len];
//  DATATYPE *ofm1 = &m[wt0_len + ifm0_len + ofm0_len + wt1_len];

  DATATYPE *ofm0_gold = new DATATYPE [ofm0_len];
//  DATATYPE *ofm1_gold = new DATATYPE [ofm1_len];

  int value;

  value = 0;
  for (int t = 0; t < OFM0_CHN * IFM0_CHN; t++) {
    for (int i = 0; i < WT0_DIM * WT0_DIM; i++) {
      //wt0[t * wt0_size + i] = value;
      wt0[t * wt0_size + i] = (rand() % (WT0_DIM * WT0_DIM)) * 1.0f / (WT0_DIM * WT0_DIM);
      value++;
    }
  }

  value = 0;
  for (int t = 0; t < IFM0_CHN; t++) {
    for (int i = 0; i < IFM0_DIM * IFM0_DIM; i++) {
      //ifm0[t * ifm0_size + i] = value;
      ifm0[t * ifm0_size + i] = (rand() % (IFM0_DIM * IFM0_DIM)) * 1.0f / (IFM0_DIM * IFM0_DIM);
      value++;
    }
  }

  value = 0;
  for (int t = 0; t < OFM0_CHN; t++) {
    for (int i = 0; i < OFM0_DIM * OFM0_DIM; i++) {
      //ofm0[t * ofm0_size + i] = value;
      ofm0[t * ofm0_size + i] = (rand() % (OFM0_DIM * OFM0_DIM)) * 1.0f / (OFM0_DIM * OFM0_DIM);
      value++;
    }
  }

//  value = 0;
//  for (int t = 0; t < OFM1_CHN * IFM1_CHN; t++) {
//    for (int i = 0; i < WT1_DIM * WT1_DIM; i++) {
//      wt1[t * wt1_size + i] = value;
//      value++;
//      //wt1[t * wt1_size + i] = (rand() % (WT1_DIM * WT1_DIM)) * 1.0f / (WT1_DIM * WT1_DIM);
//    }
//  }
//
//  value = 0;
//  for (int t = 0; t < OFM1_CHN; t++) {
//    for (int i = 0; i < OFM1_DIM * OFM1_DIM; i++) {
//      ofm1[t * ofm1_size + i] = 0;//value;
//      value++;
//      //ofm1[t * ofm1_size + i] = (rand() % (OFM1_DIM * OFM1_DIM)) * 1.0f / (OFM1_DIM * OFM1_DIM);
//    }
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

  memcpy(ofm0_gold, ofm0, ofm0_len * sizeof(DATATYPE));
//  memcpy(ofm1_gold, ofm1, ofm1_len * sizeof(DATATYPE));

  int stride = 1;
  int pad = PAD;

//  conv3d_baseline(ifm0, ofm0, wt0,
//    IFM0_DIM, IFM0_DIM, IFM0_CHN, OFM0_CHN, WT0_DIM, ifm0_size, wt0_size, ofm0_size, stride, pad, false, false);
//  conv3d_baseline(ofm0, ofm1, wt1,
//    IFM1_DIM, IFM1_DIM, IFM1_CHN, OFM1_CHN, WT1_DIM, ifm1_size, wt1_size, ofm1_size, stride, pad, false, false);
//
//#ifdef STREAM
//  // only check the final layer (stream)
//  memcpy(ofm0, ofm0_gold, ofm0_len * sizeof(DATATYPE));
//#endif
//
//  conv3d_baseline(ifm0, ofm0_gold, wt0,
//    IFM0_DIM, IFM0_DIM, IFM0_CHN, OFM0_CHN, WT0_DIM, ifm0_size, wt0_size, ofm0_size, stride, pad, false, false);
//  conv3d_baseline(ofm0_gold, ofm1_gold, wt1,
//    IFM1_DIM, IFM1_DIM, IFM1_CHN, OFM1_CHN, WT1_DIM, ifm1_size, wt1_size, ofm1_size, stride, pad, false, false);

  conv3d_baseline(ifm0, ofm0, wt0,
    IFM0_DIM, IFM0_DIM, IFM0_CHN, OFM0_CHN, WT0_DIM, P0_DIM, ifm0_size, wt0_size, ofm0_size, stride, pad, false, true);
//  maxpool_baseline(ofm0, ofm1,
//    IFM1_DIM, IFM1_DIM, IFM1_CHN, P1_DIM, ifm1_size, ofm1_size, stride);

#ifdef STREAM
  // only check the final layer (stream)
//  memcpy(ofm0, ofm0_gold, ofm0_len * sizeof(DATATYPE));
#endif

  conv3d_baseline(ifm0, ofm0_gold, wt0,
    IFM0_DIM, IFM0_DIM, IFM0_CHN, OFM0_CHN, WT0_DIM, P0_DIM, ifm0_size, wt0_size, ofm0_size, stride, pad, false, true);
//  maxpool_baseline(ofm0_gold, ofm1_gold,
//    IFM1_DIM, IFM1_DIM, IFM1_CHN, P1_DIM, ifm1_size, ofm1_size, stride);

  // Check result
  int num_errs = 0;
  for (int i = 0; i < ofm0_len; i++) {
    if (abs(ofm0[i] - ofm0_gold[i]) > EPSILON) {
      num_errs += 1;
      //std::cout << "err at i=" << i << " ofm=" << ofm[i] << ", ofm0_gold=" << ofm0_gold[i] << '\n';
    }
  }
//  for (int i = 0; i < ofm1_len; i++) {
//    if (abs(ofm1[i] - ofm1_gold[i]) > EPSILON) {
//      num_errs += 1;
//      std::cout << "err at i=" << std::dec << i << std::hex << " ofm1=" << ofm1[i] << ", ofm1_gold=" << ofm1_gold[i] << '\n';
//    }
//  }

//  for (int i = 0; i < 20; i++) {
//    std::cout << "i = " << i << ": ofm = " << ofm[i] << ", ofm1_gold = " << ofm1_gold[i] << '\n';
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
  delete(ofm0_gold);
//  delete(ofm1_gold);
  return 0;
}
