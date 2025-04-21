# =============================================================
# main PROCEDURE TEMPLATE # 4b
#
# Use with "proc_template.asm" as the template for other procedures
#
# Based on "Ex4b" of Lecture 9 (Procedures and Stacks) of COMP411 Spring 2020
#   (main is simpler than other procedures because it does not have to
#     clean up anything before exiting)
#
# Assumptions:
#
#   - main calls other procedures with no more than 4 arguments ($a0-$a3)
#   - any local variables needed are put into registers (not memory)
#   - no values are put in temporaries that must be preserved across a call from main
#       to another procedure
#
# =============================================================
.eqv ROW        10
.eqv COL        10
.eqv TotalROW   30
.eqv TotalCOL   40

.eqv ROWS       12  
.eqv COLS       12 

.eqv y_offset   10
.eqv x_offset   15 

.eqv MINE_COUNT 10

.data 0x10010000                # Start of data memory
#
# declare global variables here
mine:     .space 576  
show:     .space 576
result:   .space 576

.text 0x00400000                # Start of instruction memory
.globl main

main:
    lui     $sp, 0x1001         # Initialize stack pointer to the 1024th location above start of data
    ori     $sp, $sp, 0x1000    # top of the stack will be one word below
                                #   because $sp is decremented first.
    addi    $fp, $sp, -4        # Set $fp to the start of main's stack frame



    # =============================================================
    # No need to create room for temporaries to be protected.
    # =============================================================




    # =============================================================
    # BODY OF main
    # ...
    # ...
    # ...
    # ... CODE FOR main HERE
        
            # =====================================================
            # main CALLS proc1
            #
            # Suppose main needs to call proc1, but there are no
            #   temporaries that need to be protected for this call.
            #
            # Suppose there are four arguments to send to proc1:
            #   (0, 10, 20, 30).  Here's how to do it.

    la   $a0, mine
    li   $a1, ROWS          
    li   $a2, COLS       
    jal  InitBoard
    
    la   $a0, show
    li   $a1, ROWS
    li   $a2, COLS
    jal  InitBoard
    
    la   $a0, show
    li   $a1, ROW       
    li   $a2, COL     
    jal  DisplayBoard
    
    la   $a0, mine
    li   $a1, ROW
    li   $a2, COL
    jal  SetMine
    
    la   $a0, mine
    la   $a1, show
    la   $a2, result
    li   $a3, ROW      
    li   $t0, COL          
    jal  FindMine

            # =====================================================
            

    # ... MORE CODE FOR main HERE
    # ...
    # ...
    # END OF BODY OF main
    # =============================================================



exit_from_main:

    ###############################
    # END using infinite loop     #
    ###############################

                        # program may not reach here, but have it for safety
end:
    j   end             # infinite loop "trap" because we don't have syscalls to exit


######## END OF MAIN #################################################################################

InitBoard:
    li $t0, 0     # i
    li $t1, 0     # j
outer_loop:
    bgt   $t0, $a1, end_outer
    li    $t1, 0        # j = 0
inner_loop:
    bge   $t1, $a2, end_inner

    # Compute offset: (i * COLS + j) * 4
    sll $t3, $t0, 3      # $t1 = $t0 * 8
    sll $t4, $t0, 2      # $t2 = $t0 * 4
    add $t3, $t3, $t4   
    add   $t3, $t3, $t1   # + j
    sll   $t3, $t3, 2     # * 4 (byte offset)

    add   $t4, $a0, $t3   # board base + offset
    sw    $zero, 0($t4)     # store value

    addi  $t1, $t1, 1
    j     inner_loop
end_inner:
    addi  $t0, $t0, 1
    j     outer_loop
end_outer:
    jr    $ra
    
    
DisplayBoard:
    li   $t0, y_offset
    li   $t1, x_offset
    li   $t2, 1             # i = 1
outer_loop2:
    bgt  $t2, $a1, end_outer_loop2
    li   $t3, 1             # j = 1
