global Predeterminado

section .data
; definimos como campos inicializados las configuraciones por default
    zorro           db  "X",0
    ocas            db  "O",0
    orientacion     db      0


section .text
; esta rutina interna se encarga de inciar el juego con los simbolos considerados como default en 
; en el enunciado


Predeterminado:
; copio los caracteres en la direccion de memoria dada 
	mov rdi, zorro
	mov rsi, ocas
	mov rdx, orientacion
ret