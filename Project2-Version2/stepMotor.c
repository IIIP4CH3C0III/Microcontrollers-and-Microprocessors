#include "stepMotor.h"

STEP_MOTOR * 
createStepMotor( void ) {
   STEP_MOTOR * st = ( STEP_MOTOR * ) malloc ( sizeof( STEP_MOTOR ) );
   st->word[0] = 0b11111001; 
   st->word[1] = 0b11111100; 
   st->word[2] = 0b11110110; 
   st->word[3] = 0b11110011; 
   
   st->phase = 0;
   st->position = 0;
	return st;
}

byte
rotationStepMotor( STEP_MOTOR * st , uint16_t phaseIntended , char direction, byte origin ) {  
  byte numSteps;
  if ( !origin )
    numSteps = phaseIntended * completeRotationInSteps / 360;
  else
    numSteps = ( int )getPhaseDif( st->phase, phaseIntended, &direction ) * completeRotationInSteps / 360;
  byte i;
  for ( i = 0 ; i < numSteps ; i++ ){
	if ( direction == '+' ){
	  st->position++;
	  if ( st->position == 4 )
	    st->position = 0;
	  st->phase += stepDegrees;
	  if ( st->phase >= 360 )
	    st->phase = st->phase - 360;
	}  
	else {
      st->position--;
	  if ( st->position == 255 )
	    st->position = 3;
	  st->phase -= stepDegrees;
	  if ( st->phase < 0 )
	  st->phase = 360 + st->phase ;
	}
    PORTE = st->word[ st->position ];	
	_delay_ms( 25 );
  }
  return 0;
}

uint16_t
getPhaseDif ( uint16_t phaseNow , uint16_t phaseIntented  , char * direction ) {
  uint16_t dif = 0;
  phaseIntented %= 360;                                    // if the value inside phaseIntended is 360 it will be 0, otherwise is unchanged
  if ( phaseIntented == phaseNow )
    return dif;
  	
  if ( phaseIntented > phaseNow ){    
	dif = phaseIntented - phaseNow;
	if ( dif > ( 360 - phaseIntented + phaseNow ) ) {
      *direction = '-';                                    // rotation in Clockwise
	  return (360 - phaseIntented + phaseNow);
	}
	*direction = '+';                                      // rotation in AntiClockwise
	return dif;
  }
  
  dif = phaseNow - phaseIntented;
  if ( dif > ( 360 - phaseNow + phaseIntented ) ) {
 	  *direction = '+';                                    // rotation in AntiClockwise
	  return (360 - phaseNow + phaseIntented );
  }
  *direction = '-';                                        // rotation in Clockwise
  return dif;
}
