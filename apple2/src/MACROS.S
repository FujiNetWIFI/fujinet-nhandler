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

.MACRO PRINT_STR str_addr1
        SAVE_REGS
        LDA str_addr1
        LDY str_addr1+1
        JSR STROUT
        RESTORE_REGS
.ENDMACRO

.MACRO PRINT_OUT str_addr2
        SAVE_REGS
        LDA #<str_addr2
        LDY #>str_addr2
        JSR STROUT
        RESTORE_REGS
.ENDMACRO

.MACRO DISPLAY_TRACE str_addr3
.IF .NOT STRIP_TRACE
        LDA TRACE_FLAG
        BEQ @no_trace1
        LDA #POUND
        JSR COUT
        LDA CURLIN+1
        LDX CURLIN
        JSR LINPRT
        LDA #SPACE
        JSR COUT
        PRINT_STR str_addr3 
@no_trace1:
.ENDIF
.ENDMACRO

.MACRO DISPLAY_TRACE_UNIT 
.IF .NOT STRIP_TRACE
        LDA TRACE_FLAG
        BEQ @no_trace2
        SAVE_REGS
        JSR PRTX
        JSR CROUT
        RESTORE_REGS
@no_trace2:
.ENDIF
.ENDMACRO


.MACRO DISPLAY_EXT2_TRACE str_addr4
.IF .NOT STRIP_TRACE
.IF EXT2_TRACE
        SAVE_REGS
        TXA
        PHA
        LDA TRACE_FLAG
        BEQ @no_trace3
        
        PRINT_STR str_addr4
        PLA
        PHA
        TAX
        JSR PRTX
        JSR CROUT
@no_trace3:       
        PLA         
        RESTORE_REGS
.ENDIF
.ENDIF
.ENDMACRO

.MACRO DISPLAY_EXT2_TRACE_NO_UNIT str_addr5
.IF .NOT STRIP_TRACE
.IF EXT2_TRACE
        SAVE_REGS

        LDA TRACE_FLAG
        BEQ @no_trace4
        
        PRINT_STR str_addr5
@no_trace4:       
        RESTORE_REGS
.ENDIF
.ENDIF
.ENDMACRO

.MACRO DISPLAY_FN_TRACE str_addr6
.IF .NOT STRIP_TRACE
        SAVE_REGS
        TXA
        PHA
        LDA TRACE_FLAG
        BEQ @no_trace5

        PRINT_STR str_addr6
        PLA
        PHA
        TAX
        JSR PRTX

@no_trace5:     
        PLA           
        RESTORE_REGS
.ENDIF
.ENDMACRO

.ENDIF