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
  motor->direction= 0  ;
  motor->absDutyC = 128; 
  motor->perDutyC = 50 ;
  motor->points   = 5  ;   

  // PWM signal
  OCR2  = motor->absDutyC;              // Variable alocated in the function.h

  return motor;
}


unsigned char
changeRotationMotor( MOTOR * motor ) {
  if( motor->state ) {
    if ( PORTB & ( 1 << 5 ) ) { // Check if bit 5 is 1
      PORTB &= 0b10011111;      // Stop the rotation
      _delay_ms(5);             // Perform a delay of 5 ms
      PORTB |= ( 1 << 6 );      // Start the rotation in the oter way 
      motor->direction = 0;
    } else {
  	  PORTB &= 0b10011111;      // Stop the rotation
  	  _delay_ms(5);             // Perform a delay of 5 ms
      PORTB |= ( 1 << 5 );      // Start the rotation in the oter way 
      motor->direction = 1;
    }
  }
  return 0;	
}

unsigned char
changeStateMotor( MOTOR * motor ) {
  if ( PORTB == 0b01111111 || PORTB == 0b00011111 ) {
    motor->state = 1 ;
    if ( motor->direction )
      PORTB |= ( 1 << 5 );     // Start the rotation in the oter way   	
    else
      PORTB |= ( 1 << 6 );     // Start the rotation in the oter way   	
  } else {
    PORTB &= 0b10011111;       // Stop the rotation
    motor->state = 0 ;  	
  }
  
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
