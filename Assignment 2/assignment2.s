#
#  Author: Prof. Taeweon Suh
#          Computer Science & Engineering
#          Korea University
#  Date:   June 13, 2020
#  Description: Simple addition of 4 words (result = op1 + op2)
#

.globl __start

.text
.align 4

__start:

        la   t0, op1      # Load Address
	la   t1, op2
	la   t2, result
	mv	 s3, x0		# s3 is counter variable, s3 = 0
	li	s4, 4		# save branch value to Register

myloop:
	lw   s0, 0(t0)
	lw   s1, 0(t1)
	sub s5, s0, s1 	# t5 = s0 - s1
        sw   s5, 0(t2)
        
	# Memory Address Info Update
	addi t0, t0, 4
	addi t1, t1, 4
	addi t2, t2, 4

	# Counter Variable update
	addi s3, s3, 1		# s3= s3 + 1 
	bne s3, s4, myloop
     

.data
.align 4
op1:    .word  1, 2, 3, 4 	# 한 자릿수당 하나의 word(32bit = 4byte)씩 할당
op2:    .word  5, 6, 7, 8	
result: .word  0, 0, 0, 0 

