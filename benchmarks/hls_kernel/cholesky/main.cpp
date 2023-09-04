#include <iostream>
#include <cstring>
#include <cmath>
#include "cholesky.h"

void init(DATATYPE *m, int num_rows, int num_cols) {
  for (int i = 0; i < num_rows; i++) {
    for (int j = 0; j < num_cols; j++) {
      if (i == j)
        m[i * num_cols + j] = 256.0;
      else if (i > j)
        m[i * num_cols + j] = (i * num_cols + j) % 10 + 1;
    }
  }
  for (int i = 0; i < num_rows; i++) {
    for (int j = 0; j < num_cols; j++) {
      if (i < j)
        m[i * num_cols + j] = m[j * num_cols + i];
    }
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

void cholesky_baseline(DATATYPE *m0, int n) {
  DATATYPE *a = m0;
  DATATYPE *l = m0 + n * n;

  for (int j = 0; j < 16; j++) {
//  for (int j = 0; j < n; j++) {
    DATATYPE tmp0 = 0.0;
    for (int k = 0; k < j; k++) {
      tmp0 += l[j * n + k] * l[j * n + k];
    }

//    l[j * n + j] = sqrt(a[j * n + j] - tmp0);
    l[j * n + j] = (a[j * n + j] - tmp0);

    for (int i = j + 1; i < n; i++) {
      DATATYPE tmp1 = 0.0;
      for (int k = 0; k < j; k++) {
        tmp1 += l[i * n + k] * l[j * n + k];
      }

//      l[i * n + j] = (a[i * n + j] - tmp1) / l[j * n + j];
      l[i * n + j] = (a[i * n + j] - tmp1) * l[j * n + j];

    }
  }
}

int main() {
  int n = 1024;

  DATATYPE *m0 = new DATATYPE [n * n * 2];
  DATATYPE *gold = new DATATYPE [n * n * 2];

  init(m0, n, n);

  for (int i = n * n; i < 2 * n * n; i++) {
    m0[i] = 0.0;
  }

  memcpy(gold, m0, n * n * 2 * sizeof(DATATYPE));

  for (int i = 0; i < 2 * n * n; i++)
    std::cout << std::hex << m0[i] << '\n';

  cholesky_baseline(m0, n);
  cholesky_baseline(gold, n);

  // Check result
  int num_errs = 0;
  for (int i = n * n; i < 2 * n * n; i++) {
    if (abs(m0[i] - gold[i]) > 1e-10) {
      num_errs += 1;
    }
  }

  if (num_errs == 0)
    std::cout << "PASSED!\n";
  else
    std::cout << "FAILED! Num. errors: " << num_errs << '\n';

  for (int i = 0; i < 2 * n * n; i++)
    std::cout << std::hex << m0[i] << '\n';

  return 0;
}
