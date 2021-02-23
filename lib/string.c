#include "string.h"
#include "../kernel/global.h"
#include "../kernel/debug.h"
#include "stdint.h"
//---------       strStr()    ------------
//要在动态内存分配实现后再实现

void memset(void *dst, uint8_t value, uint32_t size){
	ASSERT(dst != NULL);
	uint8_t *p = (uint8_t*)dst;
	while(size-- > 0)
		*p++ = value;
}

void memcpy(void *dst, const void *src, uint32_t size){
	ASSERT(dst != NULL && src != NULL);
	uint8_t *pd = (uint8_t*)dst;
	const uint8_t *ps = (uint8_t*)src;
	while(size-- > 0)
		*pd++ = *ps++;
}

int memcmp(const void *a, const void *b, uint32_t size){
	ASSERT(a != NULL && b != NULL);
	const uint8_t *pa = (const uint8_t*)a;
	const uint8_t *pb = (const uint8_t*)b;
	while(size-- > 0){
		if(*pa != *pb){
			return (*pa > *pb)? 1 : -1;
		}
		++pa; ++pb;
	}
	return 0;
}

char* strcpy(char *dst, const char *src){
	ASSERT(dst != NULL && src != NULL);
	char *p = dst;
	while((*dst++ = *src++));
	return p;
}


uint32_t strlen(const char *str){
	ASSERT(str != NULL);
	const char *p = str;
	while((*p++));	//*p++ == *(p++)
	return (p - str - 1);
}

int8_t strcmp(const char *a, const char *b){
	ASSERT(a != NULL && b != NULL);
	while(*a != 0 && *a == *b){
		a++; b++;
	}
	return (*a < *b)? -1 : (*a > *b);
}

char* strchr(const char *string, const uint8_t ch){
	ASSERT(string != NULL);
	while( *string != 0){
		if(*string == ch){
			return (char*)string;
		}
		++string;
	}
	return NULL;
}

char* strtchr(const char *str, const uint8_t ch){
	ASSERT(str != NULL);
	const char *last = str;
	while(*str != 0){
		if(*str == ch){
			last = str;
		}
		++str;
	}
	return (char*)str;
}

char* strcat(char *dst, const char* src){
	ASSERT(dst != NULL && src != NULL);
	char *str = dst;
	while(*str++); // *p++ == *(p++) 终止时p指向空字符后面的一个字符
	--str;			//-- 会到空字符处
	while((*str++ = *src++));
	return dst;
}

uint32_t strchrs(const char *str, uint8_t ch){
	ASSERT(str != NULL);
	uint32_t cnt = 0;
	const char *p = str;
	while(*p != 0){
		if(*p == ch){
			++cnt;
		}
		++p;
	}
	return cnt;
}



