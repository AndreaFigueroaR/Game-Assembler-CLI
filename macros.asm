extern puts
section     .data
    comandos                    db              "**************COMANDOS********************************************",10,"MOVIMIENTO",10,"  -Para especificar un movimiento indique (independientemente de la rotacion",10,"   elegida) primero la coordenada numèrica seguida de la alfabetica",10,"  -Movimiento de las ocas debe indicar origen->destino",10,"  -Movimiento del zorro solo indica destino",10,"INTERRUPCION",10,"  -Para interrumpir la partida indique (independientemente del jugador ",10,"   actual) : --interrumpir partida",10,"GUARDAR PARTIDA",10,"  -Para guardar el estado actual de la partida (sin interrumpir el juego ",10,"   actual) : --guardar partida",10,"******************************************************************",0
    sinOcaEnOrigen              db              "ERROR: No se encontrò una oca en la posicion de origen indicada.",10,0
    hayOcaEnDestino             db              "ERROR: Ya hay una oca en la posicion indicada.",10,0
    hayZorroEnDestino           db              "ERROR: El zorro ya se encuentra ocupando la posicion de destino indicada.",10,0
    OcaNoRetrocedeNiSalta       db              "ERROR: Las ocas no pueden retroceder ni dar saltos: avanzan y se mueven a los costados de uno en uno.",10,0
    cmd_clear                   db              "clear",0

;#############################################################################
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

;#############################################################################

;                               MACROS
;#############################################################################
;*****************************************************************************
;                       GUARDAR Y RECUPERAR PARTIDA
;*****************************************************************************
;Pre: Recibe las direcciones de memoria de las variables del juego para inicializar en el siguiente orden: infoOcas, infoZorro, 
;     jugadorActual, rotacionTablero, estadoPartida, estadisticas
;Pos: Recupera la ultima partida guardada si el usuario quiere y ademas esta existe. Sino crea una nueva inicializando las variables
;     con sus valores estandar.
%macro mRecuperacionPartida 6
    mov     R8,     %1
    mov     R9,     %2
    mov     R10,    %3
    mov     R11,    %4
    mov     R12,    %5
    mov     R13,    %6
    
    sub     RSP,    8
    call        recuperacionPartida
    add     RSP,    8
%endmacro

;Pre: Recibe las direcciones de memoria de las variables infoOcas, infoZorro, jugadorActual, rotacionTablero, 
;     estadoPartida y estadisticas.
;Pos: Guarda la partida guardando los datos de las variables en un archivo partida.txt. Si el archivo no existe,
;     lo crea, sino lo sobreescribe. 
%macro mGuardarPartida 6
    mov     R8,     %1
    mov     R9,     %2
    mov     R10,    %3
    mov     R11,    %4
    mov     R12,    %5
    mov     R13,    %6
    
    sub     RSP,    8
    call    guardarPartida
    add     RSP,    8
%endmacro

;#############################################################################
;*****************************************************************************
;                              LLAMADOS
;*****************************************************************************

;Pre: Recibe las direcciones de memoria para modificar: infoOcas, infoZorro, rotacionTablero
;Pos: Pregunta si se quiere personalizar cada uno de los elementos que contienen las direcciones recibidas.
;     Si el usuario decide cambiar alguno se cambia, si no se deja como está.
%macro mPersonalizarPartida 3
    mov     RDI,    %1
    mov     RSI,    %2
    mov     rcx,    %3

    sub     RSP,    8
    call    personalizarPartida
    add     RSP,    8
%endmacro

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

%macro mMostrarAcciones 0
    mov RDI,comandos
    sub RSP,8
    call puts
    add rsp,8
%endmacro

; Pre: Recibe las direcciones de memoria de las variables infoOcas, infoZorro, rotacionTablero
; Pos: Imprime por pantalla la tabla del juego con la información de las variables.
%macro mImprimirTabla 3
    mov     RDI,%1
    mov     RSI,%2
    mov     RDX,[%3]
    sub     rsp,8
    call    imprimirTablero
    add     rsp,8
%endmacro

