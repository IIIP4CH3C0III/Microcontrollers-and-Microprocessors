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
#include <avr/iom128.h>

#define temp r16                       ; Temporary register
#define ADSC 6                         ; Temporary register

.extern analogBuffer                   ; Reuse of the space in memory alocated to store the high buffer of the return value

.global getADCvalue                    ; Declaration of the function name

;-----------------------------------------------------------------------------------------------------------------------------------------
; Routines
;-----------------------------------------------------------------------------------------------------------------------------------------

getADCvalue:
  lds r16, ADCSRA                     ; Get the data from RAM to temp
  sbr r16, 0b01000000                 ; Start the conversion 
  sts ADCSRA, r16                     ; Update the value in RAM
  
_loop:
  lds  r16, ADCSRA                    ; Get the flags from the state register
  sbrc r16, 6                         ; Check if the bit 6 is set, if 
  rjmp _loop             

  lds r16, ADCH                       ; Read the value from RAM
  sts analogBuffer, r16               ; Load the variable into RAM to access in C program
  
  ret

;-----------------------------------------------------------------------------------------------------------------------------------------
; End
;-----------------------------------------------------------------------------------------------------------------------------------------
