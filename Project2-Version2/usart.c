#include "usart.h"

ST_USART *
createUSART() {
  ST_USART * st_usart = ( ST_USART * ) malloc ( sizeof ( ST_USART ) );
  st_usart->recieveBuffer = ' ';
  (void)strcpy( st_usart->transmitBuffer , "" );  
  return st_usart;
}

char 
recieveStringUSART( ST_USART * st_usart ) {
  st_usart->status = UCSR1A;
  st_usart->status &= 0b00011100;

  switch( st_usart->status ){
    case 0b00000000:
      st_usart->recieveBuffer = UDR1;
      break;

    case 0b00010000: 
      st_usart->recieveBuffer = frameError;
      break;
       
    case 0b00001000:    
      st_usart->recieveBuffer = dataOverRun;
      break;
    
    case 0b00000100:    
      st_usart->recieveBuffer = parityError;
      break;

    default:
      st_usart->recieveBuffer = multipleErrors;
  }
  
  return st_usart->recieveBuffer;
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

