assume cs:code,ds:data,ss:stack
data segment
	db "Welcome to VLSMB's DOS calculator!",0AH,0DH,0AH,0DH,"Please enter your choice(using ",'"',"+-*/",'"',"(only number keyboard) or ESC to choice):"
	db 0AH,0DH,"+ : compute addition",0AH,0DH,"- : compute subtraction",0AH,0DH,"* : compute multiplication",0AH,0DH,"/ : compute division",0AH,0DH
	db "ESC : exit the calculator",0AH,0DH
choice	db 0AH,0DH,"Please choose:$"
illeagal	db 0AH,0DH,"illeagal input!$"
debug	db 0AH,0DH,"Haven't finished!$",0AH,0DH
input_num db '#',00H,00H,00H,00H,00H,'#' ;暂时只提供16位加减法，32位以后再补吧…
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
	call get_input
	call debug_output
	mov dx,offset debug
	mov ah,09H
	int 21h
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
	; offset input_num 为数据段中存放数字的位置，ds固定为数据段，数据为倒序，即12345->54321
	push ax
	push bx
	push si
	mov bx,offset input_num
	add bx,5
	mov si,5
reget:
	cmp si,0
	je input_got
	mov ah,0
	int 16h
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
	pop si
	pop bx
	pop ax
	ret

debug_output:
	; 测试看字符串是否输入进去
	push bx
	push cx
	push ax
	push si
	push dx
	mov bx,offset input_num
	inc bx
	mov cx,5
	mov si,0
s:	add byte ptr [bx+si],30H
	inc si
	loop s
	mov byte ptr [bx+si+1],24H
	mov dx,offset input_num
	mov ah,09H
	int 21h
	
	mov si,0
	mov cx,5
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
