;-----------------------------------------------------------------------------------------------------------------------------------------
; 
; File    : analogDataAq.asm 
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

#include "setup.h"

.def temp  = r16                       ; Temporary register
.def val1L = r17                       ; Store the first low value captured on the ADC
.def val1H = r18                       ; Store the first high value captured on the ADC
.def val2L = r19                       ; Store the second low value captured on the ADC
.def val2H = r20                       ; Store the second high value captured on the ADC
.def cont  = r21                       ; Counter to check if two numbers are selected

.extern nowValue                       ; Reuse of the space in memory alocated to store the high buffer of the return value
.extern beforeValue                    ; Reuse of the space in memory alocated to store the low buffer of the return value

.global analogASMread                  ; Declaration of the function name

;-----------------------------------------------------------------------------------------------------------------------------------------
; Routines
;-----------------------------------------------------------------------------------------------------------------------------------------

analogASMread:                         ; This routine will perform an average
  lds temp, ADCSRA                     ; Get the data from RAM to temp
  sbr temp, 0b01000000                 ; Start the conversion 
  sts ADCSRA, temp                     ; Update the value in RAM
  ldi cont, 2                          ; The amount of numbers needed to read  
  
_loop:
  lds  temp, ADCSRA                    ; Get the flags from the state register
  sbrs temp, ADSC                      ; Check if the bit 6 is set, if 
  rjmp _loop             

  cpi cont, 2                          ; if this is true it means is getting the first number  
  brne _next                           ; Get other number if that's false
  
  lds val1L, ADCL                      ; Get the lower value of the conversion
  lds val1H, ADCH                      ; Get the higher value of the conversion
  dec cont                             ; Decrement counter
  rjmp analogASMread                   ; Return to the top

_next:
  lds val2L, ADCL                      ; Get the lower value of the conversion
  lds val2H, ADCH                      ; Get the higher value of the conversion

  ret
