#ifndef MEMORY_H
#define MEMORY_H
#include "../lib/stdint.h"
#include "../lib/bitmap.h"


struct virtual_addr{
	struct bitmap vaddr_bitmap;
	uint32_t vaddr_start;
};

extern struct pool kernel_pool, user_pool;
void mem_init(void);
#endif
