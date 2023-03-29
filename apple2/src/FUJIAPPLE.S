;*****************************************************
; FUJIAPPLE
; Ampersand extension for Fujinet commands
; By Norman Davie
;
; VERSION: 1.06 - updated to use ca65
;
; NOTES:
;   If you set USE_TRACE a large about of debug info will be included
; You can turn on and off the debug messages using &NTRACE and &NNOTRACE
;   If you want to test your code without a smartport card (for emulators)  
; you can set USE_SP 
;
; With ca65 task
;{
;    "version": "2.0fnet.0",
;    "tasks": [
;        {
;            "label": "ca65: Compile and Link Current File",
;            "group": "build",
;            "type": "shell",
;            "command": " cl65 -v -t apple2 -C apple2-asm.cfg  \"${file}\"",
;            "problemMatcher": [
;                "$ca65",
;                "$ld65",
;                "$ld65-config",
;                "$ld65-unresolved"
;            ]
;        }
;    ]
;}

; If you don't set STRIP_TRACE=1, then &NTRACE and &NNOTRACE
; keywords are active and a bunch of strings are included
; in the code making it quite large.
; These keywords show information regarding the BASIC and
; FN_???? functions being called.
;
; EXT_TRACE and EXT2_TRACE includes calls into the SMARTPORT routines

STRIP_TRACE= 1  ; Eliminate all tracing code and strings
TRACE_ON   = 0  ; &NTRACE is on at the very start
EXT_TRACE  = 0  ; Extended Trace, 1=display SMARTPORT internal debug messages 
EXT2_TRACE = 0  ; Extended Trace 2, display SP_STATUS and SP_CONTROL
EXT3_TRACE = 0  ; Extended Trace 3, display commands in the dispatch call
RELOCATE   = 1  ; 1=relocate himem and put our code there
PRODOS     = 1  ; 0=add dos 3.3 header
APPLEII    = 1  ; always set to one, EQUs will be for apple zero page
USE_SP     = 1  ; 1=USE ACTUAL SMARTPORT 0=EMULATE SMARTPORT FUNCTIONS
WIPE_AFTER = 1  ; WIPE ORIGINAL LOCATION AFTER RELOCATING -- FORCES A CRASH

START      = $4000

.IF PRODOS

        .ORG START

; NO HEADER FOR PRODOS

.ELSE

; WE SUBRACT 4 TO ALLOW ROOM FOR THE ADDRESS AND LENGTH FIELDS AT THE START OF THE FILE

        .ORG START - 4 

; HEADER FOR BINARY FILES ON DOS 3.3

        .WORD NINIT                             ; Starting address
        .WORD (ENDOFFILE - STARTOFFILE)         ; Length

.ENDIF
; VARIOUS SYSTEM ROUTINES AND LOCATIONS 


        .include "APPLEEQU.S"
        .include "ZEROPAGE.S"
        .include "MACROS.S"

;*********************************************************                           

STARTOFFILE:

NINIT:

.IF .NOT STRIP_TRACE
.IF TRACE_ON
                JSR NTRACE
.ELSE
                JSR NNOTRACE
.ENDIF
.ENDIF
                JSR FILL_CMD_LIST

                JSR GET_SMARTPORT_DISPATCH_ADDRESS      ; FIND THE ADDRESS

.IF .NOT STRIP_TRACE
.IF EXT_TRACE
                SAVE_REGS
                PRINT_STR DISPATCHER_ADDRESS_STR_ADDR
                JSR PRTAX
                JSR CROUT
                RESTORE_REGS
.ENDIF
.ENDIF
                LDA DISPATCHER_ADDR_HI
                CMP #$FF                                ; WAS THE CARD FOUND?
                BNE FOUND_SMARTPORT

                LDA #<SP_NOT_FOUND_STR                  ; "SMARTPORT NOT FOUND!"
                LDY #>SP_NOT_FOUND_STR
                JSR STROUT

.IF EXT_TRACE
                LDA #<EXITING_STR
                LDY #>EXITING_STR
                JSR STROUT
.ENDIF

BYE:
                RTS


FOUND_SMARTPORT:

                ; FIND ALL THE NETWORK ADAPTERS
                ; 0 IS "NETWORK" OR "NETWORK_0"
                ; 1-3 IS "NETWORK_1" OR 2, OR 3...

                LDX #$00
