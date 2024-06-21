; RUTINA EXTERNA
; Pregunta al usuario si quiere recuperar una partida guardada. Si no se quiere se inicializan las variables con sus valores estandar. 
; Si se quiere entonces verifica que haya un archivo partida.txt guardado con la configuracion del ultimo juego y carga las variables 
; con esa configuracion. Si el archivo no existe entonces se inicializan las variables con sus valores estandar.
; Si el archivo existe, entonces tiene un formato como el del siguiente ejemplo:
; ------------------------------------------------------------------------
; X                                                                       <- Simbolo del zorro
; O                                                                       <- Simbolo de las ocas
; 17                                                                      <- Cantidad de ocas vivas
; 1 3 1 4 1 5 2 3 2 4 2 5 3 1 3 2 3 3 3 4 3 5 3 6 3 7 4 1 4 7 5 1 5 7     <- Posiciones de las ocas en pares de fila y columna
; 5 4                                                                     <- Posicion del Zorro
; 1                                                                       <- Jugador actual (1 -> Zorro)
; 0                                                                       <- Rotacion del tablero
; 0                                                                       <- Estado de la partida (0 -> Partida activa)
; 0 0 0 0 0 0 0 0                                                         <- Estadisticas (termina con salto de linea)
;
; ------------------------------------------------------------------------
%include "llamadas.asm"

global recuperacionPartida
extern puts
extern gets
extern atoi
extern fopen
extern fgets
extern fclose

section     .data
    infoOcas                    dq                  0,                                          ; cantidadOcasVivas
                                dq                  "O",                                        ; simboloOcas
                                dq                  1, 3, 1, 4, 1, 5                            ; Ocas de la fila 1 (en las columnas 3, 4 y 5)
                                dq                  2, 3, 2, 4, 2, 5                            ; Ocas de la fila 2 (en las columnas 3, 4 y 5)
                                dq                  3, 1, 3, 2, 3, 3, 3, 4, 3, 5, 3, 6, 3, 7    ; Ocas de la fila 3 (en las columnas 1, 2, 3, 4, 5, 6 y 7)
                                dq                  4, 1, 4, 7                                  ; Ocas de la fila 4 (en las columnas 1 y 7)
                                dq                  5, 1, 5, 7                                  ; Ocas de la fila 5 (en las columnas 1 y 7)
    infoZorro                   dq                  "X",                                        ; simboloZorro
                                dq                  5, 4                                        ; Zorro en la fila 5 y columna 4
    jugadorActual               dq                  0                                           ; Jugador actual -> Zorro
    rotacionTablero             dq                  0
    estadoPartida               dq                  0                                           ; Partida activa
    estadisticas                dq                  0, 0, 0, 0, 0, 0, 0, 0                      ; Cantidad de movimientos en cada direccion inicializadas en 0

    pregunta                    db                  "¿Quiere recuperar la última partida guardada? Ingrese 1 si sí o 0 si no:",0
    nombreArchivo               db                  "partida.txt",0
    modoApertura                db                  "r",0
    msgErrorArchivo             db                  "Hubo un error al abrir el archivo y no se pudo cargar la partida guardada. Se creará una nueva partida.",0

section     .bss   
    respuesta                   resb 50             ; Si la respuesta es 1 quiere recuperar la ultima partida guardada. Si no, 0.
    idArchivo                   resq 1
    lineasLeidasArchivo         resb 1
    contenidoLineaArchivo       resb 100
    caracterLineaArchivo        resb 2

    infoOcasGuardada            times 18 resq 2
    infoZorroGuardada           times 3 resq 1
    jugadorActualGuardado       resq 1
    rotacionTableroGuardada     resq 1
    estadoPartidaGuardado       resq 1
    estadisticasGuardadas       times 8 resq 1

    dirInfoOcas                 resq 1
    dirInfoZorro                resq 1
    dirJugadorActual            resq 1
    dirRotacionTablero          resq 1
    dirEstadoPartida            resq 1
    dirEstadisticas             resq 1

section     .text
recuperacionPartida:
    mov                 [dirInfoOcas],r8
    mov                 [dirInfoZorro],r9
    mov                 [dirJugadorActual],r10
    mov                 [dirRotacionTablero],r11
    mov                 [dirEstadoPartida],r12
    mov                 [dirEstadisticas],r13

;   Pregunto si se quiere recuperar la última partida guardada.
    mov                 rdi,pregunta
    mPuts           

    mov                 rdi,respuesta
    mGets

    mov                 rdi,respuesta
    mAtoi

    cmp                 rax,0
    je                  inicializarVariablesEstandar
    jmp                 inicializarVariablesGuardadas
