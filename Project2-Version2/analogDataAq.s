;-----------------------------------------------------------------------------------------------------------------------------------------
; 
; File    : analogDataAq.s 
; 
; Author  : Fábio Pacheco, Joana Sousa
;
; Descrip : 
;           Perform an average of two captured values from the ADC
;
;-----------------------------------------------------------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------------------------------------------------------
; Instruction to the compiler
;-----------------------------------------------------------------------------------------------------------------------------------------

#include <avr/io.h>

#define temp r16                       ; Temporary register
#define ADSC 6                         ; Temporary register

.extern analogBuffer                   ; Reuse of the space in memory alocated to store the high buffer of the return value

.global getADCvalue                    ; Declaration of the function name

;-----------------------------------------------------------------------------------------------------------------------------------------
; Routines
;-----------------------------------------------------------------------------------------------------------------------------------------

getADCvalue:
  lds temp, ADCSRA                     ; Get the data from RAM to temp
  sbr temp, 0b01000000                 ; Start the conversion 
  sts ADCSRA, temp                     ; Update the value in RAM
  
_loop:
  lds  temp, ADCSRA                    ; Get the flags from the state register
  sbrc temp, ADSC                      ; Check if the bit 6 is set, if 
  rjmp _loop             

  lds temp, ADCH                       ; Read the value from RAM
  sts analogBuffer, temp               ; Load the variable into RAM to access in C program
  
  ret

;-----------------------------------------------------------------------------------------------------------------------------------------
; End
;-----------------------------------------------------------------------------------------------------------------------------------------
