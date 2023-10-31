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
.def cont1 = r18                       ; This variable will be used to count until 6
.def cont2 = r19                       ; This variable will be used to count until inside timers standart
.def cont3 = r20                       ; This variable will be used to count until inside timers
.def comV  = r21                       ; This variable will be used to compare things
.def maxV  = r22                       ; This variable will be used to compare things

.equ Reset = 0x0000                    ; Definition of the reset interruption 
.equ Start = 0x0002                    ; Definition of the start interruption 
.equ Stop  = 0x0008                    ; Definition of the stop  interruption
.equ Tim0  = 0x001E                    ; Definition of the tim0  interruption
.equ Code  = 0x0046                    ; Definition of where the code will start

.equ stg2  = 10                        ; Special char for a certain moment in the program

.cseg                                  ; Start the segment of code to the compiler
.org Reset                             ; Indicate if the code as an interrrupt with reset
  rjmp _setupCold                      ; Jump to the normal procedure

.org Start                             ; Indicate if the start button was pressed
  rjmp _startP                         ; Jump to the start procedure

.org Stop                              ; Indicate if the stop  button was pressed
  rjmp _stopP                          ; Jump to the stop procedure

.org Tim0                              ; Indicate if the timer flag was triggered
  rjmp _timeP                          ; Jump to the timer procedure

.org Code                              ; Where the code will start
  
;-----------------------------------------------------------------------------------------------------------------------------------------
; Inicializations and setup of the hardware
;-----------------------------------------------------------------------------------------------------------------------------------------

_setupCold:
  ; Setup up PORTD <Buttons + Dis.Control>
  ldi temp, 0b11000000                 ; Load to register 16 the value to assign to the PORTD
  out DDRD, temp                       ; Update the value on RAM of DDRD, in this case make all inputs besides 6,7
  ldi temp, 0b11011110                 ; Load to register 16 the value to assign the pull up resistors and the display selection
  out PORTD, temp                      ; Update the value on RAM of PORTD, in this case pull up resistors
  ; Update the EICRA register in RAM, and EIMSK
  ldi temp, 0b11000011                 ; Load to register 16 the value of activate the interrupt of int3 and int0 at rising edge
  sts EICRA, temp                      ; Update the value in RAM, should use the STS because ins't in the area covered by OUT
  ldi temp, 0b00000001                 ; The interrupts that will start activated, we will just use start for now, but this register will be upd
  out EIMSK, temp                      ; From the next intruction on we can recieve interrupts from the START, int0 

  sei                                  ; Enable the interrupt flag from SREG

  ; Setup up PORTC <DISPLAY>
  ldi temp, 0xFF                       ; Load to register 16 the value to assign to the PORB
  out DDRC, temp                       ; Update the value on RAM of DDRB, in this case make everything outputs 

  ; Setup up the TIMER
  ldi temp, 156                        ; This OCR0 value was selected from the equation T = Prescalar/CLK * ( OCR0 + 1 )
  out OCR0, temp                       ; Set the OCR0 to the value in temp, in this case for 10 ms, with a prescale of 1024
  ldi temp, 0b00001111                 ; Load to register temp, CTC on, and prescale 1024
  out TCCR0, temp                      ; Update the value in RAM of TCCR0 based in temp register
  ldi temp, 0b00000010                 ; Load to register temp, OCIE0 Enable for CTC flag
  out TIMSK, temp                      ; Update value in RAM
          
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
  
  ; Warm display <Print 1>
  ser temp                             ; Load everthing to 1s
  out PORTC, temp                      ; Update value in RAM, update to 8

  ; Other Events
  ldi comV, 0                          ; This will be a variable use in the rest of the program
  
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
; Routines for Interrupts
;-----------------------------------------------------------------------------------------------------------------------------------------

_startP:
  ldi temp, 0b00001000                 ; Load to the register 16 the value for chanching the activated interrupts
  out EIMSK, temp                      ; Enable the stop interrupt from the RAM   
  ser temp                             ; Load to the register temp everything at 1, to clean all flags after
  out EIFR, temp                       ; Flags of the interrupts

  ldi cont2, 2                         ; The counter for the timer
  ldi maxV , 5                         ; Set the max value to reach in this stage
  ldi comV , 0b00000001                ; Add the last bit that means it should start
  mov cont3, cont2

  reti

_stopP:
  ldi temp, 0b00000001                 ; Load to the register 16 the value for chanching the activated interrupts
  out EIMSK, temp                      ; Enable the start interrupt from the RAM   
  ser temp                             ; Load to the register temp everything at 1, to clean all flags after
  out EIFR, temp                       ; Flags of the interrupts        

  ldi cont1, 0                         ; Set the counter one with a special number
  ldi cont2, 100                       ; The counter for the timer
  ldi varAS, 0x00                      ; Load to register 17 the sum to the next position in RAM
  ldi maxV , 5                         ; Set the max value to reach in this stage
  mov cont3, cont2

  ori comV , 0b00000010                ; Add the first bit that means it should stop
  reti


_timeP:
  dec cont3
  brne _endTimeP
  mov cont3, cont2
  sbr comV, 0b00010000
_endTimeP:
  reti

;-----------------------------------------------------------------------------------------------------------------------------------------
; Main Code
;-----------------------------------------------------------------------------------------------------------------------------------------

_main:
  sbrs comV, 0                         ; Verify if the start button was pressed
  brne _main                           ; If its not equal back to the main
  clt                                  ; Clear T flag, so i can increment

_selec:
  cpi comV, 0b00000001                 ; Check if the procedure is still in the first stage
  breq _fStage                         ; If it is go back to the first stage
  cpi comV, 0b00000011                 ; Check if the procedure is in the second stage
  breq _sStage                         ; If it is go to the second stage
  rjmp _main                           ; If neither options are true return to the main

_fStage:
  ldi cont1, 0                         ; Set the counter
  ldi XL, 0x00                         ; Reposition the lower address of the X pointer
  rjmp _loop

_sStage:
  ldi comV , 0                         ; Back to the beginning number
  
_loop:
  sbrs comV, 4                         ; Verify if the bit of timer is set 
  rjmp _loop
  
_continue:  
  cbr comV, 0b00010000                 ; Clear the bit of the timer 

  in temp, PINC                        ; Get the value from the RAM of PINC
  cpi temp, 0xFF                       ; Verify if everthing is at 1s
  brne _off                            ; if it is true show the next number

  call _loadMove                       ; Load the value in RAM being the r17 the argument of add and r16 the register to return
  out PORTC, temp                      ; Update value in RAM, update to 8
  rjmp _skip

_off:                                  ; Else turn everthing off
  ser temp                             ; Set every bit in register temporary
  out PORTC, temp                      ; Update the value in RAM

_skip: 
  cp cont1, maxV                       ; Compare to check if limit was reached
  breq _selec                          ; If zero flag is activated return to the first stage
  inc cont1                            ; Increment the first counter 

  cpi comV, 0b00000000                 ; Check if the after button was pressed
  breq _end                            ; If its equal go to the main

  rjmp _loop                        

_end:
  call _loadMove                       ; Load the value in RAM being the r17 the argument of add and r16 the register to return
  out PORTC, temp                      ; Update value in RAM, update to 8
  rjmp _main
;-----------------------------------------------------------------------------------------------------------------------------------------
; End File
;-----------------------------------------------------------------------------------------------------------------------------------------
