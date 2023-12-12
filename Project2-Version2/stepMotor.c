#include "stepMotor.h"

STEP_MOTOR * 
createStepMotor( void ) {
   STEP_MOTOR * st = ( STEP_MOTOR * ) malloc ( sizeof( STEP_MOTOR ) );
   st->word[0] = 0b00001001; 
   st->word[1] = 0b00001100; 
   st->word[2] = 0b00000110; 
   st->word[3] = 0b00000011; 

	return st;
}
