macrosProcesarComando.asm
;*****************************************************************************
; MACROS PARA VALIDACION DE DATOS
;*****************************************************************************
%macro apruebaValidacionTotal 0
    mov byte[inputValido],  'S'
    jmp finValidacion
%endmacro

%macro movSeisParametros 6
    mov RDI,    %1
    mov RSI,    %2;
    mov RDX,    %3;
    mov RCX,    %4;
    mov R8,     %5;
    mov R9,     %6;
%endmacro
%macro movCuatroParametros 4
    mov RDI,    %1
    mov RSI,    %2;
    mov RDX,    %3;
    mov RCX,    %4;
%endmacro

%macro dirNumEnRango 3
    mov R10,             %1
    cmp qword[R10],      %2
    jl  finValidacion
    cmp qword[R10],      %3
    jg  finValidacion
%endmacro

%macro dirCharEnRango 3
    mov R10,            %1
    cmp byte[R10],      %2
    jl  finValidacion
    cmp byte[R10],      %3
    jg  finValidacion
%endmacro

;recibe el numero de fila y la direccion de inicio del vector con la posicion (ejmplo 50A)
%macro colProhididasPorFila 2
    mov     R10,            %2
    cmp     qword[R10],     %1
    jne %%passComparation
    ;contiene la fila indicada
    mov     RAX,            %2
    add     RAX,            8
    cmp     byte[RAX],      'A'
    je      finValidacion
    cmp     byte[RAX],      'B'
    je      finValidacion
    cmp     byte[RAX],      'F'
    je      finValidacion
    cmp     byte[RAX],      'G'
    je      finValidacion
%%passComparation:
%endmacro

;tendria que recibir la direccion donde inicia el vector de posicion(origen o destino)
%macro chequearPosicionEnTabla 1
    dirNumEnRango   %1, 1,  7

    mov     R8,     %1
    add     R8,     8
    dirCharEnRango R8,'A','G'

    colProhididasPorFila 1,%1
    colProhididasPorFila 2,%1
    colProhididasPorFila 6,%1
    colProhididasPorFila 7,%1
%endmacro

;recibo la direccion de donde inicia el vector de posicion, digamos 50A
%macro traducirLetra 1
    mov R8,%1
    add R8,8

    mov al,byte[R8];muevo el char a al
    ;reemplazo 
    mov qword[R8],1
    cmp al, 'A'
    je %%endMacro
    mov qword[R8],2
    cmp al, 'B'
    je %%endMacro
    mov qword[R8],3
    cmp al, 'C'
    je %%endMacro
    mov qword[R8],4
    cmp al, 'D'
    je %%endMacro
    mov qword[R8],5
    cmp al, 'E'
    je %%endMacro
    mov qword[R8],6
    cmp al, 'F'
    je %%endMacro
    mov qword[R8],7
%%endMacro:

%endmacro