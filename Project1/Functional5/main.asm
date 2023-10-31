;-----------------------------------------------------------------------------------------------------------------------------------------
; 
; File    : main.asm 
; 
; Created : 29-10-2023
; Author  : Fábio Pacheco, Joana Sousa
;
; Descrip : 
;            Using 2 seven segment displays, it is intended to create a game similar to the rolling of 2 dices. 
;            The winner of the game is the player that achieves the larger number os points. Using the code from operation 4,
;            the software must be altered to implement the game using 2 seven segment displays, 
;            considering that display 0 increments and display 1 decrements the value of the digits in the roulette sequence. 
;            The game starts when switch start is pressed, with the 2 displays working in simultaneous. 
;            When the switch stop is activated, the display 0 stops rolling but display 1 continues to roll. 
;            The time interval ∆t, in seconds, between activating the start switch and the stop switch must be saved in
;            a register (maximum value of 255 s). The display 1 must stop rolling only after ∆t/2 seconds have passed from the moment 
;            the stop switch is activated. At the end, the displays 0 and 1 must be shown blinking at a
;            frequency of 1 Hz during a 5 second interval. The switches SW2 (10 Hz) and SW3 (50 Hz) are used to select the frequency 
;            of the roulette operation in both displays. This frequency can be altered at any time during the game.
;
;-----------------------------------------------------------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------------------------------------------------------
; Instruction to the compiler
;-----------------------------------------------------------------------------------------------------------------------------------------

.include <m128def.inc>                 ; Indicate that we are working with atmega128

.def temp  = r16                       ; Definition of temporary variable register
.def varA  = r17                       ; This variable will be used to set how much are we advancing on the stack pointer 
.def varS  = r18                       ; This variable will be used to set how much are we returning on the stack pointer 
.def stag  = r19                       ; This variable is for monitor select, start status, and some other things eventually
.def RaPo  = r20                       ; This variable will be storing the position of display 1
.def FaPo  = r21                       ; This variable will be storing the position of display 2
.def delta = r22                       ; This variable will be storing the time since start was pressed until stop was pressed
.def timS  = r23                       ; This variable will be storing the time desired
.def timC  = r24                       ; This variable will be storing the time that will be decremented

.def XL    = r26                       ; Defition of the X pointer low and high
.def XH    = r27

.equ Reset = 0x0000                    ; Definition of the reset interruption 
.equ Start = 0x0002                    ; Definition of the start interruption 
.equ ChFq1 = 0x0004                    ; Definition of the switch2 interruption 
.equ ChFq5 = 0x0006                    ; Definition of the switch3 interruption 
.equ Stop  = 0x0008                    ; Definition of the stop  interruption
.equ Tim0  = 0x001E                    ; Definition of the tim0  interruption
.equ Code  = 0x0046                    ; Definition of where the code will start

.equ wd1  = 0b11011110                 ; Word for the display 1 
.equ wd2  = 0b10011110                 ; Word for the display 2 

.cseg                                  ; Start the segment of code to the compiler
.org Reset                             ; Indicate if the code as an interrrupt with reset
  rjmp _setupCold                      ; Jump to the normal procedure

.org Start                             ; Indicate if the start button was pressed
  rjmp _startP                         ; Jump to the start procedure

.org Stop                              ; Indicate if the stop  button was pressed
  rjmp _stopP                          ; Jump to the stop procedure

.org ChFq1                             ; Indicate if the switch2 button was pressed
  rjmp _chFq1                          ; Jump to the switch2 procedure

.org ChFq5                             ; Indicate if the switch3 button was pressed
  rjmp _chFq5                          ; Jump to the switch3 procedure

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
  ldi temp, wd1                        ; Load to register 16 the value to assign the pull up resistors and the display selection
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
  ldi XL, 0x00                         ; Load to register pointer X the last position of the RAM pointer low
  ldi XH, 0x01                         ; Load to register pointer X the main position of the RAM pointer high

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
  clt                                  ; This flag defines if we want to add or decrement the stack pointer when loaded or stored

  ; Other Events  
  
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
  add XL, varA                         ; Move the pointer in the low position depending on the argument of register 17 ( + )
  brcc __memoryNreach                  ; If this is false means the XL reached FF and we have to increment another position in the XH
  inc XH                               ; Increment a value in the position of more important value of the pointer X
  rjmp __memoryNreach                  ; Goto the end of the routine

