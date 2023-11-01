;-----------------------------------------------------------------------------------------------------------------------------------------
; 
; File    : main.asm 
; 
; Created : 23-10-2023
; Author  : Fábio Pacheco, Joana Sousa
;
; Descrip : 
;          Simulate the access control system of a room with maximum lotation of 9
;          people. The entrance and exit of people is made using the same location and
;          the passage of people is detected by sensors S1 and S2. Every time the
;          lotation reaches the maximum value, the door PE (D8) must be closed to
;          prevent more people coming in. The display on the right must show the
;          number of vacant places in the room. The room light LS (D7) must be
;          turned OFF everytime the room is empty.
;
;-----------------------------------------------------------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------------------------------------------------------
; Instruction to the compiler
;-----------------------------------------------------------------------------------------------------------------------------------------

.include <m128def.inc>                 ; Indicate that we are working with atmega128

.def XL    = r26                       ; Defition of the X pointer low and high
.def XH    = r27
.def temp  = r16                       ; Definition of temporary variable register
.def varAS = r17                       ; This variable will be used to set how much are we advancing or returning on the stack pointer 
.def cont1 = r18                       ; Definition of the register that will store the argument timer
.def comV  = r19                       ; Definition of the register that will store the argument timer

.equ Reset = 0x0000                    ; Definition of the reset interruption 
.equ Tim0  = 0x001E                    ; Definition of the tim0  interruption
.equ Code  = 0x0046                    ; Definition of where the code will start

.equ PE    = 7                         ; Definition of the pin D8 for the door
.equ LS    = 6                         ; Definition of the pin D7 for the light

.cseg                                  ; Start the segment of code to the compiler
.org Reset                             ; Indicate if the code as an interrrupt with reset
  rjmp _setupCold                      ; Jump to the normal procedure

.org Tim0                              ; Indicate if the timer flag was triggered
  rjmp _tim0                           ; Jump to the timer procedure

.org Code                              ; Where the code will start
  
;-----------------------------------------------------------------------------------------------------------------------------------------
; Inicializations and setup of the hardware
;-----------------------------------------------------------------------------------------------------------------------------------------

_setupCold:
  ; Setup up PORTD <SENSORS + Dis.Control>
  ldi temp, 0b11000000                 ; Load to register 16 the value to assign to the PORTD
  out DDRD, temp                       ; Update the value on RAM of DDRD, in this case make all inputs besides 6,7
  ldi temp, 0b11011110                 ; Load to register 16 the value to assign the pull up resistors and the display selection
  out PORTD, temp                      ; Update the value on RAM of PORTD, in this case pull up resistors

  ; Setup up PORTA <LEDS>
  ldi temp, 0b11000000                 ; Load to register 16 the value to assign to the PORTC
  out DDRA, temp                       ; Update the value on RAM of DDRC, in this case make bit 0 and 7 outputs

  ; Setup up PORTC <DISPLAY>
  ldi temp, 0xFF                       ; Load to register 16 the value to assign to the PORB
  out DDRC, temp                       ; Update the value on RAM of DDRB, in this case make everything outputs 
          
_setupWarm:
  ; Inicialization of stack pointer
  ldi temp, 0xFF                       ; Load to register 16 the last position of the stack pointer
  out spl, temp                        ; Update in RAM the value of the stack pointer low at the 0xFF
  ldi temp, 0x10                       ; Load to register 16 the last position of the stack pointer
  out sph, temp                        ; Update in RAM the value of the stack pointer high at the 0x10    

  ; Inicialization of RAM pointer ( x )
  ldi XH, 0x01                         ; Load to register pointer X the main position of the RAM pointer high
  ldi XL, 0x00                         ; Load to register pointer X the last position of the RAM pointer low

  ; Save the truth table of the display into RAM
  ldi varAS, 0x01                      ; Load to register 17 the sum to the next position in RAM
  clt                                  ; This flag defines if we want to add or decrement the stack pointer when loaded or stored

  ldi temp, 0xC0                       ; Load to register 16 the representation in the display of number 0 
  call _storeMove                      ; Argument is in register 16 and now after save the file where the pointer is and move to the next
  ldi temp, 0xF9                       ; Load to register 16 the representation in the display of number 1
  call _storeMove                      ; Argument is in register 16 and now after save the file where the pointer is and move to the next
  ldi temp, 0xA4                       ; Load to register 16 the representation in the display of number 2
  call _storeMove                      ; Argument is in register 16 and now after save the file where the pointer is and move to the next
  ldi temp, 0xB0                       ; Load to register 16 the representation in the display of number 3  
  call _storeMove                      ; Argument is in register 16 and now after save the file where the pointer is and move to the next
  ldi temp, 0x99                       ; Load to register 16 the representation in the display of number 4
  call _storeMove                      ; Argument is in register 16 and now after save the file where the pointer is and move to the next
  ldi temp, 0x92                       ; Load to register 16 the representation in the display of number 5
  call _storeMove                      ; Argument is in register 16 and now after save the file where the pointer is and move to the next
  ldi temp, 0x82                       ; Load to register 16 the representation in the display of number 6  
  call _storeMove                      ; Argument is in register 16 and now after save the file where the pointer is and move to the next
  ldi temp, 0xF8                       ; Load to register 16 the representation in the display of number 7
  call _storeMove                      ; Argument is in register 16 and now after save the file where the pointer is and move to the next
  ldi temp, 0x80                       ; Load to register 16 the representation in the display of number 8
  call _storeMove                      ; Argument is in register 16 and now after save the file where the pointer is and move to the next
  ldi temp, 0x90                       ; Load to register 16 the representation in the display of number 9
  call _storeMove                      ; Argument is in register 16 and now after save the file where the pointer is and move to the next
  
  ; Warm display <Print 9>
  out PORTC, temp                      ; Update value in RAM, update to 8

  ; Other Events
  ldi comV, 0                          ; This will be a variable use in the rest of the program
  ldi cont1, 10                        ; This will be a variable use in the rest of the program
  
  rjmp _main                           ; Jump the routine functions and go to main

