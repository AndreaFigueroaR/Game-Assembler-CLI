%include "llamadas.asm"

global main

section .data
    simboloZorro        db "X" ;Se puede cambiar a otro simbolo reemplanzando el contenido por el simbolo ASCCI
    simboloOcas         db "O" ;idem anterior
    rotacionTablero     db 0  ; 0->0º, 1->90º, 2->180º, 3-> 250º
    estado


section .bss   
    cantidadOcasVivas   resb 1; tamaño a a discusiòn
    posicionesOcas      times 17 resb 1;["C0","D0",...] inicialmente con 17
    posicionZorro       


section .text
main:
    callRecoverGame         posicionZorro,  posicionesOcas, cantidadOcasVivas,  rotacionTablero
    callCustomizeGame       simboloZorro,   simboloOcas,    rotacionTablero

    ;INICIA_PARTIDA




;*****************************************************************************
;   RUTINAS INTERNAS
;*****************************************************************************

;*****************************************************************************

