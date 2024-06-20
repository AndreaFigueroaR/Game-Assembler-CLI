%include "macros_cruz.asm"
global imprimirTablero
extern printf
extern puts

section     .data
    ;movimientos en la matriz
    despl           dq  0
    fil             dq  1
    col             dq  1
    ;impresiòn del tablero
    formato         db  "%s",0
    pared           db  "#",0
    salto           db  10,0
    espacio         db  " ",0
    ubiCol          db  "   A B C D E F G",0
    formatoUbiFil   db  "%hhi ",0
    ubiFil          dq  1

section     .bss   
    infoOcas                    times 0 resb            
        cantOcasVivas           resq    1
        simboloOcas             resq    1
        posicionesOcas          times   17  resq    2
    infoZorro                   times 0 resb 
        simboloZorro            resq    1
        posicionZorro           times   1   resq    2
    rotacionTablero         resq    1   ;0ª->1,270ª->2,90ª->-1,180ª->-2
        
    ;auxiliares de impresion
    esPar               resq    1   ;0 si es par, 1 si es impar
    punteroSimb         resq    1   ;4 bytes para un puntero
    desplazVector       resq    1
    cantElemVector      resq    1
    dirBaseVector       resq    1
    dirDestinoVector    resq    1

section     .text
imprimirTablero:
    guardarEstadoJuego
    mostrarUbiCol
_mostrarSimbSiguiente:
    cmp             qword[despl],225    ;tamaño real 15
    je              fin

    sub             rsp,8
    call            actualizarIndicesMostrarUbiFil
    add             rsp,8

    cambiarSimbA espacio
    esPar?          fil
    ;si es fila impar=>cambia a pared y quizás a espacio
    cmp             qword[esPar],0
    jne             _cambiarAPared
    esPar?          col
    je              _imprimirSimb

    _cambiarAPared:
    cambiarSimbA    pared
    sub             rsp,8
    call            convertirACruz
    add             rsp,8

    _imprimirSimb:
    mostrarSimb

    inc             qword[col]
    inc             qword[despl]
    jmp             _mostrarSimbSiguiente
fin:
    cambiarSimbA    salto
    mostrarSimb
    
ret

;_________________RUTINAS INTERNAS_________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rotarPosiciones:
    ;calculo Opciones (digamos del zorro)
    mov     r9,0
    mov     r10,[posicionZorro+r9]  ;fil
    add     r9,8
    mov     r11,[posicionZorro+r9]  ;col
    sub     r9,8

    cmp     qword[rotacionTablero],0
    je      finRotacion
    mov     rcx,[rotacionTablero]

    _starLoop:
    mov     r12,r11
    mov     r11,8
    sub     r11,r10
    mov     r10,r12
    loop    _starLoop

    finRotacion:
    imul    r10,2
    imul    r11,2
    mov     [posicionZorro+r9],r10
    add     r9,8
    mov     [posicionZorro+r9],r11
    ret

convertirACruz:
    cmp     qword[fil],11
    jg      arribaOAbajo
    ;es lado superior?
    cmp     qword[fil],5
    jl      arribaOAbajo
    esPreciso:
    ret

    arribaOAbajo:;fil>11 o fil<5
    cmp     qword[col],11
    jg      actualizarAEspacio
    cmp     qword[col],5
    jl      actualizarAEspacio
    jmp     esPreciso

    actualizarAEspacio:
    cambiarSimbA    espacio
    jmp             esPreciso  

actualizarIndicesMostrarUbiFil:
    cmp     qword[col],16;cmp si reinicia col (tamaño real 15)
    jne     actualizarFil
    mov     qword[col],1
    actualizarFil:
    imul            r8,qword[fil],15
    cmp             r8,[despl]
    jne             finIndices
    inc             qword[fil]
    cambiarSimbA    salto
    mostrarSimb
    sub     rsp,8
    call    imprimirUbiFil
    add     rsp,8

    finIndices:
    ret

imprimirUbiFil:
    cmp     qword[col],1
    jne     regresarUbiFil
    esPar?   fil
    cmp     qword[esPar],0        
    jne     imprimirEspacio      ;si es impar muestra espacio
    mostrarUbiFilYActualizar     ;si es par muestra ubiFil y actualiza
    jmp     regresarUbiFil

    imprimirEspacio:
    cambiarSimbA    espacio
    mostrarSimb
    mostrarSimb                ;doble espacio para separar el tablero de ubiFil
   
    regresarUbiFil:
    ret

guardarVector:
    ;PRE: cantElemVector, dirBaseVector, dirDestinoVector inicializados
    mov         qword[desplazVector],0
    mov         r10,[desplazVector]
    mov         r9,qword[cantElemVector]
    copiarSgt:
    cmp         qword[cantElemVector],0
    je          endCopiado

    mov         r10,[desplazVector]
    mov         rdi,[dirBaseVector]
    mov         rax,[rdi+r10]
    mov         rbx,[dirDestinoVector]
    mov         [rbx+r10],rax

    add         qword[desplazVector],8
    dec         qword[cantElemVector]
    jmp         copiarSgt
    endCopiado:
    ret
