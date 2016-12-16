%define word_size 4
%define pixel_array r12
%define array_size r13
%define result r14

mask: db 0xfc
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
max_values: dd 255, 255, 255, 255

global sepia_asm 

;точка входа в фукнцию
sepia_asm:
    ;сохраняем используемые регистры
    push r12
    push r13
    push r14
    ;при вызове функции получили в rdi - сам массив, в rsi - его длину, в rdx - адрес, в который нужно положить конечный массив.
    mov pixel_array, rdi
    mov array_size, rsi
    ;Длина должна быть кратна 4 байтам - убираем лишние, если они имеются
    and array_size, [mask]
    mov result, rdx
    ;у нас не может быть значений больше 255. Заполняем xmm6 граничными значениями, чтобы впоследствии сравнивать с ними.
    movaps xmm6, [max_values]
    ;Если нам передали массив длины меньше 4 пикселей - обработать его мы не сможем.
    test array_size, array_size
    jz .end
.loop:
    ;Перед началом разбора советую почитать про числа с плавающей точкой (FP values), что такое packed для XMM регистров.
        ;Это будет актуально для SSE команд, в которых встречаются буквы p,s.

    ;Начало цикла из трех блоков. По формуле нам нужно сначала обработать три компоненты первого пикселя и ещё одну - другого
        ;Затем, две компоненты второго пикселя (одна уже обработана) и две компоненты третьего.
        ;И в конце - одну компоненту третьего пикселя и три компоненты четвертого. После этого цикл повторяется с следующими
        ;четырьмя пикселями. Так как оптимизация для нас приоритетнее - пытаться унифицировать этот процесс не стоит.
;First iteration
        ;Обнуляем регистры, в которых у нас лежат компоненты цвета. Так как мы хотим получить в xmm регистрах 4 float'a
            ;а на вход нам подается массив байт, то мы будем пересылать байты на заранее определенные части xmm регистра.
            ;А так как данная операция не обнуляет содержимое остальных байт регистра, то нам нужно удостовериться, что
            ;xmm регистр изначально заполнен нулями.
        pxor xmm0, xmm0
        pxor xmm1, xmm1
        pxor xmm2, xmm2
        ;pinsrb - packed insert byte - первый аргумент xmm регистр, второй - байт памяти или 8-разрядный регистр. третий -
            ;позиция в xmm регистре, куда нужно положить этот байт.
        pinsrb xmm0, byte[pixel_array], 0
        ;shufps здесь используется для того, чтобы тасовать блоки по 4 байта. Получив в нулевом блоке нужное число, мы
            ;распространяем его на 1 и 2 блок. В результате получаем в регистре, в котором было [b, 0, 0, 0]
            ;числа [b, b, b, b].
        shufps xmm0, xmm0, 00000000
        ;Вставляем в последний блок b2. Получаем что-то наподобие: [b1, b1, b1, b2] в регистре.
        pinsrb xmm0, byte[pixel_array +3], 12
        ;convert packed doubleword integers to packed single-precision FP values. Конвертирует 4 dw в 4 float'a
        cvtdq2ps xmm0, xmm0

        ;то же самое для регистров xmm1, xmm2
        pinsrb xmm1, byte[pixel_array+ 1], 0
        shufps xmm1, xmm1, 00000000
        pinsrb xmm1, byte[pixel_array + 4], 12
        cvtdq2ps xmm1, xmm1

        pinsrb xmm2, byte[pixel_array + 2], 0
        shufps xmm2, xmm2, 00000000
        pinsrb xmm2, byte[pixel_array + 5], 12
        cvtdq2ps xmm2, xmm2

    ;В регистрах xmm3-xmm5 храним матрицу перехода, согласно заданию
    movaps xmm3, [c1_1]
    movaps xmm4, [c2_1]
    movaps xmm5, [c3_1]
    ;mulps выполняет умножение 4 float'ов из первого xmm регистра на 4 float'a из второго и результат помещает в первый.
    mulps xmm0, xmm3
    mulps xmm1, xmm4
    mulps xmm2, xmm5
    ;Получив результат умножения, надо сложить разноименные компоненты одного пикселя, чтобы получить новую компоненту.
        ;addps склаыдвает 4 float'a из первого xmm с четырьмя float'ами из второго и результат кладет в первый xmm.
    addps xmm0, xmm1
    addps xmm0, xmm2
    ;Совершает обратную конвертацию (из float в int)
    cvtps2dq xmm0, xmm0
    ;Сравнивает соответствующие числа из первого xmm регистра с числами из второго xmm регистра и для каждой пары
        ;минимальное число записывает в первый xmm регистр. Таким образом гарантируется, что ни одно число не превышает 255.
    pminsd xmm0, xmm6
        ;pextrb - packed extract byte. Извлекает из xmm регистра (второй аргумент) один байт на соответствующей
            ;позиции (третий аргумент) и помещает его в укзанный байт в памяти, или в 8-разрядный регистр.
            ;Таким образом, мы кладем четыре обработанные компоненты в результирующий массив.
        pextrb [result], xmm0, 0
        pextrb [result + 1], xmm0, 4
        pextrb [result + 2], xmm0, 8
        pextrb [result + 3], xmm0, 12
    ;1 пиксель мы обработали полностью, поэтому смещаемся по исходному массиву на 3 (в пикселе 3 компоненты).
    add pixel_array, 3
    ;В результирующий массив положили 4 компоненты.
    add result, 4
