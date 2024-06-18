%include "llamadas.asm"

global main

section .data
    simboloZorro        db "X"  ;Se puede cambiar a otro simbolo reemplanzando el contenido por el simbolo ASCCI
    simboloOcas         db "O"  ;idem anterior
    rotacionTablero     db 0    ; 0->0º, 1->90º, 2->180º, 3-> 250º en sentido horario
    estadoPartida       db 0    ;0->partidaActiva, 1-> partida terminada: ganò el Zorro, 2-> partida terminada: ganaron las ocas, 3->partida interrumpida
    jugadorActual       db 0    ;0->turno del zorro, 1->turno de las ocas


section .bss   
    cantidadOcasVivas   resb 1;            tamaño a a discusiòn
    posicionesOcas      times 17 resb 2;   [[1,3],[1,4],...], [fil,col] ->17 pares de coordenadas
    posicionZorro       resb 2;            [5,4]->posicion inicial del zorro antes del movimiento (equivalente a 5D)
    posicionNueva       resb 2;            [4,4]->nueva posicion (decodificada a partir de la entrada "4D")


section .text
main:
    ;INICIALIZACIÓN JUEGO
    callRecoverGame         posicionZorro,  posicionesOcas, cantidadOcasVivas,  rotacionTablero ; también debería de recuperar y guardar en su propieo archivo con sus variables la información de las estadísticas de la anterior partida, pero eso no importa en este archivo
    callCustomizeGame       simboloZorro,   simboloOcas,    rotacionTablero
    ;MOSTRAR "INSTRUCCIONES": cómo interrumpir una partida, cómo indican sus movimientos las ocas, cómo lo hace el zorro.

    ;INICIA_PARTIDA
    ;bucle: no olvidar guardar el contenido de registros importantes al iniciar el bucle, luego su cuerpo{recibir entrada, validar formato, validar movimiento, realizar jugada, imprimir tablero} y luego restaurar el contenido de los registros.
    
    ;TERMINÓ O SE INTERRUMPIÓ LA PARTIDA
    ;Una vez se salga del bucle según por què se salió:(¿Hay algun ganador?¿Se interrumpió la partida?) 
    ;    se muestra quién fue el ganador, se muestran las estadísticas de la partida 
    ;    o
    ;    se escriben los detalles del estado del juego actual en un archivo (incluyendo el conteo que se lleva para las estadisticas que se muestran cuando se gana una partida, así como el estado de las variables globales del main)

    ;fin del programa
