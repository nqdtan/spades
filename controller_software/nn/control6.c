#include "memory_map.h"
#include "kernel_mmio_linear.h"
#include "nn.h"

#define CORE_ID 6
#define NUM_CORES 9

#define LINEAR_CORE_ID 2
#define LINEAR_NUM_CORES 5

#define LINEAR_CORE_ID_START 4

void sync_with_linear_master_core() {
  CTRL_MAXI_SOCKET_OFFSET_LO = ((SOCKET4_NOC_ADDR + MMIO_REGSPACE_OFFSET) & 0xFFFFFFFF) + SYNC_OFFSET(CORE_ID); 
  CTRL_MAXI_SOCKET_OFFSET_HI = ((SOCKET4_NOC_ADDR + MMIO_REGSPACE_OFFSET) >> 32);
  CTRL_MAXI_WRITE = 1;
  while (CTRL_MAXI_WRITE_DONE == 0);

  while (SYNC(LINEAR_CORE_ID_START) == 0);
  SYNC(LINEAR_CORE_ID_START) = 0;
}

int main() {
  long long int ext_mem_offset;

  sync_with_linear_master_core();

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

  for (int i = LINEAR_CORE_ID; i < (LINEAR0_OFM_LEN + (LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN) - 1) / (LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN); i+=LINEAR_NUM_CORES) {
    int ofm_len = ((i + 1) * LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN > LINEAR0_OFM_LEN) ? (LINEAR0_OFM_LEN - i * LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN) : LINEAR_OFM_BLK_LEN;

    for (int j = 0; j < (LINEAR0_IFM_LEN + (LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN) - 1) / (LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN); j+=1) {
      int ifm_len0 = ((j + 1) * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN > LINEAR0_IFM_LEN) ?
        (LINEAR0_IFM_LEN - j * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN) : (LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN);
      int ifm_cnt = ((j + 1) * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN > LINEAR0_IFM_LEN) ? (ifm_len0 / LINEAR_IFM_BLK_LEN) : LINEAR_IFM_CNT;
      int ifm_len = (ifm_len0 >= LINEAR_IFM_BLK_LEN) ? LINEAR_IFM_BLK_LEN : ifm_len0;

      // fetch ifm
      LSU0_RAM_START_IDX = 32;
      LSU0_RAM_ADDR_OFFSET = 0;
      LSU0_RAM_BLOCK_FACTOR = LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN / LSU_WIDTH_SCALE;
      LSU0_RAM_CYCLIC_FACTOR = 1;
      ext_mem_offset = EXT_MEM_OFFSET + ((LINEAR0_MEM_OFFSET + j * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN) << LOG2_WORD_SIZE);
      LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
      LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);
      LSU0_SEG_STRIDE = 0;
      LSU0_SEG_COUNT = 1;
      LSU0_LEN = LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN / WORD_SCALE;
      LSU0_MODE = 1;

      TQ_LSU0_START();
      TQ_LSU0_DONE();

      for (int t = 0; t < ifm_cnt; t++) {
      for (int k = 0; k < LINEAR_OFM_CNT; k++) {
        // fetch wt
        LSU0_RAM_START_IDX = 0;
        LSU0_RAM_ADDR_OFFSET = 0;
        LSU0_RAM_BLOCK_FACTOR = 1;
        LSU0_RAM_CYCLIC_FACTOR = 16;
        ext_mem_offset = EXT_MEM_OFFSET + ((LINEAR0_MEM_OFFSET + LINEAR0_IFM_LEN_CEIL + i * LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN * LINEAR0_IFM_LEN_CEIL + k * LINEAR_OFM_BLK_LEN * LINEAR0_IFM_LEN_CEIL + j * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN + t * LINEAR_IFM_BLK_LEN) << LOG2_WORD_SIZE);
        LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
        LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);
        LSU0_SEG_STRIDE = LINEAR0_IFM_LEN_CEIL / WORD_SCALE;
        LSU0_SEG_COUNT = LINEAR_OFM_BLK_LEN / 2;
        LSU0_LEN = LINEAR_IFM_BLK_LEN / WORD_SCALE;
        LSU0_MODE = 1;

        TQ_LSU0_START();

        if (ofm_len >= 32) {
          LSU1_RAM_START_IDX = 16;
          LSU1_RAM_ADDR_OFFSET = 0;
          LSU1_RAM_BLOCK_FACTOR = 1;
          LSU1_RAM_CYCLIC_FACTOR = 16;
          ext_mem_offset = EXT_MEM_OFFSET + ((LINEAR0_MEM_OFFSET + LINEAR0_IFM_LEN_CEIL + i * LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN * LINEAR0_IFM_LEN_CEIL + k * LINEAR_OFM_BLK_LEN * LINEAR0_IFM_LEN_CEIL + j * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN + t * LINEAR_IFM_BLK_LEN + (LINEAR_OFM_BLK_LEN / 2) * LINEAR0_IFM_LEN_CEIL) << LOG2_WORD_SIZE);
          LSU1_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
          LSU1_M_OFFSET_HI = (ext_mem_offset >> 32);
          LSU1_SEG_STRIDE = LINEAR0_IFM_LEN_CEIL / WORD_SCALE;
          LSU1_SEG_COUNT = LINEAR_OFM_BLK_LEN / 2;
          LSU1_LEN = LINEAR_IFM_BLK_LEN / WORD_SCALE;
          LSU1_MODE = 1;

          TQ_LSU1_START();
          TQ_LSU1_DONE();
        }

        TQ_LSU0_DONE();

        KRN_INIT_OFM = (j == 0) && (t == 0);
        KRN_IFM_OFFSET = t * LINEAR_IFM_BLK_LEN / LSU_WIDTH_SCALE;
        KRN_OFM_OFFSET = k * LINEAR_OFM_BLK_LEN / LSU_WIDTH_SCALE;
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
    LSU0_RAM_BLOCK_FACTOR = LINEAR_OFM_CNT * ofm_len_tmp / LSU_WIDTH_SCALE;
    LSU0_RAM_CYCLIC_FACTOR = 1;
    ext_mem_offset = EXT_MEM_OFFSET + ((LINEAR0_MEM_OFFSET + LINEAR0_WT_LEN + LINEAR0_IFM_LEN_CEIL + i * LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN) << LOG2_WORD_SIZE);
    LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
    LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);
    LSU0_SEG_STRIDE = 0;
    LSU0_SEG_COUNT = 1;
    LSU0_LEN = LINEAR_OFM_CNT * ofm_len_tmp / WORD_SCALE;
    LSU0_MODE = 2;

    TQ_LSU0_START();
    TQ_LSU0_DONE();
  }

  while (TQ_EMPTY_N == 1);

  sync_with_linear_master_core();

  for (int i = LINEAR_CORE_ID; i < (LINEAR1_OFM_LEN + (LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN) - 1) / (LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN); i+=LINEAR_NUM_CORES) {
    int ofm_len = ((i + 1) * LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN > LINEAR1_OFM_LEN) ? (LINEAR1_OFM_LEN - i * LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN) : LINEAR_OFM_BLK_LEN;

    for (int j = 0; j < (LINEAR1_IFM_LEN + (LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN) - 1) / (LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN); j+=1) {
      int ifm_len0 = ((j + 1) * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN > LINEAR1_IFM_LEN) ?
        (LINEAR1_IFM_LEN - j * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN) : (LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN);
      int ifm_cnt = ((j + 1) * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN > LINEAR1_IFM_LEN) ? (ifm_len0 / LINEAR_IFM_BLK_LEN) : LINEAR_IFM_CNT;
      int ifm_len = (ifm_len0 >= LINEAR_IFM_BLK_LEN) ? LINEAR_IFM_BLK_LEN : ifm_len0;

      // fetch ifm
      LSU0_RAM_START_IDX = 32;
      LSU0_RAM_ADDR_OFFSET = 0;
      LSU0_RAM_BLOCK_FACTOR = LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN / LSU_WIDTH_SCALE;
      LSU0_RAM_CYCLIC_FACTOR = 1;
      ext_mem_offset = EXT_MEM_OFFSET + ((LINEAR1_MEM_OFFSET + j * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN) << LOG2_WORD_SIZE);
      LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
      LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);
      LSU0_SEG_STRIDE = 0;
      LSU0_SEG_COUNT = 1;
      LSU0_LEN = LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN / WORD_SCALE;
      LSU0_MODE = 1;

      TQ_LSU0_START();
      TQ_LSU0_DONE();

      for (int t = 0; t < ifm_cnt; t++) {
      for (int k = 0; k < LINEAR_OFM_CNT; k++) {
        // fetch wt
        LSU0_RAM_START_IDX = 0;
        LSU0_RAM_ADDR_OFFSET = 0;
        LSU0_RAM_BLOCK_FACTOR = 1;
        LSU0_RAM_CYCLIC_FACTOR = 16;
        ext_mem_offset = EXT_MEM_OFFSET + ((LINEAR1_MEM_OFFSET + LINEAR1_IFM_LEN_CEIL + i * LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN * LINEAR1_IFM_LEN_CEIL + k * LINEAR_OFM_BLK_LEN * LINEAR1_IFM_LEN_CEIL + j * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN + t * LINEAR_IFM_BLK_LEN) << LOG2_WORD_SIZE);
        LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
        LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);
        LSU0_SEG_STRIDE = LINEAR1_IFM_LEN_CEIL / WORD_SCALE;
        LSU0_SEG_COUNT = LINEAR_OFM_BLK_LEN / 2;
        LSU0_LEN = LINEAR_IFM_BLK_LEN / WORD_SCALE;
        LSU0_MODE = 1;

        TQ_LSU0_START();

        if (ofm_len >= 32) {
          LSU1_RAM_START_IDX = 16;
          LSU1_RAM_ADDR_OFFSET = 0;
          LSU1_RAM_BLOCK_FACTOR = 1;
          LSU1_RAM_CYCLIC_FACTOR = 16;
          ext_mem_offset = EXT_MEM_OFFSET + ((LINEAR1_MEM_OFFSET + LINEAR1_IFM_LEN_CEIL + i * LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN * LINEAR1_IFM_LEN_CEIL + k * LINEAR_OFM_BLK_LEN * LINEAR1_IFM_LEN_CEIL + j * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN + t * LINEAR_IFM_BLK_LEN + (LINEAR_OFM_BLK_LEN / 2) * LINEAR1_IFM_LEN_CEIL) << LOG2_WORD_SIZE);
          LSU1_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
          LSU1_M_OFFSET_HI = (ext_mem_offset >> 32);
          LSU1_SEG_STRIDE = LINEAR1_IFM_LEN_CEIL / WORD_SCALE;
          LSU1_SEG_COUNT = LINEAR_OFM_BLK_LEN / 2;
          LSU1_LEN = LINEAR_IFM_BLK_LEN / WORD_SCALE;
          LSU1_MODE = 1;

          TQ_LSU1_START();
          TQ_LSU1_DONE();
        }

        TQ_LSU0_DONE();

        KRN_INIT_OFM = (j == 0) && (t == 0);
        KRN_IFM_OFFSET = t * LINEAR_IFM_BLK_LEN / LSU_WIDTH_SCALE;
        KRN_OFM_OFFSET = k * LINEAR_OFM_BLK_LEN / LSU_WIDTH_SCALE;
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
    LSU0_RAM_BLOCK_FACTOR = LINEAR_OFM_CNT * ofm_len_tmp / LSU_WIDTH_SCALE;
    LSU0_RAM_CYCLIC_FACTOR = 1;
    ext_mem_offset = EXT_MEM_OFFSET + ((LINEAR1_MEM_OFFSET + LINEAR1_WT_LEN + LINEAR1_IFM_LEN_CEIL + i * LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN) << LOG2_WORD_SIZE);
    LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
    LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);
    LSU0_SEG_STRIDE = 0;
    LSU0_SEG_COUNT = 1;
    LSU0_LEN = LINEAR_OFM_CNT * ofm_len_tmp / WORD_SCALE;
    LSU0_MODE = 2;

    TQ_LSU0_START();
    TQ_LSU0_DONE();
  }

  while (TQ_EMPTY_N == 1);

  sync_with_linear_master_core();

  for (int i = LINEAR_CORE_ID; i < (LINEAR2_OFM_LEN + (LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN) - 1) / (LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN); i+=LINEAR_NUM_CORES) {
    int ofm_len = ((i + 1) * LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN > LINEAR2_OFM_LEN) ? (LINEAR2_OFM_LEN - i * LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN) : LINEAR_OFM_BLK_LEN;

    for (int j = 0; j < (LINEAR2_IFM_LEN + (LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN) - 1) / (LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN); j+=1) {
      int ifm_len0 = ((j + 1) * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN > LINEAR2_IFM_LEN) ?
        (LINEAR2_IFM_LEN - j * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN) : (LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN);
      int ifm_cnt = ((j + 1) * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN > LINEAR2_IFM_LEN) ? (ifm_len0 / LINEAR_IFM_BLK_LEN) : LINEAR_IFM_CNT;
      int ifm_len = (ifm_len0 >= LINEAR_IFM_BLK_LEN) ? LINEAR_IFM_BLK_LEN : ifm_len0;

      // fetch ifm
      LSU0_RAM_START_IDX = 32;
      LSU0_RAM_ADDR_OFFSET = 0;
      LSU0_RAM_BLOCK_FACTOR = LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN / LSU_WIDTH_SCALE;
      LSU0_RAM_CYCLIC_FACTOR = 1;
      ext_mem_offset = EXT_MEM_OFFSET + ((LINEAR2_MEM_OFFSET + j * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN) << LOG2_WORD_SIZE);
      LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
      LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);
      LSU0_SEG_STRIDE = 0;
      LSU0_SEG_COUNT = 1;
      LSU0_LEN = LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN / WORD_SCALE;
      LSU0_MODE = 1;

      TQ_LSU0_START();
      TQ_LSU0_DONE();

      for (int t = 0; t < ifm_cnt; t++) {
      for (int k = 0; k < LINEAR_OFM_CNT; k++) {
        // fetch wt
        LSU0_RAM_START_IDX = 0;
        LSU0_RAM_ADDR_OFFSET = 0;
        LSU0_RAM_BLOCK_FACTOR = 1;
        LSU0_RAM_CYCLIC_FACTOR = 16;
        ext_mem_offset = EXT_MEM_OFFSET + ((LINEAR2_MEM_OFFSET + LINEAR2_IFM_LEN_CEIL + i * LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN * LINEAR2_IFM_LEN_CEIL + k * LINEAR_OFM_BLK_LEN * LINEAR2_IFM_LEN_CEIL + j * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN + t * LINEAR_IFM_BLK_LEN) << LOG2_WORD_SIZE);
        LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
        LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);
        LSU0_SEG_STRIDE = LINEAR2_IFM_LEN_CEIL / WORD_SCALE;
        LSU0_SEG_COUNT = LINEAR_OFM_BLK_LEN / 2;
        LSU0_LEN = LINEAR_IFM_BLK_LEN / WORD_SCALE;
        LSU0_MODE = 1;

        TQ_LSU0_START();

        if (ofm_len >= 32) {
          LSU1_RAM_START_IDX = 16;
          LSU1_RAM_ADDR_OFFSET = 0;
          LSU1_RAM_BLOCK_FACTOR = 1;
          LSU1_RAM_CYCLIC_FACTOR = 16;
          ext_mem_offset = EXT_MEM_OFFSET + ((LINEAR2_MEM_OFFSET + LINEAR2_IFM_LEN_CEIL + i * LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN * LINEAR2_IFM_LEN_CEIL + k * LINEAR_OFM_BLK_LEN * LINEAR2_IFM_LEN_CEIL + j * LINEAR_IFM_CNT * LINEAR_IFM_BLK_LEN + t * LINEAR_IFM_BLK_LEN + (LINEAR_OFM_BLK_LEN / 2) * LINEAR2_IFM_LEN_CEIL) << LOG2_WORD_SIZE);
          LSU1_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
          LSU1_M_OFFSET_HI = (ext_mem_offset >> 32);
          LSU1_SEG_STRIDE = LINEAR2_IFM_LEN_CEIL / WORD_SCALE;
          LSU1_SEG_COUNT = LINEAR_OFM_BLK_LEN / 2;
          LSU1_LEN = LINEAR_IFM_BLK_LEN / WORD_SCALE;
          LSU1_MODE = 1;

          TQ_LSU1_START();
          TQ_LSU1_DONE();
        }

        TQ_LSU0_DONE();

        KRN_INIT_OFM = (j == 0) && (t == 0);
        KRN_IFM_OFFSET = t * LINEAR_IFM_BLK_LEN / LSU_WIDTH_SCALE;
        KRN_OFM_OFFSET = k * LINEAR_OFM_BLK_LEN / LSU_WIDTH_SCALE;
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
    LSU0_RAM_BLOCK_FACTOR = LINEAR_OFM_CNT * ofm_len_tmp / LSU_WIDTH_SCALE;
    LSU0_RAM_CYCLIC_FACTOR = 1;
    ext_mem_offset = EXT_MEM_OFFSET + ((LINEAR2_MEM_OFFSET + LINEAR2_WT_LEN + LINEAR2_IFM_LEN_CEIL + i * LINEAR_OFM_CNT * LINEAR_OFM_BLK_LEN) << LOG2_WORD_SIZE);
    LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
    LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);
    LSU0_SEG_STRIDE = 0;
    LSU0_SEG_COUNT = 1;
    LSU0_LEN = LINEAR_OFM_CNT * ofm_len_tmp / WORD_SCALE;
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
