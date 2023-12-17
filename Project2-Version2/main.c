#include "setup.h"
#include "display.h"
#include "motor.h"
#include "usart.h"
#include "analog.h"
#include "stepMotor.h"

void
loop( DISPLAYS * displays , MOTOR * motor , ST_USART * usart1 , STEP_MOTOR * stepMotor , char word[ numDisplays ] );

byte
interptDigitaData( char status, ST_USART * st_usart ,  MOTOR * motor ,  STEP_MOTOR * stepMotor );

int
main( ) {
  DISPLAYS *     display = ( DISPLAYS * )  createDisplays();
  MOTOR *        motor   = ( MOTOR * )     createMotor();
  ST_USART *     usart1  = ( ST_USART * )  createUSART();
  STEP_MOTOR * stepMotor = ( STEP_MOTOR * )createStepMotor();
  char word[ numDisplays ] ;
  mode = modeDigital ;

  (void)setup();
 
  for ( ; ; )
    (void)loop( display, 
                motor, 
                usart1, 
				stepMotor,
                word
                );
   
  return 0;
}

void
loop( DISPLAYS * displays , MOTOR * motor , ST_USART * usart1 ,  STEP_MOTOR * stepMotor , char word[ numDisplays ] ) {  
  if( flag.Tim0 ) {
    (void)writeInDisplay( displays );
    flag.Tim0 = 0;
  }

  if( flag.Tim1 ) {
    if ( mode != modeStepMotor ) {
      if ( !motor->direction )
        snprintf( word , sizeof(byte) * numDisplays + 1 , "%c %02d", mode , motor->perDutyC );
      else
        snprintf( word , sizeof(byte) * numDisplays + 1 , "%c-%02d", mode , motor->perDutyC );
    } else
        snprintf( word , sizeof(byte) * numDisplays + 1 , "%c%03d", mode, motor->perDutyC );
    

    (void)updateRegisterDisplays( displays, word );
    flag.Tim1 = 0;
  }

  if( flag.Tim2 && motor->stage ) {
    (void)changeRotationMotor( motor );  	
    flag.Tim2 = 0;
  }

  if( mode == modeSwitches ) {
    nowValue = PINA & 0b00110011;  
    switch ( nowValue ) {
      case 0b00110010:
        if ( beforeValue == 0b00110011 && nowValue == 0b00110010 ) {
          (void)interptDigitaData( decrementPoints, usart1, motor, stepMotor );
          (void)transmitStringUSART( usart1 );
        }
 	    break;

   	  case 0b00110001:
        if ( beforeValue == 0b00110011 && nowValue == 0b00110001 ) {
          (void)interptDigitaData( incrementPoints , usart1, motor, stepMotor );
          (void)transmitStringUSART( usart1 );
        }
  	    break;

	  case 0b00100011:
	    if ( beforeValue == 0b00110011 && nowValue == 0b00100011 ) {
          (void)interptDigitaData( invertMotor, usart1, motor, stepMotor );
          (void)transmitStringUSART( usart1 );	    	
	    }
 	    break;

	  case 0b00010011:
	    if ( beforeValue == 0b00110011 && nowValue == 0b00010011 ) {
          (void)interptDigitaData( stopMotor, usart1, motor, stepMotor );
          (void)transmitStringUSART( usart1 );	    		    	
	    }
	    break;
    }     
    beforeValue = PINA & 0b00110011;  
  }

  // Digital mode will be always activated on background, because it's the only way to swap between modes, but what can happend is choosing only digital mode
  if( flag.RX ) {
    flag.RX = 0;
    (void)interptDigitaData( (char) recieveStringUSART( usart1 ) , usart1, motor, stepMotor );
    (void)transmitStringUSART( usart1 );
  }

  if( mode == modeAnalog ) {
    motor->perDutyC = (byte)linearSolver( 99 , 0, 255, 0, analogRead( ));
    motor->absDutyC = (byte)linearSolver( 255, 0, 100, 0, motor->perDutyC);
    OCR2  = motor->absDutyC;             

    nowValue = PINA & 0b00110011;  
    if ( beforeValue == 0b00110011 && nowValue == 0b00100011 ) {
      (void)interptDigitaData( invertMotor, usart1, motor, stepMotor );
      (void)transmitStringUSART( usart1 );	    	
    }
    beforeValue = PINA & 0b00110011;  
  }

  if( flag.Tim3 && flag.ROT ) {
    flag.Tim3 = 0;
    rotationStepMotor( stepMotor , 0 , 0 );          // No need to give parameters now, they are already in use
  }
}