inner_loop2:
    bgt  $t3, $a2, end_inner_loop2
    sll $t4, $t2, 3  
    sll $t5, $t2, 1      
    add  $t4, $t4, $t5      
    add  $t4, $t4, $t3
    sll  $t4, $t4, 2        # byte offset
    add  $t5, $a0, $t4      # t5 = &show[i][j]
    lw   $a0, 0($t5)        # t6 = show[i][j]

    add  $t6, $t3, $t1
    addi $t6, $t6, -1       # x = x_offset + j - 1

    # Compute y = y_offset + i - 1
    add  $t7, $t2, $t0
    addi $t7, $t7, -1       # y = y_offset + i - 1

    # Call putChar_atXY(char, x, y)
    move $a1, $t6
    move $a2, $t7
    jal  putChar_atXY

    addi $t3, $t3, 1        # j++
    j    inner_loop2
end_inner_loop2:
    addi $t2, $t2, 1        # i++
    j    outer_loop2
end_outer_loop2:
    jr $ra
    

mine_count:
    li   $t9, 0             # sum = 0

    # mine[x-1][y]
    addi $t0, $a1, -1       # t0 = x-1
    sll $t1, $t0, 3      # $t1 = $t0 * 8
    sll $t2, $t0, 2      # $t2 = $t0 * 4
    add $t1, $t2, $t1   
    add  $t1, $t1, $a2   # + j
    sll  $t1, $t1, 2 
    add  $t0, $a0, $t1
    lw   $t1, 0($t0)        # t1 = mine[x-1][y]
    add  $t9, $t9, $t1

    # mine[x-1][y-1]
    addi $t2, $a2, -1       # t0 = y-1
    addi $t0, $a1, -1
    sll $t1, $t0, 3      # $t1 = $t0 * 8
    sll $t3, $t0, 2      # $t2 = $t0 * 4
    add $t1, $t3, $t1   
    add  $t1, $t1, $t2   # + j
    sll  $t1, $t1, 2 
    add  $t0, $a0, $t1
    lw   $t1, 0($t0)        # t1 = mine[x-1][y]
    add  $t9, $t9, $t1
    
    # mine[x][y-1]
    addi $t2, $a2, -1       # t0 = y-1
    sll $t1, $a1, 3      # $t1 = $t0 * 8
    sll $t3, $a1, 2      # $t2 = $t0 * 4
    add $t1, $t3, $t1   
    add  $t1, $t1, $t2   # + j
    sll  $t1, $t1, 2 
    add  $t0, $a0, $t1
    lw   $t1, 0($t0)        # t1 = mine[x-1][y]
    add  $t9, $t9, $t1

    # mine[x+1][y-1]
    addi $t2, $a2, -1       # t0 = y-1
    addi $t0, $a1, 1
    sll $t1, $t0, 3      # $t1 = $t0 * 8
    sll $t3, $t0, 2      # $t2 = $t0 * 4
    add $t1, $t3, $t1   
    add  $t1, $t1, $t2   # + j
    sll  $t1, $t1, 2 
    add  $t0, $a0, $t1
    lw   $t1, 0($t0)        # t1 = mine[x-1][y]
    add  $t9, $t9, $t1

    # mine[x+1][y]
    addi $t0, $a1, 1       # t0 = x-1
    sll $t1, $t0, 3      # $t1 = $t0 * 8
    sll $t2, $t0, 2      # $t2 = $t0 * 4
    add $t1, $t2, $t1   
    add  $t1, $t1, $a2   # + j
    sll  $t1, $t1, 2 
    add  $t0, $a0, $t1
    lw   $t1, 0($t0)        # t1 = mine[x-1][y]
    add  $t9, $t9, $t1


    # mine[x+1][y+1]
    addi $t2, $a2, 1       # t0 = y-1
    addi $t0, $a1, 1
    sll $t1, $t0, 3      # $t1 = $t0 * 8
    sll $t3, $t0, 2      # $t2 = $t0 * 4
    add $t1, $t3, $t1   
    add  $t1, $t1, $t2   # + j
    sll  $t1, $t1, 2 
    add  $t0, $a0, $t1
    lw   $t1, 0($t0)        # t1 = mine[x-1][y]
    add  $t9, $t9, $t1

    # mine[x][y+1]
    addi $t2, $a2, 1       # t0 = y-1
    sll $t1, $a1, 3      # $t1 = $t0 * 8
    sll $t3, $a1, 2      # $t2 = $t0 * 4
    add $t1, $t3, $t1   
    add  $t1, $t1, $t2   # + j
    sll  $t1, $t1, 2 
    add  $t0, $a0, $t1
    lw   $t1, 0($t0)        # t1 = mine[x-1][y]
    add  $t9, $t9, $t1

    # mine[x-1][y+1]
    addi $t2, $a2, 1       # t0 = y-1
    addi $t0, $a1, -1
    sll $t1, $t0, 3      # $t1 = $t0 * 8
    sll $t3, $t0, 2      # $t2 = $t0 * 4
    add $t1, $t3, $t1   
    add  $t1, $t1, $t2   # + j
    sll  $t1, $t1, 2 
    add  $t0, $a0, $t1
    lw   $t1, 0($t0)        # t1 = mine[x-1][y]
    add  $t9, $t9, $t1

    # result = sum / 16
    srl $v0, $t9, 4  

    jr   $ra

