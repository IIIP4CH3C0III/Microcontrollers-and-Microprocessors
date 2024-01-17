/* 
 * File name : setup.h
 *
 * Descript  : This where the inicialization of the hardware, and most of the includes are situaded
 *
 * Author    : Fábio Pacheco, Joana Sousa
 */

#ifndef SETUP_H
#define SETUP_H

#define F_CPU 16000000UL
#include <util/delay.h>

#include <avr/interrupt.h>
#include <avr/iom128.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define timeBaseOCR0                   7
#define frequencyPWM2                  500

#define numCounters                    3
// Names of the counters
#define cDisplay                       0
#define cMotor                         1
#define cStepMotor                     2 

#define BUFFER_SIZE                    64
#define baludRate                      51

#define modeSwitches                   'S'
#define modeDigital                    'D'
#define modeAnalog                     'A'
#define modeStepMotor                  'G'

#define multipleErrors                 'e'
#define frameError                     'f'
#define dataOverRun                    'o'
#define parityError                    'q'
#define stopMotor                      'P'
#define invertMotor                    'I'
#define incrementPoints                '+'
#define decrementPoints                '-'
#define report                         'B'
#define stepMotorRightRotation         'R'
#define stepMotorLeftRotation          'L'
#define stepMotorSetOrigin             'Z'
#define stepMotorMove000origin         '0'
#define stepMotorMove090origin         '9'
#define stepMotorMove180origin         '1'
#define originRelated                   1 

void setup( void );

typedef unsigned char byte;
typedef char string[ BUFFER_SIZE ];

typedef struct {
	byte Tim0: 1; // Time for the swaping between displays
	byte Tim1: 1; // Time for each display to update
	byte Tim2: 1; // Time for the motor to swap rotation
    byte Tim3: 1; // Time for the stepMotor inertia
	byte RX: 1;   // Recieve data in USART
    byte ROT: 1;  // Rotation of the stepMotor
} FLAGS;

volatile FLAGS flag; 
volatile byte counter[ numCounters ];
byte beforeValue;
byte nowValue;
char tempBuffer;
byte analogBuffer;
byte mode;

#define setBit(PORTIO, bit)              ( (PORTIO) |= ( 1 << bit) )
#define clearBit(PORTIO, bit)            ( (PORTIO) &= ~( 1 << bit) )

#endif
