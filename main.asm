%include "llamadas.asm"

global main

section .data
    
section .bss   
    infoOcas                times 18 resq 2      ; infoOcas es un vector de la forma: [cantidadOcasVivas, simboloOcas, posFilOca1, posColOca1, ..., posFilOcaN, posColOcaN], donde 0 <= N <= 17
    infoZorro               times 3 resq 1       ; infoZorro es un vector de la forma: [simboloZorro, posFilZorro, posColZorro]
    comando                 resq 1               ; Comando ingresado por el usuario
    jugadorActual           resq 1               ; Valor del jugador actual. 0 -> turno del zorro, 1 -> turno de las ocas.
    rotacionTablero         resq 1               ; Valor de rotacion de la tabla en sentido antihorario. 0 -> 0º, 1 -> 90º, 2 -> 180º, 3 -> 250º
    estadoPartida           resq 1               ; Valor del estado de la partida. 0 -> partidaActiva, 1 -> partida terminada: ganó el Zorro, 2 -> partida terminada: ganaron las ocas, 3 -> partida interrumpida
    estadisticas            times 8 resq 1       ; Vector donde cada posicion corresponde a la cantidad de movimientos en cada direccion: [arriba, abajo, izq, der, arriba-izq, arriba-der, abajo-izq, abajo-der]

section .text
main:
;   INICIALIZACIÓN DEL JUEGO
    recuperacionPartida     infoOcas, infoZorro, jugadorActual, rotacionTablero, estadoPartida, estadisticas
    personalizarPartida     infoOcas, infoZorro, rotacionTablero

continuarJugando:
    mClear
    imprimirTabla           infoOcas, infoZorro, rotacionTablero
    mGets                   comando
    realizarJugada          infoOcas, infoZorro, comando, jugadorActual, estadisticas
    resultadoJuego          infoOcas, infoZorro, jugadorActual, estadoPartida
    cmp                     byte[estadoPartida],0
    je                      continuarJugando

;   FIN DEL JUEGO
    imprimirMsgFinJuego     estadoPartida
    mostrarEstadisticas     estadisticas

    ret
