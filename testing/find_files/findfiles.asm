; do not run this code
; it crashes badly

	global start
	default rel

	section .text
start:

	mov rax, 0x2000005	; open
	push 0x2e			; "." current dir
	lea rdi, [rsp]
	mov rsi, 0
	mov rdx, 0
	syscall

	cmp rax, 0			; check if file opened correctly
	jle exit

	mov r13, rax

	;getdirentries(int fd, char *buf, u_int count, long *basep)
	mov rdi, r13		; fd
	mov rax, 0x20000c4 	; getdirentries

	mov rcx, 32		; 256 bytes
pushloop:
	push 0
	loop pushloop

	lea rsi, [rsp]
	mov rdx, 256
	push 0x0000000000000000
	pop rcx				;lea rcx, [rsp]
	syscall

	mov rax, 0x2000006			; close
	mov rdi, r13
	syscall

	; skip 24 bytes (entries . and ..)
	pop rax
	pop rax
	pop rax


get_first_dir_entry:
	mov rax, 0x2000005	; open
	lea rdi, [rsp+8]	; file from entry
	mov rsi, 0
	mov rdx, 0
	syscall

error_check:
	cmp rax, 0			; check if file opened correctly
	jle exit

	mov rdi, rax
	mov rax, 0x2000006			; close
	syscall

exit:
	mov rax, 	0x2000001	 ; exit
	xor rdi, 	rdi ; exit code 0
	syscall	


section .data
	d: db "b"


