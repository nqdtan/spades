#include "memory_map.h"
#include "kernel_mmio.h"

#define IFM_DIM 13
#define WT_DIM 3
#define PAD 1
#define OFM_DIM (IFM_DIM + 2 * PAD - WT_DIM + 1)
#define IFM_CHN 2//32//36
#define OFM_CHN 2//16//8
#define NUM_CONV2D 1//12
#define OFM_CNT 2//8
#define IFM_CHN_SCALE (IFM_CHN / NUM_CONV2D)

#define IFM_P_DIM (OFM_DIM)
#define OFM_P_DIM (IFM_P_DIM / 2)
#define IFM_P_CHN (OFM_CHN)
#define OFM_P_CHN (IFM_P_CHN)

#define WT_SIZE_CEIL  (((WT_DIM * WT_DIM + 7) / 8) * 8)
#define IFM_SIZE_CEIL (((IFM_DIM * IFM_DIM + 7) / 8) * 8)
#define OFM_SIZE_CEIL (((OFM_DIM * OFM_DIM + 7) / 8) * 8)

#define IFM_P_SIZE_CEIL (((IFM_P_DIM * IFM_P_DIM + 7) / 8) * 8)
#define OFM_P_SIZE_CEIL (((OFM_P_DIM * OFM_P_DIM + 7) / 8) * 8)

#define WT_LEN  (OFM_CHN * IFM_CHN * WT_SIZE_CEIL)
#define IFM_LEN (IFM_CHN * IFM_SIZE_CEIL)
#define OFM_LEN (OFM_CHN * OFM_SIZE_CEIL)

#define IFM_P_LEN (IFM_P_CHN * IFM_P_SIZE_CEIL)
#define OFM_P_LEN (OFM_P_CHN * OFM_P_SIZE_CEIL)

#define WORD_SCALE (512 / 32)
#define LOG2_WORD_SIZE 2
#define LSU_WIDTH_SCALE (64 / 32)

#define CORE_ID 0

