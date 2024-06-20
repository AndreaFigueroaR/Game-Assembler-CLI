;se tiene que cambiar el estado(posicion) de la oca o del zorro que se moviò
;si se movio el zorro se debe ver si se comio alguna oca, si sì se setea como que no se cambia de turno, luego al inicio de cada
;luego se tiene que verificar que se halla acabado el turno del jugador actual (si son ocas siempre dura solo un turno, si es el zorro se debe verificar una )

%include "llamadas.asm"
global realizarJugada
section     .data
    murioOca            db      0

section     .bss
    dirPosicionOrigen   resq    1;->si es que el jugador actual es el zorro aqui copio el valor de la posicion que indica su vector (antes de editarlo) y en base a la posicionDestino que dejò el procesarComando puedo asignarle su nueva posicion de destino
    dirPosicionDestino  resq    1;
    jugadorActual       resq    1;

realizarJugada:
    salvarParametros:
        mov [jugadorActual],        RDI
        mov [dirPosicionOrigen],    RSI
        mov [dirPosicionDestino],   RDX
        mov [dirInfoZorro],         R8
        mov [dirInfoOcas],          R9

    ejecutarMovimiento:
    ;si el jugador actual es el zorro se debe guardar lo que tenga como posicion actual en su info en la parte de posicionOrigen
    
    ;si es oca-> se cambia la posicion actual de la oca que indiue que està en el mismo liugar que la posicion de origen... y nada màs
    ;si es zorro-> si la nueva posicion es de un salto entonces se debe encontrar la oca que este en la posicion en el medio de estas(oca comida), se pisa la su posicion con la de la ultima oca viva, se disminuye la cantidad de ocas vivas, se cambia la posicion del zorro a la que indica la posicionDestino y se setea como 1 a "murioOca".
    ;               si no era un salto solo se cambia la psocion del zorro a la posicion indicada en posicionDestino
    
    ;ejecutadas las consecuencias del movimiento sobre el juego:        
    ;si murioOca==0 -> cambiamos de jugadorActual al opuesto
    ;si  murioOca!=0 -> se deja el jugadorActual

    ;fin
