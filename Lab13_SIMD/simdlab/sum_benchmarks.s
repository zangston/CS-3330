	.file	"sum_benchmarks.c"
	.text
	.globl	sum_C
	.type	sum_C, @function
sum_C:
.LFB4741:
	.cfi_startproc
	testq	%rdi, %rdi
	jle	.L4
	movl	$0, %edx
	movl	$0, %eax
.L3:
	movslq	%edx, %rcx
	addw	(%rsi,%rcx,2), %ax
	addl	$1, %edx
	movslq	%edx, %rcx
	cmpq	%rdi, %rcx
	jl	.L3
	ret
.L4:
	movl	$0, %eax
	ret
	.cfi_endproc
.LFE4741:
	.size	sum_C, .-sum_C
	.globl	sum_AVX
	.type	sum_AVX, @function
sum_AVX:
.LFB4742:
	.cfi_startproc
	testq	%rdi, %rdi
	jle	.L9
	movl	$0, %eax
	vpxor	%xmm0, %xmm0, %xmm0
.L8:
	movslq	%eax, %rdx
	vpaddw	(%rsi,%rdx,2), %ymm0, %ymm0
	addl	$16, %eax
	movslq	%eax, %rdx
	cmpq	%rdi, %rdx
	jl	.L8
.L7:
	vmovdqa	%xmm0, %xmm1
	vpextrw	$2, %xmm0, %eax
	vpextrw	$3, %xmm0, %edx
	addl	%edx, %eax
	vpextrw	$4, %xmm0, %edx
	addl	%edx, %eax
	vpextrw	$5, %xmm0, %edx
	addl	%edx, %eax
	vpextrw	$6, %xmm0, %edx
	addl	%edx, %eax
	vpextrw	$7, %xmm0, %edx
	addl	%edx, %eax
	vextracti128	$0x1, %ymm0, %xmm0
	vpextrw	$0, %xmm0, %edx
	addl	%edx, %eax
	vpextrw	$1, %xmm0, %edx
	addl	%edx, %eax
	vpextrw	$2, %xmm0, %edx
	addl	%edx, %eax
	vpextrw	$3, %xmm0, %edx
	addl	%edx, %eax
	vpextrw	$4, %xmm0, %edx
	addl	%edx, %eax
	vpextrw	$5, %xmm0, %edx
	addl	%edx, %eax
	vpextrw	$6, %xmm0, %edx
	addl	%edx, %eax
	vpextrw	$7, %xmm0, %edx
	addl	%edx, %eax
	vpextrw	$0, %xmm1, %ecx
	vpextrw	$1, %xmm1, %edx
	addl	%ecx, %edx
	addl	%edx, %eax
	ret
.L9:
	vpxor	%xmm0, %xmm0, %xmm0
	jmp	.L7
	.cfi_endproc
.LFE4742:
	.size	sum_AVX, .-sum_AVX
	.globl	sum_with_sixteen_accumulators
	.type	sum_with_sixteen_accumulators, @function
sum_with_sixteen_accumulators:
.LFB4743:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	movq	%rdi, -8(%rsp)
	testq	%rdi, %rdi
	jle	.L14
	movl	$0, %edx
	movl	$0, %edi
	movl	$0, %r8d
	movl	$0, %r9d
	movl	$0, %r10d
	movl	$0, %r11d
	movl	$0, %ebx
	movl	$0, %ebp
	movl	$0, %r12d
	movl	$0, %r13d
	movl	$0, %r14d
	movl	$0, %r15d
	movw	$0, -12(%rsp)
	movw	$0, -14(%rsp)
	movw	$0, -16(%rsp)
	movw	$0, -18(%rsp)
	movw	$0, -20(%rsp)
	movw	%di, -10(%rsp)
.L13:
	movslq	%edx, %rcx
	leaq	(%rcx,%rcx), %rax
	movzwl	(%rsi,%rcx,2), %ecx
	addw	%cx, -20(%rsp)
	movzwl	2(%rsi,%rax), %edi
	addw	%di, -18(%rsp)
	movzwl	4(%rsi,%rax), %edi
	addw	%di, -16(%rsp)
	movzwl	6(%rsi,%rax), %edi
	addw	%di, -14(%rsp)
	movzwl	8(%rsi,%rax), %edi
	addw	%di, -12(%rsp)
	addw	10(%rsi,%rax), %r15w
	addw	12(%rsi,%rax), %r14w
	addw	14(%rsi,%rax), %r13w
	addw	16(%rsi,%rax), %r12w
	addw	18(%rsi,%rax), %bp
	addw	20(%rsi,%rax), %bx
	addw	22(%rsi,%rax), %r11w
	addw	24(%rsi,%rax), %r10w
	addw	26(%rsi,%rax), %r9w
	addw	28(%rsi,%rax), %r8w
	movzwl	30(%rsi,%rax), %eax
	addw	%ax, -10(%rsp)
	addl	$16, %edx
	movslq	%edx, %rax
	cmpq	-8(%rsp), %rax
	jl	.L13
	movzwl	-10(%rsp), %edi
