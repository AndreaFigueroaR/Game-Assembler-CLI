global CustomizeGame

extern consultaPersonalizar
extern customizar
extern puts

%macro mConsultarPersonalizar 0
    sub     rsp,8
    call    consultaPersonalizar
    add     rsp,8

%endmacro

%macro mCustomizar 0
    sub	    rsp,8
	call	customizar
	add	    rsp,8
%endmacro

%macro mPuts 0
    sub     rsp,8
    call    puts
    add     rsp,8 
%endmacro

section .data
    dirZorro		dq      0
	dirOca			dq      0
	dirOrien		dq      0
    CMNV            db      "Comando no valido",0
    CharNo          db      "N",0
    CharSi          db      "S",0
section .bss

section .text

CustomizeGame:

Consulta:
    mov     qword[dirZorro], rdi
    mov     qword[dirOca], rsi
    mov     qword[dirOrien], rdx

	mConsultarPersonalizar

; validacion de si desea personalizar

	cmp	    rdi, CharNo
	je 	    FIN
	
	cmp 	RDI, CharSi
	jne 	NoEsValido

	mCustomizar
NoEsValido:

	mov     rdi, CMNV
	mPuts
	jmp Consulta

; si es asi pasa a llamar a customizar 
	mCustomizar

FIN:
    ret