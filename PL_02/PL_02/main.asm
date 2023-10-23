;
; PL_02.asm
;
;
; File   : Project_Class_26_09.asm
;
; Created: 26/09/2023 12:00
; Author : Fábio Pacheco, Joana Sousa
;
; Descric: Ao pressionar um botão ligar um LED 
;


; Replace with your application code
start:
  ldi r16,0b00000000	; 
  out DDRA,r16			; definir as entradas
  ldi r16,0b11011111	;
  out PORTA,r16			; ativar pullups

  ldi r16,0b00000001
  out DDRC,r16			; definir as saidas

  ldi r17,0b11111111	; 
  out PORTC,r16			; desligar todos os leds

  ldi r18,0b11111110	; ligar apenas o led 1

ciclo:
	in r16,PINA			; buscar os valores das entradas
	ori r16,0b11011111	; 
	cpi r16,0b11011111	; compara 
	brne apaga

	out PORTC,r18		; Liga o led 1
	rjmp ciclo			; 

apaga:
 out PORTC,r17			; poe as saidas a 1 (desliga os leds)
 rjmp ciclo				;