%macro cambiarSimbA 1
    ;cambia a què apunta punteroSimb al ròtulo recibido
    mov     r8,%1
    mov     [punteroSimb],r8
%endmacro
%macro esPar? 1
    mov     rax,[%1]
    ;verifica el menos significativo
    and     rax,1
    mov     [esPar],rax
%endmacro
%macro mostrarSimb 0
    ;muestra el simbolo apuntado en punteroSimb
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
%macro mostrarUbiCol 0
    mov             rdi,ubiCol
    ponerPuts
    cambiarSimbA    espacio     ;espacio adicional para mostrar ubiFil al lateral
    mostrarSimb                 ;doble espacio para separar el tablero de ubiFil
    mostrarSimb 
%endmacro

%macro guardarEstadoJuego 0
    ;POST: guardar todos los vectores recibidos por registros RDI y RSI
    mov         [rotacionTablero],rdx
    
    mov         [dirBaseVector],rdi
    mov         qword[cantElemVector],36
    mov         qword[dirDestinoVector],infoOcas
    sub         rsp,8
    call        guardarVector
    add         rsp,8

    mov         [dirBaseVector],rsi
    mov         qword[cantElemVector],3
    mov         qword[dirDestinoVector],infoZorro
    sub         rsp,8
    call        guardarVector
    add         rsp,8
%endmacro