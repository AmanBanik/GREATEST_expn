	.file	"memory_lab.cpp"
	.intel_syntax noprefix
	.text
#APP
	.globl _ZSt21ios_base_library_initv
#NO_APP
	.section	.text._ZNKSt5ctypeIcE8do_widenEc,"axG",@progbits,_ZNKSt5ctypeIcE8do_widenEc,comdat
	.align 2
	.p2align 4
	.weak	_ZNKSt5ctypeIcE8do_widenEc
	.type	_ZNKSt5ctypeIcE8do_widenEc, @function
_ZNKSt5ctypeIcE8do_widenEc:
.LFB2913:
	.cfi_startproc
	endbr64
	mov	eax, esi
	ret
	.cfi_endproc
.LFE2913:
	.size	_ZNKSt5ctypeIcE8do_widenEc, .-_ZNKSt5ctypeIcE8do_widenEc
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC1:
	.string	"cannot create std::vector larger than max_size()"
	.text
	.p2align 4
	.type	_ZL13chains_kernelRKSt6vectorImSaImEEmm, @function
_ZL13chains_kernelRKSt6vectorImSaImEEmm:
.LFB7099:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rax, rsi
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	push	r15
	push	r14
	push	r13
	push	r12
	push	rbx
	and	rsp, -32
	sub	rsp, 32
	.cfi_offset 15, -24
	.cfi_offset 14, -32
	.cfi_offset 13, -40
	.cfi_offset 12, -48
	.cfi_offset 3, -56
	shr	rax, 60
	jne	.L35
	xor	r12d, r12d
	test	rsi, rsi
	je	.L3
	lea	r12, 0[0+rsi*8]
	mov	rbx, rdi
	mov	QWORD PTR 16[rsp], rsi
	mov	r14, rdx
	mov	rdi, r12
	mov	QWORD PTR 24[rsp], r12
	call	_Znwm@PLT
	mov	rcx, QWORD PTR 16[rsp]
	mov	QWORD PTR [rax], 0
	mov	r13, rax
	lea	rdi, 8[rax]
	cmp	rcx, 1
	je	.L6
	lea	r15, [rax+r12]
	cmp	r15, rdi
	je	.L7
	lea	rdx, -8[r12]
	xor	esi, esi
	call	memset@PLT
	mov	rcx, QWORD PTR 16[rsp]
.L7:
	mov	rsi, QWORD PTR [rbx]
	mov	rax, QWORD PTR 8[rbx]
	xor	edx, edx
	sub	rax, rsi
	sar	rax, 3
	div	rcx
	lea	rdx, -1[rcx]
	cmp	rdx, 2
	jbe	.L21
	mov	rdi, rcx
	vmovq	xmm7, rax
	mov	rdx, r13
	vmovdqa	ymm3, YMMWORD PTR .LC0[rip]
	shr	rdi, 2
	vpbroadcastq	ymm4, xmm7
	vpbroadcastq	ymm5, QWORD PTR .LC3[rip]
	sal	rdi, 5
	vpsrlq	ymm6, ymm4, 32
	add	rdi, r13
	.p2align 4,,10
	.p2align 3
.L9:
	vmovdqa	ymm1, ymm3
	add	rdx, 32
	vpaddq	ymm3, ymm3, ymm5
	vpsrlq	ymm0, ymm1, 32
	vpmuludq	ymm2, ymm1, ymm4
	vpmuludq	ymm0, ymm0, ymm4
	vpmuludq	ymm1, ymm6, ymm1
	vpaddq	ymm0, ymm0, ymm1
	vpsllq	ymm0, ymm0, 32
	vpaddq	ymm0, ymm2, ymm0
	vmovdqu	YMMWORD PTR -32[rdx], ymm0
	cmp	rdx, rdi
	jne	.L9
	mov	rdx, rcx
	and	rdx, -4
	test	cl, 3
	je	.L12
.L8:
	mov	rdi, rdx
	lea	r9, 1[rdx]
	lea	r8, 0[0+rdx*8]
	imul	rdi, rax
	cmp	r9, rcx
	mov	QWORD PTR 0[r13+rdx*8], rdi
	jnb	.L12
	add	rdx, 2
	add	rdi, rax
	cmp	rdx, rcx
	mov	QWORD PTR 8[r13+r8], rdi
	jnb	.L12
	add	rdi, rax
	mov	QWORD PTR 16[r13+r8], rdi
.L12:
	test	r14, r14
	je	.L11
	lea	rcx, 0[r13+r12]
	xor	edi, edi
	.p2align 4,,10
	.p2align 3
.L13:
	mov	rax, r13
	.p2align 4,,10
	.p2align 3
.L14:
	mov	rdx, QWORD PTR [rax]
	add	rax, 8
	mov	rdx, QWORD PTR [rsi+rdx*8]
	mov	QWORD PTR -8[rax], rdx
	cmp	rcx, rax
	jne	.L14
	add	rdi, 1
	cmp	r14, rdi
	jne	.L13
.L11:
	cmp	r13, r15
	je	.L22
	lea	rdx, -8[r15]
	mov	rax, r13
	sub	rdx, r13
	mov	rcx, rdx
	shr	rcx, 3
	add	rcx, 1
	cmp	rdx, 16
	jbe	.L23
	mov	rdx, rcx
	vpxor	xmm0, xmm0, xmm0
	shr	rdx, 2
	sal	rdx, 5
	add	rdx, r13
	.p2align 4,,10
	.p2align 3
.L17:
	vpaddq	ymm0, ymm0, YMMWORD PTR [rax]
	add	rax, 32
	cmp	rax, rdx
	jne	.L17
	vmovdqa	xmm1, xmm0
	vextracti128	xmm0, ymm0, 0x1
	mov	rax, rcx
	vpaddq	xmm0, xmm1, xmm0
	and	rax, -4
	and	ecx, 3
	vpsrldq	xmm1, xmm0, 8
	lea	rax, 0[r13+rax*8]
	vpaddq	xmm0, xmm0, xmm1
	vmovq	r12, xmm0
	je	.L15
.L16:
	lea	rdx, 8[rax]
	add	r12, QWORD PTR [rax]
	cmp	r15, rdx
	je	.L15
	lea	rdx, 16[rax]
	add	r12, QWORD PTR 8[rax]
	cmp	r15, rdx
	je	.L15
	add	r12, QWORD PTR 16[rax]
.L15:
	mov	rsi, QWORD PTR 24[rsp]
	mov	rdi, r13
	vzeroupper
	call	_ZdlPvm@PLT
.L3:
	lea	rsp, -40[rbp]
	mov	rax, r12
	pop	rbx
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	pop	rbp
	.cfi_remember_state
	.cfi_def_cfa 7, 8
	ret
.L6:
	.cfi_restore_state
	mov	rsi, QWORD PTR [rbx]
	mov	rax, QWORD PTR 8[rbx]
	mov	r15, rdi
	xor	edx, edx
	mov	QWORD PTR 24[rsp], 8
	sub	rax, rsi
	sar	rax, 3
	jmp	.L8
.L23:
	xor	r12d, r12d
	jmp	.L16
.L22:
	xor	r12d, r12d
	jmp	.L15
.L35:
	lea	rdi, .LC1[rip]
	call	_ZSt20__throw_length_errorPKc@PLT
.L21:
	xor	edx, edx
	jmp	.L8
	.cfi_endproc
.LFE7099:
	.size	_ZL13chains_kernelRKSt6vectorImSaImEEmm, .-_ZL13chains_kernelRKSt6vectorImSaImEEmm
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC4:
	.string	"basic_string::append"
.LC5:
	.string	"basic_string::_M_create"
	.section	.text.unlikely,"ax",@progbits
	.align 2
	.type	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE6appendEPKcm.isra.0, @function
_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE6appendEPKcm.isra.0:
.LFB9276:
	.cfi_startproc
	movabs	rax, 9223372036854775807
	push	r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	push	r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	push	r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	push	r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	push	rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	push	rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	sub	rsp, 24
	.cfi_def_cfa_offset 80
	mov	rbp, QWORD PTR 8[rdi]
	sub	rax, rbp
	cmp	rax, rdx
	jnb	.L37
	lea	rdi, .LC4[rip]
	call	_ZSt20__throw_length_errorPKc@PLT
.L37:
	mov	rcx, QWORD PTR [rdi]
	mov	rbx, rdx
	lea	r15, 0[rbp+rdx]
	lea	rdx, 16[rdi]
	mov	r12, rdi
	mov	r13, rsi
	mov	eax, 15
	cmp	rcx, rdx
	je	.L38
	mov	rax, QWORD PTR 16[rdi]
.L38:
	cmp	rax, r15
	jb	.L39
	test	rbx, rbx
	je	.L40
	add	rbp, rcx
	cmp	rbx, 1
	jne	.L41
	mov	dl, BYTE PTR 0[r13]
	mov	BYTE PTR 0[rbp], dl
	jmp	.L40
.L41:
	mov	rdi, rbp
	mov	rsi, r13
	mov	rcx, rbx
	rep movsb
	jmp	.L40
.L39:
	test	r15, r15
	jns	.L42
	lea	rdi, .LC5[rip]
	call	_ZSt20__throw_length_errorPKc@PLT
.L42:
	add	rax, rax
	mov	r14, r15
	cmp	r15, rax
	jnb	.L43
	movabs	r14, 9223372036854775807
	cmp	rax, r14
	cmovbe	r14, rax
.L43:
	mov	rdi, r14
	inc	rdi
	jns	.L44
	call	_ZSt17__throw_bad_allocv@PLT
.L44:
	mov	QWORD PTR 8[rsp], rdx
	call	_Znwm@PLT
	test	rbp, rbp
	mov	r8, QWORD PTR [r12]
	mov	rdx, QWORD PTR 8[rsp]
	je	.L45
	cmp	rbp, 1
	jne	.L46
	mov	cl, BYTE PTR [r8]
	mov	BYTE PTR [rax], cl
	jmp	.L45
.L46:
	mov	rdi, rax
	mov	rsi, r8
	mov	rcx, rbp
	rep movsb
.L45:
	test	r13, r13
	je	.L47
	test	rbx, rbx
	je	.L47
	add	rbp, rax
	cmp	rbx, 1
	jne	.L48
	mov	cl, BYTE PTR 0[r13]
	mov	BYTE PTR 0[rbp], cl
	jmp	.L47
.L48:
	mov	rdi, rbp
	mov	rsi, r13
	mov	rcx, rbx
	rep movsb
.L47:
	cmp	rdx, r8
	je	.L49
	mov	QWORD PTR 8[rsp], rax
	mov	rax, QWORD PTR 16[r12]
	mov	rdi, r8
	lea	rsi, 1[rax]
	call	_ZdlPvm@PLT
	mov	rax, QWORD PTR 8[rsp]
.L49:
	mov	QWORD PTR [r12], rax
	mov	QWORD PTR 16[r12], r14
.L40:
	mov	rax, QWORD PTR [r12]
	mov	QWORD PTR 8[r12], r15
	mov	BYTE PTR [rax+r15], 0
	add	rsp, 24
	.cfi_def_cfa_offset 56
	pop	rbx
	.cfi_def_cfa_offset 48
	pop	rbp
	.cfi_def_cfa_offset 40
	pop	r12
	.cfi_def_cfa_offset 32
	pop	r13
	.cfi_def_cfa_offset 24
	pop	r14
	.cfi_def_cfa_offset 16
	pop	r15
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE9276:
	.size	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE6appendEPKcm.isra.0, .-_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE6appendEPKcm.isra.0
	.section	.text._ZSteqIcSt11char_traitsIcESaIcEEbRKNSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_,"axG",@progbits,_ZSteqIcSt11char_traitsIcESaIcEEbRKNSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_,comdat
	.p2align 4
	.weak	_ZSteqIcSt11char_traitsIcESaIcEEbRKNSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_
	.type	_ZSteqIcSt11char_traitsIcESaIcEEbRKNSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_, @function
_ZSteqIcSt11char_traitsIcESaIcEEbRKNSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_:
.LFB7105:
	.cfi_startproc
	endbr64
	push	r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	push	rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	mov	rbp, rdi
	push	rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	mov	r12, QWORD PTR 8[rdi]
	mov	rdi, rsi
	mov	rbx, rsi
	call	strlen@PLT
	mov	rdx, rax
	xor	eax, eax
	cmp	r12, rdx
	je	.L71
.L65:
	pop	rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	pop	rbp
	.cfi_def_cfa_offset 16
	pop	r12
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L71:
	.cfi_restore_state
	test	r12, r12
	mov	eax, 1
	je	.L65
	mov	rdi, QWORD PTR 0[rbp]
	mov	rdx, r12
	mov	rsi, rbx
	call	memcmp@PLT
	pop	rbx
	.cfi_def_cfa_offset 24
	pop	rbp
	.cfi_def_cfa_offset 16
	test	eax, eax
	pop	r12
	.cfi_def_cfa_offset 8
	sete	al
	ret
	.cfi_endproc
.LFE7105:
	.size	_ZSteqIcSt11char_traitsIcESaIcEEbRKNSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_, .-_ZSteqIcSt11char_traitsIcESaIcEEbRKNSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_
	.section	.rodata._ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2IS3_EEPKcRKS3_.str1.8,"aMS",@progbits,1
	.align 8
.LC6:
	.string	"basic_string: construction from null is not valid"
	.section	.text._ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2IS3_EEPKcRKS3_,"axG",@progbits,_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC5IS3_EEPKcRKS3_,comdat
	.align 2
	.p2align 4
	.weak	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2IS3_EEPKcRKS3_
	.type	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2IS3_EEPKcRKS3_, @function
_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2IS3_EEPKcRKS3_:
.LFB7639:
	.cfi_startproc
	endbr64
	push	r13
	.cfi_def_cfa_offset 16
	.cfi_offset 13, -16
	lea	r13, 16[rdi]
	push	r12
	.cfi_def_cfa_offset 24
	.cfi_offset 12, -24
	push	rbp
	.cfi_def_cfa_offset 32
	.cfi_offset 6, -32
	push	rbx
	.cfi_def_cfa_offset 40
	.cfi_offset 3, -40
	sub	rsp, 8
	.cfi_def_cfa_offset 48
	test	rsi, rsi
	mov	QWORD PTR [rdi], r13
	je	.L83
	mov	rbp, rdi
	mov	rdi, rsi
	mov	r12, rsi
	call	strlen@PLT
	cmp	rax, 15
	mov	rbx, rax
	ja	.L84
	cmp	rax, 1
	je	.L85
	test	rax, rax
	jne	.L75
