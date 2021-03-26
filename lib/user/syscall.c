#include "syscall.h"

//linux用宏定义一个函数，这里直接使用大括号完成
//大括号中最后一个语句的值回作为大括号代码块的返回值，
//而且要在最后一个语句后添加分号";"，否则编译时会报错
//定义中的斜杠\可以相当于回车换行符号。

//无参数的系统调用。
#define _syscall0(NUMBER)({	\
	int retval;				\
	asm volatile(			\
		"int $0x80"			\
		: "=a" (retval)		\
		: "a"  (NUMBER)		\
		: "memory"			\
		);					\
		retval;				\
})

//一个参数的系统调用
#define _syscall1(NUMBER, ARG1) ({  \
	int retval;						\
	asm volatile (					\
		"int $0x80"					\
		: "=a" (retval)				\
		: "a"(NUMBER), "b" (ARG1)	\
		: "memory"					\
		);							\
		retval;						\
})

//两个参数的系统调用
#define _syscall2(NUMBER, ARG1, ARG2) ({  \
	int retval;
	asm volatile(					\
		"int $0x80"					\
		: "=a"(retval)				\
		: "a"(NUMBER), "b"(ARG1), "c"(ARG2) \
		: "memory"					\
		);							\
		retval;						\
	})

//三个参数的系统调用
#define _syscall3(NUMBER, ARG1, ARG2, ARG3) ({  \
	int retval;
	asm volatile(					\
		"int $0x80"					\
		: "=a"(retval)				\
		: "a"(NUMBER), "b"(ARG1), "c"(ARG2), "d"(ARG3) \
		: "memory"					\
		);							\
		retval;						\
	})

//返回当前任务的pid（使用无参数的宏来传递参数）
uint32_t getpid(){
	return _syscall0(SYS_GETPID);
}

//打印字符串str
uint32_t write(char *str){
	return _syscall1(SYS_WRITE, str);
}

