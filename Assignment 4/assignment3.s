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

    la   t0, Input_data      # Load Address of Input_data, t0: address of first word of Input_data
	addi t1 t0 4			# t1 : address of next word of [t0]
	la   t2, Output_data	# Load Address of Output_data, constant
	addi t3, t0, 124		# t3 : address of last word of Input_data, constant
	mv s3, zero				# s3 : Counter Vairable, Initialzed as Zero
	addi s4, zero, 31		# s4 : 31 (constant)



myloop:
	bge s3, s4, COPY # if s3 >= 31 then EXIT, Counter Variable Check

	lw s0, 0(t0)	# s0 <= [t0]
	lw s1, 0(t1)	# s1 <= [t1]

	bgt s0 s1 l1 	## if s0 <= s1, then swap
	sw s0, 0(t1)	# [t1] <= s0
	sw s1, 0(t0)	# [t0] <= s1

l1:
	addi t0 t0 4	# Address Update
	addi t1 t1 4	# Address Update

	ble t1, t3, myloop 		# if t1 <= t3 then myloop
	la   t0, Input_data		# Load Address of Input_data, t0: address of first word of Input_data
	addi t1 t0 4			# t1 : address of next word of [t0]
	addi s3, s3, 1			# Counter Variable Update : +1
	j myloop				# jump to myloop

COPY:
	# Initialize Address Variable
	la   t0, Input_data		# Load Address of Input_data, t0: address of first word of Input_data
	la   t2, Output_data	# Load Address of Output_data, constant
	mv s3, zero				# s3 : Counter Vairable, Initialzed as Zero

COPY_LOOP:
	bgt s3, s4, EXIT # if s3 > 31 then EXIT, Counter Variable Check

	lw s0, 0(t0) # s0 <= [t0]
	sw s0, 0(t2) # [t2] <= s0

	# Address Update
	addi t0, t0, 4 # t0 = t0 + 4
	addi t2, t2, 4 # t2 = t2 + 4

	# Counter Variable Update
	addi s3, s3, 1 # s3 = s3 + 1

	j COPY_LOOP # jump to COPY_LOOP


COMAPARE:
	la t2, Output_data # Load Address of Output_data, which is constant
	lui s0, 16		# s0 <= 16
	lw s1, 0(t2)	 # s1 <= [t2]
	mv s3, zero				# s3 : Counter Vairable, Initialzed as Zero
	addi s4, zero, 31		# s4 : 31 (constant)
	
COMPARE_LOOP:
	bgt s3, s4, EXIT # if s3 > 31 then EXIT, Counter Variable Check

	bne s0, s1, ERROR # if s0 != s1 then ERROR

	addi s0, s0, -1 # s0 = s0 + -1
	addi s1, s1, 4 # s1 = s1 + 4
	addi s3, s3, 1	# Couonter Variable Update

	j COMPARE_LOOP  # jump to COMPARE_LOOP
	
	

ERROR:
	#  display 2 on HEX1
	lw  x10, 0x79
	li x3, 0xFFFF2000
	addi x3, x3, 0x10   # x3 contains 0xFFFF_2010 
	sw  x10, 0(x3)


EIXT:
	# display 1 on HEX0 
	lui x10, 0x40
	li x3, 0xFFFF2000
	addi x3, x3, 0xC   	# x3 contains 0xFFFF_200C
	sw  x10, 0(x3)
	




.data
.align 4
Input_data: .word 2, 0, -7, -1, 3, 8, -4, 10
			.word -9, -16, 15, 13, 1, 4, -3, 14
			.word -8, -10, -15, 6, -13, -5, 9, 12
			.word -11, -14, -6, 11, 5, 7, -2, -12
Output_data: .word 0, 0, 0, 0, 0, 0, 0, 0
			.word 0, 0, 0, 0, 0, 0, 0, 0
			.word 0, 0, 0, 0, 0, 0, 0, 0
			.word 0, 0, 0, 0, 0, 0, 0, 0


