
#define KRN_START    (*((volatile unsigned int*) 0x80000000))
#define KRN_DONE     (*((volatile unsigned int*) 0x80000000) & 0x2)
#define KRN_IDLE     (*((volatile unsigned int*) 0x80000000) & 0x4)

// cl flow
#define KRN_N         (*((volatile unsigned int*) 0x80000004))
#define KRN_ROW_BEGIN (*((volatile unsigned int*) 0x80000008))
#define KRN_ROW_END   (*((volatile unsigned int*) 0x8000000c))
#define KRN_LEN1      (*((volatile unsigned int*) 0x80000010))
#define KRN_LEN2      (*((volatile unsigned int*) 0x80000014))
#define KRN_I         (*((volatile unsigned int*) 0x80000018))
#define KRN_K0        (*((volatile unsigned int*) 0x8000001c))
#define KRN_STATE     (*((volatile unsigned int*) 0x80000020))
#define KRN_PP        (*((volatile unsigned int*) 0x80000024))
#define KRN_K1        (*((volatile unsigned int*) 0x80000028))
#define KRN_K2        (*((volatile unsigned int*) 0x8000002c))
#define KRN_MAXLEN    (*((volatile unsigned int*) 0x80000030))
#define KRN_CUR_PTR   (*((volatile unsigned int*) 0x80000034))