IsWin:
    li $v0, 0              # num = 0
    li $t0, 1              # i = 1

outer_loop3:
    bgt $t0, $a1, end2     # if i > row, exit loop
    li $t1, 1              # j = 1

inner_loop3:
    bgt $t1, $a2, next_i   # if j > col, continue outer loop

    # compute address of show[i][j]
    # offset = ((i * COLS) + j) * 4
    sll $t2, $t0, 3      # $t1 = $t0 * 8
    sll $t3, $t0, 2      # $t2 = $t0 * 4
    add $t2, $t3, $t2   
    add   $t2, $t2, $t1   # + j
    sll   $t2, $t2, 2    
    add $t3, $a0, $t2      # address of show[i][j]

    lw $t4, 0($t3)         # load show[i][j]

    beq $t4, $zero, increment_num   # if show[i][j] == 0
    li $t5, 13
    beq $t4, $t5, increment_num     # if show[i][j] == 13
    j skip_increment
increment_num:
    addi $v0, $v0, 1       # num++
skip_increment:
    addi $t1, $t1, 1       # j++
    j inner_loop3
next_i:
    addi $t0, $t0, 1       # i++
    j outer_loop3
end2:
    jr $ra
    
    
combineBoards:
    li $t0, 0                  # i = 0

outer_loop4:
    bge $t0, $a0, end_function     # if i >= rows, end
    li $t1, 0                  # j = 0

inner_loop4:
    bge $t1, $a1, next_i2       # if j >= cols, go to next i

    # Compute index = i * cols + j
    sll $t3, $t0, 3      # $t1 = $t0 * 8
    sll $t4, $t0, 2      # $t2 = $t0 * 4
    add $t3, $t3, $t4   
    add   $t3, $t3, $t1   # + j
    sll   $t3, $t3, 2 

    # Load mine[i][j]
    add $t4, $a2, $t3          # address of mine[i][j]
    lw $t2, 0($t4)             # t2 = mine[i][j]

    li $t5, 16
    beq $t2, $t5, store_11     # if mine[i][j] == 11, result = 11

    # Load show[i][j]
    add $t6, $a3, $t3          # address of show[i][j]
    lw $t4, 0($t6)             # t4 = show[i][j]

store_result:
    add $t7, $t3, $k0          # address of result[i][j]
    sw $t4, 0($t7)             # store show[i][j] or 11
    addi $t1, $t1, 1           # j++
    j inner_loop4

store_11:
    li $t4, 16
    j store_result

