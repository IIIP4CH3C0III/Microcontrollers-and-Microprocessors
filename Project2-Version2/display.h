/* 
 * File name : display.h
 *
 * Descript  : Handle struct and some definitions for the display
 *
 * Author    : Fábio Pacheco
 */

#ifndef DISPLAY_H
#define DISPLAY_H

#include "setup.h"
 
#define frequencyDisplays              6 // counter for 5ms * 6 = 30 ms ~= 30 Hz
#define frequencyBetweenDisplays       1 // counter for 5ms * 1 = 5  ms ~= 200 Hz

#define numDigits                      12
#define numDisplays                    4

typedef struct{
  byte registerN; // Stores the number or characther that is on the display
  byte registerA; // Stores the word to activate the display
} DISPLAY;

typedef struct{
  /*
   * In order to write information on the screen, the user as to insert the number in registerN, and write to the PORTx where the display is selected the registerA
   */
  DISPLAY display[numDisplays];
  byte selected;
} DISPLAYS;

DISPLAYS *
createDisplays();

unsigned char
updateRegisterDisplays( DISPLAYS * displays , char * word );

unsigned char
writeInDisplay( DISPLAYS * displays );

#endif
