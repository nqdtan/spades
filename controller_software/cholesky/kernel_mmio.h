
#define KRN_START    (*((volatile unsigned int*) 0x80000000))
#define KRN_DONE     (*((volatile unsigned int*) 0x80000000) & 0x2)
#define KRN_IDLE     (*((volatile unsigned int*) 0x80000000) & 0x4)

// cl flow
#define KRN_STATE (*((volatile unsigned int*) 0x80000004))
#define KRN_PP    (*((volatile unsigned int*) 0x80000008))
#define KRN_I     (*((volatile unsigned int*) 0x8000000c))
#define KRN_J     (*((volatile unsigned int*) 0x80000010))
