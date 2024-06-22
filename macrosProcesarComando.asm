macrosProcesarComando.asm
;*****************************************************************************
; MACROS PARA VALIDACION DE DATOS
;*****************************************************************************
%macro guardarParametros 0
    ;Pre: Se dejaron en los resgistros RDI,RSI,... los siguientes punteros y datos 
        ;RDI    ->jugadorActual
        ;RSI    ->dirInfoCoordenadas
        ;RDX    ->dirEstadisticas
        ;RCX    ->dirEstadoPartida
        ;R8     ->dirInfoZorro
        ;R9     ->dirInfoOcas
    ;Post: Guarda localmente los datos y punteros
    mov [jugadorActual],        RDI
    mov [dirPosicionOrigen],    RSI
    add RSI,                    16
    mov [dirPosicionDestino],   RSI
    mov [dirEstadisticas],      RDX 
    mov [dirEstadoPartida],     RCX
    mov [dirInfoZorro],         R8
    mov [dirInfoOcas],          R9
    
%endmacro

%macro pedirMovimiento 0
    ;Pre: Segun el jugador actual muestra un mensaje antes de pedir el movimiento actual
    ;Post:
    mov     RDI,            mensajePedirMovZorro
    cmp     qword[jugadorActual],   0
    je      %%imprimir
    mov     RDI,            mensajePedirMovOca

%%imprimir:
    mPrintf
    mov     RDI,            input
    mGets
%endmacro

%macro compararInput 1
;lleva a cabo el strcmp y deja en el RAX el resultado de la comparacion
;recibe la direccion del comando con quien se debe comparar
    mov     RDI,            input
    mov     RSI,            %1
    mStrcmp
%endmacro



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
%macro setParametrosScanOrigenYDestino 0
    mov     R8,     [dirPosicionOrigen]
    add     R8,     8
    mov     R9,     [dirPosicionDestino]
    add     R9,     8
    movSeisParametros       input,  formatoMovimientoOca,   qword[dirPosicionOrigen],   R8,     qword[dirPosicionDestino],  R9
%endmacro

%macro setParametrosScanDestino 0
    mov     R9,             [dirPosicionDestino]
    add     R9,     8
    movCuatroParametros     input,  formatoMovimientoOca,   qword[dirPosicionDestino],  R9
%macro 


%macro actualizarPunteroOrigen 0
    mov RAX, [dirInfoZorro]
    mov RBX, [RAX+8];->RBX contiene la posFilZorro
    mov RDX, [RAX+16];->RDX contiene la posColZorro
    
    mov RDI, [dirPosicionOrigen];->RDI tiene la direccion de coordenadasOrigen
    mov [RDI],RBX
    mov [RDI+8],RDX
%endmacro
%macro guardarDatosOrigenYDestino 0
;inicializa en memoria los valores de las coordenadas de origen X e Y
    mov     R8,             [dirPosicionOrigen]
    mov     R9,             [R8]    
    mov     [x_origen],     R9
    mov     R10,            [R8+8]  
    mov     [y_origen],     R10

;inicializa en memoria los valores de las coordenadas de destino X e Y
    mov     R8,             [dirPosicionDestino]
    mov     R9,             [R8]                
    mov     [x_destino],    R9
    mov     R10,            [R8+8]   
    mov     [y_destino],    R10

;guardo la cantidad de ocas vivas
    mov     RSI, [dirInfoOcas]
    mov     RDI,[RSI]
    mov     [n_ocas],RDI
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
%macro chequearPosEnCruz 1
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
    je %%finMacro
    mov qword[R8],2
    cmp al, 'B'
    je %%finMacro
    mov qword[R8],3
    cmp al, 'C'
    je %%finMacro
    mov qword[R8],4
    cmp al, 'D'
    je %%finMacro
    mov qword[R8],5
    cmp al, 'E'
    je %%finMacro
    mov qword[R8],6
    cmp al, 'F'
    je %%finMacro
    mov qword[R8],7
%%finMacro:

%endmacro
;probado
%macro buscarCoincidenciaCoordenadas 5
;DEJA LOS RESULTADOS DE LA CUENTA EN EL RAX Y EL INDICE DE COINCIDENCIA EN R8
    ; %1 -> Dirección de la matriz(vector de tuplas)
    ; %2 -> Número de tuplas en la matriz
    ; %3 -> X a buscar
    ; %4 -> Y a buscar
    ; %5 -> para parar al encontrar la primera coincidencia 0->no, 1->si

    mov RSI, %1
    mov RCX, %2
    mov RBX, %3
    mov R15, %4
    mov R14, %5

    xor RDI, RDI
    xor RAX, RAX
    mov R8, -1

