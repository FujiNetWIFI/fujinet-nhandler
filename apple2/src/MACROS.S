.IF .NOT .DEFINED(MACROS)

MACROS=1

.MACRO SAVE_REGS
        STA MACRO_A
        PHP
        PHA
        TXA
        PHA
        TYA
        PHA
        LDA MACRO_A
.ENDMACRO

.MACRO RESTORE_REGS
        PLA
        TAY
        PLA
        TAX
        PLA
        PLP
.ENDMACRO

.MACRO PRINT_STR STR
        SAVE_REGS
        LDA STR
        LDY STR+1
        JSR STROUT
        RESTORE_REGS
.ENDMACRO

.MACRO PRINT_OUT STR
        SAVE_REGS
        LDA #<STR
        LDY #>STR
        JSR STROUT
        RESTORE_REGS
.ENDMACRO


.ENDIF