next_i2:
    addi $t0, $t0, 1           # i++
    j outer_loop4

end_function:
    jr $ra
    
    
spread:
    # Allocate stack frame
    addi $sp, $sp, -8
    sw      $ra, 4($sp)  
    sw      $fp, 0($sp) 
    addi    $fp, $sp, 4
    addi $sp, $sp, -24
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $s3, 8($sp)
    sw $s4, 4($sp)
    sw $s5, 0($sp)

    # Save arguments
    move $s0, $a0      # mine
    move $s1, $a1      # show
    move $s2, $a2      # x
    move $s3, $a3      # y

    # Call mine_count(mine, x, y)
    move $a0, $s0
    move $a1, $s2
    move $a2, $s3
    jal mine_count     # result in $v0

    move $s4, $v0      # save count

    beq $s4, $zero, spread_zero

    # Else: show[x][y] = count + 1
    sll $t0, $s2, 3      # $t1 = $t0 * 8
    sll $t1, $s2, 2      # $t2 = $t0 * 4
    add $t0, $t0, $t1  
    add   $t0, $t0, $s3   # + j
    sll   $t0, $t0, 2     # * 4 (byte offset)      # x * COLS
    add $t1, $s1, $t0      # &show[x][y]
    addi $t3, $s4, 1
    sw $t3, 0($t1)
    j spread_exit

spread_zero:
    # show[x][y] = 1
    sll $t0, $s2, 3      # $t1 = $t0 * 8
    sll $t1, $s2, 2      # $t2 = $t0 * 4
    add $t0, $t0, $t1  
    add   $t0, $t0, $s3   # + j
    sll   $t0, $t0, 2     # * 4 (byte offset)      # x * COLS
    add $t1, $s1, $t0
    li $t3, 1
    sw $t3, 0($t1)

    # i loop (-1 to 1)
    li $s4, -1        # i = -1
loop_i:
    bgt $s4, 1, spread_exit
    li $s5, -1        # j = -1
loop_j:
    bgt $s5, 1, next_i3

    # nx = x + i
    # ny = y + j
    add $t0, $s2, $s4     # nx
    add $t1, $s3, $s5     # ny

    # Bounds check: nx >= 1 && ny >= 1 && nx < ROWS && ny < COLS
    blt $t0, 1, skip_rec
    blt $t1, 1, skip_rec
    li $t2, ROWS
    li $t3, COLS
    bge $t0, $t2, skip_rec
    bge $t1, $t3, skip_rec

    # check show[nx][ny] == 0 || show[nx][ny] == 13
    sll $t5, $t0, 3      # $t1 = $t0 * 8
    sll $t6, $t0, 2      # $t2 = $t0 * 4
    add $t5, $t5, $t6  
    add   $t5, $t5, $t1   # + j
    sll   $t5, $t5, 2 

    add $t6, $s1, $t5
    lw $t7, 0($t6)
    beq $t7, $zero, do_rec
    li $t8, 13
    beq $t7, $t8, do_rec
    j skip_rec

do_rec:
    # Call spread(mine, show, nx, ny)
    move $a0, $s0
    move $a1, $s1
    move $a2, $t0
    move $a3, $t1
    jal spread

skip_rec:
    addi $s5, $s5, 1
    j loop_j

next_i3:
    addi $s4, $s4, 1
    j loop_i

spread_exit:
    lw $s0, 20($sp)  
    lw $s1, 16($sp)
    lw $s2, 12($sp)
    lw $s3, 8($sp)
    lw $s4, 4($sp)
    lw $s5, 0($sp)
    addi    $sp, $fp, 4     # Restore $sp
    lw      $ra, 0($fp)     # Restore $ra
    lw      $fp, -4($fp)    # Restore $fp
    jr      $ra             # Return from procedure

        
generate_random_1_to_10:
    # Initialize
    li    $t0, 0x8001         # start_state
    move  $t1, $t0            # lfsr = start_state
    li    $t2, 0              # period counter
