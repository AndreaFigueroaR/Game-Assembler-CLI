%include "llamadas.asm"
%include "macrosRealizarJugada.asm"

global realizarJugada
section     .data
    esSalto                 dq      0;->0 no es salto, 1 es salto

section     .bss
    ;por dato
    jugadorActual           resq    1   ;0 -> turno zorro, 1 -> turno ocas.
    infoCoordenadas         times   0   resb        ; Vector de la forma: [filOrigen, colOrigen, filDestino,colDestino]
        coordenadasOrigen   times   0   resb
            filOrigen                   resq 1
            colOrigen                   resq 1
        coordenadasDestino  times   0   resb
            filDestino                  resq 1
            colDestino                  resq 1
    cantidadOcasVivas       resq    1
    ;punteros
    dirCantidadOcasVivas    resq    1   
    dirPosicionesOcas       resq        ;[posFilOca1, posColOca1, ..., posFilOcaN, posColOcaN]
    dirPosicionZorro        resq    1
    dirJugadorActual        resq    1
      
    ;auxiliares
    sentidoJugada           times   0    
        sentidoFila                 resq    1   ;0 si es es en la misma fila, 1 si en una fila superior, -1 para fila inferior
        sentidoColumna              resq    1   ;0 si es es en la misma columna, 1 si en una columna superior, -1 para columna inferior
    desplazVector                   resq    1
    cantElemVector                  resq    1
    dirBaseVector                   resq    1
    dirDestinoVector                resq    1
    coordenadasAux          times   0   
        filAux                  resq    1
        colAux                  resq    1
section     .text
realizarJugada:
    guardarDatos
    cmp                     qword[juagadorActual],0 ;->0 si es turno del zorro
    jne                     cambiarPosOca
    modificarPosZorro       
    ejecutarMovimiento:
    definirSaltoYSentidoMovida
    cmp                     qword[esSalto],0
    je                      cambiarJugador
    mMatarOca
    jmp                     cambiarJugador
    cambiarPosOca:
    modificarPosOca 
    cambiarJugador:         
    cmp                     qword[esSalto],0        ;0 si no es salto (no muriò oca)
    jne                      finJugada               ;si muriò una oca, se repite turno

    mov                     rax,[dirJugadorActual]  ;<-contiene la direcciòn del jugador actual
    mov                     rcx,[rax]               ;<-contiene al jugador actual
    mov                     rbx,1
    sub                     rbx,[rcx]               ;<-contiene al jugador contrario
    mov                     [rax],rbx               ;<-se cambia al jugador Actual
finJugada:
    ret
    
;__________________________________________________________
;**********************************************************
;                   RUTINAS INTERNAS
;__________________________________________________________
;**********************************************************
matarOca:
    ;sumo el sentido de la jugada (a la posicion origen) y busca una oca con esa posiciòn
    mov                 rax,[sentidoFila]
    add                 [filOrigen],rax
    mov                 rax,[sentidoColumna]
    add                 [colOrigen],rax
    ;ahora coordenadas origen tiene la posicion de la oca que busco eliminar 
    buscarOcaPorCoordenadas coordenadasOrigen
    ;desplazVector me dice què oca matar >:)
    mov                 rax,[dirPosicionesOcas]
    add                 rax,[desplazVector]
    ;busco direcciòn de la ultima oca viva
    dec                 qword[cantidadOcasVivas]        ;mato una oca
    imul                r8,qword[cantidadOcasVivas],16  ;cada coordenada ocupa 16 bytes (tengo desplazamiento hasta la ùltima viva)
    add                 r8,[dirPosicionesOcas]          ;tengo la direcciòn de la ultima oca viva          
    copiarVector        2,r8,rax   
    ret
;__________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
buscarOca:
    ;si ya la encontrè no sigo buscando=>el desplazamiento me dirà la direcciòn que le tengo que mnadar a copiar vector
    mov             r8,[desplazVector]
    mov             r9,[dirPosicionesOcas+r8];->tengo la fila
    ;si la fila no coincide->sgt oca
    cmp             r9,[filAux]
    jne             sgtOca
    ;si la columna no coincide->sgt oca
    add             r8,8
    mov             r9,[dirPosicionesOcas+r8];->tengo la columna
    cmp             r9,[colAux]
    jne             sgtOca
    ;encontrè coincidencia=>salgo del loop
    jmp             ocaEncontrada
    sgtOca:
    add             qword[desplazVector],16;->compara de a pares
    loop buscarOca:
    ocaEncontrada:
    ret
;__________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
guardarVector:
    ;PRE: cantElemVector, dirBaseVector, dirDestinoVector inicializados
    mov         qword[desplazVector],0
    mov         r10,[desplazVector]
    mov         r9,qword[cantElemVector]
    copiarSgt:
    cmp         qword[cantElemVector],0
    je          endCopiado

    mov         r10,[desplazVector]
    mov         rdi,[dirBaseVector]
    mov         rax,[rdi+r10]
    mov         rbx,[dirDestinoVector]
    mov         [rbx+r10],rax

    add         qword[desplazVector],8
    dec         qword[cantElemVector]
    jmp         copiarSgt
    endCopiado:
    ret
;__________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
analizarMovida:
    ;POST: setea el sentido de la jugada y si es que es salto o no
    ;coordenadas destino - coordenas origen
    mov     rax,[filOrigen];<-tiene Xdestino
    sub     [filDestino],rax;<-resta a las coordenadas de origen
    mov     rax,[colOrigen]
    sub     [colDestino],rax

    cmp     qword[filDestino],0
    je      mismaFila
    jg      filaSuperior
    mov     qword[sentidoFila],-1
    ;valor Abs
    not     qword[filDestino]
    inc     qword[filDestino]
    jmp     analizarCol
    mismaFila:
    mov     qword[sentidoFila],0
    jmp     analizarCol
    filaSuperior:
    mov     qword[sentidoFila],1
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    analizarCol:
    cmp     qword[colDestino],0
    je      mismaCol
    jg      colSuperior
    mov     qword[sentidoColumna],-1
    ;valor Abs
    not     qword[colDestino]
    inc     qword[colDestino]
    jmp     verificarSalto
    mismaCol:
    mov     qword[sentidoFila],0
    jmp     verificarSalto
    colSuperior:
    mov     qword[sentidoFila],1
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    verificarSalto:
    cmp     qword[filDestino],2
    je      verificarSaltoCol
    cmp     qword[filDestino],0
    je      verificarSaltoCol
    jmp     finAnalizarMovida
    verificarSaltoCol:
    cmp     qword[colDestino],2
    je      saltoConfirmado
    cmp     qword[colDestino],0
    jne     finAnalizarMovida
    saltoConfirmado:
    mov     qword[esSalto],1
    finAnalizarMovida:
    ret
