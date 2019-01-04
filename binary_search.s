// Lab-9: Implementing the binary search function:
// Here we are assuming that numbers, key, startIndex and endIndex 
// are stored in R0-R3. The final parameter should be at the top of 
// stack-the sp is in sp.

.globl binary_search

binary_search:  
  SUB sp, sp, #48     // Make room on stack
  STR r2, [sp, #4]
  STR r3, [sp, #8]
  STR lr, [sp, #12]
  STR r4, [sp, #16]
  STR r5, [sp, #20]
  STR r6, [sp, #24]
  STR r7, [sp, #28]
  STR r8, [sp, #32]
  STR r9, [sp, #36] 
  STR r0, [sp, #40]   // Spill regs, preseve copy of program state

  SUB r8, r3, r2      // r8 = endIndex - startIndex
  MOV r7, r8, LSR #1  // r7 = (endIndex - startIndex)/2
  ADD r6, r2, r7      // r6 = startIndex + r7 , r6 = middleIndex
  //LSL r6, r6, #2      // Multiply the middeIndex by 4 for byte addressing

  LDR r9, [sp, #44]	  // r9 = NumCalls
  ADD r9, r9, #1	  // NumCalls++
  STR r9, [sp, #44]   // Restore Numcalls

  CMP r2, r3          // startIndex > endIndex
  BGT L1              

  LDR r8, [r0, r6, LSL #2]    // r8 = numbers[middleIndex]
  CMP r8, r1          
  BEQ L2              // numbers[middleIndex] == key

  LDR r8, [r0, r6, LSL #2]
  CMP r8, r1          
  BGT L3              // numbers[middleIndex] > key 

	LDR r8, [r0, r6, LSL #2]
  CMP r8, r1
  BLT L4              // numbers[middleIndex] < key

Exit:
  LDR r7, [sp, #44]   // r7 = NumCalls
  MOV r8, #0
  SUB r8, r8, r7      // r8 = -NumCalls
  LDR r9, [sp, #40]	  // r9 = base address of numbers[]
  STR r8, [r9, r6, LSL #2]    // numbers[middleIndex] = -NumCalls

  LDR lr, [sp, #12]
  LDR r4, [sp, #16]    
  LDR r5, [sp, #20]
  LDR r6, [sp, #24]
  LDR r7, [sp, #28]
  LDR r8, [sp, #32]
  LDR r9, [sp, #36]	  // Restore r4-r9
 // LDR r0, [sp]		  // load the return value
  ADD sp, sp, #48     // Pop off the stack
  LDR r0, [sp, #-48]   // load the return value
  //STR r0, [sp]

  MOV pc, lr          // Return to caller


L1:
 // MOV r0, #-1          // return -1
 // LDR lr, [sp, #12]    // restore link register
 // LDR r4, [sp, #16]    
 // LDR r5, [sp, #20]
 // LDR r6, [sp, #24]
 // LDR r7, [sp, #28]
 // LDR r8, [sp, #32]
 // LDR r9, [sp, #36]	  // Restore r4-r9
 // ADD sp, sp, #48     // Pop off the stack

  // MOV pc, lr          // return to caller

  MOV r0, #-1          // keyIndex is equal to middleIndex
  STR r0, [sp]
  B Exit

L2:
  MOV r0, r6          // keyIndex is equal to middleIndex
  //LSR r0, r0, #2
  STR r0, [sp]
  B Exit

L3:
  SUB r3, r6, #1	  // middleIndex--, 4 for byte addressing
  //LSR r3, r3, #2
  //SUB r3, r6, #4	  // Inputs to binary_search are not byte addressed
  LDR r9, [sp, #44]   // r9 = NumCalls
  STR r9, [sp, #-4]   // Set up Numcalls at top off stack for recurisive call
  BL  binary_search

  //LDR r9, [sp, #-4]
  //STR r9, [sp, #44]	  // Update new NumCalls val
  STR r0, [sp]		  // Save the return value
  LDR r0, [sp, #40]
  LDR r2, [sp, #4]
  LDR r3, [sp, #8]	  // Restore variables for local routine, no need to worry about r1, it will never be modified
  B Exit			  

L4:
  ADD r2, r6, #1	  // middleIndex++, 4 for byte addressing
  //LSR r2, r2, #2	  // Inputs to binary_search are not byte addressed
  LDR r9, [sp, #44]   // r9 = NumCalls
  STR r9, [sp, #-4]   // Set up Numcalls at top off stack for recurisive call
  BL  binary_search

  STR r0, [sp]
  LDR r0, [sp, #40]
  LDR r2, [sp, #4]
  LDR r3, [sp, #8]	  // Restore variables for local routine, no need to worry about r1, it will never be modified
  B Exit	