;Second iteration
        pxor xmm0, xmm0
        pxor xmm1, xmm1
        pxor xmm2, xmm2
            pinsrb xmm0, [pixel_array], 0
            pinsrb xmm0, [pixel_array + 3], 8
        shufps xmm0, xmm0, 0b00001010
        cvtdq2ps xmm0, xmm0
           pinsrb xmm1, [pixel_array + 1], 0
           pinsrb xmm1, [pixel_array + 4], 8
       shufps xmm1, xmm1, 0b00001010
       cvtdq2ps xmm1, xmm1
           pinsrb xmm2, [pixel_array + 2], 0
           pinsrb xmm2, [pixel_array + 5], 8
       shufps xmm2, xmm2, 0b00001010
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
    cvtps2dq xmm0, xmm0
    pminsd xmm0, xmm6
        pextrb [result], xmm0, 0
        pextrb [result + 1], xmm0, 4
        pextrb [result + 2], xmm0, 8
        pextrb [result + 3], xmm0, 12
    add pixel_array, 3
    add result, 4
;Third iteration
        pxor xmm0, xmm0
        pxor xmm1, xmm1
        pxor xmm2, xmm2
            pinsrb xmm0, byte[pixel_array], 0
            pinsrb xmm0, byte[pixel_array+3], 4
        shufps xmm0, xmm0, 0b00010101
        cvtdq2ps xmm0, xmm0
            pinsrb xmm1, byte[pixel_array + 1], 0
            pinsrb xmm1, byte[pixel_array + 4], 4
        shufps xmm1, xmm1, 0b00010101
        cvtdq2ps xmm1, xmm1
            pinsrb xmm2, byte[pixel_array + 2], 0
            pinsrb xmm2, byte[pixel_array + 5], 4
        shufps xmm2, xmm2, 0b00010101
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
    cvtps2dq xmm0, xmm0
    pminsd xmm0, xmm6
        pextrb [result], xmm0, 0
        pextrb [result + 1], xmm0, 4
        pextrb [result + 2], xmm0, 8
        pextrb [result + 3], xmm0, 12
    ;За последнюю итерацию мы закончили обработку третьего пикселя и полностью обработали четвертый,
        ;поэтому, сдвигаемся на 2 пикселя, или 6 компонент.
    add pixel_array, 6
    add result, 4
    ;Если нам ещё есть что обрабатываем - повторяем цикл. Если нет, то выходим из цикла.
    sub array_size, 4
    jnz .loop
.end:
    pop r14
    pop r13
    pop r12
    ret
