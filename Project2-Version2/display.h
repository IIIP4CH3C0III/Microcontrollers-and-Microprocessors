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

const byte displayDigits[numDigits] = { 
                                       0xC0, // 0
                                       0xF9, // 1
                                       0xA4, // 2
                                       0xB0, // 3
                                       0x99, // 4
                                       0x92, // 5
                                       0x82, // 6
                                       0xF8, // 7
                                       0x80, // 8
                                       0x90, // 9
                                       0xFF, // 
                                       0xFD  // - 
                                      };

const byte displayActivations[numDisplays] = {
                                              0b00001100,
                                              0b01001100,
                                              0b10001100,
                                              0b11001100,
                                                 };

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
