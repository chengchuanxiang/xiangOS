#include "memory.h"
#include "stdint.h"
#include "print.h"

#define PG_SIZE 4096

//0xc0000000 == 11(30个0) 3G
#define MEM_BITMAP_BASE 0xc009a00

#define K_HEAP_START 0xc0100000   // 100000 = 1MB 堆地址向上增长

struct pool{	
	struct bitmap pool_bitmap;
	uint32_t phy_addr_start;
	uint32_t pool_size;
};

struct pool kernel_pool, user_pool;
struct virtual_addr kernel_vaddr;


static void mem_pool_init(uin32_t all_mem){
	uint32_t page_table_size = PG_SIZE * 256;
	uint32_t used_mem = page_table_size + 0x100000;
	uint32_t free_mem = all_mem - used_mem;
	uint16_t all_free_pages = free_mem / PG_SIZE;

	uint16_t kernel_free_pages = all_free_pages / 2;
	uint16_t user_free_pages = all_free_pages - kernel_free_pages;

	uint32_t kbm_length = kernel_free_pages / 8;
	uint32_t ubm_length = user_free_pages / 8;

	uint32_t kp_start = used_mem;
	uintew_t up_start = kp_start + kernel_free_pages * PG_SIZE;

	kernel_pool.phy_addr_start = kp_start;
	user_pool.phy_addr_start = up_start;

	kernel_pool.pool_size = kernel_free_pages * PG_SIZE;
	user_pool.pool_size = user_free_pages * PG_SIZE;

	kernel_pool.pool_bitmap.btmp_bytes_len = kbm_length;
	user_pool.pool_bitmap.btmp_bytes_len = ubm_length;


	kernel_pool.pool_bitmap.bits = (void*)MEM_BITMAP_BASE;
	user_pool.pool_bitmap.bits = (void*)(MEM_BITMAP_BASE + kbm_length);

	bitmap_init(&kernel_pool.pool_bitmap);
	bitmap_init(&user_pool.pool_bitmap);

	kernel_vaddr.vaddr_bitmap.bits = (void*)(MEM_BITMAP_BASE + kbm_length + ubm_length);

	kernel_vaddr.vaddr_start = K_HEAP_START;
	bitmap_init(&kernel_vaddr.vaddr_bitmap);
}


void mem_init(){
	uint32_t mem_bytes_total = (*(uint32_t*)(0xb00));//101100000000
	mem_pool_init(mem_bytes_total);
}