.L77:
	mov	QWORD PTR 8[rbp], rbx
	mov	BYTE PTR 0[r13+rbx], 0
	add	rsp, 8
	.cfi_remember_state
	.cfi_def_cfa_offset 40
	pop	rbx
	.cfi_def_cfa_offset 32
	pop	rbp
	.cfi_def_cfa_offset 24
	pop	r12
	.cfi_def_cfa_offset 16
	pop	r13
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L85:
	.cfi_restore_state
	movzx	eax, BYTE PTR [r12]
	mov	BYTE PTR 16[rbp], al
	jmp	.L77
	.p2align 4,,10
	.p2align 3
.L84:
	lea	rdi, 1[rax]
	call	_Znwm@PLT
	mov	QWORD PTR 16[rbp], rbx
	mov	QWORD PTR 0[rbp], rax
	mov	r13, rax
.L75:
	mov	rdi, r13
	mov	rdx, rbx
	mov	rsi, r12
	call	memcpy@PLT
	mov	r13, QWORD PTR 0[rbp]
	jmp	.L77
.L83:
	lea	rdi, .LC6[rip]
	call	_ZSt19__throw_logic_errorPKc@PLT
	.cfi_endproc
.LFE7639:
	.size	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2IS3_EEPKcRKS3_, .-_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2IS3_EEPKcRKS3_
	.weak	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC1IS3_EEPKcRKS3_
	.set	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC1IS3_EEPKcRKS3_,_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC2IS3_EEPKcRKS3_
	.section	.rodata._ZNSt6vectorImSaImEE6resizeEm.str1.1,"aMS",@progbits,1
.LC7:
	.string	"vector::_M_default_append"
	.section	.text._ZNSt6vectorImSaImEE6resizeEm,"axG",@progbits,_ZNSt6vectorImSaImEE6resizeEm,comdat
	.align 2
	.p2align 4
	.weak	_ZNSt6vectorImSaImEE6resizeEm
	.type	_ZNSt6vectorImSaImEE6resizeEm, @function
_ZNSt6vectorImSaImEE6resizeEm:
.LFB7691:
	.cfi_startproc
	endbr64
	push	r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	push	r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	push	r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	push	r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	push	rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	mov	rbp, rsi
	push	rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	mov	rbx, rdi
	sub	rsp, 24
	.cfi_def_cfa_offset 80
	mov	rdx, QWORD PTR 8[rdi]
	mov	r12, QWORD PTR [rdi]
	mov	r15, rdx
	sub	r15, r12
	mov	rax, r15
	sar	rax, 3
	cmp	rax, rsi
	jb	.L114
	cmp	rsi, rax
	jnb	.L111
	lea	rax, [r12+rsi*8]
	cmp	rax, rdx
	je	.L111
	mov	QWORD PTR 8[rdi], rax
.L111:
	add	rsp, 24
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	pop	rbx
	.cfi_def_cfa_offset 48
	pop	rbp
	.cfi_def_cfa_offset 40
	pop	r12
	.cfi_def_cfa_offset 32
	pop	r13
	.cfi_def_cfa_offset 24
	pop	r14
	.cfi_def_cfa_offset 16
	pop	r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L114:
	.cfi_restore_state
	mov	rcx, QWORD PTR 16[rdi]
	sub	rsi, rax
	sub	rcx, rdx
	sar	rcx, 3
	cmp	rcx, rsi
	jb	.L88
	sub	rsi, 1
	mov	QWORD PTR [rdx], 0
	lea	rcx, 8[rdx]
	je	.L89
	lea	rax, [rcx+rsi*8]
	mov	rdi, rcx
	xor	esi, esi
	sub	rax, rdx
	lea	rbp, -8[rax]
	mov	rdx, rbp
	call	memset@PLT
	mov	rcx, rax
	add	rcx, rbp
.L89:
	mov	QWORD PTR 8[rbx], rcx
	jmp	.L111
	.p2align 4,,10
	.p2align 3
.L88:
	movabs	rdx, 1152921504606846975
	sub	rdx, rax
	cmp	rdx, rsi
	jb	.L115
	lea	rcx, -1[rsi]
	cmp	rax, rsi
	mov	QWORD PTR [rsp], rcx
	jb	.L116
	movabs	rdx, 1152921504606846975
	add	rax, rax
	mov	QWORD PTR 8[rsp], rsi
	cmp	rax, rdx
	cmova	rax, rdx
	lea	r14, 0[0+rax*8]
	mov	rdi, r14
	call	_Znwm@PLT
	mov	rsi, QWORD PTR 8[rsp]
	lea	rdi, [rax+r15]
	mov	r13, rax
	cmp	rsi, 1
	mov	QWORD PTR [rdi], 0
	je	.L95
.L113:
	mov	rdx, QWORD PTR [rsp]
	add	rdi, 8
	xor	esi, esi
	sal	rdx, 3
	call	memset@PLT
.L93:
	test	r15, r15
	jne	.L95
	test	r12, r12
	jne	.L117
.L98:
	lea	rax, 0[r13+rbp*8]
	vmovq	xmm1, r13
	lea	rcx, 0[r13+r14]
	vpinsrq	xmm0, xmm1, rax, 1
	mov	QWORD PTR 16[rbx], rcx
	vmovdqu	XMMWORD PTR [rbx], xmm0
	jmp	.L111
	.p2align 4,,10
	.p2align 3
.L95:
	mov	rsi, r12
	mov	rdx, r15
	mov	rdi, r13
	call	memmove@PLT
	mov	rsi, QWORD PTR 16[rbx]
	sub	rsi, r12
.L97:
	mov	rdi, r12
	call	_ZdlPvm@PLT
	jmp	.L98
	.p2align 4,,10
	.p2align 3
.L116:
	movabs	rax, 1152921504606846975
	cmp	rbp, rax
	cmovbe	rax, rbp
	lea	r14, 0[0+rax*8]
	mov	rdi, r14
	call	_Znwm@PLT
	cmp	QWORD PTR [rsp], 0
	lea	rdi, [rax+r15]
	mov	r13, rax
	mov	QWORD PTR [rdi], 0
	jne	.L113
	jmp	.L93
	.p2align 4,,10
	.p2align 3
.L117:
	mov	rsi, QWORD PTR 16[rbx]
	sub	rsi, r12
	jmp	.L97
.L115:
	lea	rdi, .LC7[rip]
	call	_ZSt20__throw_length_errorPKc@PLT
	.cfi_endproc
.LFE7691:
	.size	_ZNSt6vectorImSaImEE6resizeEm, .-_ZNSt6vectorImSaImEE6resizeEm
	.section	.text._ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv,"axG",@progbits,_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv,comdat
	.align 2
	.p2align 4
	.weak	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	.type	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv, @function
_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv:
.LFB7739:
	.cfi_startproc
	endbr64
	mov	rax, QWORD PTR [rdi]
	lea	rdx, 16[rdi]
	cmp	rax, rdx
	je	.L120
	mov	rsi, QWORD PTR 16[rdi]
	mov	rdi, rax
	add	rsi, 1
	jmp	_ZdlPvm@PLT
	.p2align 4,,10
	.p2align 3
.L120:
	ret
	.cfi_endproc
.LFE7739:
	.size	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv, .-_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	.section	.text.unlikely
	.type	_ZStplIcSt11char_traitsIcESaIcEENSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_RKS8_.isra.0, @function
_ZStplIcSt11char_traitsIcESaIcEENSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_RKS8_.isra.0:
.LFB9285:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA9285
	push	r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	push	r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	push	r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	mov	r13, rsi
	push	r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	mov	r12, rcx
	push	rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	push	rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	mov	rbx, rdi
	mov	rdi, rsi
	lea	r15, 16[rbx]
	sub	rsp, 24
	.cfi_def_cfa_offset 80
	mov	QWORD PTR [rsp], rdx
	call	strlen@PLT
	xor	edx, edx
	mov	QWORD PTR [rbx], r15
	lea	rbp, [rax+r12]
	mov	QWORD PTR 8[rbx], rdx
	mov	r14, rax
	cmp	rbp, 15
	mov	BYTE PTR 16[rbx], 0
	jbe	.L122
	test	rbp, rbp
	jns	.L123
	lea	rdi, .LC5[rip]
.LEHB0:
	call	_ZSt20__throw_length_errorPKc@PLT
.L123:
	mov	eax, 30
	cmp	rbp, rax
	cmovb	rbp, rax
	mov	rdi, rbp
	inc	rdi
	jns	.L124
	call	_ZSt17__throw_bad_allocv@PLT
.L124:
	call	_Znwm@PLT
	mov	rsi, QWORD PTR 8[rbx]
	mov	rdx, QWORD PTR [rbx]
	test	rsi, rsi
	lea	rcx, 1[rsi]
	jne	.L125
	mov	cl, BYTE PTR [rdx]
	mov	BYTE PTR [rax], cl
	jmp	.L126
.L125:
	test	rcx, rcx
	je	.L126
	mov	rdi, rax
	mov	rsi, rdx
	rep movsb
.L126:
	cmp	r15, rdx
	je	.L127
	mov	QWORD PTR 8[rsp], rax
	mov	rax, QWORD PTR 16[rbx]
	mov	rdi, rdx
	lea	rsi, 1[rax]
	call	_ZdlPvm@PLT
	mov	rax, QWORD PTR 8[rsp]
.L127:
	mov	QWORD PTR [rbx], rax
	mov	QWORD PTR 16[rbx], rbp
.L122:
	mov	rdx, r14
	mov	rsi, r13
	mov	rdi, rbx
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE6appendEPKcm.isra.0
	mov	rsi, QWORD PTR [rsp]
	mov	rdx, r12
	mov	rdi, rbx
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE6appendEPKcm.isra.0
.LEHE0:
	add	rsp, 24
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	mov	rax, rbx
	pop	rbx
	.cfi_def_cfa_offset 48
	pop	rbp
	.cfi_def_cfa_offset 40
	pop	r12
	.cfi_def_cfa_offset 32
	pop	r13
	.cfi_def_cfa_offset 24
	pop	r14
	.cfi_def_cfa_offset 16
	pop	r15
	.cfi_def_cfa_offset 8
	ret
.L130:
	.cfi_restore_state
	endbr64
	mov	rbp, rax
.L129:
	mov	rdi, rbx
	vzeroupper
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	mov	rdi, rbp
.LEHB1:
	call	_Unwind_Resume@PLT
.LEHE1:
	.cfi_endproc
.LFE9285:
	.globl	__gxx_personality_v0
	.section	.gcc_except_table,"a",@progbits
.LLSDA9285:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE9285-.LLSDACSB9285
.LLSDACSB9285:
	.uleb128 .LEHB0-.LFB9285
	.uleb128 .LEHE0-.LEHB0
	.uleb128 .L130-.LFB9285
	.uleb128 0
	.uleb128 .LEHB1-.LFB9285
	.uleb128 .LEHE1-.LEHB1
	.uleb128 0
	.uleb128 0
.LLSDACSE9285:
	.section	.text.unlikely
	.size	_ZStplIcSt11char_traitsIcESaIcEENSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_RKS8_.isra.0, .-_ZStplIcSt11char_traitsIcESaIcEENSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_RKS8_.isra.0
	.section	.rodata.str1.1
.LC8:
	.string	"stoull"
.LC9:
	.string	"Expected a positive integer: "
	.section	.text.unlikely
.LCOLDB10:
	.text
.LHOTB10:
	.p2align 4
	.type	_ZL14parse_positivePKc, @function
_ZL14parse_positivePKc:
.LFB7079:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA7079
	push	r14
	.cfi_def_cfa_offset 16
	.cfi_offset 14, -16
	mov	rsi, rdi
	push	r13
	.cfi_def_cfa_offset 24
	.cfi_offset 13, -24
	push	r12
	.cfi_def_cfa_offset 32
	.cfi_offset 12, -32
	push	rbp
	.cfi_def_cfa_offset 40
	.cfi_offset 6, -40
	push	rbx
	.cfi_def_cfa_offset 48
	.cfi_offset 3, -48
	sub	rsp, 96
	.cfi_def_cfa_offset 144
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR 88[rsp], rax
	xor	eax, eax
	lea	rbp, 8[rsp]
	lea	r13, 16[rsp]
	mov	rdx, rbp
	mov	rdi, r13
.LEHB2:
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC1IS3_EEPKcRKS3_
.LEHE2:
	mov	r12, QWORD PTR 16[rsp]
	call	__errno_location@PLT
	mov	rsi, rbp
	mov	edx, 10
	mov	r14d, DWORD PTR [rax]
	mov	DWORD PTR [rax], 0
	mov	rdi, r12
	mov	rbx, rax
	call	__isoc23_strtoull@PLT
	mov	rbp, rax
	mov	rax, QWORD PTR 8[rsp]
	cmp	r12, rax
	je	.L162
	mov	edx, DWORD PTR [rbx]
	cmp	edx, 34
	je	.L163
	sub	rax, r12
	test	edx, edx
	je	.L164
