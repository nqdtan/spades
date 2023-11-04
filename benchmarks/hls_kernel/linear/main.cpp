#include <iostream>
#include <cstring>
#include <iomanip>
#include <cmath>
#include "linear.h"
#define IFM0_LEN 128
#define OFM0_LEN 256
#define EPSILON 1e-5

void linear_baseline(DATATYPE *ifm, DATATYPE *ofm, DATATYPE *wt,
  int ifm_len, int ofm_len) {

  for (int c = 0; c < ofm_len; c++) {
    DATATYPE tmp = 0;
    for (int i = 0; i < ifm_len; i++) {
      tmp += ifm[i] * wt[c * ifm_len + i];
    }
    ofm[c] = tmp;
  }
}

int main() {
  srand(0);

  int wt0_len  = OFM0_LEN * IFM0_LEN;
  int ifm0_len = IFM0_LEN;
  int ofm0_len = OFM0_LEN;
  int m_len = wt0_len + ifm0_len + ofm0_len;

  DATATYPE *m = new DATATYPE [m_len];
  for (int i = 0; i < m_len; i++)
    m[m_len] = 0;

  DATATYPE *wt0  = &m[0];
  DATATYPE *ifm0 = &m[wt0_len];
  DATATYPE *ofm0 = &m[wt0_len + ifm0_len];

  DATATYPE *ofm0_gold = new DATATYPE [ofm0_len];

  int value;

  value = 0;
  for (int t = 0; t < OFM0_LEN; t++) {
    for (int i = 0; i < IFM0_LEN; i++) {
      //wt0[t * ifm0_len + i] = value;
      wt0[t * ifm0_len + i] = (rand() % IFM0_LEN) * 1.0f / IFM0_LEN;
      value++;
    }
  }

  value = 0;
  for (int i = 0; i < IFM0_LEN; i++) {
    //ifm0[i] = value;
    ifm0[i] = (rand() % IFM0_LEN) * 1.0f / IFM0_LEN;
    value++;
  }

  value = 0;
  for (int i = 0; i < OFM0_LEN; i++) {
    ofm0[i] = 0;//value;
    //ofm0[i] = (rand() % OFM0_LEN) * 1.0f / OFM0_LEN;
    value++;
  }

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

  linear_baseline(ifm0, ofm0, wt0, ifm0_len, ofm0_len);
  linear_baseline(ifm0, ofm0_gold, wt0, ifm0_len, ofm0_len);

  // Check result
  int num_errs = 0;
  for (int i = 0; i < ofm0_len; i++) {
    if (abs(ofm0[i] - ofm0_gold[i]) > EPSILON) {
      num_errs += 1;
      //std::cout << "err at i=" << i << " ofm=" << ofm[i] << ", ofm0_gold=" << ofm0_gold[i] << '\n';
    }
  }

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
  return 0;
}
