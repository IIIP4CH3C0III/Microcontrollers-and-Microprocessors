/* 
 * File name : motor.h
 *
 * Descript  : This where the protypes of the funtions related to the motor and the struct motor
 *
 * Author    : Fábio Pacheco
 */


#ifndef MOTOR_H
#define MOTOR_H

#include "setup.h"

#define timeMotorStop  10 // Counter reset for 0.5ms * 10 = 5 ms ~= 200 Hz

typedef struct {
  byte state:     1 ;
  byte direction: 1 ;
  byte stage:     1 ;
  byte absDutyC     ;
  byte perDutyC     ; 
  byte points       ;
} MOTOR;

unsigned char
changeRotationMotor( MOTOR * motor );

unsigned char
changeStateMotor( MOTOR * motor );

MOTOR *
createMotor( );

float
linearSolver( float y2, 
              float y1,
              float x2,
              float x1,
              float var
             );

#endif
