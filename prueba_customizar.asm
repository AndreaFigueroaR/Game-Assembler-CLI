global main
extern CustomizeGame
extern puts

%macro callCustomizeGame 3
    ;Pre: Recibe las direcciones de memoria para modificar: [DirSimboloZorro, DirSimboloOcas, DirRotacionTablero]
    ;Post: pregunta si se quiere customizar cada uno de los elementos que contienen las direcciones recibidas
    ;      si el usuario decide cambiar alguno se cambia, si no se deja como està

; aca yo tengo una duda, ya que yo entiendo que el programa lo hace directamente que nosotros no debemos hacer esto, pero deberiamos guardarnos con variables la direccion de memoria
    mov     rdi, %1
    mov     rsi, %2
    mov     rdx, %3

    sub     rsp,8
    call    CustomizeGame
    add     rsp,8
%endmacro

%macro mPuts 0
    sub     rsp,8
    call    puts
    add     rsp,8 
%endmacro


section .bss
    zorro       resb    1
    oca         resb    1
    orientacion resb    1

section .text:
main:
    mov     rdi, "inicio"
    mPuts
    ;callCustomizeGame zorro, oca, orientacion

    ret
