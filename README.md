# xiangOS
一个玩具os



内存管理
===========================
##页目录表与页表

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

1. 32位虚拟地址转换为物理地址的过程
    * 1: 高10位是页目录项pde的索引，用于在页目录表中定位pde，处理器获取高10位后

		 自动将其乘4，在加上页目录表的物理地址，这样就得到了pde索引对应的pde所在  

		 的物理地址，然后自动在该物理地址中，即该pde中，获取保持的页表物理地址。

	* 2: 中间10位是页表项pde的索引，用于在页表中定位pte，cpu获取中间10位后自动将  

		 将其乘4，再加上第一步中得到的页表的物理地址，这样便得到了pte索引对应的pte
  
         所在的物理地址，然后自动在该物理地址（该pte）中获取保存的普通物理页物理地址。

	* 3: 低12位是物理页内的偏移量，页大小是4KB，12位可寻址的范围正好是4KB，因此cpu

		 便直接把低12位作为第二步中获取的物理页的偏移量，无需乘以4。用物理页的物理地址
 
		 加上这低12位的和便是这32位虚拟地址最终落向的物理地址。