int main() {

  LSU0_RAM_STRIDE = 1;
  LSU0_RAM_SEG_STRIDE = 1;
  LSU0_RAM_ADDR_OFFSET = 0;
  LSU0_M_OFFSET_HI = 0;
  LSU0_SEG_STRIDE = 0;
  LSU0_SEG_COUNT = 1;

  LSU1_RAM_STRIDE = 1;
  LSU1_RAM_SEG_STRIDE = 1;
  LSU1_RAM_ADDR_OFFSET = 0;
  LSU1_M_OFFSET_HI = 0;
  LSU1_SEG_STRIDE = 0;
  LSU1_SEG_COUNT = 1;

  for (int i = 0; i < OFM_CHN; i+=OFM_CNT) {
    // fetch ofm
    LSU0_RAM_START_IDX = 24;
    LSU0_RAM_ADDR_OFFSET = 0;
    LSU0_RAM_BLOCK_FACTOR = OFM_CNT * OFM_SIZE_CEIL / LSU_WIDTH_SCALE;
    LSU0_RAM_CYCLIC_FACTOR = 1;
    LSU0_M_OFFSET_LO = (WT_LEN + IFM_LEN + i * OFM_SIZE_CEIL) << LOG2_WORD_SIZE;
    LSU0_SEG_STRIDE = 0;
    LSU0_SEG_COUNT = 1;
    LSU0_LEN = OFM_CNT * OFM_SIZE_CEIL / WORD_SCALE;
    LSU0_MODE = 1;

    TQ_LSU0_START();
    TQ_LSU0_DONE();

    // fetch weight
    LSU1_RAM_START_IDX = 0;
    LSU1_RAM_ADDR_OFFSET = 0;
    LSU1_RAM_BLOCK_FACTOR = WT_SIZE_CEIL / LSU_WIDTH_SCALE;
    LSU1_RAM_CYCLIC_FACTOR = NUM_CONV2D;

    LSU1_M_OFFSET_LO = (i * IFM_CHN * WT_SIZE_CEIL + 0 * WT_SIZE_CEIL) << LOG2_WORD_SIZE;
    LSU1_SEG_STRIDE = IFM_CHN * WT_SIZE_CEIL / WORD_SCALE;
    LSU1_SEG_COUNT = OFM_CNT;
    LSU1_LEN = NUM_CONV2D * WT_SIZE_CEIL / WORD_SCALE;
    LSU1_MODE = 1;

    TQ_LSU1_START();

    // fetch ifm
    LSU0_RAM_START_IDX = 12;
    LSU0_RAM_ADDR_OFFSET = 0;
    LSU0_SEG_STRIDE = 0;
    LSU0_SEG_COUNT = 1;
    LSU0_RAM_BLOCK_FACTOR = IFM_SIZE_CEIL / LSU_WIDTH_SCALE;
    LSU0_RAM_CYCLIC_FACTOR = NUM_CONV2D;

    LSU0_M_OFFSET_LO = (WT_LEN + 0 * IFM_SIZE_CEIL) << LOG2_WORD_SIZE;
    LSU0_LEN = NUM_CONV2D * IFM_SIZE_CEIL / WORD_SCALE;
    LSU0_MODE = 1;

    TQ_LSU0_START();

    TQ_LSU0_DONE();
    TQ_LSU1_DONE();
    int pp = 0;
    for (int j = 0; j < IFM_CHN; j+=NUM_CONV2D) {
      int len = (j < IFM_CHN_SCALE * NUM_CONV2D) ? NUM_CONV2D : (IFM_CHN - IFM_CHN_SCALE * NUM_CONV2D);

      if (j + NUM_CONV2D < IFM_CHN) {
      // fetch weight
      LSU1_RAM_START_IDX = 0;
      LSU1_RAM_ADDR_OFFSET = (pp == 0) ? (OFM_CNT * WT_SIZE_CEIL / LSU_WIDTH_SCALE) : 0;
      LSU1_RAM_BLOCK_FACTOR = WT_SIZE_CEIL / LSU_WIDTH_SCALE;
      LSU1_RAM_CYCLIC_FACTOR = NUM_CONV2D;

      LSU1_M_OFFSET_LO = (i * IFM_CHN * WT_SIZE_CEIL + (j + NUM_CONV2D) * WT_SIZE_CEIL) << LOG2_WORD_SIZE;
      LSU1_SEG_STRIDE = IFM_CHN * WT_SIZE_CEIL / WORD_SCALE;
      LSU1_SEG_COUNT = OFM_CNT;
      LSU1_LEN = NUM_CONV2D * WT_SIZE_CEIL / WORD_SCALE;
      LSU1_MODE = 1;

      TQ_LSU1_START();

      // fetch ifm
      LSU0_RAM_START_IDX = 12;
      LSU0_RAM_ADDR_OFFSET = (pp == 0) ? IFM_SIZE_CEIL / LSU_WIDTH_SCALE : 0;
      LSU0_SEG_STRIDE = 0;
      LSU0_SEG_COUNT = 1;
      LSU0_RAM_BLOCK_FACTOR = IFM_SIZE_CEIL / LSU_WIDTH_SCALE;
      LSU0_RAM_CYCLIC_FACTOR = NUM_CONV2D;

      LSU0_M_OFFSET_LO = (WT_LEN + (j + NUM_CONV2D) * IFM_SIZE_CEIL) << LOG2_WORD_SIZE;
      LSU0_LEN = NUM_CONV2D * IFM_SIZE_CEIL / WORD_SCALE;
      LSU0_MODE = 1;

      TQ_LSU0_START();
      }

      KRN_IFM_OFFSET = (pp == 0) ? 0 : IFM_SIZE_CEIL / LSU_WIDTH_SCALE;
      for (int k = 0; k < OFM_CNT; k++) {
        KRN_WT_OFFSET = ((pp == 0) ? 0 : (OFM_CNT * WT_SIZE_CEIL / LSU_WIDTH_SCALE)) + (k * WT_SIZE_CEIL / LSU_WIDTH_SCALE);
        KRN_OFM_OFFSET = k * OFM_SIZE_CEIL / LSU_WIDTH_SCALE;
        KRN_LEN = len;
        KRN_STATE = 1;
        KRN_START = 1;
        TQ_CL_START();
        TQ_CL_DONE();
      }

      if (j + NUM_CONV2D < IFM_CHN) {
        TQ_LSU0_DONE();
        TQ_LSU1_DONE();
      }
      pp = 1 - pp;
    }

    // maxpool
    for (int k = 0; k < OFM_CNT; k++) {
      KRN_IFM_OFFSET = k * OFM_SIZE_CEIL / LSU_WIDTH_SCALE;
      //KRN_OFM_OFFSET = k * OFM_P_SIZE_CEIL / LSU_WIDTH_SCALE;
      KRN_OFM_OFFSET = k * OFM_SIZE_CEIL / LSU_WIDTH_SCALE;
      KRN_STATE = 2;
      KRN_START = 1;
      TQ_CL_START();
      TQ_CL_DONE();
    }

    // write ofm
    LSU0_RAM_START_IDX = 24;
    LSU0_RAM_ADDR_OFFSET = 0;
    LSU0_RAM_BLOCK_FACTOR = OFM_CNT * OFM_SIZE_CEIL / LSU_WIDTH_SCALE;
    LSU0_RAM_CYCLIC_FACTOR = 1;
    LSU0_M_OFFSET_LO = (WT_LEN + IFM_LEN + i * OFM_SIZE_CEIL) << LOG2_WORD_SIZE;
    LSU0_SEG_STRIDE = 0;
    LSU0_SEG_COUNT = 1;
    LSU0_LEN = OFM_CNT * OFM_SIZE_CEIL / WORD_SCALE;
    LSU0_MODE = 2;

//    LSU0_RAM_START_IDX = 24;
//    LSU0_RAM_ADDR_OFFSET = 0;
//    LSU0_RAM_BLOCK_FACTOR = OFM_CNT * OFM_P_SIZE_CEIL / LSU_WIDTH_SCALE;
//    LSU0_RAM_CYCLIC_FACTOR = 1;
//    LSU0_M_OFFSET_LO = (WT_LEN + IFM_LEN + i * OFM_SIZE_CEIL) << LOG2_WORD_SIZE;
//    LSU0_SEG_STRIDE = 0;
//    LSU0_SEG_COUNT = 1;
//    LSU0_LEN = (OFM_CNT * OFM_P_SIZE_CEIL + WORD_SCALE - 1) / WORD_SCALE;
//    LSU0_MODE = 2;

    TQ_LSU0_START();
    TQ_LSU0_DONE();
  }

  while (TQ_EMPTY_N == 1);

  CTRL_MAXI_SOCKET_OFFSET_LO = ((SOCKET_MANAGER_NOC_ADDR + MMIO_REGSPACE_OFFSET) & 0xFFFFFFFF) + ((128 + CORE_ID)<<6); 
  CTRL_MAXI_SOCKET_OFFSET_HI = ((SOCKET_MANAGER_NOC_ADDR + MMIO_REGSPACE_OFFSET) >> 32);
  CTRL_MAXI_WRITE = 1;
  while (CTRL_MAXI_WRITE_DONE == 0);

  CPU_STATUS = 1;

  // spin
  for(;;) {
    asm volatile ("nop");
  }
}
