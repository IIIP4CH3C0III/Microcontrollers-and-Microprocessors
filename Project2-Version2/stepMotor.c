/* 
 * File name : stepMotor.c
 *
 * Descript  : This where the functions related to the step motor.
 *
 * Author    : Fábio Pacheco, Joana Sousa
 */

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
   st->numSteps = 0;
	return st;
}

byte
rotationStepMotor( STEP_MOTOR * st , uint16_t phaseIntended, byte origin ) {  
  if ( st->numSteps == 0 ) {
    if ( !origin )
      st->numSteps = phaseIntended * completeRotationInSteps / 360;
    else
      st->numSteps = (uint16_t)getPhaseDif( st , phaseIntended ) * completeRotationInSteps / 360;
    flag.ROT = 1;
  } 

  if ( st->numSteps == 0 )
    flag.ROT = 0;

  if ( flag.ROT ) {
    if ( st->direction == '+' ){
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
    st->numSteps--;  	
  }
  return 0;
}

uint16_t
getPhaseDif ( STEP_MOTOR * st , uint16_t phaseIntented ) {
  uint16_t dif = 0;
  phaseIntented %= 360;                                    // if the value inside phaseIntended is 360 it will be 0, otherwise is unchanged
  if ( phaseIntented == st->phase )
    return dif;
  	
  if ( phaseIntented > st->phase  ){    
	dif = phaseIntented - st->phase ;
	if ( dif > ( 360 - phaseIntented + st->phase ) ) {
      st->direction = '-';                                 // rotation in Clockwise
	  return (360 - phaseIntented + st->phase );
	}
	st->direction = '+';                                   // rotation in AntiClockwise
	return dif;
  }
  
  dif = st->phase - phaseIntented;
  if ( dif > ( 360 - st->phase + phaseIntented ) ) {
 	  st->direction = '+';                                 // rotation in AntiClockwise
	  return (360 -st->phase + phaseIntented );
  }
  st->direction = '-';                                     // rotation in Clockwise
  return dif;
}
