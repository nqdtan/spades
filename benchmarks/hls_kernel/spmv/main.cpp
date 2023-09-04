#include <iostream>
#include <cstring>
#include <time.h>
#include "spmv.h"

//#define DEBUG 1

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

void spmv_baseline(DATATYPE *m0, int n) {
  // Compressed-Sparse Row
  DATATYPE *val = m0;
  DATATYPE *ind = m0 + n * n;
  DATATYPE *ptr = m0 + n * n * 2;
  DATATYPE *x   = m0 + n * n * 2 + n + 8;
  DATATYPE *y   = m0 + n * n * 2 + n + 8 + n;

  for (int i = 0; i < n; i++) {
    for (int k = ptr[i]; k < ptr[i + 1]; k++) {
      y[i] = y[i] + val[k] * x[ind[k]];
      //if (i < 3) {
      //  std::cout << "[" << std::dec << k << "] " << "val=" << std::hex << val[k] << " ind=" << ind[k] << " x=" << x[ind[k]] << '\n';
      //}
    }
    //if (i < 3)
    //  std::cout << "--> y[" << std::dec << i << "]=" << std::hex<< y[i] << '\n';

  }
}

// matrix-vector multiply
void mvm(DATATYPE *A, DATATYPE *x, DATATYPE *y, int n) {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      y[i] += A[i * n + j] * x[j];
    }
  }
}


int main() {
//  srand(time(NULL));
  srand(0);

  int n = 8192; // vector dim

  DATATYPE *A = new DATATYPE[n * n];
  DATATYPE *x = new DATATYPE[n];
  DATATYPE *y = new DATATYPE[n];

  int len = 0;
  int nnz = 0;
  for (int i = 0; i < n; i++) {
    // Generate random number of non-zero entries per row
    // For now, ensure there's at least one NZ entry per row
    int numNZs = (rand() % (n / 1 - 1) + 1);
    //if (numNZs == n)
    //  std::cout << "Row: " << i << " has " << numNZs << " non-zero entries\n";
    for (int k = 0; k < numNZs; k++) {
      int j = rand() % n;
      DATATYPE value = rand() % 10;
      A[i * n + j] = value;
      nnz++;
    }

    int cnt = 0;
    for (int k = 64; k < n; k++)
      if (A[i * n + k] != 0)
        cnt++;
    //if (cnt == 64)
    //  std::cout << "Row " << i << " " << cnt << '\n';
  }

  for (int i = 0; i < n; i++) {
    x[i] = i;
    y[i] = i;
  }

  // Form CSR data structure
  // ind and ptr's type should be integer, and hence may be different from val
  // but for the sake of simplicity, let's assume that they are of the same type
  DATATYPE *val = new DATATYPE[n * n];
  DATATYPE *ind = new DATATYPE[n * n];
  DATATYPE *ptr = new DATATYPE[n];

  int cur_idx = 0;

  for (int i = 0; i < n; i++) {
    ptr[i] = cur_idx;
    for (int j = 0; j < n; j++) {
      if (A[i * n + j] != 0) {
        val[cur_idx] = A[i * n + j];
        ind[cur_idx] = j; // column index
        cur_idx++;
      }
    }
  }

  ptr[n] = cur_idx;
  len = cur_idx;

#ifdef DEBUG
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      std::cout << A[i * n + j] << " ";
    }
    std::cout << '\n';
  }

  std::cout <<"CSR--";
  std::cout << "\nval\n";
  for (int i = 0; i < len; i++)
    std::cout << val[i] << " ";
  std::cout << "\nind\n";
  for (int i = 0; i < len; i++)
    std::cout << ind[i] << " ";
  std::cout << "\nptr\n";
  for (int i = 0; i < n + 1; i++)
    std::cout << ptr[i] << " ";

  std::cout << "\nNNZ ratio: " << nnz << "/" << n * n << '\n';
#endif

  //int size = len + len + (n + 1) + n + n;
  int size = (n * n) + (n * n) + (n + 8) + n + n;

  DATATYPE *m0   = new DATATYPE[size];
  DATATYPE *gold = new DATATYPE[size];

  for (int i = 0; i < n * n; i++) {
    if (i < len)
      m0[i] = val[i];
    else
      m0[i] = 0;
  }

  for (int i = 0; i < n * n; i++) {
    if (i < len)
      m0[n * n + i] = ind[i];
    else
      m0[n * n + i] = 0;
  }

  for (int i = 0; i < n + 1; i++) {
    m0[n * n + n * n + i] = ptr[i];
  }

  m0[n * n + n * n + n + 1] = 0;
  m0[n * n + n * n + n + 2] = 0;
  m0[n * n + n * n + n + 3] = 0;
  m0[n * n + n * n + n + 4] = 0;
  m0[n * n + n * n + n + 5] = 0;
  m0[n * n + n * n + n + 6] = 0;
  m0[n * n + n * n + n + 7] = 0;

  for (int i = 0; i < n; i++)
    m0[n * n + n * n + n + 8 + i] = x[i];

  for (int i = 0; i < n; i++)
    m0[n * n + n * n + n + 8 + n + i] = y[i];

//  for (int i = 0; i < size; i++)
//    std::cout << std::hex << m0[i] << '\n';

//  for (int i = 0; i < 32; i++)
//    std::cout << std::dec << "ptr[" << i << "] = " << ptr[i] << '\n';
//  DATATYPE tmp = y[19];
//  for (int i = ptr[19]; i < ptr[20]; i++) {
//    tmp += val[i] * x[ind[i]];
//    std::cout << std::dec << "(row 19) ind[" << i << "] = " << ind[i] << ", val[" << i << "] = " << val[i] << ", y_tmp = " << tmp << '\n';
//  }

  mvm(A, x, y, n);
  for (int i = 0; i < n; i+=256) {
    int row_start = i;
    int row_end   = i + 256;
    spmv_axi(m0, m0, n, row_start, row_end);
  }
//  spmv_baseline(m0, n);
 

  int num_errs = 0;
  for (int i = 0; i < n; i++) {
    if (m0[n * n + n * n + n + 8 + n + i] != y[i]) {
      num_errs += 1;
      //std::cout << "Error at [" << i << "] " << m0[n * n + n * n + n + 8 + n + i] << " " << y[i] << '\n';
    }
  }

  if (num_errs == 0)
    std::cout << "PASSED!\n";
  else
    std::cout << "FAILED! Num. errors: " << num_errs << '\n';

//  for (int i = 0; i < size; i++)
//    std::cout << std::hex << m0[i] << '\n';

  return 0;
}