loop_lfsr:
    # Compute bit = (lfsr ^ (lfsr >> 1) ^ (lfsr >> 3) ^ (lfsr >> 12)) & 1
    move  $t3, $t1            # temp = lfsr
    srl   $t4, $t3, 1         # lfsr >> 1
    xor   $t3, $t3, $t4

    srl   $t4, $t1, 3         # lfsr >> 3
    xor   $t3, $t3, $t4

    srl   $t4, $t1, 12        # lfsr >> 12
    xor   $t3, $t3, $t4

    andi  $t3, $t3, 1         # bit = result & 1

    # lfsr = (lfsr >> 1) | (bit << 15)
    srl   $t1, $t1, 1
    sll   $t4, $t3, 15
    or    $t1, $t1, $t4

    # period += 1
    addiu $t2, $t2, 1

    # if lfsr == start_state -> break
    bne   $t1, $t0, done_check

    # if lfsr in [1, 12] return it
    andi   $t2, $t2, 0x000F
    li    $t5, 1
    li    $t6, 10
    blt   $t2, $t5, loop_lfsr
    bgt   $t2, $t6, loop_lfsr

    # return lfsr
    move  $v0, $t2
    jr    $ra

done_check:
    # If we hit the initial state again, just loop again to retry
    j loop_lfsr
    
SetMine:
    li   $t0, MINE_COUNT      # count = MINE_COUNT
    addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
    sw      $ra, 4($sp)         # Save $ra
    sw      $fp, 0($sp)         # Save $fp
    addi    $fp, $sp, 4

setmine_loop:
    beq $s0, $zero, setmine_done    # while (count)

    # --- Generate x = rand() % row + 1 ---
    jal generate_random_1_to_10
    move $s1, $v0

    # --- Generate y = rand() % col + 1 ---
    jal generate_random_1_to_10
    move $s2, $v0 

    # Calculate address of mine[x][y] in linear array
    # address = base + (x * COLS + y) * 4
    sll $t0, $s1, 3      # $t1 = $t0 * 8
    sll $t1, $s1, 2      # $t2 = $t0 * 4
    add $t0, $t0, $t1  
    add   $t0, $t0, $s2   # + j
    sll   $t0, $t0, 2     # * 4 (byte offset)      # x * COLS
    add $t1, $a0, $t0
    

    lw   $t5, 0($t1)          # if (mine[x][y] == 0)
    bne $t5, $zero, setmine_loop    # skip if already has a mine

    li   $t6, 16              # mine value
    sw   $t6, 0($t1)          # mine[x][y] = 11

    addi $s0, $s0, -1          # count--

    j setmine_loop

setmine_done:
    addi    $sp, $fp, 4     # Restore $sp
    lw      $ra, 0($fp)     # Restore $ra
    lw      $fp, -4($fp)    # Restore $fp
    jr      $ra 
    
FindMine:
    # Arguments: 
    # $a0 = address of mine array
    # $a1 = address of show array
    # $a2 = address of result array
    # $a3 = row
    # [col] is in stack or passed via saved reg

    addiu $sp, $sp, -32       # allocate stack
    sw $ra, 28($sp)           # save return address
    sw $s0, 24($sp)           # save registers
    sw $s1, 20($sp)
    sw $s2, 16($sp)
    sw $s3, 12($sp)
    sw $s4, 8($sp)
    sw $s5, 4($sp)
    sw $s6, 0($sp)

    li $s0, 1         # x = 1
    li $s1, 1         # y = 1
    li $s2, 0         # key1 = 0

    # assume $s3 = row (copy from $a3)
    move $s3, $a3

    # load col from memory or pass it in $t0 -> move to $s4
    lw $s4, 0($sp)    # example: assume 'col' is passed on stack top

    # Compute y_offset = (TotalROW - row) / 2
    li $t0, 30        # TotalROW
    subu $t0, $t0, $s3
    sra $s5, $t0, 1   # s5 = y_offset

    # Compute x_offset = (TotalCOL - col) / 2
    li $t1, 40        # TotalCOL
    subu $t1, $t1, $s4
    sra $s6, $t1, 1   # s6 = x_offset

