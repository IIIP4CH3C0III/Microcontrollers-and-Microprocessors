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

typedef struct {
  int16_t phase;
  byte word[ tableRowsForStep ];
  byte position;

} STEP_MOTOR;

STEP_MOTOR * 
createStepMotor( void );

byte
rotationStepMotor( STEP_MOTOR * st , uint16_t phaseIntended , char direction , byte origin );

uint16_t
getPhaseDif ( uint16_t phaseNow , uint16_t phaseIntented  , char * direction );

#endif
