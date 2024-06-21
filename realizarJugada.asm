;se tiene que cambiar el estado(posicion) de la oca o del zorro que se moviò
;si se movio el zorro se debe ver si se comio alguna oca, si sì se setea como que no se cambia de turno, luego al inicio de cada
;luego se tiene que verificar que se halla acabado el turno del jugador actual (si son ocas siempre dura solo un turno, si es el zorro se debe verificar una )

%include "llamadas.asm"
%include "macrosRealizarJugada.asm"

global realizarJugada
section     .data
    murioOca            db      0

section     .bss
    ;por dato
    jugadorActual           resq    1   ;0 -> turno zorro, 1 -> turno ocas.
    infoCoordenadas         times   0   resb        ; Vector de la forma: [filOrigen, colOrigen, filDestino,colDestino]
        coordenadasOrigen               resq 2
        coordenadasDestino              resq 2
    cantidadOcasVivas       resq    1
    ;punteros
    dirCantidadOcasVivas    resq    1   
    dirPosicionesOcas       resq        ;[posFilOca1, posColOca1, ..., posFilOcaN, posColOcaN]
    dirPosicionZorro        resq    1
    dirJugadorActual        resq    1
    dirEstadisticas         resq    1
      
    ;auxiliares
    desplazVector                   resq    1
    cantElemVector                  resq    1
    dirBaseVector                   resq    1
    dirDestinoVector                resq    1
    coordenadasBuscadas times   0   
        filBuscada                  resq    1
        colBuscada                  resq    1


realizarJugada:
    guardarDatos
    ;moviendo jugador actual
    cmp                     qword[juagadorActual],0 ;->0 si es turno del zorro
    jne                     cambiarPosOcas
    mov                     rax,[dirPosicionZorro]
    copiarVector            2,coordenadasDestino,rax
    jmp                     ejecutarMovimiento
    cambiarPosOcas:
    buscarOcaPorCoordenadas coordenadasOrigen ;-
    ;necesito encontrar la direcciòn de la posiciòn de la oca que tiene  la misma posicion que coordenadas origen y a esa direcciòn llevarme la coordenada destino
    ejecutarMovimiento:
    ;se actualiza la info del jugador actual en base del las coordenadas copiadas

    ;si el jugador actual es el zorro se debe guardar lo que tenga como posicion actual en su info en la parte de posicionOrigen
    
    ;si es oca-> se cambia la posicion actual de la oca que indiue que està en el mismo liugar que la posicion de origen... y nada màs
    ;si es zorro-> si la nueva posicion es de un salto entonces se debe encontrar la oca que este en la posicion en el medio de estas(oca comida), se pisa la su posicion con la de la ultima oca viva, se disminuye la cantidad de ocas vivas, se cambia la posicion del zorro a la que indica la posicionDestino y se setea como 1 a "murioOca".
    ;               si no era un salto solo se cambia la psocion del zorro a la posicion indicada en posicionDestino
    
    ;ejecutadas las consecuencias del movimiento sobre el juego: 
    ;llamamos a estadisticas y actualizamos jugadorActual:       
        ;si murioOca==0 -> cambiamos de jugadorActual al opuesto
        ;si  murioOca!=0 -> se deja el jugadorActual

    ;fin

;__________________________________________________________
;**********************************************************
;                   RUTINAS INTERNAS
;__________________________________________________________
;**********************************************************

buscarOca::
    ;si ya la encontrè no sigo buscando=>el desplazamiento me dirà la direcciòn que le tengo que mnadar a copiar vector
    mov             r8,[desplazVector]
    mov             r9,[dirPosicionesOcas+r8];->tengo la fila
    ;si la fila no coincide->sgt oca
    cmp             r9,[filBuscada]
    jne             sgtOca
    ;si la columna no coincide->sgt oca
    add             r8,8
    mov             r9,[dirPosicionesOcas+r8];->tengo la columna
    cmp             r9,[colBuscada]
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
