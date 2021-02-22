TI_GDT equ 0
RPL0 equ 0
SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0

[bits 32]
section .data
put_int_buffer    dq    0     ; 定义8字节缓冲区用于数字到字符的转换

section .text
;-----------------     put_char     ---------------------

global put_str
put_str:
	push ebx
	push ecx
	xor ecx, ecx
	mov ebx, [esp + 12] ;ebx+ecx+return 12byte ,ebx中存储字符串起始地址
	
.goon:
	mov cl, [ebx]	;cl为字符
	cmp cl, 0	;字符串结尾标志 '\0' ascii == 0
	jz .str_over
	push ecx
	call put_char
	add esp, 4	;回收put_char参数所用的栈空间
	inc ebx		;下一个字符
	jmp .goon
.str_over
	pop ecx
	pop ebx
	ret


global put_char
put_char:
	pushad	;备份32位寄存器环境
	mov ax, SELECTOR_VIDEO
	mov gs, ax

;----------------     获取光标位置  --------------------
	mov dx, 0x03d4	;control寄存器组入口地址
	mov al, 0x0e	;Cursor Location High Register
	out dx, al
	mov dx, 0x03d5	;Data Register
	in  al, dx      ;把光标位置高八位写入al
	mov ah, al		;转入ah

	mov dx, 0x03d4
	mov al, 0x0f	;Cursor Location Low Register
	out dx, al
	mov dx, 0x03d5
	in	al, dx		;把光标位置低八位写入al

	mov bx, ax		;把光标存入bx
	
	mov ecx, [esp + 36]	;pushad压入32字节（8个32位寄存器），加4字节主调函数返回地址,esp+36是栈中的待打印字符地址
	;ascii 256个字符，用8位寄存器足够表示
	cmp cl, 0xd			;CR（回车符）是0x0d, LF（换行符）是0x0a
	jz .is_carriage_return
	
	cmp cl, 0xa
	jz .is_line_feed 

	cmp cl, 0x8 		;BS(backspace 退格)的ascii是0x8
	jz .is_backspace
	
	jmp .put_other


.isbackspace:
	dec bx		;光标坐标-1指向前一个字符
	shl bx, 1	;光标坐标左移一位，乘2，得到当前字符在显存中坐标(非实模式，是偏移地址，）
	mov byte [gs:bx], 0x20		;把空格的ascii写入
	inc cx
	mov byte [gs:bx], 0x07		;黑屏白字,一个字符由2个字节组成（低位ascii， 高位属性)
	shr bx, 1					;恢复光标偏移地址
	jmp .set_cursor


.put_other:
	shl bx, 1
	mov [gs:bx], cl
	inc bx
	mov byte [gs:bx], 0x07
	shr bx, 1
	
	inc bx 			;处理下一个光标值

	cmp bx, 2000
	jl .set_cursor  			;如果光标值小于2000，表示位写到显存最后，去设置新的光标值

	
.is_line_feed:
.is_carriage_return:
;先回到当前行行首	
	xor dx, dx		;dx 是被除数高16位，清0
	mov ax, bx		;ax,是被除数低16位，清0
	mov si, 80		;一行80个字符
	div si
	sub bx, dx		;光标值减去除80的余数便是取整,商在ax中，余数在dx中

;再到下一行
.is_carriage_return_end:
	add bx, 80
	cmp bx, 2000
.is_line_feed_end:
	jl .set_cursor



;----------  滚屏   -------------

;屏幕行范围是0~24， 将屏幕1~24行搬运到0~23行，再将第24行用空格填充
.roll_screen:
;cld相对应的指令是std，二者均是用来操作方向标志位DF（Direction Flag）。cld使DF 复位，即是让DF=0，std使DF置位，即DF=1.这两个指令用于串操作指令中。通过执行cld或std指令可以控制方向标志DF，决定内存地址是增大（DF=0，向高地址增加）还是减小（DF=1，向地地址减小）。
	cld		
	mov ecx, 960	; 一共有2000-80=1920个字符要搬运,共1920*2=3840字节.一次搬4字节,共3840/4=960次
	mov esi, 0xb80a0	;si->di 第一行行首
	mov edi, 0xb8000	;		第0行行首
	rep movsd

