.data
array: .word  1, 2, 3, 4, 5, 15, 7, 8, 9, 10, 11, 12, 13, 14, 15  # "array" of words to sort

.text

la   $t0, array        # load address of array
lw $t1, 0($t0)
lw $t1, 4($t0)
lw $t1, 8($t0)
lw $t1, 12($t0)
lw $t1, 16($t0)

addi $t2, $0, 6
sw $t2, 0($t0)
lw $t1, 0($t0)
addi $t2, $0, 7
sw $t2, 4($t0)
lw $t2, 4($t0)

halt
