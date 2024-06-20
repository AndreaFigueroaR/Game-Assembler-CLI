llamadas.asm
extern puts
extern system
extern printf 
extern fopen
extern fgets
extern fclose

section     .data
    cmd_clear       db  "clear",0

;*****************************************************************************
;NUESTRAS MACROS CON LLAMADAS A RUTINAS EXTERNAS
;*****************************************************************************

;Pre: recibe las direcciones de memoria de las variables del juego para inicializar en el siguiente orden: infoOcas, infoZorro, 
;     jugadorActual, rotacionTablero, estadoPartida, estadisticas
;Pos: recupera la ultima partida guardada si el usuario quiere y ademas esta existe. Sino crea una nueva inicializando las variables
;     con sus valores estandar.
%macro recuperacionPartida 6
    sub     rsp,8
    call    preguntarRecuperarPartida ; deja en orden las inicializaciones en los registros: r8, r9, r10, r11, r12, r13

    mov     %1,r8
    mov     %2,r9
    mov     %3,r10
    mov     %4,r11
    mov     %5,r12
    mov     %6,r13
%endmacro

;requirimiento 3
%macro personalizarPartida 3
    ;Pre: Recibe las direcciones de memoria para modificar: infoOcas, infoZorro, rotacionTablero
    ;Post: pregunta si se quiere customizar cada uno de los elementos que contienen las direcciones recibidas
    ;      si el usuario decide cambiar alguno se cambia, si no se deja como està

    mov RDI, %1
    mov RSI, %2
    mov RDX, %3

    sub     rsp,8
    call    ;;;;;
    add     rsp,8
%endmacro
%macro imprimirTabla 3
    ;Pre: Recibe las direcciones de memoria de la informaciòn a imprimir en el tablero: infoOcas, infoZorro, rotacionTablero
    ;Post: Imprime el tablero de acuerdo a la rotacion indicada con la respectiva informaciòn de cada personaje

    mov     RDI,%1      ;dirInfoOcas
    mov     RSI,%2      ;dirInfoZorro
    mov     RDX,[%3]    ;rotacion
    
    sub     rsp,8
    call    ;imprimirJuego
    add     rsp,8
%endmacro

;*****************************************************************************
;Auxiliares
;*****************************************************************************

%macro mPuts 0
    sub     rsp,8
    call    puts
    add     rsp,8 
%endmacro

%macro mGets 0
    sub     rsp,8
    call    gets
    add     rsp,8
%endmacro

%macro mAtoi 0
    sub     rsp,8
    call    atoi
    add     rsp,8
%endmacro

%macro mPrintf 0
    sub     rsp,8
    call    printf
    add     rsp,8
%endmacro

%macro mClear 0
    mov     rdi,cmd_clear
    sub     rsp,8
    call    system
    add     rsp,8
%endmacro

%macro mFOpen 0
    sub     rsp,8
    call    fopen
    add     rsp,8
%endmacro

%macro mFGets 0
    sub     rsp,8
    call    fgets
    add     rsp,8
%endmacro

%macro mFClose 0
    sub     rsp,8
    call    fclose
    add     rsp,8
%endmacro
