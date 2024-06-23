
%macro mPuts 0
    sub     rsp,8
    call    puts
    add     rsp,8
%endmacro

global validarOrientacion
extern puts
section .data
		msg		db "Orientacion invalida",0

section .bss

section .text

; En esta rutina nos encargamos de validar que lo ingresado cumpla con las condiciones dadas
; sobre el dato para asi correr el juego, en este caso tomamos como valida la orientacion si ingresa
; 0 -> default, la concentracion de ocas se encuentra en el cuadrante de arriba
; 90 -> la concentracion de ocas se encuentra en el cuadrante de la derecha
; 180 -> la concentracion de ocas se encuentra en el cuandrante inferior
; 270 -> la concentraicon de ocas se encuentra en el cuadrante izquierdo

validarOrientacion:
Validar:
	mov		rax,[rsi] ; la esi apunta a la direccion de memoria donde se encuentra el simbolo a validar

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
