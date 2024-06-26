%include "macros.asm"

extern sscanf
extern puts
extern printf
extern gets
extern strcmp

extern guardarPartida

global procesarComando


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                             INICIALIZACIÓN DATOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section     .data
    ;mensajes salida
    mensajePedirMovOca              db "*****************************************************************",10,"* MOVIMIENTO DE LA OCA (origen->destino): ",0
    mensajePedirMovZorro            db "*****************************************************************",10,"* MOVIMIENTO DEL ZORRO (destino): ",0
    mensajeInputInvalido            db "Error en la instrucción recibida, por favor indique una accción válida.",0
    ;formato entrada
    formatoMovimientoOca            db "%li%c->%li%c",0
    formatoMovimientoZorro          db "%li%c",0
    comandoInterrupcion             db "--interrumpir partida", 0
    comandoGuardar                  db "--guardar partida",     0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                             RESERVA DE MEMORIA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section     .bss
    ;DATOS POR VALOR
    jugadorActual                   resq    1 
    coordenadasOrige    times   0   resb
        x_origen                    resq    1
        y_origen                    resq    1
    coordenadasDestino  times   0   resb     
        x_destino                   resq    1
        y_destino                   resq    1
    n_ocas                          resq    1
    input                           resb    100
    inputValido                     resb    'N'

    ;DATOS POR REFERENCIA
    dirPosicionOrigen               resq    1
    dirPosicionDestino              resq    1
    dirEstadoPartida                resq    1 
    dirInfoZorro                    resq    1
    dirInfoOcas                     resq    1              
    dirEstadisticas                 resq    1
    dirRotacion                     resq    1
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                             CÓDIGO FUENTE
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
    mov     RAX,                    [dirEstadoPartida]
    mov     qword[RAX],             3
    apruebaValidacionTotal 

validarGuardarPartida:
    compararInput                   comandoGuardar
    cmp     EAX,                    0
    jne     validarFormatoMovimiento
    ;llamada a guardar estadisticas 
    mGuardarPartida     [dirInfoOcas],  [dirInfoZorro], jugadorActual, [dirRotacion], [dirEstadoPartida], [dirEstadisticas]
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

