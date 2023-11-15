#include <iostream>
#include <cstring>
#include <iomanip>
#include <bits/stdc++.h>
#include <cmath>
#include <sstream>
#include "linear.h"
#define IFM_LEN 32
#define OFM_LEN 128
#define EPSILON 1e-5

class linear_app {
  public:
    int ifm_len, ofm_len;

    void linear_baseline(DATATYPE *ifm, DATATYPE *ofm, DATATYPE *wt,
      int ifm_len, int ofm_len) {
      int ifm_len_ceil = ((ifm_len + 15) / 16) * 16;

      for (int c = 0; c < ofm_len; c++) {
        DATATYPE tmp = 0;
        for (int i = 0; i < ifm_len; i++) {
          tmp += ifm[i] * wt[c * ifm_len_ceil + i];
        }
        ofm[c] = tmp;
      }
    }

    void run() {
      linear_baseline(ifm, ofm, wt, ifm_len, ofm_len);
      linear_baseline(ifm, ofm_gold, wt, ifm_len, ofm_len);

      int num_errs = 0;
      for (int i = 0; i < ofm_len; i++) {
        if (abs(ofm[i] - ofm_gold[i]) > EPSILON) {
          num_errs += 1;
          //std::cout << "err at i=" << i << " ofm=" << ofm[i] << ", ofm_gold=" << ofm_gold[i] << '\n';
        }
      }
      if (num_errs == 0)
        std::cout << "PASSED!\n";
      else
        std::cout << "FAILED! Num. errors: " << num_errs << '\n';
    }

    linear_app(int _ifm_len, int _ofm_len) :
          ifm_len(_ifm_len), ofm_len(_ofm_len) {

      int ifm_len_ceil = ((ifm_len + 15) / 16) * 16;
      int ofm_len_ceil = ((ofm_len + 15) / 16) * 16;
      wt_len  = ifm_len_ceil * ofm_len;

      m_len = wt_len + ifm_len_ceil + ofm_len_ceil;

      m = new DATATYPE [m_len];
      //m = std::make_unique<DATATYPE[]>(m_len).get();
      for (int i = 0; i < m_len; i++)
        m[m_len] = 0;

      wt  = &m[0];
      ifm = &m[wt_len];
      ofm = &m[wt_len + ifm_len_ceil];

      ofm_gold = new DATATYPE [ofm_len];
      //ofm_gold = std::make_unique<DATATYPE[]>(ofm_len).get();

      init_wt(wt, ifm_len, ofm_len);
      init_ifm(ifm, ifm_len);
      init_ofm(ofm, ofm_len);

      memcpy(ofm_gold, ofm, ofm_len * sizeof(DATATYPE));
    }

    void init_wt(float *wt, int ifm_len, int ofm_len) {
      int ifm_len_ceil = ((ifm_len + 15) / 16) * 16;
      for (int t = 0; t < ofm_len; t++) {
        for (int i = 0; i < ifm_len; i++) {
          wt[t * ifm_len_ceil + i] = (rand() % ifm_len) * 1.0f / ifm_len;
        }
      }
    }

    void init_wt(int *wt, int ifm_len, int ofm_len) {
      int ifm_len_ceil = ((ifm_len + 15) / 16) * 16;
      int value = 0;
      for (int t = 0; t < ofm_len; t++) {
        //value = 0;
        for (int i = 0; i < ifm_len; i++) {
          wt[t * ifm_len_ceil + i] = value;
          value++;
        }
      }
    }

    void init_ifm(float *ifm, int ifm_len) {
      for (int i = 0; i < ifm_len; i++) {
        ifm[i] = (rand() % ifm_len) * 1.0f / ifm_len;
      }
    }

    void init_ifm(int *ifm, int ifm_len) {
      int value = 0;
      for (int i = 0; i < ifm_len; i++) {
        ifm[i] = value;
        value++;
      }
    }

    void init_ofm(float *ofm, int ofm_len) {
      for (int i = 0; i < ofm_len; i++) {
        ofm[i] = 0;//(rand() % ofm_len) * 1.0f / ofm_len;
      }
    }

    void init_ofm(int *ofm, int ofm_len) {
      int value = 0;
      for (int i = 0; i < ofm_len; i++) {
        ofm[i] = 0;//value;
        value++;
      }
    }

    void print_m(float *m, std::string file_name) {
      std::ofstream cout(file_name);
      int verify_len = m_len;
      for (int i = 0; i < verify_len; i+=2) {
        int tmp0 = *(reinterpret_cast<int*>(&m[i]));
        int tmp1 = *(reinterpret_cast<int*>(&m[i + 1]));

        cout <<
          std::hex << std::setw(8) << std::setfill('0') << tmp1 <<
          std::hex << std::setw(8) << std::setfill('0') << tmp0 << '\n';
      }
    }

    void print_m(int *m, std::string file_name) {
      std::ofstream cout(file_name);
      int verify_len = m_len;
      for (int i = 0; i < verify_len; i+=2) {
        cout <<
          std::hex << std::setw(8) << std::setfill('0') << m[i + 1] <<
          std::hex << std::setw(8) << std::setfill('0') << m[i] << '\n';
      }
    }

    void print_m(std::string stage) {
      std::ostringstream oss;
      int file_length = m_len / (8 / sizeof(DATATYPE)); // each line contains 64-bit
      oss << "linear_" << stage << ".mif." << file_length;
      print_m(m, oss.str());
    }

    linear_app() = default;

    ~linear_app() {
      delete[] m;
      delete[] ofm_gold;
    }

  private:
    int m_len;
    int wt_len;
    DATATYPE *m;
    DATATYPE *wt, *ifm, *ofm;
    DATATYPE *ofm_gold;
};

int main() {
  srand(0);

  linear_app test{IFM_LEN, OFM_LEN};
  test.print_m("init");
  test.run();
  test.print_m("result");
  return 0;
}
