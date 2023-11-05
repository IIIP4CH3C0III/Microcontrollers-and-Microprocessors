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
.def cont  = r18                       ; Definition of the register that will store the counter value for the lotation
.def argTimer = r19                    ; Definition of the timer argument
.def comV  = r20                       ; Definition of the register that will store the compare value

.equ Reset = 0x0000                    ; Definition of the reset interruption 
.equ Code  = 0x0046                    ; Definition of where the code will start

.equ PE    = 7                         ; Definition of the pin D8 for the door
.equ LS    = 6                         ; Definition of the pin D7 for the light
.equ min   = 0                         ; Definition of min value to compare
.equ max   = 9                         ; Definition of max value to compare

.equ Xcounter = 241                    ; Defition of the constant X of delay    
.equ Ycounter = 22                     ; Defition of the constant Y of delay
.equ Zcounter = 1                      ; Defition of the constant Z of delay

.cseg                                  ; Start the segment of code to the compiler
.org Reset                             ; Indicate if the code as an interrrupt with reset
  rjmp _setupCold                      ; Jump to the normal procedure

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
  ser temp                             ; Load to register temporary all in 1s
  out PORTA, temp                      ; Turn everthing off
  
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
  ldi XL, 0x08                         ; Load to register pointer X the last position of the RAM pointer low
  call _loadMove                       ; Get the value 
  out PORTC, temp                      ; Update value in RAM, update to 8

  ; Other Events
  ldi cont , 9                         ; This will be a variable use in the rest of the program
  ldi varAS, 0                         ; We won't be using this variable to add or sub in the rest of the program
  ldi argTimer, 1                      ; Load the argument timer at 1, so just repeats once it calls the timer
  
  rjmp _main                           ; Jump the routine functions and go to main

;-----------------------------------------------------------------------------------------------------------------------------------------
; Timer
;-----------------------------------------------------------------------------------------------------------------------------------------

_delay:
  push r18                             ; Store the value from the r18 in the stack 
  push r19                             ; Store the value from the r19 in the stack
  push r20                             ; Store the value from the r20 in the stack
  ldi r20, Zcounter                    ; Load to register 20 the value of Z
__loopZ:                               
  ldi r19, Ycounter                    ; Load to register 19 the value of Y
__loopY:
  ldi r18, Xcounter                    ; Load to register 18 the value of X
__loopX:
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
  call _delay                          ; Execute the delay of 1 ms
  dec argTimer                         ; Decrement the value stored in the register 19
  brne _timer                          ; If the zero wasn't reached back to the loop 
  ret                                  ; Return to the place lefted before     

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
  ldi comV, 0                          ; Reset the flag word 
  mov XL, cont                         ; Insert in the pointer low from X the value inside counter
  call _loadMove                       ; Get the value in RAM for the value in XL
  out PORTC, temp                      ; Update the value in RAM for the display 
  
_loop:
  in temp, PIND                        ; Read from the RAM the exact value of Inputs

  cpi comV, 0b01001111                 ; Check if the word of person going inside is filled 
  breq _add
  cpi comV, 0b10001111                 ; Check if the word of person going inside is filled 
  breq _sub

  cpi temp, 0b11111110                 ; Check if S1 is pressed and S2 is not
  breq _S1AnS2                         
  cpi temp, 0b11011111                 ; Check if S2 is pressed and S1 is not
  breq _nS1AS2                         
  cpi temp, 0b11011110                 ; Check if S1 and S2 are pressed
  breq _S1AS2                         
  cpi temp, 0b11111111                 ; Check if nothing is pressed
  breq _nS1AnS2                         
  
  rjmp _loop                           ; Back to the loop


_S1AnS2:
  call _timer                          ; Execute a delay of 1 ms
  in temp, PIND                        ; Read from the RAM the exact value of Inputs
  sbrc temp, 0                         ; Skip the next line if the S1 was indeed pressed
  rjmp _loop                           ; Wasn't actually pressed 

  sbrs comV, 7                         ; Skip if the 7 bit is set from the word 0b1--- ----, which means the person is leaving
  sbr comV, 0b01000000                 ; If it's the first time, set the bit 6 meaning the person is coming in
  sbr comV, 0b00000001                 ; Set the bit 0 corresponds to the S1 was pressed      
  rjmp _loop

_nS1AS2:
  call _timer                          ; Execute a delay of 1 ms
  in temp, PIND                        ; Read from the RAM the exact value of Inputs
  sbrc temp, 5                         ; Skip the next line if the S2 was indeed pressed
  rjmp _loop                           ; Wasn't actually pressed 

  sbrs comV, 6                         ; Skip if the 6 bit is set from the word 0b-1-- ----, which means the person is entering
  sbr comV, 0b10000000                 ; If it's the first time, set the bit 6 meaning the person is coming in
  sbr comV, 0b00000010                 ; Set the bit 1 corresponds to the S2 was pressed      
  rjmp _loop

_S1AS2:
  call _timer                          ; Execute a delay of 1 ms
  in temp, PIND                        ; Read from the RAM the exact value of Inputs
  sbrc temp, 0                         ; Skip the next line if the S1 was indeed pressed
  rjmp _loop                           ; Wasn't actually pressed 
  sbrc temp, 5                         ; Skip the next line if the S2 was indeed pressed
  rjmp _loop                           ; Wasn't actually pressed 
  sbr comV, 0b00000100                 ; Set the bit 2 corresponds to the S1 & S2 were pressed      
  rjmp _loop

_nS1AnS2:
  cpi comV, 0                          ; Check if its the first time 
  breq _loop                           ; If it is back to the loop
  sbr comV, 0b00001000                 ; Else set the bit 4 which corresponds to the person not being anymore in the front of the sensors
  rjmp _loop

_add:
  cpi cont, 0                          ; Check if the free spaces arrived at 0 
  breq __closeDoor                     ; if its true just close door
  sbic PORTA, LS                       ; Skip the next line if the light is already turn on
  cbi PORTA, LS                        ; Turn the liht on from the room
  sbis PORTA, PE                       ; Skip the next line if the light from the door is already turn off
  sbi PORTA, PE                        ; Turn the light off, which means open the door
  dec cont                             ; Decrement a free space
  breq __closeDoor                     ; if it arrive at 0 close the door
  rjmp _main                           ; Back to the main

__closeDoor:
  sbic PORTA, PE                       ; Skip the next line if the light from the door is already turn on
  cbi PORTA, PE                        ; Turn the light on, which means closign the door
  rjmp _main                           ; Back to the main

_sub:
  cpi cont, 9                          ; Check if the free spaces arrived at 9
  breq __closeLight                    ; if its true just close the light from the room
  sbic PORTA, LS                       ; Skip the next line if the light is already turn on
  cbi PORTA, LS                        ; Turn the liht on from the room
  sbis PORTA, PE                       ; Skip the next line if the light from the door is already turn off
  sbi PORTA, PE                        ; Turn the light off, which means open the door
  inc cont                             ; Increment a free space
  cpi cont, 9                          ; Check if the free spaces arrived at 9
  breq __closeLight                    ; if its true just close the light from the room   
  rjmp _main                           ; Back to the main

__closeLight:
  sbis PORTA, LS                       ; Skip the next line if the light from the door is already turn off
  sbi PORTA, LS                        ; Turn the light off from the room
  rjmp _main                           ; Back to the main


;-----------------------------------------------------------------------------------------------------------------------------------------
; End File
;-----------------------------------------------------------------------------------------------------------------------------------------