NEXT_NETWORK_CACHE:
                STX BASIC_UNIT 
                JSR FN_FIND_NETWORK
                ; X gets destroyed so reload as "BASIC" unit
                ; y = real unit #
                LDX BASIC_UNIT
                TYA
                STA NETWORK_CACHE,X

                INX
                CPX #$04        ; move to the next "basic" unit
                BNE NEXT_NETWORK_CACHE

.IF .NOT STRIP_TRACE
.IF EXT2_TRACE
                JSR DISPLAY_NETS
.ENDIF
.ENDIF

                ; FIND THE FN_CLOCK SO WE DON'T NEED TO
                ; KEEP LOOKING FOR THE UNIT NUMBER

                LDA #FN_ERR_NO_DEVICE
                STA FN_CLOCK_CACHE

                LDA CLOCK_STR_ADDR+1
                LDY CLOCK_STR_ADDR
    
                JSR SP_FIND_DEVICE          ; LOOK FOR "NETWORK"
                CPX #SP_ERR
                BEQ @skip
                STX FN_CLOCK_CACHE
 @skip:               
; RELOCATE US TO WHERE IT'S SAFE

.IF .NOT STRIP_TRACE
.IF EXT_TRACE
                JSR CROUT               ; CARRIAGE RETURN
                LDA #<HIMEM_IS_STR          ; "OLD HIMEM:"
                LDY #>HIMEM_IS_STR
                JSR STROUT

                LDA HIMEM+1
                STA OLDHIMEM+1          ; KEEP TRACK OF HIMEM
		LDX HIMEM
                STX OLDHIMEM
		JSR PRTAX               ; PRINT ADDRESS
.ENDIF
.ENDIF

.IF RELOCATE
		JSR ADJUST_HIMEM        ; Move HIMEM so we can put our code at it. 
.ENDIF

.IF .NOT STRIP_TRACE
.IF EXT_TRACE
		LDA #<NEW_HIMEM_STR    ; "NEW HIMEM: "
		LDY #>NEW_HIMEM_STR
		JSR STROUT
.ENDIF
.ENDIF

		LDA HIMEM+1
		LDX HIMEM

.IF .NOT STRIP_TRACE
.IF EXT_TRACE
		JSR PRTAX               ; PRINT NEW HIMEM ADDRESS
                JSR CROUT
.ENDIF
.ENDIF

.IF RELOCATE
                JSR CLEAR_CMD_LIST      ; clear the data so we can relocate code/data together
                JSR RELOCATE_TO_HIMEM   ; copy the code and data, adjust all absolute addresses
.ENDIF    

relocate000:    JSR FILL_CMD_LIST       ; let's fix all the smartport instruction data now that
                                        ; everything has been relocated

.IF .NOT USE_SP
                JSR GET_SMARTPORT_DISPATCH_ADDRESS      ; address would have changed during relocation
.ENDIF

.IF RELOCATE

.IF .NOT STRIP_TRACE
.IF EXT_TRACE
                LDA #<RELOC_SIZE_STR        ; "CODE SIZE:"
                LDY #>RELOC_SIZE_STR
                JSR STROUT

                LDX #<(RELOCATE_DATA_END - RELOCATE_CODE_START)
                LDA #>(RELOCATE_DATA_END - RELOCATE_CODE_START)
                JSR PRTAX               ; PRINT SIZE
                JSR CROUT

.ENDIF
.ENDIF


.ENDIF

; SAVE PREVIOUS VECTOR INFO

SAVEVECT:

                LDA AMPVECT
relocate001:    STA PREVECT
                LDA AMPVECT+1
relocate002:    STA PREVECT+1
                LDA AMPVECT+2
relocate003:    STA PREVECT+2

; UPDATE THE AMPERSAND VECTOR TO OUR ROUTINE

                LDA #$4C                                ; JMP
                STA AMPVECT
relocate004:    LDA RELOC_NSTART                        ; SET THE AMPERSAND VECTOR
                STA AMPVECT+1
relocate005:    LDA RELOC_NSTART+1
                STA AMPVECT+2
        
; ANNOUNCE OUR SUCCESS

                LDA #<EXTADDED_STR                      ; "FUJINET EXTENSION ADDED"
                LDY #>EXTADDED_STR          
                JSR STROUT