__set:
  sub XL, varS                         ; Move the pointer in the low position depending on the argument of register 17 ( - )
  brne  __memoryNreach                 ; If it didn't reach the 0 return, otherwise decrement a value of the high pointer
  dec XH                               ; Decrement the high pointer in this case XH 

__memoryNreach:
  ld temp, X                           ; Load the number diagram into the r16
  ret                                  ; Return to the last position  


_timer:
  ret   
;-----------------------------------------------------------------------------------------------------------------------------------------
; Routines for Interrupts
;-----------------------------------------------------------------------------------------------------------------------------------------

_startP:
  sbr temp, 0b00001100                 ; Set to the register 16 the bit for chanching the activated interrupts
  out EIMSK, temp                      ; Enable the stop interrupt from the RAM   
  ser temp                             ; Load to the register temp everything at 1, to clean all flags after
  out EIFR, temp                       ; Flags of the interrupts

  sbr stag, 0b00000100                 ; Set the bit of start in the stag word
  ldi timS, 10                         ; Start with 10 Hz 
  
  reti

_stopP:
  ldi temp, 0b00000000                 ; Load to the register 16 the value for chanching the activated interrupts
  out EIMSK, temp                      ; Enable the start interrupt from the RAM   
  ser temp                             ; Load to the register temp everything at 1, to clean all flags after
  out EIFR, temp                       ; Flags of the interrupts        

  sbr stag, 0b00000001                 ; Set the bit of stop in the stag word

  reti

_chFq1:
  sbr temp, 0b00000100                 ; Set to the register 16 the bit for chanching the activated interrupts
  cbr temp, 0b00000010                 ; Clear to the register 16 the bit for chanching the activated interrupts
  out EIMSK, temp                      ; Enable the start interrupt from the RAM   
  ser temp                             ; Load to the register temp everything at 1, to clean all flags after
  out EIFR, temp                       ; Flags of the interrupts        

  reti

_chFq5:
  sbr temp, 0b00000010                 ; Set to the register 16 the bit for chanching the activated interrupts
  cbr temp, 0b00000100                 ; Clear to the register 16 the bit for chanching the activated interrupts
  out EIMSK, temp                      ; Enable the start interrupt from the RAM   
  ser temp                             ; Load to the register temp everything at 1, to clean all flags after
  out EIFR, temp                       ; Flags of the interrupts        

  reti

_timeP:

  reti
  
;-----------------------------------------------------------------------------------------------------------------------------------------
; Main Code
;-----------------------------------------------------------------------------------------------------------------------------------------

_main:
  ldi RaPo, 0x00                       ; Load to the register RaPo the position to start raising
  ldi FaPo, 0x07                       ; Load to the register FaPo the position to start falling
  ldi stag, 0x00                       ; Load the stag all to 0s so display 1 is "selected" and its in no stage, neither started have been pressed
  ldi delta, 0                         ; Load to the reference delta time at 0
  
  ldi temp, 0b00000001                 ; Set to the register temp the bit for chanching the activated interrupts
  out EIMSK, temp                      ; Enable the stop interrupt from the RAM   
  ser temp                             ; Load to the register temp everything at 1, to clean all flags after
  out EIFR, temp                       ; Flags of the interrupts        

_loop:
  cpi stag, 0b00000100                 ; Compare to the first possibility, first stage
  breq _fStage                         ; if it is go the first stage
  cpi stag, 0b00000101                 ; Compare to the second possibility, second stage
  breq _sStage                         ; if it is go the second stage
  cpi stag, 0b00000110                 ; Compare to the third possibility, third stage
  breq _tStage                         ; if it is go the third stage
  rjmp _loop                           ; Otherwise back to the loop

_fStage:
  mov timC, timS                       ; Insert value of the time desigred to the time counter
  ldi varA, 1                          ; Load to the add Value argument a 1 
  ldi varS, 1                          ; Load to the subtract Value argument a 1
  rjmp _if_DiSe
  
_sStage:
  ldi timS, 100                        ; Load to the timer 1 second
  mov timC, timS                       ; Move the value from timS to timC
  ldi varA , 0                         ; Load to the add Value argument a 0 
  ; ldi contS, delta/2 
  rjmp _if_DiSe
  
_tStage:
  ldi timC, 100                        ; Load to the timer 1 second
  ldi varS , 0                         ; Load to the subtract Value argument a 0 
  ; ldi contS, 5                         ; Load to the counter a 5 
  rjmp _if_DiSe

_if_DiSe:
     

;-----------------------------------------------------------------------------------------------------------------------------------------
; End File
;-----------------------------------------------------------------------------------------------------------------------------------------
