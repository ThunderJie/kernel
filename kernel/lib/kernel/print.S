TI_GDT equ 0
RPL0 equ 0
SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0

section .data
put_int_buffer dq 0 ; 定义8字节缓冲区用于数字到字符的转换

[bits 32]
section .text
; --------------------------------------------
; put_str通过put_char来打印以0字符结尾的字符串
; 输入：栈中参数为打印的字符串
; 输出：无
; --------------------------------------------
global put_str
put_str:
; 此函数用到ebx和ecx，先备份
	push ebx
	push ecx
	xor ecx, ecx
	mov ebx, [esp + 0xc] ; 栈中得到待打印字符串的地址
.goon:
	mov cl, [ebx]
	cmp cl, 0       ; 如果处理到了字符串尾，跳到结束处返回
	jz .str_over
	push ecx		; 为put_char函数传递参数
	call put_char	; 循环调用put_char实现打印字符串
	add esp, 4
	inc ebx			; ebx指向下一个字符
	jmp .goon

.str_over:
	pop ecx
	pop ebx
	ret

global put_char ; 全局变量，外部可调用
put_char:
	pushad ; 备份环境
	; 保证gs中为正确的视频段选择子
	; 为保险起见，每次打印时都为gs赋值
	mov ax, SELECTOR_VIDEO ; 不能直接把立即数送入段寄存器
	mov gs, ax
	
; 获取当前光标位置，25个字符一行，一共80行，从0行开始
; 先获得高8位
	mov dx, 0x03d4  ; 索引寄存器
	mov al, 0x0e    ; 用于提供光标位置的高8位
	out dx, al
	mov dx, 0x03d5  ; 通过读写数据端口0x3d5来获得或设置光标位置
	in  al, dx      ; 得到了光标位置的高8位
	mov ah, al
	
	; 在获取低8位光标
	mov dx, 0x3d4
	mov al, 0x0f
	out dx, al
	mov dx, 0x3d5
	in  al, dx
	; 将16位完整的光标存入bx
	mov bx, ax
	; 下面这行是在栈中获取待打印的字符
	mov ecx, [esp + 36] ; pushad压入4x8=32字节
						; 加上主函数4字节返回地址
	cmp cl, 0xd			; 回车CR是0x0d，换行LF是0x0a
	jz .is_carriage_return
	cmp cl, 0xa
	jz .is_line_feed
	
	cmp cl, 0x8			; BS(backspace)的asc码是8
	jz .is_backspace
	jmp .put_other

.is_backspace:
	;;;;;;;;;;;;;;;;;; 对于backspace的一点说明 ;;;;;;;;;;;;;;;;;;
	; 当为 backspace 时，光标前移一位
	; 末尾添加空格或空字符0
	dec bx
	shl bx, 1				; 光标左移一位等于乘2
							; 表示光标对应显存中的偏移字节
	mov byte [gs:bx], 0x20	; 将待删除的字节补为0或空格皆可
	inc bx
	mov byte [gs:bx], 0x07
	shr bx, 1
	jmp .set_cursor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.put_other:
	shl bx, 1      			; 光标位置用2字节表示，将光标值乘2         
						    ; 表示对应显存中的偏移字节
	mov [gs:bx], cl         ; ASCII字符本身
	inc bx
	mov byte [gs:bx], 0x07  ; 字符属性
	shr bx, 1				; 恢复老的光标值
	inc bx					; 下一个光标值
	cmp bx, 2000
	jl .set_cursor			; 若光标值小于2000，表示未写到显存的最后，则去设置新的光标值
							; 若超出屏幕字符数大小(2000)则换行处理
.is_line_feed:				; 是换行符LF(\n)
.is_carriage_return:		; 是回车符
; 如果是CR(\r)，只要把光标移到行首就行了
	xor dx, dx 				; dx是被除数的高16位，清0
	mov ax, bx				; ax是被除数的低16位
	mov si, 80              ; 效访Linux中\n表示下一行的行首
	div si					; 这里\n和\r都处理为下一行的行首
	sub bx, dx				; 光标值减去除80的余数便是取整
							; 以上4行处理\r的代码
.is_carriage_return_end:    ; 回车符CR处理结束
	add bx, 80
	cmp bx, 2000
