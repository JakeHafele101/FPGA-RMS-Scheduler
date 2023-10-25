.data
val1:	.word 5
val2:	.word 7

.text
	lw $t0, val1		# $t0 = 5
	lw $t1, val2		# $t1 = 10
	bne $t0, $t1, goTo	# if $t0 not equal to $t1
	addi $t2, $zero, 1	# Should be skipped
goTo:
	addi $t2, $zero, 2	# Should be executed
halt
