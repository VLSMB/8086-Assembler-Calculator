assume cs:code,ds:data,ss:stack
data segment
	db "Welcome to VLSMB's DOS calculator!",0AH,0DH,0AH,0DH,"Please enter your choice(using ",'"',"+-*/",'"',"(only number keyboard) or ESC to choice):"
	db 0AH,0DH,"A : compute addition",0AH,0DH,"S : compute subtraction",0AH,0DH,"M : compute multiplication",0AH,0DH,"D : compute division",0AH,0DH
	db "ESC : exit the calculator",0AH,0DH
choice	db 0AH,0DH,"Please choose:$"
illeagal	db 0AH,0DH,"illeagal input!$"
debug	db 0AH,0DH,"Haven't finished!$",0AH,0DH
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
	; Press other button
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
	; do addition
	mov dx,offset debug
	mov ah,09H
	int 21h
	ret

do_sub:
	; do subtraction
	mov dx,offset debug
	mov ah,09H
	int 21h
	ret

do_mul:
	; do multiplication
	mov dx,offset debug
	mov ah,09H
	int 21h
	ret
	
do_div:	
	; do division
	mov dx,offset debug
	mov ah,09H
	int 21h
	ret

exit:
	mov ax,4c00h
	int 21h
code ends
end start
