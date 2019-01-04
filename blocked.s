/* NOTE: This code is based of code in the COD textbook, chapter 5.4 page 429 */
// Optimize Matrix multiplication

block_size:
	.word 3

N:
	.word 16

MA:
	.double 1.1
	.double 2.2
	.double 3.4

	.double 4.66
	.double 1.2
	.double 2.4
//-------------------
	.double 1.1
	.double 1.1
	.double 1.1

MB: 
	.double 5.3
	.double 7.2
	.double 2.4

	.double 6.66
	.double 5.3
	.double 9.0

	.double 1.1
	.double 1.1
	.double 1.1

M_C:
	.double 0
	.double 0
	.double 0

	.double 0
	.double 0
	.double 0

	.double 0
	.double 0
	.double 0

db1:
	.double 0

db2:
	.double 0

db3:
	.double 0
// This is the code for part 3:
// Blocked Matrix Multiplication to improve temproral 
// and spatial locality. This results in better performance 
// since we have optimized usage of the cache.
// Since, at any given time, we will be dealing with only a small 
// chunck of A and B we can also optimize our register use. 
// We can store most of the variables in regs which reduced the 
// number of LDR instructions. 
// Performance can be compared with the included spreadsheet

// PARAM:	A, B, C are NxN matricies
//			r0 == N 
//			r1 == block_size 
//
//			r2 == MA 
//			r3 == MB
// 			r4 == M_C 
//
//			r5 == i 
//			r6 == j 
// 			r7 == k 
//
//			d1 == cij 
//			d2 == A[i+k*n]
//			d3 == B[k+j*n]
//
//			r8 == si 
//			r9 == sj 
// 			r10 == sk 
//
// 			r11 == temp
//			r12 == temp1



.global dgemm
dgemm:
	
	push {r0-r12, lr}

	ldr r11, =N 
	ldr r0, [r11] // r0 now contains the value at N
	ldr r11, =block_size
	ldr r1, [r11] // r1 now contains the value block_size
	ldr r2, =MA 
	ldr r3, =MB 
	ldr r4, =M_C // load the base addresses for the matricies

	mov r9, #0 // sj = 0 

L1outer:
	
	mov r8, #0 // si = 0 

L1mid:

	mov r10, #0 // sk = 0

L1inner:

	bl blocked_mm // blocked_mm(n, si, sj, sk, A, B, C)

	add r10, r10, r1 // sk = sk + block_size 
	cmp r10, r0 
	blt L1inner // sk < n then repeat 

	add r8, r8, r1 // si = si + block_size 
	cmp r8, r0 
	blt L1mid // si < n then repeat 

	add r9, r9, r1 // sj = sj + block_size 
	cmp r9, r0 
	blt L1outer // sj < n then repeat 

EXIT2: 
	
	pop {r0-r12, lr}

	mov pc, lr // return control 

// PARAM:	A, B, C are NxN matricies
//			r0 == N 
//			r1 == block_size 
//
//			r2 == MA 
//			r3 == MB
// 			r4 == M_C 
//
//			r5 == i 
//			r6 == j 
// 			r7 == k 
//
//			d1 == cij 
//			d2 == A[i+k*n]
//			d3 == B[k+j*n]
//			d4 == A[i+k*n] * B[k+j*n]
//
//			r8 == si 
//			r9 == sj 
// 			r10 == sk 
//
// 			r11 == temp
//			r12 == temp1


.global blocked_mm
blocked_mm:

	push {lr}
	
	mov r5, r8 // i = si 

L2outer: 
	
	mov r6, r9 // j = sj

L2mid:

	mul r11, r6, r0 // j*n 
	add r11, r11, r5  // i + j*n 
	lsl r11, r11, #3 // 2-byte addressing 
	add r11, r11, r4 // base address C + byte address
	.word 0xed9b1b00 // fldd d1, [r11] ==> cij = C[i +j*n] 
	
	mov r7, r10 // k = sk 

L2inner: 

	mul r11, r7, r0 // k*n 
	add r11, r11, r5 // i + k*n 
	lsl r11, r11, #3 // Byte addressing 
	add r11, r11, r2 // base address + byte addressing
	.word 0xed9b2b00 // fldd d2, [r11] ==> d2 = A[i+k*n]
	
	mul r11, r6, r0 // j*n 
	add r11, r11, r7 // k + j*n 
	lsl r11, r11, #3 // byte addressing
	add r11, r11, r3 // base address + byte addressing
	.word 0xed9b3b00 // fldd d3, [r11] ==> d3 = B[k+j*n]

	.word 0xee224b03 // fmuld d4, d3, d2
	
	.word 0xee311b04 // faddd d1, d1, d4
	

	add r7, r7, #1 // k++ 
	add r11, r10, r1 // sk + block_size
	cmp r7, r11 
	blt L2inner // k < sk + block_size

	mul r11, r6, r0 // j*n 
	add r11, r11, r5  // i + j*n 
	lsl r11, r11, #3 // 2-byte addressing 
	add r11, r11, r4 // base address C + byte address
	.word 0xed8b1b00 //fstd d1, [r11] ==> C[i+j*n] = cij 
	

	add r6, r6, #1 // j++ 
	add r11, r9, r1 // sj + block_size 
	cmp r6, r11 
	blt L2mid // j < sj + block_size

	add r5, r5, #1 
	add r11, r8, r1 // si + block_size
	cmp r5, r11 
	blt L2outer // i < si + block_size 


	pop {lr}

	mov pc, lr 
