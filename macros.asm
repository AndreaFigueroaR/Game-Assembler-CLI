section     .data
    cmd_clear                   db              "clear",0
;   Impresión del mensaje de fin del juego
    msgGanoZorro                db              "PARTIDA TERMINADA: El zorro es el ganador!",0
    msgGanaronOcas              db              "PARTIDA TERMINADA: Las ocas son las ganadoras!",0
;   Impresión de estadísticas
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
    datoEstadistica             resq 2

;******************************************************************************************************************
; MACROS DEL MAIN
;******************************************************************************************************************

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
; Pos: Actualiza las variables según el comando ingresado por el usuario. Actualiza el estado del juego según si el zorro esta acorralado o si ya murieron 12 ocas
%macro mRealizarJugada 4

    mov     RDI, %1;->infoOcas
    mov     RSI, %2;->posicionZorro
    mov     RDX, %3;->infoCoordenadas
    mov     RCX, %4;->jugadorActual
    
    sub     rsp,8
    call    realizarJugada
    add     rsp,8
%endmacro

; Pre: Recibe el jugadorActual, las direcciones donde guardar las coordenadas de origen y destino, la direccion de estadoPartida, la direccion donde esta la infoZorro, la direccion donde esta la infoOcas.
; Post: Recibe input hasta que sea una acción válida: coordenadas adecuadas para el juagadorActual o comandos para interrumpir o guardar la partida, si lee comando para interrumpir la partida cambia el estado de la partida, si es un movimiento valido deja inicializadas las coordenadas.
%macro mProcesarComando 6

    mov RDI,    %1  ;->jugadorActual
    mov RSI,    %2  ;->dirInfoCoordenadas
    mov RDX,    %3  ;->dirEstadisticas
    mov RCX,    %4  ;->dirEstadoPartida 
    mov R8,     %5  ;->dirInfoOcas
    mov R9,     %6  ;->dirRotacion

    sub RSP,    8
    call        procesarComando
    add RSP,    8
%endmacro


; Pre: Recibe la dirección de memoria de la variable estadoPartida.
; Pos: Imprime por pantalla el mensaje de fin del juego según el estado final del juego.
%macro imprimirMsgFinJuego 1
    mov     rdi,%1              ; Copio la direccion de estadoPartida al rdi
    mov     rsi,[rdi]           ; Copio el contenido de estadoPartida al rsi

    cmp     rsi,1
    jne     ganaronOcas
    mov     rdi,msgGanoZorro
    jmp     fin
ganaronOcas:
    mov     rdi,msgGanaronOcas
finImprimirMsgFinJuego:
    mPuts
%endmacro

; Pre: Recibe la dirección de memoria de la variable estadisticas.
; Pos: Imprime por pantalla las estadisticas finales de los movimientos del zorro.
%macro mMostrarEstadisticas 1
    mov             rdi,msgEstadisticas
    mPuts
    mov             rdi,separador
    mPuts
;   Imprimo estadisticas
    xor             rbx,rbx                     ; Uso el registro rbx como auxiliar para recorrer el vector ya que printf preserva el contenido de este registro
    mov             rdi,msgEstMovAdelante
    imprimirEst     [%1]
    mov             rdi,msgEstMovAtras
    imprimirEst     [%1]
    mov             rdi,msgEstMovIzq
    imprimirEst     [%1]
    mov             rdi,msgEstMovDer
    imprimirEst     [%1]
    mov             rdi,msgEstMovAdelanteIzq
    imprimirEst     [%1]
    mov             rdi,msgEstMovAdelanteDer
    imprimirEst     [%1]
    mov             rdi,msgEstMovAtrasIzq
    imprimirEst     [%1]
    mov             rdi,msgEstMovAtrasDer
    imprimirEst     [%1]

    mov             rdi,separador
    mPuts
%endmacro

