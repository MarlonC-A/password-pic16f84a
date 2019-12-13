; PIC16F84A Configuration Bit Settings
; Assembly source line config statements

#include "p16f84a.inc"

; CONFIG
; __config 0xFFF1
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF

;Declaracion de registros
TMR0        EQU 0x01
ESTADO      EQU 0x03
PUEB        EQU 0x06
INTCON      EQU 0x0B
REPIS       EQU 0x0C

;Declaracion de bits
PS0	        EQU 0x00
PS1	        EQU 0x01
PS2	        EQU 0x02
T0IF        EQU 0x02
PSA	        EQU 0x03
T0CS        EQU 0x05
RP0         EQU 0X05
RP1         EQU 0X06

    ORG 0
                bcf     ESTADO, RP1
                bsf     ESTADO, RP0
                movlw   b'11101111'
                movwf   PUEB
                bcf     TMR0,PSA
                bsf     TMR0,PS2
                bsf     TMR0,PS1
                bsf     TMR0,PS0
                bcf     TMR0,T0CS
                bcf     ESTADO, RP0
                
                clrf    REPIS
        inicio  bcf     PUEB,4
                movfw   PUEB
                sublw   b'00000100'
                btfss   ESTADO,2
                goto    inicio
                goto    paso1
        paso1   movfw   PUEB
                sublw   b'00000100'
                btfsc   ESTADO,2
                goto    paso1
        paso1m  movfw   PUEB
                addlw   .0
                btfsc   ESTADO,2
                goto    paso1m
                movfw   PUEB
                sublw   b'00001000'
                btfss   ESTADO,2
                goto    inicio
                goto    paso2
        paso2   movfw   PUEB
                sublw   b'00001000'
                btfsc   ESTADO,2
                goto    paso2
        paso2m  movfw   PUEB
                addlw   .0
                btfsc   ESTADO,2
                goto    paso2m
                movfw   PUEB
                sublw   b'00000010'
                btfss   ESTADO,2
                goto    inicio
                goto    paso3
        paso3   movfw   PUEB
                sublw   b'00000010'
                btfsc   ESTADO,2
                goto    paso3
        paso3m  movfw   PUEB
                addlw   .0
                btfsc   ESTADO,2
                goto    paso3m
                movfw   PUEB
                sublw   b'00001000'
                btfsc   ESTADO,2
                goto    unlock
                goto    inicio
        unlock  bsf     PUEB,4
                call    cincos
                goto    inicio
                
        ;Para contar cinco segundos, el método más sencillo es desbordar el TIMER0 varias veces
        ;Con un predivisor de 256 y un oscilador de 4 MHz, el desbordamiento ocurre en ~1/16 s
        ;Esto se obtiene de la fórmula TDesborde = TOsc * 4 * (TMR0 - 256) * Predivisor
        ;Para cinco segundos, es necesario desbordar el TIMER0 ~76 veces
        
        ;Subrutina de Delay(5s)
        cincos  btfss   INTCON, T0IF
                goto    cincos
                goto    desbor
        desbor  incf    REPIS,1
                bcf     INTCON, T0IF
                movfw   REPIS
                xorlw   .76
                btfss   ESTADO,2
                goto    cincos
                clrf    REPIS
                return
    END