.is_line_feed_end:			; 若是LF(\n)，将光标移+80便可
	jl .set_cursor
; 屏幕行范围是0~24，滚屏的原理是将屏幕的第1~24行搬运到第0~23行，再将第24行用空格填充
.roll_screen:				; 若超出屏幕大小，开始滚屏
	cld
	mov ecx, 960			; 2000-80=1920个字符要搬运，共1920*2=3820字节
							; 一次搬4字节，共3840/4=960次
	mov esi, 0xc00b80a0		; 第一行行首
	mov edi, 0xc00b8000		; 第0行行首
	rep movsd
	
; 将最后一行填充为空白
	mov ebx, 3840			; 最后一行首字符的第一个字节偏移=1920*2
	mov ecx, 80				; 一行是80字符(160字节)，每次清空1字符(2字节)，一行需要移动80次
	
.cls:
	mov word [gs:ebx], 0x0720 	; 0x0720是黑底白字的空格键
	add ebx, 2
	loop .cls
	mov bx, 1920			  	; 将光标值重置为1920，最后一行的首字符

.set_cursor:
; 将光标设为bx值
; 1.先设置高8位
	mov dx, 0x03d4			  	; 索引寄存器
	mov al, 0x0e				; 用于提供光标位置的高8位
	out dx, al
	mov dx, 0x03d5				; 通过读写数据端口0x3d5来获得或设置光标位置
	mov al, bh
	out dx, al
	
; 2.再设置低8位
	mov dx, 0x3d4
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
	mov eax, [ebp + 4*9] ; call的返回地址占4字节再加上pushad的8个四字节
	mov edx, eax
	mov edi, 7	; 指定在put_int_buffer中初始的偏移量	
	mov ecx, 8	; 32位数字中，十六进制数字的位数是8个
	mov ebx, put_int_buffer
	
; 将32位数字按照十六进制的形式从低位到高位逐个处理
; 共处理8个十六进制数字
.16based_4bits:	; 每4位二进制是16进制数字的1位
; 遍历每一位十六进制数字
	and edx, 0x0000000F	; 解析十六进制数字的每一位
						; and与操作后，edx只有低4位有效
	cmp edx, 9			; 数字0~9和a~f需要分别处理成对应的字符
	jg .is_A2F
	add edx, '0'		; ASCII码是8位大小。add求和操作后，edx低8位有效
	jmp .store
.is_A2F:
	sub edx, 10			; A~F减去10所得到的差，再加上字符A的
						; ASCII码，便是A~F对应的ASCII码
	add edx, 'A'
; 将每一位数字转换成对应的字符后,按照类似“大端”的顺序存储到缓冲区put_int_buffer
; 高位字符放在低地址,低位字符要放在高地址,这样和大端字节序类似,只不过咱们这里是字符序.
.store:
; 此时dl中应该是数字对应的字符的ASCII码
	mov [ebx + edi], dl
	dec edi
	shr eax, 4
	mov edx, eax
	loop .16based_4bits
	
; 现在put_int_buffer中已全是字符，打印之前
; 把高位连续的字符去掉，比如把字符000123变成123
.ready_to_print:
	inc edi		; 此时edi退减为-1(0xffffffff),加上1使其为0
.skip_prefix_0:
	cmp edi, 8	; 若已经比较第9个字符了
				; 表示待打印的字符串为全0
	je .full0
; 找出连续的0字符，edi作为非0的最高位字符的偏移
.go_on_skip:
	mov cl, [put_int_buffer + edi]
	inc edi
	cmp cl, '0'
	je .skip_prefix_0	; 继续判断下一位字符是否为字符0(不是数字0)
	dec edi				; edi在上面的inc操作中指向了下一个字符
	; 若当前字符不为'0'，要使edi减1恢复指向当前字符
	jmp .put_each_num
	
.full0:
	mov cl, '0'			; 输入的数字为全0时，则只打印0
.put_each_num:
	push ecx			; 此时cl中为可打印的字符
	call put_char
	add esp, 4
	inc edi				; 使edi指向下一个字符
	mov cl, [put_int_buffer + edi] ; 获取下一个字符到cl寄存器
	cmp edi, 8
	jl .put_each_num
	popad
	ret