ISR( USART1_RX_vect ) {
  flag.RX = 1 ;
  tempBuffer = UDR1;
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

  if ( counter[ cStepMotor ] <= 0 ) {
    counter[ cStepMotor ] = timeChangeInductor;
    flag.Tim3 = 1 ;
  }   
  else
    counter[ cStepMotor ]-- ;      
    
}

byte
interptDigitaData( char status , 
                   ST_USART * st_usart , 
                   MOTOR * motor,  
				   STEP_MOTOR * stepMotor 
                  ) {
  switch( status ) {
    case multipleErrors:
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Error:\r\n Multiple errors\r\n" );
    break;
    
    case frameError:
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Error:\r\n Frame error\r\n" );
    break;

    case dataOverRun:
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Error:\r\n Data overrun\r\n" );
    break;

    case parityError:
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Error:\r\n Parity bit error\r\n" );
    break;

    case stopMotor:
    case 'p':
      if ( motor->state )
        snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\r\n Stop motor\r\n" );
      else 
        snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\r\n Start motor\r\n" );
      
      (void)changeStateMotor( motor );
    break;

    case invertMotor:
    case 'i':
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\r\n Invert direction of motor\r\n" );     
  	  (void)changeRotationMotor( motor );
    break;

    case incrementPoints:
      if ( motor->perDutyC < 100 )
        motor->perDutyC += motor->points ;
      if ( motor->perDutyC >= 100 )
        motor->perDutyC = 99;
      motor->absDutyC = (byte)linearSolver( 255, 0, 100, 0, motor->perDutyC);
      OCR2  = motor->absDutyC;             
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\r\n Increase PWM by %02d\r\n", motor->points );     
    break;

    case decrementPoints:
      if ( motor->perDutyC > 0 )
        motor->perDutyC -= motor->points ;
      if ( motor->perDutyC <= 0 )
        motor->perDutyC = 0;
      motor->absDutyC = (byte)linearSolver( 255, 0, 100, 0, motor->perDutyC);
      OCR2  = motor->absDutyC;             
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\r\n Decrease PWM by %02d\r\n", motor->points );     
    break;

    case report:
    case 'b':
      if ( !motor->direction )
        snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Report:\r\n DutyCycle: %02d%%\r\n Direction: +\r\n", motor->perDutyC );
      else
        snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Report:\r\n DutyCycle: %02d%%\r\n Direction: -\r\n", motor->perDutyC );        
    break;

    case modeSwitches:
    case 's':
      mode = modeSwitches;
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\r\n Switches mode selected\r\n");     
    break;
    
    case modeDigital:
    case 'd':
      mode = modeDigital;
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\r\n Digital mode selected\r\n");     
    break;

    case modeAnalog:
    case 'a':
      mode = modeAnalog;
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\r\n Analog mode selected\r\n");     
    break;

    case modeStepMotor:
    case 'g':
      mode = modeStepMotor;
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\r\n Step motor mode selected\r\n");     
    break;
	
    case stepMotorRightRotation:
	case 'r':
      stepMotor->direction = '+';
	  rotationStepMotor( stepMotor , stepDegrees, !originRelated );
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\r\n Move to right 1 step\r\n Degrees:%d\r\n" , stepMotor->phase );
	break;

    case stepMotorLeftRotation:
    case 'l':
      stepMotor->direction = '-';
      rotationStepMotor( stepMotor , stepDegrees , !originRelated );
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\r\n Move to left 1 step\r\n Degrees:%d\r\n" , stepMotor->phase );
    break;

    case stepMotorSetOrigin:
    case 'z':
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\r\n Set new origin at %d degrees from before Origin\r\n" , stepMotor->phase );
      stepMotor->phase = 0;
    break;
    	
	case stepMotorMove000origin:
      rotationStepMotor( stepMotor, 0,  originRelated );
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\r\n Move to origin 0 degrees\r\n Degrees:%d\r\n" , stepMotor->phase);
	break;

	case stepMotorMove090origin:
      rotationStepMotor( stepMotor, 90, originRelated );
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\r\n Move to origin 90 degrees\r\n Degrees:%d\r\n" , stepMotor->phase);
	break;

	case stepMotorMove180origin:
      rotationStepMotor( stepMotor, 180, originRelated );
      snprintf( st_usart->transmitBuffer , BUFFER_SIZE , "Action:\r\n Move to origin 180 degrees\r\n Degrees:%d\r\n" , stepMotor->phase);
	break;
  }	
  return 0;
}
