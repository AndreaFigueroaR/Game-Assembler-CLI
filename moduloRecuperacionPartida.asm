; RUTINA EXTERNA
; Pregunta al usuario si quiere recuperar una partida guardada. Si no se quiere se inicializan las variables con sus valores estandar. 
; Si se quiere entonces verifica que haya un archivo partida.txt guardado con la configuracion del ultimo juego y carga las variables 
; con esa configuracion. Si el archivo no existe entonces se inicializan las variables con sus valores estandar.
%include "llamadas.asm"

global recuperacionPartida

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
    contenidoLineaArchivo       resb 100
    lineasLeidasArchivo         resb 1

    infoOcasGuardada            times 18 resq 2
    infoZorroGuardada           times 3 resq 1
    jugadorActualGuardado       resq 1
    rotacionTableroGuardada     resq 1
    estadoPartidaGuardado       resq 1
    estadisticasGuardadas       times 8 resq 1

section     .text
recuperacionPartida:
;   Pregunto si se quiere recuperar la última partida guardada.
    mov                 rdi,pregunta
    mPuts           
    mov                 rdi,respuesta
    mGets           

    mov                 rdi,respuesta
    mAtoi           
    mov                 rdi,rax

    cmp                 rdi,0
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
    mov                 qword[infoZorro],rax
    jmp                 continuarLeyendo
    leerSimboloOcas:
    cmp                 byte[lineasLeidasArchivo],1
    jne                 leerCantidadOcasVivas
    mov                 rdi,contenidoLineaArchivo
    call                eliminarCaracterSaltoLinea
    mov                 qword[infoOcas+8],rax
    jmp                 continuarLeyendo
    leerCantidadOcasVivas:
    cmp                 byte[lineasLeidasArchivo],2
    jne                 leerPosicionesOcas
    mov                 rdi,contenidoLineaArchivo
    call                eliminarCaracterSaltoLinea
    mAtoi                                                    ; Convierto la cadena a entero
    mov                 qword[infoOcas],rax
    jmp                 continuarLeyendo
    leerPosicionesOcas:
    cmp                 byte[lineasLeidasArchivo],3
    jne                 leerPosicionZorro
    mov                 rdi,contenidoLineaArchivo
    lea                 rsi,[infoOcas+16]
    call                inicializarVector
    mov                 [infoOcas+16],rsi
    jmp                 continuarLeyendo
    leerPosicionZorro:
    cmp                 byte[lineasLeidasArchivo],4
    jne                 leerJugadorActual
    mov                 rdi,contenidoLineaArchivo
    lea                 rsi,[infoZorro+8]
    call                inicializarVector
    mov                 [infoZorro+8],rsi
    jmp                 continuarLeyendo
    leerJugadorActual:
    cmp                 byte[lineasLeidasArchivo],5
    jne                 leerRotacionTablero
    mov                 rdi,contenidoLineaArchivo
    call                eliminarCaracterSaltoLinea
    mAtoi           
    mov                 qword[jugadorActualGuardado],rax
    jmp                 continuarLeyendo
    leerRotacionTablero:
    cmp                 byte[lineasLeidasArchivo],6
    jne                 leerEstadoPartida
    mov                 rdi,contenidoLineaArchivo
    call                eliminarCaracterSaltoLinea
    mAtoi
    mov                 qword[rotacionTableroGuardada],rax
    jmp                 continuarLeyendo
    leerEstadoPartida:
    cmp                 byte[lineasLeidasArchivo],7
    jne                 leerEstadisticas
    mov                 rdi,contenidoLineaArchivo
    call                eliminarCaracterSaltoLinea
    mAtoi           
    mov                 qword[estadoPartidaGuardado],rax
    jmp                 continuarLeyendo
    leerEstadisticas:
    cmp                 byte[lineasLeidasArchivo],8
    jne                 finArchivo
    mov                 rdi,contenidoLineaArchivo
    mov                 rsi,estadisticasGuardadas
    call                inicializarVector
    mov                 [estadisticasGuardadas],rsi
    jmp                 finArchivo
continuarLeyendo:
    inc                 byte[lineasLeidasArchivo]
    jmp                 loopLecturaArchivo
finArchivo:
    mov     rdi,[idArchivo]
    mFClose
fin:
    ret

;_________________RUTINAS INTERNAS_________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Elimina el caracter de salto de linea de una cadena (cuya direccion recibe en el registro rdi) y lo reemplaza por un 0. 
; Deja el resultado en el rax.
eliminarCaracterSaltoLinea:
    call                contarCaracteres
    mov                 byte[rdi+rcx],0     ; Reemplazar '\n' con un carácter nulo
    mov                 rax,[rdi]
    ret

; Cuenta los caracteres de una cadena cuya direccion de memoria se encuentra guardada en el registro rdi y guarda el resultado en el rcx.
contarCaracteres:
    xor                 rcx,rcx             ; Inicializo el rcx en 0
loopContarCaracteres:
    cmp                 byte[rdi+rcx],10    ; Comparo el caracter actual con el \n (10 en ASCII)
    je                  finContarCaracteres

    inc                 rcx
    jmp                 loopContarCaracteres
finContarCaracteres:
    ret

; Recibe la direccion a la linea del archivo en el registro rdi y recibe la direccion al vector a inicializar en el rsi.
; Devuelve en el rsi la dirección de memoria al vector inicializado.
inicializarVector:
    xor                 rcx,rcx             ; Inicializo el rcx en 0, con él recorro la linea
    xor                 r8,r8               ; Inicializo el r8 en 0, con él recorro el vector de posicion del Zorro.
    mov                 r9,rdi
loopRecorrerLinea:
    cmp                 byte[r9+rcx],10     ; Comparo el caracter actual con el \n (10 en ASCII)
    je                  finLinea
    cmp                 byte[r9+rcx],32     ; Comparo el caracter actual con el espacio (32 en ASCII)
    je                  avanzarEnLaLinea
    ; Si llego aca es porque el caracter actual es un numero.
    lea                 rdi,[r9+rcx]        ; Actualizo rdi con la dirección actual
    mov                 r10,[r9+rcx+1]      ; Me guardo el siguiente caracter original de la cadena
    mov                 byte[r9+rcx+1],0    ; Coloco un \0 después del número
    mAtoi           
    mov                 qword[rsi+r8],rax
    add                 r8,8
    mov                 [r9+rcx+1],r10      ; Restauro el espacio original
avanzarEnLaLinea:
    inc                 rcx
    jmp                 loopRecorrerLinea
finLinea:
    ret