%macro mRealizarJugada 5

    mov     RDI,    %1;->dirInfoOcas
    mov     RSI,    %2;->dirPosicionZorro
    mov     RDX,    %3;->dirInfoCoordenadas
    mov     RCX,    %4;->dirJugadorActual
    mov     R8,     %5 ;->dirEstadoPartida
    
    sub     RSP,    8
    call        realizarJugada
    add     RSP,    8
%endmacro

; Pre: Recibe la dirección de memoria de la variable estadoPartida.
; Pos: Imprime por pantalla el mensaje de fin del juego según el estado final del juego.
%macro imprimirMsgFinJuego 1
    mov     RDI,    %1              ; Copio la direccion de estadoPartida al RDI
    mov     RSI,    [RDI]           ; Copio el contenido de estadoPartida al RSI

    cmp     RSI,    1
    jne     ganaronOcas
    mov     RDI,    msgGanoZorro
    jmp     finImprimirMsgFinJuego
ganaronOcas:
    mov     RDI,    msgGanaronOcas
finImprimirMsgFinJuego:
    mPuts
%endmacro

; Pre: Recibe la dirección de memoria de la variable estadisticas.
; Pos: Imprime por pantalla las estadisticas finales de los movimientos del zorro.
%macro mMostrarEstadisticas 1
    mov             RDI,msgEstadisticas
    mPuts
    mov             RDI,separador
    mPuts
;   Imprimo estadisticas
    xor             rbx,rbx                     ; Uso el registro rbx como auxiliar para recorrer el vector ya que printf preserva el contenido de este registro
    mov             RDI,msgEstMovAdelante
    imprimirEst     %1
    mov             RDI,msgEstMovAtras
    imprimirEst     %1
    mov             RDI,msgEstMovIzq
    imprimirEst     %1
    mov             RDI,msgEstMovDer
    imprimirEst     %1
    mov             RDI,msgEstMovAdelanteIzq
    imprimirEst     %1
    mov             RDI,msgEstMovAdelanteDer
    imprimirEst     %1
    mov             RDI,msgEstMovAtrasIzq
    imprimirEst     %1
    mov             RDI,msgEstMovAtrasDer
    imprimirEst     %1

    mov             RDI,separador
    mPuts
%endmacro

; Pre: Recibe la dirección de memoria a la direccion de memoria de la variable estadisticas.
; Pos: Imprime por pantalla la estadistica actual.
%macro imprimirEst 1
    mov             RSI,[%1+RBX]                        ; Me guardo el dato de la estadistica actual en el RSI.
    mPrintf
    add             RBX,8
%endmacro

;Pre: Recibe las direcciones de memoria de las variables estadisticas, coordOrigenZorro y coordDestinoZorro.
;Pos: Actualiza los datos de las estadisticas segun la posicion anterior del zorro y la nueva.
%macro mActualizarEstadisticas 3
    mov     R8,     %1
    mov     R9,     %2
    mov     R10,    %3
    
    sub     RSP,    8
    call    actualizarEstadisticas
    add     RSP,    8
%endmacro

;*****************************************************************************
;MACROS PARA PROCESAR COMANDO
;*****************************************************************************

;PRE: Se dejaron en los resgistros RDI,RSI,... los siguientes punteros y datos   
;POST: Guarda localmente los datos y punteros
%macro guardarParametros 0
    mov [jugadorActual],        RDI     ;-> jugadorActual
    mov [dirPosicionOrigen],    RSI     ;-> DirInfoCoordandasOrigen (contiguo a las de destino) 
    add RSI,                    16      ;-> desplazamiento para obtener las coordenadas de destino
    mov [dirPosicionDestino],   RSI     ;-> DirInfoCoordandasDestino
    mov [dirEstadisticas],      RDX     ;-> DirEstadisticas 
    mov [dirEstadoPartida],     RCX     ;-> DirEstadoPartida
    mov [dirInfoOcas],          R8      ;-> DirInfoOcas(vector contiguo a la informacion del zorro)
    add R8,                     288     ;-> desplazamiento para obtener la direccion de la informacion del zorro 8+8+(17*2*8)=288
    mov [dirInfoZorro],         R8      ;-> DirInfoZorro
    mov [dirRotacion],          R9      ;-> DirRotacion
    mov byte[inputValido],      'N'     
    
