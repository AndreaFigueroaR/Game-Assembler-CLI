
%macro copiarVector 3
    ;PRE: recibe el tamaño a copiar, la dir del vector DE DONDE se copiarà, y dir del vector DONDE se copiarà 
    mov         qword[cantElemVector],%1
    mov         [dirBaseVector],%2
    mov         qword[dirDestinoVector],%3

    sub         rsp,8
    call        guardarVector
    add         rsp,8

%endmacro

%macro  guardarDatos 0
    mov     [dirPosicionZorro],     rsi
    mov     [dirEstadisticas],      r8
    mov     [dirCantidadOcasVivas], rdi
    mov     r10,                    [rdi]
    mov     [cantidadOcasVivas],    r10
    add     rdi,                    16  ;<-offset para dir posicionesOcas
    mov     [dirPosicionesOcas],    rdi

    mov     [dirJugadorActual],     rcx
    mov     r10,                     [rcx]
    mov     [juagadorActual],       r10
    ;guardando coordenadas
    copiarVector                    4,rdx,infoCoordenadas
%endmacro

%macro buscarOcaPorCoordenadas 1
    ;PRE: Recibe el rotulo de la posicion que se quiere buscar. Ejem: buscarOcaPorCoordenadas coordenadasOrigen
    ;POST:Deja en desplazVector el desplazamiento desde el inicio del vector
    mov                 rcx,[cantidadOcasVivas]
    mov                 qword[desplazVector],0
    copiarVector        2,%1,coordenadasBuscadas
    sub                 rsp,8
    call                buscarOca
    add                 rsp,8
%endmacro
