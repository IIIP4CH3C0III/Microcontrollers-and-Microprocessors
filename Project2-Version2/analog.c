/* 
 * File name : analog.c
 *
 * Descript  : This where the functions related to the analog values
 *
 * Author    : Fábio Pacheco
 */

#include "analog.h"

ST_ANALOG * 
createANALOG( void ) {
  ST_ANALOG * st_analog = malloc( sizeof(ST_ANALOG) );
  return st_analog; 
}

uint16_t
analogRead( ST_ANALOG * st_analog ) {
  uint16_t sum = 0;
  byte i, n = 0;
  for ( i = 0 ; i < quantityOfNumbersToAverage ; i++ ) {
    enableConversion;
    while( (ADCSRA & ( 1 << ADSC )) != 0 );
    st_analog->reading[n].L = ADCL;
    st_analog->reading[n].H = ADCH;
    sum += ( st_analog->reading[n].H << 8 ) + st_analog->reading[n].L ;
    n++;  	
  }

  return (sum / quantityOfNumbersToAverage);
}

