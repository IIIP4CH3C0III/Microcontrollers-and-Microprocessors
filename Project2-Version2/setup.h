/* 
 * File name : setup.h
 *
 * Descript  : This where the inicialization of the hardware, and most of the includes are situaded
 *
 * Author    : Fábio Pacheco
 */

#ifndef SETUP_H
#define SETUP_H

#include <avr/interrupt.h>
#include <avr/iom128.h>

#include <util/delay.h>
#define F_CPU 16000000UL

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define timeBaseOCR0                   7
#define frequencyPWM2                  500

void setup( void );

typedef unsigned char byte;

volatile byte flag; // In use the first two bits, in this case bit 0 represents time to swap display and bit 1 time to refresh each display  
byte counter;
byte beforeValue;
byte nowValue;

#endif
