.data
array: .word  1, 5, 108, 3105, -4, 2, -68, 19  # "array" of words to sort
size:  .word  8                                # size of "array"

.text
la   $a0, array        # load address of array
lw   $a1, size         # load address of size variable

addi $t0, $0, 0   # step = 0
addi $t1, $a1, -1 # size - 1  

loop_array_cond:
slt $t2, $t0, $t1  #set $t2 to 1 if step < size - 1, otherwise 0
beq $t2, $0, loop_array_exit #branch if step >= size - 1

loop_array:
addi $t2, $0, 0   #i = 0
sub $t3, $t1, $t0 # (size - 1) - step

loop_compare_cond:
slt $t4, $t2, $t3  #set $t4 to 1 if i < size - step - 1, otherwise 0
beq $t4, $0, loop_compare_exit #branch if i >= size - step - 1

loop_compare:
sll $t4, $t2, 2  # i * 4, byte addressable

add $t5, $a0, $t4 # &array[i]

lw $t6, 0($t5) # array[i]
lw $t7, 4($t5) # array[i + 1]

slt $t8, $t7, $t6 # 1 if array[i+1] < array[i], 0 otherwise
beq $t8, $0, i_greater #do NOT swap if array[i + 1] greater

# swap array[i] and array[i+1], load back to memory
sw $t7, 0($t5) # array[i] = array[i+1]
sw $t6, 4($t5) # array[i+1] = array[i]

i_greater:
addi $t2, $t2, 1 # ++i
j loop_compare_cond

loop_compare_exit:
addi $t0, $t0, 1 # ++step
j loop_array_cond

loop_array_exit:

halt
