
#include <iostream>
#include <cstdlib>
#include <unistd.h>
#include <sys/stat.h>
#include <string>
#include <sys/time.h>
#include "experimental/xrt_kernel.h"
#include "experimental/xrt_ip.h"
#include "experimental/xrt_uuid.h"

#define DEVICE_ID 0
#define MAT_DIM 8192
#define MAT_SIZE (MAT_DIM * MAT_DIM)

typedef int64_t DATATYPE;

#define SOCKET_CSR_OFFSET        64
#define SOCKET_IMEM_ADDR_OFFSET  67
#define SOCKET_IMEM_WDATA_OFFSET 68
#define SOCKET_IMEM_WE_OFFSET    69

#include "control_top.h"

unsigned long diff(const struct timeval *newTime, const struct timeval *oldTime) {
  return (newTime->tv_sec - oldTime->tv_sec) * 1000000 + (newTime->tv_usec - oldTime->tv_usec);
}

void spmv_baseline(DATATYPE *m0, int len, int n) {
  // Compressed-Sparse Row
  DATATYPE *val = m0;
  DATATYPE *ind = m0 + len;
  DATATYPE *ptr = m0 + len * 2;
  DATATYPE *x   = m0 + len * 2 + n;
  DATATYPE *y   = m0 + len * 2 + n * 2;

  for (int i = 0; i < n; i++) {
    for (int k = ptr[i]; k < ptr[i + 1] - 1; k++) {
      y[i] = y[i] + val[k] * x[ind[k]];
    }
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

int main(int argc, char *argv[]) {
  struct timeval tstart, tend;
  int exec_time;

//  srand(time(NULL));
  srand(0);

  int n = MAT_DIM; // vector dim

  DATATYPE *A = new DATATYPE[n * n];
  DATATYPE *x = new DATATYPE[n];
  DATATYPE *y = new DATATYPE[n];

  int len = 0;
  int nnz = 0;
  for (int i = 0; i < n; i++) {
    // Generate random number of non-zero entries per row
    // For now, ensure there's at least one NZ entry per row
    int numNZs = (rand() % (n / 1 - 1) + 1);
    for (int k = 0; k < numNZs; k++) {
      int j = rand() % n;
      DATATYPE value = rand() % 10;
      A[i * n + j] = value;
      nnz++;
    }
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

  int size = (n * n) + (n * n) + (n + 8) + n + n;

  DATATYPE *m0   = new DATATYPE[size];
//  for (int i = 0; i < size; i++)
//    m0[i] = 0;
//
//  int cur_idx = 0;
//
//  for (int i = 0; i < n; i++) {
//    m0[n * n + n * n + i] = cur_idx; // ptr
//    for (int j = 0; j < n; j++) {
//      if (A[i * n + j] != 0) {
//        m0[cur_idx] = A[i * n + j]; // val
//        m0[n * n + cur_idx] = j; // column index (ind)
//        cur_idx++;
//      }
//    }
//  }

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

  std::string xclbin_file;
  std::cout << "Program running in hardware mode" << std::endl;
  xclbin_file = "ulp.xclbin";

  // Load xclbin
  std::cout << "Load " << xclbin_file << std::endl;
  xrt::device device = xrt::device(DEVICE_ID);
  xrt::uuid xclbin_uuid = device.load_xclbin(xclbin_file);

  // create kernel objects
  std::cout << "Create kernel" << std::endl;
  xrt::ip ip = xrt::ip(device, xclbin_uuid, "socket_manager");

  xrt::bo data_buf = xrt::bo(device, size * sizeof(DATATYPE), xrt::bo::flags::normal, 0);

  int log2_byte_size = 6;

  int num_sockets = NUM_SOCKETS;
  int64_t socket_base_addr = 0x00000000000 + ((1 << 16) << log2_byte_size);
  int64_t socket_offset    = 0x00040000000;
  int64_t socket_addr;
  int control_offset = 0;

  int64_t socket_addrs[12] = {
    0x00000000000,
    0x00040000000,
    0x00080000000,
    0x000c0000000,
    0x00140000000,
    0x00180000000,
    0x001c0000000,
    0x00200000000,
    0x00240000000,
    0x00280000000,
    0x002c0000000,
    0x00300000000
  };
  // CHECK INDIVIDUAL SOCKET
  socket_base_addr += socket_offset * 0;

  gettimeofday(&tstart, 0);
  data_buf.write(m0);
  data_buf.sync(XCL_BO_SYNC_BO_TO_DEVICE);
  gettimeofday(&tend, 0);
  exec_time = diff(&tend, &tstart);
  std::cout << "Done transferring data" << std::endl;
  std::cout << "Transfer time: " << exec_time << " us" << std::endl;

  // reset sockets
  std::cout << "Resetting socket before execution...\n";
  for (int i = 0; i < num_sockets; i++) {
    socket_addr = socket_addrs[i] + ((1 << 16) << log2_byte_size);
    ip.write_register(0x10, socket_addr + (256 << log2_byte_size)); // socket_csr
    ip.write_register(0x14, socket_addr >> 32);
    ip.write_register(0x20, 0);
    ip.write_register(0x0, 1);

    // check write idle
    while (ip.read_register(0x18) != 0);
  }

  ip.write_register(0x24, 0); // rcnt
  ip.write_register(0x28, 0); // wcnt
  ip.write_register(0x40, 0); // socket_status

  std::cout << "socket_manager state_wr " << std::hex << ip.read_register(0x18) << std::dec << '\n';
  std::cout << "socket_manager state_rd " << std::hex << ip.read_register(0x2c) << std::dec << '\n';

  for (int i = 0; i < num_sockets; i++) {
    socket_addr = socket_addrs[i] + ((1 << 16) << log2_byte_size);
    ip.write_register(0x10, socket_addr + (SOCKET_CSR_OFFSET << log2_byte_size)); // socket_csr
    ip.write_register(0x14, socket_addr >> 32);
    //std::cout << "0. Check status before configuration: " << ip.read_register(0x0) << " of socket " << i << '\n';
    std::cout << "Check socket status before configuration:\n";
    ip.read_register(0x0);
    while (ip.read_register(0x2c) != 0);
    std::cout << "[csr] socket_rdata[" << i << "]: " << std::hex << ip.read_register(0x1c) << std::dec << '\n';
  }

  std::cout << "Sockets configuring ...\n";
  gettimeofday(&tstart, 0);
  for (int i = 0; i < num_sockets; i++) {
    socket_addr = socket_addrs[i] + ((1 << 16) << log2_byte_size);
    ip.write_register(0x14, socket_addr >> 32);

    ip.write_register(0x10, socket_addr + (SOCKET_IMEM_WE_OFFSET << log2_byte_size));
    ip.write_register(0x20, 1);
    ip.write_register(0x0, 1); // commit
    while (ip.read_register(0x18) != 0) {
      //std::cout <<  std::hex << ip.read_register(0x18) << std::dec << '\n';
    }

    for (int j = 0; j < control_lens[i]; j++) {
      ip.write_register(0x10, socket_addr + (SOCKET_IMEM_ADDR_OFFSET << log2_byte_size));
      ip.write_register(0x20, j);
      ip.write_register(0x0, 1); // commit
      while (ip.read_register(0x18) != 0) {
        //std::cout << std::hex << ip.read_register(0x18) << std::dec << '\n';
      }

      ip.write_register(0x10, socket_addr + (SOCKET_IMEM_WDATA_OFFSET << log2_byte_size));
      ip.write_register(0x20, control[j + control_offset]);
      ip.write_register(0x0, 1); // commit
      while (ip.read_register(0x18) != 0) {
        //std::cout << std::hex << ip.read_register(0x18) << std::dec << '\n';
      }

      usleep(1000);
    }
    control_offset += control_lens[i];

    ip.write_register(0x10, socket_addr + (SOCKET_IMEM_WE_OFFSET << log2_byte_size));
    ip.write_register(0x20, 0);
    ip.write_register(0x0, 1); // commit
    while (ip.read_register(0x18) != 0) {
      //std::cout << std::hex << ip.read_register(0x18) << std::dec << '\n';
    }

    ip.write_register(0x10, socket_addr + (SOCKET_CSR_OFFSET << log2_byte_size));
    ip.write_register(0x20, 1);
    while (ip.read_register(0x18) != 0) {
      //std::cout << std::hex << ip.read_register(0x18) << std::dec << '\n';
    }
  }
  gettimeofday(&tend, 0);
  exec_time = diff(&tend, &tstart);
  std::cout << "Done configuration" << std::endl;
  std::cout << "Config time: " << exec_time << " us" << std::endl;

  ip.write_register(0x10, socket_base_addr + (SOCKET_IMEM_WDATA_OFFSET << log2_byte_size));
  ip.write_register(0x14, socket_base_addr >> 32);
  // check write idle
  while (ip.read_register(0x18) != 0) {
    //std::cout << std::hex << ip.read_register(0x18) << std::dec << '\n';
  }

  ip.read_register(0x0);
  while (ip.read_register(0x2c) != 0) {
    std::cout << "read_state " << std::hex << ip.read_register(0x2c) << std::dec << '\n';
  }
  std::cout << "socket_rdata: " << std::hex << ip.read_register(0x1c) << std::dec << '\n';

  for (int i = 0; i < num_sockets; i++) {
    socket_addr = socket_addrs[i] + ((1 << 16) << log2_byte_size);
    ip.write_register(0x10, socket_addr + (74 << log2_byte_size)); // perf_cnt
    ip.write_register(0x14, socket_addr >> 32);
    ip.read_register(0x0);
    while (ip.read_register(0x2c) != 0);
    std::cout << "[Before] socket " << i << " performance cnt: " << std::dec << ip.read_register(0x1c) << std::dec << '\n';
  }

  // Enqueue socket offsets
  ip.write_register(0x20, 1);

//  for (int i = num_sockets - 1; i >= 0; i--) {
  for (int i = 0; i < num_sockets; i++) {
    socket_addr = socket_addrs[i] + ((1 << 16) << log2_byte_size);
    ip.write_register(0x10, socket_addr + (SOCKET_CSR_OFFSET << log2_byte_size)); // socket_csr
    ip.write_register(0x14, socket_addr >> 32);
    ip.write_register(0x38, 0); // ADDR_SOCKET_QUEUE_ENQ
  }

  std::cout << "Run krnl...\n" ;
  gettimeofday(&tstart, 0);

  // start sockets
  // Dequeue all socket offsets in the queue
  ip.write_register(0x3c, 0); // ADDR_SOCKET_QUEUE_DEQ
  // check status
  int cnt_done = 0;
  while (cnt_done != num_sockets) {
    int socket_status = ip.read_register(0x40);
    cnt_done = 0;
    for (int i = 0; i < num_sockets; i++) {
       cnt_done += (socket_status >> i) & 0x1;
    }
  }
  gettimeofday(&tend, 0);
  exec_time = diff(&tend, &tstart);
  std::cout << "Execution time: " << exec_time << " us" << std::endl;

  for (int i = 0; i < num_sockets; i++) {
    socket_addr = socket_addrs[i] + ((1 << 16) << log2_byte_size);
    ip.write_register(0x10, socket_addr + (74 << log2_byte_size)); // perf_cnt
    ip.write_register(0x14, socket_addr >> 32);
    ip.read_register(0x0);
    while (ip.read_register(0x2c) != 0);
    std::cout << "[After] socket " << i << " performance cnt: " << std::dec << ip.read_register(0x1c) << std::dec << '\n';
  }

  std::cout << "Transfer output data to host...\n";
  gettimeofday(&tstart, 0);
  data_buf.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
  data_buf.read(m0);
  gettimeofday(&tend, 0);
  exec_time = diff(&tend, &tstart);
  std::cout << "Transfer time: " << exec_time << " us" << std::endl;

  std::cout << "Run sw version...\n" ;
  gettimeofday(&tstart, 0);
  mvm(A, x, y, n);
  //spmv(m0, n);
  gettimeofday(&tend, 0);
  exec_time = diff(&tend, &tstart);
  std::cout << "Execution time: " << exec_time << " us" << std::endl;

  for (int i = 0; i < 10; i++) {
    std::cout << std::hex << i << " " << m0[n * n + n * n + n + 8 + n + i] << " " << y[i] << '\n';
  }

  // Check result
  int num_mismatches = 0;
  for (int i = 0; i < n; i++) {
    if (m0[n * n + n * n + n + 8 + n + i] != y[i]) {
      num_mismatches += 1;
      std::cout << "Mismatched: " << std::dec << i << " " << std::hex << m0[n * n + n * n + n + 8 + n + i] << " " << y[i] << '\n';
    }
  }

  if (num_mismatches == 0)
    std::cout << "Test Passed!" << std::endl;
  else
    std::cout << "Test Failed! Num. mismatches: " << std::dec << num_mismatches << std::endl;

  free(A);
  free(x);
  free(y);
  free(m0);
}
