global consultaPersonalizar
extern puts
extern sscanf

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

section .data
	ResSI		db 	"S",0
	ResNO		db	"N",0
	msg		    db	"Desea personalizar?",0

section .bss

    respuesta	resb	50

section .text
consultaPersonalizar:
    mov     rdi,msg
    mPuts		

    mov     rdi,respuesta
    mSscanf	
; creo que es innecesario
    mov		rdi, [respuesta]