%%siguienteTupla:
    cmp     RCX,    0 
    je      %%fin              

    imul    R12,    RDI,    16      
    mov     R9,     [RSI + R12]
    mov     R11,    [RSI + R12 + 8]

    cmp     R9,     RBX 
    jne     %%noIgual
    cmp     R11,    R15             
    jne     %%noIgual               
    inc     RAX                     
    cmp     R8,     -1              
    jne     %%noIgual 

    mov     R8,     RDI 

    cmp     R14,    1
    je      %%fin 

%%noIgual:
    inc     RDI    
    loop    %%siguienteTupla    

%%fin:
%endmacro

%macro unaOcaEnOrigen 0
    mov RSI,            qword[dirInfoOcas]
    add RSI,            16
    buscarCoincidenciaCoordenadas    RSI,    qword[n_ocas],     qword[x_origen],     qword[y_origen],    1
    cmp RAX,            1
    jne finValidacion
%endmacro

%macro sinOcasEnDestino 0
    mov RSI,            qword[dirInfoOcas];
    add RSI,            16
    buscarCoincidenciaCoordenadas   RSI,    qword[n_ocas],    qword[x_destino],    qword[y_destino],    1
    cmp RAX,            0
    jne finValidacion
%endmacro

%macro sinZorroEnDestino 0
    mov RSI,            qword[dirInfoZorro]
    add RSI,            8
    buscarCoincidenciaCoordenadas   RSI,    1,    qword[x_destino],    qword[y_destino],    1
    cmp RAX, 0
    jne finValidacion

%endmacro

%macro calcularDistancia 2
    ; Pre: recibe  %1 - primer número, %2 - segundo número
    ;Post: Calcula la distancia y deja el resultado en el registro RAX
    mov                 RAX,                %1
    mov                 RBX,                %2
    sub                 RAX,                RBX
    test                rax,                RAX
    jge                 %%fin    
    neg                 RAX
%%fin:
%endmacro
%macro movimientoAdelanteOCostado 0
    ;movimiento en el eje X: debe ser una posicion adelante
    mov                 RAX,                [x_destino]
    cmp                 RAX,                [x_origen]
    je                  %%validarMovCostado
    sub                 RAX,                [x_origen]
    cmp                 RAX,                1
    jne                 finValidacion
    ;si la diferencia si fue de uno ahora debo comparar las coordenadas Y
    mov                 RAX,                [y_destino]
    cmp                 RAX,                [y_origen]
    jne                 finValidacion
    apruebaValidacionTotal
%%validarMovCostado:
    calcularDistancia   [y_destino],        [y_origen]
    cmp                 RAX,                1
    jne                 finValidacion
    apruebaValidacionTotal
%endmacro
%macro distanciaCeroODos 2
    calcularDistancia   %1,                 %2
    cmp                 RAX,                2
    je                  %%fin
    cmp                 RAX,                0
    je                  %%fin
    jmp                 finValidacion
%%fin:
%endmacro
%macro puntoMedio 2
    mov                 rax, %1
    add rax, %2
    shr rax, 1        ; Dividir la suma por 2 quitando un digito a la representacion binaria
%endmacro

%macro movimientoSimpleOSalto 0
    calcularDistancia   qword[x_destino],   qword[x_origen]
    cmp                 RAX,                1
    jg                  %%validarSalto
    calcularDistancia   qword[y_destino],   qword[y_origen]
    cmp                 RAX,                1
    jg                  %%validarSalto
    apruebaValidacionTotal
%%validarSalto:
    distanciaCeroODos   qword[x_destino],   qword[x_origen]
    distanciaCeroODos   qword[y_destino],   qword[y_origen]
    puntoMedio          qword[x_destino],   qword[x_origen]
    mov                 R8,                 RAX
    puntoMedio          qword[y_destino],   qword[y_origen]
    mov                 R9,                 RAX
    mov                 RSI,                qword[dirInfoOcas];
    add                 RSI,                16
    buscarCoincidenciaCoordenadas           RSI,    qword[n_ocas],     R8,     R9,    1
    cmp                 RAX,                1
    jne                 finValidacion
    apruebaValidacionTotal
%endmacro
