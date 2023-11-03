#Merge Sort
.data
array: .word 109,671,771,1157,1681,1756,1760,1795,1820,1967,1977,2010,2154,2215,2329,2335,2395,2513,2540,2620,2689,2835,3216,3468,3685,4305,4592,4679,4736,4826,4854,4922,5540,6076,6394,6440,6506,6569,6635,6688,6956,6972,7160,7343,7405,7482,7711,7724,7891,8022,8089,8208,8807,8847,8862,8961,8981,9370,9414,9420,9646,9702,9837,9927

.text

main:
# Start program
la $a0, array
la $s1, array
addi $a1, $zero,63
sll  $a1, $a1, 2
add $a1, $a1, $a0
addi, $a2,$a2,109
la  $sp, 0x7fffeffc
jal binarySearch
add $s0 , $zero, $v0
la $s1, array
slt $t0, $s0, $zero
bne $t0, $zero, skip
sub $s0,$s0,$s1
srl $s0,$s0, 2
skip:


halt


binarySearch:
add $t0, $a0, $a1  #find midpoint
srl $t0, $t0, 3
sll $t0, $t0, 2
lw $t1, 0($t0)
bne $t1,$a2, notFound  #check if found
addi, $v0,$t0,0
jr $ra
notFound:
bne $a0, $a1 keepLooking #if it is not in the array
addi, $v0,$zero,-1
jr $ra
keepLooking:
addi $sp, $sp, -24
sw $ra,16($sp) #store return address

#checks left
slt $t3,$t1,$a2
bne $t3, $zero,right
#go left
addi $a0,$a0,0
addi $a1,$t0,-4
addi $a2,$a2,0
jal binarySearch
j exit
#go right
right:
addi $a0,$t0,4
addi $a1,$a1,0
addi $a2,$a2,0
jal binarySearch

#loads return from stack pointer
exit:
lw $ra,16($sp)
addi $sp, $sp, 24
jr $ra





