%include "llamadas.asm"

global main

section .data
    
section .bss   
    dirInfoOcas             times 18 resq 2      ; dirInfoOcas es la direccion a un vector de la forma: [cantidadOcasVivas, simboloOcas, posFilOca1, posColOca1, ..., posFilOcaN, posColOcaN], donde 0 <= N <= 17
    dirInfoZorro            times 3 resq 1       ; dirInfoZorro es la direccion a un vector de la forma: [simboloZorro, posFilZorro, posColZorro]
    dirComando              resq 1               ; Dirección al comando ingresado por el usuario
    dirJugadorActual        resq 1               ; Dir al valor del jugador actual. 0 -> turno del zorro, 1 -> turno de las ocas.
    dirRotacionTablero      resq 1               ; Dir al valor de rotacion de la tabla en sentido antihorario. 0 -> 0º, 1 -> 90º, 2 -> 180º, 3 -> 250º
    dirEstadoPartida        resq 1               ; Dir al valor del estado de la partida. 0 -> partidaActiva, 1 -> partida terminada: ganó el Zorro, 2 -> partida terminada: ganaron las ocas, 3 -> partida interrumpida
    dirEstadisticas         times 8 resb 1       ; Dir al vector donde cada posicion corresponde a la cantidad de movimientos en cada direccion: [arriba, abajo, izq, der, arriba-izq, arriba-der, abajo-izq, abajo-der]

section .text
main:
;   INICIALIZACIÓN DEL JUEGO
    recuperacionPartida     dirInfoOcas, dirInfoZorro, dirJugadorActual, dirRotacionTablero, dirEstadoPartida, dirEstadisticas
    personalizarPartida     dirInfoOcas, dirInfoZorro, dirRotacionTablero

continuarJugando:
    mClear
    imprimirTabla           dirInfoOcas, dirInfoZorro, dirRotacionTablero
    mGets                   dirComando
    realizarJugada          dirInfoOcas, dirInfoZorro, dirComando, dirJugadorActual, dirEstadisticas
    resultadoJuego          dirInfoOcas, dirInfoZorro, dirJugadorActual, dirEstadoPartida
    cmp                     byte[dirEstadoPartida],0
    je                      continuarJugando

;   FIN DEL JUEGO
    imprimirMsgFinJuego     dirEstadoPartida
    mostrarEstadisticas     dirEstadisticas

    ret
