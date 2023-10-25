.data
passmsg: .asciiz "Test Passed\n"
failmsg: .asciiz "Test Failed\n"
testcase1: .asciiz "Test 1\n"
testcase2: .asciiz "Test 2\n"
testcase3: .asciiz "Test 3\n"
.text
.globl main

main:

# Test case 1: input positive int

    li $v0, 4
    la $a0, testcase1
    syscall

    addi $t0, $zero, 100
    bgtz $t0, pass1            # 100 is greater than 0 so branch
    
    li $v0, 4
    la $a0, failmsg
    syscall

pass1:

    li $v0, 4
    la $a0, passmsg
    syscall

test2:

    li $v0, 4
    la $a0, testcase2
    syscall

    addi $t0, $zero, -100
    bgtz $t0, fail2          # -100 is not greater than 0 so do not branch

    li $v0, 4
    la $a0, passmsg
    syscall

    j test3

fail2:

    li $v0, 4
    la $a0, failmsg
    syscall

# Test case 3: input zero int
test3:

    li $v0, 4
    la $a0, testcase3
    syscall

    addi $t0, $zero, 0
    bgtz $t0, fail3          # 0 is not greater than 0 so do not branch

    li $v0, 4
    la $a0, passmsg
    syscall

    j exit

fail3:

    li $v0, 4
    la $a0, failmsg
    syscall

exit:
halt
# Exit program