%endmacro

;PRE:--
;POST: Segun el jugador actual muestra un mensaje y recibe input paara analizar la accion a realizar
%macro pedirMovimiento 0
    mov     RDI,            mensajePedirMovZorro
    cmp     qword[jugadorActual],   0
    je      %%imprimir
    mov     RDI,            mensajePedirMovOca
%%imprimir:
    mPrintf
    mov     RDI,            input
    mGets
%endmacro

;PRE:--
;POST: cambia el estado de la validacion a 'S' y salta al fin de la validaciòn
%macro apruebaValidacionTotal 0
    mov byte[inputValido],  'S'
    jmp finValidacion
%endmacro

;PRE: recibe la direccion del comando con con quien se debe comparar el input (el rotulo input apunta a la direcciòn de un string con el 0 al final).
;POST: Deja en el EAX el resultado de la comparaciòn: 0->son inguales.
%macro compararInput 1
    mov     RDI,            input
    mov     RSI,            %1
    mStrcmp
%endmacro

;PRE:--
;POST: Mueve a los registros determinados por convencion los 6 parametros recibidos. 
%macro movSeisParametros 6
    mov RDI,    %1
    mov RSI,    %2;
    mov RDX,    %3;
    mov RCX,    %4;
    mov R8,     %5;
    mov R9,     %6;
%endmacro

;PRE:--
;POST: Mueve a los registros determinados por convencion los 4 parametros recibidos. 
%macro movCuatroParametros 4
    mov RDI,    %1
    mov RSI,    %2;
    mov RDX,    %3;
    mov RCX,    %4;
%endmacro

;PRE: --
;POST:Calcula las direcciones para cada elemento de las tuplas (X,Y) de las coordenadas de origen y destino y las setea en los registros necesarios para usar scanff
%macro setParametrosScanOrigenYDestino 0
    mov     R8,     [dirPosicionOrigen]
    add     R8,     8
    mov     R9,     [dirPosicionDestino]
    add     R9,     8
    movSeisParametros       input,  formatoMovimientoOca,   qword[dirPosicionOrigen],   R8,     qword[dirPosicionDestino],  R9
%endmacro

;PRE: --
;POST:Calcula las direcciones para cada elemento de las tuplas (X,Y) de la coordenada origen  y las setea en los registros necesarios para usar scanff
%macro setParametrosScanDestino 0
    mov     R9,             [dirPosicionDestino]
    add     R9,     8
    movCuatroParametros     input,  formatoMovimientoZorro,   qword[dirPosicionDestino],  R9
%endmacro 

;PRE:recibe la direccion de un nùmero, un valor minimo y un valor maximo
;POST: Finaliza la validacion si el numero se salia de rango
%macro dirNumEnRango 3
    mov R10,             %1
    cmp qword[R10],      %2
    jl  finValidacion
    cmp qword[R10],      %3
    jg  finValidacion
%endmacro

;PRE:recibe la direccion de un char, un valor minimo('A') y un valor maximo ('G')
;POST: Finaliza la validacion si el char se salia de rango
%macro dirCharEnRango 3
    mov R10,            %1
    cmp byte[R10],      %2
    jl  finValidacion
    cmp byte[R10],      %3
    jg  finValidacion
%endmacro

;PRE: recibe el numero de fila y la direccion de inicio del vector con cordenadas(alfanumèricas) (el numero de tamaño qword)
;POST: Salta al final de la validacion si la coordenada representaba una posicion fuera de la cruz donde se juega
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

;PRE: Recibe la direccion donde se encuentra un vector de coordenadas de la forma '7A', (numero de tamaño qword y char de tamaño de un byte)
;POST: salta al final de la validacion si la coordenada no era una posicion vàlida dentro de la cruz donde se desarrolla el juego
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

