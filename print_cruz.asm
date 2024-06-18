global main
extern printf
extern puts
%macro changeSimbTo 1
    mov     r8,%1
    mov     [simbPointer],r8
%endmacro
%macro even? 1
    ;recibe ròtulo que guarda el num
    ;carga num
    mov     rax,[%1]
    ;verifica menos significativo
    and     rax,1
    mov     [isEven],rax
%endmacro
%macro showSimb 0
    mov     rdi,form
    mov     rsi,[simbPointer]
    sub     rsp,8
    call    printf
    add     rsp,8 
%endmacro

%macro mPuts 0
    sub     rsp,8
    call    puts
    add     rsp,8 
%endmacro
%macro showUbiFilAndUpdate 0
    ;PRE: ubiFil debe ser la fila actual
    ;POST: muestra ubiFil y lo incrementa
    mov     rdi,formatUbiFil
    mov     rsi,[ubiFil]
    sub     rsp,8
    call    printf
    add     rsp,8
    inc     qword[ubiFil]
%endmacro

section     .data
    form            db  "%s",0
    despl           dq  0
    wall            db  "#",0
    salto           db  10,0
    space           db  " ",0
    zorro           db  "X",0
    fil             dq  1
    col             dq  1
    ubiCol          db  "   A B C D E F G",0
    formatUbiFil    db  "%hhi ",0
    ubiFil          dq  1

section     .bss
    simbPointer     resb    4   ;4 bytes para un puntero
    isEven          resq    1   ;0 si es par 1 si es impar    

section     .text
main:
_showUbiFil:
    mov             rdi,ubiCol
    mPuts
    ;espacio adicional para mostrar ubiFil al lateral
    changeSimbTo space
    showSimb
    showSimb                ;doble espacio para separar tablero de ubiFil
_showNextSimb:
    cmp     qword[despl],225    ;tam real 15
    je      fin
    sub     rsp,8
    call    actIndices
    add     rsp,8

    changeSimbTo space
    even?   fil
    ;si es fil impar=>cambia a pared y quizàs a espacio
    cmp     qword[isEven],0
    jne     _changeWall
    even?   col
    je      _printSimb

    _changeWall:
    changeSimbTo    wall
    sub     rsp,8
    call    convertToCross
    add     rsp,8

    _printSimb:
    showSimb

    inc     qword[col]
    inc     qword[despl]
    jmp     _showNextSimb
fin:
    changeSimbTo    salto
    showSimb
ret
;_________________RUTINAS INTERNAS_________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

convertToCross:
    cmp     qword[fil],11
    jg      topOrBottom
    ;es topside?
    cmp     qword[fil],5
    jl      topOrBottom
    itsAccurate:
    ret

    topOrBottom:;fil>11 or fil<5
    cmp     qword[col],11
    jg      updatingToSpace
    cmp     qword[col],5
    jl      updatingToSpace
    jmp     itsAccurate

    updatingToSpace:
    changeSimbTo    space
    jmp             itsAccurate   

actIndices:
    cmp     qword[col],16;cmp si reinicia col (tam real 15)
    jne     actFil
    mov     qword[col],1
    actFil:
    imul            r8,qword[fil],15
    cmp             r8,[despl]
    jne             finIndices
    inc             qword[fil]
    changeSimbTo    salto
    showSimb
    sub     rsp,8
    call    printUbiFil
    add     rsp,8

    finIndices:
    ret

printUbiFil:
    cmp     qword[col],1
    jne     getBackUbiFil
    even?   fil
    cmp     qword[isEven],0        
    jne     printSpace      ;si es impar muestra espacio
    showUbiFilAndUpdate     ;si es par muestra ubiFil y actualiza
    jmp     getBackUbiFil

    printSpace:
    changeSimbTo    space
    showSimb
    showSimb                ;doble espacio para separar tablero de ubiFil
    
    getBackUbiFil:
    ret
