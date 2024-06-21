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
    dirPosicionOrigen           resq 1;donde dejarà las coordenadas de origen
    dirPosicionDestino          resq 1;donde dejarà las coordenadas de destino
    dirEstadoPartida            resq 1 
    dirInfoZorro                resq 1
    dirInfoOcas                 resq 1


section     .text

procesarComando:
    mov [jugadorActual],        RDI
    mov [dirPosicionOrigen],    RSI
    mov [dirPosicionDestino],   RDX
    mov [dirEstadoPartida],     RCX
    mov [dirInfoZorro],         R8
    mov [dirInfoOcas],          R9

lecturaInput:

    ;muestro de quien es el turno:
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
    mov qword[RAX],         3              ;cambio estadoPartida

    apruebaValidacionTotal  ;pues era una interrupcion

validarFormatoMovimiento:
    cmp qword[jugadorActual],   0
    je  movimientoZorro
    movimientoOca:
        
        ;si falla alguna de las siguientes pruebas -> se lleva a finValidacion con la validacion en 'N'
        ;prueba 1.- al convertir el input al NumChar->NumChar se deben convertir exitosamente 4 variables
        mov     R8,     [dirPosicionOrigen]
        add     R8,     8
        mov     R9,     [dirPosicionDestino]
        add     R9,     8
        movParametros   input,  formatoMovimientoOca,   qword[dirPosicionOrigen],   R8,     qword[dirPosicionDestino],  R9
        mSscanf
        cmp     EAX,    4
        jne     finValidacion

        chequearPosicionEnTabla [dirPosicionOrigen];Le estoy pasando la direccion donde inicia el vector
        chequearPosicionEnTabla dirPosicionDestino

        


        ;si llega hasta aqui es que pasò la validacion del formato de movimiento de una oca
        ;y sè que los datos guardados en las variables deben ser los numeros posibles dentro del tablero
        jmp validacionLogicaMovOca;se continuan con màs validaciones
        
        
    movimientoZorro:


    jmp validacionLogicaMovZorro

validacionLogicaMovOca:

validacionLogicaMovZorro:

finValidacion:
    cmp byte[inputValido],  'N'
    je  lecturaInput
    ret

