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

        la   t0, op1
	la   t1, op2
	la   t2, result
	sub t3, t1, t0 
	srai  t3, t3, 2   # how many words? shift right by 2

myloop:
	lw   s0, 0(t0)
	lw   s1, 0(t1)
	addi s2, s0, 0
	sw   s2, 0(t2)
	addi t3, t3, -1   # decrement by 1
	beq  t3, zero, myself
	addi t0, t0, 4
	addi t1, t1, 4
	addi t2, t2, 4
	j    myloop

myself:
        li   t0, 0x12345678   # just an example pseudo code
        nop	              # just an example pseudo code
        mv   t1, t0           # just an example pseudo code
        j myself
        

.data
.align 4
op1:    .word  1, 2, 3, 4 
op2:    .word  5, 6, 7, 8
result: .word  0, 0, 0, 0 