.IF .NOT USE_SP
                PRINT_STR FAKE_SMARTPORT_STR_ADDR
                JSR GET_SMARTPORT_DISPATCH_ADDRESS      ; FIND THE ADDRESS AGAIN, SINCE IT WAS RELOCATED
.ENDIF


                ; RELOCATION CODE WILL CLOBBER THE
                ; STRING, THINKING IT'S CODE,
                ; SO PUT IT THERE AFTER IT'S
                ; BEEN MOVED

                LDX #$00
CPY_SIG:
                LDA SIGNATURE_STR,X
relocate006:    STA SIGNATURE,X
                INX
                CPX #SIG_SIZE
                BNE CPY_SIG
                LDA #SIG_SIZE
relocate007:    STA SIGNATURE,X


.IF RELOCATE
.IF WIPE_AFTER
                LDA #<RELOCATE_CODE_START
                STA ZP1_LO
                LDY #>RELOCATE_CODE_START
                STY ZP1_HI
                
                LDX #<(RELOCATE_DATA_END - RELOCATE_CODE_START)
                LDY #>(RELOCATE_DATA_END - RELOCATE_CODE_START)
WIPE_IT:
WIPE_IT_GOOD:
                TYA
                PHA
                LDY #$00
                LDA #$00
                STA (ZP1),Y
                LDA ZP1_LO
                CLC
                ADC #$01
                STA ZP1_LO
                LDA ZP1_HI
                ADC #$00
                STA ZP1_HI
                PLA
                TAY
                DEX
                BNE WIPE_IT
                DEY
                BNE WIPE_IT_GOOD

.ENDIF
.ENDIF

.IF PRODOS
                RTS
.ELSE
                JMP DOSWARM             ; WARM START DOS-NEEDED FOR BRUN
.ENDIF

RELOCATE_CODE_START:

;REM *******************************************
;REM DETERMINE IF FUJI EXTENSIONS ARE INSTALLED
;REM *******************************************
;10000 GOSUB 10030: IF R=1 THEN PRINT "EXTENSIONS ALREADY INSTALLED.": RETURN
;10010 PRINT "LOADING EXTENSIONS..."
;10020 PRINT  CHR$ (4);"BRUN /FUJI.APPLE/FUJIAPPLE":RETURN
;
;10030 X = PEEK(1014)+PEEK(1015)*256
;10040 X = X - 1
;10050 C = PEEK(X)
;10060 IF C = 0 OR C > 20 THEN 10140
;10070 X = X - C
;10080 A$=""
;10090 FOR Y = 1 TO C: A$=A$+CHR$(PEEK(X)):X=X+1:NEXT Y
;10100 B$ = "FUJIAMP"
;10130 IF A$=B$ THEN R=1: GOTO 10150
;10140 R=0
;10150 RETURN

;****************************************
SIGNATURE:
                .BYTE $EA,$EA,$EA,$EA,$EA,$EA,$EA
                .BYTE $EA

;****************************************
; NSTART - FUJINET EXTENSION START
;   THIS IS THE ENTRY POINT OF THE AMPERSAND ROUTINE
;   CHECK FOR OUR COMMANDS AND EXECUTE IF FOUND
;   IF IT DOESN'T MATCH OUR COMMANDS, THEN
;   GO TO THE PREVIOUS AMPERSAND ROUTINE
;****************************************

NSTART:
                LDX #$00
NEXTCMD:
                LDY #$00       ; INDEX INTO TXTPTR
                LDA COMMANDS,X ; COMMAND TEXT IN TABLE
                BEQ NOMORECMDS ; WE'VE EXAUSTED OUR CMD LIST
COMP:
                LDA COMMANDS,X
                CMP (TXTPTR),Y ; DOES COMMAND TEXT MATCH?
                BNE SKIPCMD    ; IT'S NOT A MATCH
                INY              ; MOVE TO NEXT CHARACTER
                INX
                LDA COMMANDS,X ; IS THE CHARACTER A NULL?
                BNE COMP       ; NOPE, COMPARE NEXT CHARACTER
                BEQ FOUNDCMD   ; YES, WE'VE FOUND OUR COMMAND
SKIPCMD:
                INX             ; MOVE TO THE NEXT CHARACTER
                LDA COMMANDS,X  ; KEEP READING UNTIL NULL
                BNE SKIPCMD
                INX             ; IGNORE THE NULL
                INX             ; IGNORE THE ADDRESS
                INX

                CLC
                BCC NEXTCMD     ; CHECK NEXT CMD
