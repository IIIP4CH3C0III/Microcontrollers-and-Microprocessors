;-----------------------------------------------------------------------------------------------------------------------------------------
; 
; File    : main.asm 
; 
; Created : 23-10-2023
; Author  : Fábio Pacheco, Joana Sousa
;
; Descrip : 
;          Using one of the 7 segment displays, an electronic dice is to be implemented, by showing a sequence of 6 digits. 
;          Every time the start switch is pressed, the display must show the digit “1” to the digit “6” at a 20 ms (50 Hz) rate. 
;          When digit “6” is reached, the display must restart with digit “1”. Activating the stop switch, during the dice/roulette operation, 
;          the sequence must be halted and the current digit shown blinking at a frequency of 1 Hz. 
;          After 5 seconds the roulette must finish it’s operation and the display must show the digit without blinking. 
;          At the initial state, the display must be off with no digit showing.
;
;-----------------------------------------------------------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------------------------------------------------------
; Instruction to the compiler
;-----------------------------------------------------------------------------------------------------------------------------------------

.include <m128def.inc>                 ; Indicate that we are working with atmega128

.def temp  = r16                       ; Definition of temporary variable register
.def XL    = r26                       ; Defition of the X pointer low and high
.def XH    = r27
.def varAS = r17                       ; This variable will be used to set how much are we advancing or returning on the stack pointer 

.cseg                                  ; Start the segment of code to the compiler
.org 0x00                              ; Indicate if the code as an interrrupt with reset
  rjmp _setupCold                      ; Jump to the normal procedure

.org 0x46                              ; Indicate if the sw6 was pressed as an interrupt, INT7
  
;-----------------------------------------------------------------------------------------------------------------------------------------
; Inicializations and setup of the hardware
;-----------------------------------------------------------------------------------------------------------------------------------------

_setupCold:
  ; Setup up PORTD <Buttons + Dis.Control>
  ldi temp, 0b11000000                 ; Load to register 16 the value to assign to the PORTD
  out DDRD, temp                       ; Update the value on RAM of DDRD, in this case make all inputs besides 6,7
  ldi temp, 0b11011110                 ; Load to register 16 the value to assign the pull up resistors and the display selection
  out PORTD, temp                      ; Update the value on RAM of PORTD, in this case pull up resistors

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
  ldi XL, 0x10                         ; Load to register 16 the last position of the RAM pointer low
  ldi XH, 0x01                         ; Load to register 16 the main position of the RAM pointer high

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
  
  ; Warm display <Print 1>
  ldi varAS, 8                         ; Subtract 8 to the RAM stack pointer, it should be in 1
  set                                  ; This flag defines if we want to add or decrement the stack pointer when loaded or stored, in this case decrement
  call _loadMove                       ; Load the value in RAM being the r17 the argument of add and r16 the register to return
  out PORTC, temp                      ; Update value in RAM, update to 8

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
; Routines without a return statment
;-----------------------------------------------------------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------------------------------------------------------
; Main Code
;-----------------------------------------------------------------------------------------------------------------------------------------

_main:
  ; Check input
  in temp, PIND                        ; Store in the register 16 the value stored in RAM, in the position pointed by PIND
  cpi temp, 0xFE                       ; Check if the switch one was pressed, which means start the program ( dice )
  brne _main                           ; If the user didn't pressed keep on the loop coming back to main, else continue  

_pre:
  clt                                  ; Clear the T flag which will mean we are going to increment values   
  ldi varAS, 0                         ; This register will be used to store the supost position of our xpointer 
  ; Reinicialization of RAM pointer ( x )
  ldi XL, 0x10                         ; Load to register 16 the last position of the RAM pointer low
  ldi XH, 0x01                         ; Load to register 16 the main position of the RAM pointer high

_loop:
  cpi varAS, 6                         ; Verify if we reach 6, similar to >> for ( x = 0 ; x < 6 ; x++ )
  breq _pre                            ; If it was reached comeback to the pre loop, and start from 1 again
  
  ; Go from one to six
  inc varAS                            ; increment the register that contains the number on the display itself
  call _loadMove                       ; Get the value of the code of display    
  out PORTC, temp                      ; Update value in RAM, update to 8
  ; delay of 20 ms, maybe using tim0
  
  in temp, PIND                        ; Store in the register 16 the value stored in RAM, in the position pointed by PIND
  cpi temp, 0xF7                       ; Check if the switch for was pressed, which means stop the program ( dice )
  brne _loop                           ; If the user didn't pressed back to the loop, else continue

  ; Start the timer for 5 sec, maybe using tim0 again

__loop:
  ldi temp, 0xFF                       ; Load to register temporary the way shuting down  
  out PORTC, temp                      ; Update value in RAM, update to 8
  ; delay of 1 sec, maybe using tim1
  call _loadMove                       ; Get the number again to the temporary register
  out PORTC, temp                      ; Print over and over the same number 
  rjmp __loop                          ; Return to the second loop
  
   
;-----------------------------------------------------------------------------------------------------------------------------------------
; End File
;-----------------------------------------------------------------------------------------------------------------------------------------
