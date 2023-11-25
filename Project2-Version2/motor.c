/* 
 * File name : motor.c
 *
 * Descript  : This where the funtions related to the motor are.
 *
 * Author    : Fábio Pacheco
 */

#include "motor.h"

MOTOR *
createMotor( ) {
  MOTOR * motor = ( MOTOR * ) malloc ( sizeof ( MOTOR ) ) ;
  motor->state    = 0  ; 
  motor->stage    = 0  ; 
  motor->direction= 0  ;
  motor->absDutyC = 128; 
  motor->perDutyC = 50 ;
  motor->points   = 5  ;   

  // PWM signal
  OCR2  = motor->absDutyC;              // Variable alocated in the setup.h

  return motor;
}


unsigned char
changeRotationMotor( MOTOR * motor  ) {
  /*
   * It checks if the motor is on and its in first stage (0), if that's true it will stop the motor
   * And it leaves the function, after the flag Tim2 was activated, the if statment with stage 1 now selected
   * it will enter the function changeRotationMotor again, but now the first if statment isn't true, 
   * but the second is, so it will change the rotation based in the bit direction and change the state of the motor again
   */

  if ( motor->state && !motor->stage ) {
  	(void)changeStateMotor( motor );
  	motor->stage = 1;
  } 
  else if ( motor->stage ) {
    motor->direction ^= motor->direction;
    motor->stage = 0;
	(void)changeStateMotor( motor ); 
  }  
  return 0;	
}

unsigned char
changeStateMotor( MOTOR * motor ) {
  if ( PORTB == 0b01111111 || PORTB == 0b00011111 ) {
    motor->state = 1 ;
    if ( motor->direction )
      PORTB |= ( 1 << 6 );     // Start the rotation in the oter way   	
    else
      PORTB |= ( 1 << 5 );     // Start the rotation in the oter way   	
    return 0;
  } 
  
  PORTB &= 0b10011111;       // Stop the rotation
  motor->state = 0 ;  	
  return 0;
}

unsigned char
linearSolver( unsigned char y2, 
              unsigned char y1,
              unsigned char x2,
              unsigned char x1,
              unsigned char var
             ) {

  unsigned char	m = ( y2 - y1 ) / ( x2 - x1 ) ;
  unsigned char b = y2 - m*x2 ;
  unsigned char y = m*var + b ;
  return y;
}