.L141:
	cmp	QWORD PTR 24[rsp], rax
	jne	.L142
	test	rbp, rbp
	je	.L165
	mov	rdi, r13
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	mov	rax, QWORD PTR 88[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L157
	add	rsp, 96
	.cfi_remember_state
	.cfi_def_cfa_offset 48
	mov	rax, rbp
	pop	rbx
	.cfi_def_cfa_offset 40
	pop	rbp
	.cfi_def_cfa_offset 32
	pop	r12
	.cfi_def_cfa_offset 24
	pop	r13
	.cfi_def_cfa_offset 16
	pop	r14
	.cfi_def_cfa_offset 8
	ret
.L164:
	.cfi_restore_state
	mov	DWORD PTR [rbx], r14d
	jmp	.L141
.L163:
	mov	rax, QWORD PTR 88[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L157
	lea	rdi, .LC8[rip]
.LEHB3:
	call	_ZSt20__throw_out_of_rangePKc@PLT
.L162:
	mov	rax, QWORD PTR 88[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L157
	lea	rdi, .LC8[rip]
	call	_ZSt24__throw_invalid_argumentPKc@PLT
.LEHE3:
.L157:
	call	__stack_chk_fail@PLT
.L155:
	endbr64
	jmp	.L144
.L165:
	jmp	.L142
	.section	.gcc_except_table
.LLSDA7079:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE7079-.LLSDACSB7079
.LLSDACSB7079:
	.uleb128 .LEHB2-.LFB7079
	.uleb128 .LEHE2-.LEHB2
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB3-.LFB7079
	.uleb128 .LEHE3-.LEHB3
	.uleb128 .L155-.LFB7079
	.uleb128 0
.LLSDACSE7079:
	.text
	.cfi_endproc
	.section	.text.unlikely
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDAC7079
	.type	_ZL14parse_positivePKc.cold, @function
_ZL14parse_positivePKc.cold:
.LFSB7079:
.L142:
	.cfi_def_cfa_offset 144
	.cfi_offset 3, -48
	.cfi_offset 6, -40
	.cfi_offset 12, -32
	.cfi_offset 13, -24
	.cfi_offset 14, -16
	mov	edi, 16
	lea	r12, 48[rsp]
	call	__cxa_allocate_exception@PLT
	mov	rcx, QWORD PTR 24[rsp]
	mov	rdx, QWORD PTR 16[rsp]
	mov	rdi, r12
	lea	rsi, .LC9[rip]
	mov	rbp, rax
.LEHB4:
	call	_ZStplIcSt11char_traitsIcESaIcEENSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_RKS8_.isra.0
.LEHE4:
	mov	rsi, r12
	mov	rdi, rbp
.LEHB5:
	call	_ZNSt13runtime_errorC1ERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE@PLT
.LEHE5:
	mov	rdi, r12
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	mov	rax, QWORD PTR 88[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L161
	mov	rdx, QWORD PTR _ZNSt13runtime_errorD1Ev@GOTPCREL[rip]
	lea	rsi, _ZTISt13runtime_error[rip]
	mov	rdi, rbp
.LEHB6:
	call	__cxa_throw@PLT
.LEHE6:
.L144:
	cmp	DWORD PTR [rbx], 0
	jne	.L159
	mov	DWORD PTR [rbx], r14d
.L159:
	mov	rbx, rax
	vzeroupper
	jmp	.L146
.L154:
	endbr64
	mov	rdi, r12
	mov	rbx, rax
	vzeroupper
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
.L149:
	mov	rdi, rbp
	call	__cxa_free_exception@PLT
.L146:
	mov	rdi, r13
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	mov	rax, QWORD PTR 88[rsp]
	sub	rax, QWORD PTR fs:40
	je	.L150
.L161:
	call	__stack_chk_fail@PLT
.L153:
	endbr64
	mov	rbx, rax
	vzeroupper
	jmp	.L149
.L152:
	endbr64
	jmp	.L159
.L150:
	mov	rdi, rbx
.LEHB7:
	call	_Unwind_Resume@PLT
.LEHE7:
	.cfi_endproc
.LFE7079:
	.section	.gcc_except_table
.LLSDAC7079:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSEC7079-.LLSDACSBC7079
.LLSDACSBC7079:
	.uleb128 .LEHB4-.LCOLDB10
	.uleb128 .LEHE4-.LEHB4
	.uleb128 .L153-.LCOLDB10
	.uleb128 0
	.uleb128 .LEHB5-.LCOLDB10
	.uleb128 .LEHE5-.LEHB5
	.uleb128 .L154-.LCOLDB10
	.uleb128 0
	.uleb128 .LEHB6-.LCOLDB10
	.uleb128 .LEHE6-.LEHB6
	.uleb128 .L152-.LCOLDB10
	.uleb128 0
	.uleb128 .LEHB7-.LCOLDB10
	.uleb128 .LEHE7-.LEHB7
	.uleb128 0
	.uleb128 0
.LLSDACSEC7079:
	.section	.text.unlikely
	.text
	.size	_ZL14parse_positivePKc, .-_ZL14parse_positivePKc
	.section	.text.unlikely
	.size	_ZL14parse_positivePKc.cold, .-_ZL14parse_positivePKc.cold
.LCOLDE10:
	.text
.LHOTE10:
	.section	.text._ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE11_M_gen_randEv,"axG",@progbits,_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE11_M_gen_randEv,comdat
	.align 2
	.p2align 4
	.weak	_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE11_M_gen_randEv
	.type	_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE11_M_gen_randEv, @function
_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE11_M_gen_randEv:
.LFB8445:
	.cfi_startproc
	endbr64
	movabs	rsi, -5403634167711393303
	mov	rdx, rdi
	mov	rax, rdi
	vpbroadcastq	ymm5, QWORD PTR .LC19[rip]
	vmovq	xmm2, rsi
	lea	rcx, 1248[rdi]
	vpxor	xmm6, xmm6, xmm6
	vpbroadcastq	ymm4, QWORD PTR .LC20[rip]
	vpbroadcastq	ymm3, QWORD PTR .LC21[rip]
	vpbroadcastq	ymm2, xmm2
	.p2align 4,,10
	.p2align 3
.L167:
	vpand	ymm1, ymm4, YMMWORD PTR 8[rax]
	vpand	ymm0, ymm5, YMMWORD PTR [rax]
	add	rax, 32
	vpor	ymm0, ymm0, ymm1
	vpsrlq	ymm1, ymm0, 1
	vpand	ymm0, ymm0, ymm3
	vpxor	ymm1, ymm1, YMMWORD PTR 1216[rax]
	vpsubq	ymm0, ymm6, ymm0
	vpand	ymm0, ymm0, ymm2
	vpxor	ymm0, ymm1, ymm0
	vmovdqu	YMMWORD PTR -32[rax], ymm0
	cmp	rax, rcx
	jne	.L167
	mov	rsi, -2147483648
	lea	rcx, 2464[rdx]
	vpxor	xmm6, xmm6, xmm6
	vmovq	xmm0, rsi
	mov	esi, 2147483647
	vmovq	xmm1, rsi
	mov	esi, 1
	vpbroadcastq	ymm9, xmm0
	vmovq	xmm2, rsi
	vpbroadcastq	ymm8, xmm1
	movabs	rsi, -5403634167711393303
	vmovq	xmm5, rsi
	vpbroadcastq	ymm7, xmm2
	vpbroadcastq	ymm5, xmm5
	.p2align 4,,10
	.p2align 3
.L168:
	vpand	ymm4, ymm8, YMMWORD PTR 8[rax]
	vpand	ymm3, ymm9, YMMWORD PTR [rax]
	add	rax, 32
	vpor	ymm3, ymm3, ymm4
	vpsrlq	ymm4, ymm3, 1
	vpand	ymm3, ymm3, ymm7
	vpxor	ymm4, ymm4, YMMWORD PTR -1280[rax]
	vpsubq	ymm3, ymm6, ymm3
	vpand	ymm3, ymm3, ymm5
	vpxor	ymm3, ymm4, ymm3
	vmovdqu	YMMWORD PTR -32[rax], ymm3
	cmp	rcx, rax
	jne	.L168
	mov	rdi, QWORD PTR 2488[rdx]
	vpunpcklqdq	xmm1, xmm1, xmm1
	vpunpcklqdq	xmm0, xmm0, xmm0
	vpunpcklqdq	xmm2, xmm2, xmm2
	mov	rax, QWORD PTR 2480[rdx]
	vpand	xmm1, xmm1, XMMWORD PTR 2472[rdx]
	vmovq	xmm7, rsi
	mov	QWORD PTR 2496[rdx], 0
	mov	rcx, rdi
	and	rdi, -2147483648
	vpand	xmm0, xmm0, XMMWORD PTR 2464[rdx]
	and	ecx, 2147483647
	and	rax, -2147483648
	or	rax, rcx
	vpor	xmm0, xmm0, xmm1
	mov	rcx, rax
	vpsrlq	xmm1, xmm0, 1
	vpand	xmm0, xmm0, xmm2
	and	eax, 1
	neg	rax
	shr	rcx
	xor	rcx, QWORD PTR 1232[rdx]
	vpxor	xmm2, xmm2, xmm2
	and	rax, rsi
	vpxor	xmm1, xmm1, XMMWORD PTR 1216[rdx]
	vpsubq	xmm0, xmm2, xmm0
	xor	rax, rcx
	vpunpcklqdq	xmm2, xmm7, xmm7
	mov	QWORD PTR 2480[rdx], rax
	mov	rax, QWORD PTR [rdx]
	vpand	xmm0, xmm0, xmm2
	vpxor	xmm0, xmm1, xmm0
	and	eax, 2147483647
	vmovdqu	XMMWORD PTR 2464[rdx], xmm0
	or	rax, rdi
	mov	rcx, rax
	and	eax, 1
	neg	rax
	shr	rcx
	xor	rcx, QWORD PTR 1240[rdx]
	and	rax, rsi
	xor	rax, rcx
	mov	QWORD PTR 2488[rdx], rax
	vzeroupper
	ret
	.cfi_endproc
.LFE8445:
	.size	_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE11_M_gen_randEv, .-_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE11_M_gen_randEv
	.section	.text._ZSt7shuffleIN9__gnu_cxx17__normal_iteratorIPmSt6vectorImSaImEEEERSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEEvT_SA_OT0_,"axG",@progbits,_ZSt7shuffleIN9__gnu_cxx17__normal_iteratorIPmSt6vectorImSaImEEEERSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEEvT_SA_OT0_,comdat
	.p2align 4
	.weak	_ZSt7shuffleIN9__gnu_cxx17__normal_iteratorIPmSt6vectorImSaImEEEERSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEEvT_SA_OT0_
	.type	_ZSt7shuffleIN9__gnu_cxx17__normal_iteratorIPmSt6vectorImSaImEEEERSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEEvT_SA_OT0_, @function
_ZSt7shuffleIN9__gnu_cxx17__normal_iteratorIPmSt6vectorImSaImEEEERSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEEvT_SA_OT0_:
.LFB7675:
	.cfi_startproc
	endbr64
	push	r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	push	r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	push	r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	push	r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	push	rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	push	rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	sub	rsp, 24
	.cfi_def_cfa_offset 80
	cmp	rdi, rsi
	mov	QWORD PTR [rsp], rsi
	je	.L201
	mov	rcx, rsi
	mov	rbx, rdx
	lea	rbp, 8[rdi]
	mov	r14, rdi
	sub	rcx, rdi
	sar	rcx, 3
	mov	rax, rcx
	mul	rcx
	seto	al
	movzx	eax, al
	test	rax, rax
	je	.L203
	cmp	QWORD PTR [rsp], rbp
	je	.L201
	movabs	r9, 6148914691236517205
	movabs	r13, 8202884508482404352
	movabs	r15, -2270628950310912
	.p2align 4,,10
	.p2align 3
.L194:
	mov	rax, rbp
	mov	rdx, QWORD PTR 2496[rbx]
	sub	rax, r14
	sar	rax, 3
	mov	rcx, rdx
	cmp	rax, -1
	je	.L187
	cmp	rdx, 311
	lea	r12, 1[rax]
	ja	.L204
.L188:
	mov	rsi, QWORD PTR [rbx+rdx*8]
	lea	rcx, 1[rdx]
	mov	QWORD PTR 2496[rbx], rcx
	mov	rdx, rsi
	shr	rdx, 29
	and	rdx, r9
	xor	rsi, rdx
	mov	rdx, rsi
	sal	rdx, 17
	and	rdx, r13
	xor	rsi, rdx
	mov	rdx, rsi
	sal	rdx, 37
	and	rdx, r15
	xor	rsi, rdx
	mov	rdx, rsi
	shr	rdx, 43
	xor	rsi, rdx
	mov	rdx, rsi
	mulx	rdi, rsi, r12
	cmp	rsi, r12
	jnb	.L189
	xor	edx, edx
	not	rax
	div	r12
	cmp	rsi, rdx
	mov	r8, rdx
	jb	.L191
	jmp	.L189
	.p2align 4,,10
	.p2align 3
.L190:
	mov	rsi, QWORD PTR [rbx+rax*8]
	lea	rcx, 1[rax]
	mov	QWORD PTR 2496[rbx], rcx
	mov	rax, rsi
	shr	rax, 29
	and	rax, r9
	xor	rsi, rax
	mov	rax, rsi
	sal	rax, 17
	and	rax, r13
	xor	rsi, rax
	mov	rax, rsi
	sal	rax, 37
	and	rax, r15
	xor	rsi, rax
	mov	rax, rsi
	shr	rax, 43
	xor	rsi, rax
	mov	rdx, rsi
	mulx	rdi, rsi, r12
	cmp	rsi, r8
	jnb	.L189
.L191:
	cmp	rcx, 311
	mov	rax, rcx
	jbe	.L190
	mov	rdi, rbx
	mov	QWORD PTR 8[rsp], r8
	call	_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE11_M_gen_randEv
	mov	rax, QWORD PTR 2496[rbx]
	mov	r8, QWORD PTR 8[rsp]
	movabs	r9, 6148914691236517205
	jmp	.L190
	.p2align 4,,10
	.p2align 3
.L189:
	mov	rax, rdi
.L192:
	lea	rax, [r14+rax*8]
	mov	rdx, QWORD PTR 0[rbp]
	add	rbp, 8
	mov	rcx, QWORD PTR [rax]
	mov	QWORD PTR -8[rbp], rcx
	cmp	QWORD PTR [rsp], rbp
	mov	QWORD PTR [rax], rdx
	jne	.L194
.L201:
	add	rsp, 24
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	pop	rbx
	.cfi_def_cfa_offset 48
	pop	rbp
	.cfi_def_cfa_offset 40
	pop	r12
	.cfi_def_cfa_offset 32
	pop	r13
	.cfi_def_cfa_offset 24
	pop	r14
	.cfi_def_cfa_offset 16
	pop	r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L187:
	.cfi_restore_state
	cmp	rdx, 311
	ja	.L205
.L193:
	lea	rax, 1[rcx]
	mov	QWORD PTR 2496[rbx], rax
	mov	rax, QWORD PTR [rbx+rcx*8]
	mov	rdx, rax
	shr	rdx, 29
	and	rdx, r9
	xor	rax, rdx
	mov	rdx, rax
	sal	rdx, 17
	and	rdx, r13
	xor	rax, rdx
	mov	rdx, rax
	sal	rdx, 37
	and	rdx, r15
	xor	rax, rdx
	mov	rdx, rax
	shr	rdx, 43
	xor	rax, rdx
	jmp	.L192
	.p2align 4,,10
	.p2align 3
.L204:
	mov	rdi, rbx
	mov	QWORD PTR 8[rsp], rax
	call	_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE11_M_gen_randEv
	mov	rdx, QWORD PTR 2496[rbx]
	mov	rax, QWORD PTR 8[rsp]
	movabs	r9, 6148914691236517205
	jmp	.L188
	.p2align 4,,10
	.p2align 3
.L205:
	mov	rdi, rbx
	call	_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE11_M_gen_randEv
	mov	rcx, QWORD PTR 2496[rbx]
	movabs	r9, 6148914691236517205
	jmp	.L193
	.p2align 4,,10
	.p2align 3
.L203:
	and	ecx, 1
	je	.L206
.L176:
	cmp	QWORD PTR [rsp], rbp
	je	.L201
	movabs	r10, 6148914691236517205
	movabs	r9, 8202884508482404352
	movabs	r13, -2270628950310912
	.p2align 4,,10
	.p2align 3
.L186:
	mov	r12, rbp
	mov	rax, QWORD PTR 2496[rbx]
	sub	r12, r14
	sar	r12, 3
	lea	r15, 2[r12]
	add	r12, 1
	imul	r12, r15
	test	r12, r12
	je	.L179
	cmp	rax, 311
	ja	.L207
.L180:
	mov	rsi, QWORD PTR [rbx+rax*8]
	lea	rcx, 1[rax]
	mov	QWORD PTR 2496[rbx], rcx
	mov	rax, rsi
	shr	rax, 29
	and	rax, r10
	xor	rsi, rax
	mov	rax, rsi
	sal	rax, 17
	and	rax, r9
	xor	rsi, rax
	mov	rax, rsi
	sal	rax, 37
	and	rax, r13
	xor	rsi, rax
	mov	rax, rsi
	shr	rax, 43
	xor	rsi, rax
	mov	rdx, rsi
	mulx	rdi, rsi, r12
	cmp	rsi, r12
	jnb	.L181
	mov	rax, r12
	xor	edx, edx
	neg	rax
	div	r12
	cmp	rsi, rdx
	mov	r8, rdx
	jb	.L183
	jmp	.L181
	.p2align 4,,10
	.p2align 3
.L182:
	mov	rsi, QWORD PTR [rbx+rax*8]
	lea	rcx, 1[rax]
	mov	QWORD PTR 2496[rbx], rcx
	mov	rax, rsi
	shr	rax, 29
	and	rax, r10
	xor	rsi, rax
	mov	rax, rsi
	sal	rax, 17
	and	rax, r9
	xor	rsi, rax
	mov	rax, rsi
	sal	rax, 37
	and	rax, r13
	xor	rsi, rax
	mov	rax, rsi
	shr	rax, 43
	xor	rsi, rax
	mov	rdx, rsi
	mulx	rdi, rsi, r12
	cmp	rsi, r8
	jnb	.L181
.L183:
	cmp	rcx, 311
	mov	rax, rcx
	jbe	.L182
	mov	rdi, rbx
	mov	QWORD PTR 8[rsp], r8
	call	_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE11_M_gen_randEv
	mov	rax, QWORD PTR 2496[rbx]
	mov	r8, QWORD PTR 8[rsp]
	movabs	r9, 8202884508482404352
	movabs	r10, 6148914691236517205
	jmp	.L182
	.p2align 4,,10
	.p2align 3
.L181:
	mov	rax, rdi
.L184:
	xor	edx, edx
	mov	rcx, QWORD PTR 0[rbp]
	add	rbp, 16
	div	r15
	lea	rax, [r14+rax*8]
	mov	rsi, QWORD PTR [rax]
	mov	QWORD PTR -16[rbp], rsi
	mov	QWORD PTR [rax], rcx
	lea	rax, [r14+rdx*8]
	mov	rdx, QWORD PTR -8[rbp]
	mov	rcx, QWORD PTR [rax]
	mov	QWORD PTR -8[rbp], rcx
	cmp	QWORD PTR [rsp], rbp
	mov	QWORD PTR [rax], rdx
	jne	.L186
	jmp	.L201
	.p2align 4,,10
	.p2align 3
.L179:
	cmp	rax, 311
	ja	.L208
.L185:
	lea	rdx, 1[rax]
	mov	rax, QWORD PTR [rbx+rax*8]
	mov	QWORD PTR 2496[rbx], rdx
	mov	rdx, rax
	shr	rdx, 29
	and	rdx, r10
	xor	rax, rdx
	mov	rdx, rax
	sal	rdx, 17
	and	rdx, r9
	xor	rax, rdx
	mov	rdx, rax
	sal	rdx, 37
	and	rdx, r13
	xor	rax, rdx
	mov	rdx, rax
	shr	rdx, 43
	xor	rax, rdx
	jmp	.L184
	.p2align 4,,10
	.p2align 3
.L207:
	mov	rdi, rbx
	call	_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE11_M_gen_randEv
	mov	rax, QWORD PTR 2496[rbx]
	movabs	r9, 8202884508482404352
	movabs	r10, 6148914691236517205
	jmp	.L180
	.p2align 4,,10
	.p2align 3
.L208:
	mov	rdi, rbx
	call	_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE11_M_gen_randEv
	mov	rax, QWORD PTR 2496[rbx]
	movabs	r9, 8202884508482404352
	movabs	r10, 6148914691236517205
	jmp	.L185
.L206:
	mov	rax, QWORD PTR 2496[rbx]
	cmp	rax, 311
	ja	.L209
.L177:
	lea	rdx, 1[rax]
	mov	rax, QWORD PTR [rbx+rax*8]
	lea	rbp, 16[r14]
	movabs	rcx, 6148914691236517205
	mov	QWORD PTR 2496[rbx], rdx
	mov	rdx, rax
	shr	rdx, 29
	and	rdx, rcx
	movabs	rcx, 8202884508482404352
	xor	rax, rdx
	mov	rdx, rax
	sal	rdx, 17
	and	rdx, rcx
	movabs	rcx, -2270628950310912
	xor	rax, rdx
	mov	rdx, rax
	sal	rdx, 37
	and	rdx, rcx
	xor	rax, rdx
	mov	rdx, rax
	shr	rdx, 43
	xor	rax, rdx
	mov	edx, 2
	mul	rdx
	lea	rax, [r14+rdx*8]
	mov	rdx, QWORD PTR 8[r14]
	mov	rcx, QWORD PTR [rax]
	mov	QWORD PTR 8[r14], rcx
	mov	QWORD PTR [rax], rdx
	jmp	.L176
.L209:
	mov	rdi, rbx
	call	_ZNSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EE11_M_gen_randEv
	mov	rax, QWORD PTR 2496[rbx]
	jmp	.L177
	.cfi_endproc
.LFE7675:
	.size	_ZSt7shuffleIN9__gnu_cxx17__normal_iteratorIPmSt6vectorImSaImEEEERSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEEvT_SA_OT0_, .-_ZSt7shuffleIN9__gnu_cxx17__normal_iteratorIPmSt6vectorImSaImEEEERSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEEvT_SA_OT0_
	.text
	.p2align 4
	.type	_ZL10make_cycleRSt6vectorImSaImEEmmm, @function
_ZL10make_cycleRSt6vectorImSaImEEmmm:
.LFB7090:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	push	r15
	push	r14
	push	r13
	push	r12
	push	rbx
	and	rsp, -32
	sub	rsp, 2528
	.cfi_offset 15, -24
	.cfi_offset 14, -32
	.cfi_offset 13, -40
	.cfi_offset 12, -48
	.cfi_offset 3, -56
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR 2520[rsp], rax
	mov	rax, rdx
	shr	rax, 60
	jne	.L244
	test	rdx, rdx
	mov	QWORD PTR 8[rsp], rsi
	mov	rbx, rdi
	mov	r14, rdx
	mov	r13, rcx
	je	.L228
	lea	r12, 0[0+rdx*8]
	mov	rdi, r12
	call	_Znwm@PLT
	cmp	r14, 1
	mov	r8, QWORD PTR 8[rsp]
	mov	QWORD PTR [rax], 0
	mov	r15, rax
	lea	rdi, 8[rax]
	je	.L229
	lea	rcx, [rax+r12]
	cmp	rcx, rdi
	je	.L216
	lea	rdx, -8[r12]
	xor	esi, esi
	mov	QWORD PTR [rsp], r8
	mov	QWORD PTR 8[rsp], rcx
	call	memset@PLT
	mov	rcx, QWORD PTR 8[rsp]
	mov	r8, QWORD PTR [rsp]
.L216:
	mov	rdi, rcx
.L214:
	cmp	rdi, r15
	je	.L213
	mov	rdx, rdi
	mov	rax, r15
	sub	rdx, r15
	sub	rdx, 8
	mov	rcx, rdx
	shr	rcx, 3
	add	rcx, 1
	cmp	rdx, 16
	jbe	.L217
	mov	rdx, rcx
	vmovq	xmm3, r8
	vpbroadcastq	ymm2, QWORD PTR .LC3[rip]
	shr	rdx, 2
	vpbroadcastq	ymm0, xmm3
	vpaddq	ymm0, ymm0, YMMWORD PTR .LC0[rip]
	sal	rdx, 5
	add	rdx, r15
	.p2align 4,,10
	.p2align 3
.L218:
	vmovdqa	ymm1, ymm0
	add	rax, 32
	vpaddq	ymm0, ymm0, ymm2
	vmovdqu	YMMWORD PTR -32[rax], ymm1
	cmp	rdx, rax
	jne	.L218
	mov	rax, rcx
	and	rax, -4
	add	r8, rax
	and	ecx, 3
	lea	rax, [r15+rax*8]
	je	.L245
	vzeroupper
.L217:
	lea	rcx, 8[rax]
	mov	QWORD PTR [rax], r8
	lea	rdx, 1[r8]
	cmp	rdi, rcx
	je	.L213
	mov	QWORD PTR 8[rax], rdx
	lea	rdx, 16[rax]
	add	r8, 2
	cmp	rdi, rdx
	je	.L213
	mov	QWORD PTR 16[rax], r8
.L213:
	mov	QWORD PTR 16[rsp], r13
	mov	edx, 1
	lea	rcx, 16[rsp]
	movabs	rsi, 6364136223846793005
	.p2align 4,,10
	.p2align 3
.L221:
	mov	rax, r13
	shr	rax, 62
	xor	rax, r13
	imul	rax, rsi
	lea	r13, [rax+rdx]
	mov	QWORD PTR [rcx+rdx*8], r13
	add	rdx, 1
	cmp	rdx, 312
	jne	.L221
	mov	rsi, rdi
	mov	rdx, rcx
	mov	rdi, r15
	mov	QWORD PTR 2512[rsp], 312
	call	_ZSt7shuffleIN9__gnu_cxx17__normal_iteratorIPmSt6vectorImSaImEEEERSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEEvT_SA_OT0_
	test	r14, r14
	je	.L246
	mov	rsi, QWORD PTR [rbx]
	xor	ecx, ecx
	.p2align 4,,10
	.p2align 3
.L225:
	add	rcx, 1
	xor	edx, edx
	mov	rax, rcx
	div	r14
	mov	rax, QWORD PTR -8[r15+rcx*8]
	cmp	rcx, r14
	mov	rdx, QWORD PTR [r15+rdx*8]
	mov	QWORD PTR [rsi+rax*8], rdx
	jne	.L225
.L223:
	mov	rax, QWORD PTR 2520[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L243
	lea	rsp, -40[rbp]
	mov	rsi, r12
	mov	rdi, r15
	pop	rbx
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	pop	rbp
	.cfi_remember_state
	.cfi_def_cfa 7, 8
	jmp	_ZdlPvm@PLT
.L228:
	.cfi_restore_state
	xor	r12d, r12d
	xor	r15d, r15d
	xor	edi, edi
	jmp	.L213
.L229:
	mov	r12d, 8
	jmp	.L214
.L246:
	test	r15, r15
	jne	.L223
	mov	rax, QWORD PTR 2520[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L243
	lea	rsp, -40[rbp]
	pop	rbx
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	pop	rbp
	.cfi_remember_state
	.cfi_def_cfa 7, 8
	ret
.L245:
	.cfi_restore_state
	vzeroupper
	jmp	.L213
.L244:
	mov	rax, QWORD PTR 2520[rsp]
	sub	rax, QWORD PTR fs:40
	jne	.L243
	lea	rdi, .LC1[rip]
	call	_ZSt20__throw_length_errorPKc@PLT
.L243:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE7090:
	.size	_ZL10make_cycleRSt6vectorImSaImEEmmm, .-_ZL10make_cycleRSt6vectorImSaImEEmmm
	.section	.rodata.str1.1
.LC23:
	.string	"Usage: "
	.section	.rodata.str1.8
	.align 8
.LC24:
	.string	" MODE ELEMENTS WORK_COUNT REPEATS [CHAINS] [SEED]"
	.align 8
.LC25:
	.string	"MODE: stream | random | chase | chains"
	.align 8
.LC26:
	.string	"ELEMENTS: uint64_t elements / pointer nodes"
	.align 8
.LC27:
	.string	"WORK_COUNT: stream passes; otherwise accesses or steps per chain"
	.section	.rodata.str1.1
.LC28:
	.string	"REPEATS: timed repetitions"
	.section	.rodata.str1.8
	.align 8
.LC29:
	.string	"CHAINS: chains mode only; default 1"
	.align 8
.LC30:
	.string	"SEED: optional deterministic seed; default 12345"
	.align 8
.LC31:
	.string	"Working-set byte count would overflow"
	.section	.rodata.str1.1
.LC32:
	.string	"chains"
.LC33:
	.string	"stream"
	.section	.rodata.str1.8
	.align 8
.LC34:
	.string	"For chains mode, CHAINS must divide ELEMENTS and be <= ELEMENTS"
	.section	.rodata.str1.1
.LC35:
	.string	"random"
.LC38:
	.string	"chase"
.LC39:
	.string	"Unknown mode: "
	.section	.rodata.str1.8
	.align 8
.LC40:
	.string	"mode,elements,working_set_bytes,work_count,chains,repeat,seconds,operations,ns_per_operation,nominal_bytes,checksum"
	.section	.rodata.str1.1
.LC44:
	.string	"Error: "
	.section	.text.unlikely
.LCOLDB46:
	.section	.text.startup,"ax",@progbits
.LHOTB46:
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB7104:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA7104
	endbr64
	lea	r10, 8[rsp]
	.cfi_def_cfa 10, 0
	and	rsp, -32
	push	QWORD PTR -8[r10]
	push	rbp
	mov	rbp, rsp
	.cfi_escape 0x10,0x6,0x2,0x76,0
	push	r15
	push	r14
	push	r13
	push	r12
	push	r10
	.cfi_escape 0xf,0x3,0x76,0x58,0x6
	.cfi_escape 0x10,0xf,0x2,0x76,0x78
	.cfi_escape 0x10,0xe,0x2,0x76,0x70
	.cfi_escape 0x10,0xd,0x2,0x76,0x68
	.cfi_escape 0x10,0xc,0x2,0x76,0x60
	push	rbx
	.cfi_escape 0x10,0x3,0x2,0x76,0x50
	mov	rbx, rsi
	sub	rsp, 2784
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR -56[rbp], rax
	xor	eax, eax
	cmp	edi, 4
	jle	.L492
	lea	rax, -2592[rbp]
	mov	rsi, QWORD PTR 8[rsi]
	mov	r12d, edi
	lea	rdx, -2624[rbp]
	mov	rdi, rax
	mov	QWORD PTR -2752[rbp], rdx
	mov	QWORD PTR -2744[rbp], rax
.LEHB8:
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEC1IS3_EEPKcRKS3_
.LEHE8:
	mov	rdi, QWORD PTR 16[rbx]
.LEHB9:
	call	_ZL14parse_positivePKc
	mov	rdi, QWORD PTR 24[rbx]
	mov	QWORD PTR -2712[rbp], rax
	call	_ZL14parse_positivePKc
	mov	rdi, QWORD PTR 32[rbx]
	mov	r15, rax
	call	_ZL14parse_positivePKc
.LEHE9:
	cmp	r12d, 5
	mov	QWORD PTR -2728[rbp], rax
	jne	.L493
	mov	QWORD PTR -2760[rbp], 1
	mov	r13d, 12345
.L250:
	mov	rax, QWORD PTR -2712[rbp]
	shr	rax, 61
	jne	.L474
	mov	rdi, QWORD PTR -2744[rbp]
	lea	rsi, .LC32[rip]
	call	_ZSteqIcSt11char_traitsIcESaIcEEbRKNSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_
	test	al, al
	je	.L253
	mov	rax, QWORD PTR -2712[rbp]
	mov	rbx, QWORD PTR -2760[rbp]
	cmp	rax, rbx
	jb	.L254
	xor	edx, edx
	div	rbx
	test	rdx, rdx
	jne	.L254
.L253:
	mov	rdi, QWORD PTR -2744[rbp]
	vpxor	xmm0, xmm0, xmm0
	lea	rsi, .LC33[rip]
	mov	QWORD PTR -2640[rbp], 0
	mov	QWORD PTR -2608[rbp], 0
	vmovdqa	XMMWORD PTR -2656[rbp], xmm0
	vmovdqa	XMMWORD PTR -2624[rbp], xmm0
	call	_ZSteqIcSt11char_traitsIcESaIcEEbRKNSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_
	test	al, al
	jne	.L255
	lea	rax, .LC35[rip]
	mov	rdi, QWORD PTR -2744[rbp]
	mov	rsi, rax
	mov	QWORD PTR -2688[rbp], rax
	call	_ZSteqIcSt11char_traitsIcESaIcEEbRKNSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_
	test	al, al
	jne	.L255
	xor	edx, edx
	xor	r14d, r14d
	mov	QWORD PTR -2768[rbp], rdx
	mov	QWORD PTR -2792[rbp], rdx
.L258:
	mov	rdi, QWORD PTR -2744[rbp]
	lea	rsi, .LC38[rip]
	call	_ZSteqIcSt11char_traitsIcESaIcEEbRKNSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_
	test	al, al
	jne	.L494
.L280:
	mov	rdi, QWORD PTR -2744[rbp]
	lea	rsi, .LC32[rip]
	call	_ZSteqIcSt11char_traitsIcESaIcEEbRKNSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_
	test	al, al
	je	.L284
	mov	rbx, QWORD PTR -2712[rbp]
	mov	rdi, QWORD PTR -2752[rbp]
	mov	rsi, rbx
.LEHB10:
	call	_ZNSt6vectorImSaImEE6resizeEm
	mov	rax, rbx
	mov	rbx, QWORD PTR -2760[rbp]
	xor	edx, edx
	div	rbx
	test	rbx, rbx
	mov	r12, rax
	je	.L284
	lea	rax, 0[r13+rbx]
	xor	ebx, ebx
	mov	QWORD PTR -2680[rbp], rax
	.p2align 4,,10
	.p2align 3
.L285:
	mov	rdi, QWORD PTR -2752[rbp]
	mov	rcx, r13
	mov	rdx, r12
	mov	rsi, rbx
	call	_ZL10make_cycleRSt6vectorImSaImEEmmm
.LEHE10:
	mov	rax, QWORD PTR -2680[rbp]
	add	r13, 1
	add	rbx, r12
	cmp	r13, rax
	jne	.L285
.L284:
	mov	rbx, QWORD PTR -2656[rbp]
	mov	rax, QWORD PTR -2584[rbp]
	mov	QWORD PTR -2776[rbp], rbx
	mov	rbx, QWORD PTR -2624[rbp]
	cmp	rax, 6
	mov	QWORD PTR -2784[rbp], rbx
	je	.L495
	cmp	rax, 5
	jne	.L496
	mov	rdi, QWORD PTR -2592[rbp]
	mov	edx, 5
	lea	rsi, .LC38[rip]
	call	memcmp@PLT
	test	eax, eax
	jne	.L296
	test	r15, r15
	je	.L403
	mov	rdx, QWORD PTR -2784[rbp]
	xor	eax, eax
	xor	ecx, ecx
.L297:
	add	rax, 1
	mov	rcx, QWORD PTR [rdx+rcx*8]
	cmp	r15, rax
	jne	.L297
	jmp	.L287
.L493:
	mov	rdi, QWORD PTR 40[rbx]
.LEHB11:
	call	_ZL14parse_positivePKc
	cmp	r12d, 6
	mov	QWORD PTR -2760[rbp], rax
	je	.L394
	mov	rdi, QWORD PTR 48[rbx]
	call	_ZL14parse_positivePKc
.LEHE11:
	mov	r13, rax
	jmp	.L250
.L255:
	mov	rbx, QWORD PTR -2712[rbp]
	movabs	rax, 1152921504606846975
	cmp	rax, rbx
	jb	.L497
	mov	r12, QWORD PTR -2712[rbp]
	test	r12, r12
	je	.L396
	lea	rbx, 0[0+r12*8]
	mov	rdi, rbx
.LEHB12:
	call	_Znwm@PLT
.LEHE12:
	mov	r14, rax
	lea	rax, [rax+rbx]
	xor	r8d, r8d
	sub	r12, 1
	mov	QWORD PTR -2792[rbp], rax
	lea	rax, 8[r14]
	mov	QWORD PTR [r14], r8
	mov	QWORD PTR -2768[rbp], rax
	je	.L498
	mov	r12, QWORD PTR -2792[rbp]
	mov	rdi, QWORD PTR -2768[rbp]
	cmp	r12, rdi
	je	.L266
	lea	rdx, -8[rbx]
	xor	esi, esi
	call	memset@PLT
	mov	QWORD PTR -2768[rbp], r12
.L266:
	mov	rbx, QWORD PTR -2712[rbp]
	lea	rax, -1[rbx]
	cmp	rax, 2
	jbe	.L267
	shr	rbx, 2
	mov	rax, r14
	movabs	rcx, -7046029254386353131
	vmovdqa	ymm3, YMMWORD PTR .LC0[rip]
	mov	rdx, rbx
	vmovq	xmm4, rcx
	vpbroadcastq	ymm6, QWORD PTR .LC3[rip]
	vpbroadcastq	ymm5, QWORD PTR .LC21[rip]
	sal	rdx, 5
	vpbroadcastq	ymm4, xmm4
	add	rdx, r14
	vpsrlq	ymm7, ymm4, 32
	.p2align 4,,10
	.p2align 3
.L268:
	vmovdqa	ymm2, ymm3
	add	rax, 32
	vpaddq	ymm3, ymm3, ymm6
	vpsrlq	ymm0, ymm2, 32
	vpmuludq	ymm1, ymm2, ymm4
	vpmuludq	ymm0, ymm0, ymm4
	vpmuludq	ymm2, ymm7, ymm2
	vpaddq	ymm0, ymm0, ymm2
	vpsllq	ymm0, ymm0, 32
	vpaddq	ymm0, ymm1, ymm0
	vpaddq	ymm0, ymm0, ymm5
	vmovdqu	YMMWORD PTR -32[rax], ymm0
	cmp	rax, rdx
	jne	.L268
	mov	rbx, QWORD PTR -2712[rbp]
	mov	rax, rbx
	and	rax, -4
	and	bl, 3
	je	.L499
	vzeroupper
.L265:
	mov	rbx, QWORD PTR -2712[rbp]
	lea	rcx, 0[0+rax*8]
	movabs	rdx, -7046029254386353131
	imul	rdx, rax
	lea	rsi, 1[rdx]
	mov	QWORD PTR [r14+rax*8], rsi
	lea	rsi, 1[rax]
	cmp	rsi, rbx
	jnb	.L261
.L391:
	mov	rbx, QWORD PTR -2712[rbp]
	add	rax, 2
	movabs	rsi, -7046029254386353130
	add	rsi, rdx
	cmp	rax, rbx
	mov	QWORD PTR 8[r14+rcx], rsi
	jnb	.L261
	movabs	rax, 4354685564936845355
	add	rdx, rax
	mov	QWORD PTR 16[r14+rcx], rdx
	jmp	.L261
.L494:
	mov	r12, QWORD PTR -2712[rbp]
	mov	rbx, QWORD PTR -2752[rbp]
	mov	rsi, r12
	mov	rdi, rbx
.LEHB13:
	call	_ZNSt6vectorImSaImEE6resizeEm
	mov	rcx, r13
	mov	rdx, r12
	xor	esi, esi
	mov	rdi, rbx
	call	_ZL10make_cycleRSt6vectorImSaImEEmmm
	jmp	.L280
.L495:
	mov	rbx, QWORD PTR -2592[rbp]
	mov	edx, 6
	lea	rsi, .LC33[rip]
	mov	rdi, rbx
	call	memcmp@PLT
	test	eax, eax
	jne	.L286
	test	r15, r15
	je	.L403
	mov	rdi, QWORD PTR -2768[rbp]
	mov	r10d, 1
	mov	r11, rdi
	sub	r11, r14
	mov	r8, r11
	sar	r8, 3
	test	r11, r11
	cmovne	r10, r8
	xor	ecx, ecx
	xor	esi, esi
	mov	rax, r10
	mov	rbx, r10
	and	r10d, 3
	shr	rax, 2
	and	rbx, -4
	sal	rax, 5
	add	rax, r14
	.p2align 4,,10
	.p2align 3
.L288:
	cmp	rdi, r14
	je	.L293
	cmp	r11, 24
	jbe	.L401
	mov	rdx, r14
	vpxor	xmm0, xmm0, xmm0
	.p2align 4,,10
	.p2align 3
.L290:
	vpaddq	ymm0, ymm0, YMMWORD PTR [rdx]
	add	rdx, 32
	cmp	rax, rdx
	jne	.L290
	vextracti128	xmm1, ymm0, 0x1
	vpaddq	xmm0, xmm1, xmm0
	vpsrldq	xmm1, xmm0, 8
	vpaddq	xmm0, xmm0, xmm1
	vmovq	rdx, xmm0
	add	rcx, rdx
	test	r10, r10
	mov	rdx, rbx
	je	.L293
.L289:
	lea	r12, 1[rdx]
	add	rcx, QWORD PTR [r14+rdx*8]
	lea	r9, 0[0+rdx*8]
	cmp	r12, r8
	jnb	.L293
	add	rdx, 2
	add	rcx, QWORD PTR 8[r14+r9]
	cmp	rdx, r8
	jnb	.L293
	add	rcx, QWORD PTR 16[r14+r9]
.L293:
	add	rsi, 1
	cmp	r15, rsi
	jne	.L288
	vzeroupper
.L287:
	mov	edx, 115
	lea	rsi, .LC40[rip]
	lea	rdi, _ZSt4cout[rip]
	mov	QWORD PTR _ZL11result_sink[rip], rcx
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	lea	rdi, _ZSt4cout[rip]
	call	_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_@PLT
	cmp	QWORD PTR -2728[rbp], 0
	je	.L375
	mov	rax, QWORD PTR -2768[rbp]
	mov	rcx, QWORD PTR -2712[rbp]
	mov	QWORD PTR -2680[rbp], 0
	sub	rax, r14
	sal	rcx, 3
	mov	rbx, rax
	mov	QWORD PTR -2800[rbp], rax
	sar	rbx, 3
	test	rax, rax
	mov	eax, 1
	mov	QWORD PTR -2736[rbp], rcx
	cmovne	rax, rbx
	mov	QWORD PTR -2824[rbp], rbx
	mov	r12, rax
	mov	QWORD PTR -2816[rbp], rax
	and	rax, -4
	shr	r12, 2
	mov	QWORD PTR -2808[rbp], rax
	sal	r12, 5
	add	r12, r14
	.p2align 4,,10
	.p2align 3
.L374:
	call	_ZNSt6chrono3_V212steady_clock3nowEv@PLT
	mov	r13, rax
	mov	rax, QWORD PTR -2584[rbp]
	cmp	rax, 6
	je	.L500
	cmp	rax, 5
	jne	.L501
	mov	rdi, QWORD PTR -2592[rbp]
	mov	edx, 5
	lea	rsi, .LC38[rip]
	call	memcmp@PLT
	test	eax, eax
	jne	.L321
	test	r15, r15
	je	.L406
	mov	rdx, QWORD PTR -2784[rbp]
	xor	eax, eax
	xor	ebx, ebx
	.p2align 4,,10
	.p2align 3
.L323:
	add	rax, 1
	mov	rbx, QWORD PTR [rdx+rbx*8]
	cmp	r15, rax
	jne	.L323
	.p2align 4,,10
	.p2align 3
.L310:
	call	_ZNSt6chrono3_V212steady_clock3nowEv@PLT
	vxorpd	xmm7, xmm7, xmm7
	mov	QWORD PTR _ZL11result_sink[rip], rbx
	sub	rax, r13
	mov	r13, QWORD PTR -2584[rbp]
	vcvtsi2sd	xmm0, xmm7, rax
	vdivsd	xmm4, xmm0, QWORD PTR .LC41[rip]
	vmovsd	QWORD PTR -2696[rbp], xmm4
	cmp	r13, 6
	je	.L502
	cmp	r13, 5
	mov	rcx, QWORD PTR -2592[rbp]
	jne	.L338
	mov	rdi, rcx
	mov	edx, 5
	lea	rsi, .LC38[rip]
	mov	QWORD PTR -2688[rbp], rcx
	call	memcmp@PLT
	mov	rcx, QWORD PTR -2688[rbp]
	test	eax, eax
	jne	.L338
	test	r15, r15
	js	.L340
	vxorpd	xmm4, xmm4, xmm4
	vcvtsi2sd	xmm0, xmm4, r15
	vmovsd	QWORD PTR -2688[rbp], xmm0
.L341:
	vmovsd	xmm7, QWORD PTR .LC42[rip]
	vmulsd	xmm3, xmm7, QWORD PTR -2688[rbp]
	vmovsd	xmm6, QWORD PTR -2688[rbp]
	vmovsd	QWORD PTR -2720[rbp], xmm3
	.p2align 4,,10
	.p2align 3
.L334:
	vmovsd	xmm3, QWORD PTR .LC41[rip]
	vmovsd	xmm0, QWORD PTR .LC43[rip]
	vmulsd	xmm5, xmm3, QWORD PTR -2696[rbp]
	vcomisd	xmm0, xmm6
	vmovsd	QWORD PTR -2704[rbp], xmm5
	ja	.L346
	vdivsd	xmm4, xmm5, xmm6
	vmovsd	QWORD PTR -2704[rbp], xmm4
.L346:
	mov	rdx, r13
	mov	rsi, rcx
	lea	rdi, _ZSt4cout[rip]
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	r13, rax
	mov	rax, QWORD PTR [rax]
	mov	BYTE PTR -2666[rbp], 44
	mov	rax, QWORD PTR -24[rax]
	cmp	QWORD PTR 16[r13+rax], 0
	je	.L347
	lea	rsi, -2666[rbp]
	mov	edx, 1
	mov	rdi, r13
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	r13, rax
.L348:
	mov	rsi, QWORD PTR -2712[rbp]
	mov	rdi, r13
	call	_ZNSo9_M_insertImEERSoT_@PLT
	mov	r13, rax
	mov	rax, QWORD PTR [rax]
	mov	BYTE PTR -2665[rbp], 44
	mov	rax, QWORD PTR -24[rax]
	cmp	QWORD PTR 16[r13+rax], 0
	je	.L349
	lea	rsi, -2665[rbp]
	mov	edx, 1
	mov	rdi, r13
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	r13, rax
.L350:
	mov	rsi, QWORD PTR -2736[rbp]
	mov	rdi, r13
	call	_ZNSo9_M_insertImEERSoT_@PLT
	mov	r13, rax
	mov	rax, QWORD PTR [rax]
	mov	BYTE PTR -2664[rbp], 44
	mov	rax, QWORD PTR -24[rax]
	cmp	QWORD PTR 16[r13+rax], 0
	je	.L351
	lea	rsi, -2664[rbp]
	mov	edx, 1
	mov	rdi, r13
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	r13, rax
.L352:
	mov	rsi, r15
	mov	rdi, r13
	call	_ZNSo9_M_insertImEERSoT_@PLT
	mov	r13, rax
	mov	rax, QWORD PTR [rax]
	mov	BYTE PTR -2663[rbp], 44
	mov	rax, QWORD PTR -24[rax]
	cmp	QWORD PTR 16[r13+rax], 0
	je	.L353
	lea	rsi, -2663[rbp]
	mov	edx, 1
	mov	rdi, r13
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	cmp	QWORD PTR -2584[rbp], 6
	mov	r13, rax
	mov	esi, 1
	je	.L503
.L355:
	mov	rdi, r13
	call	_ZNSo9_M_insertImEERSoT_@PLT
	mov	r13, rax
	mov	rax, QWORD PTR [rax]
	mov	BYTE PTR -2662[rbp], 44
	mov	rax, QWORD PTR -24[rax]
	cmp	QWORD PTR 16[r13+rax], 0
	je	.L358
	lea	rsi, -2662[rbp]
	mov	edx, 1
	mov	rdi, r13
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	r13, rax
.L359:
	mov	rsi, QWORD PTR -2680[rbp]
	mov	rdi, r13
	call	_ZNSo9_M_insertImEERSoT_@PLT
	mov	r13, rax
	mov	rax, QWORD PTR [rax]
	mov	BYTE PTR -2661[rbp], 44
	mov	rax, QWORD PTR -24[rax]
	cmp	QWORD PTR 16[r13+rax], 0
	je	.L360
	lea	rsi, -2661[rbp]
	mov	edx, 1
	mov	rdi, r13
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	r13, rax
.L361:
	mov	rax, QWORD PTR 0[r13]
	vmovsd	xmm0, QWORD PTR -2696[rbp]
	mov	rdi, r13
	mov	rax, QWORD PTR -24[rax]
	mov	QWORD PTR 8[r13+rax], 10
	call	_ZNSo9_M_insertIdEERSoT_@PLT
	mov	r13, rax
	mov	rax, QWORD PTR [rax]
	mov	BYTE PTR -2660[rbp], 44
	mov	rax, QWORD PTR -24[rax]
	cmp	QWORD PTR 16[r13+rax], 0
	je	.L362
	lea	rsi, -2660[rbp]
	mov	edx, 1
	mov	rdi, r13
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	r13, rax
.L363:
	vmovsd	xmm0, QWORD PTR -2688[rbp]
	mov	rdi, r13
	call	_ZNSo9_M_insertIdEERSoT_@PLT
	mov	r13, rax
	mov	rax, QWORD PTR [rax]
	mov	BYTE PTR -2659[rbp], 44
	mov	rax, QWORD PTR -24[rax]
	cmp	QWORD PTR 16[r13+rax], 0
	je	.L364
	lea	rsi, -2659[rbp]
	mov	edx, 1
	mov	rdi, r13
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	r13, rax
.L365:
	vmovsd	xmm0, QWORD PTR -2704[rbp]
	mov	rdi, r13
	call	_ZNSo9_M_insertIdEERSoT_@PLT
	mov	r13, rax
	mov	rax, QWORD PTR [rax]
	mov	BYTE PTR -2658[rbp], 44
	mov	rax, QWORD PTR -24[rax]
	cmp	QWORD PTR 16[r13+rax], 0
	je	.L366
	lea	rsi, -2658[rbp]
	mov	edx, 1
	mov	rdi, r13
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	r13, rax
.L367:
	vmovsd	xmm0, QWORD PTR -2720[rbp]
	mov	rdi, r13
	call	_ZNSo9_M_insertIdEERSoT_@PLT
	mov	r13, rax
	mov	rax, QWORD PTR [rax]
	mov	BYTE PTR -2657[rbp], 44
	mov	rax, QWORD PTR -24[rax]
	cmp	QWORD PTR 16[r13+rax], 0
	je	.L368
	lea	rsi, -2657[rbp]
	mov	edx, 1
	mov	rdi, r13
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	r13, rax
.L369:
	mov	rsi, rbx
	mov	rdi, r13
	call	_ZNSo9_M_insertImEERSoT_@PLT
	mov	rbx, rax
	mov	rax, QWORD PTR [rax]
	mov	rax, QWORD PTR -24[rax]
	mov	r13, QWORD PTR 240[rbx+rax]
	test	r13, r13
	je	.L504
	cmp	BYTE PTR 56[r13], 0
	je	.L372
	movsx	esi, BYTE PTR 67[r13]
.L373:
	mov	rdi, rbx
	call	_ZNSo3putEc@PLT
	mov	rdi, rax
	call	_ZNSo5flushEv@PLT
	add	QWORD PTR -2680[rbp], 1
	mov	rax, QWORD PTR -2680[rbp]
	cmp	QWORD PTR -2728[rbp], rax
	jne	.L374
.L375:
	cmp	QWORD PTR -2784[rbp], 0
	je	.L304
	mov	rsi, QWORD PTR -2608[rbp]
	mov	rdi, QWORD PTR -2784[rbp]
	sub	rsi, rdi
	call	_ZdlPvm@PLT
.L304:
	mov	rdi, QWORD PTR -2776[rbp]
	test	rdi, rdi
	je	.L376
	mov	rsi, QWORD PTR -2640[rbp]
	sub	rsi, rdi
	call	_ZdlPvm@PLT
.L376:
	test	r14, r14
	je	.L377
	mov	rsi, QWORD PTR -2792[rbp]
	mov	rdi, r14
	sub	rsi, r14
	call	_ZdlPvm@PLT
.L377:
	mov	rdi, QWORD PTR -2744[rbp]
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	xor	eax, eax
	jmp	.L247
.L396:
	xor	ecx, ecx
	xor	esi, esi
	xor	r14d, r14d
	mov	QWORD PTR -2792[rbp], rcx
	mov	QWORD PTR -2768[rbp], rsi
.L261:
	lea	rax, .LC35[rip]
	mov	rdi, QWORD PTR -2744[rbp]
	mov	rsi, rax
	mov	QWORD PTR -2688[rbp], rax
	call	_ZSteqIcSt11char_traitsIcESaIcEEbRKNSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_
	test	al, al
	je	.L258
	mov	rsi, QWORD PTR -2712[rbp]
	lea	rdi, -2656[rbp]
	call	_ZNSt6vectorImSaImEE6resizeEm
.LEHE13:
	mov	r8, QWORD PTR -2648[rbp]
	mov	rdi, QWORD PTR -2656[rbp]
	cmp	rdi, r8
	je	.L277
	lea	rdx, -8[r8]
	mov	rax, rdi
	sub	rdx, rdi
	mov	rcx, rdx
	shr	rcx, 3
	add	rcx, 1
	cmp	rdx, 48
	jbe	.L399
	mov	rdx, rcx
	mov	esi, 8
	vmovdqa	ymm2, YMMWORD PTR .LC22[rip]
	shr	rdx, 3
	vmovd	xmm3, esi
	sal	rdx, 6
	vpbroadcastd	ymm3, xmm3
	add	rdx, rdi
.L275:
	vmovdqa	ymm0, ymm2
	add	rax, 64
	vpaddd	ymm2, ymm2, ymm3
	vpmovsxdq	ymm1, xmm0
	vextracti128	xmm0, ymm0, 0x1
	vpmovsxdq	ymm0, xmm0
	vmovdqu	YMMWORD PTR -64[rax], ymm1
	vmovdqu	YMMWORD PTR -32[rax], ymm0
	cmp	rdx, rax
	jne	.L275
	mov	rax, rcx
	and	rax, -8
	and	cl, 7
	mov	edx, eax
	lea	rax, [rdi+rax*8]
	je	.L505
	vzeroupper
.L274:
	lea	rsi, 8[rax]
	movsx	rcx, edx
	cmp	r8, rsi
	mov	QWORD PTR [rax], rcx
	lea	ecx, 1[rdx]
	je	.L277
	lea	rsi, 16[rax]
	movsx	rcx, ecx
	cmp	r8, rsi
	mov	QWORD PTR 8[rax], rcx
	lea	ecx, 2[rdx]
	je	.L277
	lea	rsi, 24[rax]
	movsx	rcx, ecx
	cmp	r8, rsi
	mov	QWORD PTR 16[rax], rcx
	lea	ecx, 3[rdx]
	je	.L277
	lea	rsi, 32[rax]
	movsx	rcx, ecx
	cmp	r8, rsi
	mov	QWORD PTR 24[rax], rcx
	lea	ecx, 4[rdx]
	je	.L277
	lea	rsi, 40[rax]
	movsx	rcx, ecx
	cmp	r8, rsi
	mov	QWORD PTR 32[rax], rcx
	lea	ecx, 5[rdx]
	je	.L277
	movsx	rcx, ecx
	add	edx, 6
	mov	QWORD PTR 40[rax], rcx
	lea	rcx, 48[rax]
	cmp	r8, rcx
	je	.L277
	movsx	rdx, edx
	mov	QWORD PTR 48[rax], rdx
.L277:
	mov	QWORD PTR -2560[rbp], r13
	mov	ecx, 1
	mov	rdx, r13
	lea	rbx, -2560[rbp]
	movabs	rsi, 6364136223846793005
	.p2align 4,,10
	.p2align 3
.L273:
	mov	rax, rdx
	shr	rax, 62
	xor	rax, rdx
	imul	rax, rsi
	lea	rdx, [rax+rcx]
	mov	QWORD PTR [rbx+rcx*8], rdx
	add	rcx, 1
	cmp	rcx, 312
	jne	.L273
	mov	rdx, rbx
	mov	rsi, r8
	mov	QWORD PTR -64[rbp], 312
	call	_ZSt7shuffleIN9__gnu_cxx17__normal_iteratorIPmSt6vectorImSaImEEEERSt23mersenne_twister_engineImLm64ELm312ELm156ELm31ELm13043109905998158313ELm29ELm6148914691236517205ELm17ELm8202884508482404352ELm37ELm18444473444759240704ELm43ELm6364136223846793005EEEvT_SA_OT0_
	jmp	.L258
.L492:
	lea	r12, _ZSt4cerr[rip]
	mov	edx, 7
	lea	rsi, .LC23[rip]
	mov	rdi, r12
.LEHB14:
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	rsi, QWORD PTR [rbx]
	mov	rdi, r12
	call	_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc@PLT
	mov	edx, 49
	lea	rsi, .LC24[rip]
	mov	rdi, rax
	mov	rbx, rax
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	rdi, rbx
	call	_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_@PLT
	mov	edx, 38
	lea	rsi, .LC25[rip]
	mov	rdi, rax
	mov	rbx, rax
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	rdi, rbx
	call	_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_@PLT
	mov	edx, 43
	lea	rsi, .LC26[rip]
	mov	rdi, rax
	mov	rbx, rax
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	rdi, rbx
	call	_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_@PLT
	mov	edx, 64
	lea	rsi, .LC27[rip]
	mov	rdi, rax
	mov	rbx, rax
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	rdi, rbx
	call	_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_@PLT
	mov	edx, 26
	lea	rsi, .LC28[rip]
	mov	rdi, rax
	mov	rbx, rax
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	rdi, rbx
	call	_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_@PLT
	mov	edx, 35
	lea	rsi, .LC29[rip]
	mov	rdi, rax
	mov	rbx, rax
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	rdi, rbx
	call	_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_@PLT
	mov	edx, 48
	lea	rsi, .LC30[rip]
	mov	rdi, rax
	mov	rbx, rax
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	rdi, rbx
	call	_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_@PLT
.LEHE14:
	mov	eax, 2
.L247:
	mov	rdx, QWORD PTR -56[rbp]
	sub	rdx, QWORD PTR fs:40
	jne	.L506
	add	rsp, 2784
	pop	rbx
	pop	r10
	.cfi_remember_state
	.cfi_def_cfa 10, 0
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	pop	rbp
	lea	rsp, -8[r10]
	.cfi_def_cfa 7, 8
	ret
.L286:
	.cfi_restore_state
	mov	rsi, QWORD PTR -2688[rbp]
	mov	edx, 6
	mov	rdi, rbx
	call	memcmp@PLT
	test	eax, eax
	je	.L507
	mov	edx, 6
	lea	rsi, .LC32[rip]
	mov	rdi, rbx
	call	memcmp@PLT
	test	eax, eax
	jne	.L296
	mov	rsi, QWORD PTR -2760[rbp]
	mov	rdi, QWORD PTR -2752[rbp]
	mov	rdx, r15
.LEHB15:
	call	_ZL13chains_kernelRKSt6vectorImSaImEEmm
	mov	rcx, rax
	jmp	.L287
.L498:
	xor	eax, eax
	jmp	.L265
	.p2align 4,,10
	.p2align 3
.L366:
	mov	esi, 44
	mov	rdi, r13
	call	_ZNSo3putEc@PLT
	jmp	.L367
	.p2align 4,,10
	.p2align 3
.L364:
	mov	esi, 44
	mov	rdi, r13
	call	_ZNSo3putEc@PLT
	jmp	.L365
	.p2align 4,,10
	.p2align 3
.L362:
	mov	esi, 44
	mov	rdi, r13
	call	_ZNSo3putEc@PLT
	jmp	.L363
	.p2align 4,,10
	.p2align 3
.L360:
	mov	esi, 44
	mov	rdi, r13
	call	_ZNSo3putEc@PLT
	jmp	.L361
	.p2align 4,,10
	.p2align 3
.L368:
	mov	esi, 44
	mov	rdi, r13
	call	_ZNSo3putEc@PLT
	jmp	.L369
	.p2align 4,,10
	.p2align 3
.L358:
	mov	esi, 44
	mov	rdi, r13
	call	_ZNSo3putEc@PLT
	jmp	.L359
	.p2align 4,,10
	.p2align 3
.L353:
	mov	esi, 44
	mov	rdi, r13
	call	_ZNSo3putEc@PLT
	cmp	QWORD PTR -2584[rbp], 6
	mov	esi, 1
	jne	.L355
.L503:
	mov	rax, QWORD PTR -2592[rbp]
	cmp	DWORD PTR [rax], 1767991395
	je	.L508
.L356:
	mov	esi, 1
	jmp	.L355
	.p2align 4,,10
	.p2align 3
.L351:
	mov	esi, 44
	mov	rdi, r13
	call	_ZNSo3putEc@PLT
	jmp	.L352
	.p2align 4,,10
	.p2align 3
.L349:
	mov	esi, 44
	mov	rdi, r13
	call	_ZNSo3putEc@PLT
	jmp	.L350
	.p2align 4,,10
	.p2align 3
.L347:
	mov	esi, 44
	mov	rdi, r13
	call	_ZNSo3putEc@PLT
	jmp	.L348
	.p2align 4,,10
	.p2align 3
.L372:
	mov	rdi, r13
	call	_ZNKSt5ctypeIcE13_M_widen_initEv@PLT
	mov	rax, QWORD PTR 0[r13]
	lea	rdx, _ZNKSt5ctypeIcE8do_widenEc[rip]
	mov	esi, 10
	mov	rax, QWORD PTR 48[rax]
	cmp	rax, rdx
	je	.L373
	mov	rdi, r13
	call	rax
	movsx	esi, al
	jmp	.L373
.L502:
	mov	rcx, QWORD PTR -2592[rbp]
	cmp	DWORD PTR [rcx], 1701999731
	je	.L509
.L329:
	mov	eax, 1
.L330:
	test	r15, r15
	js	.L331
	vxorpd	xmm3, xmm3, xmm3
	vcvtsi2sd	xmm0, xmm3, r15
	vmovsd	QWORD PTR -2688[rbp], xmm0
.L332:
	test	eax, eax
	je	.L510
	cmp	DWORD PTR [rcx], 1684955506
	je	.L511
.L338:
	test	r15, r15
	js	.L342
	vxorpd	xmm2, xmm2, xmm2
	vcvtsi2sd	xmm1, xmm2, r15
.L343:
	mov	rax, QWORD PTR -2760[rbp]
	test	rax, rax
	js	.L344
	vxorpd	xmm4, xmm4, xmm4
	vcvtsi2sd	xmm0, xmm4, rax
.L345:
	vmulsd	xmm4, xmm1, xmm0
	vmovsd	xmm3, QWORD PTR .LC42[rip]
	vmulsd	xmm7, xmm3, xmm4
	vmovsd	QWORD PTR -2688[rbp], xmm4
	vmovsd	xmm6, xmm4, xmm4
	vmovsd	QWORD PTR -2720[rbp], xmm7
	jmp	.L334
.L510:
	vxorpd	xmm3, xmm3, xmm3
	vmovsd	xmm7, QWORD PTR .LC42[rip]
	vcvtsi2sd	xmm0, xmm3, QWORD PTR -2712[rbp]
	vmulsd	xmm2, xmm0, QWORD PTR -2688[rbp]
	vmulsd	xmm4, xmm7, xmm2
	vmovsd	QWORD PTR -2688[rbp], xmm2
	vmovsd	xmm6, xmm2, xmm2
	vmovsd	QWORD PTR -2720[rbp], xmm4
	jmp	.L334
.L500:
	mov	rdi, QWORD PTR -2592[rbp]
	cmp	DWORD PTR [rdi], 1701999731
	je	.L512
.L306:
	cmp	DWORD PTR [rdi], 1684955506
	je	.L513
.L316:
	mov	edx, 6
	lea	rsi, .LC32[rip]
	call	memcmp@PLT
	test	eax, eax
	jne	.L321
	mov	rsi, QWORD PTR -2760[rbp]
	mov	rdi, QWORD PTR -2752[rbp]
	mov	rdx, r15
	call	_ZL13chains_kernelRKSt6vectorImSaImEEmm
	mov	rbx, rax
	jmp	.L310
.L501:
	jmp	.L321
.L331:
	mov	rdx, r15
	mov	rsi, r15
	vxorpd	xmm3, xmm3, xmm3
	shr	rdx
	and	esi, 1
	or	rdx, rsi
	vcvtsi2sd	xmm0, xmm3, rdx
	vaddsd	xmm7, xmm0, xmm0
	vmovsd	QWORD PTR -2688[rbp], xmm7
	jmp	.L332
.L512:
	cmp	WORD PTR 4[rdi], 28001
	jne	.L306
	mov	rdi, QWORD PTR -2816[rbp]
	xor	ebx, ebx
	xor	edx, edx
	and	edi, 3
	test	r15, r15
	je	.L310
	mov	r8, QWORD PTR -2800[rbp]
	mov	rsi, QWORD PTR -2768[rbp]
	mov	r9, QWORD PTR -2808[rbp]
	mov	rcx, QWORD PTR -2824[rbp]
	.p2align 4,,10
	.p2align 3
.L309:
	cmp	rsi, r14
	je	.L315
	cmp	r8, 24
	jbe	.L405
	mov	rax, r14
	vpxor	xmm0, xmm0, xmm0
	.p2align 4,,10
	.p2align 3
.L312:
	vpaddq	ymm0, ymm0, YMMWORD PTR [rax]
	add	rax, 32
	cmp	rax, r12
	jne	.L312
	vextracti128	xmm1, ymm0, 0x1
	vpaddq	xmm0, xmm1, xmm0
	vpsrldq	xmm1, xmm0, 8
	vpaddq	xmm0, xmm0, xmm1
	vmovq	rax, xmm0
	add	rbx, rax
	test	rdi, rdi
	mov	rax, r9
	je	.L315
.L311:
	lea	r11, 1[rax]
	add	rbx, QWORD PTR [r14+rax*8]
	lea	r10, 0[0+rax*8]
	cmp	r11, rcx
	jnb	.L315
	add	rax, 2
	add	rbx, QWORD PTR 8[r14+r10]
	cmp	rax, rcx
	jnb	.L315
	add	rbx, QWORD PTR 16[r14+r10]
.L315:
	add	rdx, 1
	cmp	r15, rdx
	jne	.L309
	vzeroupper
	jmp	.L310
.L405:
	xor	eax, eax
	jmp	.L311
.L508:
	cmp	WORD PTR 4[rax], 29550
	mov	rsi, QWORD PTR -2760[rbp]
	jne	.L356
	jmp	.L355
.L509:
	xor	eax, eax
	cmp	WORD PTR 4[rcx], 28001
	jne	.L329
	jmp	.L330
.L511:
	cmp	WORD PTR 4[rcx], 28015
	jne	.L338
	vmovsd	xmm7, QWORD PTR -2688[rbp]
	vmulsd	xmm7, xmm7, QWORD PTR .LC42[rip]
	vmovsd	xmm6, QWORD PTR -2688[rbp]
	vmovsd	QWORD PTR -2720[rbp], xmm7
	jmp	.L334
.L513:
	cmp	WORD PTR 4[rdi], 28015
	jne	.L316
	test	r15, r15
	je	.L406
	mov	rsi, QWORD PTR -2648[rbp]
	mov	rdi, QWORD PTR -2776[rbp]
	xor	ebx, ebx
	xor	ecx, ecx
	sub	rsi, rdi
	sar	rsi, 3
	.p2align 4,,10
	.p2align 3
.L322:
	mov	rax, rcx
	xor	edx, edx
	add	rcx, 1
	div	rsi
	mov	rax, QWORD PTR [rdi+rdx*8]
	add	rbx, QWORD PTR [r14+rax*8]
	cmp	r15, rcx
	jne	.L322
	jmp	.L310
.L344:
	mov	rdi, QWORD PTR -2760[rbp]
	vxorpd	xmm7, xmm7, xmm7
	mov	rax, rdi
	and	edi, 1
	shr	rax
	or	rax, rdi
	vcvtsi2sd	xmm0, xmm7, rax
	vaddsd	xmm0, xmm0, xmm0
	jmp	.L345
.L342:
	mov	rax, r15
	mov	rdx, r15
	vxorpd	xmm4, xmm4, xmm4
	shr	rax
	and	edx, 1
	or	rax, rdx
	vcvtsi2sd	xmm1, xmm4, rax
	vaddsd	xmm1, xmm1, xmm1
	jmp	.L343
.L340:
	mov	rax, r15
	mov	rdx, r15
	vxorpd	xmm2, xmm2, xmm2
	shr	rax
	and	edx, 1
	or	rax, rdx
	vcvtsi2sd	xmm0, xmm2, rax
	vaddsd	xmm3, xmm0, xmm0
	vmovsd	QWORD PTR -2688[rbp], xmm3
	jmp	.L341
.L401:
	xor	edx, edx
	jmp	.L289
.L394:
	mov	r13d, 12345
	jmp	.L250
.L406:
	xor	ebx, ebx
	jmp	.L310
.L499:
	vzeroupper
	jmp	.L261
.L507:
	test	r15, r15
	je	.L403
	mov	rdi, QWORD PTR -2648[rbp]
	mov	r8, QWORD PTR -2776[rbp]
	xor	ecx, ecx
	xor	esi, esi
	sub	rdi, r8
	sar	rdi, 3
.L295:
	mov	rax, rsi
	xor	edx, edx
	add	rsi, 1
	div	rdi
	mov	rax, QWORD PTR [r8+rdx*8]
	add	rcx, QWORD PTR [r14+rax*8]
	cmp	r15, rsi
	jne	.L295
	jmp	.L287
.L399:
	xor	edx, edx
	jmp	.L274
.L496:
	jmp	.L296
.L403:
	xor	ecx, ecx
	jmp	.L287
.L505:
	vzeroupper
	jmp	.L277
.L504:
	mov	rax, QWORD PTR -56[rbp]
	sub	rax, QWORD PTR fs:40
	jne	.L514
	call	_ZSt16__throw_bad_castv@PLT
.LEHE15:
.L506:
	call	__stack_chk_fail@PLT
.L267:
	mov	QWORD PTR [r14], 1
	xor	ecx, ecx
	xor	edx, edx
	xor	eax, eax
	jmp	.L391
.L497:
	mov	rax, QWORD PTR -56[rbp]
	sub	rax, QWORD PTR fs:40
	jne	.L515
	lea	rdi, .LC1[rip]
.LEHB16:
	call	_ZSt20__throw_length_errorPKc@PLT
.LEHE16:
.L514:
	call	__stack_chk_fail@PLT
.L515:
	call	__stack_chk_fail@PLT
.L420:
	endbr64
	mov	rbx, rax
	mov	r13, rdx
	jmp	.L381
.L410:
	endbr64
	mov	rdi, rax
	mov	r12, rdx
	vzeroupper
	jmp	.L385
.L470:
	endbr64
	jmp	.L471
.L421:
	endbr64
	mov	rbx, rax
	mov	r13, rdx
	jmp	.L263
.L419:
	endbr64
.L473:
	mov	rbx, rax
	mov	r13, rdx
	vzeroupper
	jmp	.L264
	.section	.gcc_except_table
	.align 4
.LLSDA7104:
	.byte	0xff
	.byte	0x9b
	.uleb128 .LLSDATT7104-.LLSDATTD7104
.LLSDATTD7104:
	.byte	0x1
	.uleb128 .LLSDACSE7104-.LLSDACSB7104
.LLSDACSB7104:
	.uleb128 .LEHB8-.LFB7104
	.uleb128 .LEHE8-.LEHB8
	.uleb128 .L410-.LFB7104
	.uleb128 0x1
	.uleb128 .LEHB9-.LFB7104
	.uleb128 .LEHE9-.LEHB9
	.uleb128 .L470-.LFB7104
	.uleb128 0x3
	.uleb128 .LEHB10-.LFB7104
	.uleb128 .LEHE10-.LEHB10
	.uleb128 .L419-.LFB7104
	.uleb128 0x3
	.uleb128 .LEHB11-.LFB7104
	.uleb128 .LEHE11-.LEHB11
	.uleb128 .L470-.LFB7104
	.uleb128 0x3
	.uleb128 .LEHB12-.LFB7104
	.uleb128 .LEHE12-.LEHB12
	.uleb128 .L421-.LFB7104
	.uleb128 0x3
	.uleb128 .LEHB13-.LFB7104
	.uleb128 .LEHE13-.LEHB13
	.uleb128 .L419-.LFB7104
	.uleb128 0x3
	.uleb128 .LEHB14-.LFB7104
	.uleb128 .LEHE14-.LEHB14
	.uleb128 .L410-.LFB7104
	.uleb128 0x1
	.uleb128 .LEHB15-.LFB7104
	.uleb128 .LEHE15-.LEHB15
	.uleb128 .L419-.LFB7104
	.uleb128 0x3
	.uleb128 .LEHB16-.LFB7104
	.uleb128 .LEHE16-.LEHB16
	.uleb128 .L420-.LFB7104
	.uleb128 0x3
.LLSDACSE7104:
	.byte	0x1
	.byte	0
	.byte	0
	.byte	0x7d
	.align 4
	.long	DW.ref._ZTISt9exception-.
.LLSDATT7104:
	.section	.text.startup
	.cfi_endproc
	.section	.text.unlikely
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDAC7104
	.type	main.cold, @function
main.cold:
.LFSB7104:
.L321:
	.cfi_escape 0xf,0x3,0x76,0x58,0x6
	.cfi_escape 0x10,0x3,0x2,0x76,0x50
	.cfi_escape 0x10,0x6,0x2,0x76,0
	.cfi_escape 0x10,0xc,0x2,0x76,0x60
	.cfi_escape 0x10,0xd,0x2,0x76,0x68
	.cfi_escape 0x10,0xe,0x2,0x76,0x70
	.cfi_escape 0x10,0xf,0x2,0x76,0x78
	mov	edi, 16
	lea	rbx, -2560[rbp]
	call	__cxa_allocate_exception@PLT
	mov	rcx, QWORD PTR -2584[rbp]
	mov	rdx, QWORD PTR -2592[rbp]
	mov	rdi, rbx
	lea	rsi, .LC39[rip]
	mov	r15, rax
.LEHB17:
	call	_ZStplIcSt11char_traitsIcESaIcEENSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_RKS8_.isra.0
.LEHE17:
	mov	rsi, rbx
	mov	rdi, r15
.LEHB18:
	call	_ZNSt13runtime_errorC1ERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE@PLT
.LEHE18:
	mov	rdi, rbx
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	mov	rax, QWORD PTR -56[rbp]
	sub	rax, QWORD PTR fs:40
	jne	.L516
	mov	rdx, QWORD PTR _ZNSt13runtime_errorD1Ev@GOTPCREL[rip]
	lea	rsi, _ZTISt13runtime_error[rip]
	mov	rdi, r15
.LEHB19:
	call	__cxa_throw@PLT
.LEHE19:
.L296:
	mov	edi, 16
	lea	rbx, -2560[rbp]
	call	__cxa_allocate_exception@PLT
	mov	rcx, QWORD PTR -2584[rbp]
	mov	rdx, QWORD PTR -2592[rbp]
	mov	rdi, rbx
	lea	rsi, .LC39[rip]
	mov	r15, rax
.LEHB20:
	call	_ZStplIcSt11char_traitsIcESaIcEENSt7__cxx1112basic_stringIT_T0_T1_EEPKS5_RKS8_.isra.0
.LEHE20:
	mov	rsi, rbx
	mov	rdi, r15
.LEHB21:
	call	_ZNSt13runtime_errorC1ERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE@PLT
.LEHE21:
	mov	rdi, rbx
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	mov	rax, QWORD PTR -56[rbp]
	sub	rax, QWORD PTR fs:40
	jne	.L517
	mov	rdx, QWORD PTR _ZNSt13runtime_errorD1Ev@GOTPCREL[rip]
	lea	rsi, _ZTISt13runtime_error[rip]
	mov	rdi, r15
.LEHB22:
	call	__cxa_throw@PLT
.LEHE22:
.L411:
	endbr64
.L471:
	mov	rbx, rax
	mov	r12, rdx
	vzeroupper
.L379:
	mov	rdi, QWORD PTR -2744[rbp]
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	mov	rdi, rbx
.L385:
	sub	r12, 1
	jne	.L518
	call	__cxa_begin_catch@PLT
	lea	r12, _ZSt4cerr[rip]
	mov	edx, 7
	lea	rsi, .LC44[rip]
	mov	rdi, r12
	mov	rbx, rax
.LEHB23:
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	mov	rax, QWORD PTR [rbx]
	mov	rdi, rbx
	call	[QWORD PTR 16[rax]]
	mov	rdi, r12
	mov	rsi, rax
	call	_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc@PLT
	mov	rdi, rax
	call	_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_@PLT
.LEHE23:
	call	__cxa_end_catch@PLT
	mov	eax, 1
	jmp	.L247
.L517:
	call	__stack_chk_fail@PLT
.L416:
	endbr64
	mov	r12, rax
	mov	rdi, rbx
	mov	r13, rdx
	vzeroupper
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	mov	rbx, r12
	jmp	.L301
.L415:
	endbr64
	mov	rbx, rax
	mov	r13, rdx
	vzeroupper
.L301:
	mov	rdi, r15
	call	__cxa_free_exception@PLT
.L264:
	mov	rdi, QWORD PTR -2624[rbp]
	mov	rsi, QWORD PTR -2608[rbp]
	sub	rsi, rdi
	test	rdi, rdi
	je	.L382
	call	_ZdlPvm@PLT
.L382:
	mov	rdi, QWORD PTR -2656[rbp]
	mov	rsi, QWORD PTR -2640[rbp]
	sub	rsi, rdi
	test	rdi, rdi
	je	.L383
	call	_ZdlPvm@PLT
.L383:
	mov	rsi, QWORD PTR -2792[rbp]
	sub	rsi, r14
	test	r14, r14
	je	.L384
	mov	rdi, r14
	call	_ZdlPvm@PLT
.L384:
	mov	r12, r13
	jmp	.L379
.L381:
	xor	eax, eax
	xor	r14d, r14d
	mov	QWORD PTR -2792[rbp], rax
	vzeroupper
	jmp	.L264
.L472:
	endbr64
	jmp	.L473
.L263:
	xor	edi, edi
	xor	r14d, r14d
	mov	QWORD PTR -2792[rbp], rdi
	vzeroupper
	jmp	.L264
.L254:
	mov	edi, 16
	call	__cxa_allocate_exception@PLT
	lea	rsi, .LC34[rip]
	mov	rdi, rax
	mov	r13, rax
.LEHB24:
	call	_ZNSt13runtime_errorC1EPKc@PLT
.LEHE24:
	mov	rax, QWORD PTR -56[rbp]
	sub	rax, QWORD PTR fs:40
	jne	.L519
	mov	rdx, QWORD PTR _ZNSt13runtime_errorD1Ev@GOTPCREL[rip]
	lea	rsi, _ZTISt13runtime_error[rip]
	mov	rdi, r13
.LEHB25:
	call	__cxa_throw@PLT
.LEHE25:
.L519:
	call	__stack_chk_fail@PLT
.L413:
	endbr64
.L491:
	mov	rdi, r13
	mov	rbx, rax
	mov	r12, rdx
	vzeroupper
	call	__cxa_free_exception@PLT
	jmp	.L379
.L474:
	mov	edi, 16
	call	__cxa_allocate_exception@PLT
	lea	rsi, .LC31[rip]
	mov	rdi, rax
	mov	r13, rax
.LEHB26:
	call	_ZNSt13runtime_errorC1EPKc@PLT
.LEHE26:
	mov	rax, QWORD PTR -56[rbp]
	sub	rax, QWORD PTR fs:40
	jne	.L520
	mov	rdx, QWORD PTR _ZNSt13runtime_errorD1Ev@GOTPCREL[rip]
	lea	rsi, _ZTISt13runtime_error[rip]
	mov	rdi, r13
.LEHB27:
	call	__cxa_throw@PLT
.LEHE27:
.L520:
	call	__stack_chk_fail@PLT
.L518:
	mov	rax, QWORD PTR -56[rbp]
	sub	rax, QWORD PTR fs:40
	jne	.L521
.LEHB28:
	call	_Unwind_Resume@PLT
.L521:
	call	__stack_chk_fail@PLT
.L516:
	call	__stack_chk_fail@PLT
.L418:
	endbr64
	mov	r12, rax
	mov	rdi, rbx
	mov	r13, rdx
	vzeroupper
	call	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_disposeEv
	mov	rbx, r12
	jmp	.L328
.L417:
	endbr64
	mov	rbx, rax
	mov	r13, rdx
	vzeroupper
.L328:
	mov	rdi, r15
	call	__cxa_free_exception@PLT
	jmp	.L264
.L412:
	endbr64
	jmp	.L491
.L414:
	endbr64
	mov	rbx, rax
	vzeroupper
	call	__cxa_end_catch@PLT
	mov	rax, QWORD PTR -56[rbp]
	sub	rax, QWORD PTR fs:40
	jne	.L522
	mov	rdi, rbx
	call	_Unwind_Resume@PLT
.LEHE28:
.L522:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE7104:
	.section	.gcc_except_table
	.align 4
.LLSDAC7104:
	.byte	0xff
	.byte	0x9b
	.uleb128 .LLSDATTC7104-.LLSDATTDC7104
.LLSDATTDC7104:
	.byte	0x1
	.uleb128 .LLSDACSEC7104-.LLSDACSBC7104
.LLSDACSBC7104:
	.uleb128 .LEHB17-.LCOLDB46
	.uleb128 .LEHE17-.LEHB17
	.uleb128 .L417-.LCOLDB46
	.uleb128 0x3
	.uleb128 .LEHB18-.LCOLDB46
	.uleb128 .LEHE18-.LEHB18
	.uleb128 .L418-.LCOLDB46
	.uleb128 0x3
	.uleb128 .LEHB19-.LCOLDB46
	.uleb128 .LEHE19-.LEHB19
	.uleb128 .L472-.LCOLDB46
	.uleb128 0x3
	.uleb128 .LEHB20-.LCOLDB46
	.uleb128 .LEHE20-.LEHB20
	.uleb128 .L415-.LCOLDB46
	.uleb128 0x3
	.uleb128 .LEHB21-.LCOLDB46
	.uleb128 .LEHE21-.LEHB21
	.uleb128 .L416-.LCOLDB46
	.uleb128 0x3
	.uleb128 .LEHB22-.LCOLDB46
	.uleb128 .LEHE22-.LEHB22
	.uleb128 .L472-.LCOLDB46
	.uleb128 0x3
	.uleb128 .LEHB23-.LCOLDB46
	.uleb128 .LEHE23-.LEHB23
	.uleb128 .L414-.LCOLDB46
	.uleb128 0
	.uleb128 .LEHB24-.LCOLDB46
	.uleb128 .LEHE24-.LEHB24
	.uleb128 .L413-.LCOLDB46
	.uleb128 0x3
	.uleb128 .LEHB25-.LCOLDB46
	.uleb128 .LEHE25-.LEHB25
	.uleb128 .L411-.LCOLDB46
	.uleb128 0x3
	.uleb128 .LEHB26-.LCOLDB46
	.uleb128 .LEHE26-.LEHB26
	.uleb128 .L412-.LCOLDB46
	.uleb128 0x3
	.uleb128 .LEHB27-.LCOLDB46
	.uleb128 .LEHE27-.LEHB27
	.uleb128 .L411-.LCOLDB46
	.uleb128 0x3
	.uleb128 .LEHB28-.LCOLDB46
	.uleb128 .LEHE28-.LEHB28
	.uleb128 0
	.uleb128 0
.LLSDACSEC7104:
	.byte	0x1
	.byte	0
	.byte	0
	.byte	0x7d
	.align 4
	.long	DW.ref._ZTISt9exception-.
.LLSDATTC7104:
	.section	.text.unlikely
	.section	.text.startup
	.size	main, .-main
	.section	.text.unlikely
	.size	main.cold, .-main.cold
.LCOLDE46:
	.section	.text.startup
.LHOTE46:
	.local	_ZL11result_sink
	.comm	_ZL11result_sink,8,8
	.section	.rodata.cst32,"aM",@progbits,32
	.align 32
.LC0:
	.quad	0
	.quad	1
	.quad	2
	.quad	3
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.LC3:
	.quad	4
	.align 8
.LC19:
	.quad	-2147483648
	.align 8
.LC20:
	.quad	2147483647
	.set	.LC21,.LC0+8
	.section	.rodata.cst32
	.align 32
.LC22:
	.long	0
	.long	1
	.long	2
	.long	3
	.long	4
	.long	5
	.long	6
	.long	7
	.section	.rodata.cst8
	.align 8
.LC41:
	.long	0
	.long	1104006501
	.align 8
.LC42:
	.long	0
	.long	1075838976
	.align 8
.LC43:
	.long	0
	.long	1072693248
	.hidden	DW.ref._ZTISt9exception
	.weak	DW.ref._ZTISt9exception
	.section	.data.rel.local.DW.ref._ZTISt9exception,"awG",@progbits,DW.ref._ZTISt9exception,comdat
	.align 8
	.type	DW.ref._ZTISt9exception, @object
	.size	DW.ref._ZTISt9exception, 8
DW.ref._ZTISt9exception:
	.quad	_ZTISt9exception
	.hidden	DW.ref.__gxx_personality_v0
	.weak	DW.ref.__gxx_personality_v0
	.section	.data.rel.local.DW.ref.__gxx_personality_v0,"awG",@progbits,DW.ref.__gxx_personality_v0,comdat
	.align 8
	.type	DW.ref.__gxx_personality_v0, @object
	.size	DW.ref.__gxx_personality_v0, 8
DW.ref.__gxx_personality_v0:
	.quad	__gxx_personality_v0
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
