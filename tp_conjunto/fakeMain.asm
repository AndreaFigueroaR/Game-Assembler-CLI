 ;para compilar y ejecutar:

;   nasm realizarJugada.asm -f elf64
;   nasm procesarEntrada.asm -f elf64
;   nasm printCruz.asm -f elf64
;   nasm fakeMain.asm -f elf64
;   gcc realizarJugada.o procesarEntrada.o printCruz.o fakeMain.o -o a.out -no-pie
;   ./a.out

%include "macros.asm"

global main

extern imprimirTablero
extern procesarComando
extern realizarJugada
extern system
extern printf


section     .data
    infoOcas                    dq                  17,                                         ; cantidadOcasVivas
    simboloOcas                 dq                  "O",                                        ; simboloOcas
                                dq                  1, 3, 5,4, 1, 5                            ; Ocas de la fila 1 (en las columnas 3, 4 y 5)
                                dq                  2, 3, 2, 4, 2, 5                            ; Ocas de la fila 2 (en las columnas 3, 4 y 5)
                                dq                  3, 1, 3, 2, 3, 3, 4, 4, 3, 5, 3, 6, 3, 7    ; Ocas de la fila 3 (en las columnas 1, 2, 3, 4, 5, 6 y 7)
                                dq                  4, 1, 4, 7                                  ; Ocas de la fila 4 (en las columnas 1 y 7)
                                dq                  5, 1, 5, 7                                  ; Ocas de la fila 5 (en las columnas 1 y 7)
    infoZorro                   dq                  "X"                                        ; simboloZorro
        posicionZorro           dq                  1, 4                                        ; Zorro en la fila 5 y columna 4
    jugadorActual               dq                  1                                           ; Jugador actual -> Zorro 1
    rotacionTablero             dq                  0
    estadoPartida               dq                  0                                           ; Partida activa

section     .bss    
    estadisticas            times 8  resq 1      ; Vector donde cada posicion corresponde a la cantidad de movimientos en cada direccion: [arriba, abajo, izq, der, arriba-izq, arriba-der, abajo-izq, abajo-der]
    infoCoordenadas         times 0  resb        ; Vector de la forma: [filOrigen, colOrigen, filDestino,colDestino]
        coordenadasOrigen            resq 2
        coordenadasDestino           resq 2

section     .text

main:
    
    mMostrarAcciones
    continuarJugando:
    cmp                     qword[estadoPartida],    0
    jne                     finJuego

    mImprimirTabla          infoOcas,               infoZorro,          rotacionTablero
    mProcesarComando        qword[jugadorActual],   infoCoordenadas,    estadisticas,       estadoPartida,      infoOcas,       rotacionTablero

    mRealizarJugada         infoOcas,               posicionZorro,      infoCoordenadas,    jugadorActual,      estadoPartida

    jmp continuarJugando

finJuego:

    ret


    