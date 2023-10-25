.data
.text
.globl main
main:
    # Start Test - DO NOT Branch when register value is < 0
    addi $1, $0, 0xFFFFFFFF # -1 in 2s complement
    bgez $1, L1             # Verify NO branch when $1 < 0
    addi $1, $0, 2
    
L1: addi $2, $0, 0xFFFFFFFF  # $1 should now be 2
    bgez $2, L2              # Verify NO branch when $2 < 0
    addi $2, $0, 2
    
L2: addi $3, $0, 0xFFFFFFFF  # $2 should now be 2
    bgez $3, L3              # Verify NO branch when $3 < 0
    addi $3, $0, 2
    
L3: addi $4, $0, 0xFFFFFFFF  # $3 should now be 2
    bgez $4, L4              # Verify NO branch when $4 < 0
    addi $4, $0, 2
    
L4: addi $5, $0, 0xFFFFFFFF  # $4 should now be 2
    bgez $5, L5              # Verify NO branch when $5 < 0
    addi $5, $0, 2

L5: addi $6, $0, 0xFFFFFFFF  # $5 should now be 2
    bgez $6, L6              # Verify NO branch when $6 < 0
    addi $6, $0, 2

L6: addi $7, $0, 0xFFFFFFFF  # $6 should now be 2
    bgez $7, L7              # Verify NO branch when $7 < 0
    addi $7, $0, 2

L7: addi $8, $0, 0xFFFFFFFF  # $7 should now be 2
    bgez $8, L8              # Verify NO branch when $8 < 0
    addi $8, $0, 2

L8: addi $9, $0, 0xFFFFFFFF  # $8 should now be 2
    bgez $9, L9              # Verify NO branch when $9 < 0
    addi $9, $0, 2

L9: addi $10, $0, 0xFFFFFFFF # $9 should now be 2
    bgez $10, L10            # Verify NO branch when $10 < 0
    addi $10, $0, 2

L10:addi $11, $0, 0xFFFFFFFF # $10 should now be 2
    bgez $11, L11            # Verify NO branch when $11 < 0
    addi $11, $0, 2

L11:addi $12, $0, 0xFFFFFFFF # $11 should now be 2
    bgez $12, L12            # Verify NO branch when $12 < 0
    addi $12, $0, 2

L12:addi $13, $0, 0xFFFFFFFF # $12 should now be 2
    bgez $13, L13            # Verify NO branch when $13 < 0
    addi $13, $0, 2

L13:addi $14, $0, 0xFFFFFFFF # $13 should now be 2
    bgez $14, L14            # Verify NO branch when $14 < 0
    addi $14, $0, 2

L14:addi $15, $0, 0xFFFFFFFF # $14 should now be 2
    bgez $15, L15            # Verify NO branch when $15 < 0
    addi $15, $0, 2

L15:addi $16, $0, 0xFFFFFFFF # $15 should now be 2
    bgez $16, L16            # Verify NO branch when $16 < 0
    addi $16, $0, 2

L16:addi $17, $0, 0xFFFFFFFF # $16 should now be 2
    bgez $17, L17            # Verify NO branch when $17 < 0
    addi $17, $0, 2

L17:addi $18, $0, 0xFFFFFFFF # $17 should now be 2
    bgez $18, L18            # Verify NO branch when $18 < 0
    addi $18, $0, 2

L18:addi $19, $0, 0xFFFFFFFF # $18 should now be 2
    bgez $19, L19            # Verify NO branch when $19 < 0
    addi $19, $0, 2

L19:addi $20, $0, 0xFFFFFFFF # $19 should now be 2
    bgez $20, L20            # Verify NO branch when $20 < 0
    addi $20, $0, 2

L20:addi $21, $0, 0xFFFFFFFF # $20 should now be 2
    bgez $21, L21            # Verify NO branch when $21 < 0
    addi $21, $0, 2

L21:addi $22, $0, 0xFFFFFFFF # $21 should now be 2
    bgez $22, L22            # Verify NO branch when $22 < 0
    addi $22, $0, 2

L22:addi $23, $0, 0xFFFFFFFF # $22 should now be 2
    bgez $23, L23            # Verify NO branch when $23 < 0
    addi $23, $0, 2

L23:addi $24, $0, 0xFFFFFFFF # $23 should now be 2
    bgez $24, L24            # Verify NO branch when $24 < 0
    addi $24, $0, 2

L24:addi $25 $0, 0xFFFFFFFF  # $24 should now be 2
    bgez $25, L25            # Verify NO branch when $25 < 0
    addi $25, $0, 2

L25:addi $26, $0, 0xFFFFFFFF # $25 should now be 2
    bgez $26, L26            # Verify NO branch when $26 < 0
    addi $26, $0, 2

L26:addi $27, $0, 0xFFFFFFFF # $26 should now be 2
    bgez $27, L27            # Verify NO branch when $27 < 0
    addi $27, $0, 2

L27:addi $28, $0, 0xFFFFFFFF # $27 should now be 2
    bgez $28, L28            # Verify NO branch when $28 < 0
    addi $28, $0, 2

L28:addi $29, $0, 0xFFFFFFFF # $28 should now be 2
    bgez $29, L29            # Verify NO branch when $29 < 0
    addi $29, $0, 2

L29:addi $30, $0, 0xFFFFFFFF # $29 should now be 2
    bgez $30, L30            # Verify NO branch when $30 < 0
    addi $30, $0, 2

L30:addi $31, $0, 0xFFFFFFFF # $30 should now be 2
    bgez $31, L31            # Verify NO branch when $31 < 0
    addi $31, $0, 2

L31: # $31 should now be 2
    # End Test

    # Exit program
    halt
