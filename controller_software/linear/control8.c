#include "memory_map.h"
#include "kernel_mmio.h"
#include "linear.h"

#define CORE_ID 8
#define NUM_CORES 9

int main() {
  long long int ext_mem_offset;

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

  for (int i = CORE_ID; i < (OFM_LEN + (OFM_CNT * OFM_BLK_LEN) - 1) / (OFM_CNT * OFM_BLK_LEN); i+=NUM_CORES) {
    int ofm_len = ((i + 1) * OFM_CNT * OFM_BLK_LEN > OFM_LEN) ? (OFM_LEN - i * OFM_CNT * OFM_BLK_LEN) : OFM_BLK_LEN;

    for (int j = 0; j < (IFM_LEN + (IFM_CNT * IFM_BLK_LEN) - 1) / (IFM_CNT * IFM_BLK_LEN); j+=1) {
      int ifm_len = ((j + 1) * IFM_CNT * IFM_BLK_LEN > IFM_LEN) ? (IFM_LEN - j * IFM_CNT * IFM_BLK_LEN) : IFM_BLK_LEN;

      // fetch ifm
      LSU0_RAM_START_IDX = 32;
      LSU0_RAM_ADDR_OFFSET = 0;
      LSU0_RAM_BLOCK_FACTOR = IFM_CNT * IFM_BLK_LEN / LSU_WIDTH_SCALE;
      LSU0_RAM_CYCLIC_FACTOR = 1;
      ext_mem_offset = EXT_MEM_OFFSET + ((WT_LEN + j * IFM_CNT * IFM_BLK_LEN) << LOG2_WORD_SIZE);
      LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
      LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);
      LSU0_SEG_STRIDE = 0;
      LSU0_SEG_COUNT = 1;
      LSU0_LEN = IFM_CNT * IFM_BLK_LEN / WORD_SCALE;
      LSU0_MODE = 1;

      TQ_LSU0_START();
      TQ_LSU0_DONE();

      for (int t = 0; t < IFM_CNT; t++) {
      for (int k = 0; k < OFM_CNT; k++) {
        // fetch wt
        LSU0_RAM_START_IDX = 0;
        LSU0_RAM_ADDR_OFFSET = 0;
        LSU0_RAM_BLOCK_FACTOR = 1;
        LSU0_RAM_CYCLIC_FACTOR = 16;
        ext_mem_offset = EXT_MEM_OFFSET + ((i * OFM_CNT * OFM_BLK_LEN * IFM_LEN_CEIL + k * OFM_BLK_LEN * IFM_LEN_CEIL + j * IFM_CNT * IFM_BLK_LEN + t * IFM_BLK_LEN) << LOG2_WORD_SIZE);
        LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
        LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);
        LSU0_SEG_STRIDE = IFM_LEN_CEIL / WORD_SCALE;
        LSU0_SEG_COUNT = OFM_BLK_LEN / 2;
        LSU0_LEN = IFM_BLK_LEN / WORD_SCALE;
        LSU0_MODE = 1;

        TQ_LSU0_START();

        if (ofm_len >= 32) {
          LSU1_RAM_START_IDX = 16;
          LSU1_RAM_ADDR_OFFSET = 0;
          LSU1_RAM_BLOCK_FACTOR = 1;
          LSU1_RAM_CYCLIC_FACTOR = 16;
          ext_mem_offset = EXT_MEM_OFFSET + ((i * OFM_CNT * OFM_BLK_LEN * IFM_LEN_CEIL + k * OFM_BLK_LEN * IFM_LEN_CEIL + j * IFM_CNT * IFM_BLK_LEN + t * IFM_BLK_LEN + (OFM_BLK_LEN / 2) * IFM_LEN_CEIL) << LOG2_WORD_SIZE);
          LSU1_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
          LSU1_M_OFFSET_HI = (ext_mem_offset >> 32);
          LSU1_SEG_STRIDE = IFM_LEN_CEIL / WORD_SCALE;
          LSU1_SEG_COUNT = OFM_BLK_LEN / 2;
          LSU1_LEN = IFM_BLK_LEN / WORD_SCALE;
          LSU1_MODE = 1;

          TQ_LSU1_START();
          TQ_LSU1_DONE();
        }

        TQ_LSU0_DONE();

        KRN_INIT_OFM = (j == 0) && (t == 0);
        KRN_IFM_OFFSET = t * IFM_BLK_LEN / LSU_WIDTH_SCALE;
        KRN_OFM_OFFSET = k * OFM_BLK_LEN / LSU_WIDTH_SCALE;
        KRN_IFM_LEN = ifm_len;
        KRN_OFM_LEN = ofm_len;
        KRN_START = 1;
        TQ_CL_START();
        TQ_CL_DONE();
      }
    }
    }

    // write ofm
    int ofm_len_tmp = ((ofm_len + WORD_SCALE - 1) / WORD_SCALE) * WORD_SCALE;
    LSU0_RAM_START_IDX =33;
    LSU0_RAM_ADDR_OFFSET = 0;
    LSU0_RAM_BLOCK_FACTOR = OFM_CNT * ofm_len_tmp / LSU_WIDTH_SCALE;
    LSU0_RAM_CYCLIC_FACTOR = 1;
    ext_mem_offset = EXT_MEM_OFFSET + ((WT_LEN + IFM_LEN_CEIL + i * OFM_CNT * OFM_BLK_LEN) << LOG2_WORD_SIZE);
    LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
    LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);
    LSU0_SEG_STRIDE = 0;
    LSU0_SEG_COUNT = 1;
    LSU0_LEN = OFM_CNT * ofm_len_tmp / WORD_SCALE;
    LSU0_MODE = 2;

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
