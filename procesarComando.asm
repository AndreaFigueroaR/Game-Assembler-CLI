%include "llamadas.asm"
%include "macrosProcesarComando.asm"

;tildes Á, É,Í,Ó,Ú á,é,í,ó,ú
global procesarComando

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                             INICIALIZACION DATOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section     .data
    ;mensajes salida
    mensajePedirMovOca          db "* MOVIMIENTO DE LA OCA (origen) -> (destino) : ",0
    mensajePedirMovZorro        db "* MOVIMIENTO DEL ZORRO (destino) : ",0
    mensajeInputInvalido        db "Error en la instrucción recibida, por favor indique una accción válida.",0
    ;formato entrada
    formatoMovimientoOca        db "%li%c -> %li%c",0
    formatoMovimientoZorro      db "%li%c",0
    comandoInterrupcion         db "--interrumpir partida", 0
    comandoGuardar              db "--guardar partida",     0
    ;variables auxiliares
    inputValido                 db 'N'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                             RESERVA DE MEMORIA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section     .bss
    ;DATOS POR VALOR
    jugadorActual               resq    1 
    coordenadasOrigen           times   0   resb
        x_origen                            resq 1
        y_origen                            resq 1
    coordenadasDestino          times   0   resb     
        x_destino                           resq 1
        y_destino                           resq 1
    n_ocas                      resq    1
    input                       resb    20

    ;DATOS POR REFERENCIA
    dirPosicionOrigen           resq    1
    dirPosicionDestino          resq    1
    dirEstadoPartida            resq    1 
    dirInfoZorro                resq    1
    dirInfoOcas                 resq    1              
    dirEstadisticas             resq    1
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                             CODIGO FUENTE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section     .text

procesarComando:
    guardarParametros

pedirInput:
    pedirMovimiento

validarInterrupcion:
    compararInput                   comandoInterrupcion
    cmp     EAX,                    0
    jne     validarGuardarPartida
    mov     RAX,                    [dirEstadoJuego]
    mov     qword[RAX],             3
    apruebaValidacionTotal 

validarGuardarPartida:
    compararInput                   comandoGuardar
    cmp     EAX,                    0
    jne     validarFormatoMovimiento
    ;LLAMADA A GUARDAR ESTADISTICAS
    ;mActualizarEstadisticas [dirEstadisticas],;dirCoordOrigenZorro y dirCoordDestinoZorro? hay dif si envio punteros a las coordenadas de origen y de destino (del jugador actual)?
    jmp     pedirInput

validarFormatoMovimiento:
    cmp     qword[jugadorActual],   0
    je      movimientoZorro

movimientoOca:
    setParametrosScanOrigenYDestino
    mSscanf
    cmp     EAX,                4
    jne     finValidacion
    chequearPosEnCruz           [dirPosicionOrigen]
    chequearPosEnCruz           [dirPosicionDestino]
    jmp     validacionLogicaMovOca

movimientoZorro:
    setParametrosScanDestino
    mSscanf
    cmp     EAX,                2
    jne     finValidacion
    chequearPosEnCruz           [dirPosicionDestino]
    jmp     validacionLogicaMovZorro

validacionLogicaMovOca:
    traducirLetra               [dirPosicionOrigen]
    traducirLetra               [dirPosicionDestino]
    guardarDatosOrigenYDestino

    unaOcaEnOrigen
    sinOcasEnDestino
    sinZorroEnDestino
    movimientoAdelanteOCostado    

validacionLogicaMovZorro:
    traducirLetra               [dirPosicionDestino]
    actualizarPunteroOrigen
    guardarDatosOrigenYDestino
    
    sinOcasEnDestino
    sinZorroEnDestino
    movimientoSimpleOSalto    


finValidacion:
    cmp     byte[inputValido],  'N'
    je      fallaValidacion
    ret

fallaValidacion:
    mov     RDI,    mensajeInputInvalido
    mPuts
    jmp     pedirInput

