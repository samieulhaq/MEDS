.data
array:          .word 10, -5, 20, -15, 30, 40, -8, 50, 60, -25, 70, 6
org_arr_msg:    .string "Original Array: "
sorted_arr_msg: .string "\nSorted Array: "
newline:        .string "\n"

.text
.globl main

print_array:
    mv   t0, a0 # arr pointer
    mv   t1, a1 # arr size
    li   t2, 0
print_loop:
    bge  t2, t1, print_end
    li   a0, 1
    lw   a1, 0(t0)
    ecall
    li   a0, 11
    li   a1, 32          # space character
    ecall
    addi t0, t0, 4
    addi t2, t2, 1
    j    print_loop
print_end:
    ret

# in merge a0=ptr, a1=left, a2=mid, a3=right
# it merges two sorted halves in place
# uses a temp buffer on stack
merge:
    addi sp, sp, -64
    sw   ra,  60(sp)
    sw   s0,  56(sp)
    sw   s1,  52(sp)
    sw   s2,  48(sp)
    sw   s3,  44(sp)
    sw   s4,  40(sp)
    sw   s5,  36(sp)
    sw   s6,  32(sp)

    mv   s0, a0          # base ptr
    mv   s1, a1          # left
    mv   s2, a2          # mid
    mv   s3, a3          # right

    # copy left half into temp buffer on stack
    mv   t0, s1          # i = left
    li   t1, 0           # buf index
copy_left:
    bgt  t0, s2, copy_left_done
    slli t2, t0, 2
    add  t2, s0, t2
    lw   t3, 0(t2)
    slli t4, t1, 2
    add  t4, sp, t4
    sw   t3, 0(t4)
    addi t0, t0, 1
    addi t1, t1, 1
    j    copy_left
copy_left_done:
    mv   s4, t1          # s4 = left half size

    # merge: i=0 (buf index), j=mid+1, k=left
    li   s5, 0           # i = 0 (left buffer index)
    addi s6, s2, 1       # j = mid + 1

    mv   t6, s1          # k = left (write index into original array)

merge_loop:
    # if i >= s4, copy remaining right and done
    bge  s5, s4, copy_right
    # if j > right, copy remaining left buffer and done
    bgt  s6, s3, copy_left_buf

    # compare buf[i] vs array[j]
    slli t0, s5, 2
    add  t0, sp, t0
    lw   t1, 0(t0)       # t1 = buf[i]

    slli t2, s6, 2
    add  t2, s0, t2
    lw   t3, 0(t2)       # t3 = array[j]

    blt  t1, t3, take_left
    # take right
    slli t4, t6, 2
    add  t4, s0, t4
    sw   t3, 0(t4)
    addi s6, s6, 1
    addi t6, t6, 1
    j    merge_loop

take_left:
    slli t4, t6, 2
    add  t4, s0, t4
    sw   t1, 0(t4)
    addi s5, s5, 1
    addi t6, t6, 1
    j    merge_loop

copy_left_buf:
    bge  s5, s4, merge_done
    slli t0, s5, 2
    add  t0, sp, t0
    lw   t1, 0(t0)
    slli t4, t6, 2
    add  t4, s0, t4
    sw   t1, 0(t4)
    addi s5, s5, 1
    addi t6, t6, 1
    j    copy_left_buf

copy_right:
    bgt  s6, s3, merge_done
    slli t2, s6, 2
    add  t2, s0, t2
    lw   t3, 0(t2)
    slli t4, t6, 2
    add  t4, s0, t4
    sw   t3, 0(t4)
    addi s6, s6, 1
    addi t6, t6, 1
    j    copy_right

merge_done:
    lw   s6,  32(sp)
    lw   s5,  36(sp)
    lw   s4,  40(sp)
    lw   s3,  44(sp)
    lw   s2,  48(sp)
    lw   s1,  52(sp)
    lw   s0,  56(sp)
    lw   ra,  60(sp)
    addi sp, sp, 64
    ret

merge_sort: # a0=ptr, a1=left, a2=right
    addi sp, sp, -32
    sw   ra,  28(sp)
    sw   s0,  24(sp)
    sw   s1,  20(sp)
    sw   s2,  16(sp)
    sw   s3,  12(sp)

    mv   s0, a0          # ptr
    mv   s1, a1          # left
    mv   s2, a2          # right

    bge  s1, s2, ms_done 

    add  s3, s1, s2
    srli s3, s3, 1      

    mv   a0, s0
    mv   a1, s1
    mv   a2, s3
    call merge_sort

    mv   a0, s0
    addi a1, s3, 1
    mv   a2, s2
    call merge_sort

    mv   a0, s0
    mv   a1, s1
    mv   a2, s3
    mv   a3, s2
    call merge

ms_done:
    lw   s3,  12(sp)
    lw   s2,  16(sp)
    lw   s1,  20(sp)
    lw   s0,  24(sp)
    lw   ra,  28(sp)
    addi sp, sp, 32
    ret

main:
    la   s0, array
    li   a0, 4
    la   a1, org_arr_msg
    ecall
    mv   a0, s0
    li   a1, 12
    call print_array

    addi sp, sp, -16
    sw   ra, 12(sp)
    mv   a0, s0
    li   a1, 0
    li   a2, 11
    call merge_sort
    lw   ra, 12(sp)
    addi sp, sp, 16

    li   a0, 4
    la   a1, sorted_arr_msg
    ecall
    mv   a0, s0
    li   a1, 12
    call print_array

    li   a0, 10
    ecall