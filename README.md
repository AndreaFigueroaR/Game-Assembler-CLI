# Trabajo Práctico Organización del Computador
## Integrantes
  - Andrea Figueroa: 110450
  - Leticia Figueroa: 110510
  - Candela Matelica: 110641
  - Jesabel Pugliese: 110860
## Instrucciones de ejecución
 Estando en la ubicación donde se encuentren los archivos, correr los siguientes comandos en la terminal:<br>
  ### Para ensamblar:
  - ```nasm main.asm -f elf64```
  - ```nasm recuperacionPartida.asm -f elf64```
  - ```nasm guardarPartida.asm -f elf64```
  - ```nasm realizarJugada.asm -f elf64```
  - ```nasm procesarEntrada.asm -f elf64```
  - ```nasm printCruz.asm -f elf64```
  ### Para compilar:
  - ```gcc main.o recuperacionPartida.o guardarPartida.o realizarJugada.o procesarEntrada.o printCruz.o -o a.out -no-pie```
  ### Para ejecutar:
  - ```./a.out```

