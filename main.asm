; PIC16F84A Configuration Bit Settings
; Assembly source line config statements

#include "p16f84a.inc"

; CONFIG
; __config 0xFFF1
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF

;Declaracion de registros
TMR0        EQU 0x01
ESTADO      EQU 0x03
PUEA        EQU 0x05
PUEB        EQU 0x06
INTCON      EQU 0x0B
REPIS       EQU 0x0C
PAL0        EQU 0x0D
PAL1        EQU 0x0E
PAL2        EQU 0x0F
PAL3        EQU 0x10

;Declaracion de bits
PS0         EQU 0x00
PS1         EQU 0x01
PS2         EQU 0x02
T0IF        EQU 0x02
PSA         EQU 0x03
T0CS        EQU 0x05
RP0         EQU 0x05
RP1         EQU 0x06

    ORG 0
        
        ;Se usa el Puerto B como entradas de contraseña para que sea sencillo añadir 'palabras' a esta
        ;La salida se encuentra en el Puerto A, el cual puede suministrar un máximo de 20 mA
        ;Para conectar algo más exigente que un LED a la salida, se recomienda usar un optoacoplador
        
                bcf     ESTADO, RP1
                bsf     ESTADO, RP0
                movlw   b'00011110'
                movwf   PUEA
                movlw   b'11111111'
                movwf   PUEB
                bcf     TMR0,PSA
                bsf     TMR0,PS2
                bsf     TMR0,PS1
                bsf     TMR0,PS0
                bcf     TMR0,T0CS
                bcf     ESTADO, RP0
                clrf    REPIS
                
        ;Los bloques 'newp#' se usan para ingresar una contraseña nueva
        ;Esto sólo ocurre la primera vez que inicia el programa, o tras presionar el botón de RESET
        ;Además, 'newp#r' indica que la siguiente instrucción no se debe ejecutar hasta soltar (Release) el boton
        
        newp0   btfss   PUEA,1
                goto    newp0
                movfw   PUEB
                movwf   PAL0
        newp0r  btfsc   PUEA,1
                goto    newp0r
        
        newp1   btfss   PUEA,1
                goto    newp1
                movfw   PUEB
                movwf   PAL1
        newp1r  btfsc   PUEA,1
                goto    newp1r
                
        newp2   btfss   PUEA,1
                goto    newp2
                movfw   PUEB
                movwf   PAL2
        newp2r  btfsc   PUEA,1
                goto    newp2r
                
        newp3   btfss   PUEA,1
                goto    newp3
                movfw   PUEB
                movwf   PAL3
        newp3r  btfsc   PUEA,1
                goto    newp3r 
             
        ;Los bloques 'paso#' permiten que la contraseña sea ingresada
           
        paso0   bcf     PUEA,0
                btfss   PUEA,1
                goto    paso0
        paso0r  btfsc   PUEA,1
                goto    paso0r
                movfw   PUEB
                xorlw   PAL0
                btfss   ESTADO,2
                goto    paso0        
                
        paso1   btfss   PUEA,1
                goto    paso1
        paso1r  btfsc   PUEA,1
                goto    paso1r
                movfw   PUEB
                xorlw   PAL1
                btfss   ESTADO,2
                goto    paso0        
                
        paso2   btfss   PUEA,1
                goto    paso2
        paso2r  btfsc   PUEA,1
                goto    paso2r
                movfw   PUEB
                xorlw   PAL2
                btfss   ESTADO,2
                goto    paso0
                
        paso3   btfss   PUEA,1
                goto    paso3
        paso3r  btfsc   PUEA,1
                goto    paso3r
                movfw   PUEB
                xorlw   PAL2
                btfsc   ESTADO,2
                goto    unlock
                goto    paso0
                
        unlock  bsf     PUEA,0
                call    cincos
                goto    paso0
        
        ;Subrutina de Delay(5s)        
        ;Para contar cinco segundos, el método más sencillo es desbordar el TIMER0 varias veces
        ;Con un predivisor de 256 y un oscilador de 4 MHz, el desbordamiento ocurre en ~1/16 s
        ;Esto se obtiene de la fórmula TDesborde = TOsc * 4 * (TMR0 - 256) * Predivisor
        ;Para cinco segundos, es necesario desbordar el TIMER0 ~76 veces
        
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
