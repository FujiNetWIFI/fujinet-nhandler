.IF .NOT .DEFINED(PRINT_X)

PRINT_X:
        JSR PRTX
        LDA #' ' + $80
        JSR COUT
        RTS


STR_X:          .ASCIIZ " X:"
STR_Y:          .ASCIIZ " Y:"
STR_A:          .ASCIIZ " A:"
STR_P:          .ASCIIZ " P:"

STR_STACK:      .ASCIIZ "STACK:T"

MACRO_A:        .BYTE 1
TEMP_A:         .BYTE 1
TEMP_X:         .BYTE 1
TEMP_Y:         .BYTE 1

TEMP_P:         .BYTE 1
TEMP_AND:       .BYTE 1
TEMP_CHAR:      .BYTE 1


PRINT_FLAG:
        PHA

        STX TEMP_CHAR
        STY TEMP_AND
        
        AND #$80
        BNE FLAG_SET
        LDA TEMP_CHAR
        CLC
        BCC PRINT_FLAG_DONE
FLAG_SET:
     
PRINT_FLAG_DONE:
        JSR COUT
        PLA
        RTS

PRINT_FLAGS:
        LDA #<STR_P
        LDY #>STR_P
        JSR STROUT
        LDA TEMP_P      ; Load accumulator with contents of $0018

        TAX
        JSR PRTX
        LDA #' ' + $80
        JSR COUT

        LDA #$80
        LDX #'N'
        LSR
        JSR PRINT_FLAG

        LDX #'V'
        LSR
        JSR PRINT_FLAG

        LDX #'.'
        LSR
        JSR PRINT_FLAG

        LDX #'B'
        LSR
        JSR PRINT_FLAG

        LDX #'D'
        LSR
        JSR PRINT_FLAG

        LDX #'I'
        LSR
        JSR PRINT_FLAG

        LDX #'Z'
        LSR
        JSR PRINT_FLAG

        LDX #'C'
        LSR
        JSR PRINT_FLAG

        RTS

PRINT_REGS:
        PHP
        
        STA TEMP_A

        PLA             ; GET THE PROCESSOR FLAG
        PHA

        LDA #$80
        STA TEMP_P
        
        STX TEMP_X
        STY TEMP_Y

        SAVE_REGS
        LDA #<STR_A
        LDY #>STR_A
        JSR STROUT
        LDX TEMP_A
        JSR PRTX
        
        LDA #<STR_X
        LDY #>STR_X
        JSR STROUT
        LDX TEMP_X
        JSR PRTX
        
        LDA #<STR_Y
        LDY #>STR_Y
        JSR STROUT
        LDX TEMP_Y
        JSR PRTX
        
;        JSR PRINT_FLAGS

        JSR CROUT
        RESTORE_REGS
        
        PLP
        
        RTS


STACK_ITEMS = 10
PRINT_STACK:
        SAVE_REGS

        LDA #<STR_STACK
        LDY #>STR_STACK
        JSR STROUT

        TSX
        INX             ; NOW AT TOP OF STACK WITH DATA

        INX             ; IGNORE THE STUFF WE PUT ON THE STACK ; PHP
        INX             ; Y
        INX             ; X
        INX             ; A
 
        LDY #STACK_ITEMS

NEXT_STACK_ITEM:
        TXA
        PHA

        LDA $0100,X     ; 
        TAX

        SAVE_REGS
        JSR PRINT_X
        RESTORE_REGS

        PLA
        TAX

        INX
        DEY
        BNE NEXT_STACK_ITEM

        JSR CROUT
        RESTORE_REGS

        RTS

WAIT_STR: .ASCIIZ "WAITING..."

GETCHR:
        LDA #<WAIT_STR
        LDY #>WAIT_STR
        JSR STROUT

CHK_KEY:
        LDA KYBD
        CMP #$80        ; KEYPRESS?
        BCC CHK_KEY     ; NO, TRY AGAIN
        STA STROBE      ; CLEAR KYBD STROBE
        ;A = CHARACTER
        RTS
        
.ENDIF