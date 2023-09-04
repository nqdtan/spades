
#define LSU0_CSR               (*((volatile unsigned int*) 0x80000100))
#define LSU0_DONE              (*((volatile unsigned int*) 0x80000100) & 0x2)
#define LSU0_RAM_START_IDX     (*((volatile unsigned int*) 0x80000104))
#define LSU0_RAM_BLOCK_FACTOR  (*((volatile unsigned int*) 0x80000108))
#define LSU0_RAM_CYCLIC_FACTOR (*((volatile unsigned int*) 0x8000010c))
#define LSU0_RAM_STRIDE        (*((volatile unsigned int*) 0x80000110))
#define LSU0_RAM_SEG_STRIDE    (*((volatile unsigned int*) 0x80000114))
#define LSU0_RAM_ADDR_OFFSET   (*((volatile unsigned int*) 0x80000118))

#define LSU0_M_OFFSET_LO       (*((volatile unsigned int*) 0x8000011c))
#define LSU0_M_OFFSET_HI       (*((volatile unsigned int*) 0x80000120))
#define LSU0_SEG_STRIDE        (*((volatile unsigned int*) 0x80000124))
#define LSU0_SEG_COUNT         (*((volatile unsigned int*) 0x80000128))
#define LSU0_LEN               (*((volatile unsigned int*) 0x8000012c))
#define LSU0_MODE              (*((volatile unsigned int*) 0x80000130))

#define LSU1_CSR               (*((volatile unsigned int*) 0x80000200))
#define LSU1_DONE              (*((volatile unsigned int*) 0x80000200) & 0x2)
#define LSU1_RAM_START_IDX     (*((volatile unsigned int*) 0x80000204))
#define LSU1_RAM_BLOCK_FACTOR  (*((volatile unsigned int*) 0x80000208))
#define LSU1_RAM_CYCLIC_FACTOR (*((volatile unsigned int*) 0x8000020c))
#define LSU1_RAM_STRIDE        (*((volatile unsigned int*) 0x80000210))
#define LSU1_RAM_SEG_STRIDE    (*((volatile unsigned int*) 0x80000214))
#define LSU1_RAM_ADDR_OFFSET   (*((volatile unsigned int*) 0x80000218))

#define LSU1_M_OFFSET_LO       (*((volatile unsigned int*) 0x8000021c))
#define LSU1_M_OFFSET_HI       (*((volatile unsigned int*) 0x80000220))
#define LSU1_SEG_STRIDE        (*((volatile unsigned int*) 0x80000224))
#define LSU1_SEG_COUNT         (*((volatile unsigned int*) 0x80000228))
#define LSU1_LEN               (*((volatile unsigned int*) 0x8000022c))
#define LSU1_MODE              (*((volatile unsigned int*) 0x80000230))

#define COMM0_MODE             (*((volatile unsigned int*) 0x80000234))
#define COMM1_MODE             (*((volatile unsigned int*) 0x80000238))

#define TQ_WDATA               (*((volatile unsigned int*) 0x80000240))
#define TQ_EMPTY_N             (*((volatile unsigned int*) 0x80000244))
#define TQ_FULL_N              (*((volatile unsigned int*) 0x80000248))

#define CL_CFG_ENQ             (*((volatile unsigned int*) 0x8000024c))

#define TQ_LSU0_START() { \
  TQ_WDATA = (1 << 1) | 1; \
}
#define TQ_LSU0_DONE() { \
  TQ_WDATA = (2 << 1) | 1; \
}
#define TQ_LSU1_START() { \
  TQ_WDATA = (3 << 1) | 1; \
}
#define TQ_LSU1_DONE() { \
  TQ_WDATA = (4 << 1) | 1; \
}
#define TQ_CL_START() { \
  TQ_WDATA = (5 << 1) | 1; \
}
#define TQ_CL_DONE() { \
  TQ_WDATA = (6 << 1) | 1; \
}

