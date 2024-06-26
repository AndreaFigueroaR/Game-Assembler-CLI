# Trabajo Práctico Organización del Computador
## Integrantes
  - Andrea Figueroa: 110450
  - Leticia Figueroa: 110510
  - Candela Matelica: 110641
  - Jesabel Pugliese: 110860
## Instrucciones de ejecución
 Estando en la ubicación donde se encuentren los archivos, correr los siguientes comandos en la terminal:<br>
  ### Para ensamblar:
  - ```nasm actualizarEstadisticas.asm -f elf64```
  - ```nasm customizar.asm -f elf64```
  - ```nasm guardarPartida.asm -f elf64```
  - ```nasm macros.asm -f elf64```
  - ```nasm main.asm -f elf64```
  - ```nasm personalizarPartida.asm -f elf64```
  - ```nasm printCruz.asm -f elf64```
  - ```nasm procesarComando.asm -f elf64```
  - ```nasm realizarJugada.asm -f elf64```
  - ```nasm recuperacionPartida.asm -f elf64```
  ### Para compilar:
  - ```gcc actualizarEstadisticas.o customizar.o guardarPartida.o macros.o main.o personalizarPartida.o printCruz.o procesarComando.o realizarJugada.o recuperacionPartida.o -o a.out -no-pie```
  ### Para ejecutar:
  - ```./a.out```
## Instrucciones de Juego
Cada partida se juega de a 2 jugadores: las ocas y el zorro.<br> Se detalla el modo de juego la inicio de cada ejecución. 

