.data
# The 6 hand-encoded instructions as raw hex words
encoded: .word 0x00A28233   # R: add x4, x5, x10
         .word 0x00500113   # I: addi x2, x0, 5
         .word 0x00742423   # S: sw x7, 8(x8)
         .word 0x00208863   # B: beq x1, x2, +16
         .word 0x123452B7   # U: lui x5, 0x12345
         .word 0x008000EF   # J: jal x1, +8

# Labels for printing
r_lbl:  .string "R-type | opcode: "
i_lbl:  .string "I-type | opcode: "
s_lbl:  .string "S-type | opcode: "
b_lbl:  .string "B-type | opcode: "
u_lbl:  .string "U-type | opcode: "
j_lbl:  .string "J-type | opcode: "

rd_str:     .string "  rd: "
rs1_str:    .string "  rs1: "
funct3_str: .string "  funct3: "
newline:    .string "\n"

.text
.globl main

# print_fields(a0 = raw instruction word, a1 = label addr)
# extract and print opcode, rd, rs1, funct3
print_fields:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0,  8(sp)

    mv   s0, a0 

    # print label
    mv   a1, a1
    li   a0, 4
    ecall

    # extract opcode = bits [6:0]
    li   a0, 4
    la   a1, rd_str 
    ecall
    andi a1, s0, 0x7F 
    li   a0, 1
    ecall

    # extract rd = bits [11:7]
    li   a0, 4
    la   a1, rd_str
    ecall
    srli t0, s0, 7
    andi a1, t0, 0x1F  
    li   a0, 1
    ecall

    # extract rs1 = bits [19:15]
    li   a0, 4
    la   a1, rs1_str
    ecall
    srli t0, s0, 15
    andi a1, t0, 0x1F  
    li   a0, 1
    ecall

    # extract funct3 = bits [14:12]
    li   a0, 4
    la   a1, funct3_str
    ecall
    srli t0, s0, 12
    andi a1, t0, 0x7   
    li   a0, 1
    ecall

    li   a0, 4
    la   a1, newline
    ecall

    lw   s0,  8(sp)
    lw   ra,  12(sp)
    addi sp, sp, 16
    ret

main:
    la   s0, encoded         # base address of encoded words

    lw   a0, 0(s0)
    la   a1, r_lbl
    call print_fields

    lw   a0, 4(s0)
    la   a1, i_lbl
    call print_fields

    lw   a0, 8(s0)
    la   a1, s_lbl
    call print_fields

    lw   a0, 12(s0)
    la   a1, b_lbl
    call print_fields

    lw   a0, 16(s0)
    la   a1, u_lbl
    call print_fields

    lw   a0, 20(s0)
    la   a1, j_lbl
    call print_fields

    li   a0, 10
    ecall