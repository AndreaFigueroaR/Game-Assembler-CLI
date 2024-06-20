%include "llamadas.asm"

global procesarComando
;parece que tendrìa que llevar a cabo la validacion Fisica, la validacion Logica de los movimientos
    ;(luego en realizar jugada se llevarà a cabo segun el valor del estadoPartida: guardarPartida o realizarMovimiento efectivamente)

section     .data
    ;mesnajes salida
    mensajePedirMovOca      db "MOVIMIENTO OCA: ",0
    mensajePedirMovZorro    db "MOVIMIENTO ZORRO: ",0
    mensajeInputInvalido    db "Error con la instruccion recibida, por favor, indique una accion valida",0; usado para cuando no tiene el formato de un movimiento del jugador actual o no representa el comando para interrumpir la partida
    
    ;variables auxiliares
    inputValido             db 'N'
    formatoInputMovOca      db "%c%li-%c%li",0
    formatoInputMovZorro    db "%c%li",0
    comandoInterrupcion     db "--guardar partida",0
    resCmp                  db 0;variable para guardar el resultado de la comparacion del resultado


section     .bss
    input                   resb 20;reservo 20 bytes para la entrada del imput
    ;AFECTADOS POR LA VALIDACION FISICA
    posicionOrigen          resq 2;(X,Y)
    posicionDestino         resq 2;los uso para al finalizar la validacionFisica poder comparar la concordancia con los datos del jugador activo y si sì se puede mover de/a donde se indica
    dirEstadoPartida        resq 1; puntero de donde se guarda el estado de la partida (para editarlo si se necesita)
    ;LOS QUE SE TIENEN QUE AFECTAR DESPUES DE LA VALIDACION LOGICA


section     .text

procesarComando:

    salvarParametros:;guardo los parametros recibidos en los registros: [jugadorActual,dirParOrigen, dirParDestino]
    mov [dir],
    mov [dirPosicionOrigen],
    mov [dirParOrigen],
    mov [dirEstadoPartida],

    lecturaInput:
        mov RDI,input
        mGets
    validacionFisica:
        ;voy a usar la funcion strcmp de C para verificar si el input es identico a este
        mov RDI, input
        mov RSI, comandoInterrupcion
        mStrcmp
        ;ahora se que el resultado de la comparacion està en el eax (4 bytes)
        jne 

    ;si despues de la validacion fisica se tiene que era una interrupciòn-> se CAMBIA EL ESTADO_PARTIDA=3
    interrupcionOmovimiento:
    ;si &estadoPartida !=3 -> salto hasta validacionLogica
    ;se llama a guardar las estadisticas
    ;se salta a la parte de 
    validacionLogicaMovimientos:

