%macro mPrintf 0
    sub     rsp,8
    call    printf
    add     rsp,8
%endmacro

%macro mAtoi 0
    sub     rsp,8
    call    atoi
    add     rsp,8
%endmacro

%macro mValidarChar 0
    sub     rsp,8
    ;call    validarChar
    add     rsp,8
%endmacro

%macro mValidarOrientacion 0
    sub     rsp,8
    call    validarOrientacion
    add     rsp,8
%endmacro

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
	
; se podria generalizar en otra rutina para no repetir
SolicitarParaOca:
    mov     rdi, msgOca
    mPrintf
	
    mov     rdi, SimboloOca
    mGets
	
    mov     rsi,SimboloOca
    mValidarChar

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

	mov     esi,orientacion
    mValidarOrientacion


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
