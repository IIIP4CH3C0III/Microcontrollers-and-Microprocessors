/* 
 * File name : analog.c
 *
 * Descript  : This where the functions related to the analog values
 *
 * Author    : Fábio Pacheco, Joana Sousa
 */

#include "analog.h"

uint16_t
analogRead( ) {
  float sum = 0;
  byte i;
  for ( i = 0 ; i < quantityOfNumbersToAverage ; i++ ) {
    (void)getADCvalue( );
    sum += analogBuffer;
  }
  return (uint16_t)(sum / quantityOfNumbersToAverage);
}
