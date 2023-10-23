;---------------------------------------------------------------------------------------------------------
; 
; File    : main.asm 
; 
; Created : 03-09-2023
; Author  : Fábio Pacheco, Joana Sousa
;
; Descrip : After pressing the SW1 start a roller by a timer in each LED, and start reducing after each
;           LED 300ms until reaching D8, if at any time the SW6 is pressed stop whatever is doing until SW1
;           is pressed again
;
; Bugs    : Since we dind't used the hardware interrupt, we are checking the SW6 inside the delay routine
;           which increase the size of delay from 2 seconds to 5 seconds, in order to fix it we have
;           redo the values of x, y and z for that we have to create a new equation. 
;
;---------------------------------------------------------------------------------------------------------

;---------------------------------------------------------------------------------------------------------
; Instruction to the compiler
;---------------------------------------------------------------------------------------------------------

.include <m128def.inc>                 ; Indicate that we are working with atmega128

.cseg                                  ; Start the segment of code to the compiler
.org 0x00                              ; Indicate if the code as an interrrupt with reset
  rjmp _setup                          ; Jump to the normal procedure

.org 0x10                              ; Indicate if the sw6 was pressed as an interrupt, INT7
  rjmp _warm                           ; Only need to restart the stack

.equ Xcounter = 176                    ; Defition of the constant X of delay    
.equ Ycounter = 131                    ; Defition of the constant Y of delay
.equ Zcounter = 9                     ; Defition of the constant Z of delay

.equ diminishes = 3                    ; Defition of diminishes per cicle to remove timings

;---------------------------------------------------------------------------------------------------------
; Inicializations and setup of the hardware
;---------------------------------------------------------------------------------------------------------

_setup:
  ; We are using PORTA to the switches, and PORTC to the LEDs
  ; Setup up PORTA
  ldi r16, 0x00                        ; Load to register 16 all the bits as inputs
  out DDRA, r16                        ; Define DDRA all the bits to inputs
  ldi r16, 0b11011110                  ; Load to register 16 the inputs are not being use
  out PORTA, r16                       ; Forcing the above inputs to use the internal pull up resistors
 
  ; Setup up PORTC
  ldi r16, 0xFF                        ; Load to register 16 all the bits as outputs
  out DDRC, r16                        ; Define DDRC all the bits as outputs
  
  sei                                  ; Enable global interrupts
  ; The interrupts if enable will triger even if the INT7:0 pins are configured as outputs
   
  
_warm:
  ; Inicialization of stack pointer
  ldi r16, 0xFF                        ; Load to register 16 the last position of the stack pointer
  out spl, r16                         ; Start the stack pointer low at the 0xFF

  out PORTC, r16                       ; Make every LED turn off, reutilization of register 16 

  ldi r16, 0x10                        ; Load to register 16 the last position of the stack pointer
  out sph, r16                         ; Start the stack pointer high at the 0x10    

  ldi r17, 0x01                        ; Load to register 17 the add register 0000 0001
  ldi r18, 0x80                        ; Load to register 18 the add register 1000 0000
  ldi r20, 20                          ; Load to register 20 the decimal value of 20 to the left timer
  
  rjmp _main                           ; Jump the routine functions and go to main

;---------------------------------------------------------------------------------------------------------
; Routines
;---------------------------------------------------------------------------------------------------------

_delay:
  push r18                             ; Store the value from the r18 in the stack 
  push r19                             ; Store the value from the r19 in the stack
  push r20                             ; Store the value from the r20 in the stack

  ; For 100ms seconds at 16 Mhz
  ldi r20, Zcounter                    ; Load to register 20 the value of Z
__loopZ:                               

  ldi r19, Ycounter                    ; Load to register 19 the value of Y
__loopY:

  ldi r18, Xcounter                    ; Load to register 18 the value of X
__loopX:
  in r21, PINA                         ; Get the byte from the PINA and load to register 16
  ori r21, 0b11011111                  ; Independent if the user pressed other switches, sw6 will preserve
  cpi r21, 0b11011111                  ; Compare and check if switch 6 is pressed
  breq _warm                           ; If the zero flag is not 0 keep returning to the main, else continue

  dec r18                              ; Decrement the value of X
  brne __loopX                         ; Back to X loop

  dec r19                              ; Decrement the value of Y
  brne __loopY                         ; Back to Y loop

  dec r20                              ; Decrement the value of Z
  brne __loopZ                         ; Back to Z loop
        
  ; Remember the LIFO tipology
  pop r20                              ; Get the value from the past r20 from the stack
  pop r19                              ; Get the value from the past r19 from the stack
  pop r18                              ; Get the value from the past r18 from the stack
  ret                                  ; Return to the place lefted before


