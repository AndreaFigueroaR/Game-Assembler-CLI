
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
    mov     [dirEstadoPartida],     r8
    mov     [dirPosicionZorro],     rsi
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
    ;PRE: Recibe el rotulo de la posicion que se quiere buscar. Ejem: buscarOcaPorCoordenadas coordenadasOrigen, esta no puede ser las coordenadas auxiliares 
    ;POST:Deja en desplazVector el desplazamiento desde el inicio del vector
    mov                 rcx,[cantidadOcasVivas]
    mov                 qword[desplazVector],0
    copiarVector        2,%1,coordenadasAux
    sub                 rsp,8
    call                buscarOca
    add                 rsp,8
%endmacro

%macro modificarPosOca 0
    buscarOcaPorCoordenadas coordenadasOrigen
    mov                     rax,[dirPosicionesOcas]
	add                     rax,[desplazVector]
	copiarVector            2,coordenadasDestino,rax
%endmacro 

%macro modificarPosZorro 0
    mov                     rax,[dirPosicionZorro]
    copiarVector            2,coordenadasDestino,rax
%endmacro
 

%macro salvarCoordenadas 2
    ;PRE:recibe las direcciones que se van a salvar
    ;POST: las guarda en filAux y colAux (respectivamente)
    mov     r8,[%1]
    mov     [filAux],r8
    mov     r8,[%2]
    mov     [colAux],r8
%endmacro

%macro recuperarCoordenadas 2
    mov     r8,[filAux]
    mov     [%1],r8
    mov     r8,[colAux]
    mov     [%1],r8
%endmacro

%macro mMatarOca 0
    salvarCoordenadas       filOrigen,colOrigen
    sub     rsp,8
    call    matarOca
    add     rsp,8
    recuperarCoordenadas    filOrigen,colOrigen
%endmacro

%macro excluirOca 0
    dec                 qword[cantidadOcasVivas]
    mov                 r11,[cantidadOcasVivas]
    mov                 r10,[dirCantidadOcasVivas]
    mov                 [r10],r11
%endmacro 

%macro estadoGanaZorro 0
    mov     rdi,[dirEstadoPartida]
    mov     qword[rdi],1
%endmacro

%macro definirSaltoYSentidoMovida 0
    ;POST: setea el sentido de la jugada y si es que es salto o no
    salvarCoordenadas           filDestino,colDestino
    sub         rsp,8
    call        analizarMovida
    add         rsp,8
    recuperarCoordenadas        filDestino,colDestino
%endmacro 
