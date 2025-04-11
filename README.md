# Juego Zorro vs Ocas- versión por Linea de comando- desarrollado en assembler (x86)

## En qué consiste el juego?

El juego del Zorro y las Ocas se desarrolla en un tablero de 7x7 casillas, con un total de 33 casillas utilizables contando con 1 ficha correspondiente al zorro y 17 fichas que representan a las ocas. 
El objetivo del juego es capturar o ser capturado dependiendo del rol que juegue cada jugador. <br>


### Roles:
- Un jugador controla al **Zorro**. <br>
- El otro jugador controla las **Ocas**. <br>

### Objetivos:

**Zorro**: 
Capturar 12 ocas 

**Ocas**:
Acorralar al Zorro de tal manera que no pueda moverse, o que 6 ocas llegan a la parte inferior del tablero

### Movimientos:

**Zorro**: 
- Puede moverse una casilla a la vez en cualquier dirección: hacia adelante, hacia atrás, en diagonales o a los costados.
- Para capturar una oca, debe saltar sobre ella hacia una casilla vacía.
- Si el zorro capturo una oca puede realizar otro movimiento adicional, cuealquier otro tipo de movimiento.

**Ocas**:
- Pueden moverse una casilla a la vez hacia adelante o a los costados.
- No pueden saltar sobre el Zorro, por lo tanto, deben intentar acorralarlo para limitar sus movimientos.

### Fin del juego:

El juego termina automáticamente cuando:
- El Zorro captura 12 ocas.
- El Zorro no puede realizar ningún movimiento válido porque quedo acorralado o 6 ocas llegaron a la parte mas inferior del tablero.
***
**También podrás encontrar instrucciones al iniciar la partida**
***
## Desarrolladores
| Nombre   | Apellido  | Correo FIUBA         | Usuario de Github                                 |
|----------|-----------|----------------------|--------------------------------------------------|
| Candela  | Matelica  | cmatelica@fi.uba.ar | [candematelica](https://github.com/candematelica)|
| Jesabel    | Pugliese    | jpugliese@fi.uba.ar   | [jesapugliese](https://github.com/jesapugliese) |
| Leticia  | Figueroa  | lfigueroar@fi.uba.ar| [leticiafrR](https://github.com/leticiafrR)      |
| Andrea   | Figueroa  | afigueroa@fi.uba.ar | [AndreaFigueroaR](https://github.com/AndreaFigueroaR)    
## Instrucciones de ejecución
Estando en la ubicación donde se encuentren los archivos, correr el siguiente comando en la terminal: <br>
```sh run.sh```
