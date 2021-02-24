#ifndef BITMAP_H
#define BITMAP_H
#include "../../kernel/global.h"
#include "../stdint.h"
#define BITMAP_MASK 1
struct bitmap {
	uint32_t btmp_bytes_len;
	uint8_t *bits;
};
//将位图bitmap初始化
void bitmap_init(struct bitmap *btmp);
//判断bit_idx位是否等于1，若为1，返回true，否则返回false
bool bitmap_scan_test(struct bitmap *btmp, uint32_t bit_idx);
//在位图中连续申请cnt个位，成功返回下标，失败返回-1
int bitmap_scan(struct bitmap *btmp, uint32_t cnt);
//将位图btmp的bit_idx位设置为value
void bitmap_set(struct bitmap *btmp, uint32_t bit_idx, int8_t value);
#endif
