%include "llamadas.asm"

%macro mImprimirEstadistica 0
    mov                 rax,[dirEstadisticas]
    mov                 rsi,[rax+rbx]
    mov                 [dato],rsi
    mov                 qword[dato+8],0
    mov                 rsi,[dato]
    mPrintf
    add                 rbx,8
%endmacro

global mostrarEstadisticas
extern puts
extern printf

section     .data
    msgEstadisticas             db              "Estadísticas de los movimientos realizados por el zorro:",0
    msgEstMovAdelante           db              "Adelante: %d",10,0
    msgEstMovAtras              db              "Atras: %d",10,0
    msgEstMovIzq                db              "Izquierda: %d",10,0
    msgEstMovDer                db              "Derecha: %d",10,0
    msgEstMovAdelanteIzq        db              "Adelante-Izquierda: %d",10,0
    msgEstMovAdelanteDer        db              "Adelante-Derecha: %d",10,0
    msgEstMovAtrasIzq           db              "Atras-Izquierda: %d",10,0
    msgEstMovAtrasDer           db              "Atras-Derecha: %d",10,0
    separador                   db              "------------------------------------------------------------",0

section     .bss   
    dirEstadisticas             resq 1
    dato                        resq 2

; Estadisticas: [adelante, atras, izq, der, adelante-izq, adelante-der, atras-izq, atras-der]
section     .text
mostrarEstadisticas:
    mov                 [dirEstadisticas],r8

    mov                 rdi,msgEstadisticas
    mPuts

    mov                 rdi,separador
    mPuts

;   Imprimo estadisticas
    xor                 rbx,rbx                 ; Uso el registro rbx como auxiliar para recorrer el vector ya que printf preserva el contenido de este registro
    ;Adelante
    mov                 rdi,msgEstMovAdelante
    mImprimirEstadistica
    ;Atras
    mov                 rdi,msgEstMovAtras
    mImprimirEstadistica
    ;Izquierda
    mov                 rdi,msgEstMovIzq
    mImprimirEstadistica
    ;Derecha
    mov                 rdi,msgEstMovDer
    mImprimirEstadistica
    ;Adelante-Izquierda
    mov                 rdi,msgEstMovAdelanteIzq
    mImprimirEstadistica
    ;Adelante-Derecha
    mov                 rdi,msgEstMovAdelanteDer
    mImprimirEstadistica
    ;Atras-Izquierda
    mov                 rdi,msgEstMovAtrasIzq
    mImprimirEstadistica
    ;Atras-Derecha
    mov                 rdi,msgEstMovAtrasDer
    mImprimirEstadistica

    mov                 rdi,separador
    mPuts

    ret
