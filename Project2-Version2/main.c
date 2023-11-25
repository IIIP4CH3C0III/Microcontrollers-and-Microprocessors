#include "setup.h"
#include "display.h"
#include "motor.h"
#include "usart.h"

void
loop( DISPLAYS * displays , MOTOR * motor , ST_USART * usart1  , char word[ numDisplays ] );

byte
interptDigitaData( char status, ST_USART * st_usart , MOTOR * motor , byte * mode );

int
main( ) {
  DISPLAYS * display = ( DISPLAYS * ) createDisplays();
  MOTOR * motor = ( MOTOR * ) createMotor();
  ST_USART * usart1 = ( ST_USART * )createUSART();
  char word[ numDisplays ] ;
  mode = 'D';
  (void)setup();
 
  for ( ; ; )
    (void)loop( display, motor , usart1 , word );
   
  return 0;
}

void
loop( DISPLAYS * displays , MOTOR * motor , ST_USART * usart1 , char word[ numDisplays ] ) {  
  if( flag.Tim0 ) {
    (void)writeInDisplay( displays );
    flag.Tim0 = 0;
  }

  if( flag.Tim1 ) {
    if ( !motor->direction )
      snprintf( word , sizeof(byte) * numDisplays + 1 , "%c %02d", mode , motor->perDutyC );
    else
      snprintf( word , sizeof(byte) * numDisplays + 1 , "%c-%02d", mode , motor->perDutyC );

    (void)updateRegisterDisplays( displays, word );
    flag.Tim1 = 0;
  }

  if( flag.Tim2 && motor->stage ) {
    (void)changeRotationMotor( motor );  	
    flag.Tim2 = 0;
  }

  nowValue = PINA & 0b00110011;  
  switch ( nowValue ) {
    case 0b00110010:
      if ( beforeValue == 0b00110011 && nowValue == 0b00110010 )
        (void)interptDigitaData( decrementPoints, usart1, motor, &mode );
 	    break;

	  case 0b00110001:
      if ( beforeValue == 0b00110011 && nowValue == 0b00110001 )
        (void)interptDigitaData( incrementPoints , usart1, motor, &mode );
	    break;

	  case 0b00100011:
	    if ( beforeValue == 0b00110011 && nowValue == 0b00100011 )
        (void)interptDigitaData( invertMotor, usart1, motor, &mode );
	    break;

	  case 0b00010011:
	    if ( beforeValue == 0b00110011 && nowValue == 0b00010011 )
        (void)interptDigitaData( stopMotor, usart1, motor, &mode );
	    break;
  }     
  beforeValue = PINA & 0b00110011;  

  if( flag.RX ) {
    flag.RX = 0;
    (void)interptDigitaData( (char) recieveStringUSART( usart1 ) , usart1, motor, &mode );
    (void)transmitStringUSART( usart1 );
  }
}

ISR ( TIMER0_COMP_vect ) {
  flag.Tim0 = 1;

  if ( counter[ cDisplay ] <= 0 ) {
    counter[ cDisplay ] = frequencyDisplays;
    flag.Tim1 = 1 ;
  }   
  else
    counter[ cDisplay ]-- ;      

  if ( counter[ cMotor ] <= 0 ) {
    counter[ cMotor ] = timeMotorStop;
    flag.Tim2 = 1 ;
  }   
  else
    counter[ cMotor ]-- ;      
}

ISR( USART1_RX_vect ) {
  flag.RX = 1 ;
}

byte
interptDigitaData( char status , 
                   ST_USART * st_usart , 
                   MOTOR * motor , 
                   byte * mode 
                  ) {
  switch( status ) {
    case multipleErrors:
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Error:\n Multiple errors\n" );
    break;
    
    case frameError:
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Error:\n Frame error\n" );
    break;

    case dataOverRun:
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Error:\n Data overrun\n" );
    break;

    case parityError:
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Error:\n Parity bit error\n" );
    break;

    case stopMotor:
    case 'p':
      if ( motor->state )
        snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\n Stop motor\n" );
      else 
        snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\n Start motor\n" );
      
      (void)changeStateMotor( motor );
    break;

    case invertMotor:
    case 'i':
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\n Invert direction of motor\n" );     
  	  (void)changeRotationMotor( motor );
    break;

    case incrementPoints:
      if ( motor->perDutyC < 100 )
        motor->perDutyC += motor->points ;
      if ( motor->perDutyC >= 100 )
        motor->perDutyC = 99;
      motor->absDutyC = linearSolver( 255, 0, 100, 0, motor->perDutyC);
      OCR2  = motor->absDutyC;             
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\n Increase PWM by %02d\n", motor->points );     
    break;

    case decrementPoints:
      if ( motor->perDutyC > 0 )
        motor->perDutyC -= motor->points ;
      if ( motor->perDutyC <= 0 )
        motor->perDutyC = 0;
      motor->absDutyC = linearSolver( 255, 0, 100, 0, motor->perDutyC);
      OCR2  = motor->absDutyC;             
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\n Decrease PWM by %02d\n", motor->points );     
    break;

    case report:
    case 'b':
      if ( !motor->direction )
        snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Report:\n DutyCycle: %02d%%\n Direction: +\n", motor->perDutyC );
      else
        snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Report:\n DutyCycle: %02d%%\n Direction: -\n", motor->perDutyC );        
    break;

    case modeSwitches:
    case 's':
      *mode = modeSwitches;
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\n Switches mode selected\n");     
    break;
    
    case modeDigital:
    case 'd':
      *mode = modeDigital;
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\n Digital mode selected\n");     
    break;

    case modeAnalog:
    case 'a':
      *mode = modeAnalog;
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\n Analog mode selected\n");     
    break;
  }	
  return 0;
}