; Pre: Recibe la dirección de memoria de la variable estadisticas.
; Pos: Imprime por pantalla la estadistica actual.
%macro imprimirEst 1
    mov                 rax,[%1]                        ; Me guardo la direccion de memoria a estadisticas.
    mov                 rsi,[rax+rbx]                   ; Me guardo el dato de la estadistica actual en el rsi.
    mov                 [datoEstadistica],rsi
    mov                 qword[datoEstadistica+8],0
    mov                 rsi,[datoEstadistica]
    mPrintf
    add                 rbx,8
%endmacro

;Pre: Recibe las direcciones de memoria de las variables infoOcas, infoZorro, jugadorActual, rotacionTablero, 
;     estadoPartida y estadisticas.
;Pos: Guarda la partida guardando los datos de las variables en un archivo partida.txt. Si el archivo no existe,
;     lo crea, sino lo sobreescribe. 
%macro mGuardarPartida 6
    mov     r8,%1
    mov     r9,%2
    mov     r10,%3
    mov     r11,%4
    mov     r12,%5
    mov     r13,%6
    
    sub     rsp,8
    call    guardarPartida
    add     rsp,8
%endmacro

;Pre: Recibe las direcciones de memoria de las variables estadisticas, coordOrigenZorro y coordDestinoZorro.
;Pos: Actualiza los datos de las estadisticas segun la posicion anterior del zorro y la nueva.
%macro mActualizarEstadisticas 3
    mov     r8,%1
    mov     r9,%2
    mov     r10,%3
    
    sub     rsp,8
    call    actualizarEstadisticas
    add     rsp,8
%endmacro

;******************************************************************************************************************
; MACROS PARA IMPRIMIR EL TABLERO
;******************************************************************************************************************

%macro ubicarPersonajes 0
    ;ubicando zorro
    sub     rsp,8
    call    coincidirZorro
    add     rsp,8
    ;ubicando ocas
    mov     qword[desplazVector],0
    mov     rcx,[cantOcasVivas]
    sub     rsp,8
    call    coincidirOcas
    add     rsp,8
%endmacro

%macro cambiarSimbA 1
    ;cambia a què apunta punteroSimb al ròtulo recibido
    mov     r8,%1
    mov     [punteroSimb],r8
%endmacro

%macro esPar? 1
    mov     rax,[%1]
    ;verifica el menos significativo
    and     rax,1
    mov     [esPar],rax
%endmacro

%macro mostrarSimb 0
    ;muestra el simbolo apuntado en punteroSimb
    mov     rdi,formato
    mov     rsi,[punteroSimb]
    mov     byte[rsi+1],0   ;agregando fin de strings
    sub     rsp,8
    call    printf
    add     rsp,8
%endmacro

%macro ponerPuts 0
    sub     rsp,8
    call    puts
    add     rsp,8
%endmacro

%macro  mostrarUbicaciones 0
    ;POST: muestra la ubicacion horizontal e iniciliza la primer etiqueta vertical
    sub     rsp,8
    call    mostrarUbiHorizontal
    add     rsp,8
    sub     rsp,8
    call    inicializarUbiV
    add     rsp,8
%endmacro

%macro actulizarIndicesMostrarUbiV 0
    ;POST: actualiza los inidces y muetras (si es necesario) la ubicaciòn lateral (Sea letra numero o espacio)
    sub                 rsp,8
    call                actIndexMostrarUbiV
    add                 rsp,8
%endmacro

%macro tripleEspacio 0
    ;POST:muestra 3 espacios seguidos
    cambiarSimbA    espacio
    mostrarSimb
    mostrarSimb
    mostrarSimb
%endmacro 


%macro guardarEstadoJuego 0
    ;POST: guardar todos los vectores recibidos por registros RDI y RSI
    mov         [rotacionTablero],rdx
    mov         [dirBaseVector],rdi
    mov         qword[cantElemVector],36
    mov         qword[dirDestinoVector],infoOcas

    sub         rsp,8
    call        guardarVector
    add         rsp,8

    mov         [dirBaseVector],rsi
    mov         qword[cantElemVector],3
    mov         qword[dirDestinoVector],infoZorro

    sub         rsp,8
    call        guardarVector
    add         rsp,8
%endmacro

