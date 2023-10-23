;---------------------------------------------------------------------------------------------------------
; 
; File    : main.asm 
; 
; Created : 30-09-2023
; Author  : Fábio Pacheco
;
; Descrip : Pretends to manage the state of multiple LEDs by this order below
;           SW1 - D4,D5 
;           SW2 - D3,D6 
;           SW3 - D2,D7 
;           SW4 - D1,D8 
;           SW6 - ALL OFF 
;
;---------------------------------------------------------------------------------------------------------

;---------------------------------------------------------------------------------------------------------
; Instruction to the compiler
;---------------------------------------------------------------------------------------------------------

.cseg                                  ; Start the code compiling segment
.org 0x00                              ; When reset is pressed go to 0x00
  rjmp _setup                          ; Jump to the setup

;---------------------------------------------------------------------------------------------------------
; Inicializations and setup of the hardware
;---------------------------------------------------------------------------------------------------------

_setup:
  ; We are using PORTA to the switches, and PORTC to the LEDs
  ; Setup up PORTA
  ldi r16, 0x00                        ; Load to register 16 all the bits as inputs
  out DDRA, r16                        ; Define DDRA all the bits to inputs
  ldi r16, 0b11010000                  ; Load to register 16 the inputs are not being use
  out PORTA, r16                       ; Forcing the above inputs to fix value, prevent flutuation
 
  ; Setup up PORTC
  ldi r16, 0xFF                        ; Load to register 16 all the bits as outputs
  out DDRC, r16                        ; Define DDRC all the bits as outputs
  out PORTC, r16                       ; Forcing every output to off

  ; Setup the stack
  out spl, r16                         ; Set the stack lower pointer 0xFF, we want a 2 bytes address 0x10FF
  ldi r16, 0x10                        ; Load to register 16 the address 0x10
  out sph, r16                         ; Set the stack higher pointer to the 0x10 value, so 0x10FF done!

;---------------------------------------------------------------------------------------------------------
; Routines
;---------------------------------------------------------------------------------------------------------

_sw1:
  cbi PORTC, 3                         ; Turn on the LED in pin 4
  cbi PORTC, 4                         ; Turn on the LED in pin 5
  rjmp _loop                           ; Return to the loop
_sw2:
  cbi PORTC, 2                         ; Turn on the LED in pin 3
  cbi PORTC, 5                         ; Turn on the LED in pin 6
  rjmp _loop                           ; Return to the loop
_sw3:
  cbi PORTC, 1                         ; Turn on the LED in pin 2
  cbi PORTC, 6                         ; Turn on the LED in pin 7
  rjmp _loop                           ; Return to the loop
_sw4:
  cbi PORTC, 0                         ; Turn on the LED in pin 1 
  cbi PORTC, 7                         ; Turn on the LED in pin 8
  rjmp _loop                           ; Return to the loop

;---------------------------------------------------------------------------------------------------------
; Logic Code
;---------------------------------------------------------------------------------------------------------

_loop:
  ; If switch 6 is pressed it overwrites every other signal, turning off all the LEDs
  in r16, PINA                         ; Get the byte from the PINA and load to register 16
  ori r16, 0b11011111                  ; Independent if the user pressed other switches, sw6 will preserv
  cpi r16, 0b11011111                  ; Compare and check if switch 6 is pressed
  breq _turn_off                       ; If the zero flag is one turn off every LED, else continue

  sbis PINA, 0                         ; Check if the 1 switch wasn't pressed, <true> jump next line
  rjmp _sw1                            ; Jump to the switch 1 LEDs routine

  sbis PINA, 1                         ; Check if the 1 switch wasn't pressed, <true> jump next line
  rjmp _sw2                            ; Jump to the switch 2 LEDs routine 

  sbis PINA, 2                         ; Check if the 1 switch wasn't pressed, <true> jump next line
  rjmp _sw3                            ; Jump to the switch 3 LEDs routine

  sbis PINA, 3                         ; Check if the 1 switch wasn't pressed, <true> jump next line
  rjmp _sw4                            ; Jump to the switch 4 LEDs routine

  rjmp _loop                           ; Repeat the loop
  
_turn_off:
  ldi r16, 0xFF                        ; Load to the register 16 the configuration of everything turn off
  out PORTC, r16                       ; Send the signal to the LEDs
  rjmp _loop                           ; Return to the main loop
  
;---------------------------------------------------------------------------------------------------------
; End File
;---------------------------------------------------------------------------------------------------------
