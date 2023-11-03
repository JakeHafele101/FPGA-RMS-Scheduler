main:

addi $t1,$zero, 5
addi $t0,$zero, 1
loop:
sub $t1,$t1,$t0
bne $t1, $t0, loop

addi $t1,$zero, 5
addi $t0,$zero, 1
loop2:
sub $t1,$t1,$t0
sub $s5,$zero,$zero
beq $t1, $s5, done
j loop2
done:

addi $t1,$zero, 5
addi $t0,$zero, 1
loopbgez:
sub $t1,$t1,$t0
bgez $t1, loopbgez

addi $t1,$zero, 5
addi $t0,$zero, 1
loopbgtz:
sub $t1,$t1,$t0
bgtz $t1, loopbgtz

addi $t1,$zero, 5
addi $t0,$zero, 1
loopblez:
sub $t1,$t1,$t0
blez $t1, doneblez
j loopblez
doneblez:

addi $t1,$zero, 5
addi $t0,$zero, 1
loopbltz:
sub $t1,$t1,$t0
blez $t1, donebltz
j loopbltz
donebltz:

jal spin
addi $t1, $zero, 1
bgezal $t1 , spin
sub $t1,$t1,$t0
addi $t1, $zero, -1
bgezal $t1 , spin

bltzal $t1 , spin
addi $t1,$t1,30
bltzal $t1 , spin
addi $t1, $zero,0
bltzal $t1 , spin
bgezal $t1 , spin
addi $t1, $zero, 1
halt

spin:
jr $ra