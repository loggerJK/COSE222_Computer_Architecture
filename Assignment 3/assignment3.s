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

	bgt s0 s1 l1 	## if s0 < s1, then swap
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
	# add t0, t0, s3 # t0 = t0 + s3, Address Update
	# add t2, t2, s3	# t2 = t2 + s3, Address Update

	lw s0, 0(t0) # s0 <= [t0]
	sw s0, 0(t2) # [t2] <= s0

	# Address Update
	addi t0, t0, 4; # t0 = t0 + 4
	addi t2, t2, 4; # t2 = t2 + 4

	# Counter Variable Update
	addi s3, s3, 1 # s3 = s3 + 1

	j COPY_LOOP


EXIT:
	nop


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


