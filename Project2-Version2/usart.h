/* 
 * File name : usart.h
 *
 * Descript  : Struct and fuctions related to the usart
 *
 * Author    : Fábio Pacheco
 */

#ifndef USART_H
#define USART_H

#include "setup.h"

typedef struct {  
  char recieveBuffer;
  string transmitBuffer;
  byte   status;
}
ST_USART ;

ST_USART *
createUSART();

char 
recieveStringUSART( ST_USART * st_usart );

byte
transmitStringUSART( ST_USART * st_usart );

#endif
