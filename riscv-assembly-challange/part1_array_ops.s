.data
array:      .word 10, -5, 20, -15, 30, 40, -8, 50, 60, -25, 70, 5

sum_msg:    .string "Sum: "
min_msg:    .string "\nMin: "
max_msg:    .string "\nMax: "
neg_msg:    .string "\nNegative Count: "

.text
.globl main

sum_array:
    addi sp, sp, -16
    sw s0, 12(sp)
    sw s1, 8(sp)
    mv s0, a0
    mv s1, a1
    li t0, 0
    li t1, 0

sum_loop:
    bge t0, s1, sum_done
    slli t2, t0, 2
    add t2, s0, t2
    lw t3, 0(t2)
    add t1, t1, t3
    addi t0, t0, 1
    j sum_loop

sum_done:
    mv a0, t1
    lw s1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 16
    ret

find_min:
    addi sp, sp, -16
    sw s0, 12(sp)
    sw s1, 8(sp)
    mv s0, a0
    mv s1, a1
    lw t1, 0(s0)
    li t0, 1

min_loop:
    bge t0, s1, min_done
    slli t2, t0, 2
    add t2, s0, t2
    lw t3, 0(t2)
    blt t3, t1, update_min
    j next_min

update_min:
    mv t1, t3

next_min:
    addi t0, t0, 1
    j min_loop

min_done:
    mv a0, t1

    lw s1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 16
    ret

find_max:
    addi sp, sp, -16
    sw s0, 12(sp)
    sw s1, 8(sp)
    mv s0, a0
    mv s1, a1
    lw t1, 0(s0)
    li t0, 1

max_loop:
    bge t0, s1, max_done
    slli t2, t0, 2
    add t2, s0, t2
    lw t3, 0(t2)
    bgt t3, t1, update_max
    j next_max

update_max:
    mv t1, t3

next_max:
    addi t0, t0, 1
    j max_loop

max_done:
    mv a0, t1

    lw s1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 16
    ret

count_negative:
    addi sp, sp, -16
    sw s0, 12(sp)
    sw s1, 8(sp)
    mv s0, a0
    mv s1, a1
    li t0, 0
    li t1, 0

neg_loop:
    bge t0, s1, neg_done
    slli t2, t0, 2
    add t2, s0, t2
    lw t3, 0(t2)
    blt t3, zero, inc_neg
    j next_neg

inc_neg:
    addi t1, t1, 1

next_neg:
    addi t0, t0, 1
    j neg_loop

neg_done:
    mv a0, t1
    lw s1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 16
    ret

main:
    # Sum
    li a0, 4
    la a1, sum_msg
    ecall

    la a0, array
    li a1, 12
    call sum_array

    mv t0, a0
    li a0, 1
    mv a1, t0
    ecall

    # Min
    li a0, 4
    la a1, min_msg
    ecall

    la a0, array
    li a1, 12
    call find_min

    mv t0, a0
    li a0, 1
    mv a1, t0
    ecall

    # Max
    li a0, 4
    la a1, max_msg
    ecall

    la a0, array
    li a1, 12
    call find_max

    mv t0, a0
    li a0, 1
    mv a1, t0
    ecall

    # Negative Count
    li a0, 4
    la a1, neg_msg
    ecall

    la a0, array
    li a1, 12
    call count_negative

    mv t0, a0
    li a0, 1
    mv a1, t0
    ecall

    li a0, 10
    ecall