;PRE: recibe la direccion donde inicia el vector de posicion que contiene la primera coordenada numerica (qword) y la segunda coordenada alfabètica un char(byte)
;POST:pisa, a partir de donde estaba el char el valor alfabetico con el valor numerico correspondiente (de tamaño qword)
%macro traducirLetra 1
    mov     R8,%1
    add     R8,8

    mov     al, byte[R8]

    mov     qword[R8],1     ;->piso el valor con 1, si era una A puedo dejar el valor y finalizar la asigmnacion
    cmp     al, 'A'
    je      %%finMacro

    mov     qword[R8],2
    cmp     al, 'B'
    je      %%finMacro

    mov     qword[R8],3
    cmp     al, 'C'
    je      %%finMacro

    mov     qword[R8],4
    cmp     al, 'D'
    je      %%finMacro

    mov     qword[R8],5
    cmp     al, 'E'
    je      %%finMacro

    mov     qword[R8],6
    cmp     al, 'F'
    je      %%finMacro

    mov     qword[R8],7
%%finMacro:
%endmacro

;PRE:El contenido de dirPosicionOrigen es de 2qwords (para dos numeros X e Y)
;POST:actualizo el puntero de la coordenada de origen con la ultima posicion del zorro
%macro actualizarPunteroOrigen 0
    mov RAX, [dirInfoZorro]
    mov RBX, [RAX+8]                ;->RBX contiene la posFilZorro
    mov RDX, [RAX+16]               ;->RDX contiene la posColZorro
    
    mov RDI, [dirPosicionOrigen]    ;->RDI tiene la direccion de coordenadasOrigen
    mov [RDI],RBX
    mov [RDI+8],RDX
%endmacro

;PRE:--
;POST:guarda localmente valores de datos con los que se necesita trabajar y hacer calculos de forma màs agil
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
 
;PRE: El vector minimo contiene 2*(cantidad de tuplas) celdas de tamaño qword con nùmeros  
;POST: Busca cuantas tuplas con los mismos valores X e Y hay en el vector apuntado por la direccion recibiday deja este valor en RAX. Tambièn deja el indice de la tupla coincidente en R8
%macro buscarCoincidenciaCoordenadas 5
    mov RSI, %1             ;-> Dirección de la matriz(vector de tuplas)
    mov RCX, %2             ;-> Número de tuplas en la matriz
    mov RBX, %3             ;-> X a buscar (valor numerico)
    mov R15, %4             ;-> Y a buscar (valor numerico)
    mov R14, %5             ;-> para parar al encontrar la primera coincidencia 0:no, 1:si

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

;PRE:Los rotulos n_ocas, x_origen e y_origen contienen numeros incializados de tamaño qword que representan una coordenada en la cruz 
;POST: Verifica que haya una oca en la coordenada de origen(x_origen, y_origen), si no muestra un mensaje indicando el error y salta al fin de la validacion
%macro unaOcaEnOrigen 0
    mov RSI,            qword[dirInfoOcas]
    add RSI,            16
    buscarCoincidenciaCoordenadas    RSI,    qword[n_ocas],     qword[x_origen],     qword[y_origen],    1
    cmp RAX,            1
    jne %%noHayOcaEnOrigen
    jmp %%fin
%%noHayOcaEnOrigen:
    mov RDI, sinOcaEnOrigen
    mPrintf
    jmp finValidacion
%%fin:
%endmacro

;PRE:Los rotulos n_ocas,  x_destino e y_destino contienen numeros incializados de tamaño qword que representan una coordenada en la cruz 
;POST: Verifica que no hayan alguna oca en la coordenada de destino(x_destino, y_destino), si la hay muestra un mensaje indicando el error y salta al fin de la validacion
%macro sinOcasEnDestino 0
    mov RSI,            qword[dirInfoOcas];
    add RSI,            16
    buscarCoincidenciaCoordenadas   RSI,    qword[n_ocas],    qword[x_destino],    qword[y_destino],    1
    cmp RAX,            0
    jne %%hayOcaEnDestino
    jmp %%fin
%%hayOcaEnDestino:
    mov RDI, hayOcaEnDestino
    mPrintf
    jmp finValidacion
%%fin:
%endmacro

