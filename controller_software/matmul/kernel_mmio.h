#define KRN_START (*((volatile unsigned int*) 0x80000000))
#define KRN_DONE (*((volatile unsigned int*) 0x80000000) & 0x2)

// cl flow
#define KRN_LEN         (*((volatile unsigned int*) 0x80000004))
#define KRN_PP          (*((volatile unsigned int*) 0x80000008))
