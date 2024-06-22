; Guarda la partida según los valores de las variables cuyas direcciones de memoria fueron guardadas en r8, r9, r10, r11, r12 y r13.
; La guarda en un archivo partida.txt. Si el archivon existe, lo sobreescribe, sino lo crea y escribe en el.
; El archivo tendrá un formato como el del siguiente ejemplo:
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

%macro mEscribirLinea 0
    mov                 rdi,lineaActual
    mov                 rsi,[idArchivo]
    mFPuts
%endmacro

%macro mConvertirNumAStr 0
    mov                 rdi,lineaActual
    mov                 rsi,formatoNumAStr
    mov                 rdx,rax
    mSprintf
%endmacro

%macro mConvertirNumACaracter 0
    mov                 rdi,lineaActual
    mov                 rsi,formatoNumAStrCaracter
    mov                 rdx,rax
    mSprintf
%endmacro

global guardarPartida
extern fopen
extern fputs
extern fgets
extern fclose
extern sprintf
extern puts

section     .data
    nombreArchivo               db                  "partida.txt",0
    modoApertura                db                  "w+",0
    msgErrorGuardarPartida      db                  "Hubo un error al intentar guardar la partida.",0
    formatoNumAStr              db                  "%d",10,0
    formatoNumAStrCaracter      db                  "%d ",0

section     .bss   
    idArchivo                   resq 1
    lineaActual                 resq 50

    infoOcas                    times 18 resq 2
    infoZorro                   times 3 resq 1
    jugadorActual               resq 1
    rotacionTablero             resq 1
    estadoPartida               resq 1
    estadisticas                times 8 resq 1

    dirInfoOcas                 resq 1
    dirInfoZorro                resq 1
    dirJugadorActual            resq 1
    dirRotacionTablero          resq 1
    dirEstadoPartida            resq 1
    dirEstadisticas             resq 1

section     .text
guardarPartida:
    mov                 [dirInfoOcas],r8
    mov                 [dirInfoZorro],r9
    mov                 [dirJugadorActual],r10
    mov                 [dirRotacionTablero],r11
    mov                 [dirEstadoPartida],r12
    mov                 [dirEstadisticas],r13

    call                inicializarVariables

;   ABRO/CREO EL ARCHIVO partida.txt
    mov                 rdi,nombreArchivo
    mov                 rsi,modoApertura
    mFOpen

    cmp                 rax,0
    jg                  escribirArchivo
    mov                 rdi,msgErrorGuardarPartida
    mPuts
    jmp                 fin
escribirArchivo:
    mov                 [idArchivo],rax

;   ESCRIBO EL SIMBOLO DEL ZORRO
    mov                 rax,[infoZorro]                     ; Me guardo el dato que está en infoZorro (símbolo del zorro)
    mov                 [lineaActual],rax                   ; Me guardo el simbolo del zorro en la linea que voy a escribir
    mov                 qword[lineaActual+1],10             ; Agrego un salto de linea en el byte siguiente
    mov                 qword[lineaActual+2],0              ; Agrego un \0 al final
    mEscribirLinea
;   ESCRIBO EL SIMBOLO DE LAS OCAS
    mov                 rax,[infoOcas+8]                    ; Me guardo el dato que está en infoOcas+8 (símbolo de las ocas)
    mov                 [lineaActual],rax                   ; Me guardo el simbolo de las ocas en la linea que voy a escribir
    mov                 qword[lineaActual+1],10             ; Agrego un salto de linea en el byte siguiente
    mov                 qword[lineaActual+2],0              ; Agrego un \0 al final
    mEscribirLinea

;   ESCRIBO LA CANTIDAD DE OCAS VIVAS
    mov                 rax,[infoOcas]                      ; Me guardo el dato que está en infoOcas (cantidad de ocas vivas)
    mConvertirNumAStr
    mEscribirLinea

;   ESCRIBO LAS POSICIONES DE LAS OCAS
    xor                 r12,r12                             ; Uso estos registros ya que sprintf los preserva
    xor                 r13,r13
loopRecorrerPosicionesOcas:
    mov                 rax,[infoOcas]                      ; Me guardo el dato de la cantidad de ocas vivas
    sub                 rax,1                               ; Resto 1 a la cantidad de ocas vivas (ya que voy a comparar con el indice en r12)
    cmp                 rax,r12                             ; Si son iguales significa que me falta escribir la ultima posicion de las ocas
    je                  escribirUltimoCaracterPosicionesOcas

    mov                 rax,[infoOcas+16+r13]
    mConvertirNumACaracter
    mEscribirLinea
    
    inc                 r12
    add                 r13,8
    jmp                 loopRecorrerPosicionesOcas
    escribirUltimoCaracterPosicionesOcas:
    mov                 rax,[infoOcas+16+r13]
    mConvertirNumAStr
    mEscribirLinea