;PRE:Los rotulos  x_destino e y_destino contienen numeros incializados de tamaño qword que representan una coordenada en la cruz 
;POST: Verifica que el zorro no estè en la coordenada de destino(x_destino, y_destino), si sì muestra un mensaje indicando el error y salta al fin de la validacion
%macro sinZorroEnDestino 0
    mov RSI,            qword[dirInfoZorro]
    add RSI,            8
    buscarCoincidenciaCoordenadas   RSI,    1,    qword[x_destino],    qword[y_destino],    1
    cmp RAX, 0
    jne %%HayZorroEnDestino
    jmp %%fin
%%HayZorroEnDestino:
    mov RDI, hayZorroEnDestino
    mPrintf
    jmp finValidacion
%%fin:
%endmacro

;PRE: Las coordenadas de origen y destino ya estan inicializadas
;POST: Valida que el movimiento que representa (origen)->(destino) està dentro de los movimientos vàlidos para una oca (paso simple adelante o al costado)
%macro movimientoAdelanteOCostado 0
    ;movimiento en el eje X: debe ser una posicion adelante
    mov                 RAX,                [x_destino]
    cmp                 RAX,                [x_origen]
    je                  %%validarMovCostado

    ;se mueve en el eje x(solo debe ser adelante)
    sub                 RAX,                [x_origen]
    cmp                 RAX,                1
    jne                 %%noSeMueveAdelante
    jmp                 %%validarSinMovLateral
%%noSeMueveAdelante:
    mov                 RDI,                OcaNoRetrocedeNiSalta
    mPrintf
    jmp                 finValidacion
%%validarSinMovLateral:
    ;si la diferencia si fue de uno ahora comparo las coordenadas Y: deben ser iguales (no se permiten movimientos diagonales)
    mov                 RAX,                [y_destino]
    cmp                 RAX,                [y_origen]
    jne                 finValidacion
    apruebaValidacionTotal


%%validarMovCostado:
    calcularDistancia   [y_destino],        [y_origen]
    cmp                 RAX,                1
    jne                 %%intentaSalto
    apruebaValidacionTotal
%%intentaSalto:
    mov                 RDI,                OcaNoRetrocedeNiSalta
    mPrintf
    jmp finValidacion
%endmacro

;PRE: recibe por paràmetro dos números
;POST: Deja en el resgistro Acumulador (RAX) el resultado de la distancia entre los dos numeros
%macro calcularDistancia 2
    mov                 RAX,                %1
    mov                 RBX,                %2
    sub                 RAX,                RBX
    test                rax,                RAX
    jge                 %%fin    
    neg                 RAX
%%fin:
%endmacro

;PRE:Recibe por parametro dos numeros
;POST: salta a finValidacion si la distancia entre los dos numeros no es ni 0 ni dos
%macro distanciaCeroODos 2
    calcularDistancia   %1,                 %2
    cmp                 RAX,                2
    je                  %%fin
    cmp                 RAX,                0
    je                  %%fin
    jmp                 finValidacion
%%fin:
%endmacro

;PRE: Recibe dos nùmeros a y b
;POST: Deja el resultado del punto medio (a+b)//2  en el RAX
%macro puntoMedio 2
    mov                 rax, %1
    add rax, %2
    shr rax, 1        ; Dividir la suma por 2 quitando un digito a la representacion binaria
%endmacro
    
;PRE: Las coordenadas de origen y destino ya estan inicializadas 
;POST: Valida que el movimiento que representa (origen)->(destino) està dentro de los movimientos vàlidos para el zorro (paso simples en cuaquier direccion y saltos si hay una oca en medio)
%macro movimientoSimpleOSalto 0
    calcularDistancia   qword[x_destino],   qword[x_origen]
    cmp                 RAX,                1
    jg                  %%validarSalto
    
    calcularDistancia   qword[y_destino],   qword[y_origen]
    cmp                 RAX,                1
    jg                  %%validarSalto
    apruebaValidacionTotal
    
%%validarSalto:
    ;valido la distancia del salto
    distanciaCeroODos   qword[x_destino],   qword[x_origen]
    distanciaCeroODos   qword[y_destino],   qword[y_origen]

    ;valido que halla una oca en el medio
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

;*****************************************************************************
;MACROS PARA IMPRIMIR CRUZ
;*****************************************************************************

