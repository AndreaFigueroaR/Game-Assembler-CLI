
%macro  guardarDatos 0
    mov     [dirInfoOcas],          rdi
    mov     [dirPosicionZorro],     rsi
    mov     [dirJugadorActual],     rcx
    mov     r9,                     [rcx]
    mov     [juagadorActual],       r9
    mov     [dirEstadisticas],      r8
    ;guardando coordenadas
    mov         [dirBaseVector],rdx
    mov         qword[cantElemVector],4
    mov         qword[dirDestinoVector],infoCoordenadas

    sub         rsp,8
    call        guardarVector
    add         rsp,8

%endmacro