#include "memory_map.h"
#include "kernel_mmio.h"
#define MAT_DIM 8192
#define SIZE 8192
#define X_LEN 4096
#define Y_LEN 256

#define VAL_OFFSET 0
#define IND_OFFSET (VAL_OFFSET + MAT_DIM * MAT_DIM)
#define PTR_OFFSET (IND_OFFSET + MAT_DIM * MAT_DIM)
#define X_OFFSET   (PTR_OFFSET + MAT_DIM + 8)
#define Y_OFFSET   (X_OFFSET + MAT_DIM)

#define BROADCAST_MODE 1

#define CORE_ID 0
#define NUM_CORES 9

int main() {

  int x_len = (X_LEN < MAT_DIM) ? X_LEN : MAT_DIM;

  LSU0_RAM_STRIDE = 1;
  LSU0_RAM_SEG_STRIDE = 1;
  LSU0_M_OFFSET_HI = 0;
  LSU0_SEG_COUNT = 1;
  LSU0_SEG_STRIDE = 0;
  LSU0_RAM_ADDR_OFFSET = 0;

  LSU1_RAM_STRIDE = 1;
  LSU1_RAM_SEG_STRIDE = 1;
  LSU1_M_OFFSET_HI = 0;
  LSU1_SEG_COUNT = 1;
  LSU1_SEG_STRIDE = 0;
  LSU1_RAM_ADDR_OFFSET = 0;

  for (int i = Y_LEN * CORE_ID; i < MAT_DIM; i+=Y_LEN*NUM_CORES) {
    int row_begin = i;
    int row_end   = i + Y_LEN;

    KRN_N = MAT_DIM;
    KRN_I = i;
    KRN_ROW_BEGIN = row_begin;
    KRN_ROW_END = row_end;
    KRN_STATE = 5;
    KRN_START = 1;
    TQ_CL_START();
    TQ_CL_DONE();

    LSU0_RAM_START_IDX = 0;
    LSU0_RAM_BLOCK_FACTOR = 1;
    LSU0_RAM_CYCLIC_FACTOR = 1;

    LSU0_LEN = Y_LEN / 8;
    LSU0_M_OFFSET_LO = (Y_OFFSET + row_begin) << 3;

    LSU0_MODE = 1;
    TQ_LSU0_START();
    TQ_LSU0_DONE();

    LSU0_RAM_START_IDX = 2;
    LSU0_LEN = (Y_LEN + 8) / 8;
    LSU0_M_OFFSET_LO = (PTR_OFFSET + row_begin) << 3;

    LSU0_MODE = 1;
    TQ_LSU0_START();
    TQ_LSU0_DONE();

    int k0 = 0;
    int k1, k2;

    KRN_K0 = k0;
    KRN_STATE = 3;
    KRN_START = 1;
    TQ_CL_START();
    TQ_CL_DONE();
    while (TQ_EMPTY_N == 1);

    int cur_ptr = KRN_CUR_PTR;
    int maxlen = KRN_MAXLEN;

//    KRN_CUR_PTR = cur_ptr;
//    KRN_K0 = k0;
//    KRN_STATE = 0;
//    KRN_START = 1;
//    TQ_CL_START();
//    TQ_CL_DONE();
//    while (TQ_EMPTY_N == 1);
//    k1 = KRN_K1;
//    k2 = KRN_K2;

    //do
    while (cur_ptr < maxlen)
    {
      KRN_CUR_PTR = cur_ptr;
      KRN_K0 = k0;
      KRN_STATE = 0;
      KRN_START = 1;
      TQ_CL_START();

      LSU0_RAM_BLOCK_FACTOR = 1;
      LSU0_RAM_CYCLIC_FACTOR = 4;
      LSU0_LEN = (x_len / 8);
      LSU0_MODE = 1;
      LSU1_RAM_BLOCK_FACTOR = 1;
      LSU1_RAM_CYCLIC_FACTOR = 4;
      LSU1_LEN = (x_len / 8);
      LSU1_MODE = 1;

      LSU0_RAM_START_IDX = 4;
      LSU1_RAM_START_IDX = 12;
      LSU0_M_OFFSET_LO = (X_OFFSET + 0) << 3;
      LSU1_M_OFFSET_LO = (X_OFFSET + 0) << 3;
      TQ_LSU0_START();
      TQ_LSU1_START();

      TQ_CL_DONE();
      TQ_LSU0_DONE();
      TQ_LSU1_DONE();

      while (TQ_EMPTY_N == 1);
      k1 = KRN_K1;
      k2 = KRN_K2;

      int len1 = ((cur_ptr + SIZE) > maxlen) ? (maxlen - cur_ptr) : SIZE;
      int len2 = ((cur_ptr + len1 + SIZE) > maxlen) ? (maxlen - (cur_ptr + len1)) : SIZE;
      int len1_tmp = (len1 + 15) / 8;
      if (cur_ptr % 8 == 0)
        len1_tmp = (len1 + 7) / 8;
      int len2_tmp = (len2 + 15) / 8;
      if (cur_ptr % 8 == 0)
        len2_tmp = (len2 + 7) / 8;

      KRN_LEN1 = len1;
      KRN_LEN2 = len2;
      KRN_STATE = 2;
      KRN_START = 1;
      TQ_CL_START();

      int offset_tmp = (VAL_OFFSET + cur_ptr) / 8;
      LSU0_RAM_START_IDX = 24;
      LSU0_RAM_BLOCK_FACTOR = 1;
      LSU0_RAM_CYCLIC_FACTOR = 4;

      LSU0_LEN = len1_tmp;
      LSU0_M_OFFSET_LO = (offset_tmp * 8) << 3;
      LSU0_MODE = 1;

      TQ_LSU0_START();

      offset_tmp = (IND_OFFSET + cur_ptr) / 8;
      LSU1_RAM_START_IDX = 28;
      LSU1_RAM_BLOCK_FACTOR = 1;
      LSU1_RAM_CYCLIC_FACTOR = 4;
      LSU1_LEN = len1_tmp;
      LSU1_M_OFFSET_LO = (offset_tmp * 8) << 3;
      LSU1_MODE = 1;

      TQ_LSU1_START();


      TQ_CL_DONE();
//      KRN_CUR_PTR = cur_ptr + len1 + len2;
//      KRN_K0 = k2;
//      KRN_STATE = 0;
//      KRN_START = 1;
//      TQ_CL_START();

      TQ_LSU0_DONE();
      TQ_LSU1_DONE();

      if (cur_ptr + len1 < maxlen) {
        offset_tmp = (VAL_OFFSET + cur_ptr + len1) / 8;
        LSU0_RAM_START_IDX = 32;
        LSU0_LEN = len2_tmp;
        LSU0_M_OFFSET_LO = (offset_tmp * 8) << 3;
        LSU0_MODE = 1;

        TQ_LSU0_START();

        offset_tmp = (IND_OFFSET + cur_ptr + len1) / 8;
        LSU1_RAM_START_IDX = 36;
        LSU1_LEN = len2_tmp;
        LSU1_M_OFFSET_LO = (offset_tmp * 8) << 3;
        LSU1_MODE = 1;

        TQ_LSU1_START();

        TQ_LSU0_DONE();
        TQ_LSU1_DONE();
      }

//      TQ_CL_DONE();
//      while (TQ_EMPTY_N == 1);
//      int k1_new = KRN_K1;
//      int k2_new = KRN_K2;

      LSU0_RAM_BLOCK_FACTOR = 1;
      LSU0_RAM_CYCLIC_FACTOR = 4;
      LSU0_LEN = (x_len / 8);
      LSU0_MODE = 1;// + (BROADCAST_MODE << 3);
      LSU1_RAM_BLOCK_FACTOR = 1;
      LSU1_RAM_CYCLIC_FACTOR = 4;
      LSU1_LEN = (x_len / 8);
      LSU1_MODE = 1;// + (BROADCAST_MODE << 3);

//      KRN_CUR_PTR = cur_ptr;
//      KRN_K0 = k0;
//      KRN_K1 = k1;
//      KRN_K2 = k2;

//      LSU0_RAM_START_IDX = 4;
//      LSU1_RAM_START_IDX = 12;
//      LSU0_M_OFFSET_LO = (X_OFFSET + 0) << 3;
//      LSU1_M_OFFSET_LO = (X_OFFSET + 0) << 3;
//      TQ_LSU0_START();
//      TQ_LSU1_START();
//      TQ_LSU0_DONE();
//      TQ_LSU1_DONE();

      KRN_STATE = 1;
      int pp = 0;
      int i;
      for (i = 0; i < MAT_DIM; i += X_LEN) {
//        KRN_PP = 1;
//        LSU0_RAM_START_IDX = 4;
//        LSU0_M_OFFSET_LO = (X_OFFSET + i) << 3;
//        TQ_LSU0_START();
//        TQ_LSU0_DONE();
//        KRN_I = i;
//        KRN_START = 1;
//        TQ_CL_START();
//        TQ_CL_DONE();

        if (pp == 0) {
          KRN_PP = 1;
          LSU0_RAM_START_IDX = 8;
          LSU1_RAM_START_IDX = 16;
          pp = 1;
        } else {
          KRN_PP = 2;
          LSU0_RAM_START_IDX = 4;
          LSU1_RAM_START_IDX = 12;
          pp = 0;
        }
        KRN_I = i;
        KRN_START = 1;
        TQ_CL_START();
        if (i + X_LEN < MAT_DIM) {
        LSU0_M_OFFSET_LO = (X_OFFSET + i + X_LEN) << 3;
        LSU1_M_OFFSET_LO = (X_OFFSET + i + X_LEN) << 3;
        TQ_LSU0_START();
        TQ_LSU1_START();
        TQ_LSU0_DONE();
        TQ_LSU1_DONE();
        }
        TQ_CL_DONE();
      }
//      KRN_PP = (pp == 0) ? 2 : 1;
//      KRN_I = i - X_LEN;
//      KRN_START = 1;
//      TQ_CL_START();
//      TQ_CL_DONE();

      cur_ptr += len1 + len2;
      k0 = k2;
//      k1 = k1_new;
//      k2 = k2_new;
    }
    //while (cur_ptr < maxlen);

    KRN_STATE = 4;
    KRN_START = 1;
    TQ_CL_START();
    TQ_CL_DONE();

    LSU0_RAM_START_IDX = 0;
    LSU0_RAM_BLOCK_FACTOR = 1;
    LSU0_RAM_CYCLIC_FACTOR = 1;

    LSU0_LEN = Y_LEN / 8;
    LSU0_M_OFFSET_LO = (Y_OFFSET + row_begin) << 3;

    LSU0_MODE = 2;
    TQ_LSU0_START();
    TQ_LSU0_DONE();
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
