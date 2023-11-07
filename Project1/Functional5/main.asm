;-----------------------------------------------------------------------------------------------------------------------------------------
; 
; File    : main.asm 
; 
; Created : 23-10-2023 (03/11/23)
; Author  : Fábio Pacheco, Joana Sousa
;
; Descrip : 
;          Using 2 seven segment displays, it is intended to create a game similar to the rolling of 2 dices. 
;          The winner of the game is the player that achieves the larger number os points. Using the code from operation 4,
;          the software must be altered to implement the game using 2 seven segment displays, considering that display 0 increments and display 1
;          decrements the value of the digits in the roulette sequence. The game starts when switch start is pressed, with the 2 displays working in
;          simultaneous. When the switch stop is activated, the display 0 stops rolling but display 1 continues to roll. The time interval ∆t, 
;          in seconds, between activating the start switch and the stop switch must be saved in a register (maximum value of 255 s). 
;          The display 1 must stop rolling only after ∆t/2 seconds have passed from the moment the stop switch is activated. 
;          At the end, the displays 0 and 1 must be shown blinking at a frequency of 1 Hz during a 5 second interval. The switches SW2 (10 Hz) and 
;          SW3 (50 Hz) are used to select the frequency of the roulette operation in both displays. This frequency can be altered at any time during the game.;
;
;-----------------------------------------------------------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------------------------------------------------------
; Instruction to the compiler
;-----------------------------------------------------------------------------------------------------------------------------------------

.include <m128def.inc>                 ; Indicate that we are working with atmega128

.def disp1 = r11                       ; This variable is used store the number that is being showed in the display 1
.def disp2 = r12                       ; This variable is used store the number that is being showed in the display 2
.def cont2 = r13                       ; This variable will be used to count until 100
.def delta = r14                       ; This will count how many seconds passed since the start button was pressed until stop button
.def maxV  = r15                       ; This variable will be used to compare things
.def temp  = r16                       ; Definition of temporary variable register
.def varA  = r17                       ; This variable will be used to set how much are we advancing or returning on the stack pointer 
.def varS  = r18                       ; This variable will be used to set how much are we advancing or returning on the stack pointer 
.def cont1 = r19                       ; This variable will be used to count until maxV
.def contD = r20                       ; This variable will be used to count timers for displays
.def cont3 = r22                       ; This variable will be used to count until inside timers
.def comV  = r23                       ; This variable will be used to compare things
.def RaPo  = r24                       ; This variable will store the current position of the rise dice
.def FaPo  = r25                       ; This variable will store the current position of the falling dice
.def XL    = r26                       ; Defition of the X pointer low and high
.def XH    = r27

.equ Reset = 0x0000                    ; Definition of the reset interruption 
.equ Start = 0x0002                    ; Definition of the start interruption 
.equ Swi2  = 0x0004                    ; Definition of the switch 2 interruption 
.equ Swi3  = 0x0006                    ; Definition of the switch 3 interruption 
.equ Stop  = 0x0008                    ; Definition of the stop interruption
.equ Tim0  = 0x001E                    ; Definition of the tim0 interruption
.equ Code  = 0x0046                    ; Definition of where the code will start

.equ d1    = 0b11110000                ; Definition of the number to select the display 1, including the pull up resistors
.equ d2    = 0b10110000                ; Definition of the number to select the display 2, including the pull up resistors

.cseg                                  ; Start the segment of code to the compiler
.org Reset                             ; Indicate if the code as an interrrupt with reset
  rjmp _setupCold                      ; Jump to the normal procedure

.org Start                             ; Indicate if the start button was pressed
  rjmp _startP                         ; Jump to the start procedure

.org Swi2                              ; Indicate if the switch 2 button was pressed
  rjmp _change10                       ; Jump to the stop procedure

