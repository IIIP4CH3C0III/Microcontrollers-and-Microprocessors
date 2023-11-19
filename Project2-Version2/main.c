#include "setup.h"
#include "display.h"
#include "motor.h"

void
loop( DISPLAYS * displays , MOTOR * motor , char word[ numDisplays ] );

int
main( ) {
 DISPLAYS * display = ( DISPLAYS * ) createDisplays();
 MOTOR * motor = ( MOTOR * ) createMotor();
 char word[ numDisplays ] ;
 (void)setup();
 
 for ( ; ; )
   (void)loop( display, motor , word );
   
 return 0;
}

void
loop( DISPLAYS * displays , MOTOR * motor , char word[ numDisplays ] ) {  
  switch ( flag ) {
    case 0b11111110:
      (void)writeInDisplay( displays );
      flag ^= ( 1 << 0 );
      break;
    case 0b11111101:
      if ( !motor->direction )
        snprintf( word , sizeof(byte) * numDisplays , " %d", motor->perDutyC );
      else
        snprintf( word , sizeof(byte) * numDisplays , "-%d", motor->perDutyC );
      
      (void)updateRegisterDisplays( displays, word );
      flag ^= ( 1 << 1 );
      break;
  }	
 
  nowValue = PINA & 0b00110011;  
  switch ( nowValue ) {
  	case 0b11111110:
  	  if ( motor->perDutyC < 100 )
        motor->perDutyC += motor->points ;
  	  break;

  	case 0b11111101:
  	  if ( motor->perDutyC > 0 )
        motor->perDutyC -= motor->points ;
  	  break;

  	case 0b11101111:
  	  if ( beforeValue == 0b11111111 && nowValue == 0b11101111 )
  	    (void)changeRotationMotor( motor );
  	  break;

  	case 0b11011111:
  	  if ( beforeValue == 0b11111111 && nowValue == 0b11011111 )
        (void)changeStateMotor( motor );
  	  break;
  }   
  beforeValue = PINA & 0b00110011;  
}

ISR ( TIMER0_COMP_vect ) {
  flag ^= ( 1 << 0 );

  if ( counter == 0 ) {
    counter = frequencyDisplays;
    flag ^= ( 1 << 1 );
  }   
  else
    counter-- ;      

}
