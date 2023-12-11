#define KRN_START (*((volatile unsigned int*) 0x80000000))
#define KRN_DONE (*((volatile unsigned int*) 0x80000000) & 0x2)

// cl flow
#define KRN_IFM_LEN  (*((volatile unsigned int*) 0x80000004))
#define KRN_OFM_LEN  (*((volatile unsigned int*) 0x80000008))
#define KRN_INIT_OFM (*((volatile unsigned int*) 0x8000000c))
#define KRN_IFM_OFFSET  (*((volatile unsigned int*) 0x80000010))
#define KRN_OFM_OFFSET  (*((volatile unsigned int*) 0x80000014))


