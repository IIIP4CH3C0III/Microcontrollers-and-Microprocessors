/*
 * Name : Fábio Pacheco
 *
 * Date : 14/11/2023
 *
 * Desc : 
 *        Pressing the switch 1, start the display 0 showing numbers from 0 to 9 
 *        Pressing the switch 2, start the display 1 showing numbers from 0 to 9 
 *        The transition for each number is 200 ms
 *        The transition for each display is 5 ms
 *        Pressing the switch 4, stops the displays that are rolling
 *
 * Hard :
 *        PORTD contains the switches and the display selection
 *        PORTC contains the value that is in the display
 */ 

#include <avr/interrupt.h>
#include <avr/iom128.h>

#define  timeBase             77

#define  display0             0
#define  display1             1
#define  display2             2 
#define  display3             3 

#define  false                0
#define  true                 1

#define  counterResetValue    200

#define numDisplays           4

void setup(void);
void loop(void);

typedef struct {
  unsigned char num;	
  unsigned char word;	
  unsigned char rise;	
} DISPLAY;

volatile unsigned char timeFlagD = false;                  // This time flag will be responsible for changing between displays
volatile unsigned char timeFlagF = false;                  // This time flag will be responsible for the refresh time of the displays
volatile unsigned char counter   = counterResetValue;
unsigned char counter1 = 4;

const unsigned char displayWordSelection[4] = { 0b11110100, 0b10110100, 0b01110100, 0b00110100 };
const unsigned char displayDigits[11]       = { 0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0x80, 0x90, 0xFF };
volatile DISPLAY display[ numDisplays ];
unsigned char selectedDisplay = 0;

int
main() {
  (void)setup();

  for ( ; ; ) 
    (void)loop();

  return 0;
}

void setup(void) {
  DDRD  = 0b11000000 ;                                     // 0 represents INPUTS, 1 represents OUTPUT

  EICRA = 0xFF       ;                                     // The rising edge of INTn generates asynchronously an interrupt request.
  EIMSK = 0b00001011 ;                                     // Enable the switches for the interrupts

  DDRC  = 0xFF       ;                                     // Set the display as an output

  OCR0  = timeBase   ;                                     // Time base for the mode 2 equation for a prescaler 1024
  TCCR0 = 0b00111111 ;                                     // Enable CTC mode 2, prescalar of 1024, set 0C0 on compare match
  TIMSK = 0b00000010 ;                                     // Timer/Counter0 Output Compare Match Interrupt Enable 
    
  sei();

  for ( unsigned char i = 0 ; i < 4 ; i++ ) {
    display[i].num  = 10;
    display[i].word = displayWordSelection[i] ;  	
    display[i].rise = false;
  }

}

void loop(void) {
  if ( timeFlagD ) {
    timeFlagD = false;

    if( display[ selectedDisplay-1 ].num > 10 ) 
      display[ selectedDisplay-1 ].num = 0;

    for ( unsigned char i = 0 ; i < 4 ; i++ ) {
      PORTD = display[ selectedDisplay-1 ].word;
      PORTC = displayDigits[ display[ selectedDisplay-1 ].num ] ;

    if ( timeFlagF )
	    switch ( selectedDisplay ) {
	      case display0: // 11
	          if ( display[ selectedDisplay ].rise ) {
	            display[ selectedDisplay ].num++;
	            counter1--;          	
	          }
	          selectedDisplay++;
	        break;    	
	      case display1: // 10   	
	          if ( display[ selectedDisplay ].rise ) {
	            display[ selectedDisplay ].num++;
	            counter1--;          	
	          }
	          selectedDisplay++;
	        break;    	
	      case display2: // 01    	
	          if ( display[ selectedDisplay ].rise ) {
	            display[ selectedDisplay ].num++;
	            counter1--;          	
	          }
	          selectedDisplay++;
	        break;    	
	      case display3: // 00   	
	          if ( display[ selectedDisplay ].rise ) {
	            display[ selectedDisplay ].num++;
	            counter1--;          	
	          }
	          selectedDisplay = display0 ;
	        break;    	
	    }

  }
  
  if ( !counter1 ) { 
    counter1 = 4;
    timeFlagF = false;
  }
  
}

ISR ( INT0_vect ) {
  display[0].rise = true;
}

ISR ( INT1_vect ) {
  display[1].rise = true;
}

ISR ( INT4_vect ) {
  display[0].rise = false;
  display[1].rise = false;
}


ISR ( TIMER0_COMP_vect ) {
  timeFlagD = true;

  if ( counter == 0 ) {
    counter = counterResetValue ;
  	timeFlagF = true ;
  }   
  else
    counter-- ;      
}

