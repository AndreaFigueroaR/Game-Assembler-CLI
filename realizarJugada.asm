%include "macros.asm"
global realizarJugada
extern printf

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                             INICIALIZACIÓN DATOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section     .data
    esSalto                             dq      0;->0 no es salto, 1 es salto
    haySgtMovida                        dq      0;->0 no hay sgtMovida, 1 hay sgtMovida

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                             RESERVA DE MEMORIA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section     .bss
    seguridad                           resb    50
    ;por dato
    jugadorActual                       resq    1   ;0 -> turno zorro, 1 -> turno ocas.
    infoCoordenadas         times   0   resb        ; Vector de la forma: [filOrigen, colOrigen, filDestino,colDestino]
        coordenadasOrigen   times   0   resb
            filOrigen                   resq    1
            colOrigen                   resq    1
        coordenadasDestino  times   0   resb
            filDestino                  resq    1
            colDestino                  resq    1
    cantidadOcasVivas                   resq    1
    ;punteros
    dirCantidadOcasVivas                resq    1   
    dirPosicionesOcas                   resq    1    ;[posFilOca1, posColOca1, ..., posFilOcaN, posColOcaN]
    dirPosicionZorro                    resq    1
    dirJugadorActual                    resq    1
    dirEstadoPartida                    resq    1    ;0 -> partidaActiva, 1 ->ganó el Zorro, 2 -> ganaron las ocas, 3 -> partida interrumpida
      
    ;auxiliares
    sentidoJugada           times   0   resb
        sentidoFila                     resq    1   ;0 si es es en la misma fila, 1 si en una fila superior, -1 para fila inferior
        sentidoColumna                  resq    1   ;0 si es es en la misma columna, 1 si en una columna superior, -1 para columna inferior
    desplazVector                       resq    1
    cantElemVector                      resq    1
    dirBaseVector                       resq    1
    dirDestinoVector                    resq    1
    coordenadasAux          times   0   resb
        filAux                          resq    1
        colAux                          resq    1
    versor                  times   0   resb     
        filVersor                       resq    1
        colVersor                       resq    1
    iteradorBuscarOca                   resq    1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                             CÓDIGO FUENTE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text

realizarJugada:
    guardarDatos
    cmp                     qword[jugadorActual],0      ;->0 si es turno del zorro
    jne                     cambiarPosOca               ;->si es oca, se cambia su posiciòn y se analiza si es que se acorralò al zorro 
    modificarPosZorro                                   ;->si es zorro, se cambia su posicion, se mata a la oca y se consulta si es se mataron a 12 ocas 
    definirSaltoYSentidoMovida
    cmp                     qword[esSalto],0            ;->1 se come a una oca
    je                      cambiarJugador              ;->si no se come oca se pregunta si quedò acorralado
    mMatarOca                                           ;->si se mata oca se pregunta si zorro victorioso
    jmp                     preguntarZorroVictorioso

    cambiarPosOca:
    modificarPosOca         
    jmp                     preguntarZorroAcorralado
    jmp                     cambiarJugador

    preguntarZorroVictorioso:                 
    cmp                     qword[cantidadOcasVivas],5      ;<- 17-12 ocas
    jne                     finJugada
    estadoTerminaPartida    1                               ;<-1 ganò el zorro, 2 ganaron las ocas
    jmp                     finJugada

    preguntarZorroAcorralado:
    mZorroAcorralado?
    mov                     rdx,[dirEstadoPartida]
    cmp                     qword[rdx],0
    jne                     finJugada

    cambiarJugador:
    cmp                     qword[esSalto],0        ;0 si no es salto (no muriò oca)
    jne                     finJugada               ;si muriò una oca, se repite turno

    mov                     rax,[dirJugadorActual]  ;<-contiene la direcciòn del jugador actual
    mov                     rcx,[rax]               ;<-contiene al jugador actual
    mov                     rbx,1
    sub                     rbx,rcx                 ;<-contiene al jugador contrario
    mov                     [rax],rbx               ;<-se cambia al jugador Actual
finJugada:
    ret

;__________________________________________________________
;**********************************************************
;                   RUTINAS INTERNAS
;__________________________________________________________
;**********************************************************
zorroAcorraladoTotalemente:
    ;PRE: 
    ;POST: Cambia el estado del juego si es que el zorro no tiene una movida posible (quedò acorralado para todas las direcciones)
    
    buscarPosLibreEndireccion   1,1
    je                          zorroEsLibre
    buscarPosLibreEndireccion   1,0
    je                          zorroEsLibre
    buscarPosLibreEndireccion   1,-1
    je                          zorroEsLibre
    buscarPosLibreEndireccion   -1,1
    je                          zorroEsLibre

    buscarPosLibreEndireccion   -1,0
    je                          zorroEsLibre
    buscarPosLibreEndireccion   -1,-1
    je                          zorroEsLibre
    buscarPosLibreEndireccion   0,1
    je                          zorroEsLibre
    buscarPosLibreEndireccion   0,-1
    je                          zorroEsLibre

    estadoTerminaPartida        2
    zorroEsLibre:
    ret

;__________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

