[bits 32]
%define ERROR_CODE nop
%define ZERO push 0

extern idt_table

section .data
global intr_entry_table
intr_entry_table:

%macro VECTOR 2
section .text
intr%1entry:

	%2
	push ds
	push es
	push fs
	push gs
	pushad

	mov al, 0x20    ; 8259A的操作控制字OCW2，写入到主片0x20及从片的0xA0端口。发EOI信号手动结束中断
	out 0xa0, al
	out 0x20, al

	push %1

	call [idt_table + %1*4]		;调用对应c语言编写的中断处理程序
	jmp intr_exit

section .data
	dd	intr%1entry

%endmacro

section .text
global intr_exit
intr_exit:
	add esp, 4	;跳过中断号
	popad
	pop gs
	pop fs
	pop es
	pop ds
	add esp, 4	;跳过error_code
	iretd


VECTOR 0x00, ZERO
VECTOR 0x01, ZERO
VECTOR 0x02, ZERO
VECTOR 0x03, ZERO
VECTOR 0x04, ZERO
VECTOR 0x05, ZERO
VECTOR 0x06, ZERO
VECTOR 0x07, ZERO
VECTOR 0x08, ERROR_CODE
VECTOR 0x09, ZERO
VECTOR 0x0a, ERROR_CODE
VECTOR 0x0b, ERROR_CODE
VECTOR 0x0c, ZERO
VECTOR 0x0d, ERROR_CODE
VECTOR 0x0e, ERROR_CODE
VECTOR 0x0f, ZERO
VECTOR 0x10, ZERO
VECTOR 0x11, ERROR_CODE
VECTOR 0x12, ZERO
VECTOR 0x13, ZERO
VECTOR 0x14, ZERO
VECTOR 0x15, ZERO
VECTOR 0x16, ZERO
VECTOR 0x17, ZERO
VECTOR 0x18, ERROR_CODE
VECTOR 0x19, ZERO
VECTOR 0x1a, ERROR_CODE
VECTOR 0x1b, ERROR_CODE
VECTOR 0x1c, ZERO
VECTOR 0x1d, ERROR_CODE
VECTOR 0x1e, ERROR_CODE
VECTOR 0x1f, ZERO
VECTOR 0x20,ZERO	;时钟中断对应的入口
VECTOR 0x21,ZERO	;键盘中断对应的入口
VECTOR 0x22,ZERO	;级联用的
VECTOR 0x23,ZERO	;串口2对应的入口
VECTOR 0x24,ZERO	;串口1对应的入口
VECTOR 0x25,ZERO	;并口2对应的入口
VECTOR 0x26,ZERO	;软盘对应的入口
VECTOR 0x27,ZERO	;并口1对应的入口
VECTOR 0x28,ZERO	;实时时钟对应的入口
VECTOR 0x29,ZERO	;重定向
VECTOR 0x2a,ZERO	;保留
VECTOR 0x2b,ZERO	;保留
VECTOR 0x2c,ZERO	;ps/2鼠标
VECTOR 0x2d,ZERO	;fpu浮点单元异常
VECTOR 0x2e,ZERO	;硬盘
VECTOR 0x2f,ZERO	;保留

;安装0x80号中断对应的中断处理程序
[bits 32]
extern syscall_table
section .text
global syscall_handler
syscall_handler:
;1 保存上下文环境
	push 0

	push ds
	push es
	push fs
	push gs
	pushad

	push 0x80

;2 为系统调用子功能传入参数
	push edx	;系统调用第3个参数
	push ecx
	push ebx

;3 调用子功能处理函数
	call [syscall_table + eax*4]
	add esp, 12			;跨过上面的三个参数

;4 将call调用后的返回值存入当前内核栈中的eax寄存器的位置
;根据二进制编程接口abi约定,寄存器eax用来存储返回值
; 8(0x80占4字节，pushad第一个压入eax寄存器)
	mov [esp + 8*4], eax
	jmp intr_exit	; intr_exit返回，恢复之前的进程上下文