loop:
    # putChar_atXY(12, y-1+x_offset, x-1+y_offset)
    li $a0, 12
    addiu $t2, $s1, -1
    addu $a1, $t2, $s6    # y-1 + x_offset
    addiu $t3, $s0, -1
    addu $a2, $t3, $s5    # x-1 + y_offset
    jal putChar_atXY

    # key1 = pause_and_getkey(10)
    li $a0, 10
    jal pause_and_getkey
    move $s2, $v0         # key1 = v0

    li $t0, 1
    beq $s2, $t0, key1_up
    li $t0, 2
    beq $s2, $t0, key1_down
    li $t0, 3
    beq $s2, $t0, key1_left
    li $t0, 4
    beq $s2, $t0, key1_right
    li $t0, 5
    beq $s2, $t0, key1_select
    li $t0, 6
    beq $s2, $t0, key1_flag
    j check_win

key1_up:
    addiu $s1, $s1, -1
    bgtz $s1, skip_ymin
    li $s1, 1
skip_ymin:
    move $a0, $a1        # prepare DisplayBoard args
    jal DisplayBoard
    j loop

key1_down:
    addiu $s1, $s1, 1
    ble $s1, $s4, skip_ymax
    move $s1, $s4
skip_ymax:
    jal DisplayBoard
    j loop

key1_left:
    addiu $s0, $s0, -1
    bgtz $s0, skip_xmin
    li $s0, 1
skip_xmin:
    jal DisplayBoard
    j loop

key1_right:
    addiu $s0, $s0, 1
    ble $s0, $s3, skip_xmax
    move $s0, $s3
skip_xmax:
    jal DisplayBoard
    j loop

key1_select:
    # if (mine[x][y] == 11)
    # Use index calculation: mine[x][y] = *(base + x*COLS + y)
    # Assume ROWS and COLS are known (12)
    li $t1, 12        # COLS
    mul $t2, $s0, $t1
    add $t2, $t2, $s1
    sll $t2, $t2, 2   # offset in bytes
    add $t3, $a0, $t2 # address of mine[x][y]
    lw $t4, 0($t3)
    li $t5, 11
    beq $t4, $t5, hit_mine

    # else spread
    move $a0, $a0
    move $a1, $a1
    move $a2, $s0
    move $a3, $s1
    jal spread
    jal DisplayBoard
    j loop

hit_mine:
    move $a0, $s3     # rows
    move $a1, $s4     # cols
    jal combineBoards
    jal DisplayBoard
    j end3

key1_flag:
    # toggle show[x][y] between 0 and 13
    li $t1, 12
    mul $t2, $s0, $t1
    add $t2, $t2, $s1
    sll $t2, $t2, 2
    add $t3, $a1, $t2
    lw $t4, 0($t3)
    beqz $t4, set_13
    li $t5, 13
    beq $t4, $t5, set_0
    j loop

set_13:
    li $t5, 13
    sw $t5, 0($t3)
    jal DisplayBoard
    j loop

set_0:
    sw $zero, 0($t3)
    jal DisplayBoard
    j loop

check_win:
    # ret = IsWin(show, row, col)
    move $a0, $a1
    move $a1, $s3
    move $a2, $s4
    jal IsWin
    li $t0, 10      # MINE_COUNT
    beq $v0, $t0, end3
    j loop

end3:
    lw $ra, 28($sp)
    lw $s0, 24($sp)
    lw $s1, 20($sp)
    lw $s2, 16($sp)
    lw $s3, 12($sp)
    lw $s4, 8($sp)
    lw $s5, 4($sp)
    lw $s6, 0($sp)
    addiu $sp, $sp, 32
    jr $ra

#.include "procs_board.asm"          # include file with helpful procedures
.include "procs_mars.asm"                # Use this line for simulation in MARS
