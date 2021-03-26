#ifndef SYNC_H
#define SYNC_H
#include"list.h"
#include"stdint.h"
#include"thread.h"
//信号量
struct semaphore
{
	uint8_t value;
	list waiters;	//阻塞队列
};

//锁结构
typedef struct lock{
	struct task_struct *holder;	//锁持有者的pcb
	struct semaphore semaphore;	//用二元信号量实现锁
	uint32_t holder_repeat_nr; //锁的持有者重复申请锁的次数
}lock;

#endif