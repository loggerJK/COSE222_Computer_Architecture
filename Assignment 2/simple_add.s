.text
.align 4

	ble x2, x3, exit
	j exit



.data
.align 20
exit:

stack:
	.space 1024
