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

#define numCounters                    2
// Names of the counters
#define cDisplay                       0
#define cMotor                         1

#define BUFFER_SIZE                    64
#define baludRate                      51

#define modeSwitches                   'S'
#define modeDigital                    'D'
#define modeAnalog                     'A'

#define multipleErrors                 'e'
#define frameError                     'f'
#define dataOverRun                    'r'
#define parityError                    'q'
#define stopMotor                      'P'
#define invertMotor                    'I'
#define incrementPoints                '+'
#define decrementPoints                '-'
#define report                         'B'


void setup( void );

typedef unsigned char byte;
typedef char string[ BUFFER_SIZE ];

typedef struct {
	byte Tim0: 1;
	byte Tim1: 1;
	byte Tim2: 1;
	byte RX: 1;
} FLAGS;

volatile FLAGS flag; 
volatile byte counter[ numCounters ];
byte beforeValue;
byte nowValue;
char tempBuffer;

#endif
