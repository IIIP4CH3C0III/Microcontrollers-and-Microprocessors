CC   = avr-gcc
FLAG = -std=gnu99 -Wall
UC   = atmega128

compile:
		${CC} ${FLAG} -mmcu=${UC} -c *.c -I ./lib-common/include

link:
		${CC} ${FLAG} -mmcu=${UC} -o funcional2.elf *.o -L ./lib-common/lib