%macro ubicarPersonajes 0
    ;ubicando zorro
    sub     rsp,8
    call    coincidirZorro          ;<-si la ubicaciòn actual de la matriz es la dle zorro, encunetra la coincidencia y cambia el sìmbolo a mostrar
    add     rsp,8
    ;ubicando ocas
    mov     qword[desplazVectorP],0 ;<-auxiliar para recorrer el vector de posiciones de Ocas de forma segura
    mov     rcx,[cantOcasVivas]     ;<-cantidad de posiciones de ocas con las que se compararà nen busqueda de una coincidencia con la    sub     rsp,8
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

;POST: muestra la ubicacion horizontal e iniciliza la primer etiqueta vertical
%macro  mostrarUbicaciones 0
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
    mov         qword[despl],0
    mov         qword[fil],1

    mov         [rotacionTablero],rdx
    mov         [dirBaseVectorP],rdi
    mov         qword[cantElemVectorP],36
    mov         qword[dirDestinoVectorP],infoOcas

    sub         rsp,8
    call        guardarVector
    add         rsp,8

    mov         [dirBaseVectorP],rsi
    mov         qword[cantElemVectorP],3
    mov         qword[dirDestinoVectorP],infoZorro

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
    mov     qword[dirBaseVectorP],posicionZorro

    sub     rsp,8
    call    rotarPosicion
    add     rsp,8

    ;rotando Ocas
    mov     qword[dirBaseVectorP],posicionesOcas
    mov     qword[desplazVectorP],0

    sub     rsp,8
    call    rotarPosicionesOcas
    add     rsp,8
%endmacro

;*****************************************************************************
;MACROS PARA REALIZAR JUGADA
;*****************************************************************************

;PRE: recibe el tamaño a copiar, la dir del vector DE DONDE se copiarà, y dir del vector DONDE se copiarà 
;POST: copia la cantidad de elementos indicados del vector que se recibiò en el segundo vector recibido.Deja DesplazVector limpio (0)
%macro copiarVector 3
    mov         qword[cantElemVector],  %1
    mov         qword[dirBaseVector],   %2
    mov         qword[dirDestinoVector],%3

    sub         rsp,8
    call        guardarVector
    add         rsp,8
    mov         qword[desplazVector],   0
%endmacro

;PRE: versor inicializado con la direcciòn a la que se quiere dar un paso
;POST: suma (1 paso) el versor a las coordenadas de origen (el resultado lo deja en coordenadas de origen)
%macro sumarVersorACoordenadasOrigen 0

    mov             r8,[filVersor]
    add             [filOrigen],r8
    mov             r8,[colVersor]
    add             [colOrigen],r8
%endmacro 

;PRE:
;POST: Guarda los datos recibidos por registros en los respectivos rotulos (guarda punteros de los que se necesitan editar y copias de los que no)
%macro  guardarDatos 0
    mov     qword[esSalto],             0
    mov     qword[haySgtMovida],        0
    mov     qword[iteradorBuscarOca],   0

    mov     [dirEstadoPartida],         r8
    mov     [dirPosicionZorro],         rsi
    mov     [dirCantidadOcasVivas],     rdi
    mov     r10,                        [rdi]
    mov     [cantidadOcasVivas],        r10
    add     rdi,                        16  ;<-offset para dir posicionesOcas
    mov     [dirPosicionesOcas],        rdi

    mov     [dirJugadorActual],         rcx
    mov     r10,                        [rcx]
    mov     [jugadorActual],            r10
    ;guardando coordenadas
    copiarVector                        4,rdx,infoCoordenadas
%endmacro

; PRE: Recibe el rotulo de la posicion que se quiere buscar. Ejem: buscarOcaPorCoordenadas coordenadasOrigen, esta no puede ser las coordenadas auxiliares 
; POST:Deja en desplazVector el desplazamiento desde el inicio del vector
%macro buscarOcaPorCoordenadas 1
    mov                 rcx,[cantidadOcasVivas]
    mov                 qword[desplazVector],0
    copiarVector        2,%1,coordenadasAux
    mov                 qword[iteradorBuscarOca],0

    sub                 rsp,8
    call                buscarOca
    add                 rsp,8
%endmacro


