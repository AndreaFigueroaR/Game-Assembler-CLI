%include "llamadas.asm"

global main

section .data
    simboloZorro        db "X"  ;Se puede cambiar a otro simbolo reemplanzando el contenido por el simbolo ASCCI
    simboloOcas         db "O"  ;idem anterior
    rotacionTablero     db 0    ; 0->0º, 1->90º, 2->180º, 3-> 250º en sentido horario
    estadoPartida       db 0    ;0->nadie ganò, 1-> ganò


section .bss   
    cantidadOcasVivas   resb 1; tamaño a a discusiòn
    posicionesOcas      times 17 resb 1;[[0,1],[1,2],...], [X,Y] inicialmente con 17
    posicionZorro        
    posicionNueva      


section .text
main:
    callRecoverGame         posicionZorro,  posicionesOcas, cantidadOcasVivas,  rotacionTablero
    callCustomizeGame       simboloZorro,   simboloOcas,    rotacionTablero

    ;INICIA_PARTIDA
    ;bucle
    ;por què se interrumpe la partida: interrupciòn
    ;mostrar porque acabo la partida y quien ganò




;*****************************************************************************
;   RUTINAS INTERNAS
;*****************************************************************************

;*****************************************************************************