.org Swi3                              ; Indicate if the switch 3 button was pressed
  rjmp _change50                       ; Jump to the stop procedure

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
  ldi temp, d1                         ; Load to register 16 the value to assign the pull up resistors and the display selection
  out PORTD, temp                      ; Update the value on RAM of PORTD, in this case pull up resistors
  ; Update the EICRA register in RAM, and EIMSK
  ldi temp, 0b11111111                 ; Load to register 16 the value of activate the interrupt of int0 until int3 at rising edge
  sts EICRA, temp                      ; Update the value in RAM, should use the STS because ins't in the area covered by OUT
  ldi temp, 0b00000001                 ; The interrupts that will start activated
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
  ldi varA, 0x01                       ; Load to register 17 the sum to the next position in RAM
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
  
  ; Clear displays
  ldi temp, d1                         ; Word to select the display 1 
  out PORTD, temp                      ; Update the value in RAM of the display based on the temporary value above
  ser temp                             ; Load everthing to 1s
  out PORTC, temp                      ; Update value in RAM, update to none
  ldi temp, d2                         ; Word to select the display 2 
  out PORTD, temp                      ; Update the value in RAM of the display based on the temporary value above
  ser temp                             ; Load everthing to 1s
  out PORTC, temp                      ; Update value in RAM, update to none
  mov disp1, temp                      ; Reset the display register value
  mov disp2, temp                      ; Reset the display register value
   
  ; Other Events
  ldi comV, 0                          ; This will be a variable use in the rest of the program, this bit will be the flag bit like sreg
  
  ldi temp, 200                        ; Implement for 2 second
  mov cont2, temp                      ; Move the value from above to the cont2

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
  sub XL, varS                        ; Move the pointer in the low position depending on the argument of register 17 ( - )
  brne  __memoryNreach                 ; If it didn't reach the 0 return, otherwise decrement a value of the high pointer
  dec XH                               ; Decrement the high pointer in this case XH 

__memoryNreach:
  ld temp, X                           ; Load the number diagram into the r16
  ret                                  ; Return to the last position  

;-----------------------------------------------------------------------------------------------------------------------------------------
; Routines for Interrupts
;-----------------------------------------------------------------------------------------------------------------------------------------

_startP:
  ldi temp, 0b00001110                 ; Enable the all the other interrupts besides the start switch
  out EIMSK, temp                      ; Enable the stop interrupt from the RAM   
  ser temp                             ; Load to the register temp everything at 1, to clean all flags after
  out EIFR, temp                       ; Flags of the interrupts

  ldi varA , 0x01                      ; Load to register 17 the sum to the next position in RAM
  ldi varS , 0x01                      ; Load to register 17 the sub to the next position in RAM
  ldi comV , 0b00000001                ; Add the last bit that means it should start 
  ldi RaPo, 0                          ; Set the counter
  ldi FaPo, 7                          ; Set the counter
  ldi contD, 5                         ; Start the frequency at 10 Hz
  mov cont3, contD                     ; The value that will actually be decremented from the timer
  ser temp                             ; Load to the temporary register everthing at 1s
  mov disp1, temp                      ; Reset the display register value
  mov disp2, temp                      ; Reset the display register value
  
  ldi temp, 0                          ; Is needed because its r15
  mov delta, temp                      ; Start the delta timer
  
  ldi temp, 255                        ; Is needed because its r15
  mov maxV , temp                      ; Set the max value to reach in this stage ( 1 - 6 )
  
  reti

_stopP:
  lds temp, EIMSK                      ; Get from RAM the value stored in the position of EIMSK and put in temp
  cbr temp, 0b00001000                 ; Disable the stop switch 
  out EIMSK, temp                      ; Enable the start interrupt from the RAM   
  ser temp                             ; Load to the register temp everything at 1, to clean all flags after
  out EIFR, temp                       ; Flags of the interrupts        

  ldi cont1, 0                         ; Set the counter one with a special number
  ldi varA, 0x00                       ; Load to register 17 the sum to the next position in RAM
  sbr comV , 0b00000010                ; Add the first bit that means it should stop

  mov maxV , delta                     ; The value that took from the start until the stop button

  reti

