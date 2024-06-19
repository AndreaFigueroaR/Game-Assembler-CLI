global ValidarChar

section .text

; en esta rutina externa nos encargamos de validar que lo ingresado lo consideremos
; un simbolo valido para customizar ambos personajes
; caracteres alfabetico

ValidarChar:
; a charlar que caracteres ASCII tomamos como validos
	cmp 	rdi, "A"
	jl 	NoValido
	
	cmp 	rdi, "z"
	jl 	NoValido

	cmp 	rdi, "a"
	jge 	Valido
	
	cmp 	rdi,"Z"
	jle  	Valido

NoValido:
	mov 	rdi,"N"
	jmp 	FIN

Valido:	
	mov	rdi, "S"

FIN:
	ret