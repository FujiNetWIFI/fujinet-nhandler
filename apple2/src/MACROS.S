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

.MACRO DISPLAY_TRACE str_addr
.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ @no_trace
                LDA #POUND
                JSR COUT
                LDA CURLIN+1
                LDX CURLIN
                JSR LINPRT
                LDA #SPACE
                JSR COUT
                PRINT_STR str_addr 
@no_trace:
.ENDIF
.ENDMACRO

.MACRO DISPLAY_TRACE_UNIT 
.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ @no_trace
                SAVE_REGS
                JSR PRTX
                JSR CROUT
                RESTORE_REGS
@no_trace:
.ENDIF
.ENDMACRO


.MACRO DISPLAY_EXT2_TRACE str_addr
.IF .NOT STRIP_TRACE
.IF EXT2_TRACE
                SAVE_REGS
                TXA
                PHA
                LDA TRACE_FLAG
                BEQ @no_trace
                
                PRINT_STR str_addr
                PLA
                PHA
                TAX
                JSR PRTX
                JSR CROUT
@no_trace:       
                PLA         
                RESTORE_REGS
.ENDIF
.ENDIF
.ENDMACRO

.MACRO DISPLAY_EXT2_TRACE_NO_UNIT str_addr
.IF .NOT STRIP_TRACE
.IF EXT2_TRACE
                SAVE_REGS

                LDA TRACE_FLAG
                BEQ @no_trace
                
                PRINT_STR str_addr
@no_trace:       
                RESTORE_REGS
.ENDIF
.ENDIF
.ENDMACRO

.MACRO DISPLAY_FN_TRACE str_addr
.IF .NOT STRIP_TRACE
                SAVE_REGS
                TXA
                PHA
                LDA TRACE_FLAG
                BEQ @no_trace

                PRINT_STR str_addr
                PLA
                PHA
                TAX
                JSR PRTX

@no_trace:     
                PLA           
                RESTORE_REGS
.ENDIF
.ENDMACRO

.ENDIF