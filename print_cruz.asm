%include "macros_cruz.asm"
global imprimirTablero
extern printf
extern puts


section     .data
    ;movimientos en la matriz
    despl           dq  0
    fil             dq  1
    col             dq  1
    ;impresiòn del tablero
    formato             db  "%s",0
    pared               dw  "#"
    salto               dw  10
    espacio             dw  " "

section     .bss   
    infoOcas                    times 0 resb            
        cantOcasVivas           resq    1
        simboloOcas             resq    1
        posicionesOcas          times   17  resq    2
    infoZorro                   times 0 resb 
        simboloZorro            resq    1
        posicionZorro           times   1   resq    2
    rotacionTablero             resq    1   ;0ª->0,90ª->1,180ª->2,270ª->3
        
    ;auxiliares de impresion
    esPar               resq    1   ;0 si es par, 1 si es impar
    punteroSimb         resq    1   
    desplazVector       resq    1
    cantElemVector      resq    1
    dirBaseVector       resq    1
    dirDestinoVector    resq    1
    etiquetaUbicacion   resb    1

section     .text
imprimirTablero:
    guardarEstadoJuego
    rotarPoscionesPersonajes
    mostrarUbicaciones
_mostrarSimbSiguiente:
    cmp                 qword[despl],225    ;tamaño real 15
    je                  fin
    actulizarIndicesMostrarUbiV
    cambiarSimbA        espacio
    esPar?              fil
    ;si es fila impar=>cambia a pared y quizás a espacio
    cmp                 qword[esPar],0
    jne                 _cambiarAPared
    esPar?              col
    cmp                 qword[esPar],0
    jne                 _cambiarAPared
    ubicarPersonajes

    jmp                 _imprimirSimb
    _cambiarAPared:
    cambiarSimbA        pared
    sub                 rsp,8
    call                convertirACruz
    add                 rsp,8

    _imprimirSimb:
    mostrarSimb

    inc                 qword[col]
    inc                 qword[despl]
    jmp                 _mostrarSimbSiguiente
fin:
    cambiarSimbA        salto
    mostrarSimb
ret

;_________________RUTINAS INTERNAS_________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rotarPosicionesOcas:   
    ;PRE: dirBaseVectos inicicializada con el ròtulo del vector de posiciones de las ocas. DEsplaz vector inicializado con 0
    ;POST: rota las posiciones de las ocas vivas (y las redimensiona)
    imul    r13,[cantOcasVivas],16
    cmp     r13,[desplazVector]
    je      finRotarOcas

    mov     r9,[desplazVector]
    mov     r10,[posicionesOcas+r9]  ;fil
    add     r9,8
    mov     r11,[posicionesOcas+r9]  ;col
    sub     r9,8

    sub     rsp,8
    call    rotarPosicion
    add     rsp,8

    add     qword[desplazVector],16
    jmp     rotarPosicionesOcas
    finRotarOcas:
    ret
;__________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rotarPosicion:
    ;Pre: r10, r11 con las posiciones que se manejan dentro del juego.r9 con el desplazamiento del vector de posiciones (si hay mas de una posiciòn, sino con 0)
    ;dirBaseVector con la direcciòn de la base del vector de posiciones que se quiere rotar
    ;Post: rota una posicion del tablero (y las redimensiona)
    cmp     qword[rotacionTablero],0
    je      finRotacion
    mov     rcx,[rotacionTablero]

    _starLoopRotacion:
            mov     r12,r11
            mov     r11,8
            sub     r11,r10
            mov     r10,r12
    loop    _starLoopRotacion

    finRotacion:
    imul    r10,2   ;redimensiòn a tablero real
    imul    r11,2
    mov     r13,[dirBaseVector]
    mov     [r13+r9],r10
    add     r9,8
    mov     [r13+r9],r11    ;guardando posiciòn real
    ret
;__________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
convertirACruz:
    ;Post: da la forma de cruz
    cmp     qword[fil],11
    jg      arribaOAbajo
    ;es lado superior?
    cmp     qword[fil],5
    jl      arribaOAbajo
    esPreciso:
    ret

    arribaOAbajo:;fil>11 o fil<5
    cmp     qword[col],11
    jg      actualizarAEspacio
    cmp     qword[col],5
    jl      actualizarAEspacio
    jmp     esPreciso

    actualizarAEspacio:
    cambiarSimbA    espacio
    jmp             esPreciso  
