addi $s0, $zero, 0 # $s0 will store the number of successes (since the branch should not be taken)

addi $t0, $zero, 0
addi $t1, $zero, 0
addi $t2, $zero, 0

bgez $t0, label_0
addi $s0, $s0, 1

label_0:
bgez $t1, label_1
addi $s0, $s0, 1

label_1:
bgez $t2, label_2
addi $s0, $s0, 1

label_2:
halt
# $s0 should be 0 here if the test was successful