inicializarVariablesEstandar:
    mov                 r8,infoOcas
    mov                 r9,infoZorro
    mov                 r10,jugadorActual
    mov                 r11,rotacionTablero
    mov                 r12,estadoPartida
    mov                 r13,estadisticas
    jmp                 fin
inicializarVariablesGuardadas:
;   Abro el archivo partida.txt
    mov                 byte[lineasLeidasArchivo],0          ; Inicializo la cantidad de lineas leidas en 0.
    mov                 rdi,nombreArchivo
    mov                 rsi,modoApertura
    mFOpen

    cmp                 rax,0
    jg                  leerArchivo
;   Hubo un error al abrir el archivo.
    mov                 rdi,msgErrorArchivo
    mPuts
    jmp                 inicializarVariablesEstandar
leerArchivo:
    mov                 qword[idArchivo],rax
loopLecturaArchivo:
    mov                 rdi,contenidoLineaArchivo
    mov                 rsi,100
    mov                 rdx,[idArchivo]
    mFGets

    cmp                 rax,0
    jle                 finArchivo

    leerSimboloZorro:
    cmp                 byte[lineasLeidasArchivo],0
    jne                 leerSimboloOcas
    mov                 rdi,contenidoLineaArchivo
    call                eliminarCaracterSaltoLinea
    mov                 [infoZorroGuardada],rax
    jmp                 continuarLeyendo
    leerSimboloOcas:
    cmp                 byte[lineasLeidasArchivo],1
    jne                 leerCantidadOcasVivas
    mov                 rdi,contenidoLineaArchivo
    call                eliminarCaracterSaltoLinea
    mov                 [infoOcasGuardada+8],rax
    jmp                 continuarLeyendo
    leerCantidadOcasVivas:
    cmp                 byte[lineasLeidasArchivo],2
    jne                 leerPosicionesOcas
    mov                 rdi,contenidoLineaArchivo
    call                eliminarCaracterSaltoLinea
    call                atoi                                            ; Convierto la cadena a entero
    mov                 [infoOcasGuardada],rax
    jmp                 continuarLeyendo
    leerPosicionesOcas:
    cmp                 byte[lineasLeidasArchivo],3
    jne                 leerPosicionZorro
    lea                 rsi,[infoOcasGuardada+16]
    call                inicializarVector
    jmp                 continuarLeyendo
    leerPosicionZorro:
    cmp                 byte[lineasLeidasArchivo],4
    jne                 leerJugadorActual
    lea                 rsi,[infoZorroGuardada+8]
    call                inicializarVector
    jmp                 continuarLeyendo
    leerJugadorActual:
    cmp                 byte[lineasLeidasArchivo],5
    jne                 leerRotacionTablero
    mov                 rdi,contenidoLineaArchivo
    call                eliminarCaracterSaltoLinea
    call                atoi           
    mov                 [jugadorActualGuardado],rax
    jmp                 continuarLeyendo
    leerRotacionTablero:
    cmp                 byte[lineasLeidasArchivo],6
    jne                 leerEstadoPartida
    mov                 rdi,contenidoLineaArchivo
    call                eliminarCaracterSaltoLinea
    call                atoi
    mov                 [rotacionTableroGuardada],rax
    jmp                 continuarLeyendo
    leerEstadoPartida:
    cmp                 byte[lineasLeidasArchivo],7
    jne                 leerEstadisticas
    mov                 rdi,contenidoLineaArchivo
    call                eliminarCaracterSaltoLinea
    call                atoi           
    mov                 [estadoPartidaGuardado],rax
    jmp                 continuarLeyendo
    leerEstadisticas:
    cmp                 byte[lineasLeidasArchivo],8
    jne                 finArchivo
    mov                 rsi,estadisticasGuardadas
    call                inicializarVector    
    jmp                 finArchivo
continuarLeyendo:
    inc                 byte[lineasLeidasArchivo]
    jmp                 loopLecturaArchivo
finArchivo:
    mov                 rdi,[idArchivo]
    mFClose
    call                actualizarVariables
fin:
    ret

;_________________RUTINAS INTERNAS_________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Elimina el caracter de salto de linea de una cadena (cuya direccion recibe en el registro rdi) y lo reemplaza por un 0. 
; Deja el resultado en el rax.
eliminarCaracterSaltoLinea:
    call                contarCaracteres
    mov                 byte[rdi+rcx],0                         ; Reemplazar '\n' con un carácter nulo
    mov                 rax,[rdi]
    ret

