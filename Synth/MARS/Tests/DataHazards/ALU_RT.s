# Arithmetic
addi $t0, $0, 1
sll $t4,$t0, 5

add $t0, $t1, $t0 #2
add $t1, $t1, $t0 #0
add $t2, $t0, $t2 #-2

addu $t0, $t2, $t0 #6
addu $t1, $t0, $t1 #0
addu $t2, $t2, $t0 #-6

lui $t1, 0xFFFF

sub $t1, $t1, $t0 # -6
sub $t1, $t1, $t1 # 0
sub $t2, $t1, $t2 # 6

subu $t0, $t2, $t0 # 6
subu $t1, $t2, $t1 # 0
subu $t2, $t0, $t2 # -6

# logic
lui $t0, 0xFFFF #$t0 upper 16 1's

and $t2, $t1, $t0 

nor $t2, $t2, $t0 

xor $t2, $t2, $t0 

or $t2, $t2, $t0 


# shift
slt $t2, $t1, $t0
slt $t2, $t0, $t1

lui $t0, 0xFFFF #$t0 upper 16 1's

jal jumpTo1
add $0,$0,$0
lui $t0, 0xFFFF #$t0 upper 16 1's
ori $t0, $t0, 0xFFFF # $t0 lower 16 1's
addi $t1, $t0, 0 #$t1 all 0's

and $t2, $t1, $t0 

andi $t2, $t2, 0

nor $t2, $t2, $t0 

xor $t2, $t2, $t0 


or $t2, $t2, $t0 


# set less than

addi $t0, $0, 5
addi $t1, $0, -5


# shift

lui $t0, 0xFFFF #$t0 upper 16 1's
ori $t0, $t0, 0xFFFF # $t0 lower 16 1's

jal here

halt


jumpTo1:
lui $t0, 0xFFFF #$t0 upper 16 1's
ori $t0, $t0, 0xFFFF # $t0 lower 16 1's
addi $t1, $t0, 0 #$t1 all 0's

and $t2, $t1, $t0 

andi $t2, $t2, 0

nor $t2, $t2, $t0 

xor $t2, $t2, $t0 

xori $t2, $t2, 0

or $t2, $t2, $t0 

ori $t2, $t2, 0 


# set less than

addi $t0, $0, 5
addi $t1, $0, -5


# shift

lui $t0, 0xFFFF #$t0 upper 16 1's
ori $t0, $t0, 0xFFFF # $t0 lower 16 1's
addi $s0, $zero, 4
add $ra,$ra ,$s0
jr $ra

here:
jr $ra