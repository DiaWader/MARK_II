;GPIO block
.CONS PORTA    0x000100
.CONS DDRA     0x000101
.CONS PORTB    0x000102
.CONS DDRB     0x000103

;SYSTIM
.CONS SYSTCR   0x000104
.CONS SYSTVR   0x000105

;INT
.CONS INTMR    0x000108

;UART0
.CONS UDR0     0x00010A
.CONS UCR0     0x00010B

;UART1
.CONS UDR1     0x00010C
.CONS UCR1     0x00010D

;UART2
.CONS UDR2     0x00010E
.CONS UCR2     0x00010F

;TIM0
.CONS TCCR0    0x000110
.CONS OCRA0    0x000111
.CONS OCRB0    0x000112
.CONS TCNR0    0x000113

;TIM1
.CONS TCCR1    0x000114
.CONS OCRA1    0x000115
.CONS OCRB1    0x000116
.CONS TCNR1    0x000117

;TIM2
.CONS TCCR2    0x000118
.CONS OCRA2    0x000119
.CONS OCRB2    0x00011A
.CONS TCNR2    0x00011B

;TIM3
.CONS TCCR3    0x00011C
.CONS OCRA3    0x00011D
.CONS OCRB3    0x00011E
.CONS TCNR3    0x00011F

;RAM
.CONS RAMSTART 0x000400
.CONS RAMEND   0x0007FF

;KEYBOARD
.CONS KEYBOARD 0x000109


;start section (initialize system)
.ORG 0x00000000
start:
    OR R0 R0 R0
    MVIL SP 0x07FF   ;place a top of RAM into SP
    BZ R0 main

.ORG 0x00000010 ;SYSTIM ISR
    RETI
.ORG 0x00000012
    RETI
.ORG 0x00000014
    RETI
.ORG 0x00000016
    RETI
.ORG 0x00000018
    RETI
.ORG 0x0000001A
    RETI
.ORG 0x0000001C
    RETI
.ORG 0x0000001E
    RETI
.ORG 0x00000020 ;UART0 tx ISR
    RETI
.ORG 0x00000022 ;UART0 rx ISR
    RETI
.ORG 0x00000024 ;UART1 tx ISR
    RETI
.ORG 0x00000026 ;UART1 rx ISR
    RETI
.ORG 0x00000028 ;UART2 tx ISR
    RETI
.ORG 0x0000002A ;UART2 rx ISR
    RETI
.ORG 0x0000002C ;TIM0 ISR
    RETI
.ORG 0x0000002E ;TIM1 ISR
    RETI
.ORG 0x00000030 ;TIM2 ISR
    RETI
.ORG 0x00000032 ;TIM3 ISR
    RETI
.ORG 0x00000034 ;KEYBOARD ISR
    RETI
.ORG 0x00000036
    RETI
.ORG 0x00000038
    RETI
.ORG 0x0000003A
    RETI
.ORG 0x0000003C
    RETI
.ORG 0x0000003E
    RETI
.ORG 0x00000040
    RETI
.ORG 0x00000042
    RETI
.ORG 0x00000044
    RETI
.ORG 0x00000046
    RETI
.ORG 0x00000048
    RETI
.ORG 0x0000004A
    RETI
.ORG 0x0000004C
    RETI
.ORG 0x0000004E
    RETI
    
;main programm
.ORG 0x00000050
main:
    ;config uart0 to 1200 baud 8n1
    MVIL R1 0x02ED
    ST R1 UCR0
    MOV R0 R4
    MVIL R1 0x00FF
    ST R1 DDRA
loop:
    MVIL R1 0x0048
    ST R1 UDR0
    CALL delay
    CALL set_led

    MVIL R1 0x0065
    ST R1 UDR0
    CALL delay
    CALL set_led

    MVIL R1 0x006c
    ST R1 UDR0
    CALL delay
    CALL set_led

    MVIL R1 0x006c
    ST R1 UDR0
    CALL delay
    CALL set_led

    MVIL R1 0x006f
    ST R1 UDR0
    CALL delay
    CALL set_led

    MVIL R1 0x0021
    ST R1 UDR0
    CALL delay
    CALL set_led
    
    BZ R0 loop

;simple delay function
delay:
    MVIL R2 0xFFFF
    MVIH R2 0x001F
delay_loop:
    DEC R2 R2
    CMP EQ R2 R0 R3
    BZ R3 delay_loop
    RET

;set led
set_led:
    MVIL R3 0x00FF
    XOR R4 R3 R4
    ST R4 PORTA
    RET
