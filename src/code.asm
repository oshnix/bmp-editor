%define temp_mem r14
%define word_size 4
%define pixel_array r12
%define result r15
%define array_size r13

label_mask: db 0xfc
times 7 db 0xff

align 16
c1_1: dd 0.272, 0.349, 0.393, 0.272
align 16
c2_1: dd 0.543, 0.686, 0.769, 0.543
align 16
c3_1: dd 0.131, 0.168, 0.189, 0.131

align 16
c1_2: dd 0.349, 0.393, 0.272, 0.349
align 16
c2_2: dd 0.686, 0.769, 0.543, 0.686
align 16
c3_2: dd 0.168, 0.189, 0.131, 0.168

align 16
c1_3: dd 0.393, 0.272, 0.349, 0.393
align 16
c2_3: dd 0.769, 0.543, 0.686, 0.769
align 16
c3_3: dd 0.189, 0.131, 0.168, 0.189

align 16
max_values: dd 255.0, 255.0, 255.0, 255.0

global sepia_asm 

sepia_asm:
    push r12
    push r13
    push r14
    push r15
    mov pixel_array, rdi
    mov array_size, rsi
    and array_size, [label_mask]
    mov r8, 0
    mov temp_mem, rdx
    mov result, rcx
    movaps xmm6, [max_values]

.loop:
    ;начинаем цЫкл из трех действий
    test array_size, array_size
    jz .end
;First iteration
        xor eax, eax
        pxor xmm0, xmm0
        pxor xmm1, xmm1
        pxor xmm2, xmm2
        mov al, byte[pixel_array]
        pinsrb xmm0, al, 0
        pinsrb xmm0, al, 4
        pinsrb xmm0, al, 8
        pinsrb xmm0, byte[pixel_array +3], 12
        cvtdq2ps xmm0, xmm0
        mov al, byte[pixel_array + 1]
        pinsrb xmm1, al, 0
        pinsrb xmm1, al, 4
        pinsrb xmm1, al, 8
        pinsrb xmm1, byte[pixel_array + 4], 12
        cvtdq2ps xmm1, xmm1
        mov al, byte[pixel_array + 2]
        pinsrb xmm2, al, 0
        pinsrb xmm2, al, 4
        pinsrb xmm2, al, 8
        pinsrb xmm2, byte[pixel_array + 5], 12
        cvtdq2ps xmm2, xmm2

    ;Умножаем, приводим к минимальному числу
    movaps xmm3, [c1_1]
    movaps xmm4, [c2_1]
    movaps xmm5, [c3_1]
    mulps xmm0, xmm3
    mulps xmm1, xmm4
    mulps xmm2, xmm5
    addps xmm0, xmm1
    addps xmm0, xmm2
    minps xmm0, xmm6
        cvtps2pi mm0, xmm0
        movq [temp_mem], mm0
        movhlps xmm0, xmm0
        cvtps2pi mm0, xmm0
        movq [temp_mem + 8], mm0
            mov al, [temp_mem]
            mov [result], al
            mov al, [temp_mem + word_size]
            mov [result + 1], al
            mov al, [temp_mem + 2 * word_size]
            mov [result + 2], al
            mov al, [temp_mem + 3 * word_size]
            mov [result + 3], al
    add pixel_array, 3
    add result, 4
;Second iteration
        xor eax, eax
        pxor xmm0, xmm0
        pxor xmm1, xmm1
        pxor xmm2, xmm2
        mov al, [pixel_array]
            pinsrb xmm0, al, 0
            pinsrb xmm0, al, 4
        mov al, [pixel_array + 3]
            pinsrb xmm0, al, 8
            pinsrb xmm0, al, 12
        cvtdq2ps xmm0, xmm0
        mov al, [pixel_array + 1]
            pinsrb xmm1, al, 0
            pinsrb xmm1, al, 4
        mov al, [pixel_array + 4]
            pinsrb xmm1, al, 8
            pinsrb xmm1, al, 12
        cvtdq2ps xmm1, xmm1
        mov al, [pixel_array + 2]
            pinsrb xmm2, al, 0
            pinsrb xmm2, al, 4
        mov al, [pixel_array + 5]
            pinsrb xmm2, al, 8
            pinsrb xmm2, al, 12
        cvtdq2ps xmm2, xmm2


    ;Умножаем, приводим к минимальному числу
    movaps xmm3, [c1_2]
    movaps xmm4, [c2_2]
    movaps xmm5, [c3_2]
    mulps xmm0, xmm3
    mulps xmm1, xmm4
    mulps xmm2, xmm5
    addps xmm0, xmm1
    addps xmm0, xmm2
    minps xmm0, xmm6
        cvtps2pi mm0, xmm0
        movq [temp_mem], mm0
        movhlps xmm0, xmm0
        cvtps2pi mm0, xmm0
        movq [temp_mem + 8], mm0
            mov al, [temp_mem]
            mov [result], al
            mov al, [temp_mem + word_size]
            mov [result + 1], al
            mov al, [temp_mem + 2 * word_size]
            mov [result + 2], al
            mov al, [temp_mem + 3 * word_size]
            mov [result + 3], al
    add pixel_array, 3
    add result, 4
;Third iteration
        xor eax, eax
        pxor xmm0, xmm0
        pxor xmm1, xmm1
        pxor xmm2, xmm2
        pinsrb xmm0, byte[pixel_array], 0
        mov al, byte[pixel_array+3]
        pinsrb xmm0, al, 4
        pinsrb xmm0, al, 8
        pinsrb xmm0, al, 12
        cvtdq2ps xmm0, xmm0
        pinsrb xmm1, byte[pixel_array + 1], 0
        mov al, byte[pixel_array+4]
        pinsrb xmm1, al, 4
        pinsrb xmm1, al, 8
        pinsrb xmm1, al, 12
        cvtdq2ps xmm1, xmm1
        pinsrb xmm2, byte[pixel_array+2], 0
        mov al, byte[pixel_array+5]
        pinsrb xmm2, al, 4
        pinsrb xmm2, al, 8
        pinsrb xmm2, al, 12
        cvtdq2ps xmm2, xmm2

    ;Умножаем, приводим к минимальному числу
    movaps xmm3, [c1_3]
    movaps xmm4, [c2_3]
    movaps xmm5, [c3_3]
    mulps xmm0, xmm3
    mulps xmm1, xmm4
    mulps xmm2, xmm5
    addps xmm0, xmm1
    addps xmm0, xmm2
    minps xmm0, xmm6
        cvtps2pi mm0, xmm0
        movq [temp_mem], mm0
        movhlps xmm0, xmm0
        cvtps2pi mm0, xmm0
        movq [temp_mem + 8], mm0
            mov al, [temp_mem]
            mov [result], al
            mov al, [temp_mem + word_size]
            mov [result + 1], al
            mov al, [temp_mem + 2 * word_size]
            mov [result + 2], al
            mov al, [temp_mem + 3 * word_size]
            mov [result + 3], al
    add pixel_array, 6
    add result, 4
    sub array_size, 4
    jmp .loop
.end:
    pop r15
    pop r14
    pop r13
    pop r12
    ret
