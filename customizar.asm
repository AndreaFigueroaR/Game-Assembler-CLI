%include macros.asm


global customizar
extern  puts
extern  printf
extern gets
extern  atoi
extern  validarOrientacion


section     .data
    msgError       db   "El caracter no es valido",0
    msgZorro		db	"Ingrese un caracter para representar al zorro (a-z, A-Z): ",0	
    msgOca		db	"Ingrese un caracter para representar a la oca (a-z, A-Z): ",0
    msgOrientacion		db	"Ingrese una orientacion para el tablero (Norte: 0, Este: 1, Sur: 2, Oeste: 3): ",0
    formatNum       db  "%d",10,0


section .bss
    dirZorro		resq	1
    dirOca		resq	1
    dirOrientacion		resq	1
	SimboloZorro		resq	1
	SimboloOca		resq	1
    orientacion		resq	1

	


section .text
; esta rutina se encarga de consultarle al usuario las customizaciones a realizar
customizar:
; almacenamos las direcciones pasadas para luego del ingreso usarlas para almacenar la customizaciones
    mov     [dirZorro],rdi ;rdi corresponde a la direccion del simbolo zorro
    mov     [dirOca],rsi ; rsi corresponde a la direccion del simbolo de la oca
    mov     [dirOrientacion],rcx ; rcx corresponde a la direccion donde se almacena cual es la orientacion

SolicitarParaZorro:
    mov     rdi, msgZorro
    mPrintf

    mov     rdi,SimboloZorro
    mGets 
	mov     al, [SimboloZorro]

    mov     esi,SimboloZorro
	mValidarChar

ChequeoZorro:
    cmp     rdi, '2'
    je     SolicitarParaZorro
	
; nos tomamos la libertad de que existe la posibilidad de que el zorro y la oca tengan el mismo simbolo 
SolicitarParaOca:
    mov     rdi, msgOca
    mPrintf
	
    mov     rdi, SimboloOca
    mGets
	
    mov     rsi,SimboloOca
    jmp	    ValidarChar

    cmp     rdi, '2'
    je     SolicitarParaOca

SolicitarOrientacion:
	mov     rdi, msgOrientacion
    mPrintf
	
    mov     rdi,orientacion
    mGets
    mov     rdi,orientacion
    mAtoi
mov     [orientacion],rax
; ya esta el numero almacenado en la rax luego del atoi que es la memoria utilizada para la validacion
; mov     esi,orientacion
    jmp	    ValidarOrientacion


    cmp     rdi, '2'
    je     SolicitarOrientacion
control:
    mov     rax,[dirZorro]
    mov     rsi,[SimboloZorro]
    mov     [rax],rsi
    mov     rsi,[SimboloOca]
    mov     rdi,[dirOca]
    mov     [rdi + 8],rsi
    mov     rax,[dirOrientacion]
    mov     rsi,[orientacion]
    mov     [rax],rsi

    ret

;_________________RUTINAS INTERNAS_________________________
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; en esta rutina externa nos encargamos de validar que lo ingresado lo consideremos
; un simbolo valido para customizar ambos personajes
; caracteres alfabetico

ValidarChar:
; linea innecesaria antes de llamar a la subrutina interna muevo al 'al' el simbolo
	mov		al,[rsi] ; la esi apunta a la direccion donde se almacena el simbolo a chequear

; a charlar que caracteres ASCII tomamos como validos
	cmp 	al, 'A'
	jl 	NoValido
	
	cmp 	al, 'Z'
	jle 	Valido

	cmp 	al, 'a'
	jl 	NoValido
	
	cmp 	al, 'z'
	jle  	Valido

NoValido:
	mov		rdi,msgError
	mov 	rdi,'2'
	jmp 	FIN

Valido:	
	mov	rdi, '1'

FIN:
	ret


; En esta rutina nos encargamos de validar que lo ingresado cumpla con las condiciones dadas
; sobre el dato para asi correr el juego, en este caso tomamos como valida la orientacion si ingresa
; 0 -> default, la concentracion de ocas se encuentra en el cuadrante de arriba
; 1 -> la concentracion de ocas se encuentra en el cuadrante de la derecha
; 2 -> la concentracion de ocas se encuentra en el cuandrante inferior
; 3 -> la concentraicon de ocas se encuentra en el cuadrante izquierdo

validarOrientacion:
Validar:
	;linea innecesaria ya muevo antes de llamar a la subrutina interna
	;mov		rax,[rsi] ; la esi apunta a la direccion de memoria donde se encuentra el simbolo a validar

	cmp 	rax,0
	je 	    Valido
	
	cmp 	rax,1
	je   	Valido

	cmp 	rax,2
	je   	Valido
	
	cmp 	rax,3
	je  	Valido

NoValido:
	mov		rdi,msg
	mPuts
	mov 	rdi,'2'
	jmp 	FIN

Valido:	
	mov	    rdi,'1'

FIN:
	ret
