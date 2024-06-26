%include "macros.asm"

global main

extern imprimirTablero
extern procesarComando
extern realizarJugada
extern system
extern printf
;###################################################
extern recuperacionPartida
extern personalizarPartida
extern actualizarEstadisticas
extern resultadoJuego
extern mostrarEstadisticas
extern guardarPartida
extern sscanf
extern gets
extern strcmp
;###################################################

section     .data
    
section     .bss    
    infoOcas                times 18 resq 2      ; infoOcas es un vector de la forma: [cantidadOcasVivas, simboloOcas, posFilOca1, posColOca1, ..., posFilOcaN, posColOcaN], donde 0 <= N <= 17
    infoZorro               times 0  resb        ; infoZorro es un vector de la forma: [simboloZorro, posFilZorro, posColZorro]
        simboloZorro                 resq 1
        posicionZorro       times 1  resq 2              
    jugadorActual                    resq 1      ; Valor del jugador actual. 0 -> turno del zorro, 1 -> turno de las ocas.
    rotacionTablero                  resq 1      ; Valor de rotacion de la tabla en sentido antihorario. 0 -> 0º, 1 -> 90º, 2 -> 180º, 3 -> 250º
    estadoPartida                    resq 1      ; Valor del estado de la partida. 0 -> partidaActiva, 1 -> partida terminada: ganó el Zorro, 2 -> partida terminada: ganaron las ocas, 3 -> partida interrumpida
    estadisticas            times 8  resq 1      ; Vector donde cada posicion corresponde a la cantidad de movimientos en cada direccion: [arriba, abajo, izq, der, arriba-izq, arriba-der, abajo-izq, abajo-der]
    infoCoordenadas         times 0  resb        ; Vector de la forma: [filOrigen, colOrigen, filDestino,colDestino]
        coordenadasOrigen            resq 2
        coordenadasDestino           resq 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                             CÓDIGO FUENTE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section     .text
main:
;   INICIALIZACIÓN DEL JUEGO
    mRecuperacionPartida    infoOcas,               infoZorro,          jugadorActual,      rotacionTablero,    estadoPartida,  estadisticas
    mPersonalizarPartida    infoZorro,              infoOcas,           rotacionTablero

continuarJugando:
    mClear
    mMostrarAcciones
    mImprimirTabla          infoOcas,               infoZorro,          rotacionTablero
    mProcesarComando        qword[jugadorActual],   infoCoordenadas,    estadisticas,       estadoPartida,      infoOcas,       rotacionTablero  
    cmp                     qword[estadoPartida],   3
    je                      partidaInterrumpida 
    
    mov                     rax,[jugadorActual]
    cmp                     rax,0
    jne                     continuar
    mActualizarEstadisticas estadisticas,           coordenadasOrigen,  coordenadasDestino
    
    continuar:
    mRealizarJugada         infoOcas,               posicionZorro,      infoCoordenadas,    jugadorActual,     estadoPartida
    cmp                     qword[estadoPartida],    0
    je                      continuarJugando

partidaFinalizada:
    mClear    
    imprimirMsgFinJuego     estadoPartida
    mMostrarEstadisticas    estadisticas
    ret
    
partidaInterrumpida:
    mGuardarPartida         infoOcas,               infoZorro,          jugadorActual,      rotacionTablero,    estadoPartida,  estadisticas
    ret