FOUNDCMD:
                TXA
                PHA
RMCMD:
                JSR CHRGET      ; REMOVE CHAR FROM BASIC
                DEY
                BNE RMCMD

                PLA
                TAX

; PUSHADDR ON STACK AND "RETURN" TO OUR ROUTINE

                INX
                LDA COMMANDS+1,X
                PHA
                LDA COMMANDS,X
                PHA             ; ADDRESS OF OUR ROUTINE IS ON STACK

                RTS             ; "RETURN" (JMP) TO ADDRESS ON STACK

; IF WE'RE HERE, IT'S NOT ONE OF OUR COMMANDS
; JUMP TO THE PREVIOUS VECTOR AND LET IT PROCESS IT

NOMORECMDS:

.IF .NOT STRIP_TRACE
.IF EXT_TRACE

                PRINT_STR NOT_FOUND_STR_ADDR  ; "COMMAND NOT FOUND"
                JSR CROUT

.ENDIF
.ENDIF

                JMP   PREVECT    ; WE DIDN'T FIND OUR COMAND SO GO TO OLD VECTOR

.IF .NOT STRIP_TRACE
DISPLAY_NETS:
                SAVE_REGS
                PRINT_STR NETWORK_STR_ADDR
                LDA #COLON 
                JSR COUT

                LDY #$00

NEXT_NET:
                LDA NETWORK_CACHE,Y
                TAX
                JSR PRTX
                INY
                CPY #$04
                BNE NEXT_NET
                JSR CROUT
                RESTORE_REGS
                RTS

DISPLAY_OPENS:
                SAVE_REGS
                PRINT_STR NETWORK_STR_ADDR
                LDA #COLON 
                JSR COUT

                LDY #$00

NEXT_OPEN:
                LDA OPEN_LIST,Y
                TAX
                JSR PRTX
                INY
                CPY #$04
                BNE NEXT_OPEN
                JSR CROUT
                RESTORE_REGS
                RTS

DISPLAY_NERRS:
                SAVE_REGS
                PRINT_STR SP_ERROR_STR_ADDR
                LDA #COLON 
                JSR COUT

                LDY #$00

NEXT_NERR:
                LDA NERR,Y
                TAX
                JSR PRTX
                INY
                CPY #$04
                BNE NEXT_NERR
                JSR CROUT
                RESTORE_REGS
                RTS
.ENDIF

;*********************************
; GETSTR - GETS A STATIC STRING ("BLAH")
; INPUT:
;   TXTPTR IS AT THE START OF THE STRING IN BASIC
; RETURNS:
;   STRING IS COPIED INTO STRBUF AND TERMINATED WITH A NULL
;   STRING LENGTH IS STORED IN STRLEN
; NOTE:
;    CHRGET CONSUMES SPACES SILENTLY, WHICH IS WHY
;    WE DON'T USE IT TO COLLECT THE STRING
;***********************************

GETSTR:                         ; GET STATIC STRING
                LDY #01
CONSUME:
                LDA (TXTPTR),Y  ; GET CHARACTER FROM BASIC
                CMP #QUOTE      ; WE NEED TO STOP ON THE ENDING QUOTE
                BEQ NULLSTR1    ; WE'RE DONE

                STA STRBUF-1,Y  ; SAVE THE CHARACTER
                INY
                CLC
                BCC CONSUME     ; GET THE NEXT CHARACTER
NULLSTR1:
                LDA #00
                STA STRBUF-1,Y  ; TERMINATE THE STRING WITH A NULL
                DEY
                STY STRLEN      ; SAVE THE LENGTH OF THE STRING
                JSR CHRGET
GOBBLE:
                JSR CHRGET      ; GET THE CHARACTER FROM BASIC
                CMP #QUOTE      ; HAVE WE FOUND THE ENDING QUOTE?
                BEQ COMPLETED   ; WE'RE DONE
                INY
                CLC
                BCC GOBBLE

COMPLETED:
                JSR CHRGET     
                RTS

