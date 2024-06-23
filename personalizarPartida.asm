%include macros.asm

global  personalizarPartida
extern  puts
extern  printf
extern gets

section     .data
    inicio		db	"Personalizar",0
    CMNV		db	"Comando no valido",0
    msg		db	"Desea personalizar esta partida? (S/N) ",0

; infoOcas es un vector de la forma: [cantidadOcasVivas, simboloOcas, posFilOca1, posColOca1, ..., posFilOcaN, posColOcaN], donde 0 <= N <= 17
; infoZorro es un vector de la forma: [simboloZorro, posFilZorro, posColZorro]
; Valor de rotacion de la tabla en sentido antihorario. 0 -> 0º, 1 -> 90º, 2 -> 180º, 3 -> 250º
section     .bss
    dirZorro		resq	1
    dirOca		resq	1
    dirOrientacion		resq	1
    respuesta		resb	50
    simboloZorro    resq    1
    SimboloOca      resq    1
    orientacion     resq    2
    

section     .text
personalizarPartida:

; almaceno la direccion de la informacion del zorro
    mov     [dirZorro],rdi
; almaceno la direccion de la informacion de la oca
    mov     [dirOca],rsi
; almaceno la direccion de la informacion de la rotacion
    mov     [dirOrientacion],rcx
Bucle:
    ; imprimo el mensaje 
    mov     rdi,msg
    mPrintf
; recibo respuesta
    mov     rdi,respuesta
    mGets
 
; validacion de si desea personalizar
    cmp     byte [respuesta],'N'
    je     FIN

    cmp     byte [respuesta],'S'
    je     EsValido

    mov     rdi,CMNV
    mPuts
    jmp     Bucle

EsValido:
; si es asi pasa a llamar a customizar
    mov     rdi,[dirZorro]
    mov     rsi,[dirOca]
    mov     rcx,[dirOrientacion]
    mCustomizar
FIN:
    ret
