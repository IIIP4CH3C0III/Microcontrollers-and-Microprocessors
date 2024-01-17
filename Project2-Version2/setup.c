/* 
 * File name : setup.c
 *
 * Descript  : This where the inicialization of the hardware starts
 *
 * Author    : Fábio Pacheco, Joana Sousa
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
  TCCR2 = 0b01100011;                   // PWM in phase correct mode, prescalar 64, Clear OC2 on compare match

  // USART    -> RS232	
  // Assincronous, 19200 bps, 8 bits of data, 1 stop bit, No parity bit on, RX int, 
  UBRR1H = 0 ;                          // Since the baudRate is 51 no need to use high
  UBRR1L = 51;
  UCSR1A = 0 ; 
  UCSR1B = 0b10011000;                  // Enable RX Int, TX and RX
  UCSR1C = 0b00000110;                  // 1 stop bit, 8 bits of data, assincronous 
  
  sei();
    
  // Trimmer  -> PORTF Pin0
  ADMUX  = 0b00100000;                 // AREF, Canal 0, ADLAR = 1   
  ADCSRA = 0b10000111;                 // Start ADC, 125k Hz 
  
  // Step Motor -> PORTE 
  DDRE   = 0b00001111;                 // The step only needs 4 pins to control
  PORTE  = 0b11110000;                 // Activate the pull up resistors
  
  
  // External Interrupts


}
