#include <iostream>
#include <cstring>
#include "matmul.h"

#define SIZE 1024

void init(DATATYPE *m, int size) {
  for (int i = 0; i < size; i++) {
    m[i] = (i % 10);
  }
}

void dma_read(DATATYPE *local, DATATYPE *global,
              int num_rows, int num_cols, int global_stride) {
  for (int i = 0; i < num_rows; i++) {
    for (int j = 0; j < num_cols; j++) {
      local[i * num_cols + j] = global[i * global_stride + j];
    }
  }
}

void dma_write(DATATYPE *local, DATATYPE *global,
               int num_rows, int num_cols, int global_stride) {
  for (int i = 0; i < num_rows; i++) {
    for (int j = 0; j < num_cols; j++) {
      global[i * global_stride + j] = local[i * num_cols + j];
    }
  }
}

void matmul_baseline(DATATYPE *a, DATATYPE *b, DATATYPE *c, int n) {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      DATATYPE tmp = 0;

      for (int k = 0; k < n; k++) {
        tmp += a[i * n + k] * b[k * n + j];
      }
      c[i * n + j] += tmp;
    }
  }
}

int main() {
  int n = SIZE;
  int m_len = n * n * 3;
  DATATYPE *m = new DATATYPE [m_len];

  DATATYPE *a = &m[0];
  DATATYPE *b = &m[n * n];
  DATATYPE *c = &m[n * n * 2];

  DATATYPE *c0 = new DATATYPE [n * n];

//  init(a, n * n);
//  init(b, n * n);
//  init(c, n * n);

  for (int i = 0; i < m_len; i++)
    m[i] = i;

  int verify_len = n * n * 3;
  for (int i = 0; i < verify_len; i++)
    std::cout << std::hex << m[i] << '\n';

  int a_offset = 0;
  int b_offset = 0;
  int c_offset = 0;

  memcpy(c0, c, n * n * sizeof(DATATYPE));

  int blk = 16; // block dim
  int u = 16;   // unroll

  DATATYPE *m0 = new DATATYPE [SIZE*SIZE];
  DATATYPE *m1 = new DATATYPE [SIZE*SIZE];
  DATATYPE *m2 = new DATATYPE [SIZE*SIZE];

  for (int i = 0; i < (n / blk); i++) {
    for (int j = 0; j < (n / blk); j++) {
      c_offset = i * n * blk + j * blk;
      dma_read(m2, c + c_offset, blk, blk, n);
      for (int k = 0; k < (n / u); k++) {
        a_offset = i * n * blk + k * u;
        b_offset = k * n * u   + j * blk;
        dma_read(m0, a + a_offset, blk, u, n);
        dma_read(m1, b + b_offset, u, blk, n);
//        matmul(m0, m1, m2, 0, 0, 0, blk);
        matmul_baseline(m0, m1, m2, blk);

      }
      dma_write(m2, c + c_offset, blk, blk, n);
    }
  }

  matmul_baseline(a, b, c0, n);

  // Check result
  int num_errs = 0;
  for (int i = 0; i < n * n; i++) {
    if (c[i] != c0[i])
      num_errs += 1;
  }

  if (num_errs == 0)
    std::cout << "PASSED!\n";
  else
    std::cout << "FAILED! Num. errors: " << num_errs << '\n';

  for (int i = 0; i < verify_len; i++)
    std::cout << std::hex << m[i] << '\n';

  return 0;
}
