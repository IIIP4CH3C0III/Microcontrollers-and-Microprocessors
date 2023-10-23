;
; File   : Project_Class_19-09.asm
;
; Created: 19/09/2023 12:00
; Author : Fábio Pacheco, Joana Sousa
;
; Descric: Ao pressionar um botão ligar um LED 
;

_setup:               ; Inicialization of variables, and IO
  ldi r16, 0b11111111 ; load as output the register 16, to configure the DDRC
  out DDRC, r16       ; define as output DDRC
  out PORTC, r16      ; turn off every LED
  
  ldi r17, 0b11011110 ; load as input the bit 0,5
  out DDRA, r17       ; define as input DDRA, bit 5

_loop:
  ; AND GATE
  sbic PINA, 0        ; check if button bit 0 was pressed
  rjmp _off           ; else turn off the lights
  sbic PINA, 5        ; check if button bit 5 was pressed
  rjmp _off           ; else turn off the lights
  cbi PORTC, 0        ; turn on the light

_off:
  out PORTC, r16      ; turn off every LED
  ; sbi PORTC, 0        ; turn off the light
  rjmp _loop          ; return to the loop