%macro rotarPoscionesPersonajes 0
    ;rotando zorro
    mov     r10,[posicionZorro]  ;fil
    mov     r9,8
    mov     r11,[posicionZorro+r9]  ;col
    mov     r9,0
    mov     qword[dirBaseVector],posicionZorro

    sub     rsp,8
    call    rotarPosicion
    add     rsp,8

    ;rotando Ocas
    mov     qword[dirBaseVector],posicionesOcas
    mov     qword[desplazVector],0

    sub     rsp,8
    call    rotarPosicionesOcas
    add     rsp,8
%endmacro

;******************************************************************************************************************
; MACROS PARA VALIDACION DE DATOS
;******************************************************************************************************************

;------------------------------------------------------------------------------------------------------------------
; OPERACIONES AUXILIARES
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

%macro calcularDistancia 2
    ;Pre: recibe dos números
    mov                 RAX,                %1
    mov                 RBX,                %2
    sub                 RAX,                RBX
    test                rax,                RAX
    jge                 %%fin    
    neg                 RAX
%%fin:
%endmacro

%macro puntoMedio 2
    mov                 rax, %1
    add rax, %2
    shr rax, 1        ; Dividir la suma por 2 quitando un digito a la representacion binaria
%endmacro
;------------------------------------------------------------------------------------------------------------------

%macro guardarParametros 0
    ;Pre: Se dejaron en los resgistros RDI,RSI,... los siguientes punteros y datos 
    ;   RDI    -> jugadorActual
    ;   RSI    -> DirInfoCoordenadas
    ;   RDX    -> DirEstadisticas
    ;   RCX    -> DirEstadoPartida
    ;   R8     -> DirInfoOcasYZorro
    ;   R9     -> DirRotacion
    ;Post: Guarda localmente los datos y punteros
    mov [jugadorActual],        RDI
    mov [dirPosicionOrigen],    RSI
    add RSI,                    16
    mov [dirPosicionDestino],   RSI
    mov [dirEstadisticas],      RDX 
    mov [dirEstadoPartida],     RCX
    mov [dirInfoOcas],          R8
    add R8,                     288
    mov [dirInfoZorro],         R8
    mov [dirRotacion],          R9
    
%endmacro

%macro pedirMovimiento 0
    ;Post: Segun el jugador actual muestra un mensaje antes de pedir el movimiento actual
    mov     RDI,            mensajePedirMovZorro
    cmp     qword[jugadorActual],   0
    je      %%imprimir
    mov     RDI,            mensajePedirMovOca
%%imprimir:
    mPrintf
    mov     RDI,            input
    mGets
%endmacro

;bien usado
%macro compararInput 1
;Pre: recibe la direccion del comando con quien se debe comparar
    mov     RDI,            input
    mov     RSI,            %1
    mStrcmp
%endmacro

%macro apruebaValidacionTotal 0
    mov byte[inputValido],  'S'
    jmp finValidacion
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
%endmacro 

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
    jne %%fin
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
%%fin:
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

    mov al, byte[R8]
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

;******************************************************************************************************************
; MACROS PARA REALIZAR JUGADA
;******************************************************************************************************************

;PRE: recibe el tamaño a copiar, la dir del vector DE DONDE se copiarà, y dir del vector DONDE se copiarà 
;POST: copia la cantidad de elementos indicados del vector que se recibiò en el segundo vector recibido
%macro copiarVector 3
    mov         qword[cantElemVector],%1
    mov         qword[dirBaseVector],%2
    mov         qword[dirDestinoVector],%3

    sub         rsp,8
    call        guardarVector
    add         rsp,8
%endmacro

;PRE: versor inicializado con la direcciòn a la que se quiere dar un paso
;POST: suma (1 paso) el versor a las coordenadas de origen (el resultado lo deja en coordenadas de origen)
%macro sumarVersorACoordenadasOrigen 0
    mov             r8,[filVersor]
    add             [filOrigen],r8
    mov             r8,[colVersor]
    add             [colVersor],r8
%endmacro 

