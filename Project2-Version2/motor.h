/* 
 * File name : motor.h
 *
 * Descript  : This where the protypes of the funtions related to the motor
 *
 * Author    : Fábio Pacheco
 */


#ifndef MOTOR_H
#define MOTOR_H

#include "setup.h"

typedef struct {
  byte state     ;
  byte direction ;
  byte absDutyC  ;
  byte perDutyC  ;
  byte points    ;
} MOTOR;

unsigned char
changeRotationMotor( MOTOR * motor );

unsigned char
changeStateMotor( MOTOR * motor );

MOTOR *
createMotor( );

unsigned char
linearSolver( unsigned char y2, 
              unsigned char y1,
              unsigned char x2,
              unsigned char x1,
              unsigned char var
             );

#endif
