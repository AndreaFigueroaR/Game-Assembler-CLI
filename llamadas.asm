llamadas.asm
extern puts
extern system
extern printf 

section     .data
    cmd_clear       db  "clear",0

;*****************************************************************************
;NUESTRAS MACROS CON LLAMADAS A RUTINAS EXTERNAS
;*****************************************************************************

%macro callRecoverGame 5
    ;Pre:recive direcciones de memoria para inicializar: [DirPosicionZorro, DirPosicionesOcas, dirCantOcasVivas, dirRotacion] en los registros por convenciòn
    ;Post: pregunta si se quiere recuperar el juego:
    ;      si no se quiere recuperar el juego se inicializan con valores estandar las mismas direcciones de memoria
    ;      si sì se quiere recuperar: 
    ;        si hay un archivo con la configuraciòn de nuestro juego llamado EstadoJuego.txt o csv cualquiera, se asignan a las direcciones de memoria los valores leidos del archivo
    ;        si no se pudo encontrar el supuesto archivo se muestra mensaje de error y se deja como una partida nueva

    mov RDI, %1
    mov RSI, %2
    mov RDX, %3
    mov RCX, %4

    sub     rsp,8
    call    ;;;;;;;
    add     rsp,8
%endmacro

%macro callCustomizeGame 3
    ;Pre: Recibe las direcciones de memoria para modificar: [DirSimboloZorro, DirSimboloOcas, DirRotacionTablero]
    ;Post: pregunta si se quiere customizar cada uno de los elementos que contienen las direcciones recibidas
    ;      si el usuario decide cambiar alguno se cambia, si no se deja como està

    mov RDI, %1
    mov RSI, %2
    mov RDX, %3

    sub     rsp,8
    call    ;;;;;
    add     rsp,8
%endmacro


;*****************************************************************************
;Auxiliares
;*****************************************************************************

%macro myPuts 0
    sub     rsp,8
    call    puts;
    add     rsp,8
%endmacro

%macro myPrintf 0
    sub     rsp,8
    call    printf
    add     rsp,8
%endmacro
%macro limpieza 0
    mov     rdi,cmd_clear
    sub     rsp,8
    call    system
    add     rsp,8
%endmacro

