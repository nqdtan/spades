#include <iostream>
#include <cstring>
#include <iomanip>
#include <bits/stdc++.h>
#include <cmath>
#include <sstream>
#include "conv3d.h"

#define STRIDE 1
#define PAD 1
#define IFM_DIM 13
#define WT_DIM 3
#define IFM_CHN 36
#define OFM_CHN 16
#define P_DIM 3

#define EPSILON 1e-5

class conv3d_app {
  public:
    int ifm_dim, wt_dim, p_dim, ifm_chn, ofm_chn;
    int stride, pad;

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

      int HOut = (HIn + 2 * pad - K) / stride + 1;
      int WOut = (WIn + 2 * pad - K) / stride + 1;

      for (int co = 0; co < COut; co++) {
        for (int ci = 0; ci < CIn; ci++) {
          for (int i = 0; i < HIn + 2 * pad - K + 1; i+=stride) {
            for (int j = 0; j < WIn + 2 * pad - K + 1; j+=stride) {
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
              ofm[co * ofm_size + (i / stride) * WOut + (j / stride)] += tmp;
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

    void run(bool relu, bool maxpool) {
      conv3d_baseline(ifm, ofm, wt,
        ifm_dim, ifm_dim, ifm_chn, ofm_chn,
        wt_dim, p_dim, ifm_size, wt_size, ofm_size,
        stride, pad, relu, maxpool);

      conv3d_baseline(ifm, ofm_gold, wt,
        ifm_dim, ifm_dim, ifm_chn, ofm_chn,
        wt_dim, p_dim, ifm_size, wt_size, ofm_size,
        stride, pad, relu, maxpool);

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

    conv3d_app(int _ifm_dim, int _wt_dim, int _p_dim,
        int _ifm_chn, int _ofm_chn,
        int _stride, int _pad) :
          ifm_dim(_ifm_dim), wt_dim(_wt_dim), p_dim(_p_dim),
          ifm_chn(_ifm_chn), ofm_chn(_ofm_chn), stride(_stride), pad(_pad) {

      ofm_dim = ((ifm_dim + 2 * pad - wt_dim) / stride) + 1;
      wt_size  = ((wt_dim * wt_dim + 15) / 16) * 16;
      ifm_size = ((ifm_dim * ifm_dim + 15) / 16) * 16;
      ofm_size = ((ofm_dim * ofm_dim + 15) / 16) * 16;

      wt_len  = ofm_chn * ifm_chn * wt_size; 
      ifm_len = ifm_chn * ifm_size;
      ofm_len = ofm_chn * ofm_size;

      m_len = wt_len + ifm_len + ofm_len;

      m = new DATATYPE [m_len];
      //m = std::make_unique<DATATYPE[]>(m_len).get();
      for (int i = 0; i < m_len; i++)
        m[m_len] = 0;

      wt  = &m[0];
      ifm = &m[wt_len];
      ofm = &m[wt_len + ifm_len];

      ofm_gold = new DATATYPE [ofm_len];
      //ofm_gold = std::make_unique<DATATYPE[]>(ofm_len).get();

      init_wt(wt, ofm_chn, ifm_chn, wt_dim, wt_size);
      init_ifm(ifm, ifm_chn, ifm_dim, ifm_size);
      init_ofm(ofm, ofm_chn, ofm_dim, ofm_size);

      memcpy(ofm_gold, ofm, ofm_len * sizeof(DATATYPE));
    }

    void init_wt(float *wt, int ofm_chn, int ifm_chn, int wt_dim, int wt_size) {
      for (int t = 0; t < ofm_chn * ifm_chn; t++) {
        for (int i = 0; i < wt_dim * wt_dim; i++) {
          wt[t * wt_size + i] = (rand() % (wt_dim * wt_dim)) * 1.0f / (wt_dim * wt_dim);
        }
      }
    }

    void init_wt(int *wt, int ofm_chn, int ifm_chn, int wt_dim, int wt_size) {
      int value = 0;
      for (int t = 0; t < ofm_chn * ifm_chn; t++) {
        for (int i = 0; i < wt_dim * wt_dim; i++) {
          wt[t * wt_size + i] = value;
          value++;
        }
      }
    }

    void init_ifm(float *ifm, int ifm_chn, int ifm_dim, int ifm_size) {
      for (int t = 0; t < ifm_chn; t++) {
        for (int i = 0; i < ifm_dim * ifm_dim; i++) {
          ifm[t * ifm_size + i] = (rand() % (ifm_dim * ifm_dim)) * 1.0f / (ifm_dim * ifm_dim);
        }
      }
    }

    void init_ifm(int *ifm, int ifm_chn, int ifm_dim, int ifm_size) {
      int value = 0;
      for (int t = 0; t < ifm_chn; t++) {
        for (int i = 0; i < ifm_dim * ifm_dim; i++) {
          ifm[t * ifm_size + i] = value;
          value++;
        }
      }
    }

    void init_ofm(float *ofm, int ofm_chn, int ofm_dim, int ofm_size) {
      for (int t = 0; t < ofm_chn; t++) {
        for (int i = 0; i < ofm_dim * ofm_dim; i++) {
          ofm[t * ofm_size + i] = (rand() % (ofm_dim * ofm_dim)) * 1.0f / (ofm_dim * ofm_dim);
        }
      }
    }

    void init_ofm(int *ofm, int ofm_chn, int ofm_dim, int ofm_size) {
      int value = 0;
      for (int t = 0; t < ofm_chn; t++) {
        for (int i = 0; i < ofm_dim * ofm_dim; i++) {
          ofm[t * ofm_size + i] = value;
          value++;
        }
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
      oss << "conv3d_" << stage << ".mif." << file_length;
      print_m(m, oss.str());
    }

    conv3d_app() = default;

    ~conv3d_app() {
      delete[] m;
      delete[] ofm_gold;
    }

  private:
    int m_len;
    int ofm_dim;
    int wt_size, ifm_size, ofm_size;
    int wt_len, ifm_len, ofm_len;
    DATATYPE *m;
    DATATYPE *wt, *ifm, *ofm;
    DATATYPE *ofm_gold;
};

int main() {
  srand(0);

  conv3d_app test{IFM_DIM, WT_DIM, P_DIM, IFM_CHN, OFM_CHN, STRIDE, PAD};
  bool relu = false;
  bool maxpool = false;
  test.print_m("init");
  test.run(relu, maxpool);
  test.print_m("result");
  return 0;
}
