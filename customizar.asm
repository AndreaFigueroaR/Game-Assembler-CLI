global customizar

extern puts
extern sscanf
extern ValidarChar
extern ValidarOrientacion

%macro mPuts 0
    sub     rsp,8
    call    puts
    add     rsp,8 
%endmacro

%macro  mSscanf 0
    sub     rsp,8
    call    sscanf
    add     rsp,8
%endmacro

%macro  mValidarChar 0
    sub	    rsp,8
	call 	ValidarChar
	add 	rsp,8
%endmacro

%macro mValidarOrientacion 0
	sub	    rsp,8
	call 	ValidarOrientacion
	add 	rsp,8
%endmacro

section .data
	msgZorro		db "Ingrese un simbolo para el zorro",0
	msgOca		    db "Ingrese un simbolo para la oca",0
	msgOrientacion	db "Ingrese orientacion",0
	ResSI		db 	"S",0
	ResNO		db	"N",0

    formatChar      db      "%c",0
    formatNum       db      "%d",0

    dirZorro		dq      0
	dirOca			dq      0
	dirOrien		dq      0

section .bss
	SimboloZorro 	resb 	50
	SimboloOca		resb	50
	orientacion		resb	50


section .text
; esta rutina se encarga de consultarle al usuario las customizaciones a realizar
customizar:
; almacenamos las direcciones pasadas para luego del ingreso usarlas para almacenar la customizaciones
	mov	    qword[dirZorro],rdi ;rdi corresponde a la direccion del simbolo zorro
	mov 	qword[dirOca], rsi ; rsi corresponde a la direccion del simbolo de la oca
	mov 	qword[dirOrien], rcx ; rcx corresponde a la direccion donde se almacena cual es la orientacion

SolicitarParaZorro:
	mov 	rdi, msgZorro
	mPuts

    mov     rdi,SimboloZorro
    mov     rsi, formatChar
	mSscanf 
	
	mValidarChar

	cmp 	rdi, ResNO
	je	    SolicitarParaZorro
	
; se podria generalizar en otra rutina para no repetir
SolicitarParaOca:
	mov 	rdi, msgOca
	mPuts
	
    mov     rdi, SimboloOca
    mov     rsi, formatChar
	mSscanf 
	
	mValidarChar

	cmp 	rdi, ResNO
	je	    SolicitarParaOca

SolicitarOrientacion:
    mov 	RDI, msgOrientacion
	mPuts
	
    mov     rdi, orientacion
    mov     rsi, formatNum
	mSscanf 
	
    mValidarOrientacion

	cmp 	RDI, ResNO
	je	    SolicitarOrientacion
; creo que es inneseario
	mov	    dword[dirZorro], SimboloZorro
	mov	    dword[dirOca], SimboloOca
	mov 	dword[dirOrien], orientacion

	ret
