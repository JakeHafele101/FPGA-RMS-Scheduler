.data
x: .word 3
.text
.globl main

main:
	
la $t0, x
lw $t1, 0($t0) # loads t1 with 3

# Exit program
li $v0, 10
syscall
halt
