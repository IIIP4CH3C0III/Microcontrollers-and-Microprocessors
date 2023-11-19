/* 
 * File name : setup.c
 *
 * Descript  : This where the inicialization of the hardware starts
 *
 * Author    : Fábio Pacheco
 */

#include "setup.h"

void setup( void ) {
  // Switches -> PORTA
  DDRA  = 0b11000000;
  PORTA = 0b00001100;

  // Motor    -> PORTB
  DDRB  = 0b11100000;                  // Direction0 bit 5, Direction1 bit 6, PWM bit 7
  PORTB = 0b00011111;                  // Set both bits of direction to 0 so it doesn't move       
  
  // Display  -> PORTC           
  DDRC  = 0b11111111;
  PORTC = 0b11111111;
  
  // Clock Interrupts
  OCR0  = timeBaseOCR0;                // Defined in the function.h
  TCCR0 = 0b00111111;                  // Set 0C0 on compare match, prescalar 1024, CTC mode activated
  TIMSK = 0b00000010;                  // Enable compare on match interrupt for Tim0

  // PWM signal, 0CR2 set when creating the motor
  TCCR2 = 0b01110011;                   // PWM in phase correct mode, prescalar 64, Set OC2 on compare match

  sei();
    
  // Trimmer  -> PORTF
  // USART    -> RS232	
  // External Interrupts


}
