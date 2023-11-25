#include "usart.h"

ST_USART *
createUSART() {
  ST_USART * st_usart = ( ST_USART * ) malloc ( sizeof ( ST_USART ) );
  (void)strcpy( st_usart->recieveBuffer , "" );
  (void)strcpy( st_usart->transmitBuffer , "" );  
  return st_usart;
}

char 
recieveStringUSART( ST_USART * st_usart ) {
  char c;
  st_usart->status = UCSR1A;
  st_usart->status &= 0b00011100;

  switch( st_usart->status ){
    case 0b00010000: 
      c = frameError;
      break;
       
    case 0b00001000:    
      c = dataOverRun;
      break;
    
    case 0b00000100:    
      c = parityError;
      break;

    default:
      c = multipleErrors;
  }
  
  st_usart->recieveBuffer[0] = UDR1;
  return c;
}

byte
transmitStringUSART( ST_USART * st_usart ) {
  byte i = 0;
  while ( st_usart->transmitBuffer[i] != '\0' ) {
  	while ( (UCSR1A & 0b00100000) == 0 ); // Stay while the line is ocupied
    UDR1 = st_usart->transmitBuffer[i];
    i++;
  }
}

