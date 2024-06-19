global ValidarOrientacion

section .data

section .bss

section .text

; En esta rutina nos encargamos de validar que lo ingresado cumpla con las condiciones dadas
; sobre el dato para asi correr el juego, en este caso tomamos como valida la orientacion si ingresa
; 0 -> default, la concentracion de ocas se encuentra en el cuadrante de arriba
; 90 -> la concentracion de ocas se encuentra en el cuadrante de la derecha
; 180 -> la concentracion de ocas se encuentra en el cuandrante inferior
; 270 -> la concentraicon de ocas se encuentra en el cuadrante izquierdo

ValidarOrientacion:
	cmp 	RDI, 0
	je 	    Valido
	
	cmp 	RDI, 90
	je   	Valido

	cmp 	RDI, 180
	je   	Valido
	
	cmp 	RDI,270
	je  	Valido

NoValido:
	mov 	RDI,"N"
	jmp 	FIN

Valido:	
	mov	    RDI, "S"

FIN:
	ret
