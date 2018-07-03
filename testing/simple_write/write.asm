	global start
	default rel

	section .text
start:
v_start:

    push 	0x706d6973		; push "simp" to the stack
    jmp 	simple_write

simple_write:
	push	0x2000004		; rax = write
	pop		rax
	push	1				; rdi = stdout
	pop		rdi
	lea 	rsi,[rsp]
	mov 	rdx, 4
	syscall


exit:
	mov rax, 	0x2000001	 ; exit
	xor rdi, 	rdi ; exit code 0
	syscall	


section .data
	d: db "b"