;PRE:
;POST: Guarda los datos recibidos por registros en los respectivos rotulos (guarda punteros de los que se necesitan editar y copias de los que no)
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
    mov     [jugadorActual],       r10
    ;guardando coordenadas
    copiarVector                    4,rdx,infoCoordenadas
%endmacro

; PRE: Recibe el rotulo de la posicion que se quiere buscar. Ejem: buscarOcaPorCoordenadas coordenadasOrigen, esta no puede ser las coordenadas auxiliares 
; POST:Deja en desplazVector el desplazamiento desde el inicio del vector
%macro buscarOcaPorCoordenadas 1
    mov                 rcx,[cantidadOcasVivas]
    mov                 qword[desplazVector],0
    copiarVector        2,%1,coordenadasAux
    sub                 rsp,8
    call                buscarOca
    add                 rsp,8
%endmacro

;PRE:
;POST: modifica la posiciòn de la oca con la misma posiciòn de origen a las coordenadas de destino 
%macro modificarPosOca 0
    buscarOcaPorCoordenadas coordenadasOrigen
    mov                     rax,[dirPosicionesOcas]
	add                     rax,[desplazVector]
	copiarVector            2,coordenadasDestino,rax
%endmacro 

;PRE:
;POST: Cambia la coordenadas del del zorro a las coordenadas de destino (Ejecuta jugada)
%macro modificarPosZorro 0
    mov                     rax,[dirPosicionZorro]
    copiarVector            2,coordenadasDestino,rax
%endmacro

;PRE:recibe las direcciones que se van a salvar
;POST: las guarda en filAux y colAux (respectivamente)
%macro salvarCoordenadas 2
    mov     r8,[%1]
    mov     [filAux],r8
    mov     r8,[%2]
    mov     [colAux],r8
%endmacro

;PRE: recibe las direcciones (fil,col) donde dejar las coordenadas guardadas auxiliarmente
;POST: guardar en las direcciones recibidas las coordenadas guardadas
%macro recuperarCoordenadas 2
    mov     r8,[filAux]
    mov     [%1],r8
    mov     r8,[colAux]
    mov     [%1],r8
%endmacro

;PRE:
;POST: elimina a una oca del vector de posiciones (actualizando la cantidad de ocas vivas)
%macro mMatarOca 0
    sub     rsp,8
    call    matarOca
    add     rsp,8
%endmacro

;PRE:
;POST: descuenta a una oca viva (por copia y por puntero)
%macro excluirOca 0
    dec                 qword[cantidadOcasVivas]
    mov                 r11,[cantidadOcasVivas]
    mov                 r10,[dirCantidadOcasVivas]
    mov                 [r10],r11
%endmacro 

;PRE:
;POST: setea el sentido de la jugada (direcciòn a la que se desea mover) y si es que es salto o no (1 si es salto 0 caso contrario)
%macro definirSaltoYSentidoMovida 0
    salvarCoordenadas           filDestino,colDestino
    sub         rsp,8
    call        analizarMovida
    add         rsp,8
    recuperarCoordenadas        filDestino,colDestino
%endmacro 

;PRE: versor inicializado con la direcciòn en la que se quiere buscar una posiciòn libre para el zorro,
;coordenadas origen contiene la posiciòn desde la que se busca dar un paso (ya sea buscando desde la posicion del zorro o un paso en la misma dircciòn)
;POST: deja las flags para que je salte si es que hay una posiciòn libre dado un paso en la direcciòn indicada por el versor desde la posicison indicada en coordenadas origen
%macro calcularPosiblePosZorroEnUnSentido 0
    sumarVersorACoordenadasOrigen
    corregirCasoFueraTablero
    buscarOcaPorCoordenadas         coordenadasOrigen
    imul                            r8,qword[cantidadOcasVivas],16
    cmp                             r8,[desplazVector]          ;si son iguales=>posiciòn libre 
%endmacro 

;PRE:
;POST: si debe cambiar un caso fuera del tablero, lo hace. Si no, no 
%macro corregirCasoFueraTablero 0
    verificarPosEncruz              coordenadasOrigen
    cmp                             rax,1
    je                              %%finCorregir
    mov                             r10,[dirPosicionesOcas]
    copiarVector                    2,r10,coordenadasOrigen
    %%finCorregir:
