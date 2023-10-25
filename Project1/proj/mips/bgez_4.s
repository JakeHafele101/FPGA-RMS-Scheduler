.data
.text
.globl main
main:
    # Start Test - Branch when register value is == 0
    addi $1, $0, 0
    bgez $1, L1     # Verify branch when $1 equals 0
    addi $1, $0, 1
    
L1: addi $2, $0, 0  # $1 should still be 0
    bgez $2, L2     # Verify branch when $2 equals 0
    addi $2, $0, 1
    
L2: addi $3, $0, 0  # $2 should still be 0
    bgez $3, L3     # Verify branch when $3 equals 0
    addi $3, $0, 1
    
L3: addi $4, $0, 0  # $3 should still be 0
    bgez $4, L4     # Verify branch when $4 equals 0
    addi $4, $0, 1
    
L4: addi $5, $0, 0  # $4 should still be 0
    bgez $5, L5     # Verify branch when $5 equals 0
    addi $5, $0, 1

L5: addi $6, $0, 0  # $5 should still be 0
    bgez $6, L6     # Verify branch when $6 equals 0
    addi $6, $0, 1

L6: addi $7, $0, 0  # $6 should still be 0
    bgez $7, L7     # Verify branch when $7 equals 0
    addi $7, $0, 1

L7: addi $8, $0, 0  # $7 should still be 0
    bgez $8, L8     # Verify branch when $8 equals 0
    addi $8, $0, 1

L8: addi $9, $0, 0  # $8 should still be 0
    bgez $9, L9     # Verify branch when $9 equals 0
    addi $9, $0, 1

L9: addi $10, $0, 0 # $9 should still be 0
    bgez $10, L10   # Verify branch when $10 equals 0
    addi $10, $0, 1

L10:addi $11, $0, 0 # $10 should still be 0
    bgez $11, L11   # Verify branch when $11 equals 0
    addi $11, $0, 1

L11:addi $12, $0, 0 # $11 should still be 0
    bgez $12, L12   # Verify branch when $12 equals 0
    addi $12, $0, 1

L12:addi $13, $0, 0 # $12 should still be 0
    bgez $13, L13   # Verify branch when $13 equals 0
    addi $13, $0, 1

L13:addi $14, $0, 0 # $13 should still be 0
    bgez $14, L14   # Verify branch when $14 equals 0
    addi $14, $0, 1

L14:addi $15, $0, 0 # $14 should still be 0
    bgez $15, L15   # Verify branch when $15 equals 0
    addi $15, $0, 1

L15:addi $16, $0, 0 # $15 should still be 0
    bgez $16, L16   # Verify branch when $16 equals 0
    addi $16, $0, 1

L16:addi $17, $0, 0 # $16 should still be 0
    bgez $17, L17   # Verify branch when $17 equals 0
    addi $17, $0, 1

L17:addi $18, $0, 0 # $17 should still be 0
    bgez $18, L18   # Verify branch when $18 equals 0
    addi $18, $0, 1

L18:addi $19, $0, 0 # $18 should still be 0
    bgez $19, L19   # Verify branch when $19 equals 0
    addi $19, $0, 1

L19:addi $20, $0, 0 # $19 should still be 0
    bgez $20, L20   # Verify branch when $20 equals 0
    addi $20, $0, 1

L20:addi $21, $0, 0 # $20 should still be 0
    bgez $21, L21   # Verify branch when $21 equals 0
    addi $21, $0, 1

L21:addi $22, $0, 0 # $21 should still be 0
    bgez $22, L22   # Verify branch when $22 equals 0
    addi $22, $0, 1

L22:addi $23, $0, 0 # $22 should still be 0
    bgez $23, L23   # Verify branch when $23 equals 0
    addi $23, $0, 1

L23:addi $24, $0, 0 # $23 should still be 0
    bgez $24, L24   # Verify branch when $24 equals 0
    addi $24, $0, 1

L24:addi $25 $0, 0 # $24 should still be 0
    bgez $25, L25  # Verify branch when $25 equals 0
    addi $25, $0, 1

L25:addi $26, $0, 0 # $25 should still be 0
    bgez $26, L26   # Verify branch when $26 equals 0
    addi $26, $0, 1

L26:addi $27, $0, 0 # $26 should still be 0
    bgez $27, L27   # Verify branch when $27 equals 0
    addi $27, $0, 1

L27:addi $28, $0, 0 # $27 should still be 0
    bgez $28, L28   # Verify branch when $28 equals 0
    addi $28, $0, 1

L28:addi $29, $0, 0 # $28 should still be 0
    bgez $29, L29   # Verify branch when $29 equals 0
    addi $29, $0, 1

L29:addi $30, $0, 0 # $29 should still be 0
    bgez $30, L30   # Verify branch when $30 equals 0
    addi $30, $0, 1

L30:addi $31, $0, 0 # $30 should still be 0
    bgez $31, L31   # Verify branch when $31 equals 0
    addi $31, $0, 1

L31: # $31 should still be 0
    # End Test

    # Exit program
    halt