#define SYNC(x)        (*((volatile unsigned int*) (0x80000150 + (x << 2))))
#define SYNC0        (*((volatile unsigned int*) 0x80000150))
#define SYNC1        (*((volatile unsigned int*) 0x80000154))
#define SYNC2        (*((volatile unsigned int*) 0x80000158))
#define SYNC3        (*((volatile unsigned int*) 0x8000015c))
#define SYNC4        (*((volatile unsigned int*) 0x80000160))
#define SYNC5        (*((volatile unsigned int*) 0x80000164))
#define SYNC6        (*((volatile unsigned int*) 0x80000168))
#define SYNC7        (*((volatile unsigned int*) 0x8000016c))
#define SYNC8        (*((volatile unsigned int*) 0x80000170))
#define SYNC9        (*((volatile unsigned int*) 0x80000174))
#define SYNC10       (*((volatile unsigned int*) 0x80000178))
#define SYNC11       (*((volatile unsigned int*) 0x8000017c))
#define SYNC12       (*((volatile unsigned int*) 0x80000180))
#define SYNC13       (*((volatile unsigned int*) 0x80000184))
#define SYNC14       (*((volatile unsigned int*) 0x80000188))
#define SYNC15       (*((volatile unsigned int*) 0x8000018c))

#define SQUEUE            (*((volatile unsigned int*) 0x80000190))
#define SQUEUE_FULL       (*((volatile unsigned int*) 0x80000194) & 0x1)

#define MEM_UNIT_CTRL  (*((volatile unsigned int*) 0x80000314))
#define MEM_UNIT_ADDR  (*((volatile unsigned int*) 0x80000318))
#define MEM_UNIT_WDATA (*((volatile unsigned int*) 0x8000031c))
#define MEM_UNIT_RDATA (*((volatile unsigned int*) 0x80000320))

#define TASK_EMPTY  (*((volatile unsigned int*) 0x80000344))
#define TASK_END    (*((volatile unsigned int*) 0x80000348))
#define TASK_ADV    (*((volatile unsigned int*) 0x8000034c))

#define CTRL_MAXI_READ             (*((volatile unsigned int*) 0x80000354))
#define CTRL_MAXI_READ_DONE        (*((volatile unsigned int*) 0x80000354) & 0x2)
#define CTRL_MAXI_WRITE            (*((volatile unsigned int*) 0x80000358))
#define CTRL_MAXI_WRITE_DONE       (*((volatile unsigned int*) 0x80000358) & 0x2)
#define CTRL_MAXI_RDATA            (*((volatile unsigned int*) 0x8000035c))
#define CTRL_MAXI_WDATA            (*((volatile unsigned int*) 0x80000360))
#define CTRL_MAXI_SOCKET_OFFSET_LO (*((volatile unsigned int*) 0x80000364))
#define CTRL_MAXI_SOCKET_OFFSET_HI (*((volatile unsigned int*) 0x80000368))

#define SOCKET_INBOX (*((volatile unsigned int*) 0x8000036c))

#define DMA0_WRITE_IDLE (*((volatile unsigned int*) 0x80000370))
#define DMA1_WRITE_IDLE (*((volatile unsigned int*) 0x80000374))

#define CPU_STATUS (*((volatile unsigned int*) 0x80000350))

#define BYTE_SIZE 64//32
#define SYNC_OFFSET(x)   (x * BYTE_SIZE)
#define SYNC0_OFFSET   (0 * BYTE_SIZE)
#define SYNC1_OFFSET   (1 * BYTE_SIZE)
#define SYNC2_OFFSET   (2 * BYTE_SIZE)
#define SYNC3_OFFSET   (3 * BYTE_SIZE)
#define SYNC4_OFFSET   (4 * BYTE_SIZE)
#define SYNC5_OFFSET   (5 * BYTE_SIZE)
#define SYNC6_OFFSET   (6 * BYTE_SIZE)
#define SYNC7_OFFSET   (7 * BYTE_SIZE)
#define SYNC8_OFFSET   (8 * BYTE_SIZE)
#define SYNC9_OFFSET   (9 * BYTE_SIZE)
#define SYNC10_OFFSET  (10 * BYTE_SIZE)
#define SYNC11_OFFSET  (11 * BYTE_SIZE)
#define SYNC12_OFFSET  (12 * BYTE_SIZE)
#define SYNC13_OFFSET  (13 * BYTE_SIZE)
#define SYNC14_OFFSET  (14 * BYTE_SIZE)
#define SYNC15_OFFSET  (15 * BYTE_SIZE)

//#define RTL_SIM

#ifdef RTL_SIM
#define SOCKET_MANAGER_NOC_ADDR 0x20100000000
#define SOCKET0_NOC_ADDR        0x20140000000
#define SOCKET1_NOC_ADDR        0x20180000000

#else
#define SOCKET_MANAGER_NOC_ADDR 0x20204000000
#define SOCKET0_NOC_ADDR        0x20100000000
#define SOCKET1_NOC_ADDR        0x20140000000

#endif
