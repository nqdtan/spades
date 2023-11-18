#include "memory_map.h"
#include "kernel_mmio.h"

#define MAT_DIM 1024
#define BHA_DIM 64
#define BWA_DIM 24
#define BWB_DIM 64
#define BHB_DIM (BWA_DIM)

#define CORE_ID 8
#define NUM_CORES 9

int main() {
  long long int ext_mem_offset;

  LSU0_RAM_STRIDE = 1;
  LSU0_RAM_SEG_STRIDE = 1;
  LSU0_RAM_ADDR_OFFSET = 0;
  LSU0_M_OFFSET_HI = 0;

  LSU1_RAM_STRIDE = 1;
  LSU1_RAM_SEG_STRIDE = 1;
  LSU1_RAM_ADDR_OFFSET = 0;
  LSU1_M_OFFSET_HI = 0;

  for (int idx = CORE_ID; idx < (MAT_DIM / BHA_DIM) * (MAT_DIM / BWB_DIM); idx+=NUM_CORES) {
    int i = idx / (MAT_DIM / BWB_DIM);
    int j = idx % (MAT_DIM / BWB_DIM);

    // read c
    LSU0_RAM_START_IDX = 48;
    LSU0_RAM_BLOCK_FACTOR = 1;
    LSU0_RAM_CYCLIC_FACTOR = 4;

    ext_mem_offset = EXT_MEM_OFFSET + ((2 * MAT_DIM * MAT_DIM + i * MAT_DIM * BHA_DIM + j * BWB_DIM) << 3);
    LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
    LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);
    LSU0_SEG_STRIDE = MAT_DIM / 8;
    LSU0_SEG_COUNT = BHA_DIM;
    LSU0_LEN = BWB_DIM / 8;
    LSU0_MODE = 1;

    TQ_LSU0_START();
    TQ_LSU0_DONE();

    LSU0_RAM_BLOCK_FACTOR = 2;
    LSU0_RAM_CYCLIC_FACTOR = BWA_DIM / 2;
    LSU0_SEG_STRIDE = MAT_DIM / 8;
    LSU0_SEG_COUNT = BHA_DIM;
    LSU0_LEN = BWA_DIM / 8;
    LSU0_MODE = 1;

    LSU1_RAM_BLOCK_FACTOR = BWB_DIM * 2;
    LSU1_RAM_CYCLIC_FACTOR = BWA_DIM / 2;
    //LSU1_RAM_BLOCK_FACTOR = 2;
    //LSU1_RAM_CYCLIC_FACTOR = BWA_DIM / 2;
    LSU1_SEG_STRIDE = MAT_DIM / 8;
    LSU1_SEG_COUNT = BHB_DIM;
    LSU1_LEN = BWB_DIM / 8;
    LSU1_MODE = 1;

    int pp = 0;
    int k;
    for (k = 0; k < ((MAT_DIM + BWA_DIM - 1) / BWA_DIM); k++) {
    //for (int k = 0; k < 1; k++) {

      //KRN_LEN = (k == ((MAT_DIM + BWA_DIM - 1) / BWA_DIM) - 1) ? (MAT_DIM - k * BWA_DIM) : BWA_DIM;
      KRN_LEN = BWA_DIM;

      if (pp == 0) {
        KRN_PP = 2;
        // read a
        LSU0_RAM_START_IDX = 0;
        ext_mem_offset = EXT_MEM_OFFSET + ((i * MAT_DIM * BHA_DIM + k * BWA_DIM) << 3);
        LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
        LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);

        // read b
        LSU1_RAM_START_IDX = 24;
        ext_mem_offset = EXT_MEM_OFFSET + ((MAT_DIM * MAT_DIM + k * MAT_DIM * BHB_DIM + j * BWB_DIM) << 3);
        LSU1_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
        LSU1_M_OFFSET_HI = (ext_mem_offset >> 32);

        pp = 1;
      } else {
        KRN_PP = 1;
        // read a
        LSU0_RAM_START_IDX = 12;
        ext_mem_offset = EXT_MEM_OFFSET + ((i * MAT_DIM * BHA_DIM + k * BWA_DIM) << 3);
        LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
        LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);

        // read b
        LSU1_RAM_START_IDX = 36;
        ext_mem_offset = EXT_MEM_OFFSET + ((MAT_DIM * MAT_DIM + k * MAT_DIM * BHB_DIM + j * BWB_DIM) << 3);
        LSU1_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
        LSU1_M_OFFSET_HI = (ext_mem_offset >> 32);

        pp = 0;
      }
      TQ_LSU0_START();
      TQ_LSU1_START();
      if (k != 0) {
        KRN_START = 1;
        TQ_CL_START();
        TQ_CL_DONE();
      }
      TQ_LSU0_DONE();
      TQ_LSU1_DONE();
    }

    KRN_LEN = MAT_DIM - (k - 1) * BWA_DIM;
    KRN_PP = pp == 0 ? 2 : 1;
    KRN_START = 1;
    TQ_CL_START();
    TQ_CL_DONE();

    // write c
    LSU0_RAM_START_IDX = 48;
    LSU0_RAM_BLOCK_FACTOR = 1;
    LSU0_RAM_CYCLIC_FACTOR = 4;

    ext_mem_offset = EXT_MEM_OFFSET + ((2 * MAT_DIM * MAT_DIM + i * MAT_DIM * BHA_DIM + j * BWB_DIM) << 3);
    LSU0_M_OFFSET_LO = (ext_mem_offset & 0xFFFFFFFF);
    LSU0_M_OFFSET_HI = (ext_mem_offset >> 32);

    LSU0_SEG_STRIDE = MAT_DIM / 8;
    LSU0_SEG_COUNT = BHA_DIM;
    LSU0_LEN = BWB_DIM / 8;
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
