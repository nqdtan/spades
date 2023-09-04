#include "memory_map.h"
#include "kernel_mmio.h"

#define MAT_DIM 8192
#define BLK_DIM 64

#define MAT_SIZE (MAT_DIM * MAT_DIM)
#define BLK_SIZE (BLK_DIM * BLK_DIM)

#define GLB_M_OFFSET 0

#define DP_MODE 1

#define CORE_ID 2
#define NUM_CORES 9

int main() {

  LSU0_RAM_STRIDE = 1;
  LSU0_RAM_SEG_STRIDE = 1;
  LSU0_M_OFFSET_HI = 0;

  LSU1_RAM_STRIDE = 1;
  LSU1_RAM_SEG_STRIDE = 1;
  LSU1_RAM_ADDR_OFFSET = 0;
  LSU1_M_OFFSET_HI = 0;

  LSU1_MODE = 1;

  LSU1_SEG_STRIDE = MAT_DIM / 8;
  LSU1_SEG_COUNT = BLK_DIM;
  LSU1_LEN = BLK_DIM / 8;

  long long int m_offset_tmp;
  int NUM_ITERS = 4;
  for (int t = 0; t < NUM_ITERS; t++) {
    for (int idx = CORE_ID; idx < (MAT_DIM / BLK_DIM) * (MAT_DIM / BLK_DIM) / 2; idx+=NUM_CORES) {
    //for (int idx = CORE_ID; idx < (MAT_DIM / BLK_DIM) * (MAT_DIM / BLK_DIM) / 1; idx+=NUM_CORES) {
    //for (int idx = CORE_ID; idx < 1; idx+=NUM_CORES) {

      int i = idx / ((MAT_DIM / BLK_DIM) / 2);
      int j = idx % ((MAT_DIM / BLK_DIM) / 2);

      int j0 = 2 * j + 0;
      int j1 = 2 * j + 1;

      long long int m_offset0, m_offset1;
      if (t % 2 == 0) {
        m_offset0 = 0;
        m_offset1 = MAT_SIZE;
      } else {
        m_offset0 = MAT_SIZE;
        m_offset1 = 0;
      }

      int edge_w = (j0 == 0);
      int edge_e = (j1 == (MAT_DIM / BLK_DIM - 1));
      int edge_n = (i == 0);
      int edge_s = (i == (MAT_DIM / BLK_DIM - 1));

      int m0_n_offset = 0;

      int m_w_offset = 8;
      int m_n_offset = 1;
      int m_s_offset = 1;

      if (edge_w) {
        m_w_offset = 0;
      }

      if (edge_n) {
        m0_n_offset = 1;
        m_n_offset = 0;
      }

      if (edge_s)
        m_s_offset = 0;

      //int len_tmp = (BLK_DIM + m_w_offset + m_e_offset + 8 - 1) / 8;
      //if (m_w_offset == 4 && m_e_offset == 4)
      //  len_tmp += 1;
      int len_tmp = 1 + (BLK_DIM / 8) + 1;

      //int m_offset = (m_offset0 + i * MAT_DIM * BLK_DIM - m_n_offset * MAT_DIM +
      //                j * BLK_DIM - m_w_offset) << 3;
      long long int m_offset_0 = (m_offset0 + i * MAT_DIM * BLK_DIM +
                       j0 * BLK_DIM - m_w_offset) << 3;
      long long int m_offset_1 = (m_offset0 + i * MAT_DIM * BLK_DIM +
                       j1 * BLK_DIM - 8) << 3;

      int w_offset = edge_w ? 4 : 0;
      int n_offset = edge_n ? (BLK_DIM + 16) / 2 : 0;

      // top BLK_DIM/2 rows of tile BLK_DIM*BLK_DIM
      // even rows
      LSU0_RAM_ADDR_OFFSET = w_offset;

      LSU0_RAM_START_IDX = 0;
      LSU0_RAM_BLOCK_FACTOR = 1;
      LSU0_RAM_CYCLIC_FACTOR = 2;

      LSU0_SEG_STRIDE = 2 * MAT_DIM / 8;
      LSU0_SEG_COUNT = BLK_DIM / 4 + 1;
      LSU0_LEN = len_tmp;

      LSU0_M_OFFSET_LO = m_offset_0 & 0xFFFFFFFF;
      LSU0_M_OFFSET_HI = m_offset_0 >> 32;

      LSU0_MODE = 1 + (DP_MODE << 2);
      TQ_LSU0_START();

      LSU1_RAM_ADDR_OFFSET = 0;

      LSU1_RAM_START_IDX = 12;
      LSU1_RAM_BLOCK_FACTOR = 1;
      LSU1_RAM_CYCLIC_FACTOR = 2;

      LSU1_SEG_STRIDE = 2 * MAT_DIM / 8;
      LSU1_SEG_COUNT = BLK_DIM / 4 + 1;
      LSU1_LEN = len_tmp;

      LSU1_M_OFFSET_LO = m_offset_1 & 0xFFFFFFFF;
      LSU1_M_OFFSET_HI = m_offset_1 >> 32;
      LSU1_MODE = 1 + (DP_MODE << 2);
      TQ_LSU1_START();

      // odd rows
      LSU0_RAM_ADDR_OFFSET = n_offset + w_offset;

      LSU0_RAM_START_IDX = 2;
      LSU0_RAM_BLOCK_FACTOR = 1;
      LSU0_RAM_CYCLIC_FACTOR = 2;

      LSU0_SEG_STRIDE = 2 * MAT_DIM / 8;
      LSU0_SEG_COUNT = BLK_DIM / 4 + m_n_offset;
      LSU0_LEN = len_tmp;

      m_offset_tmp = m_offset_0 + ((m_n_offset == 1) ? -(MAT_DIM << 3) : (MAT_DIM << 3));
      LSU0_M_OFFSET_LO = m_offset_tmp & 0xFFFFFFFF;
      LSU0_M_OFFSET_HI = m_offset_tmp >> 32;
      LSU0_MODE = 1 + (DP_MODE << 2);

      TQ_LSU0_DONE();
      TQ_LSU0_START();

      LSU1_RAM_ADDR_OFFSET = n_offset + 0;

      LSU1_RAM_START_IDX = 14;
      LSU1_RAM_BLOCK_FACTOR = 1;
      LSU1_RAM_CYCLIC_FACTOR = 2;

      LSU1_SEG_STRIDE = 2 * MAT_DIM / 8;
      LSU1_SEG_COUNT = BLK_DIM / 4 + m_n_offset;
      LSU1_LEN = len_tmp;

      m_offset_tmp = m_offset_1 + ((m_n_offset == 1) ? -(MAT_DIM << 3) : (MAT_DIM << 3));
      LSU1_M_OFFSET_LO = m_offset_tmp & 0xFFFFFFFF;
      LSU1_M_OFFSET_HI = m_offset_tmp >> 32;
      LSU1_MODE = 1 + (DP_MODE << 2);

      TQ_LSU1_DONE();
      TQ_LSU1_START();

      TQ_LSU0_DONE();
      TQ_LSU1_DONE();

      KRN_EDGE_W = edge_w;
      KRN_EDGE_E = edge_e;

      KRN_EDGE_N = edge_n;
      KRN_EDGE_S = 0;
      KRN_PP = 1;

      KRN_START = 1;
      TQ_CL_START();

      // bottom BLK_DIM/2 rows of tile BLK_DIM*BLK_DIM
      n_offset = 0;

      // even rows
      m_offset_0 = m_offset_0 + ((MAT_DIM * BLK_DIM / 2) << 3);
      m_offset_1 = m_offset_1 + ((MAT_DIM * BLK_DIM / 2) << 3);

      LSU0_RAM_ADDR_OFFSET = w_offset;

      LSU0_RAM_START_IDX = 4;
      LSU0_RAM_BLOCK_FACTOR = 1;
      LSU0_RAM_CYCLIC_FACTOR = 2;

      LSU0_SEG_STRIDE = 2 * MAT_DIM / 8;
      LSU0_SEG_COUNT = BLK_DIM / 4 + m_s_offset;
      LSU0_LEN = len_tmp;

      LSU0_M_OFFSET_LO = m_offset_0 & 0xFFFFFFFF;
      LSU0_M_OFFSET_HI = m_offset_0 >> 32;
      LSU0_MODE = 1 + (DP_MODE << 2);
      TQ_LSU0_START();

      LSU1_RAM_ADDR_OFFSET = 0;

      LSU1_RAM_START_IDX = 16;
      LSU1_RAM_BLOCK_FACTOR = 1;
      LSU1_RAM_CYCLIC_FACTOR = 2;

      LSU1_SEG_STRIDE = 2 * MAT_DIM / 8;
      LSU1_SEG_COUNT = BLK_DIM / 4 + m_s_offset;
      LSU1_LEN = len_tmp;

      LSU1_M_OFFSET_LO = m_offset_1 & 0xFFFFFFFF;
      LSU1_M_OFFSET_HI = m_offset_1 >> 32;
      LSU1_MODE = 1 + (DP_MODE << 2);
      TQ_LSU1_START();

      // odd rows
      LSU0_RAM_ADDR_OFFSET = n_offset + w_offset;

      LSU0_RAM_START_IDX = 6;
      LSU0_RAM_BLOCK_FACTOR = 1;
      LSU0_RAM_CYCLIC_FACTOR = 2;

      LSU0_SEG_STRIDE = 2 * MAT_DIM / 8;
      LSU0_SEG_COUNT = BLK_DIM / 4 + 1;
      LSU0_LEN = len_tmp;

      m_offset_tmp = m_offset_0 - (MAT_DIM << 3);
      LSU0_M_OFFSET_LO = m_offset_tmp & 0xFFFFFFFF;
      LSU0_M_OFFSET_HI = m_offset_tmp >> 32;
      LSU0_MODE = 1 + (DP_MODE << 2);
      TQ_LSU0_DONE();
      TQ_LSU0_START();

      LSU1_RAM_ADDR_OFFSET = n_offset + 0;

      LSU1_RAM_START_IDX = 18;
      LSU1_RAM_BLOCK_FACTOR = 1;
      LSU1_RAM_CYCLIC_FACTOR = 2;

      LSU1_SEG_STRIDE = 2 * MAT_DIM / 8;
      LSU1_SEG_COUNT = BLK_DIM / 4 + 1;
      LSU1_LEN = len_tmp;

      m_offset_tmp = m_offset_1 - (MAT_DIM << 3);
      LSU1_M_OFFSET_LO = m_offset_tmp & 0xFFFFFFFF;
      LSU1_M_OFFSET_HI = m_offset_tmp >> 32;
      LSU1_MODE = 1 + (DP_MODE << 2);
      TQ_LSU1_DONE();
      TQ_LSU1_START();


      KRN_EDGE_N = 0;
      KRN_EDGE_S = edge_s;
      KRN_PP = 2;

      KRN_START = 1;
      //while (KRN_DONE == 0);

      TQ_LSU0_DONE();
      TQ_LSU1_DONE();
      TQ_CL_DONE();
      TQ_CL_START();

      // write result
      LSU0_RAM_ADDR_OFFSET = 0;
      LSU0_RAM_START_IDX = 8;
      LSU0_RAM_BLOCK_FACTOR = 1;
      LSU0_RAM_CYCLIC_FACTOR = 2;

      LSU0_SEG_STRIDE = MAT_DIM / 8;
      LSU0_SEG_COUNT = BLK_DIM / 2;
      LSU0_LEN = BLK_DIM / 8;

      m_offset_tmp = (m_offset1 + (i * MAT_DIM * BLK_DIM + j0 * BLK_DIM)) << 3;
      LSU0_M_OFFSET_LO = m_offset_tmp & 0xFFFFFFFF;
      LSU0_M_OFFSET_HI = m_offset_tmp >> 32;
      LSU0_MODE = 2 + (DP_MODE << 2);
      TQ_LSU0_START();

      LSU1_RAM_ADDR_OFFSET = 0;
      LSU1_RAM_START_IDX = 20;
      LSU1_RAM_BLOCK_FACTOR = 1;
      LSU1_RAM_CYCLIC_FACTOR = 2;

      LSU1_SEG_STRIDE = MAT_DIM / 8;
      LSU1_SEG_COUNT = BLK_DIM / 2;
      LSU1_LEN = BLK_DIM / 8;

      m_offset_tmp = (m_offset1 + (i * MAT_DIM * BLK_DIM + j1 * BLK_DIM)) << 3;
      LSU1_M_OFFSET_LO = m_offset_tmp & 0xFFFFFFFF;
      LSU1_M_OFFSET_HI = m_offset_tmp >> 32;
      LSU1_MODE = 2 + (DP_MODE << 2);
      TQ_LSU1_START();

      TQ_LSU0_DONE();
      TQ_LSU1_DONE();
      TQ_CL_DONE();

      // write result
      LSU0_RAM_ADDR_OFFSET = 0;
      LSU0_RAM_START_IDX = 10;
      LSU0_RAM_BLOCK_FACTOR = 1;
      LSU0_RAM_CYCLIC_FACTOR = 2;

      LSU0_SEG_STRIDE = MAT_DIM / 8;
      LSU0_SEG_COUNT = BLK_DIM / 2;
      LSU0_LEN = BLK_DIM / 8;

      m_offset_tmp = (m_offset1 + (i * MAT_DIM * BLK_DIM + j0 * BLK_DIM + MAT_DIM * BLK_DIM / 2)) << 3;
      LSU0_M_OFFSET_LO = m_offset_tmp & 0xFFFFFFFF;
      LSU0_M_OFFSET_HI = m_offset_tmp >> 32;
      LSU0_MODE = 2 + (DP_MODE << 2);
      TQ_LSU0_START();

      LSU1_RAM_ADDR_OFFSET = 0;
      LSU1_RAM_START_IDX = 22;
      LSU1_RAM_BLOCK_FACTOR = 1;
      LSU1_RAM_CYCLIC_FACTOR = 2;

      LSU1_SEG_STRIDE = MAT_DIM / 8;
      LSU1_SEG_COUNT = BLK_DIM / 2;
      LSU1_LEN = BLK_DIM / 8;

      m_offset_tmp = (m_offset1 + (i * MAT_DIM * BLK_DIM + j1 * BLK_DIM + MAT_DIM * BLK_DIM / 2)) << 3;
      LSU1_M_OFFSET_LO = m_offset_tmp & 0xFFFFFFFF;
      LSU1_M_OFFSET_HI = m_offset_tmp >> 32;
      LSU1_MODE = 2 + (DP_MODE << 2);
      TQ_LSU1_START();

      TQ_LSU0_DONE();
      TQ_LSU1_DONE();
    }

    if (t != NUM_ITERS - 1) {
      while (TQ_EMPTY_N == 1);
      long long int socket_offset = SOCKET0_NOC_ADDR + ((1<<16)<<6);
      int socket_lo_offset = socket_offset & 0xFFFFFFFF;
      int socket_hi_offset = socket_offset >> 32;
      CTRL_MAXI_SOCKET_OFFSET_LO = socket_lo_offset + SYNC_OFFSET(CORE_ID); 
      CTRL_MAXI_SOCKET_OFFSET_HI = socket_hi_offset;
      CTRL_MAXI_WRITE = 1;
      while (CTRL_MAXI_WRITE_DONE == 0);

      while (SYNC(0) == 0);
      SYNC(0) = 0;
    }
  }

  while (TQ_EMPTY_N == 1);

  long long int socket_offset = SOCKET_MANAGER_NOC_ADDR + ((1<<16)<<6);
  int socket_lo_offset = socket_offset & 0xFFFFFFFF;
  int socket_hi_offset = socket_offset >> 32;
  CTRL_MAXI_SOCKET_OFFSET_LO = socket_lo_offset + ((128 + CORE_ID)<<6); 
  CTRL_MAXI_SOCKET_OFFSET_HI = socket_hi_offset;
  CTRL_MAXI_WRITE = 1;
  while (CTRL_MAXI_WRITE_DONE == 0);

  CPU_STATUS = 1;

  // spin
  for(;;) {
    asm volatile ("nop");
  }
}