zorroAcorraladoUnVersor:
    ;PRE: Versor inicializado con una posibe direcciòn (conformada con 0, 1 o -1 excepto (0,0))
    ;POST: Si es que el zorro tiene alguna posible movida en la direcciòn inidicada en el versor, se cambia el ròtulo: haySgtMovida, indicando que hay una siguiente movida
    
    mov                             rdx,[dirPosicionZorro]
    copiarVector                    2,rdx,coordenadasOrigen

    calcularPosiblePosZorroEnUnSentido                      ;<-(flag equal indica si es una pos libre)
    je                              hayMovPosible
    calcularPosiblePosZorroEnUnSentido                      ;<-(flag equal indica si es una pos libre)
    je                              hayMovPosible
    ret
    hayMovPosible:
    mov                             qword[haySgtMovida],1
    ret
;__________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

matarOca:
    ;PRE:
    ;POST: elimina a la oca comida por el zorro 

    ;sumo el sentido de la jugada (a la posicion origen) y busca una oca con esa posiciòn
    mov                 rax,[sentidoFila]
    add                 [filOrigen],rax
    mov                 rax,[sentidoColumna]
    add                 [colOrigen],rax
    ;ahora coordenadas origen tiene la posicion de la oca que busco eliminar 
    buscarOcaPorCoordenadas coordenadasOrigen
    ;desplazVector me dice què oca matar
    mov                 rax,[dirPosicionesOcas]
    add                 rax,[desplazVector]
    excluirOca                                          ;mato una oca (en el juego y en la copia resto 1 a la cantidad de ocas vivas)
    imul                r8,qword[cantidadOcasVivas],16  ;cada coordenada ocupa 16 bytes (tengo desplazamiento hasta la ùltima viva)
    add                 r8,[dirPosicionesOcas]          ;tengo la direcciòn de la ultima oca viva          
    copiarVector        2,r8,rax                        ;piso la posiciòn de la oca que querìa matar con la ultima viva 
    
    ret
;__________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

buscarOca:
    ;POST: deja en desplaz vector el desplazamiento hasta la posiciòn de la oca buscada. Si la oca no se encontrò, el desplazamiento es cantOcasVivas*16
    ;si ya la encontrè no sigo buscando=>el desplazamiento me dirà la direcciòn que le tengo que mnadar a copiar vector
buscarOcaNext:
    mov             rcx,[cantidadOcasVivas]
    cmp             [iteradorBuscarOca],rcx
    je              ocaEncontrada

    mov             r9,[dirPosicionesOcas]  ;->tengo la direcciòn de la fila
    add             r9,[desplazVector]
    mov             r10,[r9]
    
    cmp             r10,[filAux]            ;si la fila no coincide->sgt oca
    jne             sgtOca
    
    add             r9,8                    ;->tengo la direcciòn columna
    mov             r10,[r9]
    cmp             r10,[colAux]            ;si la columna no coincide->sgt oca
    jne             sgtOca
    jmp             ocaEncontrada           ;encontrè coincidencia=>salgo del loop
    sgtOca:
    add             qword[desplazVector],16;->compara de a pares
    inc             qword[iteradorBuscarOca]
    jmp             buscarOcaNext
    ocaEncontrada:
    ret
;__________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
guardarVector:
    ;PRE: cantElemVector, dirBaseVector, dirDestinoVector inicializados con la cantidad de elementos a copiar, la direcciòn del vector source y la direcciòn dle vector destino.
    ;POST: copia la cantidad de elementos indicada del vector source al vector destino

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
    mov     rax,[filOrigen]         ;<-tiene Xdestino
    sub     [filDestino],rax        ;<-resta a las coordenadas de origen
    mov     rax,[colOrigen]
    sub     [colDestino],rax;       
    mGuardarSentidoMovida           ;<-consigue el sentido de la movida (conformado con 1, 0 o -1)
    
    cmp     qword[filDestino],2     ;a continuacion pregunta si hay algùn 2 o -2 (implica salto)
    je      saltoConfirmado
    cmp     qword[filDestino],-2
    je      saltoConfirmado

    cmp     qword[colDestino],2
    je      saltoConfirmado
    cmp     qword[colDestino],-2
    je      saltoConfirmado
    jmp     finBuscarSalto
    saltoConfirmado:
    mov     qword[esSalto],1
    finBuscarSalto:
    ret
;__________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   

guardarSentidoMovida:
    ;PRE:  coordenadasDestino inicializado con la resta entre coordenadas destino - coordenas origen
    ;POST: guarda el sentido de la jugada (con 1, 0 o -1) tanto para filas como para columnas

    cmp     qword[filDestino],0
    jl      guardarMenosUnoFil
    jg      guardarUnoFil 

    mov     qword[sentidoFila],0
    jmp     analizarSentidoCol
    guardarMenosUnoFil:
    mov     qword[sentidoFila],-1
    jmp     analizarSentidoCol
    guardarUnoFil:
    mov     qword[sentidoFila],1

analizarSentidoCol:
    cmp     qword[colDestino],0
    jl      guardarMenosUnoCol
    jg      guardarUnoCol

    mov     qword[sentidoColumna],0
    jmp     finAnalizar
    guardarMenosUnoCol:
    mov     qword[sentidoColumna],-1
    jmp     finAnalizar
    guardarUnoCol:
    mov     qword[sentidoColumna],1
finAnalizar:
    ret