_timer:                                ; Argument is register 19 
  call _delay                          ; Execute the delay of 100 ms
  dec r19                              ; Decrement the value stored in the register 19
  brne _timer                          ; If the zero wasn't reached back to the loop 
  ret                                  ; Return to the place lefted before     
  
;---------------------------------------------------------------------------------------------------------
; Routines without a return statment
;---------------------------------------------------------------------------------------------------------

__left:
  ; 1111 1100 > COMPLEMENT_1 ( 1111 1110 ) + 0000 0001 + SHIFT_LEFT( 0000 0010 ) + 0000 0001 + COMPLEMENT_1 ( 1111 1100 ) 
  ; 1111 1000 > COMPLEMENT_1 ( 1111 1100 ) + 0000 0011 + SHIFT_LEFT( 0000 0110 ) + 0000 0001 + COMPLEMENT_1 ( 1111 1000 ) 

  com r16                              ; Do complement to 1
  lsl r16                              ; Shift to the left 
  add r16, r17                         ; Add the register 16 to register 17 and store the result in r16
  com r16                              ; Do complement to 1
  rjmp _loop                           ; Back to the loop    

__right:
  ; 1000 0000 > 0000 0000 + SHIFT_RIGHT( 0000 0000 ) + 1000 0000
  ; 1100 0000 > 1000 0000 + SHIFT_RIGHT( 0100 0000 ) + 1000 0000
  ; 1111 1100 > 1111 1000 + SHIFT_RIGHT( 0111 1100 ) + 1000 0000
  
  lsr r16                              ; Shift to the right 
  add r16, r18                         ; Add to register 16 the register 18 and store the result in r16
  rjmp _loop                           ; Back to the loop    


_decrementTimer:
  cpi r20, 0x00                        ; If already reached 0 
  breq __continueIfZero                ; Jump the decrements 
  dec r20                              ; Decrement 3 times so we are removing 300 ms from 2 seconds

  dec r19                              ; Decrement the value from for statment
  brne _decrementTimer                 ; If it didn't reached the end back to the loop
  rjmp __continue                      ; Jump back
;---------------------------------------------------------------------------------------------------------
; Logic Code
;---------------------------------------------------------------------------------------------------------

_main:
  in r16, PINA                         ; Get the byte from the PINA and load to register 16
  ori r16, 0b11111110                  ; Independent if the user pressed other switches, sw1 will preserve
  cpi r16, 0b11111110                  ; Compare and check if switch 1 is pressed
  brne _main                           ; If the zero flag is not 0 keep returning to the main, else continue

  clt                                  ; Clear the T flag, definition of direction left
  ldi r16, 0xFE                        ; Load to the register 16 : 1111 1110
  
_loop:
  out PORTC, r16                       ; Send the signal to LEDs 

  brtc _segLeft                        ; If the flag direction is 0 go to Segment of code to left
  rjmp _segRight                       ; else go to Segment of code to right
  
_segLeft:
  mov r19, r20                         ; Copy what is inside register 20 to register 19
  call _timer                          ; Execute the timer routine r19, the time is given by : 2 - k.3
  
  ldi r19, diminishes                  ; Load as argument the time of diminishes each cicle 
  rjmp _decrementTimer                 ; Jump to the decrement time "routine"

__continueIfZero:
  add r20, r17                         ; Make sure the next time y don't do a delay of 0 ITS A BUG
__continue:
  cpi r16, 0b00000000                  ; Compare if the value reached the limit
  brne __left                          ; <false> is shifting to the left   
  set                                  ; Make the flag T direction 1  
  ldi r20, 20                          ; Reset the value of 2 seconds timer

  ldi r19, 30                          ; Load to register 19 the number 30 in decimal, 30*0.1 ms = 3s
  call _timer                          ; Execute the timer routine r19 is the time wanted
  rjmp _loop                           ; Back to loop
  
_segRight:
  ldi r19, 10                          ; Load to register 19 the number 10 in decimal, 10*0.1 ms = 1s
  call _timer                          ; Execute the timer routine r19 is the time wanted

  cpi r16, 0b11111111                  ; Compare if the value reached the limit
  brne __right                         ; <false> is shifting to the right
  clt                                  ; Make the flag direction 0   

  rjmp _loop                           ; Back to the loop    
  
;---------------------------------------------------------------------------------------------------------
; End File
;---------------------------------------------------------------------------------------------------------
