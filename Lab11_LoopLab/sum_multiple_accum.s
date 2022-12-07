// This is assembly is roughly equivalent to the following C code:
// unsigned short sum_C(long size, unsigned short * a) {
//    unsigned short sum1 = 0, sum2 = 0, sum3 = 0, sum4 = 0;
//    for (int i = 0; i < size; i += 4) {
//        sum1 += a[i];
//	  sum2 += a[i + 1];
//	  sum3 += a[i + 2];
//	  sum4 += a[i + 3];
//    }
//    return sum;
//}

// This implementation follows the Linux x86-64 calling convention:
//    %rdi contains the size
//    %rsi contains the pointer a
// and
//    %ax needs to contain the result when the function returns
// in addition, this code uses
//    %rcx to store i

// the '.global' directive indicates to the assembler to make this symbol 
// available to other files.
.global sum_multiple_accum
sum_multiple_accum:
	// set sum (%ax) to 0
	xor %eax, %eax
	// push, then zero accumulator in r12
	push %r12
	xor %r12, %r12
	// push, then zero accumulator in r13
	push %r13
	xor %r13, %r13
	// push, then zero accumulator in r14
	push %r14
	xor %r14, %r14
	// i think you know what's happening here
	push %r15
	xor %r15, %r15
	// return immediately; special case if size (%rdi) == 0
	test %rdi, %rdi
	je .L_done
	// store i = 0 in rcx
	movq $0, %rcx
// labels starting with '.L' are local to this file
.L_loop:
	// sum (%ax) += a[i]
	addq (%rsi,%rcx,2), %r12
	// sum (%ax) += a[i + 1]
	addq 2(%rsi,%rcx,2), %r13
	// sum (%ax) += a[i + 2]
	addq 4(%rsi,%rcx,2), %r14
	// sum (%ax) += a{i + 3]
	addq 6(%rsi,%rcx,2), %r15
	// i += 4
	addq $4, %rcx
	// i < end?
	cmpq %rdi, %rcx
	jl .L_loop
.L_done:
	// sum accumulators
	addq %r12, %rax
	addq %r13, %rax
	addq %r14, %rax
	addq %r15, %rax
	// pop registers
	pop %r15
	pop %r14
	pop %r13
	pop %r12
	
	retq
