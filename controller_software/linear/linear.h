#ifndef _LINEAR_H_
#define _LINEAR_H_

#define IFM_LEN 4096
#define OFM_LEN 4096

#define IFM_BLK_LEN 16
#define OFM_BLK_LEN 64
#define IFM_CNT 32
#define OFM_CNT 1

#define IFM_LEN_CEIL (((IFM_LEN + 15) / 16) * 16)
#define OFM_LEN_CEIL (((OFM_LEN + 15) / 16) * 16)
#define WT_LEN       (IFM_LEN_CEIL * OFM_LEN)

#define WORD_SCALE (512 / 32)
#define LOG2_WORD_SIZE 2
#define LSU_WIDTH_SCALE (64 / 32)

#endif
