#include "memory_map.h"
#include "kernel_mmio.h"

#define IFM_DIM 13
#define WT_DIM 3
#define PAD 1
#define OFM_DIM (IFM_DIM + 2 * PAD - WT_DIM + 1)

#define WT_SIZE_CEIL  (((WT_DIM * WT_DIM + 7) / 8) * 8)
#define IFM_SIZE_CEIL (((IFM_DIM * IFM_DIM + 7) / 8) * 8)
#define OFM_SIZE_CEIL (((OFM_DIM * OFM_DIM + 7) / 8) * 8)

#define WORD_SCALE (512 / 32)
#define LOG2_WORD_SIZE 2

#define CORE_ID 0

int main() {

  LSU0_RAM_STRIDE = 1;
  LSU0_RAM_SEG_STRIDE = 1;
  LSU0_RAM_ADDR_OFFSET = 0;
  LSU0_M_OFFSET_HI = 0;

  LSU0_RAM_START_IDX = 0;
  LSU0_RAM_BLOCK_FACTOR = 1;
  LSU0_RAM_CYCLIC_FACTOR = 1;

  // fetch weight and ifm
  LSU0_M_OFFSET_LO = (0) << LOG2_WORD_SIZE;
  LSU0_SEG_STRIDE = 0;
  LSU0_SEG_COUNT = 1;
  LSU0_LEN = (WT_SIZE_CEIL + IFM_SIZE_CEIL) / WORD_SCALE;
  LSU0_MODE = 1;

  TQ_LSU0_START();
  TQ_LSU0_DONE();

  // fetch ofm
  LSU0_RAM_START_IDX = 1;
  LSU0_M_OFFSET_LO = (WT_SIZE_CEIL + IFM_SIZE_CEIL) << LOG2_WORD_SIZE;
  LSU0_LEN = (OFM_SIZE_CEIL) / WORD_SCALE;
  LSU0_MODE = 1;

  TQ_LSU0_START();
  TQ_LSU0_DONE();

  KRN_START = 1;
  TQ_CL_START();
  TQ_CL_DONE();

  // write ofm
  LSU0_RAM_START_IDX = 1;
  LSU0_M_OFFSET_LO = (WT_SIZE_CEIL + IFM_SIZE_CEIL) << LOG2_WORD_SIZE;
  LSU0_LEN = (OFM_SIZE_CEIL) / WORD_SCALE;
  LSU0_MODE = 2;

  TQ_LSU0_START();
  TQ_LSU0_DONE();

  while (TQ_EMPTY_N == 1);

  CTRL_MAXI_SOCKET_OFFSET_LO = (SOCKET_MANAGER_NOC_ADDR & 0xFFFFFFFF) + ((128 + CORE_ID)<<6); 
  CTRL_MAXI_SOCKET_OFFSET_HI = (SOCKET_MANAGER_NOC_ADDR >> 32);
  CTRL_MAXI_WRITE = 1;
  while (CTRL_MAXI_WRITE_DONE == 0);

  CPU_STATUS = 1;

  // spin
  for(;;) {
    asm volatile ("nop");
  }
}
