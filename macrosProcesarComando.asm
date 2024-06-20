macrosProcesarComando.asm
;*****************************************************************************
; MACROS PARA VALIDACION DE DATOS
;*****************************************************************************
;usada solo cuando: se corrroborò que era una interrupciòn o era movimiento del jugador actual que pasò validacion fisica y logica
%macro apruebaValidacionTotal 0
    mov byte[inputValido],  'S'
    jmp finValidacion
%endmacro

%macro movimientoParametros 6
    mov RDI,    %1
    mov RSI,    %2;
    mov RDX,    %3;
    mov RCX,    %4;
    mov R8,     %5;
    mov R9,     %6;
%endmacro

%macro dirConValorEnRango 3
    mov R8,%1
    cmp qword[R8],%2
    jl finValidacion
    cmp qword[R8],%3
    jg finValidacion
%endmacro
;*****************************************************************************