_change10:
  lds temp, EIMSK                      ; Get from RAM the value stored in the position of EIMSK and put in temp
  sbr temp, 0b00000100                 ; Enable the switch 3
  cbr temp, 0b00000010                 ; Disable the switch 2
  out EIMSK, temp                      ; Enable the start interrupt from the RAM   
  ser temp                             ; Load to the register temp everything at 1, to clean all flags after
  out EIFR, temp                       ; Flags of the interrupts        

  ldi contD, 5                         ; Enable in both counters the waiting required for 10 Hz
  mov cont3, contD                     ; Update with the new value from conter Display 1 
  
  reti

_change50:
  lds temp, EIMSK                      ; Get from RAM the value stored in the position of EIMSK and put in temp
  sbr temp, 0b00000010                 ; Enable the switch 2
  cbr temp, 0b00000100                 ; Disable the switch 3
  out EIMSK, temp                      ; Enable the start interrupt from the RAM   
  ser temp                             ; Load to the register temp everything at 1, to clean all flags after
  out EIFR, temp                       ; Flags of the interrupts        

  ldi contD, 1                         ; Enable in both counters the waiting required for 50 Hz
  mov cont3, contD                     ; Update with the new value from conter Display 1   

  reti

  
_timeP:
  call _timeO                          ; Perform the 1 seconds delta T
  dec cont3                            ; Decrement the counter3 which is the counter that will be decrementing from the counter 2 
  brne _endTimeP                       ; Verify if already reached 0 and if that's the case jump to the loop, else continue
  mov cont3, contD                     ; Move the value of the counter d1 to the counter 3, reseting the value to decrement
  sbr comV, 0b00001000                 ; Set the bit in comV word, saying the time has passed
  rjmp _endTimeP

_endTimeP:
  reti                                 ; Return enabling the the interrupts flag from sreg

_timeO: ; Gotta check this TODO
  dec cont2                            ; Decrement the counter3 which is the counter that will be decrementing from the counter 2 
  brne _endTime0                       ; Verify if already reached 0 and if that's the case jump to the loop, else continue
  inc delta                            ; Increment a second into delta
  ldi temp, 200                        ; Implement for 2 second
  mov cont2, temp                      ; Move the value from above to the cont2

_endTime0:  
  ret
;-----------------------------------------------------------------------------------------------------------------------------------------
; Main Code
;-----------------------------------------------------------------------------------------------------------------------------------------

_main:

  /* Should only be inserted in real-life, not in simulations, excessive cpu load
  ldi temp, d1                         ; Word to select the display 1 
  out PORTD, temp                      ; Update the value in RAM of the display based on the temporary value above
  out PORTC, disp1                     ; Output the word stored in display 1
  ldi temp, d2                         ; Word to select the display 1 
  out PORTD, temp                      ; Update the value in RAM of the display based on the temporary value above
  out PORTC, disp2                     ; Output the word stored in display 2
  */
   
  sbrs comV, 0                         ; Verify if the start button was pressed
  brne _main                           ; If its not equal back to the main
  
_fStage:
  ldi cont1, 0                         ; Start the "program counter" this will be responsible for knowing when should it stop the loop 
  rjmp _loop

_sStage:
  sbr comV, 0b00000100                 ; Set that now we are entering the third stage
  rjmp _loop

_tStage: 
  ldi temp, 0b00000001                 ; Disable everything, besides the start button
  out EIMSK, temp                      ; Enable the start interrupt from the RAM   
  ser temp                             ; Load to the register temp everything at 1, to clean all flags after
  out EIFR, temp                       ; Flags of the interrupts        

  ldi comV , 0                         ; Back to the beginning number
  ldi cont1, 0                         ; Start the "program counter" this will be responsible for knowing if we arrived at RaPo 7 and FaPo 0  
  ldi temp, 20                         ; Pulse 5 times just showing the numbers
  mov maxV , temp                      ; Set the max value to reach in this stage ( 1 - 6 )
  ldi contD, 50                        ; Establish the 1 Hz refresh rate
  ldi varS, 0x00                       ; Fix the value in the second display aswell
  
  rjmp _loop