;PRE:
;POST: modifica la posiciòn de la oca con la misma posiciòn de origen a las coordenadas de destino 
%macro modificarPosOca 0
    mov                     qword[desplazVector],0
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

;PRE:recibe la direccion de un vector de dos numeros de tamaño qword cada uno
;POST: Verifica que las coordenadas nùmericas en el vector representen tuplas dentro del rango [1,7]x[1,7].
;      Deja en el RAX: 0->si està FUERA, 1->si està DENTRO DE CUADRADO
%macro coordenadasDentroCuadrado 1

    mov R10,%1
    mov RAX,1

    cmp qword[R10],     1
    jl  %%fuera

    mov R10,%1
    cmp qword[R10+8],   1
    jl %%fuera

    mov R10,%1
    cmp qword[R10],     7
    jg  %%fuera

    mov R10,%1
    cmp qword[R10+8],   7
    jg %%fuera

    mov RAX,1
    jmp %%fin
%%fuera:
    mov RAX,0
%%fin:
%endmacro
        
;PRE: Recibe nun numero de fila sensible (en la que se tendria que tener cuidado con el valor de la columna) y la direccion de las coordenadas a validar
;POST: Deja en RAX un 1 si es que estaba en rango y un cero si no estaba en rango
%macro colProhididasPorFilaNum 2
    mov     RAX,            1       ;-> inicia como si sì estuviese en la cruz

    mov     R10,            %2      ;-> contiene la direccion de la tupla
    cmp     qword[R10],     %1      ;-> contiene un numero de fila sensible
    jne     %%fin                   ;-> si la coordenada no tenia de fila esta fila sensible entonces las columnas no representarìan un problema sea cual sea su valor
    
    ;si es que coincidiò la fila de la coordenada recibida con la fila sensible indicada entonces se debe validar la columna de la coordenada
    add     R10,            8       ;-> desplazamiento para tener la direccion de la columna
    
    ;la columna no puede valer 1,2,6,7. Se verifica que no sea ninguna:
    cmp     qword[R10],     1
    je      %%fueraCruz

    cmp     qword[R10],     2 
    je      %%fueraCruz

    cmp     qword[R10],     6
    je      %%fueraCruz

    cmp     qword[R10],     7 
    je      %%fueraCruz
    
    mov     RAX,1
    jmp     %%fin
%%fueraCruz:
    mov RAX,0

%%fin:
;0->FUERA CRUZ, 1->DENTRO
%endmacro

;PRE: Recibe la direccion donde inicia la tupla con las coordenadas x e Y (numeros de tamaño qword)
;POST:si la coordenada de origen esta en la cruz deja 1 en el rax si no està deja 0
%macro verificarPosEncruz 1
    coordenadasDentroCuadrado %1            ;-> valida que las coordenadas (X e Y) esten dentro de rango [1,7]
    cmp RAX, 0
    je %%fuera

    ;para cada valor posible de filas "sensibles"(en la que la columna n puede valer cualquier numero entre 1 y 7) :1,2,6,7
    ;se valida que la coordenada no estè fuera de la cruz
    colProhididasPorFilaNum 1,%1
    cmp RAX,0
    je %%fuera

    colProhididasPorFilaNum 2,%1
    cmp RAX,0
    je %%fuera

    colProhididasPorFilaNum 6,%1
    cmp RAX,0
    je %%fuera

    colProhididasPorFilaNum 7,%1
    cmp RAX,0
    je %%fuera

    mov RAX,1
    jmp %%fin
%%fuera:
    mov RAX,0
%%fin:
    ;si RAX contiene: 1->Dentro CRUZ, 0->FUERA CRUZ
%endmacro

    %macro mGuardarSentidoMovida 0
        sub     rsp,8
        call    guardarSentidoMovida
        add     rsp,8
    %endmacro

;******************************************************************************************************************
; MACROS PARA PERSONALIZAR PARTIDA
;******************************************************************************************************************

;Pre: Recibe las direcciones de memoria para modificar infoOcas, infoZorro, rotacionTablero en los registros
; RSI, rdi, rcx respectivamente.
;Pos: Pregunta por cada elemento a personalizar.
%macro mCustomizar 0
    sub     RSP,8
    call    customizar
    add     RSP,8
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
