;program loader from uart

; Registers description
;
; R1 - universal register using in main program
; R2 - universal register using in interrupt
;
; R6 - temp variable
; R7 - bytenum variable
; R8 - wordnum variable
; R9 - count variable
; R10 - base variable
; R11 - mode variable


.CONS INTMR 0x000108
.CONS UDR0  0x00010A
.CONS UCR0  0x00010B

.CONS MODE_BASE  0x01
.CONS MODE_COUNT 0x02
.CONS MODE_DATA  0x03
.CONS MODE_DONE  0x04

;---------------------------------------
; init system
.ORG 0x00000000
start:
    ;init stack
    MVIL SP 0x07FF

    ;init variables
    MOV R0 R6
    MOV R0 R7
    MOV R0 R8
    MOV R0 R9
    MOV R0 R10
    .MVI R11 MODE_BASE

    ;config uart0 to 1200 baud 8n1
    MVIL R1 0x02ED
    ST R1 UCR0

    ;enable interrupt
    MVIL R1 0x0200
    ST R1 INTMR

    ;goto main program
    BZ R0 main

main:
    ; if mode != MODE_DONE then goto main else goto base
    .MVI R1 MODE_DONE
    CMP EQ R1 R11 R1
    BZ R1 main
    BZI R0 R10 ;FIXME: delete following lines to "unhalt" after loading is done

.ORG 0x00000022 ;UART0 RX ISR

    ;decide what code branch to execute - this is something like FSM
    .MVI R2 MODE_BASE
    CMP EQ R2 R11 R2
    BNZ R2 mode_base_code

    .MVI R2 MODE_COUNT
    CMP EQ R2 R11 R2
    BNZ R2 mode_count_code

    .MVI R2 MODE_DATA
    CMP EQ R2 R11 R2
    BNZ R2 mode_data_code

    ;something is wrong if we are there :(
    RETI

;base branch
mode_base_code:

    ;tmp << 8
    ROL 8 R6 R6

    ;tmp |= udr0
    LD UDR0 R2
    OR R2 R6 R6

    ;bytenum++
    INC R7 R7

    ;if bytenum == 3 then goto mode_base_code_wordcomplete else RETI
    .MVI R2 0x03
    CMP EQ R2 R7 R2
    BNZ R2 mode_base_code_wordcomplete
    RETI

mode_base_code_wordcomplete:

    MOV R6 R10 ;base = tmp
    MOV R0 R7 ;bytenum = 0
    MOV R0 R6 ;tmp = 0
    .MVI R11 MODE_COUNT ;mode = MODE_COUNT
    RETI

;count branch
mode_count_code:

    ;tmp << 8
    ROL 8 R6 R6

    ;tmp |= udr0
    LD UDR0 R2
    OR R2 R6 R6

    ;bytenum++
    INC R7 R7

    ;if bytenum == 3 then goto mode_count_code_wordcomplete else RETI
    .MVI R2 0x03
    CMP EQ R2 R7 R2
    BNZ R2 mode_count_code_wordcomplete
    RETI

mode_count_code_wordcomplete:
    MOV R6 R9 ;count = tmp
    MOV R0 R7 ;bytenum = 0
    MOV R0 R6 ;tmp = 0
    .MVI R11 MODE_DATA ;mode = MODE_DATA
    RETI


;data branch
mode_data_code:

    ;tmp << 8
    ROL 8 R6 R6

    ;tmp |= udr0
    LD UDR0 R2
    OR R2 R6 R6

    ;bytenum++
    INC R7 R7

    ;if bytenum == 4 then goto mode_data_code_wordcomplete else RETI
    .MVI R2 0x04
    CMP EQ R2 R7 R2
    BNZ R2 mode_data_code_wordcomplete
    RETI

mode_data_code_wordcomplete:
    MOV R0 R7 ;bytenum = 0

    ;store address in R2
    ADD R8 R10 R2
    ;store word (from tmp) in calculated address
    STI R6 R2

    ;wordnum++
    INC R8 R8

    ;if wordnum == count then goto mode_data_code_complete else RETI
    CMP EQ R8 R9 R2
    BNZ R2 mode_data_code_complete
    RETI

mode_data_code_complete:
    ;mode == MODE_DONE
    .MVI R11 MODE_DONE
    RETI