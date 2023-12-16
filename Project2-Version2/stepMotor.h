/* 
 * File name : stepMotor.h
 *
 * Descript  : This is where is located the structs and functions related to function of the step motor
 *
 * Author    : Fábio Pacheco
 */

#ifndef STEPMOTOR_H
#define STEPMOTOR_H

#include "setup.h"

#define  completeRotationInSteps   20
#define  tableRowsForStep          4
#define  stepDegrees               18  
#define  timeChangeInductor        50  // Counter to change to the next pair of inductors in ms -> 0.5ms * 50 = 25 ms

typedef struct {
  int16_t phase;
  byte word[ tableRowsForStep ];
  byte position;
  byte numSteps;
  char direction;

} STEP_MOTOR;

STEP_MOTOR * 
createStepMotor( void );

byte
rotationStepMotor( STEP_MOTOR * st , uint16_t phaseIntended, byte origin );

uint16_t
getPhaseDif ( STEP_MOTOR * st , uint16_t phaseIntented );

#endif
