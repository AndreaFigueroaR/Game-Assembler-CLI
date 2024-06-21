%include "llamadas.asm"

global main
extern system
extern recuperacionPartida
extern personalizarPartida
extern imprimirTablero
extern procesarComando
extern realizarJugada
extern resultadoJuego
extern imprimirMsgFinJuego
extern mostrarEstadisticas
extern guardarPartida
extern sscanf
; despues fijarnos que los extern coincidan con los nombres de las rutinas externas usadas

section .data
    
section .bss   
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

section .text
main:
;   INICIALIZACIÓN DEL JUEGO
    mRecuperacionPartida    infoOcas,               infoZorro,          jugadorActual,      rotacionTablero,    estadoPartida,  estadisticas
    personalizarPartida     infoOcas,               infoZorro,          rotacionTablero

continuarJugando:
    mClear
    imprimirTabla           infoOcas,               infoZorro,          rotacionTablero
    mProcesarComando        qword[jugadorActual],   coordenadasOrigen,  coordenadasDestino, estadoPartida,      infoZorro,      infoOcas
    cmp                     qword[estadoPartida],   3
    je                      partidaInterrumpida 
    mRealizarJugada          infoOcas,               posicionZorro,     infoCoordenadas,    jugadorActual,      estadisticas
    ;mActualizarEstadisticas                     ;realizarJugada dejarà la posicion anterior del jugador en turno en coordenadasOrigen y a donde se moviò en coordenadasDestino
    resultadoJuego          infoOcas,               infoZorro,          jugadorActual,      estadoPartida
    cmp                     qword[estadoPartida],    0
    je                      continuarJugando

partidaFinalizada:
    imprimirMsgFinJuego     estadoPartida
    mostrarEstadisticas     estadisticas
    ret
partidaInterrumpida:
    mGuardarPartida
    ret

