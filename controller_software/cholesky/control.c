#include "memory_map.h"
#include "kernel_mmio.h"

#define MAT_DIM 128
#define BLK_DIM 16

#define MAT_SIZE (MAT_DIM * MAT_DIM)
#define BLK_SIZE (BLK_DIM * BLK_DIM)

#define GLB_A_OFFSET 0
#define GLB_L_OFFSET (GLB_A_OFFSET + (MAT_SIZE << 3))

#define CORE_ID 0
#define NUM_CORES 1

void check(int i, int j) {
  int check = 0;
  if (j == i && j > 0) {
    while (check != 1) {
      CTRL_MAXI_SOCKET_OFFSET_LO = 0x00000000 + 2 * (MAT_SIZE << 3) + (((j - 1) * (MAT_DIM / BLK_DIM) + j) << 6);
      CTRL_MAXI_SOCKET_OFFSET_HI = 0;
      CTRL_MAXI_READ = 1;
      while (CTRL_MAXI_READ_DONE == 0);

      check = CTRL_MAXI_RDATA;
    }
  } else if (j != i && j == 0) {
    while (check != 1) {
      CTRL_MAXI_SOCKET_OFFSET_LO = 0x00000000 + 2 * (MAT_SIZE << 3) + ((j * (MAT_DIM / BLK_DIM) + j) << 6);
      CTRL_MAXI_SOCKET_OFFSET_HI = 0;
      CTRL_MAXI_READ = 1;
      while (CTRL_MAXI_READ_DONE == 0);

      check = CTRL_MAXI_RDATA;
    }
  } else if (j != i && j > 0) {
    while (check != 1) {
      CTRL_MAXI_SOCKET_OFFSET_LO = 0x00000000 + 2 * (MAT_SIZE << 3) + ((j * (MAT_DIM / BLK_DIM) + j) << 6);
      CTRL_MAXI_SOCKET_OFFSET_HI = 0;
      CTRL_MAXI_READ = 1;
      while (CTRL_MAXI_READ_DONE == 0);

      check = CTRL_MAXI_RDATA;
    }

    check = 0;
    while (check != 1) {
      CTRL_MAXI_SOCKET_OFFSET_LO = 0x00000000 + 2 * (MAT_SIZE << 3) + (((j - 1) * (MAT_DIM / BLK_DIM) + i) << 6);
      CTRL_MAXI_SOCKET_OFFSET_HI = 0;
      CTRL_MAXI_READ = 1;
      while (CTRL_MAXI_READ_DONE == 0);

      check = CTRL_MAXI_RDATA;
    }
  }
}

