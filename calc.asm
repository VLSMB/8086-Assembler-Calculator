assume cs:code,ds:data,ss:stack
data segment
	db "Welcome to VLSMB's DOS calculator!",0AH,0DH,0AH,0DH,"Please enter your choice(using ",'"',"+-*/",'"',"(only number keyboard) or ESC to choice):"
	db 0AH,0DH,"+ : compute addition",0AH,0DH,"- : compute subtraction",0AH,0DH,"* : compute multiplication",0AH,0DH,"/ : compute division",0AH,0DH
	db "ESC : exit the calculator",0AH,0DH
choice	db 0AH,0DH,"Please choose:$"
illeagal	db 0AH,0DH,"illeagal input!$"
debug	db 0AH,0DH,"Haven't finished!$",0AH,0DH
first  db 0AH,0DH,"Input the first number(only 10 numbers):$"
second  db 0AH,0DH,"Input the second number(only 10 numbers):$"
input_num_one db '#',00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,'#',00H;暂时只提供32位加减法，64位以后再补吧…
input_num_two db '#',00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,'#',00H
data ends
stack segment
	db 128 dup(0)
stack ends

code segment
start:
	mov ax,data
	mov ds,ax
	mov ax,stack
	mov ss,ax
	mov sp,128
init:
	mov dx,0
	mov ah,09H
	int 21h
input_choice:
	mov ah,0
	int 16h
	cmp ah,01H
	je exit_before
	cmp ah,4EH
	je add_before
	cmp ah,4AH
	je sub_before
	cmp ah,35H
	je div_before
	cmp ah,37H
	je mul_before
	; 输入了其他按键时
	mov dx,offset illeagal
	mov ah,09H
	int 21h
	mov dx,offset choice
	int 21h
	jmp input_choice
exit_before:
	jmp near ptr exit
add_before:
	call do_add
	jmp init
sub_before:
	call do_sub
	jmp init
mul_before:
	call do_mul
	jmp init
div_before:
	call do_div
	jmp init
	
do_add:
	push ax
	push dx
	push bx
	
	mov dx,offset first
	mov ah,09H
	int 21h
	mov bx,offset input_num_one
	call get_input   ; bx为数字存放地址
	call debug_output
	mov dx,offset second
	mov ah,09H
	int 21h
	mov bx,offset input_num_two
	call get_input
	call debug_output
	
	mov dx,offset debug
	mov ah,09H
	int 21h
	pop bx
	pop dx
	pop ax
	ret

do_sub:
	mov dx,offset debug
	mov ah,09H
	int 21h
	ret

do_mul:
	mov dx,offset debug
	mov ah,09H
	int 21h
	ret
	
do_div:
	mov dx,offset debug
	mov ah,09H
	int 21h
	ret

get_input:
	; ds固定为数据段，数据为倒序，即12345->54321
	; bx为offset input_num 即数据段中存放数字的位置
	push ax
	push bx
	push si
	push cx
	add bx,10
	mov si,10
	; 初始化内存空间
	mov cx,10
	push cx
	push bx
i_i:	mov byte ptr [bx],0
	dec bx
	loop i_i
	pop bx
	pop cx
reget:
	cmp si,0
	je input_got
	mov ah,0
	int 16h
	cmp ah,1CH
	je get_enter
	cmp ah,02H
	jb reget
	cmp ah,0BH
	ja reget
	call char_show ; al为ASCII码
	sub al,30H ; 将ASCII码转换为数字，存在内存中
	mov [bx],al
	dec bx
	dec si
	jmp reget
input_got:
	pop cx
	pop si
	pop bx
	pop ax
	ret
get_enter:
	; 中途按Enter后的处理
	cmp si,10
	je input_got
	mov cx,si
g_e:	
	mov byte ptr [bx],23H
	dec bx
	loop g_e
	jmp input_got

debug_output:
	; 测试看字符串是否输入进去
	; bx为offset input_num 即数据段中存放数字的位置
	push bx
	push cx
	push ax
	push si
	push dx
	inc bx
	mov cx,10
	mov si,0
s:	add byte ptr [bx+si],30H
	inc si
	loop s
	mov byte ptr [bx+si+1],24H
	mov dx,offset input_num_one
	mov ah,09H
	int 21h
	
	mov si,0
	mov cx,10
t:	sub byte ptr [bx+si],30H
	inc si
	loop t
	mov byte ptr [bx+si+1],23H

	pop dx
	pop si
	pop ax
	pop cx
	pop bx
	ret

char_show:
	; al为要输出字符的ASCII码
	push ax
	push bx
	push cx
	push dx
	mov ah,9
	mov bl,7
	mov bh,0
	mov cx,1
	int 10h
	mov ah,3
	mov bh,0
	int 10h
	inc dl
	mov ah,2
	int 10h
	pop dx
	pop cx
	pop bx
	pop ax
	ret

exit:
	mov ax,4c00h
	int 21h
code ends
end start
