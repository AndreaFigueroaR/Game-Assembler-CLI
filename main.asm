%include "llamadas.asm"

global main

section .data
    
section .bss   
    simboloZorro        db 1               ;Se puede cambiar a otro simbolo reemplanzando el contenido por el simbolo ASCCI
    simboloOcas         db 1               ;idem anterior
    cantidadOcasVivas   resb 1;            tamaño a a discusiòn
    posicionesOcas      times 17 resq 2;   [[0,1],[1,2],...], [X,Y] ->17 pares de coordenadas
    posicionZorro       resq 2;            [5,4]->posicion del zorro 
    comando             resq 2;
    jugadorActual       db 1               ;0->turno del zorro, 1->turno de las ocas
    rotacionTablero     db 1               ; 0->0º, 1->90º, 2->180º, 3-> 250º en sentido horario
    estadoPartida       db 1               ;0->partidaActiva, 1-> partida terminada: ganò el Zorro, 2-> partida terminada: ganaron las ocas, 3->partida interrumpida
    estadisticas        db 8               ;es como un vector donde cada posicion corresponde a la cantidad de movimientos en cada direccion. [arriba, abajo, izq, der, arriba-izq, arriba-der, abajo-izq, abajo-der]

section .text
main:
;   INICIALIZACIÓN JUEGO
    callRecoverGame         posicionZorro,  posicionesOcas, cantidadOcasVivas,  rotacionTablero ; también debería de recuperar y guardar en su propieo archivo con sus variables la información de las estadísticas de la anterior partida, pero eso no importa en este archivo
    callCustomizeGame       simboloZorro,   simboloOcas,    rotacionTablero

continuarJugando:
    call                    clear ; esto ponerlo con al funcion de c
    imprimirTabla           cantidadOcasVivas, posicionesOcas, posicionZorro, simboloZorro, simboloOcas, rotacionTablero
    mGets                   comando
    realizarJugada          cantidadOcasVivas, posicionesOcas, posicionZorro, comando, jugadorActual, estadisticas
    resultadoJuego          cantidadOcasVivas, posicionesOcas, posicionZorro, jugadorActual, estadoPartida
    cmp                     byte[estadoPartida],0
    je                      continuarJugando

;   FIN DEL JUEGO
    imprimirMsgFinJuego     estadoPartida ; imprimir quien gano y asi
    mostrarEstadisticas     estadisticas

    ret
