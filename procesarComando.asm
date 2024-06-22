%include "llamadas.asm"
%include "macrosProcesarComando.asm"


global procesarComando

section     .data
    ;mensajes salida
    mensajePedirMovOca      db "MOVIMIENTO OCA: ",0
    mensajePedirMovZorro    db "MOVIMIENTO ZORRO: ",0
    mensajeInputInvalido    db "Error con la instruccion recibida, por favor indique una accion valida.",0; usado para cuando no tiene el formato de un movimiento del jugador actual o no representa el comando para interrumpir la partida
    ;formato entrada
    formatoMovimientoOca        db "%li%c->%li%c",0
    formatoMovimientoZorro      db "%li%c",0
    comandoInterrupcion         db "--interrumpir partida", 0
    comandoGuardar              db "--guardar partida",     0

    ;variables auxiliares
    inputValido                 db 'N'
    

section     .bss
    input                       resb 20;reservo 20 bytes para la entrada del imput
    ;DATOS POR VALOR
    jugadorActual               resq 1; Valor del jugador actual. 0 -> turno del zorro, 1 -> turno de las ocas.
    coordenadasOrigen           times   0   resb
        x_origen                            resq 1;
        y_origen                            resq 1;
    coordenadasDestino          times   0   resb      
        x_destino                           resq 1;
        y_destino                           resq 1; 
    n_ocas                      resq 1;

    ;DATOS POR REFERENCIA
    dirPosicionOrigen           resq 1; donde dejarà las coordenadas de origen
    dirPosicionDestino          resq 1; donde dejarà las coordenadas de destino
    dirEstadoPartida            resq 1 
    dirInfoZorro                resq 1;[simboloZorro, posFilZorro, posColZorro]
    dirInfoOcas                 resq 1; infoOcas es un vector de la forma:
    ;                                   [cantidadOcasVivas, simboloOcas, posFilOca1, posColOca1, ..., posFilOcaN, posColOcaN], donde 0 <= N <= 17
     

section     .text

procesarComando:
    guardarParametros

pedirInput:
    pedirMovimiento

validarInterrupcion:
    compararInput comandoInterrupcion
    cmp     EAX,            0
    jne     validarGuardarPartida
    mov     RAX,            [dirEstadoJuego]
    mov     qword[RAX],     3
    apruebaValidacionTotal 

validarGuardarPartida:
    compararInput comandoGuardar
    cmp     EAX,            0
    jne     validarFormatoMovimiento
    ;aqui se llamaria a guardar partida
    jmp     pedirInput

validarFormatoMovimiento:
    cmp     qword[jugadorActual],   0
    je      movimientoZorro

movimientoOca:
    setParametrosScanCuatroDatos
    mSscanf
    cmp     EAX,            4
    jne     finValidacion
    chequearPosEnCruz       [dirPosicionOrigen]
    chequearPosEnCruz       [dirPosicionDestino]
    jmp     validacionLogicaMovOca

movimientoZorro:
    setParametrosScanDosDatos
    mSscanf
    cmp     EAX,            2
    jne     finValidacion
    chequearPosEnCruz       [dirPosicionDestino]
    jmp     validacionLogicaMovZorro

validacionLogicaMovOca:
    traducirLetra           [dirPosicionOrigen]
    traducirLetra           [dirPosicionDestino]
    guardarDatos

    unaOcaEnOrigen
    sinOcasEnDestino
    sinZorroEnDestino
    movimientoAdelanteOCostado    

validacionLogicaMovZorro:
    traducirLetra           [dirPosicionDestino]
    ;copio dentro de lo que apunta dirPosicionOrigen el valor de la posicion actual del zorro
    ;tambien guardo localmente la direccion de la posicion actual del zorro

;con esto parece que estoy inicializando x_origen y y_origen localmente

    ;guardo en registros los valores de la posicion actual del zorr
    mov RAX, [dirInfoZorro]
    mov RBX, [RAX+8];->RBX contiene la posFilZorro
    mov RDX, [RAX+16];->RDX contiene la posColZorro
    ;ya tengo en el RBX X_origen y en 
    mov [x_origen],RBX
    mov [y_origen],RDX

;ahora falta guardar en donde apunta dirPosicionOrigen
    mov RDI, [dirPosicionOrigen];->RDI tiene la direccion de coordenadasOrigen
    mov [RDI],RBX
    mov [RDI+8],


finValidacion:
    cmp     byte[inputValido],      'N'
    je      fallaValidacion
    ret

fallaValidacion:
    mov     RDI,    mensajeInputInvalido
    mPuts
    jmp     pedirInput

