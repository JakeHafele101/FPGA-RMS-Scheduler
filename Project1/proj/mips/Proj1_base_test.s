.text

# Arithmetic
addi $t0, $0, 1
addi $t1, $0, 0
addi $t2, $0, -1 

add $t0, $t0, $t0 #2
add $t1, $t1, $t1 #0
add $t2, $t2, $t2 #-2

addiu $t0, $t0, 1  #3
addiu $t1, $t1, 0  #0
addiu $t2, $t2, -1 #-3

addu $t0, $t0, $t0 #6
addu $t1, $t1, $t1 #0
addu $t2, $t2, $t2 #-6

sub $t0, $0, $t0 # -6
sub $t1, $0, $t1 # 0
sub $t2, $0, $t2 # 6

subu $t0, $0, $t0 # 6
subu $t1, $0, $t1 # 0
subu $t2, $0, $t2 # -6

# logic
lui $t0, 0xFFFF #$t0 upper 16 1's
ori $t0, $t0, 0xFFFF # $t0 lower 16 1's
addi $t1, $0, 0 #$t1 all 0's

and $t2, $t1, $t0 

andi $t2, $t0, 0

nor $t2, $t1, $t0 

xor $t2, $t1, $t0 

xori $t2, $t0, 0

or $t2, $t1, $t0 

ori $t2, $t0, 0 


# set less than

addi $t0, $0, 5
addi $t1, $0, -5

slt $t2, $t1, $t0
slt $t2, $t0, $t1

slti $t2, $t0, -5
slti $t2, $t0, 0
slti $t2, $t0, 5

slti $t2, $t1, -5
slti $t2, $t1, 0
slti $t2, $t1, 5

# shift

lui $t0, 0xFFFF #$t0 upper 16 1's
ori $t0, $0, 0xFFFF # $t0 lower 16 1's

sll $t1, $t0, 16
sll $t1, $t0, 31

srl $t1, $t0, 16
srl $t1, $t0, 31

sra $t1, $t0, 16
sra $t1, $t0, 31

addi $t1, $0, 0
lui $t1, 0xFFFF

halt
