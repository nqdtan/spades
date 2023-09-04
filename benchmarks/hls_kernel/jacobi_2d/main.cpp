#include <iostream>
#include <cstring>
#include <jacobi_2d.h>

void init(DATATYPE *m, int num_cols, int num_rows) {
  for (int i = 0; i < num_rows; i++) {
    for (int j = 0; j < num_cols; j++) {
      m[i * num_cols + j] = (i * num_cols + j);// % 10;
    }
  }
}

void dma_read(DATATYPE *local, DATATYPE *global,
              int len, int stride, int offset,
              int seg_stride, int seg_count) {
  for (int j = 0; j < seg_count; j++) {
    for (int i = 0; i < len; i++) {
      local[i * stride + j * (len + offset)] = global[i + j * seg_stride];
    }
  }
}

void dma_write(DATATYPE *local, DATATYPE *global,
               int len, int stride, int offset,
               int seg_stride, int seg_count) {
  for (int j = 0; j < seg_count; j++) {
    for (int i = 0; i < len; i++) {
      global[i + j * seg_stride] = local[i * stride + j * (len + offset)];
    }
  }
}

// 5-point stencil
void jacobi_2d_baseline(DATATYPE *m0, DATATYPE *m1, int n, int num_iters) {

  DATATYPE *a, *b;
  for (int k = 0; k < num_iters; k++) {
    if (k % 2 == 0) {
      a = m0;
      b = m1;
    } else {
      a = m1;
      b = m0;
    }

    //for (int i = 64; i < 128; i++) {
    //  for (int j = 0; j < 64; j++) {
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        DATATYPE tmp_m = a[(i + 0) * n + (j + 0)];
        DATATYPE tmp_n = (j - 1 >= 0) ? a[(i + 0) * n + (j - 1)] : 0;
        DATATYPE tmp_s = (j + 1 <  n) ? a[(i + 0) * n + (j + 1)] : 0;
        DATATYPE tmp_w = (i - 1 >= 0) ? a[(i - 1) * n + (j + 0)] : 0;
        DATATYPE tmp_e = (i + 1 <  n) ? a[(i + 1) * n + (j + 0)] : 0;
        b[(i + 0) * n + (j + 0)] = (tmp_m + tmp_n + tmp_s + tmp_w + tmp_e) / 5;
      }
    }
  }
}

int main() {
  int n = 128;
  int num_iters = 2;

  DATATYPE *m = new DATATYPE [2 * n * n];

  DATATYPE *gold = new DATATYPE [2 * n * n];

  init(m, n, n);

  for (int i = 0; i < 2 * n * n; i++)
    std::cout << std::hex << m[i] << '\n';

  memcpy(gold, m, n * n * sizeof(DATATYPE));

  int blk = 64; // block dim

  jacobi_2d_baseline(gold, gold + n * n, n, num_iters);

  // Check result
  int num_errs = 0;
  for (int i = 0; i < 2 * n * n; i++) {
    if (m[i] != gold[i]) {
      num_errs += 1;
    }
  }

  if (num_errs == 0)
    std::cout << "PASSED!\n";
  else
    std::cout << "FAILED! Num. errors: " << std::dec << num_errs << '\n';

  for (int i = 0; i < 2 * n * n; i++)
    std::cout << std::hex << gold[i] << '\n';

  return 0;
}
