[bits 32]
%define ERROR_CODE nop
%define ZERO push 0 ; 没有错误码时，为了保证栈结构统一，手动push 4字节

extern idt_table

section .data
global intr_entry_table
intr_entry_table:

%macro VECTOR 2
section .text
intr%1entry:	; 每个中断处理程序都要压入中断向量号
				; 自己知道自己的中断向量号是多少intr[0~32]enntry
	%2	; 如果有错误码，会压在eip后面
	push ds ; 汇编中要调用C程序，故需要保存环境
	push es
	push fs
	push gs
	pushad
	
	; 如果此时从片上进入中断，除了往从片上发送EOI外，还要往主片上发送
	; 向主片和从片中写入0x20，操作控制字OCW2
	; 第五位是EOI位此位是1，其余全为0
	mov al, 0x20	; 中断结束命令EOI
	out 0xa0, al	; 向从片发送
	out 0x20, al	; 向主片发送
	
	push %1			; 参数1为中断向量号
	call [idt_table + %1 * 4]; 调用中断处理程序
	jmp intr_exit
		
section .data
	dd intr%1entry	; 储存各个中断入口程序的地址
					; 形成intr_entry_table
%endmacro

section .text
global intr_exit
intr_exit:
	add esp, 4		; 跳过中断号
	popad
	pop gs
	pop fs
	pop es
	pop ds
	add esp, 4		; 跳过error_code
	iretd

;对宏进行调用

VECTOR 0x00,ZERO
VECTOR 0x01,ZERO
VECTOR 0x02,ZERO
VECTOR 0x03,ZERO
VECTOR 0x04,ZERO
VECTOR 0x05,ZERO
VECTOR 0x06,ZERO
VECTOR 0x07,ZERO
VECTOR 0x08,ERROR_CODE
VECTOR 0x09,ZERO
VECTOR 0x0a,ERROR_CODE
VECTOR 0x0b,ERROR_CODE
VECTOR 0x0c,ZERO
VECTOR 0x0d,ERROR_CODE
VECTOR 0x0e,ERROR_CODE
VECTOR 0x0f,ZERO
VECTOR 0x10,ZERO
VECTOR 0x11,ERROR_CODE
VECTOR 0x12,ZERO
VECTOR 0x13,ZERO
VECTOR 0x14,ZERO
VECTOR 0x15,ZERO
VECTOR 0x16,ZERO
VECTOR 0x17,ZERO
VECTOR 0x18,ERROR_CODE
VECTOR 0x19,ZERO
VECTOR 0x1a,ERROR_CODE
VECTOR 0x1b,ERROR_CODE
VECTOR 0x1c,ZERO
VECTOR 0x1d,ERROR_CODE
VECTOR 0x1e,ERROR_CODE
VECTOR 0x1f,ZERO
VECTOR 0x20,ZERO