;*******************************************
; GETSTRVAR - GET STRING VARIABLE
; RETURNS:
;   STRING LENGTH IN DSCTMP
;   STRING ADDR LO IN DSCTMP+1
;   STRING ADDR HI IN DSCTMP+2
;*********************************
GETSTRVAR:
                JSR PTRGET     ; GET STRING DESCRIPTOR
                LDY #0
                LDA (VARPTR),Y ; STRING LENGTH
                STA DSCTMP
                INY
                LDA (VARPTR),Y ; ADDR LO
                STA DSCTMP+1
                INY
                LDA (VARPTR),Y ; ADDR HI
                STA DSCTMP+2
                RTS
;*********************************
;*******************************
; BYTESAV - CONVERT BYTE TO FLOAT
;           AND STORE IN VARIABLE
; INPUT:
;   Y - BYTE TO STORE
;***
; WOR.RESAV - CONVERT WORD TO FLOAT AND STORE IN VARIABLE
; INPUT:
;   A - WORD HI
;   Y - WORD LO
;***
; RETURN
;   BOTH ROUTINES RETURN:
;   FLOAT STORED INTO VARIABLE
;**********************************
BYTESAV:
                LDA #0
WORDSAV:
                JSR GIVAYF     ; CONVERT TO FLOATING POINT
                JSR PTRGET     ; FIND ADDRESS OF THE VARIABLE
                TAX
                JSR MOVMF      ; STORE VALUE INTO VARIABLE
                RTS

.IF .NOT STRIP_TRACE
;*************************************
; DISPLAY INTERNAL STATE
;*************************************
DISPLAY_INTERNAL_STATE:

                SAVE_REGS
                LDX BASIC_UNIT
                JSR PRINT_X
                LDX MODE
                JSR PRINT_X
                LDX TRANSLATION
                JSR PRINT_X
                JSR CROUT
                LDA #'"'
                JSR COUT
                PRINT_STR URL_ADDR
                LDA #'"'
                JSR COUT
                JSR CROUT

                LDX URL_LEN
                JSR PRINT_X

                LDX COMMAND
                JSR PRINT_X
                JSR CROUT

                LDX NETWORK_CACHE
                JSR PRINT_X
                LDX NETWORK_CACHE+1
                JSR PRINT_X
                LDX NETWORK_CACHE+2
                JSR PRINT_X
                LDX NETWORK_CACHE+3
                JSR PRINT_X
                JSR CROUT

                RESTORE_REGS
                RTS
.ENDIF

;*************************************
;*************************************
;*************************************
;*************************************

;*************************************
; IGNORE_TO_NEXT_BASIC_STATEMENT
;
; Skip all crap until we either find a
; colon, or we're at the end of the 
; BASIC line
;*************************************
IGNORE_TO_NEXT_BASIC_STATEMENT:
                JSR CHRGOT              
                BEQ RETURN_TO_BASIC     ; 0 = END OF LINE
                CMP #':'
                BEQ RETURN_TO_BASIC

                JSR CHRGET
                CLC
                BCC IGNORE_TO_NEXT_BASIC_STATEMENT

RETURN_TO_BASIC:
                RTS

                .include "TOKENS.S"
                .include "SMARTPORTCMDS.S"
                .include "FAKESMARTPORT.S"
                .include "FUJINET.S"

RELOCATE_CODE_END:

;***********
;***********
;***********
;* DATA SECTION
;***********
;***********
;***********


;**************************************

relocate008:
RELOC_NSTART:   .WORD NSTART

COMMANDS:
                .ASCIIZ "NOPEN"                 ; NOPEN
relocate009:    .WORD   NOPEN-1

                .BYTE   'N', TOK_READ, 00       ; NREAD
relocate010:    .WORD   NREAD-1

                .ASCIIZ "NWRITE"                ; NWRITE
relocate011:    .WORD   NWRITE-1

                .ASCIIZ "NCTRL"                 ; NCTRL
relocate012:    .WORD   NCTRL-1

                .BYTE   "NST", TOK_AT, "US", 0  ; NSTATUS
relocate013:    .WORD   NSTATUS-1

                .ASCIIZ "NCLOSE"                ; NCLOSE
relocate014:    .WORD   NCLOSE-1

                .BYTE   "N", TOK_END, 0         ; NEND
relocate015:    .WORD   NEND-1   

                .BYTE   "N", TOK_LIST, 0        ; NLIST
relocate016:    .WORD   NLIST-1

                .ASCIIZ "NACCEPT"               ; NACCEPT
relocate017:    .WORD   NACCEPT-1

                .BYTE   "N", TOK_INPUT, 0       ; NINPUT
