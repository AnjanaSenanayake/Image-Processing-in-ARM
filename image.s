@***************************************************************************************
@    Title: Image Processor in ARM
@    Author: Anjana Senanayake
@    Date: 29/08/2017  
@    Code version: v1.0
@    Availability: https://github.com/AnjanaSenanayake/Image-Processing-in-ARM
@
@*************************************************************************************

.text                       @ instruction memory

@ ---------------------     @ functions

myscanf:   
    sub sp,sp,#4            @ make room on stack
    str lr,[sp,#0]          @ push (store) lr to the stack
    push {r5}               @ push r5 to the stack
    ldr r0, =format_input   @ r0 contains address of format string
    sub sp, sp,#4           @ allocate stack for input
    mov r1, sp              @ move sp to r1 to store entry on stack
    bl scanf                @ call scanf("%d",sp)
    ldr r0, [sp]            @ load value at sp into r0
    add sp, sp, #4          @ remove value from stack    
    pop {r5}                @ pop r5 from stack
    ldr lr,[sp,#0]          @ pop lr from the stack and return
    add sp,sp,#4
    mov pc,lr

invert:                     @ function for inverting the matrix
    sub sp,sp,#4            
    str lr,[sp,#0]          
    push {r1,r2,r3,r4,r5,r6}
    mov r10,r11
    mul r6,r8,r9
    lsl r6,r6,#2
    mov r1,#255
    mov r7,#0
    b loop
loop:                       @ looping through the matrix
    ldr r4,[r10]
    sub r4,r1,r4   
    str r4,[r10]
    add r10,r10,#4
    sub r6,r6,#4
    cmp r6,#0
    bne loop
    pop {r1,r2,r3,r4,r5,r6}
    ldr lr,[sp,#0]          
    add sp,sp,#4
    mov pc,lr

rotation:                   @ function for rotating the matrix 
    sub sp,sp,#4            
    str lr,[sp,#0]          
    push {r3,r4,r5}
    mov r7,#0
    mov r3,#0
    mul r6,r8,r9
    mov r10,r6
    lsr r10,r10,#1
    lsl r6,r6,#2
    sub r7,r6,#4
    b loop_r
loop_r:
    cmp r10,#0
    beq exit_rotate
    ldr r5,[r11,r7]
    ldr r4,[r11,r3]
    str r5,[r11,r3]
    str r4,[r11,r7]
    sub r7,r7,#4
    add r3,r3,#4
    sub r10,r10,#1
    bne loop_r
exit_rotate:  
    pop {r3,r4,r5}
    ldr lr,[sp,#0]         
    add sp,sp,#4
    mov pc,lr

flip:                        @ function to flip the matrix
    sub sp,sp,#4           
    str lr,[sp,#0]        
    push {r0,r1,r2,r3,r5,r6}
    mov r3,r9
    mov r4,#0
    mov r5,#1
    mov r12,r9
    lsr r12,r12,#1
    sub r3,r3,#1
    lsl r3,r3,#2
    b loop_flip
column_adjust:               @ moving through rows  
    mov r12,r9
    lsr r12,r12,#1
    mul r4,r5,r9
    lsl r4,r4,#2                 
    add r5,r5,#1
    mul r3,r5,r9
    lsl r3,r3,#2
    sub r3,r3,#4  
loop_flip:
    cmp r5,r8
    bgt exit_flip
    cmp r12,#0
    beq column_adjust 
    ldr r1,[r11,r3]
    ldr r2,[r11,r4]
    str r1,[r11,r4]
    str r2,[r11,r3]
    sub r3,r3,#4
    add r4,r4,#4
    sub r12,r12,#1
    b loop_flip
exit_flip:
    pop {r0,r1,r2,r3,r5,r6}
    ldr lr,[sp,#0]         
    add sp,sp,#4
    mov pc,lr

@ --------------------- 

.global main
main:
    sub sp, sp, #4          
    str lr, [sp, #0]        
    
    mov r3,#0               @ initialize index variable                 
    bl myscanf
    mov r8,r0               @ copy row value to r8             
 
    bl myscanf
    mov r9,r0               @ copy column value to r9

    bl myscanf
    mov r5,r0               @ copy opration value to r5

    mul r6,r8,r9
    lsl r6,r6,#2
    sub sp,sp,r6
    mov r11,sp
    mov r10,sp

    cmp r5,#0   
    beq inputloop
    cmp r5,#1               
    beq inputloop
    cmp r5,#2               
    beq inputloop
    cmp r5,#3               
    beq inputloop
    b error                 

inputloop:                     
    cmp r6,#0
    beq exit_loop

    ldr r0,=format_input
    mov r1,r10
    bl scanf
    add r10,r10,#4
    sub r6,r6,#4
    b inputloop             @ branch to next loop iteration

exit_loop:    
    cmp r5,#0               @ if op value=0 jump to function original
    beq original
    cmp r5,#1               @ if op value=1 jump to function invertmatrix
    beq invertmatrix
    cmp r5,#2               @ if op value=2 jump to function rotatematrix
    beq rotatematrix
    cmp r5,#3               @ if op value=e jump to function flipmatrix
    beq flipmatrix
    b error                 @ if else jump to function error


original:                   @ function 'original'
    ldr r0,=printf_original
    bl printf
    b output

invertmatrix:               @ function 'invertmatrix'
    ldr r0,=printf_invert
    bl printf
    bl invert
    b output

rotatematrix:               @ function 'rotatematrix'
    ldr r0,=printf_rotate
    bl printf
    bl rotation
    b output
flipmatrix:                 @ function 'flipmatrix'
    ldr r0,=printf_flip
    bl printf
    bl flip      
    b output  
error:                      @ function 'error'
    ldr r0,=printf_invalid
    bl printf    
    b exit


output:                     @ initializing for printing the output
    mul r6,r8,r9
    mov r3,#0   
    mov r4,#0

outputloop:                 @ printing a 2d matrix
    cmp r6,#0               @ check to see if we are done iterating
    beq exit                @ branch to exit

    cmp r9,r4               @ check with column
    beq next_row            @ branch to exit

    mul r2,r3,r9
    add r2,r2,r4
    lsl r2,r2,#2            @ multiply index*4 to get array offset
    ldr r0,=printf_array    @ r0 contains formatted string address
    ldr r1,[r11,r2]
    push {r1,r2,r3,r4}  
    bl  printf              @ branch to print procedure with return  
    pop {r1,r2,r3,r4}
    add r4,r4,#1            @ increment i index
    sub r6,r6,#1
    b outputloop            @ branch to next loop iteration
    
next_row:                   @ jump to print next row
    push {r2,r3,r4}
    ldr r0, =printf_line    @ r0 contains formatted string address
    bl printf               @ call printf
    pop {r2,r3,r4}
    mov r4,#0
    add r3,r3,#1
    b outputloop
   
exit:                       @ exiting the program
    ldr r0,=printf_line
    bl printf
    mul r6,r8,r9
    lsl r6,r6,#2
    add sp,sp,r6
    ldr lr, [sp, #0]
    add sp, sp, #4
    mov pc, lr

.data                       @ data memory

@array called arrary_a of size 90 bytes
.balign 4               @align to an address of multiple of 4
array_a: .skip 40       @unitilized array_a of 90 bytes
@array called arrary_a of size 90 bytes
.balign 4
array_b: .skip 40       @unitilized array_a of 90 bytes

format_input: .asciz "%d"
printf_array: .asciz "%d "
printf_line: .asciz "\n"
printf_original: .asciz "Original\n"
printf_invert: .asciz "Inversion\n"
printf_rotate: .asciz "Rotation by 180\n"
printf_flip: .asciz "Flip\n"
printf_invalid: .asciz "Invalid operation"
