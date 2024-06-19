global imprimirTablero
extern printf
extern puts
%macro cambiarSimbA 1
    mov     r8,%1
    mov     [punteroSimb],r8
%endmacro
%macro esPar? 1
    ;recibe rótulo que guarda el número
    ;carga el número
    mov     rax,[%1]
    ;verifica el menos significativo
    and     rax,1
    mov     [esPar],rax
%endmacro
%macro mostrarSimb 0
    mov     rdi,formato
    mov     rsi,[punteroSimb]
    sub     rsp,8
    call    printf
    add     rsp,8 
%endmacro

%macro ponerPuts 0
    sub     rsp,8
    call    puts
    add     rsp,8 
%endmacro
%macro mostrarUbiFilYActualizar 0
    ;PRE: ubiFil debe ser la fila actual
    ;POST: muestra ubiFil y lo incrementa
    mov     rdi,formatoUbiFil
    mov     rsi,[ubiFil]
    sub     rsp,8
    call    printf
    add     rsp,8
    inc     qword[ubiFil]
%endmacro

section     .data
    formato         db  "%s",0
    despl           dq  0
    pared           db  "#",0
    salto           db  10,0
    espacio         db  " ",0
    zorro           db  "X",0
    fil             dq  1
    col             dq  1
    ubiCol          db  "   A B C D E F G",0
    formatoUbiFil   db  "%hhi ",0
    ubiFil          dq  1

section     .bss
    punteroSimb     resb    4   ;4 bytes para un puntero
    esPar           resq    1   ;0 si es par, 1 si es impar    

section     .text
imprimirTablero:
_mostrarUbiCol:
    mov             rdi,ubiCol
    ponerPuts
    ;espacio adicional para mostrar ubiFil al lateral
    cambiarSimbA espacio
    mostrarSimb
    mostrarSimb                ;doble espacio para separar el tablero de ubiFil
_mostrarSimbSiguiente:
    cmp     qword[despl],225    ;tamaño real 15
    je      fin
    sub     rsp,8
    call    actualizarIndices
    add     rsp,8

    cambiarSimbA espacio
    esPar?  fil
    ;si es fila impar=>cambia a pared y quizás a espacio
    cmp     qword[esPar],0
    jne     _cambiarAPared
    esPar?  col
    je      _imprimirSimb

    _cambiarAPared:
    cambiarSimbA    pared
    sub     rsp,8
    call    convertirACruz
    add     rsp,8

    _imprimirSimb:
    mostrarSimb

    inc     qword[col]
    inc     qword[despl]
    jmp     _mostrarSimbSiguiente
fin:
    cambiarSimbA    salto
    mostrarSimb
ret
;_________________RUTINAS INTERNAS_________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

actualizarIndices:
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
