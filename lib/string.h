#ifndef	STRING_H
#define STRING_H
#include "stdint.h"
void memset(void *dst, uint8_t value, uint32_t size);//将dst起始的size个字节设置为value
void memcpy(void *dst, const void *src, uint32_t size);//将src起始的size个字节复制到dst
int memcmp(const void *a, const void *b, uint32_t size);//连续比较以地址a和地址b开头的size个字节，相等返回0，a>b返回1，否则返回-1
char* strcpy(char *dst, const char *src);//将字符串从src复制到dst
uint32_t strlen(const char *str);//返回字符串的长度
int8_t strcmp(const char *a, const char *b);//比较2个字符串，a中字符大于b时返回1，等于返回0，否则返回-1
char* strchr(const char *string, const uint8_t ch);//从左到右查找字符串str中首次出现字符ch的位置
char* strrchr(const char *string, const uint8_t ch);//从后往前查找字符串str中首次出现字符ch的位置
char* strcat(char *dst, const char* src);//将字符串src拼接到dst后，返回拼接的地址
uint32_t strchrs(const char* str, uint8_t ch);//在字符串str中查找字符ch出现的次数
int32_t strStr(const char *T, const char *P);  //检查T中是否存在P，存在返回下标，不存在返回-1，P为空返回下标0 KMP实现





#endif