int main() {

  LSU0_RAM_STRIDE = 1;
  LSU0_RAM_SEG_STRIDE = 1;
  LSU0_RAM_ADDR_OFFSET = 0;
  LSU0_M_OFFSET_HI = 0;

  LSU1_RAM_STRIDE = 1;
  LSU1_RAM_SEG_STRIDE = 1;
  LSU1_RAM_ADDR_OFFSET = 0;
  LSU1_M_OFFSET_HI = 0;

  LSU1_MODE = 1;

  LSU0_SEG_STRIDE = MAT_DIM / 8;
  LSU0_SEG_COUNT = BLK_DIM;
  LSU0_LEN = BLK_DIM / 8;

  LSU1_SEG_STRIDE = MAT_DIM / 8;
  LSU1_SEG_COUNT = BLK_DIM;
  LSU1_LEN = BLK_DIM / 8;

  LSU1_RAM_BLOCK_FACTOR = 2;
  LSU1_RAM_CYCLIC_FACTOR = 8;

  for (int j = 0; j < ((MAT_DIM + BLK_DIM - 1) / BLK_DIM); j+=1) {
    for (int i = j + CORE_ID; i < ((MAT_DIM + BLK_DIM - 1) / BLK_DIM); i+=NUM_CORES) {
      LSU0_RAM_START_IDX = 36;
      LSU0_RAM_BLOCK_FACTOR = 1;
      LSU0_RAM_CYCLIC_FACTOR = 4;

      LSU0_M_OFFSET_LO = (i * MAT_DIM * BLK_DIM + j * BLK_DIM) << 3;
      LSU0_MODE = 1;
      TQ_LSU0_START();

      if (i == j) {
        KRN_STATE = 4;
      } else {
        KRN_STATE = 5;
      }
      KRN_START = 1;
      TQ_CL_START();
      TQ_CL_DONE();

      TQ_LSU0_DONE();

      LSU0_RAM_BLOCK_FACTOR = 2;
      LSU0_RAM_CYCLIC_FACTOR = 8;

      KRN_PP = 1;
      int pp = 0;
      if (i == j) {
        KRN_STATE = 0;
        for (int k0 = 0; k0 < j; k0++) {
          if (pp == 0) {
            LSU0_RAM_START_IDX = 0;
            LSU0_M_OFFSET_LO = (MAT_DIM * MAT_DIM + j * MAT_DIM * BLK_DIM + k0 * BLK_DIM) << 3;
            LSU1_RAM_START_IDX = 16;
            LSU1_M_OFFSET_LO = (MAT_DIM * MAT_DIM + j * MAT_DIM * BLK_DIM + k0 * BLK_DIM) << 3;

            KRN_PP = 2;
            pp = 1;
          } else {
            LSU0_RAM_START_IDX = 8;
            LSU0_M_OFFSET_LO = (MAT_DIM * MAT_DIM + j * MAT_DIM * BLK_DIM + k0 * BLK_DIM) << 3;
            LSU1_RAM_START_IDX = 24;
            LSU1_M_OFFSET_LO = (MAT_DIM * MAT_DIM + j * MAT_DIM * BLK_DIM + k0 * BLK_DIM) << 3;

            KRN_PP = 1;
            pp = 0;
          }
          TQ_LSU0_START();
          TQ_LSU1_START();
          if (k0 != 0) {
            KRN_START = 1;
            TQ_CL_START();
            TQ_CL_DONE();
          }
          TQ_LSU0_DONE();
          TQ_LSU1_DONE();
        }
        if (j != 0) {
          KRN_PP = (pp == 0) ? 2 : 1;
          KRN_START = 1;
          TQ_CL_START();
          TQ_CL_DONE();
        }
        KRN_PP = 1;
        KRN_STATE = 1;
        KRN_START = 1;
        TQ_CL_START();
        TQ_CL_DONE();
      } else {
        KRN_STATE = 2;
        for (int k0 = 0; k0 < j; k0++) {
          if (pp == 0) {
            LSU0_RAM_START_IDX = 0;
            LSU0_M_OFFSET_LO = (MAT_DIM * MAT_DIM + j * MAT_DIM * BLK_DIM + k0 * BLK_DIM) << 3;

            LSU1_RAM_START_IDX = 16;
            LSU1_M_OFFSET_LO = (MAT_DIM * MAT_DIM + i * MAT_DIM * BLK_DIM + k0 * BLK_DIM) << 3;

            KRN_PP = 2;
            pp = 1;
          } else {
            LSU0_RAM_START_IDX = 8;
            LSU0_M_OFFSET_LO = (MAT_DIM * MAT_DIM + j * MAT_DIM * BLK_DIM + k0 * BLK_DIM) << 3;

            LSU1_RAM_START_IDX = 24;
            LSU1_M_OFFSET_LO = (MAT_DIM * MAT_DIM + i * MAT_DIM * BLK_DIM + k0 * BLK_DIM) << 3;

            KRN_PP = 1;
            pp = 0;
          }
          TQ_LSU0_START();
          TQ_LSU1_START();
          if (k0 != 0) {
            KRN_START = 1;
            TQ_CL_START();
            TQ_CL_DONE();
          }
          TQ_LSU0_DONE();
          TQ_LSU1_DONE();
        }
        if (j != 0) {
          KRN_PP = (pp == 0) ? 2 : 1;
          KRN_START = 1;
          TQ_CL_START();
          TQ_CL_DONE();
        }

        LSU1_RAM_START_IDX = 16;
        LSU1_M_OFFSET_LO = (MAT_DIM * MAT_DIM + j * MAT_DIM * BLK_DIM + j * BLK_DIM) << 3;

        TQ_LSU1_START();
        TQ_LSU1_DONE();

        KRN_PP = 1;
        KRN_STATE = 3;
        KRN_START = 1;
        TQ_CL_START();
        TQ_CL_DONE();
      }

      LSU0_RAM_BLOCK_FACTOR = 1;
      LSU0_RAM_CYCLIC_FACTOR = 16;
      LSU0_RAM_START_IDX = 0;
      LSU0_M_OFFSET_LO = (MAT_DIM * MAT_DIM + i * MAT_DIM * BLK_DIM + j * BLK_DIM) << 3;

      LSU0_MODE = 2;
      TQ_LSU0_START();
      TQ_LSU0_DONE();
      while (TQ_EMPTY_N == 1);
    }
  }

  while (TQ_EMPTY_N == 1);

//  long long int socket_offset = 0x20100000000 + ((1<<18)<<6);
//  int socket_lo_offset = socket_offset & 0xFFFFFFFF;
//  int socket_hi_offset = socket_offset >> 32;
//  CTRL_MAXI_SOCKET_OFFSET_LO = socket_lo_offset + ((128 + CORE_ID)<<6); 
//  CTRL_MAXI_SOCKET_OFFSET_HI = socket_hi_offset;
//  CTRL_MAXI_WRITE = 1;
//  while (CTRL_MAXI_WRITE_DONE == 0);

  CPU_STATUS = 1;

  // spin
  for(;;) {
    asm volatile ("nop");
  }
}
