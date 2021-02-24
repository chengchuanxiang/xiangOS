# xiangOS
一个玩具os



内存管理
===========================
## 页目录表与页表

* 页目录表

 ... |
-----|
页目录项1|
页目录项0|

* 页表

 ... |
-----|
页表项1|
页表项0|



## 页目录项与页表项结构

* 页目录项

31~12 | 11~9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
------|------|---|---|---|---|---|---|---|---|---|
页表物理页地址 | AVL | G | 0 | D | A | PCD | PWT | US | RW | P |

* 页表项

31~12 | 11~9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
------|------|---|---|---|---|---|---|---|---|---|
物理页地址 | AVL | G | PAT | D | A | PCD | PWT | US | RW | P |

* 符号意义
 *	p=1    该页存在于物理内存中         p=0  该页不存在于物理内存中

   	操作系统的页式虚拟内存管理就是通过P位和相应的pagefault异常来实现的

	RW     读写位  1为可读可写， 0表示可读不可写

	US     1为user普通用户位，特权级0,1,2,3都可以访问 0为Supervisor超级用户位，特权级3不可访问，0,1,2可以

	PWT    1表示该页为高速缓存，0为普通内存

	PCD    1该页启用高速缓存，0表示禁止将该页缓存

	A		1表示该页被内存访问过 和段描述符的p位可以一起实现段式虚拟内存访问，操作系统定期将A位清0，统计一段时间内变成1的次数(LRU?)

	D		当cpu对一个页面执行写操作时，就会设置对应页表项的D位为1

	PAT	页属性表位，能够在页面一级的粒度上设置内存属性。比较复杂，这里置0

	G		Global全局位 为1表示是全局页，在高速缓存TLB中一直保存，给出虚拟地址就出物理地址，无那3部分转换

	AVL	available位，操作系统可用该位，cpu不会理会。此处置0即可


1. 32位虚拟地址转换为物理地址的过程
    * 1: 高10位是页目录项pde的索引，用于在页目录表中定位pde，处理器获取高10位后

		 自动将其乘4，在加上页目录表的物理地址，这样就得到了pde索引对应的pde所在  

		 的物理地址，然后自动在该物理地址中，即该pde中，获取保存的页表物理地址。

	* 2: 中间10位是页表项pte的索引，用于在页表中定位pte，cpu获取中间10位后自动将  

		 将其乘4，再加上第一步中得到的页表的物理地址，这样便得到了pte索引对应的pte
  
         所在的物理地址，然后自动在该物理地址（该pte）中获取保存的普通物理页物理地址。

	* 3: 低12位是物理页内的偏移量，页大小是4KB，12位可寻址的范围正好是4KB，因此cpu

		 便直接把低12位作为第二步中获取的物理页的偏移量，无需乘以4。用物理页的物理地址
 
		 加上这低12位的和便是这32位虚拟地址最终落向的物理地址。
