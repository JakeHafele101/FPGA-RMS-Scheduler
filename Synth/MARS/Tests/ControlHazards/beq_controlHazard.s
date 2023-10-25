addi $t1, $0, 1
addi $t0, $0, 2
addi $t0, $0, 3
addi $t0, $0, 4

beq  $0, $t1 branch #branch not taken, no change
addi $t0, $0, 5
addi $t0, $0, 6
addi $t0, $0, 7
addi $t0, $0, 8

beq  $0, $0 branch #branch taken, flush IF/ID buffer reg
addi $t0, $0, 9
addi $t0, $0, 10
addi $t0, $0, 11
addi $t0, $0, 12

branch: 
addi $t0, $0, 9
addi $t0, $0, 10
addi $t0, $0, 11
addi $t0, $0, 12

halt