;-----------------------------------------------------------------------------------------------------------------------------------------
; Routines
;-----------------------------------------------------------------------------------------------------------------------------------------

_storeMove: ; Arguments r16 as the value to Store and r17 as the add value
  st X, temp                           ; Store into the RAM the value in r16
  brtc __clr                           ; If T flag cleared go to add
  rjmp __set                           ; else decrement

_loadMove:  ; Arguments r16 as the register that recives the value and r17 as the add value
  brtc __clr                           ; If T flag cleared go to add
  rjmp __set                           ; else decrement

__clr:
  add XL, varAS                        ; Move the pointer in the low position depending on the argument of register 17 ( + )
  brcc __memoryNreach                  ; If this is false means the XL reached FF and we have to increment another position in the XH
  inc XH                               ; Increment a value in the position of more important value of the pointer X
  rjmp __memoryNreach                  ; Goto the end of the routine

__set:
  sub XL, varAS                        ; Move the pointer in the low position depending on the argument of register 17 ( - )
  brne  __memoryNreach                 ; If it didn't reach the 0 return, otherwise decrement a value of the high pointer
  dec XH                               ; Decrement the high pointer in this case XH 

__memoryNreach:
  ld temp, X                           ; Load the number diagram into the r16
  ret                                  ; Return to the last position  

;-----------------------------------------------------------------------------------------------------------------------------------------
; Main Code
;-----------------------------------------------------------------------------------------------------------------------------------------

_main:
  

_loop:
  in temp, PIND                        ; Read from the RAM the exact value of Inputs
  cpi temp, 0b11111110                 ; Check if S1 is pressed and S2 is not
  breq __1                             ; If that's true check the first sensor
  cpi temp, 0b11011111                 ; Check if S2 is pressed and S1 is not
  breq __2                             ; If that's true check the second sensor
  rjmp _loop                           ; Back to the loop

__1:
  in temp, PIND                        ; Read from the RAM the exact value of Inputs
  cpi temp, 0b11011110                 ; Check if S1 and S2 are pressed  
  brne __1                             ; While the two sensors are passed

_S1:
  in temp, PIND                        ; Read from the RAM the exact value of Inputs
  cpi temp, 0b11111110                 ; Check if S1 is pressed  
  brne _S1

  cpi cont1, 0                         ; Verify if 0 was reached
  breq __c1                            ; If 0 was reached jump to __c1
  dec cont1                            ; Decrement a slot in the room
  cbi PORTA, LS                        ; Turn the light on
  ; Display 
  set                                  ; Subtracte the values inside the RAM pointer, the subtract argument varAS
  ldi varAS, 1                         ; The argument to the LoadMove
  call _loadMove                       ; Load the value from RAM and store in the temporary register
  out PORTC, temp                      ; Print the value on the display
  ; EndDisplay
  rjmp _loop                           ; Back to the loop
     
__c1:
  cbi PORTA, PE                        ; Close the door "turn light on"
  rjmp _loop                           ; Back to the loop

__2:
  in temp, PIND                        ; Read from the RAM the exact value of Inputs
  cpi temp, 0b11011110                 ; Check if S1 and S2 are pressed  
  brne __2                             ; While the two sensors are passed

_S2:
  in temp, PIND                        ; Read from the RAM the exact value of Inputs
  cpi temp, 0b11011111                 ; Check if S2 is pressed  
  brne _S2

  cpi cont1, 10                        ; Verify if 10 was reached
  breq __c2                            ; If 0 was reached jump to __c1
  dec cont1                            ; Decrement a slot in the room
  cbi PORTA, LS                        ; Turn the light on
  sbi PORTA, PE                        ; Open the door "turn off"
  ; Display 
  clt                                  ; Add the values inside the RAM pointer, the add argument varAS
  ldi varAS, 1                         ; The argument to the LoadMove
  call _loadMove                       ; Load the value from RAM and store in the temporary register
  out PORTC, temp                      ; Print the value on the display
  ; EndDisplay
  rjmp _loop                           ; Back to the loop

__c2:
  sbi PORTA, LS                        ; Turn off the light
  rjmp _loop                           ; Back to the loop


;-----------------------------------------------------------------------------------------------------------------------------------------
; End File
;-----------------------------------------------------------------------------------------------------------------------------------------
