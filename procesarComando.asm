%include "llamadas.asm"
%include "macrosProcesarComando.asm"


global procesarComando

section     .data
    ;mensajes salida
    mensajePedirMovOca      db "MOVIMIENTO OCA: ",0
    mensajePedirMovZorro    db "MOVIMIENTO ZORRO: ",0
    mensajeInputInvalido    db "Error con la instruccion recibida, por favor indique una accion valida.",0; usado para cuando no tiene el formato de un movimiento del jugador actual o no representa el comando para interrumpir la partida
    
    ;variables auxiliares
    inputValido                 db 'N'
    formatoMovimientoOca        db "%li%c->%li%c",0
    formatoMovimientoZorro      db "%li%c",0
    comandoInterrupcion         db "--guardar partida",0

section     .bss
    input                       resb 20;reservo 20 bytes para la entrada del imput
    ;PARAMETROS SALVADOS
    jugadorActual               resq 1; Valor del jugador actual. 0 -> turno del zorro, 1 -> turno de las ocas.
    dirPosicionOrigen           resq 1; donde dejarà las coordenadas de origen
    dirPosicionDestino          resq 1; donde dejarà las coordenadas de destino
    dirEstadoPartida            resq 1 
    dirInfoZorro                resq 1
    dirInfoOcas                 resq 1; infoOcas es un vector de la forma:
    ;                                   [cantidadOcasVivas, simboloOcas, posFilOca1, posColOca1, ..., posFilOcaN, posColOcaN], donde 0 <= N <= 17


section     .text

procesarComando:
    
    mov [jugadorActual],        RDI
    mov [dirPosicionOrigen],    RSI
    mov [dirPosicionDestino],   RDX
    mov [dirEstadoPartida],     RCX
    mov [dirInfoZorro],         R8
    mov [dirInfoOcas],          R9

lecturaInput:

    mov RDI,mensajePedirMovZorro
    cmp qword[jugadorActual],0
    je mostrarTurno
    mov RDI,mensajePedirMovOca
    mostrarTurno:
    mPuts

    mov RDI,                input
    mGets

validacionInterrupcion:
    mov RDI,                input
    mov RSI,                comandoInterrupcion
    mStrcmp
    cmp EAX,                0
    jne                     validarFormatoMovimiento
    mov RAX,                [dirEstadoJuego]
    mov qword[RAX],         3

    apruebaValidacionTotal  

validarFormatoMovimiento:
    cmp         qword[jugadorActual],   0
    je          movimientoZorro

    movimientoOca:
        mov     R8,             [dirPosicionOrigen]
        add     R8,     8
        mov     R9,             [dirPosicionDestino]
        add     R9,     8
        movSeisParametros       input,  formatoMovimientoOca,   qword[dirPosicionOrigen],   R8,     qword[dirPosicionDestino],  R9
        mSscanf
        cmp     EAX,    4
        jne     finValidacion

        chequearPosicionEnTabla [dirPosicionOrigen]
        chequearPosicionEnTabla [dirPosicionDestino]

        jmp validacionLogicaMovOca
    movimientoZorro:
        mov     R9,             [dirPosicionDestino]
        add     R9,     8
        movCuatroParametros     input,  formatoMovimientoOca,   qword[dirPosicionDestino],  R9
        mSscanf
        cmp     EAX,    2
        jne     finValidacion

        chequearPosicionEnTabla [dirPosicionDestino]
        jmp     validacionLogicaMovZorro

validacionLogicaMovOca:
    traducirLetra   [dirPosicionOrigen]
    traducirLetra   [dirPosicionDestino]
    ;1.-verificar que hay una oca con las mismas coordenadas de origen
    mov     RSI,    [dirInfoOcas]
    mov     RDI,    RSI                 ;RDI contiene la direccion donde esta el numero (qword) de ocas vivas
    add     RSI,    16                  ;RSI contiene la direccion de inicio del vector
    
    mov     R8,     [dirPosicionOrigen]
    mov     R9,     [R8]                ;R9 contiene X buscado
    mov     R10,    [R8+8]              ;R10 contiene Y buscado    
    buscarOcasEnPosicion    RSI,    qword[RDI],     R9,     R10,    1

    cmp RAX,1
    jne finValidacion
    
    ;2.-validar que hayan cero personajes en la posicion destino
    ;ocas
    mov     RDI,    [dirInfoOcas]              
    mov     R8,     [dirPosicionDestino]
    mov     R9,     [R8]                ;R9 contiene X buscado
    mov     R10,    [R8+8]              ;R10 contiene Y buscado 
    buscarOcaEnPosicion     RSI,    qword[RDI],     R9,     R10,    1
    cmp RAX,0
    jne finValidacion

    validarAnvance:;se trata de ver que la oca solo se estè moviendo de

validacionLogicaMovZorro:
    traducirLetra [dirPosicionDestino]
    ;no olvidar iniciarlizar posicionOrigen con la posicion que indica el vector de info del zorro


finValidacion:
    cmp     byte[inputValido],      'N'
    je      fallaValidacion
    ret

fallaValidacion:
    mov     RDI,    mensajeInputInvalido
    mPuts
    jmp     lecturaInput