;   ESCRIBO LA POSICION DEL ZORRO
    mov                 rax,[infoZorro+8]
    mConvertirNumACaracter
    mEscribirLinea
    
    mov                 rax,[infoZorro+16]
    mConvertirNumAStr
    mEscribirLinea

;   ESCRIBO EL VALOR DEL JUGADOR ACTUAL
    mov                 rax,[jugadorActual]
    mConvertirNumAStr
    mEscribirLinea

;   ESCRIBO EL VALOR DE LA ROTACION DEL TABLERO
    mov                 rax,[rotacionTablero]
    mConvertirNumAStr
    mEscribirLinea

;   ESCRIBO EL VALOR DEL ESTADO DE LA PARTIDA
    mov                 rax,0                               ; Establezco el estado de la partida guardada siempre en 0 para que se la pueda retomar.
    mConvertirNumAStr
    mEscribirLinea

;   ESCRIBO LAS ESTADISTICAS
    xor                 r12,r12
    xor                 r13,r13
loopRecorrerEstadisticas:
    mov                 rax,8                               ; Me guardo el dato de la cantidad de espacios de las estadisticas
    sub                 rax,1                               ; Resto 1 (ya que voy a comparar con el indice en r12)
    cmp                 rax,r12                             ; Si son iguales significa que me falta escribir la ultima posicion de las estadisticas
    je                  escribirUltimoCaracterEstadisticas

    mov                 rax,[estadisticas+r13]
    mConvertirNumACaracter
    mEscribirLinea
    
    inc                 r12
    add                 r13,8
    jmp                 loopRecorrerEstadisticas
    escribirUltimoCaracterEstadisticas:
    mov                 rax,[estadisticas+r13]
    mConvertirNumAStr
    mEscribirLinea

    mov                 rdi,[idArchivo]
    mFClose
fin:
    ret

;_________________RUTINAS INTERNAS_________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Inicializa las variables de infoOcas, infoZorro, jugadorActual, rotacionTablero, estadoPartida y estadisticas según los datos
; guardados en las direcciones de memoria guardadas en los registros r8, r9, r10, r11, r12 y r13.
inicializarVariables:
;   Copio infoOcas
    xor                 rcx,rcx                                 ; Inicializo el rcx en 0, con él cuento las iteraciones del loop.
    xor                 rsi,rsi                                 ; Inicializo el rsi en 0. Auxiliar para avanzar en el vector.
loopCopiarInfoOcas:
    cmp                 rcx,36                                  ; 18 * 2 qwords = 36 qwords
    jge                 finLoopCopiarInfoOcas

    mov                 rdi,infoOcas
    mov                 rax,[r8+rsi]
    mov                 [rdi+rsi],rax
    inc                 rcx
    add                 rsi,8
    jmp                 loopCopiarInfoOcas
finLoopCopiarInfoOcas:
;   Copio infoZorro
    xor                 rcx,rcx
    xor                 rsi,rsi
loopCopiarInfoZorro:
    cmp                 rcx,3                                   ; 3 * 1 qwords = 3 qwords
    jge                 finLoopCopiarInfoZorro

    mov                 rdi,infoZorro
    mov                 rax,[r9+rsi]
    mov                 [rdi+rsi],rax

    inc                 rcx
    add                 rsi,8
    jmp                 loopCopiarInfoZorro
finLoopCopiarInfoZorro:
;   Copio jugadorActual
    mov                 rdi,jugadorActual
    mov                 rax,[r10]
    mov                 [rdi],rax
;   Copio rotacionTablero
    mov                 rdi,rotacionTablero
    mov                 rax,[r11]
    mov                 [rdi],rax
;   Copio estadoPartida
    mov                 rdi,estadoPartida
    mov                 rax,[r12]
    mov                 [rdi],rax
;   Copio estadisticas
    xor                 rcx,rcx
    xor                 rsi,rsi
loopCopiarEstadisticas:
    cmp                 rcx,8                                   ; 8 * 1 qwords = 8 qwords
    jge                 finLoopCopiarEstadisticas

    mov                 rdi,estadisticas
    mov                 rax,[r13+rsi]
    mov                 [rdi+rsi],rax

    inc                 rcx
    add                 rsi,8
    jmp                 loopCopiarEstadisticas
finLoopCopiarEstadisticas:
    ret