; Cuenta los caracteres de una cadena cuya direccion de memoria se encuentra guardada en el registro rdi y guarda el resultado en el rcx.
contarCaracteres:
    xor                 rcx,rcx                                 ; Inicializo el rcx en 0
loopContarCaracteres:
    cmp                 byte[rdi+rcx],10                        ; Comparo el caracter actual con el \n (10 en ASCII)
    je                  finContarCaracteres

    inc                 rcx
    jmp                 loopContarCaracteres
finContarCaracteres:
    ret

; Recibe la direccion al vector a inicializar en el rsi.
; Devuelve en el rsi la dirección de memoria al vector inicializado.
inicializarVector:
    xor                 rcx,rcx                                 ; Inicializo el rcx en 0, con él recorro la linea
    xor                 r8,r8                                   ; Inicializo el r8 en 0. Auxiliar para avanzar en el vector.
loopRecorrerLinea:
    cmp                 byte[contenidoLineaArchivo+rcx],10      ; Comparo el caracter actual con el \n (10 en ASCII)
    je                  finLinea
    cmp                 byte[contenidoLineaArchivo+rcx],32      ; Comparo el caracter actual con el espacio (32 en ASCII)
    je                  avanzarEnLaLinea
;   Si llego aca es porque el caracter actual es un numero.
    mov                 dil,byte[contenidoLineaArchivo+rcx]     ; Actualizo dil con el caracter actual
    mov                 byte[caracterLineaArchivo],dil          ; Me guardo el caracter actual en caracterLineaArchivo
    mov                 byte[caracterLineaArchivo+1],0          ; Coloco un \0 después del número
    mov                 rdi,caracterLineaArchivo
    
    push                rcx                                     ; Quiero preservar el contenido de estos registros
    push                rsi
    push                r8
    mAtoi
    pop                 r8
    pop                 rsi
    pop                 rcx
    
    mov                 [rsi+r8],rax                            ; Actualizo la posicion del vector con el nuevo dato
    add                 r8,8
avanzarEnLaLinea:
    inc                 rcx
    jmp                 loopRecorrerLinea
finLinea:
    ret

; Actualiza las variables originales segun las guardadas tras recorrer el archivo.
actualizarVariables:
;   Copio infoOcas
    xor                 rcx,rcx                                 ; Inicializo el rcx en 0, con él cuento las iteraciones del loop.
    xor                 r8,r8                                   ; Inicializo el r8 en 0. Auxiliar para avanzar en el vector.
loopCopiarInfoOcas:
    cmp                 rcx,36                                  ; 18 * 2 qwords = 36 qwords
    jge                 finLoopCopiarInfoOcas

    mov                 rdi,[dirInfoOcas]
    mov                 rax,[infoOcasGuardada+r8]
    mov                 [rdi+r8],rax

    inc                 rcx
    add                 r8,8
    jmp                 loopCopiarInfoOcas
finLoopCopiarInfoOcas:
;   Copio infoZorro
    xor                 rcx,rcx
    xor                 r8,r8
loopCopiarInfoZorro:
    cmp                 rcx,3                                   ; 3 * 1 qwords = 3 qwords
    jge                 finLoopCopiarInfoZorro

    mov                 rdi,[dirInfoZorro]
    mov                 rax,[infoZorroGuardada+r8]
    mov                 [rdi+r8],rax

    inc                 rcx
    add                 r8,8
    jmp                 loopCopiarInfoZorro
finLoopCopiarInfoZorro:
;   Copio jugadorActual
    mov                 rdi,[dirJugadorActual]
    mov                 rax,[jugadorActualGuardado]
    mov                 [rdi],rax
;   Copio rotacionTablero
    mov                 rdi,[dirRotacionTablero]
    mov                 rax,[rotacionTableroGuardada]
    mov                 [rdi],rax
;   Copio estadoPartida
    mov                 rdi,[dirEstadoPartida]
    mov                 rax,[estadoPartidaGuardado]
    mov                 [rdi],rax
;   Copio estadisticas
    xor                 rcx,rcx
    xor                 r8,r8
loopCopiarEstadisticas:
    cmp                 rcx,8                                   ; 8 * 1 qwords = 8 qwords
    jge                 finLoopCopiarEstadisticas

    mov                 rdi,[dirEstadisticas]
    mov                 rax,[estadisticasGuardadas+r8]
    mov                 [rdi+r8],rax

    inc                 rcx
    add                 r8,8
    jmp                 loopCopiarEstadisticas
finLoopCopiarEstadisticas:
    ret
