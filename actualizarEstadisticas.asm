%include "macros.asm"

global actualizarEstadisticas

section     .data

section     .bss   
    coordOrigenZorro            resq 2                              ; Coordenada del tipo [fila, columna]
    coordDestinoZorro           resq 2                              ; Coordenada del tipo [fila, columna]
    indiceEstadAActualizar      resq 1                              ; Me guardo el indice de la posicion del vector a actualizar. Tomo el indice comenzando en 0.

    dirEstadisticas             resq 1
    dirCoordOrigenZorro         resq 1
    dirCoordDestinoZorro        resq 1

section     .text
actualizarEstadisticas:
    mov                 [dirEstadisticas],r8
    mov                 [dirCoordOrigenZorro],r9
    mov                 [dirCoordDestinoZorro],r10

;   Copio coordOrigenZorro en memoria
    mov                 rdi,[dirCoordOrigenZorro]
    mov                 rax,[rdi]
    mov                 [coordOrigenZorro],rax

    mov                 rdi,[dirCoordOrigenZorro]
    mov                 rax,[rdi+8]
    mov                 [coordOrigenZorro+8],rax
    
;   Copio coordDestinoZorro en memoria
    mov                 rdi,[dirCoordDestinoZorro]
    mov                 rax,[rdi]
    mov                 [coordDestinoZorro],rax

    mov                 rdi,[dirCoordDestinoZorro]
    mov                 rax,[rdi+8]
    mov                 [coordDestinoZorro+8],rax

;   Veo para dónde se movió, siendo que las estadisticas son de la forma: [adelante, atras, izq, der, adelante-izq, adelante-der, atras-izq, atras-der]
    ;Veo FILA
    mov                 rax,[coordDestinoZorro]
    cmp                 rax,[coordOrigenZorro]
    jl                  movAtras
    jg                  movAdelante
    ;Se quedo en la misma fila
    ;Veo COLUMNA
    mov                 rax,[coordDestinoZorro+8]
    cmp                 rax,[coordOrigenZorro+8]
    jl                  movIzq
    jg                  movDer
    ;Se quedo en su lugar, no hay estadisticas que actualizar
    jmp                 fin
    
    movIzq:
    mov                 qword[indiceEstadAActualizar],2
    jmp                 realizarActualizacion

    movDer:
    mov                 qword[indiceEstadAActualizar],3
    jmp                 realizarActualizacion
movAtras:
    ;Veo COLUMNA
    mov                 rax,[coordDestinoZorro+8]
    cmp                 rax,[coordOrigenZorro+8]
    jl                  movAtrasIzq
    jg                  movAtrasDer
    ;Se movio hacia abajo
    mov                 qword[indiceEstadAActualizar],1
    jmp                 realizarActualizacion
    
    movAtrasIzq:
    mov                 qword[indiceEstadAActualizar],6
    jmp                 realizarActualizacion
    
    movAtrasDer:
    mov                 qword[indiceEstadAActualizar],7
    jmp                 realizarActualizacion
movAdelante:
    ;Veo COLUMNA
    mov                 rax,[coordDestinoZorro+8]
    cmp                 rax,[coordOrigenZorro+8]
    jl                  movAdelanteIzq
    jg                  movAdelanteDer
    ;Se movio hacia adelante
    mov                 qword[indiceEstadAActualizar],0
    jmp                 realizarActualizacion
    
    movAdelanteIzq:
    mov                 qword[indiceEstadAActualizar],4
    jmp                 realizarActualizacion
    
    movAdelanteDer:
    mov                 qword[indiceEstadAActualizar],5
    jmp                 realizarActualizacion
realizarActualizacion:
    mov                 rax,[indiceEstadAActualizar]
    mov                 rsi,8
    imul                rsi                                     ; Multiplico por 8 porque cada qword son 8 bytes
    mov                 rdi,[dirEstadisticas]
    inc                 qword[rdi+rax]
fin:
    ret
