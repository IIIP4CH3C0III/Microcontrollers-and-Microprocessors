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

typedef struct {
  uint16_t phase;
  byte word[ tableRowsForStep ];

} STEP_MOTOR;

STEP_MOTOR * 
createStepMotor( void );

#endif
