/* 
 * File name : analog.h
 *
 * Descript  : This where the structs and functions related to the analog values
 *
 * Author    : Fábio Pacheco, Joana Sousa
 */

#ifndef ANALOG_H
#define ANALOG_H

#include "setup.h"

#define quantityOfNumbersToAverage 2

uint16_t
analogRead( );

extern void getADCvalue( void );

#endif
