/* 
 * File name : analog.h
 *
 * Descript  : This where the structs and functions related to the analog values
 *
 * Author    : Fábio Pacheco
 */

#ifndef ANALOG_H
#define ANALOG_H

#include "setup.h"

#define quantityOfNumbersToAverage 2
#define enableConversion ( (ADCSRA) |= ( 1 << ADSC ) )

typedef struct {
  byte L;
  byte H;
} ANALOG_RD;

typedef struct {
  ANALOG_RD reading[ quantityOfNumbersToAverage ];
} ST_ANALOG;

ST_ANALOG * 
createANALOG( void );

/*
uint16_t
analogRead( ST_ANALOG * st_analog );
*/

uint16_t
analogRead( );

extern void getADCvalue( void );

#endif