;__________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
actIndexMostrarUbiV:
    ;POST: actualiza fil y col, si es nueva fila muestra o espacio o la etiqueta de esa fila para el usuario (lateral izquierdo).
    cmp             qword[col],16;cmp si reinicia col (tamaño real 15)
    jne             actualizarFil
    mov             qword[col],1
    actualizarFil:
    imul            r8,qword[fil],15
    cmp             r8,[despl]
    jne             finActualizarIndices  ;Si no son iguales no es una nueva fila
    inc             qword[fil]
    cambiarSimbA    salto
    mostrarSimb

    sub     rsp,8
    call    mostrarLateralIzquierdo
    add     rsp,8
    finActualizarIndices:
    ret

;__________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mostrarLateralIzquierdo:
    ;POST: muestra la etiqueta vertical estando en una nueva fila (o espacio o una ubicaciòn)
    esPar?          fil
    cmp             qword[esPar],0        
    je              mostrarUbiV                 ;si es impar muestra espacio
    tripleEspacio
    ret   
    mostrarUbiV:                                ;si es par muestra ubiV y actualiza
    cambiarSimbA    espacio
    mostrarSimb
    cambiarSimbA    etiquetaUbicacion
    mostrarSimb
    cambiarSimbA    espacio     
    mostrarSimb
    cmp             qword[rotacionTablero],0    ;avanza o retrocede dependiendo de la rotaciòn
    je              avanzarV
    cmp             qword[rotacionTablero],1
    je              avanzarV
    dec             word[etiquetaUbicacion]
    jmp             finUbiV
    avanzarV:
    inc             word[etiquetaUbicacion]
    finUbiV:
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
coincidirZorro:
    ;POST: si la posicion actual es la del zorro, cambia el simbolo
    mov                 rax,0
    mov                 r9,[posicionZorro]
    cmp                 [fil],r9
    jne                 finCoincidirZorro
    mov                 rax,8
    mov                 r9,[posicionZorro+rax]
    cmp                 [col],r9
    jne                 finCoincidirZorro
    cambiarSimbA        simboloZorro
    finCoincidirZorro:
    ret
;__________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
coincidirOcas:
    ;POST: si la posicion actual es la de alguna OCA, cambia el simbolo
    mov                 rax,[desplazVector]
    mov                 r9,[posicionesOcas+rax]
    add                 rax,8
    cmp                 [fil],r9
    jne                 siguienteOca            ;si la fila es diferente, siguiente oca
    
    mov                 r9,[posicionesOcas+rax]
    cmp                 [col],r9
    jne                 siguienteOca            ;si la columna es diferente, siguiente oca
    cambiarSimbA        simboloOcas
    jmp                 finCoincidirOcas
    siguienteOca:
        add                 qword[desplazVector],16 ;analiza de a pares
    loop    coincidirOcas   
    finCoincidirOcas:
    ret
;__________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mostrarUbiHorizontal:
    ;POST: muestra las teiquetas horizonatales para ej jugador 
    mov             qword[desplazVector],7
    tripleEspacio                   ;espacio adicional para mostrar ubiV y separarlo de ubiV
    mov             byte[etiquetaUbicacion],"A"
    cmp             qword[rotacionTablero],0
    je              mostrarH
    mov             byte[etiquetaUbicacion],"7"
    cmp             qword[rotacionTablero],1
    je              mostrarH
    mov             byte[etiquetaUbicacion],"G"
    cmp             qword[rotacionTablero],2
    je              mostrarH
    mov             byte[etiquetaUbicacion],"1"
    mostrarH:
    cmp             qword[desplazVector],0
    je              finUbiH
    dec             qword[desplazVector]
    cambiarSimbA    espacio
    mostrarSimb     ;espacio entre casilla y casilla
    cambiarSimbA    etiquetaUbicacion
    mostrarSimb
    cmp             qword[rotacionTablero],0
    je              avanzarH
    cmp             qword[rotacionTablero],3
    je              avanzarH
    ;en otro caso, retrocede
    dec             word[etiquetaUbicacion]
    jmp             mostrarH
    avanzarH:
    inc             word[etiquetaUbicacion]
    jmp             mostrarH
    finUbiH:
    cambiarSimbA    salto
    mostrarSimb
    tripleEspacio
    ret
;__________________________________________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inicializarUbiV:  
    ;POST: Inicializa la primera ubicaciòn lateral izquierda para el usuario 
    mov             byte[etiquetaUbicacion],"1"
    cmp             qword[rotacionTablero],0
    je              finInicializarubiV
    mov             byte[etiquetaUbicacion],"A"
    cmp             qword[rotacionTablero],1
    je              finInicializarubiV
    mov             byte[etiquetaUbicacion],"7"
    cmp             qword[rotacionTablero],2
    je              finInicializarubiV
    mov             byte[etiquetaUbicacion],"G"
    finInicializarubiV:
    ret
