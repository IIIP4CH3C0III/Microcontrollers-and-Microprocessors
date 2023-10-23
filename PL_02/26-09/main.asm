;---------------------------------------------------------------------------------------------------------
; 
; File    : main.asm 
; 
; Created : 26-09-2023
; Author  : Fábio Pacheco, Joana Sousa
;
; Descrip : Pressing a switch to turn on LED
;
;---------------------------------------------------------------------------------------------------------

;---------------------------------------------------------------------------------------------------------
; Inicializations and setup of the hardware
;---------------------------------------------------------------------------------------------------------

_setup:
  ; PORTA are connected the switches
  ; PORTC are connected the LEDs

  ldi r16, 0b00000000 ; Load to register 16 all the bits as inputs
  out DDRA, r16       ; Define DDRA all the bits to inputs
  ldi r16, 0b11011111 ; Load to register 16, forcing every entry 0
  out PORTA, r16      ; Forcing states

  ldi r16, 0b00000001 ; Load to register 16 all the bits as inputs besides the first bit which will be an output
  out DDRC, r16       ; Define DDRC in order above

  ldi r17, 0b11111111 ; Load to register 17 the intruction to turn off every LED
  ldi r18, 0b11111110 ; Load to register 18 the intruction to turn on LED 0
  out PORTC, r17      ; Execute the intruction to turn off the LED

;---------------------------------------------------------------------------------------------------------
; Logic Code
;---------------------------------------------------------------------------------------------------------
    
_loop:
  ; Read the inputs and update the outputs
  in r16, PINA        ; Get the byte from the PINA and load to register 16
  ori r16, 0b11011111 ; Do the sum and make sure we have the right input, otherwise store the right one in register 16 
  cpi r16, 0b11011111 ; Compare the register 16 to the constant, in order to know if the user pressed the button
  brne _off           ; Consult the flag Z in order to know if the button is pressed

  out PORTC, r18      ; Turn the bit 0 on
  rjmp _loop          ; Return to the loop

_off:
  out PORTC, r17
  rjmp _loop

;---------------------------------------------------------------------------------------------------------
; End File
;---------------------------------------------------------------------------------------------------------