_selec:
  mov temp, comV                       ; Move the value inside the compare value to the temporary
  andi temp, 0b00000111                ; Perform an and operation, to just check the stage bits
  cpi temp,  0b00000001                ; Compare and check if it is on the first stage
  breq _fStage                         ; If its equal go to the first stage
  cpi temp,  0b00000011                ; Compare and check if the user pressed the stop button and second stage is now active
  breq _sStage
  cpi temp,  0b00000111                ; Compare and check if the user pressed the stop button and third stage is now active  
  breq _tStage

  mov XL, RaPo                         ; Move the value from RaPo position to the pointer in RAM
  call _loadMove                       ; Get the value from RAM of the number
  mov disp1, temp                      ; And store it inside the register from the display
  mov XL, FaPo                         ; Move the value from RaPo position to the pointer in RAM  
  call _loadMove                       ; Get the value from RAM of the number
  mov disp2, temp                      ; And store it inside the register from the display
  
  rjmp _main                           ; If neither options are true return to the main
  
_loop:
  sbrs comV, 3                         ; Verify if the bit of timer is set 
  rjmp _loop  
  cbr comV, 0b00001000                 ; Clear the bit of the timer 
  
  sbrs comV, 4                         ; Verify if the bit of display is set 
  rjmp __D1                            ; Selected display 1 
  rjmp __D2                            ; Selected display 2

__D1:
  ldi temp, d1                         ; Word to select the display 1 
  out PORTD, temp                      ; Update the value in RAM of the display based on the temporary value above
  sbr comV, 0b00010000                 ; Select the display 2 for the next iteration

  mov temp, disp1                      ; Move the value for a valid register to be compared
  cpi temp, 0xFF                       ; Verify if everthing is at 1s
  brne _off                            ; if it is true show the next number

  mov XL, RaPo                         ; Move the value from RaPo position to the pointer in RAM
  clt                                  ; Make our counter move forward
  add RaPo, varA                       ; Sum the value in RaPo with the sum defined above

  in temp, PINC                        ; Get the value from the RAM of PINC
  mov disp1, temp                      ; Move the now value of the display inside disp1

  cpi RaPo, 6                          ; Check if we arrive at 7
  breq __rRaPo                         ; If it was reached go to the reset of his value
  rjmp _continue

__D2:
  ldi temp, d2                         ; Word to select the display 2 
  out PORTD, temp                      ; Update the value in RAM of the display based on the temporary value above
  cbr comV, 0b00010000                 ; Select the display 1 for the next iteration
 
  mov temp, disp2                      ; Move the value for a valid register to be compared
  cpi temp, 0xFF                       ; Verify if everthing is at 1s
  brne _off                            ; if it is true show the next number

  mov XL, FaPo                         ; Move the value from RaPo position to the pointer in RAM
  set                                  ; Make our counter move backwards
  sub FaPo, varS                       ; Sum the value in FaPo with the sum defined above

  cpi FaPo, 1                          ; Check if we arrive at 0
  breq __rFaPo                         ; If it was reached go to the reset of his value
  rjmp _continue                       ; Back to the continue
  
_continue:
  call _loadMove                       ; Load the value in RAM being the r17 the argument of add and r16 the register to return
  out PORTC, temp                      ; Update value in RAM, update to 8
  rjmp _skip

_off:                                  ; Else turn everthing off
  ser temp                             ; Set every bit in register temporary
  out PORTC, temp                      ; Update the value in RAM

_skip: 
  in temp, PINC                        ; Get the value from the RAM of PINC
  sbrs comV, 4                         ; Verify if the bit of display is set <inverse>
  mov disp2, temp                      ; Move the now value of the display inside disp2
  sbrc comV, 4                         ; Verify if the bit of display is clear <inverse>
  mov disp1, temp                      ; Move the now value of the display inside disp1

  cp cont1, maxV                       ; Compare to check if limit was reached
  breq _selec                          ; If zero flag is activated return to the first stage
  inc cont1                            ; Increment the first counter 

  rjmp _loop                        

__rRaPo:
  ldi RaPo, 0                          ; Set the counter
  rjmp _continue
__rFaPo:
  ldi FaPo, 7                          ; Set the counter
  rjmp _continue

;-----------------------------------------------------------------------------------------------------------------------------------------
; End File
;-----------------------------------------------------------------------------------------------------------------------------------------
