LOADER_BASE_ADDR equ 0x900
LOADER_START_SECTOR equ 0x2

section mbr vstart=0x7c00
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov fs,ax
	mov sp,0x7c00
	mov ax,0xb800 ;显存初始地址(x86)
	mov gs,ax


;使用BIOS中断 0x10 0x06 清屏
	mov ax,0600h
	mov bx,0700h
	mov cx,0
	mov dx,184fh

	int 10h

;输出字符串 ccx
	mov byte [gs:0x9c4],'C'
	mov byte [gs:0x9c5],0xA4
	
	mov byte [gs:0x9c6],' '
 	mov byte [gs:0x9c7],0xA4

	mov byte [gs:0x9c8],'C'
	mov byte [gs:0x9c9],0xA4
	
	mov byte [gs:0x9ca],' '
 	mov byte [gs:0x9cb],0xA4
	
	mov byte [gs:0x9cc],'X'
	mov byte [gs:0x9cd],0xA4
	
	mov byte [gs:0x9ce],' '
 	mov byte [gs:0x9cf],0xA4

;将磁盘中的loader载入内存并跳转过去执行
	;为函数read_disk 传入参数
	mov eax,LOADER_START_SECTOR ;读出的逻辑扇区号
	mov bx,LOADER_BASE_ADDR		;写入内存起始地址
	mov cx,1 ;待读入的扇区数
	call read_disk
	
	jmp LOADER_BASE_ADDR


;读取硬盘的n个扇区
read_disk:
	mov esi,eax ;备份eax
	mov di,cx	;备份cx

	mov dx,0x1f2
	mov al,cl
	out dx,al ; 读取的扇区数,out指令中dx用来存储端口号，用al来向端口写数据
		
	mov eax,esi ;恢复eax

;将LBA(逻辑块地址)地址写入0x1f3 ~ 0x1f6
	mov dx,0x1f3
	out dx,al

	mov cl,8
	shr eax,cl
	mov dx,0x1f4
	out dx,al

	shr eax,cl
	mov dx,0x1f5
	out dx,al

	shr eax,cl
	and al,0x0f ;00001111 lba 24~27
	or al,0xe0  ;1110设置4~7位为1110，表示lba模式,使用通道上的主盘
	mov dx,0x1f6
	out dx,al

;向0x1f7端口写入读命令,0x20
	mov dx,0x1f7
	mov al,0x20
	out dx,al

;监测硬盘是否准备好进行数据传输
.not_ready:
	nop ;什么也不做，增加延迟，减少打扰硬盘工作
	in al,dx ;0x1f7端口写时表示命令，读时表示硬盘状态
	and al,0x88;1000 1000 第3位（从第0位开始）为1表示硬盘控制器已准备号数据传输，第7位为1表示硬盘忙
	cmp al,0x08
	jnz .not_ready ; al-0x08 != 0 就循环

;从0x1f0端口读数据
 	mov ax,di ; di = cx 读入扇区数
	mov dx,256 ;一个块（512字节）有256个字
 	mul dx
 	mov cx,ax ;将要读入字数装入cx
	
	mov dx,0x1f0 ;端口操作准备
.go_on_read:
	in ax,dx
	mov [bx],ax
	add bx,2
	loop .go_on_read
	ret

times 510-($-$$) db 0
db 0x55,0xaa