relocate018:    .WORD   NINPUT-1

                .BYTE   "N", TOK_PRINT, 0       ; NPRINT
relocate019:    .WORD   NPRINT-1

                .ASCIIZ "NTIME"                 ; NTIME
relocate023:    .WORD   NTIME-1

                .ASCIIZ "NSETEOL"               ; NSETEOL
relocate024:    .WORD   NSETEOL-1

.IF .NOT STRIP_TRACE
                .BYTE   "N", TOK_TRACE, 0       ; NTRACE
trace053:       .WORD   NTRACE-1

                .BYTE   "N",TOK_NOTRACE, 0      ; NNOTRACE
trace054:       .WORD   NNOTRACE-1
.ENDIF

;*******************************************
;* END OF TABLE
;*******************************************
                .BYTE   00      ; END OF TABLE

.IF .NOT STRIP_TRACE            
TRACE_FLAG:     .BYTE   $01
.ENDIF
RELOC_SIZE:     .BYTE   $0D

PREVECT:        .RES    3       ; JUMP TO CONTENTS OF THE PREVIOUS AMPERSAND VECTOR
OLDHIMEM:       .RES    2       ; VALUE OF ORIGINAL HIMEM



;***************************************
BASIC_UNIT:     .BYTE   0       ; BASIC UNIT 0-4 NOT FUJINET UNIT
MODE:           .BYTE   4       ; 4=READ ONLY, 6=READ DIRECTORY, 8= WRITE ONLY, 12=READ/WRITE, 13= HTTP POST
TRANSLATION:    .BYTE   0       ; 0 = NO TRANSLATION, 1=CR to ATASCII EOL, 2=LF to ATASCII EOL, 3=CR/LF to ATASCII EOL
URL_LEN:        .BYTE   45
URL:            .RES    255 

relocate020:
URL_ADDR:       .WORD   URL
COMMAND:        .BYTE   0       ; FUJINET COMMAND
BASIC_PAYLOAD:  .RES    255     ; PAYLOAD TO SEND
BW:             .WORD   0       ; BYTES WAITING
CONNECT:        .BYTE   0       ; 1=CONNECTED
BUFLEN:         .BYTE   0
BUF:            .RES    255     ; GENERIC BUFFER FOR READ/WRITE

relocate021:
BUF_ADDR:       .WORD   BUF
STRADDR:        .WORD   0
STRLEN:         .BYTE   0
STRBUF:         .RES    255

relocate022:
STRBUF_ADDR:    .WORD   STRBUF
FN_CLOCK_CACHE: .BYTE   FN_ERR_NO_DEVICE
NETWORK_CACHE:  .BYTE   FN_ERR_NO_DEVICE, FN_ERR_NO_DEVICE, FN_ERR_NO_DEVICE, FN_ERR_NO_DEVICE
OPEN_LIST:      .BYTE   FN_ERR_NO_DEVICE, FN_ERR_NO_DEVICE, FN_ERR_NO_DEVICE, FN_ERR_NO_DEVICE      ; BASIC UNIT INDEX TO ACTUAL UNIT
NERR:           .BYTE   FN_ERR, FN_ERR, FN_ERR, FN_ERR                                  ; LAST ERROR

STR_DSC_LEN:    .BYTE   0
STR_DSC_LO:     .BYTE   0
STR_DSC_HI:     .BYTE   0

CENTURY:        .BYTE   0
YEAR:           .BYTE   0
MONTH:          .BYTE   0
DAY:            .BYTE   0
HOUR:           .BYTE   0
MINUTE:         .BYTE   0
SECOND:         .BYTE   0

EOL:            .BYTE   $0D


.include "STRINGS.S"
.include "REGS_DATA.S"
.include "FAKESMARTPORT_DATA.S"
.include "SMARTPORT_DATA.S"
.include "FUJINET_DATA.S"

RELOCATE_DATA_END:

; Anything here is only used during setup and doesn't need to be relocated.


.include "RELOCATION.S" 

RELOCATION_TABLE:
.include "FUJIAPPLE_RELOC.S"
.include "STR_RELOC.S"
.include "SMARTPORT_RELOC.S"
.include "FAKESMARTPORT_RELOC.S"
END_RELOCATION_TABLE:	
                .WORD 	0 ; end of table

; We should generate an error if there are too many entries (greater than 255)

ENDOFFILE:      NOP

