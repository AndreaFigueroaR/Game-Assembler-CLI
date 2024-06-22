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
    ;verificarPosEncruz              ;<- verifica que la coordenada de origen estè en la cruz si no està la cambia por cualquier posiciòn de oca viva (la primera en todo caso)
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

%macro coordenadasDentroCuadrado 1
    mov R10,%1
    cmp qword[R10],     1
    jl  %%fuera

    cmp qword[R10+8],   1
    jl %%fuera
    
    cmp qword[R10],     7
    jg  %%fuera

    cmp qword[R10+8],   7
    jg %%fuera
    mov RAX,1
%%fuera:
    mov RAX,0
%endmacro

;pre: Recibe nun numero de fila sensible y la direccion de las coordenadas a validar
;post: Deja en RAX un 1 si es que estaba en rango y un cero si no estaba en rango
%macro colProhididasPorFila 2
    mov     RAX,            1;inicia como si sì estuviese en la cruz

    mov     R10,            %2;contiene la direccion de la tupla
    cmp     qword[R10],     %1;contiene un numero de fila sensible
    jne     %%fin
    
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

%%fin:
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
    jmp %%fin
%%fuera:
    mov RAX,0
%%fin:
%endmacro
