.data
array: .word  1, 5, 108, 3105, -4, 2, -68, 19  # "array" of words to sort
size:  .word  8                                # size of "array"

.text
la   $s0, array        # load address of array
lw   $s1, size         # load address of size variable

addi $t0 , $zero, 235
sw $t0, 4($s0)
lw $t1, 4($s0)
sw $t1, 4($s0)
lw $t2, 0($s0)
lw $t3, 8($s0)
lw $t4, 12($s0)
sw $t1, 12($s0)
lw $t4, 12($s0)
jal here
nop
halt

here:
sw $ra, 4($s0)
lw $ra, 4($s0)
addi $s0, $s0, 4
addi $ra,$ra,4
jr $ra
