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
    compararInput                   comandoInterrupcion     ;->¿Se esta indicando que se quiere interrumpir la partida?
    cmp     EAX,                    0 
    jne     validarGuardarPartida                           ;-> si no se prosigue a comparar si se està tratando de unicamente guardar la partida
    mov     RAX,                    [dirEstadoPartida]      ;-> si sì se cambia el estado de la partida 3->partida interrumpida 
    mov     qword[RAX],             3
    apruebaValidacionTotal                                  ;->se cambia inputValido a 'S' y se pasa al fin de la validacion

validarGuardarPartida:
    compararInput                   comandoGuardar          ;->¿Se esta indicando que se quiere guardar la partida?
    cmp     EAX,                    0
    jne     validarFormatoMovimiento                        ;-> si no se prosigue a validar si es algun movimiento valido del jugador actual
                                                            ;-> si sì se guarda la partida y se vuelve a pedir alguna accion a realizar  
    mGuardarPartida     [dirInfoOcas],  [dirInfoZorro], jugadorActual, [dirRotacion], [dirEstadoPartida], [dirEstadisticas]  
    jmp     pedirInput

validarFormatoMovimiento:
    cmp     qword[jugadorActual],   0                       ;-> segun el jugador actual se valida el formato del input (que deberia ser un movimiento de tipo '4E' )
    je      movimientoZorro

movimientoOca:
    setParametrosScanOrigenYDestino                         ;-> guardo en los registros las direcciones del formato de un movimiento de una oca, direccion donde dejar las coordenadas X e Y de origen y las de las coordenadas X e Y de destino
    mSscanf                                                 ;-> se transforman las coordenadas numericas a un numeros y las alfabeticas se dejan contiguas en memoria  
    cmp     EAX,                4                           ;-> valido la cantidad de conversiones exitosas (2 valores numericos y dos chares)
    jne     finValidacion
    chequearPosEnCruz           [dirPosicionOrigen]         ;-> valido que la coordenada de origen estè dentro de la cruz 
    chequearPosEnCruz           [dirPosicionDestino]        ;-> valido que la coordenada de destino estè dentro de la cruz 
    jmp     validacionLogicaMovOca                          ;-> termino con la validacion fisica del input y continuo para ver si es un movimiento valido

movimientoZorro:
    setParametrosScanDestino                                ;-> guardo en los registros las direcciones del formato de un movimiento de un zorro y las direcciones donde dejar las coordenadas X e Y de destino
    mSscanf                                                 ;-> se transforman las coordenadas numericas a un numeros y las alfabeticas se dejan contiguas en memoria 
    cmp     EAX,                2                           ;-> valido la cantidad de conversiones exitosas (1 valor numerico y 1 char)
    jne     finValidacion
    chequearPosEnCruz           [dirPosicionDestino]
    jmp     validacionLogicaMovZorro

validacionLogicaMovOca:
    traducirLetra               [dirPosicionOrigen]         ;-> piso chares con valor numerico correspondiente
    traducirLetra               [dirPosicionDestino]
    guardarDatosOrigenYDestino                              ;-> guardo una copia local de los numeros de las coordenadas (para facilitar los calculos)

    unaOcaEnOrigen                                          ;-> valido que exista una oca en la posicion de origen indicada
    sinOcasEnDestino                                        ;-> valido que no haya ya una oca ocupando la posicion de destino
    sinZorroEnDestino                                       ;-> valido que el zorro no estè en la posicion de destino
    movimientoAdelanteOCostado                              ;-> valido que el movimiento represente solo moverse adelante, a la izquierda o a la derecha (pasos simples)

validacionLogicaMovZorro:
    traducirLetra               [dirPosicionDestino]        ;-> piso chare de la coordenada de destino con valor numerico correspondiente
    actualizarPunteroOrigen                                 ;-> actualizo el puntero de la coordenada de origen con la ultima posicion del zorro
    guardarDatosOrigenYDestino                              ;-> guardo una copia local de los numeros de las coordenadas (para facilitar los calculos)
    
    sinOcasEnDestino                                        ;-> valido que no haya una oca ocupando la posicion de destino
    sinZorroEnDestino                                       ;-> el zorro no puede quedarse quieto
    movimientoSimpleOSalto                                  ;-> valido que sea un paso simple o que sea un salto con una oca en medio


finValidacion:
    cmp     byte[inputValido],  'N'
    je      fallaValidacion
    ret

fallaValidacion:
    mov     RDI,    mensajeInputInvalido
    mPuts
    jmp     pedirInput

