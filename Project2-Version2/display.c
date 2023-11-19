/* 
 * File name : display.c
 *
 * Descript  : Contains the functions related to print information on the displays
 *
 * Author    : Fábio Pacheco
 */


#include "display.h"

DISPLAYS *
createDisplays() {
  DISPLAYS * displays = ( DISPLAYS * ) malloc ( sizeof ( DISPLAYS ) );

  for ( unsigned char i = 0 ; i < numDisplays ; i++ )
    displays->display[ i ].registerA = displayActivations[ i ];  
  return displays;
}

unsigned char
writeInDisplay( DISPLAYS * displays ) {
  PORTA = displays->display[ displays->selected ].registerA;
  PORTC = displays->display[ displays->selected ].registerN;

  if( displays->selected == (numDisplays - 1) )
    displays->selected = 0;
  else
    displays->selected++;
   return 0;
}

unsigned char
updateRegisterDisplays( DISPLAYS * displays , char * word ) {
  for ( unsigned char i = 0 ;  i < numDisplays ; i++ ) 
	switch ( word[i] ) {
		case 'A':
		case 'a':
		  break;
		  
		case 'B':
		case 'b':
		   break;

		case 'C':
		case 'c':
		  break;

		case 'D':
		case 'd':
		  break;

		case 'E':
		case 'e':
		  break;

		case 'F':
		case 'f':
		  break;

		case 'G':
		case 'g':
		  break;

		case 'H':
		case 'h':
		  break;

		case 'I':
		case 'i':
		  break;

		case 'J':
		case 'j':
		  break;

		case 'K':
		case 'k':
		  break;

		case 'L':
		case 'l':
		  break;

		case 'M':
		case 'm':
		  break;

		case 'N':
		case 'n':
		  break;

		case 'O':
		case 'o':
		  break;

		case 'P':
		case 'p':
		  break;

		case 'Q':
		case 'q':
		  break;

		case 'R':
		case 'r':
		  break;

		case 'S':
		case 's':
		  break;

		case 'T':
		case 't':
		  break;

		case 'U':
		case 'u':
		  break;

		case 'V':
		case 'v':
		  break;

		case 'W':
		case 'w':
		  break;

		case 'X':
		case 'x':
		  break;

		case 'Y':
		case 'y':
		  break;

		case 'Z':
		case 'z':
		  break;

		case '0':
             displays->display[i].registerN = displayDigits[0];
		  break;

		case '1':
             displays->display[i].registerN = displayDigits[1];
		  break;

		case '2':
             displays->display[i].registerN = displayDigits[2];
		  break;

		case '3':
             displays->display[i].registerN = displayDigits[3];
		  break;

		case '4':
             displays->display[i].registerN = displayDigits[4];
		  break;

		case '5':
             displays->display[i].registerN = displayDigits[5];
		  break;

		case '6':
             displays->display[i].registerN = displayDigits[6];
		  break;

		case '7':
             displays->display[i].registerN = displayDigits[7];
		  break;

		case '8':
             displays->display[i].registerN = displayDigits[8];
		  break;

		case '9':
             displays->display[i].registerN = displayDigits[9];
		  break;

		case '-':
             displays->display[i].registerN = displayDigits[11];
		  break;

		default:
             displays->display[i].registerN = displayDigits[10];
		  break;
	}
  return 0;	
}

