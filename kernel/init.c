#include "init.h"
#include "print.h"
#include "interrupt.h"
#include "../device/timer.h"
#include "thread.h"

void init_all(){
	put_str("init_all\n");
	idt_init();//初始化中断
	mem_init();//初始化内存管理系统
	thread_init();//线程相关结构
	timer_init();//初始化PIC（可编程中断控制器8259A，和计数器（时钟）8253）
}
