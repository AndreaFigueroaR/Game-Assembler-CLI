section     .data
    cmd_clear       db  "clear",0

;*****************************************************************************
;NUESTRAS MACROS CON LLAMADAS A RUTINAS EXTERNAS
;*****************************************************************************

;Pre: Recibe las direcciones de memoria de las variables del juego para inicializar en el siguiente orden: infoOcas, infoZorro, 
;     jugadorActual, rotacionTablero, estadoPartida, estadisticas
;Pos: Recupera la ultima partida guardada si el usuario quiere y ademas esta existe. Sino crea una nueva inicializando las variables
;     con sus valores estandar.
%macro mRecuperacionPartida 6
    mov     r8,%1
    mov     r9,%2
    mov     r10,%3
    mov     r11,%4
    mov     r12,%5
    mov     r13,%6
    
    sub     rsp,8
    call    recuperacionPartida
    add     rsp,8
%endmacro

;Pre: Recibe las direcciones de memoria para modificar: infoOcas, infoZorro, rotacionTablero
;Pos: Pregunta si se quiere personalizar cada uno de los elementos que contienen las direcciones recibidas.
;     Si el usuario decide cambiar alguno se cambia, si no se deja como está.
%macro personalizarPartida 3
    sub     rsp,8
    call    ;;;;
    add     rsp,8
%endmacro

; Pre: Recibe las direcciones de memoria de las variables infoOcas, infoZorro, rotacionTablero
; Pos: Imprime por pantalla la tabla del juego con la información de las variables.
%macro imprimirTabla 3
    mov     RDI,%1
    mov     RSI,%2
    mov     RDX,%3
    sub     rsp,8
    call    imprimirTablero
    add     rsp,8
%endmacro

; Pre: Recibe las direcciones de memoria de las variables infoOcas, posicionZorro, infoCoordenadas, jugadorActual, estadisticas.
; Pos: Actualiza las variables según el comando ingresado por el usuario.
%macro mRealizarJugada 5

    mov     RDI, %1;->infoOcas
    mov     RSI, %2;->posicionZorro
    mov     RDX, %3;->infoCoordenadas
    mov     RCX, %4;->jugadorActual
    mov     R8,  %5;->estadisticas
    
    sub     rsp,8
    call    realizarJugada
    add     rsp,8
%endmacro

; Pre: Recibe el jugadorActual, las direcciones donde guardar las coordenadas de origen y destino, la direccion de estadoPartida, la direccion donde esta la infoZorro, la direccion donde esta la infoOcas.
; Post: Lee entrada, valida que sean coordenadas adecuadas para el juagadorActual o que sea el comenado para interrumpir la partida (si sì-> se modifica el estadoPartida)
;       guarda las coordenadas en las direcciones brindadas.
%macro mProcesarComando 6

    mov RDI,    %1;->jugador activo (solo la uso de lectura, ya que realizarJugada se encarga de editarlo)
    mov RSI,    %2;->dirOrigen
    mov RDX,    %3;->dirDestino 
    mov RCX,    %4;->dirEstadoPartida (la edito si se interrumpe el juego)
    mov R8,     %5;->dirInfoZorro
    mov R9,     %6;->dirInfoOcas

    sub RSP,    8
    call        procesarComando
    add RSP,    8
%endmacro

; Pre: Recibe las direcciones de memoria de las variables infoOcas, infoZorro, jugadorActual, estadoPartida.
; Pos: Actualiza el estado del juego según si el zorro esta acorralado o si ya murieron 12 ocas
%macro resultadoJuego 4
    sub     rsp,8
    call    ;;;;
    add     rsp,8
%endmacro

; Pre: Recibe la dirección de memoria de la variable estadoPartida.
; Pos: Imprime por pantalla el mensaje de fin del juego según el estado final del juego.
%macro imprimirMsgFinJuego 1
    sub     rsp,8
    call    ;;;;
    add     rsp,8
%endmacro

; Pre: Recibe la dirección de memoria de la variable estadisticas.
; Pos: Imprime por pantalla las estadisticas finales de los movimientos del zorro.
%macro mostrarEstadisticas 1
    sub     rsp,8
    call    ;;;;
    add     rsp,8
%endmacro

;Pre: Recibe las direcciones de memoria de las variables infoOcas, infoZorro, jugadorActual, rotacionTablero, 
;     estadoPartida, estadisticas.
;Pos: Guarda la partida guardando los datos de las variables en un archivo partida.txt. Si el archivo no existe,
;     lo crea, si no lo sobreescribe. 
%macro mGuardarPartida 6
    sub     rsp,8
    call    ;;;;
    add     rsp,8
%endmacro

;Pre: Recibe las direcciones de memoria de las variables de infoZorro, de la posicion anterior del zorro y 
;     de la posicion nueva.
;Pos: Actualiza los datos de las estadisticas segun las posiciones recibidas.
%macro mActualizarEstadisticas 3
    sub     rsp,8
    call    ;;;;
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

%macro mStrcmp 0
    sub     rsp,8
    call    strcmp
    add     rsp,8
%endmacro

%macro mSscanf 0
    sub     rsp,8
    call    sscanf
    add     rsp,8
%endmacro     