;最后一行填充为空白
	mov ebx, 3840		;最后一行首字符的第一个字节偏移 = 1920 * 2
	mov ecx, 80
.cls:
	mov word [gs:enx], 0x0720	;黑底白字空格键
	add ebx, 2
	loop .cls
	mov bx,1920			;光标回到最后一行行首

.set_cursor:
;将光标设为bx值
	mov dx, 0x03d4
	mov al, 0x0e
	out dx, al
	mov dx, 0x03d5
	mov al, bh
	out dx, al

	mov dx, 0x03d4
	mov al, 0x0f
	out dx, al
	mov dx, 0x03d5
	mov al, bl
	out dx, al

.put_char_done:
	popad
	ret

;--------------------   将小端字节序的数字变成对应的ascii后，倒置   -----------------------
;输入：栈中参数为待打印的数字
;输出：在屏幕上打印16进制数字,并不会打印前缀0x,如打印10进制15时，只会直接打印f，不会是0xf
;------------------------------------------------------------------------------------------
global put_int
put_int:
   pushad
   mov ebp, esp
   mov eax, [ebp+4*9]		       ; call的返回地址占4字节+pushad的8个4字节
   mov edx, eax
   mov edi, 7                          ; 指定在put_int_buffer中初始的偏移量
   mov ecx, 8			       ; 32位数字中,16进制数字的位数是8个
   mov ebx, put_int_buffer

;将32位数字按照16进制的形式从低位到高位逐个处理,共处理8个16进制数字
.16based_4bits:			       ; 每4位二进制是16进制数字的1位,遍历每一位16进制数字
   and edx, 0x0000000F		       ; 解析16进制数字的每一位。and与操作后,edx只有低4位有效
   cmp edx, 9			       ; 数字0～9和a~f需要分别处理成对应的字符
   jg .is_A2F 
   add edx, '0'			       ; ascii码是8位大小。add求和操作后,edx低8位有效。
   jmp .store
.is_A2F:
   sub edx, 10			       ; A~F 减去10 所得到的差,再加上字符A的ascii码,便是A~F对应的ascii码
   add edx, 'A'

;将每一位数字转换成对应的字符后,按照类似“大端”的顺序存储到缓冲区put_int_buffer
;高位字符放在低地址,低位字符要放在高地址,这样和大端字节序类似,只不过咱们这里是字符序.
.store:
; 此时dl中应该是数字对应的字符的ascii码
   mov [ebx+edi], dl		       
   dec edi
   shr eax, 4
   mov edx, eax 
   loop .16based_4bits

;现在put_int_buffer中已全是字符,打印之前,
;把高位连续的字符去掉,比如把字符000123变成123
.ready_to_print:
   inc edi			       ; 此时edi退减为-1(0xffffffff),加1使其为0
.skip_prefix_0:  
   cmp edi,8			       ; 若已经比较第9个字符了，表示待打印的字符串为全0 
   je .full0 
;找出连续的0字符, edi做为非0的最高位字符的偏移
.go_on_skip:   
   mov cl, [put_int_buffer+edi]
   inc edi
   cmp cl, '0' 
   je .skip_prefix_0		       ; 继续判断下一位字符是否为字符0(不是数字0)
   dec edi			       ;edi在上面的inc操作中指向了下一个字符,若当前字符不为'0',要恢复edi指向当前字符		       
   jmp .put_each_num

.full0:
   mov cl,'0'			       ; 输入的数字为全0时，则只打印0
.put_each_num:
   push ecx			       ; 此时cl中为可打印的字符
   call put_char
   add esp, 4
   inc edi			       ; 使edi指向下一个字符
   mov cl, [put_int_buffer+edi]	       ; 获取下一个字符到cl寄存器
   cmp edi,8
   jl .put_each_num
   popad
   ret

	





