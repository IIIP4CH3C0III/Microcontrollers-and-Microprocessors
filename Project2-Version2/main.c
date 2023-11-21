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
  if( flag & ( 1 << 0 )) {
    (void)writeInDisplay( displays );
    flag &= ~( 1 << 0 );
  }

  if( flag & ( 1 << 1 )) {
    if ( !motor->direction )
      snprintf( word , sizeof(byte) * numDisplays + 1 , "  %02d", motor->perDutyC );
    else
      snprintf( word , sizeof(byte) * numDisplays + 1 , " -%02d", motor->perDutyC );

    (void)updateRegisterDisplays( displays, word );
    flag &= ~( 1 << 1 );
  }
 
  nowValue = PINA & 0b00110011;  
  switch ( nowValue ) {
  	case 0b00110010:
  	  if ( motor->perDutyC < 100 )
        if ( beforeValue == 0b00110011 && nowValue == 0b00110010 )
          motor->perDutyC += motor->points ;
   	break;

  	case 0b00110001:
  	  if ( motor->perDutyC > 0 )
        if ( beforeValue == 0b00110011 && nowValue == 0b00110001 )
          motor->perDutyC -= motor->points ;
  	break;

  	case 0b00100011:
  	  if ( beforeValue == 0b00110011 && nowValue == 0b00100011 )
  	    (void)changeRotationMotor( motor );
  	  break;

  	case 0b00010011:
  	  if ( beforeValue == 0b00110011 && nowValue == 0b00010011 )
        (void)changeStateMotor( motor );
  	  break;
  }   
  beforeValue = PINA & 0b00110011;  
}

ISR ( TIMER0_COMP_vect ) {
  flag |= ( 1 << 0 );

  if ( counter <= 0 ) {
    counter = frequencyDisplays;
    flag |= ( 1 << 1 );
  }   
  else
    counter-- ;      

}