.L12:
	movzwl	-16(%rsp), %eax
	addw	-14(%rsp), %ax
	addw	-12(%rsp), %ax
	addl	%r15d, %eax
	addl	%r14d, %eax
	addl	%r13d, %eax
	addl	%r12d, %eax
	addl	%ebp, %eax
	addl	%ebx, %eax
	addl	%r11d, %eax
	addl	%r10d, %eax
	addl	%r9d, %eax
	addl	%r8d, %eax
	addl	%eax, %edi
	movzwl	-20(%rsp), %eax
	addw	-18(%rsp), %ax
	addl	%edi, %eax
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
.L14:
	.cfi_restore_state
	movl	$0, %edi
	movl	$0, %r8d
	movl	$0, %r9d
	movl	$0, %r10d
	movl	$0, %r11d
	movl	$0, %ebx
	movl	$0, %ebp
	movl	$0, %r12d
	movl	$0, %r13d
	movl	$0, %r14d
	movl	$0, %r15d
	movw	$0, -12(%rsp)
	movw	$0, -14(%rsp)
	movw	$0, -16(%rsp)
	movw	$0, -18(%rsp)
	movw	$0, -20(%rsp)
	jmp	.L12
	.cfi_endproc
.LFE4743:
	.size	sum_with_sixteen_accumulators, .-sum_with_sixteen_accumulators
	.globl	sum_with_eight_accumulators
	.type	sum_with_eight_accumulators, @function
sum_with_eight_accumulators:
.LFB4744:
	.cfi_startproc
	pushq	%r13
	.cfi_def_cfa_offset 16
	.cfi_offset 13, -16
	pushq	%r12
	.cfi_def_cfa_offset 24
	.cfi_offset 12, -24
	pushq	%rbp
	.cfi_def_cfa_offset 32
	.cfi_offset 6, -32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	.cfi_offset 3, -40
	testq	%rdi, %rdi
	jle	.L20
	movl	$0, %ecx
	movl	$0, %r11d
	movl	$0, %ebx
	movl	$0, %ebp
	movl	$0, %r12d
	movl	$0, %r13d
	movl	$0, %edx
	movl	$0, %r10d
	movl	$0, %r9d
.L19:
	movslq	%ecx, %r8
	leaq	(%r8,%r8), %rax
	addw	(%rsi,%r8,2), %r9w
	addw	2(%rsi,%rax), %r10w
	addw	4(%rsi,%rax), %dx
	addw	6(%rsi,%rax), %r13w
	addw	8(%rsi,%rax), %r12w
	addw	10(%rsi,%rax), %bp
	addw	12(%rsi,%rax), %bx
	addw	14(%rsi,%rax), %r11w
	addl	$8, %ecx
	movslq	%ecx, %rax
	cmpq	%rdi, %rax
	jl	.L19
.L18:
	addl	%r13d, %edx
	leal	(%rdx,%r12), %eax
	addl	%ebp, %eax
	addl	%ebx, %eax
	addl	%r11d, %eax
	addl	%r10d, %r9d
	addl	%r9d, %eax
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 32
	popq	%rbp
	.cfi_def_cfa_offset 24
	popq	%r12
	.cfi_def_cfa_offset 16
	popq	%r13
	.cfi_def_cfa_offset 8
	ret
.L20:
	.cfi_restore_state
	movl	$0, %r11d
	movl	$0, %ebx
	movl	$0, %ebp
	movl	$0, %r12d
	movl	$0, %r13d
	movl	$0, %edx
	movl	$0, %r10d
	movl	$0, %r9d
	jmp	.L18
	.cfi_endproc
.LFE4744:
	.size	sum_with_eight_accumulators, .-sum_with_eight_accumulators
	.globl	functions
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"C (local)"
.LC1:
	.string	"C (clang6 -O)"
.LC2:
	.string	"sixteen accumulators (C)"
.LC3:
	.string	"eight accumulators (C)"
.LC4:
	.string	"vector instrinsics (C)"
	.data
	.align 32
	.type	functions, @object
	.size	functions, 96
functions:
	.quad	sum_C
	.quad	.LC0
	.quad	sum_clang6_O
	.quad	.LC1
	.quad	sum_with_sixteen_accumulators
	.quad	.LC2
	.quad	sum_with_eight_accumulators
	.quad	.LC3
	.quad	sum_AVX
	.quad	.LC4
	.quad	0
	.quad	0
	.ident	"GCC: (GNU) 7.1.0"
	.section	.note.GNU-stack,"",@progbits
