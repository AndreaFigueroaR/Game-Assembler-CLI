global ValidarChar
section .data
	msgError       db   "El caracter no es valido",0
section .text

; en esta rutina externa nos encargamos de validar que lo ingresado lo consideremos
; un simbolo valido para customizar ambos personajes
; caracteres alfabetico

ValidarChar:
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