%endmacro

;PRE: recibe solo coordenadas formadas con 1,0 o -1
;POST: deja las flags para je salte si se encontrò una posiciòn libre en la direcciòn indicada (desde la posiciòn actual del zorro)
%macro buscarPosLibreEndireccion 2
    mov             qword[filVersor],%1
    mov             qword[colVersor],%2
    sub             rsp,8
    call            zorroAcorraladoUnVersor
    add             rsp,8
    cmp             qword[haySgtMovida],1
%endmacro

;PRE: recibe el còdigo del ganador: 1 ganò el zorro, 2 ganaron las ocas
;POST: establece que la partida terminò (con el còdigo de quièn ganò recibido)
%macro estadoTerminaPartida 1
    mov     rdi,[dirEstadoPartida]
    mov     qword[rdi],%1
%endmacro

;PRE:
;POST: cambia el estado de la partida si detrmina que el zorro està acorralado
%macro mZorroAcorralado? 0
    sub         rsp,8
    call        zorroAcorraladoTotalemente
    add         rsp,8
%endmacro

%macro coordenadasDentroCuadrado 1
    mov R10,%1
    cmp qword[R10],     1
    jl  fueraCoordenadasDentroCuadrado

    cmp qword[R10+8],   1
    jl fueraCoordenadasDentroCuadrado
    
    cmp qword[R10],     7
    jg  fueraCoordenadasDentroCuadrado

    cmp qword[R10+8],   7
    jg fueraCoordenadasDentroCuadrado
    mov RAX,1
fueraCoordenadasDentroCuadrado:
    mov RAX,0
%endmacro

;pre: Recibe nun numero de fila sensible y la direccion de las coordenadas a validar
;post: Deja en RAX un 1 si es que estaba en rango y un cero si no estaba en rango
%macro colProhididasPorFila 2
    mov     RAX,            1;inicia como si sì estuviese en la cruz

    mov     R10,            %2;contiene la direccion de la tupla
    cmp     qword[R10],     %1;contiene un numero de fila sensible
    jne     finColProhididasPorFila
    
    add     R10,            8;para tener la direccion de la columna

    cmp     qword[R10],     1
    je      %%fueraCruz
    cmp     qword[R10],     2 
    je      %%fueraCruz
    cmp     qword[R10],     6
    je      %%fueraCruz
    cmp     qword[R10],     7 
    je      %%fueraCruz
    
%%fueraCruz:
    mov RAX,0

finColProhididasPorFila:
%endmacro
;Pre: Recibe la direccion donde inicia la tupla con las coordenadas x e Y
;Post:si la coordenada de origen esta en la cruz deja 1 en el rax si no està deja 0
%macro verificarPosEncruz 1
    coordenadasDentroCuadrado %1
    cmp RAX, 0
    je %%fuera

    colProhididasPorFila 1,%1
    cmp RAX,0
    je %%fuera
    colProhididasPorFila 2,%1
    cmp RAX,0
    je %%fuera
    colProhididasPorFila 6,%1
    cmp RAX,0
    je %%fuera
    colProhididasPorFila 7,%1
    cmp RAX,0
    je %%fuera

    mov RAX,1
    jmp finVerificarPosEncruz
%%fuera:
    mov RAX,0
finVerificarPosEncruz:
%endmacro

;******************************************************************************************************************
; MACROS PARA PERSONALIZAR PARTIDA
;******************************************************************************************************************
;Pre: Recibe las direcciones de memoria para modificar infoOcas, infoZorro, rotacionTablero en los registros
; rsi, rdi, rcx respectivamente.
;Pos: Pregunta por cada elemento a personalizar.
%macro mCustomizar 0
    sub     rsp,8
    call    customizar
    add     rsp,8
%endmacro


;******************************************************************************************************************
; AUXILIARES
;******************************************************************************************************************

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

%macro mSprintf 0
    sub     rsp,8
    call    sprintf
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

%macro mFPuts 0
    sub     rsp,8
    call    fputs
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
