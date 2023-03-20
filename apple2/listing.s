ca65 V2.19 - Git c226e58
Main file   : ./src/FUJIAPPLE.S
Current file: ./src/FUJIAPPLE.S

000000r 1               ;*****************************************************
000000r 1               ; FUJIAPPLE
000000r 1               ; Ampersand extension for Fujinet commands
000000r 1               ; By Norman Davie
000000r 1               ;
000000r 1               ; VERSION: 1.06 - updated to use ca65
000000r 1               ;
000000r 1               ; NOTES:
000000r 1               ;   If you set USE_TRACE a large about of debug info will be included
000000r 1               ; You can turn on and off the debug messages using &NTRACE and &NNOTRACE
000000r 1               ;   If you want to test your code without a smartport card (for emulators)
000000r 1               ; you can set USE_SP
000000r 1               ;
000000r 1               ; With ca65 task
000000r 1               ;{
000000r 1               ;    "version": "2.0fnet.0",
000000r 1               ;    "tasks": [
000000r 1               ;        {
000000r 1               ;            "label": "ca65: Compile and Link Current File",
000000r 1               ;            "group": "build",
000000r 1               ;            "type": "shell",
000000r 1               ;            "command": " cl65 -v -t apple2 -C apple2-asm.cfg  \"${file}\"",
000000r 1               ;            "problemMatcher": [
000000r 1               ;                "$ca65",
000000r 1               ;                "$ld65",
000000r 1               ;                "$ld65-config",
000000r 1               ;                "$ld65-unresolved"
000000r 1               ;            ]
000000r 1               ;        }
000000r 1               ;    ]
000000r 1               ;}
000000r 1               
000000r 1               ; If you don't set STRIP_TRACE=1, then &NTRACE and &NNOTRACE
000000r 1               ; keywords are active and a bunch of strings are included
000000r 1               ; in the code making it quite large.
000000r 1               ; These keywords show information regarding the BASIC and
000000r 1               ; FN_???? functions being called.
000000r 1               ;
000000r 1               ; EXT_TRACE and EXT2_TRACE includes calls into the SMARTPORT routines
000000r 1               
000000r 1               STRIP_TRACE= 1  ; Eliminate all tracing code and strings
000000r 1               TRACE_ON   = 0  ; &NTRACE is on at the very start
000000r 1               EXT_TRACE  = 0  ; Extended Trace, 1=display SMARTPORT internal debug messages
000000r 1               EXT2_TRACE = 0  ; Extended Trace 2, display SP_STATUS and SP_CONTROL
000000r 1               RELOCATE   = 0  ; 1=relocate himem and put our code there
000000r 1               PRODOS     = 1  ; 0=add dos 3.3 header
000000r 1               APPLEII    = 1  ; always set to one, EQUs will be for apple zero page
000000r 1               USE_SP     = 1  ; 1=USE ACTUAL SMARTPORT 0=EMULATE SMARTPORT FUNCTIONS
000000r 1               WIPE_AFTER = 1  ; WIPE ORIGINAL LOCATION AFTER RELOCATING -- FORCES A CRASH
000000r 1               
000000r 1               START      = $2000
000000r 1               
000000r 1               .IF PRODOS
000000r 1               
000000r 1                       .ORG START
002000  1               
002000  1               ; NO HEADER FOR PRODOS
002000  1               
002000  1               .ELSE
002000  1               
002000  1               ; WE SUBRACT 4 TO ALLOW ROOM FOR THE ADDRESS AND LENGTH FIELDS AT THE START OF THE FILE
002000  1               
002000  1                       .ORG START - 4
002000  1               
002000  1               ; HEADER FOR BINARY FILES ON DOS 3.3
002000  1               
002000  1                       .WORD NINIT                             ; Starting address
002000  1                       .WORD (ENDOFFILE - STARTOFFILE)         ; Length
002000  1               
002000  1               .ENDIF
002000  1               ; VARIOUS SYSTEM ROUTINES AND LOCATIONS
002000  1               
002000  1               
002000  1                       .include "APPLEEQU.S"
002000  2               .IF .NOT .DEFINED(AMPVECT)
002000  2               
002000  2               SPACE                   =   $A0         ; SPACE CHARACTER FOR COUT
002000  2               COLON                   =   ':'+$80     ; COLON CHARACTER FOR COUT
002000  2               
002000  2               FRESPC                  =   $71         ; Applesoft pointer at the string storage area, used when a new string is created.
002000  2               AMPVECT                 =   $03F5       ; AMPERSAND VECTOR FOR APPLESOFT
002000  2               GETBYT                  =   $E6F8       ; EVAL BYTE -> X
002000  2               CHKCOM                  =   $DEBE       ; CHECK FOR COMMA
002000  2               FRMNUM                  =   $DD67       ; EVALUATE NUMERIC EXPRESSION
002000  2               GETADR                  =   $E752       ; CONVERT FAC TO INT (MAX 65535)
002000  2               PTRGET                  =   $DFE3       ; FIND NAMED VARIABLE (ADDRESS IN VARPTR)
002000  2               STRINI                  =   $E3D5       ; CREATE NEW STRING SPACE
002000  2               MOVSTR                  =   $E5E2       ; MOVE STRING INTO NEW SPACE A=LEN Y-HI SRC X=LO SRC, DESC in FRESPC
002000  2               MOVFM                   =   $EAF9       ; UNPACK (Y,A) TO FAC
002000  2               MOVMF                   =   $EB2B       ; PACK FAC TO (Y,A)
002000  2               GIVAYF                  =   $E2F2       ; CONVERT SIGNED WORD (A,Y) TO FLOAT
002000  2               SNGFLT                  =   $E301       ; CONVERT UNSIGNED BYTE Y TO FLOAT
002000  2               FLOAT                   =   $EB90       ; CONVERT SIGNED BYTE A TO FLOAT
002000  2               COUT                    =   $FDED       ; DISPLAY A AS CHAR ON SCREEN
002000  2               CROUT                   =   $FD8E       ; END OF LINE (CARRIAGE RETURN)
002000  2               STROUT                  =   $DB3A       ; PRINTS STRING POINT BY Y (HI) AND A(LO)
002000  2               CONINT                  =   $E6FB       ; CONVERT FAC TO INT (MAX 255)
002000  2               SYNERR                  =   $DEC9       ; ?SYNTAX ERROR
002000  2               PRTYX                   =   $F940       ; PRINT Y AND X AS HEX
002000  2               PRTAX                   =   $F941       ; PRINT A AND X AS HEX
002000  2               PRTX                    =   $F944       ; PRINT X AS HEX
002000  2               DOSWARM                 =   $03D0       ; CALL TO EXIT BRUN'D PROGRAM
002000  2               TXTPTR                  =   $B8         ; WHERE WE ARE IN THE BASIC FILE
002000  2               VARPTR                  =   $83         ; POINTER TO OUR VARIABLE
002000  2               DSCTMP                  =   $9D         ; TEMPORARY DESCRIPTION STORAGE
002000  2               CHRGET                  =   $B1         ; ADVANCE TXTPTR, GET CHAR INTO A
002000  2               CHRGOT                  =   $B7         ; CHARACTER ALREADY PROCESSED BY BASIC
002000  2               HIMEM                   =   $73         ; APPLESOFT HIMEM
002000  2               LOMEM                   =   $4A         ; INTEGER BASIC LOMEM
002000  2               KYBD                    =   $C000       ; KEYBOARD LOCATION
002000  2               STROBE                  =   $C010       ;
002000  2               
002000  2               TOK_READ                =       135     ; APPLESOFT TOKEN FOR READ
002000  2               TOK_AT                  =       197     ; APPLESOFT TOKEN FOR AT
002000  2               TOK_END                 =       128     ; APPLESOFT TOKEN FOR END
002000  2               QUOTE                   =       $22     ; ASCII QUOTE CHARACTER
002000  2               TOK_LIST                =       188     ; APPLESOFT TOKEN FOR LIST
002000  2               TOK_TRACE               =       155     ; APPLESOFT TOKEN FOR TRACE
002000  2               TOK_NOTRACE             =       156     ; APPLESOFT TOKEN FOR NOTRACE
002000  2               TOK_INPUT               =       132     ; APPLESOFT TOKEN FOR INPUT
002000  2               
002000  2               
002000  2               NEXT_WITHOUT_FOR        =   0
002000  2               SYNTAX_ERROR            =  16
002000  2               RETURN_WITHOUT_GOSUB    =  22
002000  2               OUT_OF_DATA             =  42
002000  2               ILLEGAL_QUANTITY_ERROR  =  53
002000  2               OVERFLOW                =  69
002000  2               OUT_OF_MEMORY           =  77
002000  2               UNDEFINED_STATEMENT     =  90
002000  2               BAD_SUBSCRIPT           = 107
002000  2               REDIMINSIONED_ARRAY     = 120
002000  2               DIVISION_BY_ZERO        = 133
002000  2               TYPE_MISMATCH           = 163
002000  2               STRING_TOO_LONG         = 176
002000  2               FORMULA_TOO_COMPLEX     = 191
002000  2               UNDEFINED_FUNCTION      = 224
002000  2               BAD_RESPONSE_TO_INPUT   = 254
002000  2               CTRL_C_INTERRUPT        = 255
002000  2               
002000  2               APPLESOFT_ERROR         = $D412
002000  2               
002000  2               
002000  2               .ENDIF
002000  2               
002000  1                       .include "ZEROPAGE.S"
002000  2               ;*****************************************************
002000  2               ; ZEROPAGE
002000  2               ; "Safe" locations to use in zero page
002000  2               ;
002000  2               ; define APPLEII for Apple II zero page
002000  2               ; define ATARI   for Atari 8-bit zero page
002000  2               ;
002000  2               ; By Norman Davie
002000  2               
002000  2               .IF .NOT .DEFINED(ZP1)
002000  2               
002000  2               .IF .DEFINED(APPLEII)
002000  2               ZP1             =	$EB
002000  2               ZP1_LO	        =	$EB
002000  2               ZP1_HI	        = 	$EC
002000  2               
002000  2               ZP2             =	$ED
002000  2               ZP2_LO	        =	$ED
002000  2               ZP2_HI          =	$EE
002000  2               
002000  2               ZP3             =	$FA
002000  2               ZP3_LO          =	$FA
002000  2               ZP3_HI	   	    =	$FB
002000  2               
002000  2               ZP4	            =	$FC
002000  2               ZP4_LO		    =	$FC
002000  2               ZP4_HI		    =	$FD
002000  2               
002000  2               ZP5             =	$EF
002000  2               
002000  2               ZP_BLOCK_SIZE   = ZP4_HI - ZP1 + 1
002000  2               
002000  2               .ENDIF
002000  2               
002000  2               .IF .DEFINED(ATARI)
002000  2               
002000  2               ZP1             =	$A2
002000  2               ZP1_LO	        =	$A2
002000  2               ZP1_HI	        = 	$A3
002000  2               
002000  2               ZP2             =	$A4
002000  2               ZP2_LO		    =	$A4
002000  2               ZP2_HI		    =	$A5
002000  2               
002000  2               ZP3             =	$A6
002000  2               ZP3_LO		    =	$A6
002000  2               ZP3_HI		    =	$A7
002000  2               
002000  2               ZP4             =	$A8
002000  2               ZP4_LO		    =	$A8
002000  2               ZP4_HI		    =	$A9
002000  2               
002000  2               ZP5		    =	$AA
002000  2               .ENDIF
002000  2               
002000  2               
002000  2               .ENDIF
002000  2               
002000  1                       .include "MACROS.S"
002000  2               .IF .NOT .DEFINED(MACROS)
002000  2               
002000  2               MACROS=1
002000  2               
002000  2               .MACRO SAVE_REGS
002000  2                       STA MACRO_A
002000  2                       PHP
002000  2                       PHA
002000  2                       TXA
002000  2                       PHA
002000  2                       TYA
002000  2                       PHA
002000  2                       LDA MACRO_A
002000  2               .ENDMACRO
002000  2               
002000  2               .MACRO RESTORE_REGS
002000  2                       PLA
002000  2                       TAY
002000  2                       PLA
002000  2                       TAX
002000  2                       PLA
002000  2                       PLP
002000  2               .ENDMACRO
002000  2               
002000  2               .MACRO PRINT_STR STR
002000  2                       SAVE_REGS
002000  2                       LDA STR
002000  2                       LDY STR+1
002000  2                       JSR STROUT
002000  2                       RESTORE_REGS
002000  2               .ENDMACRO
002000  2               
002000  2               .MACRO PRINT_OUT STR
002000  2                       SAVE_REGS
002000  2                       LDA #<STR
002000  2                       LDY #>STR
002000  2                       JSR STROUT
002000  2                       RESTORE_REGS
002000  2               .ENDMACRO
002000  2               
002000  2               
002000  2               .ENDIF
002000  2               
002000  1               
002000  1               ;*********************************************************
002000  1               
002000  1               STARTOFFILE:
002000  1               
002000  1               NINIT:
002000  1               
002000  1               .IF .NOT STRIP_TRACE
002000  1               .IF TRACE_ON
002000  1                               JSR NTRACE
002000  1               .ELSE
002000  1                               JSR NNOTRACE
002000  1               .ENDIF
002000  1               .ENDIF
002000  1  20 79 24                     JSR FILL_CMD_LIST
002003  1               
002003  1  20 57 25                     JSR GET_SMARTPORT_DISPATCH_ADDRESS      ; FIND THE ADDRESS
002006  1               
002006  1               .IF .NOT STRIP_TRACE
002006  1               .IF EXT_TRACE
002006  1                               SAVE_REGS
002006  1                               PRINT_STR DISPATCHER_ADDRESS_STR_ADDR
002006  1                               JSR PRTAX
002006  1                               JSR CROUT
002006  1                               RESTORE_REGS
002006  1               .ENDIF
002006  1               .ENDIF
002006  1  AD 2D 32                     LDA DISPATCHER_ADDR_HI
002009  1  C9 FF                        CMP #$FF                                ; WAS THE CARD FOUND?
00200B  1  D0 08                        BNE FOUND_SMARTPORT
00200D  1               
00200D  1  A9 A6                        LDA #<SP_NOT_FOUND_STR                  ; "SMARTPORT NOT FOUND!"
00200F  1  A0 2F                        LDY #>SP_NOT_FOUND_STR
002011  1  20 3A DB                     JSR STROUT
002014  1               
002014  1               .IF EXT_TRACE
002014  1                               LDA #<EXITING_STR
002014  1                               LDY #>EXITING_STR
002014  1                               JSR STROUT
002014  1               .ENDIF
002014  1               
002014  1               BYE:
002014  1  60                           RTS
002015  1               
002015  1               
002015  1               FOUND_SMARTPORT:
002015  1               
002015  1                               ; FIND ALL THE NETWORK ADAPTERS
002015  1                               ; 0 IS "NETWORK" OR "NETWORK_0"
002015  1                               ; 1-3 IS "NETWORK_1" OR 2, OR 3...
002015  1               
002015  1  A2 00                        LDX #$00
002017  1               NEXT_NETWORK_CACHE:
002017  1  8E 6E 2B                     STX BASIC_UNIT
00201A  1  20 3F 2A                     JSR FN_FIND_NETWORK
00201D  1                               ; X gets destroyed so reload as "BASIC" unit
00201D  1                               ; y = real unit #
00201D  1  AE 6E 2B                     LDX BASIC_UNIT
002020  1  98                           TYA
002021  1  9D 7C 2F                     STA NETWORK_CACHE,X
002024  1               
002024  1  E8                           INX
002025  1  E0 04                        CPX #$04        ; move to the next "basic" unit
002027  1  D0 EE                        BNE NEXT_NETWORK_CACHE
002029  1               
002029  1               .IF .NOT STRIP_TRACE
002029  1               .IF EXT2_TRACE
002029  1                               JSR DISPLAY_NETS
002029  1               .ENDIF
002029  1               .ENDIF
002029  1               
002029  1               ; RELOCATE US TO WHERE IT'S SAFE
002029  1               
002029  1               .IF .NOT STRIP_TRACE
002029  1               .IF EXT_TRACE
002029  1                               JSR CROUT               ; CARRIAGE RETURN
002029  1                               LDA #<HIMEM_IS_STR          ; "OLD HIMEM:"
002029  1                               LDY #>HIMEM_IS_STR
002029  1                               JSR STROUT
002029  1               
002029  1                               LDA HIMEM+1
002029  1                               STA OLDHIMEM+1          ; KEEP TRACK OF HIMEM
002029  1               		LDX HIMEM
002029  1                               STX OLDHIMEM
002029  1               		JSR PRTAX               ; PRINT ADDRESS
002029  1               .ENDIF
002029  1               .ENDIF
002029  1               
002029  1               .IF RELOCATE
002029  1               		JSR ADJUST_HIMEM        ; Move HIMEM so we can put our code at it.
002029  1               .ENDIF
002029  1               
002029  1               .IF .NOT STRIP_TRACE
002029  1               .IF EXT_TRACE
002029  1               		LDA #<NEW_HIMEM_STR    ; "NEW HIMEM: "
002029  1               		LDY #>NEW_HIMEM_STR
002029  1               		JSR STROUT
002029  1               .ENDIF
002029  1               .ENDIF
002029  1               
002029  1  A5 74        		LDA HIMEM+1
00202B  1  A6 73        		LDX HIMEM
00202D  1               
00202D  1               .IF .NOT STRIP_TRACE
00202D  1               .IF EXT_TRACE
00202D  1               		JSR PRTAX               ; PRINT NEW HIMEM ADDRESS
00202D  1                               JSR CROUT
00202D  1               .ENDIF
00202D  1               .ENDIF
00202D  1               
00202D  1               .IF RELOCATE
00202D  1                               JSR CLEAR_CMD_LIST      ; clear the data so we can relocate code/data together
00202D  1                               JSR RELOCATE_TO_HIMEM   ; copy the code and data, adjust all absolute addresses
00202D  1               .ENDIF
00202D  1               
00202D  1  20 79 24     relocate000:    JSR FILL_CMD_LIST       ; let's fix all the smartport instruction data now that
002030  1                                                       ; everything has been relocated
002030  1               
002030  1               .IF .NOT USE_SP
002030  1                               JSR GET_SMARTPORT_DISPATCH_ADDRESS      ; address would have changed during relocation
002030  1               .ENDIF
002030  1               
002030  1               .IF RELOCATE
002030  1               
002030  1               .IF .NOT STRIP_TRACE
002030  1               .IF EXT_TRACE
002030  1                               LDA #<RELOC_SIZE_STR        ; "CODE SIZE:"
002030  1                               LDY #>RELOC_SIZE_STR
002030  1                               JSR STROUT
002030  1               
002030  1                               LDX #<(RELOCATE_DATA_END - RELOCATE_CODE_START)
002030  1                               LDA #>(RELOCATE_DATA_END - RELOCATE_CODE_START)
002030  1                               JSR PRTAX               ; PRINT SIZE
002030  1                               JSR CROUT
002030  1               
002030  1               .ENDIF
002030  1               .ENDIF
002030  1               
002030  1               
002030  1               .ENDIF
002030  1               
002030  1               ; SAVE PREVIOUS VECTOR INFO
002030  1               
002030  1               SAVEVECT:
002030  1               
002030  1  AD F5 03                     LDA AMPVECT
002033  1  8D 69 2B     relocate001:    STA PREVECT
002036  1  AD F6 03                     LDA AMPVECT+1
002039  1  8D 6A 2B     relocate002:    STA PREVECT+1
00203C  1  AD F7 03                     LDA AMPVECT+2
00203F  1  8D 6B 2B     relocate003:    STA PREVECT+2
002042  1               
002042  1               ; UPDATE THE AMPERSAND VECTOR TO OUR ROUTINE
002042  1               
002042  1  A9 4C                        LDA #$4C                                ; JMP
002044  1  8D F5 03                     STA AMPVECT
002047  1  AD 1C 2B     relocate004:    LDA RELOC_NSTART                        ; SET THE AMPERSAND VECTOR
00204A  1  8D F6 03                     STA AMPVECT+1
00204D  1  AD 1D 2B     relocate005:    LDA RELOC_NSTART+1
002050  1  8D F7 03                     STA AMPVECT+2
002053  1               
002053  1               ; ANNOUNCE OUR SUCCESS
002053  1               
002053  1  A9 8B                        LDA #<EXTADDED_STR                      ; "FUJINET EXTENSION ADDED"
002055  1  A0 2F                        LDY #>EXTADDED_STR
002057  1  20 3A DB                     JSR STROUT
00205A  1               
00205A  1               .IF .NOT USE_SP
00205A  1                               PRINT_STR FAKE_SMARTPORT_STR_ADDR
00205A  1                               JSR GET_SMARTPORT_DISPATCH_ADDRESS      ; FIND THE ADDRESS AGAIN, SINCE IT WAS RELOCATED
00205A  1               .ENDIF
00205A  1               
00205A  1               
00205A  1                               ; RELOCATION CODE WILL CLOBBER THE
00205A  1                               ; STRING, THINKING IT'S CODE,
00205A  1                               ; SO PUT IT THERE AFTER IT'S
00205A  1                               ; BEEN MOVED
00205A  1               
00205A  1  A2 00                        LDX #$00
00205C  1               CPY_SIG:
00205C  1  BD 02 30                     LDA SIGNATURE_STR,X
00205F  1  9D 6D 20     relocate006:    STA SIGNATURE,X
002062  1  E8                           INX
002063  1  E0 07                        CPX #SIG_SIZE
002065  1  D0 F5                        BNE CPY_SIG
002067  1  A9 07                        LDA #SIG_SIZE
002069  1  9D 6D 20     relocate007:    STA SIGNATURE,X
00206C  1               
00206C  1               
00206C  1               .IF RELOCATE
00206C  1               .IF WIPE_AFTER
00206C  1                               LDA #<RELOCATE_CODE_START
00206C  1                               STA ZP1_LO
00206C  1                               LDY #>RELOCATE_CODE_START
00206C  1                               STY ZP1_HI
00206C  1               
00206C  1                               LDX #<(RELOCATE_DATA_END - RELOCATE_CODE_START)
00206C  1                               LDY #>(RELOCATE_DATA_END - RELOCATE_CODE_START)
00206C  1               WIPE_IT:
00206C  1               WIPE_IT_GOOD:
00206C  1                               TYA
00206C  1                               PHA
00206C  1                               LDY #$00
00206C  1                               LDA #$00
00206C  1                               STA (ZP1),Y
00206C  1                               LDA ZP1_LO
00206C  1                               CLC
00206C  1                               ADC #$01
00206C  1                               STA ZP1_LO
00206C  1                               LDA ZP1_HI
00206C  1                               ADC #$00
00206C  1                               STA ZP1_HI
00206C  1                               PLA
00206C  1                               TAY
00206C  1                               DEX
00206C  1                               BNE WIPE_IT
00206C  1                               DEY
00206C  1                               BNE WIPE_IT_GOOD
00206C  1               
00206C  1               .ENDIF
00206C  1               .ENDIF
00206C  1               
00206C  1               .IF PRODOS
00206C  1  60                           RTS
00206D  1               .ELSE
00206D  1                               JMP DOSWARM             ; WARM START DOS-NEEDED FOR BRUN
00206D  1               .ENDIF
00206D  1               
00206D  1               RELOCATE_CODE_START:
00206D  1               ;****************************************
00206D  1               ; THIS IS USED TO DETERMINE IF THE
00206D  1               ; EXTENSIONS HAVE ALREADY BEEN INSTALLED
00206D  1               ; (R=1)
00206D  1               ;****************************************
00206D  1               ;10000 REM *************************
00206D  1               ;10010 REM DETERMINE IF FUJI EXTENSIONS
00206D  1               ;10015 REM HAVE BEEN INSTALLED (R=1)
00206D  1               ;10020 REM *************************
00206D  1               ;10030 X = PEEK(1014)+PEEK(1015)*256
00206D  1               ;10040 X = X - 1
00206D  1               ;10050 C = PEEK(X): IF C = 0 OR C > 20 THEN 10080
00206D  1               ;10060 X = X - C - 1
00206D  1               ;10070 A$=""
00206D  1               ;10080 FOR Y = 1 TO C: A$=A$+CHR$(PEEK(X)):X=X+1:NEXT Y
00206D  1               ;10090 B$ = "FUJIAMP"
00206D  1               ;10100 PRINT A$;"--";B$;"?";
00206D  1               ;10130 IF A$=B$ THEN R=1: PRINT "YES":GOTO 10150
00206D  1               ;10140 R=0:PRINT "NO"
00206D  1               ;10150 RETURN
00206D  1               
00206D  1               ;****************************************
00206D  1               SIGNATURE:
00206D  1  EA EA EA EA                  .BYTE $EA,$EA,$EA,$EA,$EA,$EA,$EA
002071  1  EA EA EA     
002074  1  EA                           .BYTE $EA
002075  1               
002075  1               ;****************************************
002075  1               ; NSTART - FUJINET EXTENSION START
002075  1               ;   THIS IS THE ENTRY POINT OF THE AMPERSAND ROUTINE
002075  1               ;   CHECK FOR OUR COMMANDS AND EXECUTE IF FOUND
002075  1               ;   IF IT DOESN'T MATCH OUR COMMANDS, THEN
002075  1               ;   GO TO THE PREVIOUS AMPERSAND ROUTINE
002075  1               ;****************************************
002075  1               
002075  1               NSTART:
002075  1  A2 00                        LDX #$00
002077  1               NEXTCMD:
002077  1  A0 00                        LDY #$00       ; INDEX INTO TXTPTR
002079  1  BD 1E 2B                     LDA COMMANDS,X ; COMMAND TEXT IN TABLE
00207C  1  F0 30                        BEQ NOMORECMDS ; WE'VE EXAUSTED OUR CMD LIST
00207E  1               COMP:
00207E  1  BD 1E 2B                     LDA COMMANDS,X
002081  1  D1 B8                        CMP (TXTPTR),Y ; DOES COMMAND TEXT MATCH?
002083  1  D0 09                        BNE SKIPCMD    ; IT'S NOT A MATCH
002085  1  C8                           INY              ; MOVE TO NEXT CHARACTER
002086  1  E8                           INX
002087  1  BD 1E 2B                     LDA COMMANDS,X ; IS THE CHARACTER A NULL?
00208A  1  D0 F2                        BNE COMP       ; NOPE, COMPARE NEXT CHARACTER
00208C  1  F0 0C                        BEQ FOUNDCMD   ; YES, WE'VE FOUND OUR COMMAND
00208E  1               SKIPCMD:
00208E  1  E8                           INX             ; MOVE TO THE NEXT CHARACTER
00208F  1  BD 1E 2B                     LDA COMMANDS,X  ; KEEP READING UNTIL NULL
002092  1  D0 FA                        BNE SKIPCMD
002094  1  E8                           INX             ; IGNORE THE NULL
002095  1  E8                           INX             ; IGNORE THE ADDRESS
002096  1  E8                           INX
002097  1               
002097  1  18                           CLC
002098  1  90 DD                        BCC NEXTCMD     ; CHECK NEXT CMD
00209A  1               FOUNDCMD:
00209A  1  8A                           TXA
00209B  1  48                           PHA
00209C  1               RMCMD:
00209C  1  20 B1 00                     JSR CHRGET      ; REMOVE CHAR FROM BASIC
00209F  1  88                           DEY
0020A0  1  D0 FA                        BNE RMCMD
0020A2  1               
0020A2  1  68                           PLA
0020A3  1  AA                           TAX
0020A4  1               
0020A4  1               ; PUSHADDR ON STACK AND "RETURN" TO OUR ROUTINE
0020A4  1               
0020A4  1  E8                           INX
0020A5  1  BD 1F 2B                     LDA COMMANDS+1,X
0020A8  1  48                           PHA
0020A9  1  BD 1E 2B                     LDA COMMANDS,X
0020AC  1  48                           PHA             ; ADDRESS OF OUR ROUTINE IS ON STACK
0020AD  1               
0020AD  1  60                           RTS             ; "RETURN" (JMP) TO ADDRESS ON STACK
0020AE  1               
0020AE  1               ; IF WE'RE HERE, IT'S NOT ONE OF OUR COMMANDS
0020AE  1               ; JUMP TO THE PREVIOUS VECTOR AND LET IT PROCESS IT
0020AE  1               
0020AE  1               NOMORECMDS:
0020AE  1               
0020AE  1               .IF .NOT STRIP_TRACE
0020AE  1               .IF EXT_TRACE
0020AE  1               
0020AE  1                               PRINT_STR NOT_FOUND_STR_ADDR  ; "COMMAND NOT FOUND"
0020AE  1                               JSR CROUT
0020AE  1               
0020AE  1               .ENDIF
0020AE  1               .ENDIF
0020AE  1               
0020AE  1  4C 69 2B                     JMP   PREVECT    ; WE DIDN'T FIND OUR COMAND SO GO TO OLD VECTOR
0020B1  1               
0020B1  1               .IF .NOT STRIP_TRACE
0020B1  1               DISPLAY_NETS:
0020B1  1                               SAVE_REGS
0020B1  1                               PRINT_STR NETWORK_STR_ADDR
0020B1  1                               LDA #COLON
0020B1  1                               JSR COUT
0020B1  1               
0020B1  1                               LDY #$00
0020B1  1               
0020B1  1               NEXT_NET:
0020B1  1                               LDA NETWORK_CACHE,Y
0020B1  1                               TAX
0020B1  1                               JSR PRTX
0020B1  1                               INY
0020B1  1                               CPY #$04
0020B1  1                               BNE NEXT_NET
0020B1  1                               JSR CROUT
0020B1  1                               RESTORE_REGS
0020B1  1                               RTS
0020B1  1               
0020B1  1               DISPLAY_OPENS:
0020B1  1                               SAVE_REGS
0020B1  1                               PRINT_STR NETWORK_STR_ADDR
0020B1  1                               LDA #COLON
0020B1  1                               JSR COUT
0020B1  1               
0020B1  1                               LDY #$00
0020B1  1               
0020B1  1               NEXT_OPEN:
0020B1  1                               LDA OPEN_LIST,Y
0020B1  1                               TAX
0020B1  1                               JSR PRTX
0020B1  1                               INY
0020B1  1                               CPY #$04
0020B1  1                               BNE NEXT_OPEN
0020B1  1                               JSR CROUT
0020B1  1                               RESTORE_REGS
0020B1  1                               RTS
0020B1  1               
0020B1  1               DISPLAY_NERRS:
0020B1  1                               SAVE_REGS
0020B1  1                               PRINT_STR SP_ERROR_STR_ADDR
0020B1  1                               LDA #COLON
0020B1  1                               JSR COUT
0020B1  1               
0020B1  1                               LDY #$00
0020B1  1               
0020B1  1               NEXT_NERR:
0020B1  1                               LDA NERR,Y
0020B1  1                               TAX
0020B1  1                               JSR PRTX
0020B1  1                               INY
0020B1  1                               CPY #$04
0020B1  1                               BNE NEXT_NERR
0020B1  1                               JSR CROUT
0020B1  1                               RESTORE_REGS
0020B1  1                               RTS
0020B1  1               .ENDIF
0020B1  1               
0020B1  1               ;*********************************
0020B1  1               ; GETSTR - GETS A STATIC STRING ("BLAH")
0020B1  1               ; INPUT:
0020B1  1               ;   TXTPTR IS AT THE START OF THE STRING IN BASIC
0020B1  1               ; RETURNS:
0020B1  1               ;   STRING IS COPIED INTO STRBUF AND TERMINATED WITH A NULL
0020B1  1               ;   STRING LENGTH IS STORED IN STRLEN
0020B1  1               ; NOTE:
0020B1  1               ;    CHRGET CONSUMES SPACES SILENTLY, WHICH IS WHY
0020B1  1               ;    WE DON'T USE IT TO COLLECT THE STRING
0020B1  1               ;***********************************
0020B1  1               
0020B1  1               GETSTR:                         ; GET STATIC STRING
0020B1  1  A0 01                        LDY #01
0020B3  1               CONSUME:
0020B3  1  B1 B8                        LDA (TXTPTR),Y  ; GET CHARACTER FROM BASIC
0020B5  1  C9 22                        CMP #QUOTE      ; WE NEED TO STOP ON THE ENDING QUOTE
0020B7  1  F0 07                        BEQ NULLSTR1    ; WE'RE DONE
0020B9  1               
0020B9  1  99 7A 2E                     STA STRBUF-1,Y  ; SAVE THE CHARACTER
0020BC  1  C8                           INY
0020BD  1  18                           CLC
0020BE  1  90 F3                        BCC CONSUME     ; GET THE NEXT CHARACTER
0020C0  1               NULLSTR1:
0020C0  1  A9 00                        LDA #00
0020C2  1  99 7A 2E                     STA STRBUF-1,Y  ; TERMINATE THE STRING WITH A NULL
0020C5  1  88                           DEY
0020C6  1  8C 7A 2E                     STY STRLEN      ; SAVE THE LENGTH OF THE STRING
0020C9  1  20 B1 00                     JSR CHRGET
0020CC  1               GOBBLE:
0020CC  1  20 B1 00                     JSR CHRGET      ; GET THE CHARACTER FROM BASIC
0020CF  1  C9 22                        CMP #QUOTE      ; HAVE WE FOUND THE ENDING QUOTE?
0020D1  1  F0 04                        BEQ COMPLETED   ; WE'RE DONE
0020D3  1  C8                           INY
0020D4  1  18                           CLC
0020D5  1  90 F5                        BCC GOBBLE
0020D7  1               
0020D7  1               COMPLETED:
0020D7  1  20 B1 00                     JSR CHRGET
0020DA  1  60                           RTS
0020DB  1               
0020DB  1               ;*******************************************
0020DB  1               ; GETSTRVAR - GET STRING VARIABLE
0020DB  1               ; RETURNS:
0020DB  1               ;   STRING LENGTH IN DSCTMP
0020DB  1               ;   STRING ADDR LO IN DSCTMP+1
0020DB  1               ;   STRING ADDR HI IN DSCTMP+2
0020DB  1               ;*********************************
0020DB  1               GETSTRVAR:
0020DB  1  20 E3 DF                     JSR PTRGET     ; GET STRING DESCRIPTOR
0020DE  1  A0 00                        LDY #0
0020E0  1  B1 83                        LDA (VARPTR),Y ; STRING LENGTH
0020E2  1  85 9D                        STA DSCTMP
0020E4  1  C8                           INY
0020E5  1  B1 83                        LDA (VARPTR),Y ; ADDR LO
0020E7  1  85 9E                        STA DSCTMP+1
0020E9  1  C8                           INY
0020EA  1  B1 83                        LDA (VARPTR),Y ; ADDR HI
0020EC  1  85 9F                        STA DSCTMP+2
0020EE  1  60                           RTS
0020EF  1               ;*********************************
0020EF  1               ;*******************************
0020EF  1               ; BYTESAV - CONVERT BYTE TO FLOAT
0020EF  1               ;           AND STORE IN VARIABLE
0020EF  1               ; INPUT:
0020EF  1               ;   Y - BYTE TO STORE
0020EF  1               ;***
0020EF  1               ; WOR.RESAV - CONVERT WORD TO FLOAT AND STORE IN VARIABLE
0020EF  1               ; INPUT:
0020EF  1               ;   A - WORD HI
0020EF  1               ;   Y - WORD LO
0020EF  1               ;***
0020EF  1               ; RETURN
0020EF  1               ;   BOTH ROUTINES RETURN:
0020EF  1               ;   FLOAT STORED INTO VARIABLE
0020EF  1               ;**********************************
0020EF  1               BYTESAV:
0020EF  1  A9 00                        LDA #0
0020F1  1               WORDSAV:
0020F1  1  20 F2 E2                     JSR GIVAYF     ; CONVERT TO FLOATING POINT
0020F4  1  20 E3 DF                     JSR PTRGET     ; FIND ADDRESS OF THE VARIABLE
0020F7  1  AA                           TAX
0020F8  1  20 2B EB                     JSR MOVMF      ; STORE VALUE INTO VARIABLE
0020FB  1  60                           RTS
0020FC  1               
0020FC  1               .IF .NOT STRIP_TRACE
0020FC  1               ;*************************************
0020FC  1               ; DISPLAY INTERNAL STATE
0020FC  1               ;*************************************
0020FC  1               DISPLAY_INTERNAL_STATE:
0020FC  1               
0020FC  1                               SAVE_REGS
0020FC  1                               LDX BASIC_UNIT
0020FC  1                               JSR PRINT_X
0020FC  1                               LDX MODE
0020FC  1                               JSR PRINT_X
0020FC  1                               LDX TRANSLATION
0020FC  1                               JSR PRINT_X
0020FC  1                               JSR CROUT
0020FC  1                               LDA #'"'
0020FC  1                               JSR COUT
0020FC  1                               PRINT_STR URL_ADDR
0020FC  1                               LDA #'"'
0020FC  1                               JSR COUT
0020FC  1                               JSR CROUT
0020FC  1               
0020FC  1                               LDX URL_LEN
0020FC  1                               JSR PRINT_X
0020FC  1               
0020FC  1                               LDX COMMAND
0020FC  1                               JSR PRINT_X
0020FC  1                               JSR CROUT
0020FC  1               
0020FC  1                               LDX NETWORK_CACHE
0020FC  1                               JSR PRINT_X
0020FC  1                               LDX NETWORK_CACHE+1
0020FC  1                               JSR PRINT_X
0020FC  1                               LDX NETWORK_CACHE+2
0020FC  1                               JSR PRINT_X
0020FC  1                               LDX NETWORK_CACHE+3
0020FC  1                               JSR PRINT_X
0020FC  1                               JSR CROUT
0020FC  1               
0020FC  1                               RESTORE_REGS
0020FC  1                               RTS
0020FC  1               .ENDIF
0020FC  1               
0020FC  1               ;*************************************
0020FC  1               ;*************************************
0020FC  1               ;*************************************
0020FC  1               ;*************************************
0020FC  1               
0020FC  1               ;*************************************
0020FC  1               ; IGNORE_TO_NEXT_BASIC_STATEMENT
0020FC  1               ;
0020FC  1               ; Skip all crap until we either find a
0020FC  1               ; colon, or we're at the end of the
0020FC  1               ; BASIC line
0020FC  1               ;*************************************
0020FC  1               IGNORE_TO_NEXT_BASIC_STATEMENT:
0020FC  1  20 B7 00                     JSR CHRGOT
0020FF  1  F0 0A                        BEQ RETURN_TO_BASIC     ; 0 = END OF LINE
002101  1  C9 3A                        CMP #':'
002103  1  F0 06                        BEQ RETURN_TO_BASIC
002105  1               
002105  1  20 B1 00                     JSR CHRGET
002108  1  18                           CLC
002109  1  90 F1                        BCC IGNORE_TO_NEXT_BASIC_STATEMENT
00210B  1               
00210B  1               RETURN_TO_BASIC:
00210B  1  60                           RTS
00210C  1               
00210C  1                               .include "TOKENS.S"
00210C  2               ;************************************************************************
00210C  2               ; &NOPEN UNIT,MODE,TRANS,URL$
00210C  2               ; &NOPEN UNIT,MODE,TRANS,"URL"
00210C  2               ;
00210C  2               ; Opens a specified URL for use.
00210C  2               ;
00210C  2               ; UNIT = 0-4 BASIC NETWORK (not Fujinet unit number)
00210C  2               ; MODE = 04-READ ONLY
00210C  2               ;        06-READ DIRECTORY
00210C  2               ;        08-WRITE ONLY
00210C  2               ;        0C-READ AND WRITE
00210C  2               ;        0E-HTTP POST
00210C  2               ; TRANS= 0-NO TRANSLATION
00210C  2               ;        1-CR TO CR (yeah, does nothing)
00210C  2               ;        2-LF TO CR
00210C  2               ;        3-CR/LF TO CR
00210C  2               ;************************************************************************
00210C  2               NOPEN:
00210C  2               
00210C  2               .IF .NOT STRIP_TRACE
00210C  2                               LDA TRACE_FLAG
00210C  2                               BEQ NO_TRACE1
00210C  2                               PRINT_STR NOPEN_STR_ADDR        ; "NOPEN"
00210C  2               NO_TRACE1:
00210C  2               .ENDIF
00210C  2               
00210C  2  20 F8 E6                     JSR GETBYT                      ; GET THE BASIC UNIT
00210F  2  8E 6E 2B                     STX BASIC_UNIT
002112  2               
002112  2               .IF .NOT STRIP_TRACE
002112  2                               LDA TRACE_FLAG
002112  2                               BEQ NO_TRACE32
002112  2                               SAVE_REGS
002112  2                               JSR PRTX
002112  2                               JSR CROUT
002112  2                               RESTORE_REGS
002112  2               NO_TRACE32:
002112  2               .ENDIF
002112  2  E0 04                        CPX #$04                        ; BASIC UNIT HAS TO BE BETWEEN 0-3
002114  2  30 05                        BMI UNIT_OK1                    ; OUT OF RANGE?
002116  2               
002116  2  A2 35                        LDX #ILLEGAL_QUANTITY_ERROR     ; MUST BE BETWEEN 0 AND 3
002118  2  4C 12 D4                     JMP APPLESOFT_ERROR
00211B  2               
00211B  2               UNIT_OK1:
00211B  2  AE 6E 2B                     LDX BASIC_UNIT
00211E  2  E0 FE                        CPX #FN_ERR                     ; NETWORK WAS NOT FOUND!
002120  2  D0 0E                        BNE NOPEN_NETWORK_FOUND
002122  2               
002122  2               NO_NETWORK_ERROR:
002122  2  A9 D2                        LDA #FN_ERR_SERVICE_NOT_AVAILABLE       ; CAN'T FIND THE SPECIFIED NETWORK (E.G. NETWORK_1 WAS NOT FOUND)
002124  2  9D 84 2F                     STA NERR,X                              ; RECORD THE ERROR
002127  2  A9 FE                        LDA #FN_ERR                             ; INDICATE THIS BASIC_UNIT IS CLOSED
002129  2  9D 80 2F                     STA OPEN_LIST,X
00212C  2  20 FC 20                     JSR IGNORE_TO_NEXT_BASIC_STATEMENT
00212F  2  60                           RTS
002130  2               
002130  2               NOPEN_NETWORK_FOUND:
002130  2               
002130  2                               ; NETWORK_CACHE: WW XX YY ZZ - WHERE EACH BYTE IS THE ACTUAL UNIT NUMBER
002130  2               
002130  2  AE 6E 2B                     LDX BASIC_UNIT                  ; LOAD THE "BASIC" UNIT NUMBER
002133  2  BD 7C 2F                     LDA NETWORK_CACHE,X
002136  2  9D 80 2F                     STA OPEN_LIST, X                     ; STORE THE ACTUAL UNIT NUMBER FOR LATER USE
002139  2               
002139  2  20 BE DE                     JSR CHKCOM
00213C  2  20 F8 E6                     JSR GETBYT                      ; GET MODE
00213F  2  8E 6F 2B                     STX MODE
002142  2               
002142  2  20 BE DE                     JSR CHKCOM
002145  2  20 F8 E6                     JSR GETBYT                      ; GET TRANS
002148  2  8E 70 2B                     STX TRANSLATION
00214B  2               
00214B  2  20 BE DE                     JSR CHKCOM
00214E  2  20 B7 00                     JSR CHRGOT                      ; WHAT ARE WE POINTING AT IN BASIC
002151  2  C9 22                        CMP #QUOTE                      ; IS IT A STATIC STRING?
002153  2  D0 15                        BNE VARSTR
002155  2               
002155  2  20 B1 20                     JSR GETSTR                      ; GETS THE STATIC STRING, STORED IN STRBUF
002158  2               
002158  2               ; WE'RE GOING TO CREATE A NEW DESCRIPTION
002158  2               ; THE SAME WAY APPLESOFT DOES
002158  2               
002158  2  AD 7A 2E                     LDA STRLEN                      ; GETSTR STORES THE STRING LENGTH HERE
00215B  2  85 9D                        STA DSCTMP
00215D  2               
00215D  2  AD 7A 2F                     LDA STRBUF_ADDR                 ; THE ADDRESS OF OUR STATIC STRING
002160  2  85 9E                        STA DSCTMP+1
002162  2  AD 7B 2F                     LDA STRBUF_ADDR+1
002165  2  85 9F                        STA DSCTMP+2
002167  2               
002167  2  18                           CLC
002168  2  90 03                        BCC STORE
00216A  2               
00216A  2               VARSTR:
00216A  2  20 DB 20                     JSR GETSTRVAR                   ; IT'S A STRING VARIABLE
00216D  2               STORE:
00216D  2  A4 9D                        LDY DSCTMP                      ; GET THE STRING LENGTH
00216F  2  8C 71 2B                     STY URL_LEN                     ; INCLUDE NULL AT END OF LENGTH
002172  2  88                           DEY
002173  2               STORING:
002173  2  B1 9E                        LDA (DSCTMP+1),Y                ; TRANSER THE STRING TO THE URL BUFFER
002175  2  99 72 2B                     STA URL,Y
002178  2  88                           DEY
002179  2  10 F8                        BPL STORING
00217B  2               
00217B  2                               ; MAKE THE STRING C COMPATIBLE
00217B  2               
00217B  2  AC 71 2B                     LDY URL_LEN
00217E  2  A9 00                        LDA #0                          ; NULL TERMINATE THE STRING
002180  2  99 72 2B                     STA URL,Y
002183  2               
002183  2  C8                           INY                             ; INCLUDE THE NULL TERMINATOR TO THE LENGTH
002184  2  8C 71 2B                     STY URL_LEN
002187  2               
002187  2  AE 6E 2B                     LDX BASIC_UNIT                  ; BASIC UNIT 0-4
00218A  2  BD 80 2F                     LDA OPEN_LIST,X                   ; FUJINET UNIT
00218D  2  AA                           TAX
00218E  2  20 5A 29                     JSR FN_OPEN
002191  2  90 0E                        BCC NOPEN_COMPLETE
002193  2               
002193  2  AE 6E 2B                     LDX BASIC_UNIT                  ; FAILED TO OPEN
002196  2  A9 FD                        LDA #FN_NO_NETWORK              ; INDICATE THE NETWORK IS
002198  2  9D 80 2F                     STA OPEN_LIST,X                   ; NOT IN USE
00219B  2  AD 5C 36                     LDA FN_LAST_ERR
00219E  2  9D 84 2F                     STA NERR,X
0021A1  2               
0021A1  2               NOPEN_COMPLETE:
0021A1  2               
0021A1  2  60                           RTS
0021A2  2               
0021A2  2               
0021A2  2               ;************************************************************************
0021A2  2               ; &NCLOSE UNIT
0021A2  2               ; Closes a network connection.
0021A2  2               ;************************************************************************
0021A2  2               NCLOSE:
0021A2  2               
0021A2  2               .IF .NOT STRIP_TRACE
0021A2  2                               LDA TRACE_FLAG
0021A2  2                               BEQ NO_TRACE2
0021A2  2                               PRINT_STR NCLOSE_STR_ADDR       ; "NCLOSE"
0021A2  2               
0021A2  2               NO_TRACE2:
0021A2  2               .ENDIF
0021A2  2  20 F8 E6                     JSR   GETBYT                    ; GET THE UNIT
0021A5  2  8E 6E 2B                     STX   BASIC_UNIT
0021A8  2               
0021A8  2               .IF .NOT STRIP_TRACE
0021A8  2                               LDA TRACE_FLAG
0021A8  2                               BEQ NO_TRACE34
0021A8  2               
0021A8  2                               SAVE_REGS
0021A8  2                               JSR PRTX
0021A8  2                               JSR CROUT
0021A8  2                               RESTORE_REGS
0021A8  2               NO_TRACE34:
0021A8  2               .ENDIF
0021A8  2               
0021A8  2               
0021A8  2  AE 6E 2B                     LDX BASIC_UNIT
0021AB  2  BD 80 2F                     LDA OPEN_LIST, X          ; THIS IS THE ACTUAL UNIT NUMBER
0021AE  2  C9 FD                        CMP #FN_NO_NETWORK   ; CLOSING SOMETHING THAT IS NOT ACTUALLY OPEN
0021B0  2  F0 04                        BEQ JUST_CLOSE
0021B2  2  AA                           TAX
0021B3  2  20 F8 29                     JSR FN_CLOSE
0021B6  2               
0021B6  2               JUST_CLOSE:
0021B6  2  AE 6E 2B                     LDX BASIC_UNIT          ; SAVE ANY ERROR THAT OCCURED DURING CLOSE
0021B9  2  9D 84 2F                     STA NERR,X
0021BC  2               
0021BC  2  A9 FD                        LDA #FN_NO_NETWORK      ; REGARDLESS, INDICATE BASIC UNIT IS CLOSED
0021BE  2  9D 80 2F                     STA OPEN_LIST, X
0021C1  2  60                           RTS
0021C2  2               
0021C2  2               ;************************************************************************
0021C2  2               ; &NREAD UNIT, VAR$, LEN
0021C2  2               ; Gets len number of bytes and puts them into string variable var$
0021C2  2               ;************************************************************************
0021C2  2               NREAD:
0021C2  2               
0021C2  2               .IF .NOT STRIP_TRACE
0021C2  2                               LDA TRACE_FLAG
0021C2  2                               BEQ NO_TRACE3
0021C2  2                               PRINT_STR NREAD_STR_ADDR        ; "NREAD"
0021C2  2               NO_TRACE3:
0021C2  2               .ENDIF
0021C2  2  20 F8 E6                     JSR   GETBYT                    ; GET THE UNIT
0021C5  2  8E 6E 2B                     STX   BASIC_UNIT
0021C8  2               
0021C8  2               .IF .NOT STRIP_TRACE
0021C8  2                               LDA TRACE_FLAG
0021C8  2                               BEQ NO_TRACE36
0021C8  2                               SAVE_REGS
0021C8  2                               JSR PRTX
0021C8  2                               JSR CROUT
0021C8  2                               RESTORE_REGS
0021C8  2               NO_TRACE36:
0021C8  2               .ENDIF
0021C8  2               
0021C8  2  20 BE DE                     JSR CHKCOM
0021CB  2  20 E3 DF                     JSR PTRGET                      ; GET THE STRING TO RECEIVED OUR DATA
0021CE  2               
0021CE  2               ;Returns the address of variable contents in A-reg (high) and Y-reg (low),
0021CE  2               ;as well as in VARPTR at $83.84. If a variable does not exist, it
0021CE  2               ;is created. TXTPTR points to the next character.
0021CE  2               
0021CE  2  A5 83                        LDA VARPTR                      ; SAVE THE STRING DESCRIPTOR LOCATION
0021D0  2  8D 88 2F                     STA STR_DSC_LEN                 ; FOR LATER
0021D3  2  A5 84                        LDA VARPTR+1
0021D5  2  8C 89 2F                     STY STR_DSC_LO
0021D8  2  A5 85                        LDA VARPTR+2
0021DA  2  8D 8A 2F                     STA STR_DSC_HI
0021DD  2               
0021DD  2  20 BE DE                     JSR CHKCOM
0021E0  2  20 F8 E6                     JSR GETBYT                      ; GET THE NUMBER OF CHARACTERS TO READ
0021E3  2  8E 76 2D                     STX BUFLEN
0021E6  2  8A                           TXA
0021E7  2               
0021E7  2               
0021E7  2  AE 6E 2B                     LDX BASIC_UNIT                  ; CONVERT THE BASIC_UNIT TO THE FUJINET UNIT
0021EA  2  BD 80 2F                     LDA OPEN_LIST,X
0021ED  2  C9 FD                        CMP #FN_NO_NETWORK              ; $FF INDICATES IT WAS NEVER OPENED
0021EF  2  D0 06                        BNE UNIT_OK2
0021F1  2               
0021F1  2  A9 FD                        LDA #FN_NO_NETWORK              ; RETURN ERROR THAT WE WERE NEVER CONNECTED
0021F3  2  9D 84 2F                     STA NERR,X
0021F6  2  60                           RTS
0021F7  2               
0021F7  2               UNIT_OK2:
0021F7  2  AA                           TAX
0021F8  2  20 B0 29                     JSR FN_READ                     ; REQUEST THE DATA FROM FUJINET
0021FB  2  E0 FE                        CPX #FN_ERR
0021FD  2  D0 04                        BNE TRANSFER_VALUES
0021FF  2               
0021FF  2               NREAD_ERROR:
0021FF  2  9D 84 2F                     STA NERR,X
002202  2  60                           RTS
002203  2               
002203  2               TRANSFER_VALUES:
002203  2                               ; TODO:
002203  2                               ; Adjust BUFLEN to the actual amount of
002203  2                               ; characters read
002203  2               
002203  2                               ; MOVSTR
002203  2                               ; Source must be in Y(HI) and X(LO)
002203  2                               ; Destination must be in FRESPC ($71,$72)
002203  2               
002203  2  AD 88 2F                     LDA STR_DSC_LEN                 ; RESTORE THE STRING DESCRIPTOR
002206  2  85 83                        STA VARPTR                      ; THAT WE SAVED EARLIER SO WE
002208  2  AD 89 2F                     LDA STR_DSC_LO
00220B  2  85 84                        STA VARPTR+1
00220D  2  AD 8A 2F                     LDA STR_DSC_HI
002210  2  85 85                        STA VARPTR+2
002212  2               
002212  2  AD 76 2D                     LDA BUFLEN                      ; THIS IS THE ACTUAL NUMBER OF CHARS WE READ
002215  2  20 D5 E3                     JSR STRINI                      ; CREATE NEW STRING OF LENGTH A
002218  2               
002218  2  A0 00                        LDY #$00
00221A  2  A5 9D                        LDA DSCTMP                      ; DESCRIPTOR FOR NEW STRING
00221C  2  91 83                        STA (VARPTR),Y                  ; UPDATE THE LENGTH
00221E  2  C8                           INY
00221F  2  A5 9E                        LDA DSCTMP+1                    ; UPDATE THE LOCATION OF THE STRING
002221  2  91 83                        STA (VARPTR),Y
002223  2  C8                           INY
002224  2  A5 9F                        LDA DSCTMP+2
002226  2  91 83                        STA (VARPTR),Y
002228  2               
002228  2  AD 76 2D                     LDA BUFLEN                      ; USE THE APPLESOFT ROUTINES TO
00222B  2  AC 2F 32                     LDY SP_PAYLOAD_ADDR+1           ; MOVE THE PAYLOAD INTO THE
00222E  2  AE 2E 32                     LDX SP_PAYLOAD_ADDR             ; ACTUAL STRING
002231  2  20 E2 E5                     JSR MOVSTR                      ; COPY BUFFER TO STRING (VAR$)
002234  2               
002234  2  60                           RTS
002235  2               
002235  2               ;************************************************************************
002235  2               ; &NWRITE UNIT,VAR$,LEN
002235  2               ; &NWRITE UNIT,"STRING",LEN
002235  2               ; Gets len number of bytes and puts them into string variable var$
002235  2               ;************************************************************************
002235  2               NWRITE:
002235  2               
002235  2               .IF .NOT STRIP_TRACE
002235  2                               LDA TRACE_FLAG
002235  2                               BEQ NO_TRACE4
002235  2                               PRINT_STR NWRITE_STR_ADDR       ; "NWRITE"
002235  2               NO_TRACE4:
002235  2               .ENDIF
002235  2  20 F8 E6                     JSR GETBYT                      ; GET UNIT
002238  2  8E 6E 2B                     STX BASIC_UNIT
00223B  2               
00223B  2               .IF .NOT STRIP_TRACE
00223B  2                               LDA TRACE_FLAG
00223B  2                               BEQ NO_TRACE37
00223B  2                               SAVE_REGS
00223B  2                               JSR PRTX
00223B  2                               JSR CROUT
00223B  2                               RESTORE_REGS
00223B  2               NO_TRACE37:
00223B  2               .ENDIF
00223B  2               
00223B  2  20 BE DE                     JSR CHKCOM
00223E  2  20 B7 00                     JSR CHRGOT                      ; WHAT ARE WE POINTING AT IN BASIC?
002241  2  C9 22                        CMP #QUOTE                      ; IS IT A STATIC STRING?
002243  2  D0 06                        BNE GETVAR
002245  2               
002245  2  20 B1 20                     JSR GETSTR                      ; GET THE STATIC STRING
002248  2  18                           CLC
002249  2  90 12                        BCC STORE2
00224B  2               
00224B  2               GETVAR:
00224B  2  20 DB 20                     JSR GETSTRVAR                   ; GET VAR$
00224E  2               
00224E  2  A5 9D                        LDA DSCTMP                      ; SAVE THE STRING DESCRIPTOR LOCATION
002250  2  8D 88 2F                     STA STR_DSC_LEN                 ; FOR LATER
002253  2  A5 9E                        LDA DSCTMP+1
002255  2  8D 89 2F                     STA STR_DSC_LO
002258  2  A5 9F                        LDA DSCTMP+2
00225A  2  8D 8A 2F                     STA STR_DSC_HI
00225D  2               
00225D  2               STORE2:
00225D  2  20 BE DE                     JSR CHKCOM
002260  2  20 F8 E6                     JSR GETBYT                    ; GET LENGTH REQUESTED
002263  2  8E 76 2D                     STX BUFLEN
002266  2               
002266  2  A0 00                        LDY #$00
002268  2  AD 88 2F                     LDA STR_DSC_LEN
00226B  2  99 9D 00                     STA DSCTMP,Y
00226E  2  C8                           INY
00226F  2  AD 89 2F                     LDA STR_DSC_LO
002272  2  99 9D 00                     STA DSCTMP,Y
002275  2  C8                           INY
002276  2  AD 8A 2F                     LDA STR_DSC_HI
002279  2  99 9D 00                     STA DSCTMP,Y
00227C  2               
00227C  2  AC 76 2D                     LDY BUFLEN
00227F  2               COPYBUF:
00227F  2  B1 9E                        LDA (DSCTMP+1),Y
002281  2  99 77 2D                     STA BUF,Y
002284  2  88                           DEY
002285  2  10 F8                        BPL COPYBUF
002287  2               
002287  2  AE 6E 2B                     LDX BASIC_UNIT
00228A  2  BD 80 2F                     LDA OPEN_LIST,X
00228D  2  C9 FD                        CMP #FN_NO_NETWORK
00228F  2  D0 1E                        BNE UNIT_OK5
002291  2               
002291  2  8D F9 31 08                  PRINT_STR NOT_OPENED_STR_ADDR
002295  2  48 8A 48 98  
002299  2  48 AD F9 31  
0022AC  2  4C C9 DE                     JMP SYNERR
0022AF  2               
0022AF  2               UNIT_OK5:
0022AF  2               ;****** TO DO *********
0022AF  2               ; BUF NOW CONTAINS DATA
0022AF  2               ; TO BE SENT
0022AF  2               ; CALL FUJINET
0022AF  2               ;**********************
0022AF  2  AA                           TAX
0022B0  2  20 CC 29                     JSR FN_WRITE
0022B3  2               
0022B3  2  60                           RTS
0022B4  2               
0022B4  2               ;************************************************************************
0022B4  2               ; &NCTRL UNIT,COMMAND, PAYLOAD$
0022B4  2               ; Sends a specific control message to the network device
0022B4  2               ; to do a special command. The payload for this command
0022B4  2               ; is specified as the very last parameter.
0022B4  2               ;************************************************************************
0022B4  2               NCTRL:
0022B4  2               
0022B4  2               .IF .NOT STRIP_TRACE
0022B4  2                               LDA TRACE_FLAG
0022B4  2                               BEQ NO_TRACE5
0022B4  2                               PRINT_STR NCTRL_STR_ADDR        ; "NCTRL"
0022B4  2               NO_TRACE5:
0022B4  2               .ENDIF
0022B4  2  20 F8 E6                     JSR GETBYT     ; GET UNIT
0022B7  2  8E 6E 2B                     STX BASIC_UNIT
0022BA  2               
0022BA  2               .IF .NOT STRIP_TRACE
0022BA  2                               LDA TRACE_FLAG
0022BA  2                               BEQ NO_TRACE38
0022BA  2                               SAVE_REGS
0022BA  2                               JSR PRTX
0022BA  2                               JSR CROUT
0022BA  2                               RESTORE_REGS
0022BA  2               NO_TRACE38:
0022BA  2               .ENDIF
0022BA  2               
0022BA  2  20 BE DE                     JSR CHKCOM
0022BD  2  20 F8 E6                     JSR GETBYT     ; GET COMMAND
0022C0  2  8E 73 2C                     STX COMMAND
0022C3  2               
0022C3  2  20 BE DE                     JSR CHKCOM
0022C6  2  20 B7 00                     JSR CHRGOT     ; WHAT ARE WE POINTING AT IN BASIC?
0022C9  2  C9 22                        CMP #QUOTE     ; IS IT A STATIC STRING?
0022CB  2  D0 06                        BNE GETVAR3
0022CD  2               
0022CD  2  20 B1 20                     JSR GETSTR     ; GET THE STATIC STRING
0022D0  2  18                           CLC
0022D1  2  90 03                        BCC STORE3
0022D3  2               
0022D3  2               GETVAR3:
0022D3  2  20 DB 20                     JSR GETSTRVAR
0022D6  2               
0022D6  2               STORE3:
0022D6  2               
0022D6  2               ; MOVE STRING TO PAYLOAD
0022D6  2  A4 9D                        LDY DSCTMP
0022D8  2               CPY2BUF:
0022D8  2  B1 9E                        LDA (DSCTMP+1),Y
0022DA  2  99 74 2C                     STA BASIC_PAYLOAD,Y
0022DD  2  88                           DEY
0022DE  2  10 F8                        BPL CPY2BUF
0022E0  2               
0022E0  2  AD 6E 2B                     LDA BASIC_UNIT
0022E3  2  AA                           TAX
0022E4  2  BD 80 2F                     LDA OPEN_LIST,X
0022E7  2  C9 FD                        CMP #FN_NO_NETWORK
0022E9  2  D0 1E                        BNE UNIT_OK4
0022EB  2               
0022EB  2  8D F9 31 08                  PRINT_STR NOT_OPENED_STR_ADDR
0022EF  2  48 8A 48 98  
0022F3  2  48 AD F9 31  
002306  2  4C C9 DE                     JMP SYNERR
002309  2               
002309  2               UNIT_OK4:
002309  2               ;****** TO DO *******
002309  2               ; UNIT, COMMAND ARE STORED
002309  2               ; AND PAYLOAD$ IS IN BASIC_PAYLOAD
002309  2               ; CALL FUJINET
002309  2               ;*******************
002309  2  60                           RTS
00230A  2               
00230A  2               ;************************************************************************
00230A  2               ; &NSTATUS UNIT,BW,CONNECTED,NERR
00230A  2               ; To get the status of network unit. BW = bytes waiting,
00230A  2               ; CONNECTED equals 1 if connect and NERR returns
00230A  2               ; the network error code
00230A  2               ;************************************************************************
00230A  2               NSTATUS:
00230A  2               
00230A  2               .IF .NOT STRIP_TRACE
00230A  2                               LDA TRACE_FLAG
00230A  2                               BEQ NO_TRACE6
00230A  2                               PRINT_STR NSTATUS_STR_ADDR
00230A  2               NO_TRACE6:
00230A  2               .ENDIF
00230A  2  20 F8 E6                     JSR GETBYT
00230D  2  8E 6E 2B                     STX BASIC_UNIT       ; STORE THE UNIT NUMBER
002310  2               
002310  2               .IF .NOT STRIP_TRACE
002310  2                               LDA TRACE_FLAG
002310  2                               BEQ NO_TRACE39
002310  2                               SAVE_REGS
002310  2                               JSR PRTX
002310  2                               JSR CROUT
002310  2                               RESTORE_REGS
002310  2               NO_TRACE39:
002310  2               .ENDIF
002310  2  20 BE DE                     JSR CHKCOM
002313  2               
002313  2  AE 6E 2B                     LDX BASIC_UNIT
002316  2  BD 80 2F                     LDA OPEN_LIST,X
002319  2  C9 FD                        CMP #FN_NO_NETWORK
00231B  2  D0 10                        BNE INFO
00231D  2               
00231D  2  A9 FF                        LDA #$FF                        ; USER HASN'T OPENED THE
00231F  2  8D 73 2D                     STA BW                          ; CONNECTION, SO JUST
002322  2  8D 74 2D                     STA BW+1                        ; SET EVERYTHING TO -1/255
002325  2               
002325  2  A9 00                        LDA #$00
002327  2  8D 75 2D                     STA CONNECT                     ; NO CONNECTION
00232A  2  18                           CLC
00232B  2  90 04                        BCC SAVE_INFO
00232D  2               
00232D  2                               ; we have a network
00232D  2               
00232D  2               INFO:
00232D  2  AA                           TAX
00232E  2  20 1C 2A                     JSR FN_STATUS           ; THIS SETS BW AND CONNECT
002331  2               
002331  2               SAVE_INFO:
002331  2                               ; SEND TO BASIC
002331  2  AD 74 2D                     LDA BW+1       ; NUMBER OF BYTES WAITING
002334  2  AC 73 2D                     LDY BW
002337  2  20 F1 20                     JSR WORDSAV    ; CONVERT TO FLOAT AND STORE IN BW VAR
00233A  2               
00233A  2  20 BE DE                     JSR CHKCOM
00233D  2               
00233D  2  AC 75 2D                     LDY CONNECT
002340  2  20 EF 20                     JSR BYTESAV    ; CONVERT TO FLOAT AND STORE IN CONNECT VAR
002343  2               
002343  2  20 BE DE                     JSR CHKCOM
002346  2               
002346  2  AE 6E 2B                     LDX BASIC_UNIT  ; "BASIC" UNIT, NOT THE ACTUAL UNIT
002349  2  BD 84 2F                     LDA NERR,X      ; GET THE ERROR FOR THIS BASIC UNIT
00234C  2  A8                           TAY
00234D  2  20 EF 20                     JSR BYTESAV    ; CONVERT TO FLOAT AND STORE IN NERR VAR
002350  2  60                           RTS
002351  2               
002351  2               ;************************************************************************
002351  2               ; &NEND
002351  2               ; Remove the fujiapple vector and
002351  2               ; put the original vector back
002351  2               ; Restore HIMEM if it hasn't been changed since we set it
002351  2               ;************************************************************************
002351  2               NEND:
002351  2               
002351  2               .IF .NOT STRIP_TRACE
002351  2                               LDA TRACE_FLAG
002351  2                               BEQ NO_TRACE7
002351  2                               PRINT_STR NEND_STR_ADDR
002351  2               NO_TRACE7:
002351  2               .ENDIF
002351  2               
002351  2               .IF RELOCATE
002351  2               
002351  2                               LDA HIMEM
002351  2                               CMP RELOC_NSTART
002351  2                               BNE NO_RESTORE
002351  2                               LDA HIMEM+1
002351  2                               CMP RELOC_NSTART+1
002351  2                               BNE NO_RESTORE
002351  2               
002351  2                               PRINT_STR RESTORE_HIMEM_STR_ADDR
002351  2               
002351  2                               LDA OLDHIMEM
002351  2                               STA HIMEM
002351  2                               LDA OLDHIMEM+1
002351  2                               STA HIMEM+1
002351  2               
002351  2                               JMP RESTORE_VECT
002351  2               
002351  2               NO_RESTORE:
002351  2                               PRINT_STR CANT_RESTORE_STR_ADDR
002351  2               
002351  2               .ENDIF
002351  2               
002351  2               ;*****************************************************
002351  2               RESTORE_VECT:
002351  2               
002351  2  AD 69 2B                     LDA PREVECT
002354  2  8D F5 03                     STA AMPVECT
002357  2  AD 6A 2B                     LDA PREVECT+1
00235A  2  8D F6 03                     STA AMPVECT+1
00235D  2  AD 6B 2B                     LDA PREVECT+2
002360  2  8D F7 03                     STA AMPVECT+2
002363  2               
002363  2  8D F9 31 08                  PRINT_STR EXTREMOVED_STR_ADDR      ; LET THE USER KNOW
002367  2  48 8A 48 98  
00236B  2  48 AD F9 31  
00237E  2  60                           RTS
00237F  2               
00237F  2               ;************************************************************************
00237F  2               ; &NLIST
00237F  2               ; &NLIST A$
00237F  2               ; Display devices
00237F  2               ;************************************************************************
00237F  2               NLIST:
00237F  2               
00237F  2               .IF .NOT STRIP_TRACE
00237F  2                               LDA TRACE_FLAG
00237F  2                               BEQ NO_TRACE8
00237F  2                               PRINT_STR NLIST_STR_ADDR
00237F  2               NO_TRACE8:
00237F  2               .ENDIF
00237F  2               
00237F  2  20 B7 00                     JSR CHRGOT
002382  2  F0 2A                        BEQ NO_ARG
002384  2  C9 3A                        CMP #':'
002386  2  F0 26                        BEQ NO_ARG
002388  2               
002388  2  20 74 2A                     JSR FN_LIST
00238B  2               
00238B  2  20 E3 DF                     JSR PTRGET                      ; GET THE STRING TO RECEIVED OUR DATA
00238E  2               
00238E  2  AD 7A 2E                     LDA STRLEN                      ; USE THE APPLESOFT ROUTINES TO
002391  2  20 D5 E3                     JSR STRINI                      ; CREATE A NEW STRING OF APPROPRIATE SIZE
002394  2               
002394  2  A0 00                        LDY #$00
002396  2  A5 9D                        LDA DSCTMP                      ; DESCRIPTOR FOR NEW STRING
002398  2  91 83                        STA (VARPTR),Y                  ; UPDATE THE LENGTH
00239A  2  C8                           INY
00239B  2  A5 9E                        LDA DSCTMP+1                    ; UPDATE THE LOCATION OF THE STRING
00239D  2  91 83                        STA (VARPTR),Y
00239F  2  C8                           INY
0023A0  2  A5 9F                        LDA DSCTMP+2
0023A2  2  91 83                        STA (VARPTR),Y
0023A4  2               
0023A4  2  AC 7B 2F                     LDY STRBUF_ADDR+1               ; MOVE OUR STRING BUFFER INTO THE
0023A7  2  AE 7A 2F                     LDX STRBUF_ADDR                 ; ACTUAL STRING
0023AA  2  20 E2 E5                     JSR MOVSTR                      ; COPY BUFFER TO STRING (VAR$)
0023AD  2               
0023AD  2  60                           RTS
0023AE  2               
0023AE  2               NO_ARG:
0023AE  2  20 F0 26                     JSR DISPLAY_SP_DEVICES
0023B1  2               
0023B1  2  60                           RTS
0023B2  2               
0023B2  2               
0023B2  2               .IF .NOT STRIP_TRACE
0023B2  2               ;************************************************************************
0023B2  2               ; &NTRACE
0023B2  2               ; Display debug messages
0023B2  2               ;************************************************************************
0023B2  2               NTRACE:
0023B2  2               
0023B2  2                               PRINT_STR FUJIAPPLE_VER_STR_ADDR
0023B2  2               
0023B2  2                               PRINT_STR NTRACE_STR_ADDR
0023B2  2               
0023B2  2                               LDA #$01
0023B2  2                               STA TRACE_FLAG
0023B2  2               
0023B2  2                               RTS
0023B2  2               
0023B2  2               ;************************************************************************
0023B2  2               ; &NNOTRACE
0023B2  2               ; Display debug messages
0023B2  2               ;************************************************************************
0023B2  2               NNOTRACE:
0023B2  2               
0023B2  2                               LDA #$00
0023B2  2                               STA TRACE_FLAG
0023B2  2               
0023B2  2                               RTS
0023B2  2               .ENDIF
0023B2  2               
0023B2  2               ;************************************************************************
0023B2  2               ; &NACCEPT UNIT
0023B2  2               ; Accept the incoming connection
0023B2  2               ;************************************************************************
0023B2  2               NACCEPT:
0023B2  2               .IF .NOT STRIP_TRACE
0023B2  2                               LDA TRACE_FLAG
0023B2  2                               BEQ NO_TRACE43
0023B2  2                               PRINT_STR NACCEPT_STR_ADDR       ; "NACCEPT"
0023B2  2               
0023B2  2               NO_TRACE43:
0023B2  2               .ENDIF
0023B2  2  20 F8 E6                     JSR   GETBYT                    ; GET THE UNIT
0023B5  2  8E 6E 2B                     STX   BASIC_UNIT
0023B8  2               
0023B8  2               .IF .NOT STRIP_TRACE
0023B8  2                               LDA TRACE_FLAG
0023B8  2                               BEQ NO_TRACE45
0023B8  2               
0023B8  2                               SAVE_REGS
0023B8  2                               JSR PRTX
0023B8  2                               JSR CROUT
0023B8  2                               RESTORE_REGS
0023B8  2               NO_TRACE45:
0023B8  2               .ENDIF
0023B8  2               
0023B8  2  AE 6E 2B                     LDX BASIC_UNIT
0023BB  2  BD 80 2F                     LDA OPEN_LIST, X        ; THIS IS THE ACTUAL UNIT NUMBER
0023BE  2  C9 FD                        CMP #FN_NO_NETWORK      ; TRYING TO ACCEPT SOMETHING THAT IS NOT ACTUALLY OPEN
0023C0  2  F0 04                        BEQ ACCEPT_FAILED
0023C2  2  AA                           TAX
0023C3  2  20 D0 2A                     JSR FN_ACCEPT
0023C6  2               
0023C6  2               ACCEPT_FAILED:
0023C6  2  60                           RTS
0023C7  2               
0023C7  2               ;************************************************************************
0023C7  2               ; &NINPUT UNIT,VAR$
0023C7  2               ;   Reads until either Carriage Return is received or 255 characters
0023C7  2               ; are received
0023C7  2               ;************************************************************************
0023C7  2               NINPUT:
0023C7  2               
0023C7  2               .IF .NOT STRIP_TRACE
0023C7  2                               LDA TRACE_FLAG
0023C7  2                               BEQ NO_TRACE44
0023C7  2                               PRINT_STR NINPUT_STR_ADDR       ; "NINPUT"
0023C7  2               NO_TRACE44:
0023C7  2               .ENDIF
0023C7  2  20 F8 E6                     JSR GETBYT                      ; GET UNIT
0023CA  2  8E 6E 2B                     STX BASIC_UNIT
0023CD  2               
0023CD  2               .IF .NOT STRIP_TRACE
0023CD  2                               LDA TRACE_FLAG
0023CD  2                               BEQ NO_TRACE46
0023CD  2                               SAVE_REGS
0023CD  2                               JSR PRTX
0023CD  2                               JSR CROUT
0023CD  2                               RESTORE_REGS
0023CD  2               NO_TRACE46:
0023CD  2               .ENDIF
0023CD  2               
0023CD  2  20 BE DE                     JSR CHKCOM
0023D0  2               
0023D0  2  20 E3 DF                     JSR PTRGET                      ; GET THE STRING TO RECEIVED OUR DATA
0023D3  2               
0023D3  2               ;Returns the address of variable contents in A-reg (high) and Y-reg (low),
0023D3  2               ;as well as in VARPTR at $83.84. If a variable does not exist, it
0023D3  2               ;is created. TXTPTR points to the next character.
0023D3  2               
0023D3  2  A5 83                        LDA VARPTR                      ; SAVE THE STRING DESCRIPTOR LOCATION
0023D5  2  8D 88 2F                     STA STR_DSC_LEN                 ; FOR LATER
0023D8  2  A5 84                        LDA VARPTR+1
0023DA  2  8C 89 2F                     STY STR_DSC_LO
0023DD  2  A5 85                        LDA VARPTR+2
0023DF  2  8D 8A 2F                     STA STR_DSC_HI
0023E2  2               
0023E2  2  AE 6E 2B                     LDX BASIC_UNIT
0023E5  2  BD 80 2F                     LDA OPEN_LIST,X
0023E8  2  C9 FD                        CMP #FN_NO_NETWORK
0023EA  2  D0 1E                        BNE UNIT_OK6
0023EC  2               
0023EC  2  8D F9 31 08                  PRINT_STR NOT_OPENED_STR_ADDR
0023F0  2  48 8A 48 98  
0023F4  2  48 AD F9 31  
002407  2  4C C9 DE                     JMP SYNERR
00240A  2               
00240A  2               UNIT_OK6:
00240A  2  AA                           TAX
00240B  2  20 EF 2A                     JSR FN_INPUT
00240E  2               
00240E  2  AD 88 2F                     LDA STR_DSC_LEN                 ; RESTORE THE STRING DESCRIPTOR
002411  2  85 83                        STA VARPTR                      ; THAT WE SAVED EARLIER SO WE
002413  2  AD 89 2F                     LDA STR_DSC_LO
002416  2  85 84                        STA VARPTR+1
002418  2  AD 8A 2F                     LDA STR_DSC_HI
00241B  2  85 85                        STA VARPTR+2
00241D  2               
00241D  2  AD 5A 35                     LDA FN_BUFFER_SIZE              ; THIS IS THE ACTUAL NUMBER OF CHARS WE READ
002420  2  20 D5 E3                     JSR STRINI                      ; CREATE NEW STRING OF LENGTH A
002423  2               
002423  2  A0 00                        LDY #$00
002425  2  A5 9D                        LDA DSCTMP                      ; DESCRIPTOR FOR NEW STRING
002427  2  91 83                        STA (VARPTR),Y                  ; UPDATE THE LENGTH
002429  2  C8                           INY
00242A  2  A5 9E                        LDA DSCTMP+1                    ; UPDATE THE LOCATION OF THE STRING
00242C  2  91 83                        STA (VARPTR),Y
00242E  2  C8                           INY
00242F  2  A5 9F                        LDA DSCTMP+2
002431  2  91 83                        STA (VARPTR),Y
002433  2               
002433  2  AD 5A 35                     LDA FN_BUFFER_SIZE              ; USE THE APPLESOFT ROUTINES TO
002436  2  AC 5B 36                     LDY FN_BUFFER_ADDR+1            ; MOVE THE PAYLOAD INTO THE
002439  2  AE 5A 36                     LDX FN_BUFFER_ADDR              ; ACTUAL STRING
00243C  2  20 E2 E5                     JSR MOVSTR                      ; COPY BUFFER TO STRING (VAR$)
00243F  2               
00243F  2  60                           RTS
002440  2               
002440  1                               .include "SMARTPORTCMDS.S"
002440  2               ;*****************************************************
002440  2               ; Smartport Commands
002440  2               ;
002440  2               ; Generic smartport commands for use with Fujinet
002440  2               ; By Norman Davie
002440  2               ;
002440  2               ; NOTE: Relocation code does not expect data to be mixed
002440  2               ;       with code.  As a result, we need to put NOPs where
002440  2               ;       CMDLIST would be then fill it later
002440  2               
002440  2               
002440  2                       .include "APPLEEQU.S"
002440  3               .IF .NOT .DEFINED(AMPVECT)
002440  3               
002440  3               SPACE                   =   $A0         ; SPACE CHARACTER FOR COUT
002440  3               COLON                   =   ':'+$80     ; COLON CHARACTER FOR COUT
002440  3               
002440  3               FRESPC                  =   $71         ; Applesoft pointer at the string storage area, used when a new string is created.
002440  3               AMPVECT                 =   $03F5       ; AMPERSAND VECTOR FOR APPLESOFT
002440  3               GETBYT                  =   $E6F8       ; EVAL BYTE -> X
002440  3               CHKCOM                  =   $DEBE       ; CHECK FOR COMMA
002440  3               FRMNUM                  =   $DD67       ; EVALUATE NUMERIC EXPRESSION
002440  3               GETADR                  =   $E752       ; CONVERT FAC TO INT (MAX 65535)
002440  3               PTRGET                  =   $DFE3       ; FIND NAMED VARIABLE (ADDRESS IN VARPTR)
002440  3               STRINI                  =   $E3D5       ; CREATE NEW STRING SPACE
002440  3               MOVSTR                  =   $E5E2       ; MOVE STRING INTO NEW SPACE A=LEN Y-HI SRC X=LO SRC, DESC in FRESPC
002440  3               MOVFM                   =   $EAF9       ; UNPACK (Y,A) TO FAC
002440  3               MOVMF                   =   $EB2B       ; PACK FAC TO (Y,A)
002440  3               GIVAYF                  =   $E2F2       ; CONVERT SIGNED WORD (A,Y) TO FLOAT
002440  3               SNGFLT                  =   $E301       ; CONVERT UNSIGNED BYTE Y TO FLOAT
002440  3               FLOAT                   =   $EB90       ; CONVERT SIGNED BYTE A TO FLOAT
002440  3               COUT                    =   $FDED       ; DISPLAY A AS CHAR ON SCREEN
002440  3               CROUT                   =   $FD8E       ; END OF LINE (CARRIAGE RETURN)
002440  3               STROUT                  =   $DB3A       ; PRINTS STRING POINT BY Y (HI) AND A(LO)
002440  3               CONINT                  =   $E6FB       ; CONVERT FAC TO INT (MAX 255)
002440  3               SYNERR                  =   $DEC9       ; ?SYNTAX ERROR
002440  3               PRTYX                   =   $F940       ; PRINT Y AND X AS HEX
002440  3               PRTAX                   =   $F941       ; PRINT A AND X AS HEX
002440  3               PRTX                    =   $F944       ; PRINT X AS HEX
002440  3               DOSWARM                 =   $03D0       ; CALL TO EXIT BRUN'D PROGRAM
002440  3               TXTPTR                  =   $B8         ; WHERE WE ARE IN THE BASIC FILE
002440  3               VARPTR                  =   $83         ; POINTER TO OUR VARIABLE
002440  3               DSCTMP                  =   $9D         ; TEMPORARY DESCRIPTION STORAGE
002440  3               CHRGET                  =   $B1         ; ADVANCE TXTPTR, GET CHAR INTO A
002440  3               CHRGOT                  =   $B7         ; CHARACTER ALREADY PROCESSED BY BASIC
002440  3               HIMEM                   =   $73         ; APPLESOFT HIMEM
002440  3               LOMEM                   =   $4A         ; INTEGER BASIC LOMEM
002440  3               KYBD                    =   $C000       ; KEYBOARD LOCATION
002440  3               STROBE                  =   $C010       ;
002440  3               
002440  3               TOK_READ                =       135     ; APPLESOFT TOKEN FOR READ
002440  3               TOK_AT                  =       197     ; APPLESOFT TOKEN FOR AT
002440  3               TOK_END                 =       128     ; APPLESOFT TOKEN FOR END
002440  3               QUOTE                   =       $22     ; ASCII QUOTE CHARACTER
002440  3               TOK_LIST                =       188     ; APPLESOFT TOKEN FOR LIST
002440  3               TOK_TRACE               =       155     ; APPLESOFT TOKEN FOR TRACE
002440  3               TOK_NOTRACE             =       156     ; APPLESOFT TOKEN FOR NOTRACE
002440  3               TOK_INPUT               =       132     ; APPLESOFT TOKEN FOR INPUT
002440  3               
002440  3               
002440  3               NEXT_WITHOUT_FOR        =   0
002440  3               SYNTAX_ERROR            =  16
002440  3               RETURN_WITHOUT_GOSUB    =  22
002440  3               OUT_OF_DATA             =  42
002440  3               ILLEGAL_QUANTITY_ERROR  =  53
002440  3               OVERFLOW                =  69
002440  3               OUT_OF_MEMORY           =  77
002440  3               UNDEFINED_STATEMENT     =  90
002440  3               BAD_SUBSCRIPT           = 107
002440  3               REDIMINSIONED_ARRAY     = 120
002440  3               DIVISION_BY_ZERO        = 133
002440  3               TYPE_MISMATCH           = 163
002440  3               STRING_TOO_LONG         = 176
002440  3               FORMULA_TOO_COMPLEX     = 191
002440  3               UNDEFINED_FUNCTION      = 224
002440  3               BAD_RESPONSE_TO_INPUT   = 254
002440  3               CTRL_C_INTERRUPT        = 255
002440  3               
002440  3               APPLESOFT_ERROR         = $D412
002440  3               
002440  3               
002440  3               .ENDIF
002440  3               
002440  2                       .include "ZEROPAGE.S"
002440  3               ;*****************************************************
002440  3               ; ZEROPAGE
002440  3               ; "Safe" locations to use in zero page
002440  3               ;
002440  3               ; define APPLEII for Apple II zero page
002440  3               ; define ATARI   for Atari 8-bit zero page
002440  3               ;
002440  3               ; By Norman Davie
002440  3               
002440  3               .IF .NOT .DEFINED(ZP1)
002440  3               
002440  3               .IF .DEFINED(APPLEII)
002440  3               ZP1             =	$EB
002440  3               ZP1_LO	        =	$EB
002440  3               ZP1_HI	        = 	$EC
002440  3               
002440  3               ZP2             =	$ED
002440  3               ZP2_LO	        =	$ED
002440  3               ZP2_HI          =	$EE
002440  3               
002440  3               ZP3             =	$FA
002440  3               ZP3_LO          =	$FA
002440  3               ZP3_HI	   	    =	$FB
002440  3               
002440  3               ZP4	            =	$FC
002440  3               ZP4_LO		    =	$FC
002440  3               ZP4_HI		    =	$FD
002440  3               
002440  3               ZP5             =	$EF
002440  3               
002440  3               ZP_BLOCK_SIZE   = ZP4_HI - ZP1 + 1
002440  3               
002440  3               .ENDIF
002440  3               
002440  3               .IF .DEFINED(ATARI)
002440  3               
002440  3               ZP1             =	$A2
002440  3               ZP1_LO	        =	$A2
002440  3               ZP1_HI	        = 	$A3
002440  3               
002440  3               ZP2             =	$A4
002440  3               ZP2_LO		    =	$A4
002440  3               ZP2_HI		    =	$A5
002440  3               
002440  3               ZP3             =	$A6
002440  3               ZP3_LO		    =	$A6
002440  3               ZP3_HI		    =	$A7
002440  3               
002440  3               ZP4             =	$A8
002440  3               ZP4_LO		    =	$A8
002440  3               ZP4_HI		    =	$A9
002440  3               
002440  3               ZP5		    =	$AA
002440  3               .ENDIF
002440  3               
002440  3               
002440  3               .ENDIF
002440  3               
002440  2                       .include "MACROS.S"
002440  3               .IF .NOT .DEFINED(MACROS)
002440  3               
002440  3               MACROS=1
002440  3               
002440  3               .MACRO SAVE_REGS
002440  3                       STA MACRO_A
002440  3                       PHP
002440  3                       PHA
002440  3                       TXA
002440  3                       PHA
002440  3                       TYA
002440  3                       PHA
002440  3                       LDA MACRO_A
002440  3               .ENDMACRO
002440  3               
002440  3               .MACRO RESTORE_REGS
002440  3                       PLA
002440  3                       TAY
002440  3                       PLA
002440  3                       TAX
002440  3                       PLA
002440  3                       PLP
002440  3               .ENDMACRO
002440  3               
002440  3               .MACRO PRINT_STR STR
002440  3                       SAVE_REGS
002440  3                       LDA STR
002440  3                       LDY STR+1
002440  3                       JSR STROUT
002440  3                       RESTORE_REGS
002440  3               .ENDMACRO
002440  3               
002440  3               .MACRO PRINT_OUT STR
002440  3                       SAVE_REGS
002440  3                       LDA #<STR
002440  3                       LDY #>STR
002440  3                       JSR STROUT
002440  3                       RESTORE_REGS
002440  3               .ENDMACRO
002440  3               
002440  3               
002440  3               .ENDIF
002440  3               
002440  2               
002440  2               SP_ERR                  =       $FE
002440  2               
002440  2               SP_CMD_STATUS           =       $00
002440  2               SP_CMD_READ_BLOCK       =       $01
002440  2               SP_CMD_WRITE_BLOCK      =       $02
002440  2               SP_CMD_FORMAT           =       $03
002440  2               SP_CMD_CONTROL          =       $04
002440  2               SP_CMD_INIT             =       $05
002440  2               SP_CMD_OPEN             =       $06
002440  2               SP_CMD_CLOSE            =       $07
002440  2               SP_CMD_READ             =       $08
002440  2               SP_CMD_WRITE            =       $09
002440  2               
002440  2               SP_STATUS_CODE          =       $00     ; RETURN DEVICE STATUS
002440  2               SP_STATUS_DIB           =       $03     ; RETURN DEVICE INFORMATION BLOCK
002440  2               SP_STATUS_DIB_EXTRA     =       $04     ; RETURN DEVICE INFORMATION BLOCK EXTRA
002440  2               SP_STATUS_LAST_ERROR    =       $05
002440  2               SP_STATUS_RETURN_DATA   =       $06     ; RETURN BYTES/BLOCK PARAMETER FOR DEVICE
002440  2               
002440  2               SP_ERROR_OK             =       $00
002440  2               SP_ERROR_BAD_CMD        =       $01
002440  2               SP_ERROR_BAD_PCNT       =       $02     ; BAD CALL PARAMETER COUNT
002440  2               SP_ERROR_BUS_ERR        =       $06     ; bus error in IWM chip
002440  2               SP_ERROR_BAD_UNIT       =       $11     ; UNIT NUMBER $00 WAS USED
002440  2               SP_ERROR_BAD_CTRL       =       $21     ; CTRL OR STATUS CODE WAS NOT SUPPORTED
002440  2               SP_ERROR_BAD_CTRL_PARM  =       $22     ; CTRL PARAMTER LIST CONTAINS INVALID INFO
002440  2               SP_ERROR_IO_ERROR       =       $27     ; CAN'T ACCESS DEVICE OR DEVICE ERROR
002440  2               SP_ERROR_NO_DRIVE       =       $28     ; DEVICE IS NOT CONNECTED
002440  2               SP_ERROR_NO_WRITE       =       $2B     ; MEDIUM IS WRITE PROTECTED
002440  2               SP_ERROR_BAD_BLOCK      =       $2D     ; BLOCK NUMBER IS OUTSIDE OF RANGE
002440  2               SP_ERROR_DISK_SW        =       $2E     ; DISK SWITCH TOOK PLACE
002440  2               SP_ERROR_OFFLINE        =       $2F     ; DEVICE OFFLINE OR NO DISK IN DRIVE
002440  2               SP_ERROR_DEV_SPEC0      =       $30     ; DEVICE SPECIFIC ERRORS
002440  2               SP_ERROR_DEV_SPECF      =       $3F     ; DEVICE SPECIFIC ERRORS
002440  2               ;SP_ERROR_RESERVED $40-$4F
002440  2               SP_ERROR_NON_FATAL50    =       $50     ; DEVICE SPECIFIC WARNING
002440  2               SP_ERROR_NON_FATAL7F    =       $7F     ; DEVICE SPECIFIC WARNING
002440  2               
002440  2               SP_INIT_PARAM_COUNT     =       3
002440  2               SP_OPEN_PARAM_COUNT     =       3
002440  2               SP_CLOSE_PARAM_COUNT    =       3
002440  2               SP_READ_PARAM_COUNT     =       4
002440  2               SP_WRITE_PARAM_COUNT    =       4
002440  2               SP_STATUS_PARAM_COUNT   =       3
002440  2               SP_CONTROL_PARAM_COUNT  =       3
002440  2               
002440  2               
002440  2               SP_ERROR_NOT_FOUND      =       SP_ERROR_NON_FATAL50
002440  2               
002440  2               
002440  2               SP_STATUS_FLAG_BLOCK_DEVICE     = %10000000
002440  2               SP_STATUS_FLAG_WRITE_ALLOWED    = %01000000
002440  2               SP_STATUS_FLAG_READ_ALLOWED     = %00100000
002440  2               SP_STATUS_FLAG_DEVICE_ONLINE    = %00010000
002440  2               SP_STATUS_FLAG_FORMAT_ALLOWED   = %00001000
002440  2               SP_STATUS_FLAG_WRITE_PROTECTED  = %00000100
002440  2               SP_STATUS_FLAG_DEVICE_INTERRUPT = %00000010
002440  2               SP_STATUS_FLAG_DEVICE_OPEN      = %00000001
002440  2               
002440  2               
002440  2               SLOT_ADDR		=	ZP2
002440  2               SLOT_ADDR_LO	    	=	ZP2_LO
002440  2               SLOT_ADDR_HI		=	ZP2_HI
002440  2               
002440  2               
002440  2               CLEAR_CMD_LIST:
002440  2  A9 EA                        LDA #$EA
002442  2               
002442  2  8D AC 25                     STA cmd_list0
002445  2  8D BD 25                     STA cmd_list1
002448  2  8D DD 25                     STA cmd_list2
00244B  2  8D 02 26                     STA cmd_list3
00244E  2  8D 37 26                     STA cmd_list4
002451  2  8D 61 26                     STA cmd_list5
002454  2               
002454  2  8D AD 25                     STA cmd_list0+1
002457  2  8D BE 25                     STA cmd_list1+1
00245A  2  8D DE 25                     STA cmd_list2+1
00245D  2  8D 03 26                     STA cmd_list3+1
002460  2  8D 38 26                     STA cmd_list4+1
002463  2  8D 62 26                     STA cmd_list5+1
002466  2               
002466  2  8D AB 25                     STA cmd_open
002469  2  8D BC 25                     STA cmd_close
00246C  2  8D DC 25                     STA cmd_control
00246F  2  8D 01 26                     STA cmd_read
002472  2  8D 36 26                     STA cmd_write
002475  2  8D 60 26                     STA cmd_status
002478  2               
002478  2  60                           RTS
002479  2               
002479  2               
002479  2               FILL_CMD_LIST:
002479  2  AD 4A 32                     LDA CMD_LIST_ADDR
00247C  2  8D AC 25                     STA cmd_list0
00247F  2  8D BD 25                     STA cmd_list1
002482  2  8D DD 25                     STA cmd_list2
002485  2  8D 02 26                     STA cmd_list3
002488  2  8D 37 26                     STA cmd_list4
00248B  2  8D 61 26                     STA cmd_list5
00248E  2               
00248E  2  AD 4B 32                     LDA CMD_LIST_ADDR+1
002491  2  8D AD 25                     STA cmd_list0+1
002494  2  8D BE 25                     STA cmd_list1+1
002497  2  8D DE 25                     STA cmd_list2+1
00249A  2  8D 03 26                     STA cmd_list3+1
00249D  2  8D 38 26                     STA cmd_list4+1
0024A0  2  8D 62 26                     STA cmd_list5+1
0024A3  2               
0024A3  2  A9 06                        LDA #SP_CMD_OPEN
0024A5  2  8D AB 25                     STA cmd_open
0024A8  2  A9 07                        LDA #SP_CMD_CLOSE
0024AA  2  8D BC 25                     STA cmd_close
0024AD  2  A9 04                        LDA #SP_CMD_CONTROL
0024AF  2  8D DC 25                     STA cmd_control
0024B2  2  A9 08                        LDA #SP_CMD_READ
0024B4  2  8D 01 26                     STA cmd_read
0024B7  2  A9 09                        LDA #SP_CMD_WRITE
0024B9  2  8D 36 26                     STA cmd_write
0024BC  2  A9 00                        LDA #SP_CMD_STATUS
0024BE  2  8D 60 26                     STA cmd_status
0024C1  2               
0024C1  2  60                           RTS
0024C2  2               
0024C2  2               ;*******************************
0024C2  2               ; WIPE_PAYLOAD
0024C2  2               ;   Clear the contents of the payload
0024C2  2               ;**********************************
0024C2  2               
0024C2  2               WIPE_PAYLOAD:
0024C2  2  8D F9 31 08                  SAVE_REGS
0024C6  2  48 8A 48 98  
0024CA  2  48 AD F9 31  
0024CE  2               
0024CE  2  A9 A5                        LDA #$A5
0024D0  2               
0024D0  2  A2 00                        LDX #$00
0024D2  2               CLR:
0024D2  2  9D 50 32                     STA SP_PAYLOAD+4,X
0024D5  2  E8                           INX
0024D6  2  E0 10                        CPX #16
0024D8  2  D0 F8                        BNE CLR
0024DA  2               
0024DA  2  68 A8 68 AA                  RESTORE_REGS
0024DE  2  68 28        
0024E0  2  60                           RTS
0024E1  2               
0024E1  2               ;*******************************
0024E1  2               ; PRINT_SP_PAYLOAD
0024E1  2               ;   Display the ASCII contents
0024E1  2               ; of the payload buffer.  Buffer
0024E1  2               ; is NULL terminated and Length is
0024E1  2               ; not stored at start of buffer.
0024E1  2               ;**********************************
0024E1  2               PRINT_SP_PAYLOAD:
0024E1  2  8D F9 31 08                  SAVE_REGS
0024E5  2  48 8A 48 98  
0024E9  2  48 AD F9 31  
0024ED  2               
0024ED  2  A2 00                        LDX #$00
0024EF  2               
0024EF  2               PPAYLOAD:
0024EF  2  BD 50 32                     LDA SP_PAYLOAD+4,X      ; STRING
0024F2  2  09 80                        ORA #$80
0024F4  2  20 ED FD                     JSR COUT
0024F7  2  E8                           INX
0024F8  2  18                           CLC              ; "NULL" TERMINATED (we just or'd this)
0024F9  2  90 F4                        BCC PPAYLOAD
0024FB  2               
0024FB  2  68 A8 68 AA                  RESTORE_REGS
0024FF  2  68 28        
002501  2               END_PAYLOAD:
002501  2  60                           RTS
002502  2               
002502  2               
002502  2               ;*******************************
002502  2               ; PRINT_SP_PAYLOAD_STR
002502  2               ;   Display the ASCII contents
002502  2               ; of the payload buffer.  Buffer
002502  2               ; length is the first byte at the
002502  2               ; start of buffer.
002502  2               ;**********************************
002502  2               PRINT_SP_PAYLOAD_STR:
002502  2  8D F9 31 08                  SAVE_REGS
002506  2  48 8A 48 98  
00250A  2  48 AD F9 31  
00250E  2               
00250E  2  A2 00                        LDX #$00
002510  2               
002510  2               PPAYLOAD2:
002510  2  BD 51 32                     LDA SP_PAYLOAD+5,X      ; STRING
002513  2  09 80                        ORA #$80
002515  2  20 ED FD                     JSR COUT
002518  2  E8                           INX
002519  2  EC 50 32                     CPX SP_PAYLOAD+4        ; LENGTH OF STRING
00251C  2  D0 F2                        BNE PPAYLOAD2
00251E  2               
00251E  2  68 A8 68 AA                  RESTORE_REGS
002522  2  68 28        
002524  2  60                           RTS
002525  2               
002525  2               .IF .NOT STRIP_TRACE
002525  2               
002525  2               
002525  2               ;*******************************
002525  2               ; DUMP_SP_PAYLOAD_HEX
002525  2               ;   Display the HEX contents
002525  2               ; of the payload buffer
002525  2               ;**********************************
002525  2               
002525  2               DUMP_SP_PAYLOAD_HEX:
002525  2                               SAVE_REGS
002525  2               
002525  2                               PRINT_STR PAYLOAD_STR_ADDR
002525  2               
002525  2                               LDX #$00
002525  2               PPAYLOAD4:
002525  2                               TXA
002525  2                               PHA                     ; SAVE X PUSH +1
002525  2               
002525  2                               LDA SP_PAYLOAD,X      ; STRING
002525  2                               TAX
002525  2                               JSR PRINT_X
002525  2               
002525  2                               PLA                     ; RESTORE X -1
002525  2                               TAX
002525  2               
002525  2                               INX
002525  2                               CPX #10
002525  2                               BNE PPAYLOAD4
002525  2               
002525  2                               RESTORE_REGS
002525  2                               RTS
002525  2               
002525  2               
002525  2               
002525  2               ;*******************************
002525  2               ; DUMP_SP_PAYLOAD
002525  2               ;   Display the HEX and ASCII contents
002525  2               ; of the payload buffer
002525  2               ;**********************************
002525  2               DUMP_SP_PAYLOAD:
002525  2                               JSR DUMP_SP_PAYLOAD_HEX
002525  2               
002525  2                               SAVE_REGS
002525  2               
002525  2                               PRINT_STR PAYLOAD_STR_ADDR
002525  2                               LDX #$00
002525  2               PPAYLOAD1:
002525  2                               TXA
002525  2                               PHA                     ; SAVE OUR X
002525  2               
002525  2                               LDA SP_PAYLOAD,X        ; STRING
002525  2                               CMP #$20
002525  2                               BPL PRINT_IT
002525  2                               LDA #'.'                ; NON-PRINTABLE CHARACTERS ARE SHOWN AN '.'
002525  2               PRINT_IT:
002525  2                               ORA #$80                ; MAKE SURE THE HIGH BIT IS
002525  2                               JSR COUT                ; SET SO IT DOESN'T LOOK INVERSE
002525  2                               LDA #SPACE
002525  2                               JSR COUT                ; TWO SPACES
002525  2                               JSR COUT
002525  2               
002525  2                               PLA                     ; RESTORE OUR X
002525  2                               TAX
002525  2                               INX
002525  2                               CPX SP_PAYLOAD
002525  2                               BNE PPAYLOAD1
002525  2               
002525  2                               JSR CROUT
002525  2               
002525  2                               RESTORE_REGS
002525  2               
002525  2                               RTS
002525  2               
002525  2               ;*******************************
002525  2               ; DUMP_CMD_LIST
002525  2               ;   Display the CMD_LIST in HEX
002525  2               ;**********************************
002525  2               
002525  2               DUMP_CMD_LIST:
002525  2                               SAVE_REGS
002525  2               
002525  2                               PRINT_STR CMD_LIST_STR_ADDR
002525  2               
002525  2                               LDX #$00
002525  2               CMDLIST0:
002525  2                               TXA
002525  2                               PHA                     ; SAVE X PUSH +1
002525  2               
002525  2                               LDA CMD_LIST,X      ; STRING
002525  2                               TAX
002525  2                               JSR PRINT_X
002525  2               
002525  2                               PLA                     ; RESTORE X -1
002525  2                               TAX
002525  2               
002525  2                               INX
002525  2                               CPX #7
002525  2                               BNE CMDLIST0
002525  2               
002525  2                               RESTORE_REGS
002525  2               
002525  2                               RTS
002525  2               
002525  2               
002525  2               ;**********************************
002525  2               
002525  2               DUMP_SP_PAYLOAD_STR:
002525  2                               SAVE_REGS
002525  2               
002525  2                               PRINT_STR LEN_STR_ADDR
002525  2               
002525  2                               LDA #'['
002525  2                               JSR COUT
002525  2                               LDX SP_PAYLOAD+4
002525  2                               JSR PRTX
002525  2                               LDA #']'
002525  2                               JSR COUT
002525  2               
002525  2               
002525  2                               LDX #$00
002525  2               PPAYLOAD3:
002525  2                               TXA
002525  2                               PHA
002525  2                               LDA SP_PAYLOAD+5,X      ; STRING
002525  2                               ORA #$80
002525  2                               JSR COUT
002525  2                               PLA
002525  2                               TAX
002525  2                               INX
002525  2                               CPX SP_PAYLOAD+4
002525  2                               BNE PPAYLOAD3
002525  2               
002525  2                               JSR CROUT
002525  2                               RESTORE_REGS
002525  2               
002525  2                               RTS
002525  2               
002525  2               .ENDIF
002525  2               
002525  2               
002525  2               .IF USE_SP
002525  2               
002525  2               ;*******************************
002525  2               ; FIND_SMARTPORT_SLOT
002525  2               ; INPUT:
002525  2               ;   NONE
002525  2               ;***
002525  2               ; RETURN
002525  2               ;   A = $FF - NO SMARTPORT FOUND
002525  2               ;   A = $CX - WHERE X IS THE SLOT
002525  2               ;**********************************
002525  2               
002525  2               FIND_SMARTPORT_SLOT:
002525  2               
002525  2               .IF .NOT STRIP_TRACE
002525  2               .IF EXT2_TRACE
002525  2                               SAVE_REGS
002525  2                               LDA TRACE_FLAG
002525  2                               BEQ NO_TRACE10
002525  2                               PRINT_STR FIND_SMARTPORT_SLOT_STR_ADDR
002525  2               
002525  2                NO_TRACE10:
002525  2                               RESTORE_REGS
002525  2               .ENDIF
002525  2               .ENDIF
002525  2               
002525  2  A9 C7                        LDA     #$C7            ; START AT SLOT 7 ($C700)
002527  2  85 EE                        STA     SLOT_ADDR_HI
002529  2  A9 00                        LDA     #$00
00252B  2  85 ED                        STA     SLOT_ADDR_LO
00252D  2               
00252D  2               SCAN:
00252D  2  A0 01                        LDY #$01                ; LOOK AT BYTES 1,3,5,AND 7
00252F  2  A2 00                        LDX #$00
002531  2               
002531  2               NEXT_MATCH:
002531  2  B1 ED                        LDA (SLOT_ADDR),Y       ; COMPARE TO THE MAGIC NUMBERS
002533  2  DD 56 35                     CMP SMARTPORT_ID,X      ;
002536  2  D0 09                        BNE NEXT_SLOT           ; NOT THE SAME, SO GO TO NEXT SLOT
002538  2               
002538  2  C8                           INY                     ; PREPARE TO CHECK THE NEXT NUMBER
002539  2  C8                           INY
00253A  2  E8                           INX                     ; POINTER TO NEXT NUMBER TO CHECK
00253B  2  E0 04                        CPX #$04                ; HAVE WE COMPARED ALL 4 NUMBERS?
00253D  2  F0 0D                        BEQ FOUND               ; YES, WE'VE FOUND IT
00253F  2  D0 F0                        BNE NEXT_MATCH          ; MORE TO MATCH
002541  2               
002541  2               NEXT_SLOT:
002541  2  A6 EE                        LDX SLOT_ADDR_HI        ; MOVE TO THE NEXT LOWER SLOT
002543  2  CA                           DEX                     ; $C700 -> $C600
002544  2  86 EE                        STX SLOT_ADDR_HI
002546  2  E0 C0                        CPX #$C0                ; HAVE WE GONE BELOW SLOT 1?
002548  2  F0 06                        BEQ NOT_FOUND           ; WE'RE DONE
00254A  2  D0 E1                        BNE SCAN                ; CONTINUE SCANNING
00254C  2               
00254C  2               FOUND:
00254C  2  8A                           TXA
00254D  2  18                           CLC
00254E  2  90 06                        BCC SLOT_FIND_DONE
002550  2               
002550  2               NOT_FOUND:
002550  2  A9 FF                        LDA #$FF                ; WE DIDN'T FIND IT
002552  2  85 ED                        STA SLOT_ADDR_LO
002554  2  85 EE                        STA SLOT_ADDR_HI
002556  2               
002556  2               SLOT_FIND_DONE:
002556  2               
002556  2               .IF .NOT STRIP_TRACE
002556  2               .IF EXT2_TRACE
002556  2                               SAVE_REGS
002556  2                               LDA TRACE_FLAG
002556  2                               BEQ NO_TRACE28
002556  2                               LDA SLOT_ADDR_HI
002556  2                               LDX SLOT_ADDR_LO
002556  2                               JSR PRTAX
002556  2                               JSR CROUT
002556  2                NO_TRACE28:
002556  2                               RESTORE_REGS
002556  2               .ENDIF
002556  2               .ENDIF
002556  2               
002556  2  60                           RTS
002557  2               
002557  2               ;*******************************
002557  2               ; GET_SMARTPORT_DISPATCH_ADDRESS
002557  2               ; INPUT:
002557  2               ;   NONE
002557  2               ;***
002557  2               ; RETURN
002557  2               ;   -A DISPATCHER ADDRESS HIGH
002557  2               ;   -X DISPATCHER ADDRESS LOW
002557  2               ; OR A AND X WILL BE SET TO $FF
002557  2               ; IF DISPATCHER NOT FOUND
002557  2               ;**********************************
002557  2               GET_SMARTPORT_DISPATCH_ADDRESS:
002557  2               
002557  2               .IF .NOT STRIP_TRACE
002557  2                               SAVE_REGS
002557  2                               LDA TRACE_FLAG
002557  2                               BEQ NO_TRACE11
002557  2                               PRINT_STR GET_SMARTPORT_DISPATCH_ADDRESS_STR_ADDR
002557  2               NO_TRACE11:
002557  2                               RESTORE_REGS
002557  2               .ENDIF
002557  2               
002557  2  20 25 25                     JSR FIND_SMARTPORT_SLOT
00255A  2  C9 FF                        CMP #$FF                ; IF A == $FF THEN NOT FOUND
00255C  2  F0 31                        BEQ NO_DISPATCHER
00255E  2               
00255E  2  A5 EE                        LDA SLOT_ADDR_HI
002560  2  8D 2D 32                     STA DISPATCHER_ADDR_HI  ; A = $CX WHERE X IS THE SLOT
002563  2  A5 ED                        LDA SLOT_ADDR_LO
002565  2  8D 2C 32                     STA DISPATCHER_ADDR_LO  ; COMPLETE ADDRESS IS $CX00
002568  2               
002568  2  A0 FF                        LDY #$FF
00256A  2  B1 ED                        LDA (SLOT_ADDR),Y        ; j= peek(a+0xFF)
00256C  2  18                           CLC
00256D  2  6D 2C 32                     ADC DISPATCHER_ADDR_LO   ; DISPATCHER_ADDR += J
002570  2  8D 2C 32                     STA DISPATCHER_ADDR_LO
002573  2               
002573  2  AD 2D 32                     LDA DISPATCHER_ADDR_HI
002576  2  69 00                        ADC #$00
002578  2  8D 2D 32                     STA DISPATCHER_ADDR_HI
00257B  2               
00257B  2  18                           CLC                     ; DISPATCHER_ADDR += 3
00257C  2  AD 2C 32                     LDA DISPATCHER_ADDR_LO
00257F  2  69 03                        ADC #$03
002581  2  8D 2C 32                     STA DISPATCHER_ADDR_LO
002584  2               
002584  2  AD 2D 32                     LDA DISPATCHER_ADDR_HI
002587  2  69 00                        ADC #$00
002589  2  8D 2D 32                     STA DISPATCHER_ADDR_HI
00258C  2               
00258C  2  18                           CLC
00258D  2  90 0A                        BCC DONE
00258F  2               
00258F  2               NO_DISPATCHER:
00258F  2  A9 FF                        LDA #$FF                ; NO ADDRESS FOUND
002591  2  A2 FF                        LDX #$FF
002593  2  8D 2D 32                     STA DISPATCHER_ADDR_HI  ; PUT ADDRESS IN A AND X
002596  2  8E 2C 32                     STX DISPATCHER_ADDR_LO
002599  2               DONE:
002599  2  AD 2D 32                     LDA DISPATCHER_ADDR_HI  ; PUT ADDRESS IN A AND X
00259C  2  AE 2C 32                     LDX DISPATCHER_ADDR_LO
00259F  2               
00259F  2  60                           RTS
0025A0  2               
0025A0  2               .ENDIF
0025A0  2               
0025A0  2               ;******************************************************************
0025A0  2               ; SP_OPEN
0025A0  2               ; The Open command opens a logical me on the target device for data I/0. This
0025A0  2               ; command is used for character devices only. The parameter list for this call is as
0025A0  2               ; follows:
0025A0  2               ; Byte Definition
0025A0  2               ; 0     parameter list length ($03)
0025A0  2               ; 1     unit number
0025A0  2               ; INPUT
0025A0  2               ; X = UNIT DESTINATION
0025A0  2               ;******************************************************************
0025A0  2               SP_OPEN:
0025A0  2               
0025A0  2               .IF .NOT STRIP_TRACE
0025A0  2               .IF EXT2_TRACE
0025A0  2                               SAVE_REGS
0025A0  2                               TXA
0025A0  2                               PHA                                     ; STACK +1
0025A0  2               
0025A0  2                               LDA TRACE_FLAG
0025A0  2                               BEQ NO_TRACE12
0025A0  2               
0025A0  2                               JSR CROUT
0025A0  2                               PRINT_STR SP_OPEN_STR_ADDR              ; "SP_OPEN:"
0025A0  2               
0025A0  2                               PLA                                     ; STACK -1
0025A0  2                               PHA                                     ; STACK +1
0025A0  2                               TAX
0025A0  2                               JSR PRTX
0025A0  2                               JSR CROUT
0025A0  2                               JSR DUMP_SP_PAYLOAD_STR
0025A0  2                               JSR CROUT
0025A0  2               NO_TRACE12:
0025A0  2                               PLA                                     ; STACK -1
0025A0  2               
0025A0  2                               RESTORE_REGS
0025A0  2               
0025A0  2               .ENDIF
0025A0  2               .ENDIF
0025A0  2               
0025A0  2  A9 03                        LDA #SP_OPEN_PARAM_COUNT        ; 3
0025A2  2  8D 35 32                     STA CMD_LIST                    ; PARAMETER COUNT
0025A5  2  8E 36 32                     STX CMD_LIST+1                  ; DESTINATION DEVICE
0025A8  2  20 70 26                     JSR CALL_DISPATCHER
0025AB  2               
0025AB  2  EA           cmd_open:       .BYTE $EA       ; SP_CMD_OPEN
0025AC  2  EA EA        cmd_list0:      .WORD $EAEA     ; CMD_LIST
0025AE  2               
0025AE  2  90 00                        BCC SP_OPEN_DONE
0025B0  2               
0025B0  2               OPEN_ERROR:
0025B0  2               .IF EXT2_TRACE
0025B0  2                               PHA
0025B0  2                               PRINT_STR SP_ERROR_STR_ADDR
0025B0  2                               PLA
0025B0  2                               TAX
0025B0  2                               JSR PRTX
0025B0  2                               JSR CROUT
0025B0  2               .ENDIF
0025B0  2               SP_OPEN_DONE:
0025B0  2               
0025B0  2  60                           RTS
0025B1  2               
0025B1  2               ;******************************************************************
0025B1  2               ; SP_CLOSE
0025B1  2               ; The Close command closes a logical file on the target device after a data I/O
0025B1  2               ; sequence is completed. This command is used for character devices only. The
0025B1  2               ; parameter list for this call is as follows:
0025B1  2               ; Byte Definition
0025B1  2               ; 0     parameter list length ($03)
0025B1  2               ; 1     unit number
0025B1  2               ; INPUT
0025B1  2               ; X = UNIT DESTINATION
0025B1  2               ;******************************************************************
0025B1  2               SP_CLOSE:
0025B1  2               
0025B1  2               .IF .NOT STRIP_TRACE
0025B1  2               .IF EXT2_TRACE
0025B1  2                               SAVE_REGS
0025B1  2                               TXA
0025B1  2                               PHA
0025B1  2                               LDA TRACE_FLAG
0025B1  2                               BEQ NO_TRACE13
0025B1  2                               PRINT_STR SP_CLOSE_STR_ADDR
0025B1  2                               PLA
0025B1  2                               PHA
0025B1  2                               TAX
0025B1  2                               JSR PRTX
0025B1  2               
0025B1  2               NO_TRACE13:
0025B1  2                               PLA
0025B1  2                               RESTORE_REGS
0025B1  2               .ENDIF
0025B1  2               .ENDIF
0025B1  2               
0025B1  2  A9 03                        LDA #SP_CLOSE_PARAM_COUNT       ; 3
0025B3  2  8D 35 32                     STA CMD_LIST                    ; PARAMETER COUNT
0025B6  2  8E 36 32                     STX CMD_LIST+1                  ; DESTINATION DEVICE
0025B9  2  20 70 26                     JSR CALL_DISPATCHER
0025BC  2               
0025BC  2  EA           cmd_close:      .BYTE $EA       ; SP_CMD_CLOSE
0025BD  2  EA EA        cmd_list1:      .WORD $EAEA     ; CMD_LIST
0025BF  2               
0025BF  2  90 00                        BCC SP_CLOSE_DONE
0025C1  2               CLOSE_ERROR:
0025C1  2               .IF EXT2_TRACE
0025C1  2                               PRINT_STR SP_ERROR_STR_ADDR
0025C1  2               
0025C1  2                               LDX CMD_LIST+1
0025C1  2                               JSR PRTX
0025C1  2                               JSR CROUT
0025C1  2               .ENDIF
0025C1  2               SP_CLOSE_DONE:
0025C1  2               
0025C1  2  60                           RTS
0025C2  2               
0025C2  2               
0025C2  2               ;******************************************************************
0025C2  2               ; SP_CONTROL
0025C2  2               ;The Control command provides two basic functions. The first is to execute device
0025C2  2               ;control routines designed by Apple. The second is to execute Fujinet commands.
0025C2  2               ;Although each control code has its own parameter list.
0025C2  2               ;
0025C2  2               ; CMD_LIST:
0025C2  2               ;  0    - PARAMETER
0025C2  2               ;  1    - UNIT
0025C2  2               ;  2-3  - CTRL LIST POINTER
0025C2  2               ;  4    - CTRL CODE
0025C2  2               ;
0025C2  2               ; FUJINET SPECIFC
0025C2  2               ;Byte   Definition
0025C2  2               ; 'O'-open
0025C2  2               ;0-1    payload size
0025C2  2               ;2      mode read or write or both
0025C2  2               ;3      translation
0025C2  2               ;4...   url
0025C2  2               ;
0025C2  2               ; 'C'-close
0025C2  2               ;0-1    payload size $00
0025C2  2               ;
0025C2  2               ; 'R'-read
0025C2  2               ;0-1   payload size (bytes to return)
0025C2  2               ;2..   data
0025C2  2               ;
0025C2  2               ; 'W'-write
0025C2  2               ; 0-1  payload size (bytes to write)
0025C2  2               ; 2..  data
0025C2  2               ;
0025C2  2               ; 'A'-accept
0025C2  2               ; accept connection
0025C2  2               ;0-1    payload size $00?
0025C2  2               ;
0025C2  2               ; 'c'-close connection
0025C2  2               ; close client connection
0025C2  2               ;0-1    payload size $00?
0025C2  2               ;
0025C2  2               ;'D'-udp destination
0025C2  2               ; set UDP destination
0025C2  2               ;0-1    payload size?
0025C2  2               ;2...   url?
0025C2  2               ;
0025C2  2               ; INPUT
0025C2  2               ;  X = UNIT
0025C2  2               ;  Y = CONTROL CODE
0025C2  2               ;******************************************************************
0025C2  2               SP_CONTROL:
0025C2  2               
0025C2  2               .IF .NOT STRIP_TRACE
0025C2  2               .IF EXT2_TRACE
0025C2  2                               SAVE_REGS
0025C2  2                               LDA TRACE_FLAG
0025C2  2                               BEQ NO_TRACE14
0025C2  2               
0025C2  2                               TXA
0025C2  2                               PHA
0025C2  2               
0025C2  2                               PRINT_STR SP_CONTROL_STR_ADDR
0025C2  2                               PLA
0025C2  2                               TAX
0025C2  2               
0025C2  2                               JSR PRTX
0025C2  2                               LDA #'['
0025C2  2                               JSR COUT
0025C2  2                               LDA CMD_LIST+4
0025C2  2                               JSR COUT
0025C2  2                               LDA #']'
0025C2  2                               JSR COUT
0025C2  2                               LDX CMD_LIST+4
0025C2  2                               JSR PRTX
0025C2  2                               JSR CROUT
0025C2  2               NO_TRACE14:
0025C2  2                               RESTORE_REGS
0025C2  2               .ENDIF
0025C2  2               .ENDIF
0025C2  2               
0025C2  2  A9 03                        LDA #SP_CONTROL_PARAM_COUNT     ; 3
0025C4  2  8D 35 32                     STA CMD_LIST                    ; PARAMETER COUNT
0025C7  2  8E 36 32                     STX CMD_LIST+1                  ; DESTINATION DEVICE     param 1
0025CA  2  AD 2E 32                     LDA SP_PAYLOAD_ADDR             ; CONTROL LIST POINTER   param 2
0025CD  2  8D 37 32                     STA CMD_LIST+2
0025D0  2  AD 2F 32                     LDA SP_PAYLOAD_ADDR+1           ;                        param 2.5
0025D3  2  8D 38 32                     STA CMD_LIST+3
0025D6  2  8C 39 32                     STY CMD_LIST+4                  ; CONTROL CODE           param 3
0025D9  2               
0025D9  2                               ; OTHER ITEMS WILL NEED TO BE
0025D9  2                               ; SET BEFORE CALLING THIS ROUTINE
0025D9  2               
0025D9  2               .IF .NOT STRIP_TRACE
0025D9  2               .IF EXT2_TRACE
0025D9  2                       SAVE_REGS
0025D9  2                       JSR DUMP_CMD_LIST
0025D9  2                       JSR DUMP_SP_PAYLOAD
0025D9  2                       RESTORE_REGS
0025D9  2               .ENDIF
0025D9  2               .ENDIF
0025D9  2               
0025D9  2  20 70 26                     JSR CALL_DISPATCHER
0025DC  2               
0025DC  2  EA           cmd_control:    .BYTE $EA       ; SP_CMD_CONTROL
0025DD  2  EA EA        cmd_list2:      .WORD $EAEA     ; CMD_LIST
0025DF  2               
0025DF  2  90 00                        BCC SP_CTRL_DONE
0025E1  2               
0025E1  2               CTRL_ERROR:
0025E1  2               
0025E1  2               .IF EXT_TRACE
0025E1  2                               PHA
0025E1  2                               PRINT_STR SP_ERROR_STR_ADDR
0025E1  2                               PLA
0025E1  2                               TAX
0025E1  2                               JSR PRTX
0025E1  2                               JSR CROUT
0025E1  2                               SEC
0025E1  2               .ENDIF
0025E1  2               
0025E1  2               SP_CTRL_DONE:
0025E1  2  60                           RTS
0025E2  2               
0025E2  2               ;******************************************************************
0025E2  2               ; SP_READ
0025E2  2               ;The Read command reads a specified number of bytes from the target device
0025E2  2               ;specified in the unit number parameter. The bytes read by this command are
0025E2  2               ;written into RAM, beginning at the address specified in the data buffer pointer. The
0025E2  2               ;number of bytes to be read is specified in the byte count parameter. The parameter
0025E2  2               ;list for this call is as follows:
0025E2  2               ;
0025E2  2               ;Byte  Definition
0025E2  2               ;0      parameter list length ($04)
0025E2  2               ;1      unit number
0025E2  2               ;2-3    input buffer pointer (lsb-msb)
0025E2  2               ;4-5    byte count
0025E2  2               ;6-7    address pointer
0025E2  2               ;
0025E2  2               ;Parameter description
0025E2  2               ;input buffer pointer: This parameter contains the beginning address of the host data
0025E2  2               ;buffer to which the target bytes are written.
0025E2  2               ;byte count: This parameter contains the number of bytes to be read
0025E2  2               ;address pointer: This parameter contains the block address of the target block.
0025E2  2               ;******************************************************************
0025E2  2               SP_READ:
0025E2  2               
0025E2  2               .IF .NOT STRIP_TRACE
0025E2  2               .IF EXT2_TRACE
0025E2  2                               SAVE_REGS
0025E2  2                               LDA TRACE_FLAG
0025E2  2                               BEQ NO_TRACE15
0025E2  2                               TXA
0025E2  2                               PHA
0025E2  2                               PRINT_STR SP_READ_STR_ADDR
0025E2  2                               PLA
0025E2  2                               TAX
0025E2  2                               JSR PRTX
0025E2  2                               JSR CROUT
0025E2  2               NO_TRACE15:
0025E2  2                               RESTORE_REGS
0025E2  2               .ENDIF
0025E2  2               .ENDIF
0025E2  2               
0025E2  2  A9 04                        LDA #SP_READ_PARAM_COUNT
0025E4  2  8D 35 32                     STA CMD_LIST                    ; [0] PARAMETER COUNT
0025E7  2  8E 36 32                     STX CMD_LIST+1                  ; [1] X = DESTINATION DEVICE
0025EA  2  AD 2E 32                     LDA SP_PAYLOAD_ADDR
0025ED  2  8D 37 32                     STA CMD_LIST+2                  ; [2] WHERE TO STORE DATA LO
0025F0  2  AD 2F 32                     LDA SP_PAYLOAD_ADDR+1
0025F3  2  8D 38 32                     STA CMD_LIST+3                  ; [3] WHERE TO STORE DATA HI
0025F6  2  8C 39 32                     STY CMD_LIST+4                  ; [4] Y = LENGTH LO ; yeah, max 255 byte payload...
0025F9  2  A9 00                        LDA #$00
0025FB  2  8D 3A 32                     STA CMD_LIST+5                  ; [5] LENGTH HI
0025FE  2               
0025FE  2                               ; *** Based on Smartport SCSI info below
0025FE  2                               ; *** Not sure if necessary
0025FE  2                               ; *** was not set in the example by Thom Cherryhomes
0025FE  2               
0025FE  2               ;                LDA #00
0025FE  2               ;                STA CMD_LIST+6                  ; [6] ???? BLOCK ADDRESS OF TARGET BLOCK
0025FE  2               ;                LDA #00
0025FE  2               ;                STA CMD_LIST+7                  ; [7] ????
0025FE  2               
0025FE  2                               ; ***
0025FE  2               
0025FE  2  20 70 26                     JSR CALL_DISPATCHER
002601  2               
002601  2  EA           cmd_read:       .BYTE $EA       ; SP_CMD_READ               ; READ CALL COMMAND NUMBER
002602  2  EA EA        cmd_list3:      .WORD $EAEA     ; CMD_LIST
002604  2               
002604  2  8E 32 32                     STX SP_COUNT
002607  2  8C 33 32                     STY SP_COUNT+1
00260A  2  8D 34 32                     STA LAST_SP_ERR
00260D  2  90 01                        BCC SP_READ_DONE
00260F  2               
00260F  2               ERROR:
00260F  2               .IF EXT2_TRACE
00260F  2                               PHA
00260F  2                               PRINT_STR SP_ERROR_STR_ADDR
00260F  2                               PLA
00260F  2                               TAX
00260F  2                               JSR PRTX
00260F  2                               JSR CROUT
00260F  2               .ENDIF
00260F  2  38                           SEC
002610  2               
002610  2               SP_READ_DONE:
002610  2  60                           RTS
002611  2               
002611  2               
002611  2               ;******************************************************************
002611  2               ; SP_WRITE
002611  2               ;The Write command writes a specified number of bytes to the target device
002611  2               ;specified in the unit number p4rameter. The bytes written by this command are
002611  2               ;read from RAM, beginning at the address specified in the data buffer pointer. The
002611  2               ;number of bytes to be written is specified in the byte count parameter. The
002611  2               ;parameter list for this call is as follows:
002611  2               ;
002611  2               ;Byte  Definition
002611  2               ;0      parameter list length
002611  2               ;1      unit number
002611  2               ;2-3    data buffer pointer
002611  2               ;4-5    byte count
002611  2               ;6-7    address pointer
002611  2               ;
002611  2               ;data buffer pointer: This parameter contains the beginning address of the data
002611  2               ;buffer from which the target bytes are written.
002611  2               ;byte count: This parameter contains the number of bytes to write for this
002611  2               ;command.
002611  2               ;address pointer: This parameter contains the block address of the target block.
002611  2               ;
002611  2               ; INPUT
002611  2               ;    X - DEVICE
002611  2               ;    Y - LENGTH
002611  2               ;    SP_PAYLOAD - CONTAINS DATA
002611  2               ;******************************************************************
002611  2               SP_WRITE:
002611  2               
002611  2               .IF .NOT STRIP_TRACE
002611  2               .IF EXT2_TRACE
002611  2                               SAVE_REGS
002611  2                               TXA
002611  2                               PHA
002611  2                               LDA TRACE_FLAG
002611  2                               BEQ NO_TRACE40
002611  2               
002611  2                               PRINT_STR SP_WRITE_STR_ADDR
002611  2                               PLA
002611  2                               PHA
002611  2                               TAX
002611  2                               JSR PRTX
002611  2                               JSR CROUT
002611  2               NO_TRACE40:
002611  2                               PLA
002611  2                               RESTORE_REGS
002611  2               .ENDIF
002611  2               .ENDIF
002611  2               
002611  2  A9 04                        LDA #SP_WRITE_PARAM_COUNT
002613  2  8D 35 32                     STA CMD_LIST                    ; PARAMETER COUNT
002616  2  8E 36 32                     STX CMD_LIST+1                  ; DESTINATION DEVICE
002619  2  AD 2E 32                     LDA SP_PAYLOAD_ADDR
00261C  2  8D 37 32                     STA CMD_LIST+2                  ; DATA BUFFER
00261F  2  AD 2F 32                     LDA SP_PAYLOAD_ADDR+1
002622  2  8C 39 32                     STY CMD_LIST+4                  ; Y=LENGTH LO
002625  2  A9 00                        LDA #$00
002627  2  8D 3A 32                     STA CMD_LIST+5                  ; LENGTH HI
00262A  2  8D 3B 32                     STA CMD_LIST+6                  ; ADDRESS POINTER LOW
00262D  2  8D 3C 32                     STA CMD_LIST+7                  ; ADDRESS POINTER MID
002630  2  8D 3D 32                     STA CMD_LIST+8                  ; ADDRESS POINTER HI
002633  2               
002633  2                               ; *** Based on Smartport SCSI info below
002633  2                               ; *** Not sure if necessary
002633  2                               ; *** was not set in the example by Thom Cherryhomes
002633  2               
002633  2               ;                LDA #0                          ; DATA POINTER
002633  2               ;                STA CMD_LIST+6
002633  2               ;                STA CMD_LIST+7
002633  2               
002633  2                               ; ***
002633  2               
002633  2  20 70 26                     JSR CALL_DISPATCHER
002636  2               
002636  2  EA           cmd_write:      .BYTE $EA       ; SP_CMD_WRITE             ; STATUS CALL COMMAND NUMBER
002637  2  EA EA        cmd_list4:      .WORD $EAEA     ; CMD_LIST
002639  2               
002639  2  8E 32 32                     STX SP_COUNT
00263C  2  8C 33 32                     STY SP_COUNT+1
00263F  2  8D 34 32                     STA LAST_SP_ERR
002642  2  90 01                        BCC SP_WRITE_DONE
002644  2               
002644  2               ERROR2:
002644  2               
002644  2               .IF .NOT STRIP_TRACE
002644  2               .IF EXT2_TRACE
002644  2                               PHA
002644  2                               PRINT_STR SP_ERROR_STR_ADDR
002644  2                               PLA
002644  2                               PHA
002644  2                               TAX
002644  2                               JSR PRTX
002644  2                               JSR CROUT
002644  2                               PLA ; A = ERROR CODE
002644  2               .ENDIF
002644  2               .ENDIF
002644  2  38                           SEC
002645  2               SP_WRITE_DONE:
002645  2  60                           RTS
002646  2               
002646  2               
002646  2               
002646  2               
002646  2               ;******************************************************************
002646  2               ; SP_STATUS
002646  2               ;   The Status command returns information about a specific device.
002646  2               ; The information returned by this command is determined by status code.
002646  2               ; On return from a Status call, the microprocessor X and Y registers are set to
002646  2               ; indicate the number of bytes transferred to the Apple II by the command. The X
002646  2               ; register is set to the low byte of the count, and the Y register is set to the high byte.
002646  2               ; The parameter list for this call is as follows:
002646  2               ; Byte Definition
002646  2               ;  0   parameter list length
002646  2               ;  1   unit number
002646  2               ; 2-3  status list pointer (lsb-msb)
002646  2               ;  4   status code
002646  2               ; INPUT
002646  2               ;   X - UNIT DESTINATION
002646  2               ;   Y - STATUS CODE
002646  2               ;       Y='S' return SP[0..1] = Bytes waiting, SP[2] & 0x02 = connected
002646  2               ;******************************************************************
002646  2               ; examples
002646  2               ;          Params
002646  2               ;               dest
002646  2               ;                      storage
002646  2               ;                                 status code
002646  2               ; CMD_LIST: 03   07    36 3c         53
002646  2               ;
002646  2               ; CMD_LIST: 03 07 36 3c 53
002646  2               ; payload:  00 02 01 01 4e 3a 48 54 54
002646  2               ;                        N  :  H  T  T
002646  2               ;
002646  2               ; CMD_LIST: 03 00 36 3c 00
002646  2               ; payload:  09
002646  2               ;
002646  2               ; CMD_LIST: 03 01 36 3c 03
002646  2               ; payload:  fc 18 01 00 0e 46 55 4a 49 4e 45 54 5f 44 49 53
002646  2               ;                           F  U  J  I  N  E  T  _  D  I  S
002646  2               ; this program
002646  2               ;
002646  2               ; CMD_LIST: 03 00 60 27 00
002646  2               ; payload:  09
002646  2               ;
002646  2               ; CMD_LIST: 03 01 36 3c 03
002646  2               ; payload:  fc 18 01 00 0e 46 55 4a 49 4e 45 54 5f 44 49 53
002646  2               
002646  2               SP_STATUS:
002646  2               
002646  2               .IF .NOT STRIP_TRACE
002646  2               .IF EXT2_TRACE
002646  2               
002646  2                               SAVE_REGS
002646  2                               TXA
002646  2                               PHA
002646  2                               LDA TRACE_FLAG
002646  2                               BEQ NO_TRACE35
002646  2                               PRINT_STR SP_STATUS_STR_ADDR
002646  2                               PLA
002646  2                               PHA
002646  2                               TAX
002646  2                               JSR PRTX
002646  2               
002646  2               NO_TRACE35:
002646  2                               PLA
002646  2                               RESTORE_REGS
002646  2               .ENDIF
002646  2               .ENDIF
002646  2               
002646  2  A9 03                        LDA #SP_STATUS_PARAM_COUNT
002648  2  8D 35 32                     STA CMD_LIST                    ; PARAMETER COUNT
00264B  2               
00264B  2  8E 36 32                     STX CMD_LIST+1                  ; X = DESTINATION DEVICE
00264E  2               
00264E  2  AD 2E 32                     LDA SP_PAYLOAD_ADDR
002651  2  8D 37 32                     STA CMD_LIST+2                  ; STATUS LIST POINTER LO
002654  2  AD 2F 32                     LDA SP_PAYLOAD_ADDR+1
002657  2  8D 38 32                     STA CMD_LIST+3                  ; STATUS LIST POINTER HI
00265A  2               
00265A  2  8C 39 32                     STY CMD_LIST+4                  ; Y = STATUS CODE
00265D  2               
00265D  2  20 70 26                     JSR CALL_DISPATCHER
002660  2               
002660  2  EA           cmd_status:     .BYTE $EA       ; SP_CMD_STATUS             ; STATUS CALL COMMAND NUMBER
002661  2  EA EA        cmd_list5:      .WORD $EAEA     ; CMD_LIST
002663  2               
002663  2  8E 32 32                     STX SP_COUNT
002666  2  8C 33 32                     STY SP_COUNT+1
002669  2  8D 34 32                     STA LAST_SP_ERR
00266C  2               
00266C  2               .IF .NOT STRIP_TRACE
00266C  2               .IF EXT2_TRACE
00266C  2                       SAVE_REGS
00266C  2                       PHA
00266C  2                       PRINT_STR SP_ERROR_STR_ADDR
00266C  2                       PLA
00266C  2                       TAX
00266C  2                       JSR PRTX
00266C  2                       JSR DUMP_CMD_LIST
00266C  2                       JSR DUMP_SP_PAYLOAD_HEX
00266C  2                       RESTORE_REGS
00266C  2               .ENDIF
00266C  2               .ENDIF
00266C  2               
00266C  2  90 01                        BCC SP_STATUS_DONE
00266E  2               
00266E  2               ERROR3:
00266E  2               .IF .NOT STRIP_TRACE
00266E  2               .IF EXT2_TRACE
00266E  2                               SAVE_REGS
00266E  2                               PHA
00266E  2                               PRINT_STR SP_ERROR_STR_ADDR
00266E  2                               PLA
00266E  2                               TAX
00266E  2                               JSR PRTX
00266E  2                               RESTORE_REGS
00266E  2                               SEC
00266E  2               .ENDIF
00266E  2               .ENDIF
00266E  2               
00266E  2  60                           RTS
00266F  2               SP_STATUS_DONE:
00266F  2               .IF .NOT STRIP_TRACE
00266F  2               .IF EXT2_TRACE
00266F  2                               SAVE_REGS
00266F  2                               JSR CROUT
00266F  2                               RESTORE_REGS
00266F  2               
00266F  2                               CLC
00266F  2               .ENDIF
00266F  2               .ENDIF
00266F  2  60                           RTS
002670  2               
002670  2               
002670  2               ;*******************************
002670  2               ; CALL_DISPATCHER
002670  2               ;   Call this routine as a JSR
002670  2               ; INPUT:
002670  2               ;   Immediately following the
002670  2               ; JSR put the following data
002670  2               ; into your code
002670  2               ; BYTE - Command Number
002670  2               ; WORD - Address for return values
002670  2               ;**********************************
002670  2               CALL_DISPATCHER:
002670  2  6C 2C 32                     JMP (SMARTPORT_DISPATCHER)
002673  2               
002673  2               ;*******************************
002673  2               ; DISPLAY_SP_STATUS
002673  2               ;   Displays the device count,
002673  2               ; vender id, and version number
002673  2               ;**********************************
002673  2               DISPLAY_SP_STATUS:
002673  2               
002673  2               .IF .NOT STRIP_TRACE
002673  2               .IF EXT2_TRACE
002673  2                               LDA TRACE_FLAG
002673  2                               BEQ NO_TRACE17
002673  2                               PRINT_STR DISPLAY_SP_STATUS_STR_ADDR
002673  2               NO_TRACE17:
002673  2               .ENDIF
002673  2               .ENDIF
002673  2               
002673  2  A2 00                        LDX #$00                                ; SMARTPORT DEVICE ZERO
002675  2  A0 00                        LDY #$00
002677  2  20 46 26                     JSR SP_STATUS
00267A  2  8E 4C 32                     STX DCOUNT                              ; DCOUNT = NUMBER OF DEVICES
00267D  2               
00267D  2  8D F9 31 08                  PRINT_STR COUNT_STR_ADDR
002681  2  48 8A 48 98  
002685  2  48 AD F9 31  
002698  2  AE 4C 32                     LDX DCOUNT
00269B  2  20 44 F9                     JSR PRTX
00269E  2  20 8E FD                     JSR CROUT
0026A1  2               
0026A1  2  8D F9 31 08                  PRINT_STR VENDER_STR_ADDR
0026A5  2  48 8A 48 98  
0026A9  2  48 AD F9 31  
0026BC  2  AD 4E 32                     LDA MANUFACTURER
0026BF  2  AE 4F 32                     LDX MANUFACTURER+1
0026C2  2  20 41 F9                     JSR PRTAX
0026C5  2  20 8E FD                     JSR CROUT
0026C8  2               
0026C8  2  8D F9 31 08                  PRINT_STR VENDER_VERSION_STR_ADDR
0026CC  2  48 8A 48 98  
0026D0  2  48 AD F9 31  
0026E3  2  AD 50 32                     LDA INTERFACEVER
0026E6  2  AE 51 32                     LDX INTERFACEVER+1
0026E9  2  20 41 F9                     JSR PRTAX
0026EC  2  20 8E FD                     JSR CROUT
0026EF  2               
0026EF  2  60                           RTS
0026F0  2               
0026F0  2               
0026F0  2               .IF .NOT STRIP_TRACE
0026F0  2               ;*******************************
0026F0  2               ; ISTROUT
0026F0  2               ;   Display string in Fsp_D
0026F0  2               ;**********************************
0026F0  2               ISTROUT:
0026F0  2                               STA ZP1_LO
0026F0  2                               STY ZP1_HI
0026F0  2                               LDY #$00
0026F0  2               PRINTI:
0026F0  2                               LDA (ZP1),Y
0026F0  2                               BEQ PRINTI_STOP
0026F0  2                               AND #$3F        ; INVERSE
0026F0  2               ;               ORA #$80        ; NORMAL
0026F0  2               ;               ORA #$40        ; FLASHING
0026F0  2                               JSR COUT
0026F0  2                               INY
0026F0  2                               CLC
0026F0  2                               BCC PRINTI
0026F0  2               PRINTI_STOP:
0026F0  2                               RTS
0026F0  2               .ENDIF
0026F0  2               
0026F0  2               ;*******************************
0026F0  2               ; DISPLAY_SP_DEVICES
0026F0  2               ;   Display all the devices on
0026F0  2               ; the smartport
0026F0  2               ;**********************************
0026F0  2               DISPLAY_SP_DEVICES:
0026F0  2               
0026F0  2  A2 00                        LDX #$00
0026F2  2  A0 00                        LDY #SP_CMD_STATUS
0026F4  2  20 46 26                     JSR SP_STATUS
0026F7  2               
0026F7  2  AE 4C 32                     LDX DCOUNT
0026FA  2  E8                           INX
0026FB  2  8E 2B 32                     STX NUM_DEVICES
0026FE  2               
0026FE  2  A2 01                        LDX #$01
002700  2               NEXT_DEV:
002700  2  8A                           TXA
002701  2  48                           PHA
002702  2               
002702  2  8D F9 31 08                  PRINT_STR UNIT_STR_ADDR
002706  2  48 8A 48 98  
00270A  2  48 AD F9 31  
00271D  2               
00271D  2  68                           PLA                     ; GET BACK OUR VALUE OF
00271E  2  48                           PHA                     ; X WE STORED ON THE STACK
00271F  2  AA                           TAX
002720  2  20 44 F9                     JSR PRTX
002723  2               
002723  2  8D F9 31 08                  PRINT_STR NAME_STR_ADDR
002727  2  48 8A 48 98  
00272B  2  48 AD F9 31  
00273E  2               
00273E  2  68                           PLA                     ; ONCE AGAIN, GET OUR VALUE OF X
00273F  2  48                           PHA
002740  2  AA                           TAX
002741  2               
002741  2  A0 03                        LDY #SP_STATUS_DIB      ; X = DEVICE
002743  2  20 46 26                     JSR SP_STATUS
002746  2  B0 0F                        BCS DISPLAY_ERROR_OUT   ; SHOULD NEVER HAPPEN, BUT IF IT DOES, JUST EXIT
002748  2               
002748  2  20 02 25                     JSR PRINT_SP_PAYLOAD_STR
00274B  2               
00274B  2  20 8E FD                     JSR CROUT
00274E  2               
00274E  2  68                           PLA
00274F  2  AA                           TAX
002750  2  E8                           INX
002751  2  EC 2B 32                     CPX NUM_DEVICES
002754  2  D0 AA                        BNE NEXT_DEV
002756  2  60                           RTS
002757  2               
002757  2               DISPLAY_ERROR_OUT:
002757  2  20 44 F9                     JSR PRTX
00275A  2               
00275A  2  8D F9 31 08                  PRINT_STR UNIT_STR_ADDR
00275E  2  48 8A 48 98  
002762  2  48 AD F9 31  
002775  2               
002775  2  68                           PLA
002776  2  AA                           TAX
002777  2  20 44 F9                     JSR PRTX
00277A  2               
00277A  2  60                           RTS
00277B  2               
00277B  2               ;***************************************************************
00277B  2               
00277B  2               ;*******************************
00277B  2               ; SP_FIND_DEVICE
00277B  2               ;   Looks for the specified smartport device
00277B  2               ; INPUT
00277B  2               ;   Put NULL terminated string of device to
00277B  2               ;   search for in FIND_DEVICE_STR
00277B  2               ; RETURNS
00277B  2               ;   A = High byte address of string
00277B  2               ;   Y = Low byte address of string
00277B  2               ;   X = Device number or $FF on failure
00277B  2               ;*********************************
00277B  2               
00277B  2               SP_FIND_DEVICE:
00277B  2               
00277B  2               .IF .NOT STRIP_TRACE
00277B  2               .IF EXT_TRACE
00277B  2                               SAVE_REGS
00277B  2                               LDA TRACE_FLAG
00277B  2                               BEQ NO_TRACE18
00277B  2                               PRINT_STR SP_FIND_DEVICE_STR_ADDR       ; "SP_FIND_DEVICE:"
00277B  2               NO_TRACE18:
00277B  2                               RESTORE_REGS
00277B  2               .ENDIF
00277B  2               .ENDIF
00277B  2  85 EC                        STA ZP1_HI                              ; STORE THE STRING ADDRESS
00277D  2  84 EB                        STY ZP1_LO
00277F  2               
00277F  2  A2 00                        LDX #$00
002781  2  A0 00                        LDY #$00
002783  2               LOOK_FOR_NULL:
002783  2  B1 EB                        LDA (ZP1),Y                             ; START OF STRING WITHOUT LENGTH
002785  2  9D 55 34                     STA FIND_DEVICE_BUF,X
002788  2  F0 05                        BEQ GOT_LENGTH                          ; STOP WHEN WE GET TO NULL
00278A  2  C8                           INY
00278B  2  E8                           INX
00278C  2  18                           CLC
00278D  2  90 F4                        BCC LOOK_FOR_NULL
00278F  2               GOT_LENGTH:
00278F  2  8E 54 34                     STX FIND_DEVICE_BUF_LEN                 ; SAVE THE LENGTH INCLUDES NULL
002792  2               
002792  2               .IF .NOT STRIP_TRACE
002792  2               .IF EXT_TRACE
002792  2                               LDA TRACE_FLAG
002792  2                               BEQ NO_TRACE19
002792  2                               PRINT_STR FIND_DEVICE_BUF_ADDR          ; DISPLAY THE STRING WE COLLECTED
002792  2                               JSR CROUT                               ; CARRIAGE RETURN
002792  2               NO_TRACE19:
002792  2               .ENDIF
002792  2               .ENDIF
002792  2               
002792  2  A2 00                        LDX #$00
002794  2  A0 00                        LDY #SP_CMD_STATUS                      ; ASK FOR SMARTPORT STATUS
002796  2  20 46 26                     JSR SP_STATUS
002799  2                ;               BCC GOT_DEVICE_COUNT                    ; GOT AN ERROR
002799  2                ;               PRINT_STR SP_NO_DCOUNT_STR_ADDR
002799  2                ;               SEC
002799  2                ;               BCS ERROR_OUT2
002799  2               
002799  2               GOT_DEVICE_COUNT:
002799  2  AE 4C 32                     LDX DCOUNT                              ; THE NUMBER OF DEVICES
00279C  2  E8                           INX
00279D  2  8E 2B 32                     STX NUM_DEVICES
0027A0  2               .IF .NOT STRIP_TRACE
0027A0  2               .IF EXT2_TRACE
0027A0  2                               PRINT_STR SP_DCOUNT_STR_ADDR
0027A0  2                               DEX
0027A0  2                               JSR PRTX
0027A0  2                               JSR CROUT
0027A0  2               .ENDIF
0027A0  2               .ENDIF
0027A0  2  A2 01                        LDX #$01                                ; START AT DEVICE #1
0027A2  2               
0027A2  2               NEXT_DEV2:
0027A2  2  8A                           TXA
0027A3  2  48                           PHA
0027A4  2               
0027A4  2               .IF .NOT STRIP_TRACE
0027A4  2               .IF EXT_TRACE
0027A4  2                               JSR PRTX
0027A4  2                               PLA
0027A4  2                               PHA
0027A4  2                               TAX
0027A4  2               .ENDIF
0027A4  2               .ENDIF
0027A4  2               
0027A4  2  A0 03                        LDY #SP_STATUS_DIB                      ; X IS DEVICE
0027A6  2  20 46 26                     JSR SP_STATUS                           ; GET INFO
0027A9  2  B0 2A                        BCS ERROR_OUT                           ; QUIT IF WE GET AN ERROR
0027AB  2               
0027AB  2  AD 50 32                     LDA SP_PAYLOAD+4                        ; LENGTH OF STRING
0027AE  2  CD 54 34                     CMP FIND_DEVICE_BUF_LEN                 ; IS IT THE SAME SIZE AS THE STRING WE'RE LOOKING FOR?
0027B1  2  D0 13                        BNE NEXT_DEVICE                         ; NOPE, CHECK NEXT DEVICE
0027B3  2               
0027B3  2                               ; SAME SIZE STRING, NOW CHECK AND SEE IF IT
0027B3  2                               ; IS THE DEVICE WE'RE LOOKING FOR
0027B3  2               
0027B3  2               .IF .NOT STRIP_TRACE
0027B3  2               .IF EXT2_TRACE
0027B3  2                               LDA #'>'
0027B3  2                               JSR COUT
0027B3  2                               JSR DUMP_SP_PAYLOAD
0027B3  2               .ENDIF
0027B3  2               .ENDIF
0027B3  2               
0027B3  2  A2 00                        LDX #$00
0027B5  2               SCAN_CHAR:
0027B5  2               
0027B5  2  BD 51 32                     LDA SP_PAYLOAD+5,X                      ; INFO STRING
0027B8  2  DD 55 34                     CMP FIND_DEVICE_BUF,X                   ; DEVICE WE'RE LOOKING FOR
0027BB  2  D0 09                        BNE NEXT_DEVICE                         ; NOT THE SAME, CHECK NEXT DEVICE
0027BD  2               
0027BD  2  E8                           INX                                     ; MOVE TO NEXT DEVICE
0027BE  2  EC 50 32                     CPX SP_PAYLOAD+4                        ; HAVE WE FINISHED LOOKING AT THE SAME NUMBER OF CHARACTERS?
0027C1  2  D0 F2                        BNE SCAN_CHAR                           ; NOPE, KEEP GOING
0027C3  2               
0027C3  2  18                           CLC
0027C4  2  90 13                        BCC FOUND_DEVICE                        ; WE FOUND OUR DEVICE
0027C6  2               NEXT_DEVICE:
0027C6  2  68                           PLA                                     ; REMOVE THE DEVICE NUMBER OFF STACK
0027C7  2  AA                           TAX
0027C8  2  E8                           INX                                     ; AND INCREMENT IT
0027C9  2  EC 2B 32                     CPX NUM_DEVICES                         ; HAVE WE CHECKED ALL DEVICES?
0027CC  2  D0 D4                        BNE NEXT_DEV2                           ; NOPE, KEEP GOING
0027CE  2               
0027CE  2                               ; EXHAUSTED OUR LIST
0027CE  2               
0027CE  2  A2 FE                        LDX #SP_ERR                                ; NOT FOUND
0027D0  2  A9 50                        LDA #SP_ERROR_NOT_FOUND
0027D2  2  18                           CLC
0027D3  2  90 06                        BCC FOUND_DONE
0027D5  2               
0027D5  2               ERROR_OUT:
0027D5  2  68                           PLA
0027D6  2               ERROR_OUT2:
0027D6  2                               ; ERROR STRING HERE
0027D6  2               
0027D6  2               .IF .NOT STRIP_TRACE
0027D6  2               .IF EXT2_TRACE
0027D6  2                               PRINT_STR SP_FIND_DEVICE_ERROR_STR_ADDR
0027D6  2               .ENDIF
0027D6  2               .ENDIF
0027D6  2               
0027D6  2               
0027D6  2  A2 FE                        LDX #SP_ERR                               ; ERROR
0027D8  2  60                           RTS
0027D9  2               
0027D9  2               FOUND_DEVICE:
0027D9  2               .IF .NOT STRIP_TRACE
0027D9  2               .IF EXT2_TRACE
0027D9  2                               LDA #'F'
0027D9  2                               JSR COUT
0027D9  2                               JSR CROUT
0027D9  2               .ENDIF
0027D9  2               .ENDIF
0027D9  2               
0027D9  2  68                           PLA
0027DA  2  AA                           TAX
0027DB  2               
0027DB  2               FOUND_DONE:
0027DB  2               
0027DB  2  60                           RTS
0027DC  2               
0027DC  2               
0027DC  2               
0027DC  2               
0027DC  2               
0027DC  1                               .include "FAKESMARTPORT.S"
0027DC  2               FN_STATUS_FLAG_CONNECTED        = %00000010
0027DC  2               FN_STATUS_FLAG_NOT_CONNECTED    = %11111101
0027DC  2               
0027DC  2               .IF .NOT USE_SP
0027DC  2               
0027DC  2               NUMBER_OF_FAKE_UNITS = 4
0027DC  2               
0027DC  2               ;*******************************
0027DC  2               ; FIND_SMARTPORT_SLOT
0027DC  2               ; INPUT:
0027DC  2               ;   NONE
0027DC  2               ;***
0027DC  2               ; RETURN
0027DC  2               ;   A = $FF - NO SMARTPORT FOUND
0027DC  2               ;   A = $CX - WHERE X IS THE SLOT
0027DC  2               ;**********************************
0027DC  2               .IF USE_SP
0027DC  2               
0027DC  2               FIND_SMARTPORT_SLOT:
0027DC  2               
0027DC  2               .IF .NOT STRIP_TRACE
0027DC  2                               SAVE_REGS
0027DC  2                               LDA TRACE_FLAG
0027DC  2                               BEQ NO_TRACE29
0027DC  2               
0027DC  2                               PRINT_STR FAKE_SMARTPORT_STR_ADDR
0027DC  2               
0027DC  2                               PRINT_STR FIND_SMARTPORT_SLOT_STR_ADDR
0027DC  2               
0027DC  2               NO_TRACE29:
0027DC  2                               RESTORE_REGS
0027DC  2               .ENDIF
0027DC  2               
0027DC  2                               LDA #$C5                ; FAKE SMARTPORT FOR TESTING $C500
0027DC  2                               LDA SLOT_ADDR_HI
0027DC  2                               RTS                     ; WE FOUND IT! A = SLOT ADDRESS
0027DC  2               
0027DC  2               .ENDIF
0027DC  2               ;*******************************
0027DC  2               ; GET_SMARTPORT_DISPATCH_ADDRESS
0027DC  2               ; INPUT:
0027DC  2               ;   NONE
0027DC  2               ;***
0027DC  2               ; RETURN
0027DC  2               ;   -A DISPATCHER ADDRESS HIGH
0027DC  2               ;   -X DISPATCHER ADDRESS LOW
0027DC  2               ; OR A AND X WILL BE SET TO $FF
0027DC  2               ; IF DISPATCHER NOT FOUND
0027DC  2               ;**********************************
0027DC  2               GET_SMARTPORT_DISPATCH_ADDRESS:
0027DC  2                               ; FAKE SMARTPORT DISPATCHER
0027DC  2               
0027DC  2                               LDX FAKE_DISPATCHER_ADDR
0027DC  2                               STX DISPATCHER_ADDR_LO
0027DC  2                               LDA FAKE_DISPATCHER_ADDR+1
0027DC  2                               STA DISPATCHER_ADDR_HI
0027DC  2               
0027DC  2                               RTS
0027DC  2               
0027DC  2               ; THIS IS JUST FOR TESTING WITH AN EMULATOR
0027DC  2               
0027DC  2               ;******************************************************************
0027DC  2               ; FAKE_DISPATCHER
0027DC  2               ;   Simulates dispatcher calls so we can test in an emulator
0027DC  2               ; This routine saves part of the contents of ZP to absolute memory
0027DC  2               ; and then restores them.
0027DC  2               ;
0027DC  2               ; ZP1 = Address from stack
0027DC  2               ; ZP2 = CMD_LIST
0027DC  2               ; ZP3 = STORAGE
0027DC  2               ; ZP4 = address of string to copy
0027DC  2               ;******************************************************************
0027DC  2               ;*** fake ***
0027DC  2               ; 0 - SMARTPORT
0027DC  2               ; 1 - FUJI_DISK_0
0027DC  2               ; 2 - NETWORK
0027DC  2               ; 3 - NETWORK_1
0027DC  2               ; 4 - NETWORK_2
0027DC  2               
0027DC  2               ADDRESS_ON_STACK        = ZP1
0027DC  2               ADDRESS_ON_STACK_LO     = ZP1_LO
0027DC  2               ADDRESS_ON_STACK_HI     = ZP1_HI
0027DC  2               
0027DC  2               ZCMD_LIST               = ZP2
0027DC  2               ZCMD_LIST_LO            = ZP2_LO
0027DC  2               ZCMD_LIST_HI            = ZP2_HI
0027DC  2               
0027DC  2               ZPAYLOAD                = ZP3
0027DC  2               ZPAYLOAD_LO             = ZP3_LO
0027DC  2               ZPAYLOAD_HI             = ZP3_HI
0027DC  2               
0027DC  2               SRC_STR                 = ZP4
0027DC  2               SRC_STR_LO              = ZP4_LO
0027DC  2               SRC_STR_HI              = ZP4_HI
0027DC  2               
0027DC  2               
0027DC  2               FAKE_DISPATCHER:
0027DC  2                               LDX #$00
0027DC  2               SAVE_ZP:
0027DC  2                               LDA ZP1,X
0027DC  2                               STA SAVED_ZERO_PAGE,X
0027DC  2                               INX
0027DC  2                               CPX #ZP_BLOCK_SIZE
0027DC  2                               BNE SAVE_ZP
0027DC  2               
0027DC  2                               ; ADDRESS OF THE NEXT
0027DC  2                               ; INSTRUCTION MINUS 1
0027DC  2                               ; THIS WILL BE THE (ADDRESS
0027DC  2                               ; OF THE PARAMETERS) - 1
0027DC  2               
0027DC  2                               PLA
0027DC  2                               STA ADDRESS_ON_STACK_LO
0027DC  2                               PLA
0027DC  2                               STA ADDRESS_ON_STACK_HI         ; NWD CONFIRMED CORRECT
0027DC  2               
0027DC  2               ;                JSR CALL_DISPATCHER
0027DC  2               ;
0027DC  2               ;Y+1:            .BYTE SP_CMD_STATUS            ; STATUS CALL COMMAND NUMBER
0027DC  2               ;y+2:            .WORD CMD_LIST
0027DC  2               ;Y+4:            NEXT INSTRUCTION
0027DC  2               
0027DC  2               ; let's play, fake the call!
0027DC  2               
0027DC  2                               JSR WIPE_PAYLOAD                ; CLEAR OUR PAYLOAD
0027DC  2               
0027DC  2                               LDY #$01
0027DC  2                               LDA (ADDRESS_ON_STACK),Y
0027DC  2                               STA REQUESTED_CMD               ; SMARTPORT COMMAND
0027DC  2               
0027DC  2                               LDY #$02                        ; GET CMD_LIST ADDRESS
0027DC  2                               LDA (ADDRESS_ON_STACK),Y
0027DC  2                               STA ZCMD_LIST_LO                ; POINTER TO CMDLIST (STORED_AFTER_CALL)
0027DC  2                               INY ; #$03
0027DC  2                               LDA (ADDRESS_ON_STACK),Y
0027DC  2                               STA ZCMD_LIST_HI                ; NWD CONFIRMED CORRECT
0027DC  2               
0027DC  2                               ; COMMON TO ALL CALLS
0027DC  2                               ; SMARTPORT CONTROLLER CMDLIST
0027DC  2                               ; 0   parameter list length
0027DC  2                               ; 1   unit number
0027DC  2                               ; 2-3 storage
0027DC  2               
0027DC  2                               LDY #$01                        ; CMD_LIST
0027DC  2                               LDA (ZCMD_LIST),Y               ; UNIT #
0027DC  2                               STA REQUESTED_UNIT              ; NWD CONFIRMED CORRECT
0027DC  2               
0027DC  2                               LDY #$02
0027DC  2                               LDA (ZCMD_LIST),Y               ; where to store
0027DC  2                               STA ZPAYLOAD_LO
0027DC  2                               INY ; #$03
0027DC  2                               LDA (ZCMD_LIST),Y               ; NWD CONFIRMED CORRECT
0027DC  2                               STA ZPAYLOAD_HI                 ; WHERE TO STORE RESULT
0027DC  2               
0027DC  2                               LDA REQUESTED_CMD
0027DC  2                               CMP #SP_CMD_STATUS
0027DC  2                               BNE CHECK_READ_CMD
0027DC  2               
0027DC  2                               ; ***********************
0027DC  2                               ; SP_CMD_STATUS
0027DC  2                               ; ***********************
0027DC  2               
0027DC  2                               LDA REQUESTED_UNIT
0027DC  2                               CMP #$00            ; SMARTPORT_CONTROLLER
0027DC  2                               BNE NON_SMARTPORT_CTRLR
0027DC  2               
0027DC  2                               ; SMARTPORT CONTROLLER CMDLIST
0027DC  2                               ; 0   parameter list length
0027DC  2                               ; 1   unit number
0027DC  2                               ; 2-3  status list pointer (lsb-msb)
0027DC  2                               ; 4   status code
0027DC  2               
0027DC  2                               LDY #4
0027DC  2                               LDA (ZCMD_LIST),Y
0027DC  2                               CMP #SP_STATUS_CODE
0027DC  2                               BNE COMPLETE_CMD_            ; DON'T KNOW WHAT TO DO...
0027DC  2               
0027DC  2                               LDY #$00
0027DC  2                               LDA #NUMBER_OF_FAKE_UNITS
0027DC  2                               STA (ZPAYLOAD),Y
0027DC  2                               CLC
0027DC  2                               BCC COMPLETE_CMD_
0027DC  2               
0027DC  2               NON_SMARTPORT_CTRLR:
0027DC  2               ;               LDA REQUESTED_UNIT
0027DC  2                               CMP #1
0027DC  2                               BNE NETWORK_DEV0
0027DC  2               FUJI_DISK1:                                     ; UNIT 1 - FUJINET DISK 0
0027DC  2                               LDA FUJI_DISK_0_STR_ADDR
0027DC  2                               LDY FUJI_DISK_0_STR_ADDR+1
0027DC  2                               LDX FUJI_DISK_0_STR_LEN
0027DC  2                               CLC
0027DC  2                               BCC COPY_2_PAYLOAD_2
0027DC  2               
0027DC  2               NETWORK_DEV0:                                   ; UNIT 2 - NETWORK
0027DC  2               ;               LDA REQUESTED_UNIT
0027DC  2                               CMP #$02
0027DC  2                               BNE NETWORK_1_AND_UP
0027DC  2               
0027DC  2                               LDA NETWORK_STR_ADDR
0027DC  2                               LDY NETWORK_STR_ADDR+1
0027DC  2                               LDX NETWORK_STR_LEN
0027DC  2               
0027DC  2                               CLC
0027DC  2                               BCC COPY_2_PAYLOAD_2
0027DC  2               
0027DC  2               NETWORK_1_AND_UP:
0027DC  2               ;               LDA REQUESTED_UNIT
0027DC  2                               CMP #$05
0027DC  2                               BPL COMPLETE_CMD_
0027DC  2               
0027DC  2                               TAX
0027DC  2                               DEX                             ; UNIT 3/4 = NETWORK_1/2
0027DC  2                               DEX
0027DC  2                               TXA
0027DC  2                               CLC
0027DC  2                               ADC #'0'
0027DC  2                               LDX NETWORK_STR_WITH_NUMBER_INDEX
0027DC  2                               STA NETWORK_STR_WITH_NUMBER,X
0027DC  2               
0027DC  2                               LDA NETWORK_STR_WITH_NUMBER_ADDR
0027DC  2                               LDY NETWORK_STR_WITH_NUMBER_ADDR+1
0027DC  2                               LDX NETWORK_STR_WITH_NUMBER_LEN
0027DC  2                               CLC
0027DC  2                               BCC COPY_2_PAYLOAD_2
0027DC  2               
0027DC  2               CHECK_READ_CMD:
0027DC  2                               LDA REQUESTED_CMD
0027DC  2                               CMP #SP_CMD_READ
0027DC  2                               BNE CHECK_WRITE_CMD
0027DC  2               
0027DC  2                               ; ***********************
0027DC  2                               ; SP_CMD_READ
0027DC  2                               ; ***********************
0027DC  2                               ;Byte  Definition
0027DC  2                               ;0      parameter list length ($04)
0027DC  2                               ;1      unit number
0027DC  2                               ;2-3    input buffer pointer (lsb-msb)
0027DC  2                               ;4-5    byte count
0027DC  2                               ;6-7    address pointer
0027DC  2               
0027DC  2                               LDY #4
0027DC  2                               LDA (ZCMD_LIST),Y
0027DC  2                               STA REQUESTED_BYTES
0027DC  2                               INY
0027DC  2                               LDA (ZCMD_LIST),y
0027DC  2                               STA REQUESTED_BYTES+1
0027DC  2               
0027DC  2                               LDA TEST_BLOCK_STR_ADDR
0027DC  2                               LDY TEST_BLOCK_STR_ADDR+1
0027DC  2                               LDX REQUESTED_BYTES         ; Yeah, I'm cheating, only the low byte
0027DC  2               
0027DC  2               COPY_2_PAYLOAD_2:
0027DC  2                               CLC
0027DC  2                               BCC COPY_2_PAYLOAD
0027DC  2               
0027DC  2               
0027DC  2               COMPLETE_CMD_:
0027DC  2                               BCC COMPLETE_CMD_2
0027DC  2               
0027DC  2               CHECK_WRITE_CMD:
0027DC  2               ;               LDA REQUESTED_CMD
0027DC  2                               CMP #SP_CMD_WRITE
0027DC  2                               BNE CHECK_CONTROL
0027DC  2               
0027DC  2                               ; ***********************
0027DC  2                               ; SP_CMD_WRITE
0027DC  2                               ; ***********************
0027DC  2                               ;Byte  Definition
0027DC  2                               ;0      parameter list length
0027DC  2                               ;1      unit number
0027DC  2                               ;2-3    data buffer pointer
0027DC  2                               ;4-5    byte count
0027DC  2                               ;6-7    address pointer
0027DC  2                               CLC
0027DC  2                               BCC COMPLETE_CMD_2
0027DC  2               
0027DC  2               CHECK_CONTROL:
0027DC  2               ;               LDA REQUESTED_CMD
0027DC  2                               CMP #SP_CMD_CONTROL
0027DC  2                               BNE COMPLETE_CMD_2
0027DC  2               
0027DC  2                               ; ***********************
0027DC  2                               ; SP_CMD_CONTROL
0027DC  2                               ; ***********************
0027DC  2                               LDY #4
0027DC  2                               LDA (ZCMD_LIST),Y
0027DC  2                               STA CONTROL_CMD
0027DC  2               
0027DC  2                               CMP #'O'
0027DC  2                               BNE CTRL_CLOSE
0027DC  2               
0027DC  2                               ; ***********************
0027DC  2                               ; 'O'
0027DC  2                               ; ***********************
0027DC  2                               INC OPEN_COUNT
0027DC  2                               LDA #255
0027DC  2                               STA BYTES_WAITING
0027DC  2                               LDA STATUS_FLAG
0027DC  2                               ORA #FN_STATUS_FLAG_CONNECTED
0027DC  2                               STA STATUS_FLAG
0027DC  2               
0027DC  2               CTRL_CLOSE:
0027DC  2                               CMP #'C'
0027DC  2                               BNE CTRL_R
0027DC  2               
0027DC  2                               LDA OPEN_COUNT
0027DC  2                               BEQ NO_OPENED_FILES
0027DC  2                               DEC OPEN_COUNT
0027DC  2               
0027DC  2               NO_OPENED_FILES:
0027DC  2                               LDA OPEN_COUNT
0027DC  2                               BNE NO_OPENED_FILES2
0027DC  2               
0027DC  2                               LDA STATUS_FLAG         ; CLEAR CONNECTED FLAG
0027DC  2                               AND #FN_STATUS_FLAG_NOT_CONNECTED
0027DC  2                               STA STATUS_FLAG
0027DC  2               
0027DC  2               NO_OPENED_FILES2:
0027DC  2                               ; TODO: SAVE FLAGS
0027DC  2                               CLC
0027DC  2                               BCC COMPLETE_CMD_2
0027DC  2               
0027DC  2               
0027DC  2               CTRL_R:
0027DC  2                               CMP #'R'
0027DC  2                               BNE CTRL_W
0027DC  2               
0027DC  2               COMPLETE_CMD_2:
0027DC  2                               CLC
0027DC  2                               BCC COMPLETE_CMD
0027DC  2               
0027DC  2               CTRL_W:
0027DC  2                               CMP #'W'
0027DC  2                               BNE CTRL_A
0027DC  2               
0027DC  2                               CLC
0027DC  2                               BCC COMPLETE_CMD
0027DC  2               
0027DC  2               CTRL_A:
0027DC  2                               CMP #'A'
0027DC  2                               BNE CTRL_CLOSE_CONNECTION
0027DC  2               
0027DC  2                               CLC
0027DC  2                               BCC COMPLETE_CMD
0027DC  2               
0027DC  2               CTRL_CLOSE_CONNECTION:
0027DC  2                               CMP #'c'
0027DC  2                               BNE CTRL_D
0027DC  2               
0027DC  2                               CLC
0027DC  2                               BCC COMPLETE_CMD
0027DC  2               
0027DC  2               
0027DC  2               CTRL_D:
0027DC  2                               CMP #'D'
0027DC  2                               BNE COMPLETE_CMD
0027DC  2               
0027DC  2                               CLC
0027DC  2                               BCC COMPLETE_CMD
0027DC  2               
0027DC  2               
0027DC  2                               ;Byte   Definition
0027DC  2                               ; 'O'-open
0027DC  2                               ;0-1    payload size
0027DC  2                               ;2      mode read or write or both
0027DC  2                               ;3      translation
0027DC  2                               ;4...   url
0027DC  2                               ;
0027DC  2                               ; 'C'-close
0027DC  2                               ;0-1    payload size $00
0027DC  2                               ;
0027DC  2                               ; 'R'-read
0027DC  2                               ;0-1   payload size (bytes to return)
0027DC  2                               ;2..   data
0027DC  2                               ;
0027DC  2                               ; 'W'-write
0027DC  2                               ; 0-1  payload size (bytes to write)
0027DC  2                               ; 2..  data
0027DC  2                               ;
0027DC  2                               ; 'A'-accept
0027DC  2                               ; accept connection
0027DC  2                               ;0-1    payload size $00?
0027DC  2                               ;
0027DC  2                               ; 'c'-close connection
0027DC  2                               ; close client connection
0027DC  2                               ;0-1    payload size $00?
0027DC  2                               ;
0027DC  2                               ;'D'-udp destination
0027DC  2                               ; set UDP destination
0027DC  2                               ;0-1    payload size?
0027DC  2                               ;2...   url?
0027DC  2               
0027DC  2               COPY_2_PAYLOAD:
0027DC  2               
0027DC  2                               ; SP_PAYLOAD+4 LENGTH
0027DC  2                               ; SP_PAYLOAD+5 STRING
0027DC  2               
0027DC  2                               STA SRC_STR_LO                      ; GET THE STRING FROM
0027DC  2                               STY SRC_STR_HI
0027DC  2               
0027DC  2                               TXA
0027DC  2                               LDY #4                          ; PAYLOAD+4
0027DC  2                               STA (ZPAYLOAD),Y                     ; STORE THE LENGTH
0027DC  2               
0027DC  2                               TXA                             ; LENGTH OF STRING
0027DC  2                               TAY
0027DC  2                               STY GET_INDEX
0027DC  2               
0027DC  2                               INY
0027DC  2                               INY
0027DC  2                               INY
0027DC  2                               INY
0027DC  2                               INY
0027DC  2               
0027DC  2                               STY STORE_INDEX
0027DC  2                               INX
0027DC  2               CPY2PAYLOAD:
0027DC  2                               LDY GET_INDEX
0027DC  2                               LDA (SRC_STR),Y                     ; GET THE STRING
0027DC  2                               LDY STORE_INDEX
0027DC  2                               STA (ZPAYLOAD),Y                     ; STORE THE STRING
0027DC  2               
0027DC  2                               DEC STORE_INDEX
0027DC  2                               DEC GET_INDEX
0027DC  2                               DEX
0027DC  2                               BNE CPY2PAYLOAD
0027DC  2               
0027DC  2               COMPLETE_CMD:
0027DC  2                               LDX #255                        ; buf buffer, but we don't care
0027DC  2                               STX SP_COUNT
0027DC  2                               LDY #$00
0027DC  2                               STY SP_COUNT+1
0027DC  2               
0027DC  2                               ; INCREASE ADDRESS BY NUMBER OF PARAMETERS
0027DC  2               
0027DC  2                               LDY #$02
0027DC  2                               LDA (ADDRESS_ON_STACK),Y
0027DC  2                               STA ZCMD_LIST_LO                      ; CMD_LIST
0027DC  2                               INY
0027DC  2                               LDA (ADDRESS_ON_STACK),Y
0027DC  2                               STA ZCMD_LIST_HI
0027DC  2               
0027DC  2                               LDY #$00
0027DC  2                               LDA (ZCMD_LIST),Y           ; NUMBER OF PARAMETERS
0027DC  2                               TAY                         ; ADD ONE
0027DC  2                               INY
0027DC  2                               TYA
0027DC  2                               CLC                         ; ADD THE NUMBER OF PARAMETERS + 1TO THE
0027DC  2                               ADC ADDRESS_ON_STACK_LO     ; ADDRESS THAT WAS ON THE STACK
0027DC  2                               STA ADDRESS_ON_STACK_LO     ; WHEN WE CAME HERE.
0027DC  2                               LDA ADDRESS_ON_STACK_HI     ; THAT GIVES US THE ADDRESS WE ARE
0027DC  2                               ADC #$00                    ; TO CONTINUE FROM
0027DC  2                               STA ADDRESS_ON_STACK_HI
0027DC  2               
0027DC  2                               LDA ADDRESS_ON_STACK_LO
0027DC  2                               STA CONTINUE_ADDRESS        ; CONTINUE ADDRESS IS NOW POINTING
0027DC  2                               LDA ADDRESS_ON_STACK_HI     ; TO THE ADDRESS FOLLOWING THE PARAMETERS
0027DC  2                               STA CONTINUE_ADDRESS+1
0027DC  2               
0027DC  2                               LDY #$00                    ; RESTORE THE ZERO PAGE DATA
0027DC  2               RESTORE_ZP:
0027DC  2                               LDA SAVED_ZERO_PAGE,Y
0027DC  2                               STA ZP1,Y
0027DC  2               
0027DC  2                               INY
0027DC  2                               CPY #ZP_BLOCK_SIZE
0027DC  2                               BNE RESTORE_ZP
0027DC  2               
0027DC  2                               LDA #SP_ERROR_OK
0027DC  2                               CLC                         ; NO ERROR
0027DC  2               
0027DC  2                               ; CONTINUE EXECUTION AFTER PARAMETERS
0027DC  2               
0027DC  2                               .BYTE $4C                   ; JMP
0027DC  2               CONTINUE_ADDRESS:
0027DC  2                               .WORD $0000
0027DC  2               
0027DC  2               
0027DC  2               
0027DC  2               .ENDIF
0027DC  2               
0027DC  1                               .include "FUJINET.S"
0027DC  2               ;*****************************************************
0027DC  2               ; FUJINET.S
0027DC  2               ; BASIC to Fujinet
0027DC  2               ; By Norman Davie
0027DC  2               
0027DC  2                   .include "MACROS.S"
0027DC  3               .IF .NOT .DEFINED(MACROS)
0027DC  3               
0027DC  3               MACROS=1
0027DC  3               
0027DC  3               .MACRO SAVE_REGS
0027DC  3                       STA MACRO_A
0027DC  3                       PHP
0027DC  3                       PHA
0027DC  3                       TXA
0027DC  3                       PHA
0027DC  3                       TYA
0027DC  3                       PHA
0027DC  3                       LDA MACRO_A
0027DC  3               .ENDMACRO
0027DC  3               
0027DC  3               .MACRO RESTORE_REGS
0027DC  3                       PLA
0027DC  3                       TAY
0027DC  3                       PLA
0027DC  3                       TAX
0027DC  3                       PLA
0027DC  3                       PLP
0027DC  3               .ENDMACRO
0027DC  3               
0027DC  3               .MACRO PRINT_STR STR
0027DC  3                       SAVE_REGS
0027DC  3                       LDA STR
0027DC  3                       LDY STR+1
0027DC  3                       JSR STROUT
0027DC  3                       RESTORE_REGS
0027DC  3               .ENDMACRO
0027DC  3               
0027DC  3               .MACRO PRINT_OUT STR
0027DC  3                       SAVE_REGS
0027DC  3                       LDA #<STR
0027DC  3                       LDY #>STR
0027DC  3                       JSR STROUT
0027DC  3                       RESTORE_REGS
0027DC  3               .ENDMACRO
0027DC  3               
0027DC  3               
0027DC  3               .ENDIF
0027DC  3               
0027DC  2                   .include "REGS.S"
0027DC  3               .IF .NOT .DEFINED(PRINT_X)
0027DC  3               
0027DC  3               PRINT_X:
0027DC  3  20 44 F9             JSR PRTX
0027DF  3  A9 A0                LDA #' ' + $80
0027E1  3  20 ED FD             JSR COUT
0027E4  3  60                   RTS
0027E5  3               
0027E5  3               
0027E5  3               
0027E5  3               
0027E5  3               
0027E5  3               PRINT_FLAG:
0027E5  3  48                   PHA
0027E6  3               
0027E6  3  8E FF 31             STX TEMP_CHAR
0027E9  3  8C FE 31             STY TEMP_AND
0027EC  3               
0027EC  3  29 80                AND #$80
0027EE  3  D0 06                BNE FLAG_SET
0027F0  3  AD FF 31             LDA TEMP_CHAR
0027F3  3  18                   CLC
0027F4  3  90 00                BCC PRINT_FLAG_DONE
0027F6  3               FLAG_SET:
0027F6  3               
0027F6  3               PRINT_FLAG_DONE:
0027F6  3  20 ED FD             JSR COUT
0027F9  3  68                   PLA
0027FA  3  60                   RTS
0027FB  3               
0027FB  3               PRINT_FLAGS:
0027FB  3  A9 ED                LDA #<STR_P
0027FD  3  A0 31                LDY #>STR_P
0027FF  3  20 3A DB             JSR STROUT
002802  3  AD FD 31             LDA TEMP_P      ; Load accumulator with contents of $0018
002805  3               
002805  3  AA                   TAX
002806  3  20 44 F9             JSR PRTX
002809  3  A9 A0                LDA #' ' + $80
00280B  3  20 ED FD             JSR COUT
00280E  3               
00280E  3  A9 80                LDA #$80
002810  3  A2 4E                LDX #'N'
002812  3  4A                   LSR
002813  3  20 E5 27             JSR PRINT_FLAG
002816  3               
002816  3  A2 56                LDX #'V'
002818  3  4A                   LSR
002819  3  20 E5 27             JSR PRINT_FLAG
00281C  3               
00281C  3  A2 2E                LDX #'.'
00281E  3  4A                   LSR
00281F  3  20 E5 27             JSR PRINT_FLAG
002822  3               
002822  3  A2 42                LDX #'B'
002824  3  4A                   LSR
002825  3  20 E5 27             JSR PRINT_FLAG
002828  3               
002828  3  A2 44                LDX #'D'
00282A  3  4A                   LSR
00282B  3  20 E5 27             JSR PRINT_FLAG
00282E  3               
00282E  3  A2 49                LDX #'I'
002830  3  4A                   LSR
002831  3  20 E5 27             JSR PRINT_FLAG
002834  3               
002834  3  A2 5A                LDX #'Z'
002836  3  4A                   LSR
002837  3  20 E5 27             JSR PRINT_FLAG
00283A  3               
00283A  3  A2 43                LDX #'C'
00283C  3  4A                   LSR
00283D  3  20 E5 27             JSR PRINT_FLAG
002840  3               
002840  3  60                   RTS
002841  3               
002841  3               PRINT_REGS:
002841  3  08                   PHP
002842  3               
002842  3  8D FA 31             STA TEMP_A
002845  3               
002845  3  68                   PLA             ; GET THE PROCESSOR FLAG
002846  3  48                   PHA
002847  3               
002847  3  A9 80                LDA #$80
002849  3  8D FD 31             STA TEMP_P
00284C  3               
00284C  3  8E FB 31             STX TEMP_X
00284F  3  8C FC 31             STY TEMP_Y
002852  3               
002852  3  8D F9 31 08          SAVE_REGS
002856  3  48 8A 48 98  
00285A  3  48 AD F9 31  
00285E  3  A9 E9                LDA #<STR_A
002860  3  A0 31                LDY #>STR_A
002862  3  20 3A DB             JSR STROUT
002865  3  AE FA 31             LDX TEMP_A
002868  3  20 44 F9             JSR PRTX
00286B  3               
00286B  3  A9 E1                LDA #<STR_X
00286D  3  A0 31                LDY #>STR_X
00286F  3  20 3A DB             JSR STROUT
002872  3  AE FB 31             LDX TEMP_X
002875  3  20 44 F9             JSR PRTX
002878  3               
002878  3  A9 E5                LDA #<STR_Y
00287A  3  A0 31                LDY #>STR_Y
00287C  3  20 3A DB             JSR STROUT
00287F  3  AE FC 31             LDX TEMP_Y
002882  3  20 44 F9             JSR PRTX
002885  3               
002885  3               ;        JSR PRINT_FLAGS
002885  3               
002885  3  20 8E FD             JSR CROUT
002888  3  68 A8 68 AA          RESTORE_REGS
00288C  3  68 28        
00288E  3               
00288E  3  28                   PLP
00288F  3               
00288F  3  60                   RTS
002890  3               
002890  3               
002890  3               STACK_ITEMS = 10
002890  3               PRINT_STACK:
002890  3  8D F9 31 08          SAVE_REGS
002894  3  48 8A 48 98  
002898  3  48 AD F9 31  
00289C  3               
00289C  3  A9 F1                LDA #<STR_STACK
00289E  3  A0 31                LDY #>STR_STACK
0028A0  3  20 3A DB             JSR STROUT
0028A3  3               
0028A3  3  BA                   TSX
0028A4  3  E8                   INX             ; NOW AT TOP OF STACK WITH DATA
0028A5  3               
0028A5  3  E8                   INX             ; IGNORE THE STUFF WE PUT ON THE STACK ; PHP
0028A6  3  E8                   INX             ; Y
0028A7  3  E8                   INX             ; X
0028A8  3  E8                   INX             ; A
0028A9  3               
0028A9  3  A0 0A                LDY #STACK_ITEMS
0028AB  3               
0028AB  3               NEXT_STACK_ITEM:
0028AB  3  8A                   TXA
0028AC  3  48                   PHA
0028AD  3               
0028AD  3  BD 00 01             LDA $0100,X     ;
0028B0  3  AA                   TAX
0028B1  3               
0028B1  3  8D F9 31 08          SAVE_REGS
0028B5  3  48 8A 48 98  
0028B9  3  48 AD F9 31  
0028BD  3  20 DC 27             JSR PRINT_X
0028C0  3  68 A8 68 AA          RESTORE_REGS
0028C4  3  68 28        
0028C6  3               
0028C6  3  68                   PLA
0028C7  3  AA                   TAX
0028C8  3               
0028C8  3  E8                   INX
0028C9  3  88                   DEY
0028CA  3  D0 DF                BNE NEXT_STACK_ITEM
0028CC  3               
0028CC  3  20 8E FD             JSR CROUT
0028CF  3  68 A8 68 AA          RESTORE_REGS
0028D3  3  68 28        
0028D5  3               
0028D5  3  60                   RTS
0028D6  3               
0028D6  3               
0028D6  3               
0028D6  3               GETCHR:
0028D6  3  A9 00                LDA #<WAIT_STR
0028D8  3  A0 32                LDY #>WAIT_STR
0028DA  3  20 3A DB             JSR STROUT
0028DD  3               
0028DD  3               CHK_KEY:
0028DD  3  AD 00 C0             LDA KYBD
0028E0  3  C9 80                CMP #$80        ; KEYPRESS?
0028E2  3  90 F9                BCC CHK_KEY     ; NO, TRY AGAIN
0028E4  3  8D 10 C0             STA STROBE      ; CLEAR KYBD STROBE
0028E7  3                       ;A = CHARACTER
0028E7  3  60                   RTS
0028E8  3               
0028E8  3               .ENDIF
0028E8  3               
0028E8  2               
0028E8  2               FN_OK                   = 0
0028E8  2               FN_ERR                  = $FE
0028E8  2               FN_NO_NETWORK           = $FD
0028E8  2               
0028E8  2               FN_ERR_WRITE_ONLY       = 131	    ;$83 Protocol is in Write-only mode
0028E8  2               FN_ERR_INVALID_COMMAND  = 132	    ;$84 Protocol was sent an invalid command
0028E8  2               FN_ERR_MISSING_PROTO    = 133	    ;$85 No protocol attached.
0028E8  2               FN_ERR_READ_ONLY        = 135	    ;$86 Protocol is in read-only mode
0028E8  2               FN_ERR_TIMED_OUT        = 138	    ;$8A Timed out
0028E8  2               FN_ERR_CRITICAL         = 144	    ;$90 A critical error occurred. SIO reports this, get the actual Error code from byte 4 of STATUS.
0028E8  2               FN_ERR_CMD_NOT_IMPLEMENTED = 146	;$92 Command not implemented
0028E8  2               FN_ERR_FILE_EXISTS      = 151	    ;$97 File Exists
0028E8  2               FN_ERR_NO_SPACE         = 162	    ;$A2 No space on device
0028E8  2               FN_ERR_INVALID_URL      = 165	    ;$A5 Invalid Devicespec
0028E8  2               FN_ERR_ACCESS_DENIED    = 167	    ;$A7 Access Denied
0028E8  2               FN_ERR_FILE_NOT_FOUND   = 170	    ;$AA File not found (emitted by filesystem adaptors)
0028E8  2               FN_ERR_REFUSED          = 200	    ;$C8 Connection Refused (equivalent to errno ECONNREFUSED)
0028E8  2               FN_ERR_UNREACHABLE      = 201	    ;$C9 Network Unreachable (equivalent to errno ENETUNREACH)
0028E8  2               FN_ERR_CONNECTION_TIMEOUT   = 202	;$CA Connection Timeout (equivalent to errno ETIMEDOUT)
0028E8  2               FN_ERR_NETWORK_DOWN     = 203	    ;$CB Network is down (equivalent to errno ENETDOWN)
0028E8  2               FN_ERR_CONNECTION_RESET = 204	    ;$CC Connection was reset during read/write (equivalent to errno ECONNRESET)
0028E8  2               FN_ERR_CIP              = 205	    ;$CD Connection in progress (EAGAIN)
0028E8  2               FN_ERR_ADDRESS_IN_USE   = 206	    ;$CE Address in use (EADDRINUSE)
0028E8  2               FN_ERR_NOT_CONNECTED    = 207	    ;$CF Not Connected
0028E8  2               FN_ERR_SERVER_NOT_RUNNING = 208	    ;$D0 Server not Running
0028E8  2               FN_ERR_NO_CONNECTION_WAITING = 209	;$D1 No connection waiting
0028E8  2               FN_ERR_SERVICE_NOT_AVAILABLE = 210	;$D2 Service Not Available
0028E8  2               FN_ERR_CONNECTION_ABORTED = 211	    ;$D3 Connection Aborted
0028E8  2               FN_ERR_BAD_CREDENTIALS  = 212	    ;$D4 Invalid Username or Password (debating whether to overload as access denied.)
0028E8  2               FN_ERR_MEMORY_ERROR     = 255	    ;$FF Could not allocate either receive or transmit buffers.
0028E8  2               
0028E8  2               
0028E8  2               
0028E8  2               ;******************************************************************;
0028E8  2               ; CPY_STR_TO_SP_PAYLOAD
0028E8  2               ; Copy the length proceeded string to the Smartport buffer
0028E8  2               ;
0028E8  2               ; INPUT
0028E8  2               ;  A = high address
0028E8  2               ;  Y = low address
0028E8  2               ;  X = length
0028E8  2               ; RETURNS
0028E8  2               ;  X = String length
0028E8  2               ;******************************************************************
0028E8  2               CPY_STR_TO_SP_PAYLOAD:
0028E8  2  85 EB                        STA ZP1_LO
0028EA  2  84 EC                        STY ZP1_HI
0028EC  2  86 ED                        STX ZP2
0028EE  2               
0028EE  2               
0028EE  2  A0 00                        LDY #$00
0028F0  2               CONT3:
0028F0  2  B1 EB                        LDA (ZP1),Y
0028F2  2  99 51 32                     STA SP_PAYLOAD+5,Y
0028F5  2  C8                           INY
0028F6  2  C4 ED                        CPY ZP2
0028F8  2  D0 F6                        BNE CONT3
0028FA  2               
0028FA  2               GOT_LENGTH2:
0028FA  2               
0028FA  2  8C 50 32                     STY SP_PAYLOAD+4        ; STORE LENGTH
0028FD  2  AE 50 32                     LDX SP_PAYLOAD+4
002900  2  60                           RTS
002901  2               
002901  2               ;******************************************************************
002901  2               ; CPY_URL_TO_SP_PAYLOAD
002901  2               ; Copy the BASIC URL into the Smartport buffer as a zero
002901  2               ; terminated string
002901  2               ;
002901  2               ; INPUT
002901  2               ;  A = high address
002901  2               ;  Y = low address
002901  2               ; RETURNS
002901  2               ;
002901  2               ;******************************************************************
002901  2               CPY_URL_TO_SP_PAYLOAD:
002901  2               
002901  2               
002901  2  AE 71 2B                     LDX URL_LEN
002904  2  A9 00                        LDA #$00
002906  2  9D 50 32                     STA SP_PAYLOAD+4,X  ; NULL TERMINATE STRING
002909  2               
002909  2  AD 71 2C                     LDA URL_ADDR        ; STRING WITHOUT LENGTH
00290C  2  AC 72 2C                     LDY URL_ADDR+1
00290F  2               
00290F  2  86 ED                        STX ZP2
002911  2  85 EB                        STA ZP1_LO
002913  2  84 EC                        STY ZP1_HI
002915  2               
002915  2  A2 00                        LDX #$00
002917  2  A0 00                        LDY #$00
002919  2               KEEP_CALM_AND_CARRY_ON:
002919  2  B1 EB                        LDA (ZP1),Y
00291B  2  9D 50 32                     STA SP_PAYLOAD+4,X
00291E  2  E4 ED                        CPX ZP2
002920  2  F0 05                        BEQ CPY_DONE
002922  2  C8                           INY
002923  2  E8                           INX
002924  2  18                           CLC
002925  2  90 F2                        BCC KEEP_CALM_AND_CARRY_ON
002927  2               
002927  2               CPY_DONE:
002927  2               
002927  2  60                           RTS
002928  2               
002928  2               ;******************************************************************
002928  2               ; CPY_BUF_TO_SP_PAYLOAD
002928  2               ; Copy the BASIC URL into the Smartport buffer as a zero
002928  2               ; terminated string
002928  2               ;
002928  2               ; INPUT
002928  2               ;  A = high address
002928  2               ;  Y = low address
002928  2               ; RETURNS
002928  2               ;
002928  2               ;******************************************************************
002928  2               CPY_BUF_TO_CTRL_SP_PAYLOAD:
002928  2               
002928  2  86 ED                        STX ZP2
00292A  2  85 EB                        STA ZP1_LO
00292C  2  84 EC                        STY ZP1_HI
00292E  2               
00292E  2  A2 00                        LDX #$00
002930  2  A0 00                        LDY #$00
002932  2               KEEP_CALM:
002932  2  B1 EB                        LDA (ZP1),Y
002934  2  9D 4E 32                     STA SP_PAYLOAD+2,X
002937  2  E4 ED                        CPX ZP2
002939  2  F0 05                        BEQ CPY_DONE2
00293B  2  C8                           INY
00293C  2  E8                           INX
00293D  2  18                           CLC
00293E  2  90 F2                        BCC KEEP_CALM
002940  2               
002940  2               CPY_DONE2:
002940  2  60                           RTS
002941  2               
002941  2               CPY_BUF_TO_WRITE_SP_PAYLOAD:
002941  2               
002941  2  86 ED                        STX ZP2
002943  2  85 EB                        STA ZP1_LO
002945  2  84 EC                        STY ZP1_HI
002947  2               
002947  2  A2 00                        LDX #$00
002949  2  A0 00                        LDY #$00
00294B  2               KEEP_CALM3:
00294B  2  B1 EB                        LDA (ZP1),Y
00294D  2  9D 4C 32                     STA SP_PAYLOAD,X
002950  2  E4 ED                        CPX ZP2
002952  2  F0 05                        BEQ CPY_DONE3
002954  2  C8                           INY
002955  2  E8                           INX
002956  2  18                           CLC
002957  2  90 F2                        BCC KEEP_CALM3
002959  2               
002959  2               CPY_DONE3:
002959  2  60                           RTS
00295A  2               ;******************************************************************
00295A  2               ; FN_OPEN
00295A  2               ; Open the specified UNIT, gets it ready for reading or writing
00295A  2               ;
00295A  2               ; INPUT
00295A  2               ; X = UNIT DESTINATION
00295A  2               ;******************************************************************
00295A  2               FN_OPEN:
00295A  2               
00295A  2               .IF .NOT STRIP_TRACE
00295A  2                               SAVE_REGS
00295A  2                               TXA
00295A  2                               PHA
00295A  2                               LDA TRACE_FLAG
00295A  2                               BEQ NO_TRACE20
00295A  2                               PRINT_STR FN_OPEN_STR_ADDR
00295A  2                               PLA
00295A  2                               PHA
00295A  2                               TAX
00295A  2                               JSR PRTX
00295A  2                               LDA #SPACE
00295A  2                               JSR COUT
00295A  2               
00295A  2               NO_TRACE20:
00295A  2                               PLA
00295A  2                               RESTORE_REGS
00295A  2               .ENDIF
00295A  2               
00295A  2  8A                           TXA                         ; X CONTAINS THE UNIT NUMBER
00295B  2  48                           PHA
00295C  2               
00295C  2                               ; STAGE #1
00295C  2                               ; OPEN THE DEVICE #X
00295C  2  20 A0 25                     JSR SP_OPEN
00295F  2  8D 5C 36                     STA FN_LAST_ERR
002962  2  90 08                        BCC CONT2
002964  2               OPEN_ERR:
002964  2               
002964  2               .IF .NOT STRIP_TRACE
002964  2               .IF .NOT EXT_TRACE
002964  2                               LDA #<OPEN_ERR_STR
002964  2                               LDY #>OPEN_ERR_STR
002964  2               
002964  2                               JSR STROUT
002964  2                               LDX FN_LAST_ERR
002964  2                               JSR PRTX
002964  2                               JSR CROUT
002964  2               .ENDIF
002964  2               .ENDIF
002964  2  68                           PLA
002965  2  38                           SEC
002966  2  A2 FE                        LDX #FN_ERR
002968  2  AD 5C 36                     LDA FN_LAST_ERR
00296B  2  60                           RTS
00296C  2               
00296C  2               CONT2:
00296C  2  68                           PLA                         ; GET BACK UNIT NUMBER
00296D  2  48                           PHA
00296E  2  AA                           TAX
00296F  2               
00296F  2               ; FUJINET SPECIFC
00296F  2               ;Byte   Definition
00296F  2               ; 'O'-open
00296F  2               ;0-1    payload size
00296F  2               ;2      mode read or write or both
00296F  2               ;3      translation
00296F  2               ;4...   url
00296F  2                               ; STAGE #2
00296F  2                               ; SET PAYLOAD SIZE
00296F  2  A0 04                        LDY #$04                    ; PAYLOAD SIZE = 3 + NULL ON STRING
002971  2  8C 4C 32                     STY SP_PAYLOAD
002974  2  A0 00                        LDY #$00
002976  2  8C 4D 32                     STY SP_PAYLOAD+1
002979  2               
002979  2  AD 71 2B                     LDA URL_LEN                 ; PAYLOAD += URL_LEN
00297C  2  18                           CLC
00297D  2  6D 4C 32                     ADC SP_PAYLOAD
002980  2  8D 4C 32                     STA SP_PAYLOAD
002983  2  AD 4D 32                     LDA SP_PAYLOAD+1
002986  2  69 00                        ADC #$00
002988  2  8D 4D 32                     STA SP_PAYLOAD+1
00298B  2               
00298B  2                               ; FILL PAYLOAD - Read/write mode
00298B  2  AD 6F 2B                     LDA MODE                    ; READ OR WRITE OR BOTH
00298E  2  8D 4E 32                     STA SP_PAYLOAD+2
002991  2               
002991  2                               ; FILL PAYLOAD - Character translation
002991  2  AD 70 2B                     LDA TRANSLATION             ; CHARACTER TRANSLATION
002994  2  8D 4F 32                     STA SP_PAYLOAD+3
002997  2               
002997  2                               ; FILL PAYLOAD - Transfer BASIC URL to payload
002997  2  20 01 29                     JSR CPY_URL_TO_SP_PAYLOAD   ; TRANSFER THE URL
00299A  2               
00299A  2               .IF .NOT STRIP_TRACE
00299A  2               .IF EXT_TRACE
00299A  2                               SAVE_REGS
00299A  2                               LDA TRACE_FLAG
00299A  2                               BEQ NO_TRACE21
00299A  2               
00299A  2                               PRINT_STR MODE_STR_ADDR
00299A  2                               LDX MODE
00299A  2                               JSR PRINT_X
00299A  2               
00299A  2                               PRINT_STR TRANS_STR_ADDR
00299A  2                               LDX TRANSLATION
00299A  2                               JSR PRINT_X
00299A  2               
00299A  2                               PRINT_STR PAYLOAD_STR_ADDR
00299A  2                               ;JSR DUMP_SP_PAYLOAD        ; PRINT THE URL
00299A  2                               JSR CROUT
00299A  2               NO_TRACE21:
00299A  2                               RESTORE_REGS
00299A  2               .ENDIF
00299A  2               .ENDIF
00299A  2               
00299A  2  68                           PLA                         ; GET BACK OUR DEVICE NUMBER
00299B  2  AA                           TAX
00299C  2               
00299C  2                               ; STAGE #3
00299C  2                               ; CALL FUJINET OPEN
00299C  2  A0 4F                        LDY #'O'                    ; SEND 'O' TO FUJINET
00299E  2  20 C2 25                     JSR SP_CONTROL
0029A1  2  8D 5C 36                     STA FN_LAST_ERR
0029A4  2  90 07                        BCC OPEN_OK2
0029A6  2               CTRL_ERR:
0029A6  2               
0029A6  2               .IF .NOT STRIP_TRACE
0029A6  2                               LDA #<CTRL_ERR_STR
0029A6  2                               LDY #>CTRL_ERR_STR
0029A6  2                               JSR STROUT
0029A6  2                               LDX FN_LAST_ERR
0029A6  2                               JSR PRTX
0029A6  2                               JSR CROUT
0029A6  2               .ENDIF
0029A6  2  38                           SEC
0029A7  2  A2 FE                        LDX #FN_ERR
0029A9  2  AD 5C 36                     LDA FN_LAST_ERR
0029AC  2  60                           RTS
0029AD  2               
0029AD  2               OPEN_OK2:
0029AD  2  A2 00                        LDX #FN_OK
0029AF  2  60                           RTS
0029B0  2               
0029B0  2               
0029B0  2               ;
0029B0  2               ; 'C'-close
0029B0  2               ;0-1    payload size $00
0029B0  2               ;
0029B0  2               ;'R'
0029B0  2               ;0-1   payload size (bytes to return)
0029B0  2               ;2..   data
0029B0  2               ;
0029B0  2               ;'W'
0029B0  2               ; 0-1  payload size (bytes to write)
0029B0  2               ; 2..  data
0029B0  2               ;
0029B0  2               ;'A'
0029B0  2               ; accept connection
0029B0  2               ;
0029B0  2               ; 'c'
0029B0  2               ; close client connection
0029B0  2               ;
0029B0  2               ;'D'
0029B0  2               ; set UDP destination
0029B0  2               
0029B0  2               
0029B0  2               SMARTPORT_READ  = 1
0029B0  2               SMARTPORT_WRITE = 1
0029B0  2               .IF SMARTPORT_READ
0029B0  2               ;******************************************************************
0029B0  2               ; FN_READ - SMARTPORT VERSION
0029B0  2               ; Read the specified UNIT
0029B0  2               ;
0029B0  2               ; INPUT
0029B0  2               ; X = UNIT DESTINATION
0029B0  2               ; BUFLEN = NUMBER OF BYTES TO READ
0029B0  2               ;******************************************************************
0029B0  2               FN_READ:
0029B0  2               
0029B0  2               .IF .NOT STRIP_TRACE
0029B0  2                               SAVE_REGS
0029B0  2                               TXA
0029B0  2                               PHA
0029B0  2                               LDA TRACE_FLAG
0029B0  2                               BEQ NO_TRACE22
0029B0  2               
0029B0  2                               PRINT_STR FN_READ_STR_ADDR
0029B0  2                               PLA
0029B0  2                               PHA
0029B0  2                               TAX
0029B0  2                               JSR PRTX
0029B0  2                               JSR CROUT
0029B0  2               NO_TRACE22:
0029B0  2                               PLA
0029B0  2                               RESTORE_REGS
0029B0  2               
0029B0  2               .ENDIF
0029B0  2                               ; X = DEVICE
0029B0  2  AC 76 2D                     LDY BUFLEN              ; MAX PAYLOAD IS 255
0029B3  2  20 E2 25                     JSR SP_READ
0029B6  2  8D 5C 36                     STA FN_LAST_ERR
0029B9  2  90 08                        BCC READ_OK
0029BB  2               
0029BB  2               
0029BB  2               READ_ERR:
0029BB  2               
0029BB  2               .IF .NOT STRIP_TRACE
0029BB  2               .IF EXT2_TRACE
0029BB  2                               PRINT_STR FN_READ_ERROR_STR_ADDR
0029BB  2                               JSR DUMP_SP_PAYLOAD
0029BB  2               .ENDIF
0029BB  2               .ENDIF
0029BB  2               
0029BB  2  A2 FE                        LDX #FN_ERR
0029BD  2  AD 5C 36                     LDA FN_LAST_ERR
0029C0  2  18                           CLC
0029C1  2  90 02                        BCC READ_DONE
0029C3  2               READ_OK:
0029C3  2               
0029C3  2  A2 00                        LDX #FN_OK
0029C5  2               READ_DONE:
0029C5  2  AC 32 32                     LDY SP_COUNT
0029C8  2  AD 34 32                     LDA LAST_SP_ERR
0029CB  2  60                           RTS
0029CC  2               .ELSE
0029CC  2               
0029CC  2               ;******************************************************************
0029CC  2               ; FN_READ - **** CONTROL VERSION ****
0029CC  2               ; Read the specified UNIT
0029CC  2               ;
0029CC  2               ; INPUT
0029CC  2               ; X = UNIT DESTINATION
0029CC  2               ; BUFLEN = NUMBER OF BYTES TO READ
0029CC  2               ;******************************************************************
0029CC  2               
0029CC  2               FN_READ:
0029CC  2               
0029CC  2               .IF .NOT STRIP_TRACE
0029CC  2                               SAVE_REGS
0029CC  2                               TXA
0029CC  2                               PHA
0029CC  2                               LDA TRACE_FLAG
0029CC  2                               BEQ NO_TRACE22
0029CC  2               
0029CC  2                               PRINT_STR FN_READ_STR_ADDR
0029CC  2                               PLA
0029CC  2                               PHA
0029CC  2                               TAX
0029CC  2                               JSR PRTX
0029CC  2                               JSR CROUT
0029CC  2               NO_TRACE22:
0029CC  2                               PLA
0029CC  2                               RESTORE_REGS
0029CC  2               
0029CC  2               .ENDIF
0029CC  2               
0029CC  2               ;'R'
0029CC  2               ;0-1   payload size (bytes to return)
0029CC  2               ;2..   data
0029CC  2               ;
0029CC  2                               ; SET PAYLOAD SIZE
0029CC  2               
0029CC  2                               LDY BUFLEN              ; PAYLOAD SIZE
0029CC  2                               STY SP_PAYLOAD
0029CC  2                               LDA #$00
0029CC  2                               STA SP_PAYLOAD+1
0029CC  2               
0029CC  2                               LDY #'R'
0029CC  2                               JSR SP_CONTROL
0029CC  2                               STA FN_LAST_ERR
0029CC  2                               BCC READ_OK
0029CC  2               
0029CC  2               READ_ERR:
0029CC  2               
0029CC  2               .IF .NOT STRIP_TRACE
0029CC  2               .IF EXT2_TRACE
0029CC  2                               PRINT_STR FN_READ_ERROR_STR_ADDR
0029CC  2                               JSR DUMP_SP_PAYLOAD
0029CC  2               .ENDIF
0029CC  2               .ENDIF
0029CC  2               
0029CC  2                               LDX #FN_ERR
0029CC  2                               LDA FN_LAST_ERR
0029CC  2                               CLC
0029CC  2                               BCC READ_DONE
0029CC  2               READ_OK:
0029CC  2               
0029CC  2               .IF .NOT STRIP_TRACE
0029CC  2                               JSR DUMP_SP_PAYLOAD_HEX
0029CC  2               .ENDIF
0029CC  2                               LDX #FN_OK
0029CC  2               READ_DONE:
0029CC  2                               LDY SP_COUNT
0029CC  2                               LDA LAST_SP_ERR
0029CC  2                               RTS
0029CC  2               .ENDIF
0029CC  2               
0029CC  2               
0029CC  2               .IF SMARTPORT_WRITE
0029CC  2               ;******************************************************************
0029CC  2               ; FN_WRITE - SMARTPORT VERSION
0029CC  2               ; Read the specified UNIT
0029CC  2               ;
0029CC  2               ; INPUT
0029CC  2               ; X = UNIT DESTINATION
0029CC  2               ; BUF    = THE CONTENT TO SEND
0029CC  2               ; BUFLEN = NUMBER OF BYTES TO WRITE
0029CC  2               ;******************************************************************
0029CC  2               FN_WRITE:
0029CC  2               
0029CC  2               .IF .NOT STRIP_TRACE
0029CC  2                               SAVE_REGS
0029CC  2                               TXA
0029CC  2                               PHA
0029CC  2                               LDA TRACE_FLAG
0029CC  2                               BEQ NO_TRACE41
0029CC  2               
0029CC  2                               PRINT_STR FN_WRITE_STR_ADDR
0029CC  2                               PLA
0029CC  2                               PHA
0029CC  2                               TAX
0029CC  2                               JSR PRTX
0029CC  2                               JSR CROUT
0029CC  2               NO_TRACE41:
0029CC  2                               PLA
0029CC  2                               RESTORE_REGS
0029CC  2               
0029CC  2               .ENDIF
0029CC  2               
0029CC  2  8A                           TXA
0029CD  2  48                           PHA
0029CE  2               
0029CE  2  AE 76 2D                     LDX BUFLEN
0029D1  2  AD 76 2E                     LDA BUF_ADDR
0029D4  2  AC 77 2E                     LDY BUF_ADDR+1
0029D7  2  20 41 29                     JSR CPY_BUF_TO_WRITE_SP_PAYLOAD
0029DA  2               
0029DA  2  68                           PLA
0029DB  2  AA                           TAX
0029DC  2                               ; X = DEVICE
0029DC  2  AC 76 2D                     LDY BUFLEN              ; MAX PAYLOAD IS 255
0029DF  2  20 11 26                     JSR SP_WRITE
0029E2  2  90 0B                        BCC WRITE_OK
0029E4  2               
0029E4  2               
0029E4  2               WRITE_ERR:
0029E4  2               
0029E4  2  8D 5C 36                     STA FN_LAST_ERR
0029E7  2               .IF .NOT STRIP_TRACE
0029E7  2               .IF EXT2_TRACE
0029E7  2                               PRINT_STR FN_WRITE_ERROR_STR_ADDR
0029E7  2                               JSR DUMP_SP_PAYLOAD
0029E7  2               .ENDIF
0029E7  2               .ENDIF
0029E7  2               
0029E7  2  A2 FE                        LDX #FN_ERR
0029E9  2  AD 5C 36                     LDA FN_LAST_ERR
0029EC  2  18                           CLC
0029ED  2  90 05                        BCC WRITE_DONE
0029EF  2               WRITE_OK:
0029EF  2               
0029EF  2  A2 00                        LDX #FN_OK
0029F1  2  8E 5C 36                     STX FN_LAST_ERR
0029F4  2               WRITE_DONE:
0029F4  2  AC 32 32                     LDY SP_COUNT
0029F7  2               
0029F7  2  60                           RTS
0029F8  2               .ELSE
0029F8  2               
0029F8  2               ;******************************************************************
0029F8  2               ; FN_WRITE - **** CONTROL VERSION ****
0029F8  2               ; Read the specified UNIT
0029F8  2               ;
0029F8  2               ; INPUT
0029F8  2               ; X      = UNIT DESTINATION
0029F8  2               ; BUFLEN = NUMBER OF BYTES TO WRITE
0029F8  2               ; BUF    = BUFFER TO SEND
0029F8  2               ;******************************************************************
0029F8  2               FN_WRITE:
0029F8  2               
0029F8  2                               TXA
0029F8  2                               PHA
0029F8  2               
0029F8  2               .IF .NOT STRIP_TRACE
0029F8  2                               SAVE_REGS
0029F8  2                               TXA
0029F8  2                               PHA
0029F8  2                               LDA TRACE_FLAG
0029F8  2                               BEQ NO_TRACE41
0029F8  2               
0029F8  2                               PRINT_STR FN_WRITE_STR_ADDR
0029F8  2                               PLA
0029F8  2                               PHA
0029F8  2                               TAX
0029F8  2                               JSR PRTX
0029F8  2                               JSR CROUT
0029F8  2               NO_TRACE41:
0029F8  2                               PLA
0029F8  2                               RESTORE_REGS
0029F8  2               
0029F8  2               .ENDIF
0029F8  2               
0029F8  2                               LDX BUFLEN                  ; MAX SIZE 255
0029F8  2                               LDA BUF_ADDR
0029F8  2                               LDY BUF_ADDR+1
0029F8  2               
0029F8  2                               JSR CPY_BUF_TO_CTRL_SP_PAYLOAD
0029F8  2               
0029F8  2               ;'W'
0029F8  2               ; 0-1  payload size (bytes to write)
0029F8  2               ; 2..  data
0029F8  2               
0029F8  2                               ; SET PAYLOAD SIZE
0029F8  2               
0029F8  2                               ; x = destination
0029F8  2                               PLA
0029F8  2                               TAX
0029F8  2               
0029F8  2                               LDY BUFLEN              ; PAYLOAD SIZE
0029F8  2                               STY SP_PAYLOAD
0029F8  2                               LDA #$00
0029F8  2                               STA SP_PAYLOAD+1
0029F8  2               
0029F8  2                               LDY #'W'
0029F8  2                               JSR SP_CONTROL
0029F8  2                               STA FN_LAST_ERR
0029F8  2                               BCC WRITE_OK
0029F8  2               
0029F8  2               WRITE_ERR:
0029F8  2               
0029F8  2               
0029F8  2               .IF .NOT STRIP_TRACE
0029F8  2               .IF EXT2_TRACE
0029F8  2                               PRINT_STR FN_WRITE_ERROR_STR_ADDR
0029F8  2                               JSR DUMP_SP_PAYLOAD
0029F8  2               .ENDIF
0029F8  2               .ENDIF
0029F8  2               
0029F8  2                               LDX #FN_ERR
0029F8  2                               LDA FN_LAST_ERR
0029F8  2                               CLC
0029F8  2                               BCC WRITE_DONE
0029F8  2               WRITE_OK:
0029F8  2               
0029F8  2                               LDX #FN_OK
0029F8  2               WRITE_DONE:
0029F8  2                               LDY SP_COUNT
0029F8  2                               LDA LAST_SP_ERR
0029F8  2                               RTS
0029F8  2               
0029F8  2               .ENDIF
0029F8  2               
0029F8  2               ;******************************************************************
0029F8  2               ; FN_CLOSE
0029F8  2               ; Close the specified UNIT
0029F8  2               ;
0029F8  2               ; INPUT
0029F8  2               ; X = UNIT DESTINATION
0029F8  2               ;******************************************************************
0029F8  2               FN_CLOSE:
0029F8  2               
0029F8  2               .IF .NOT STRIP_TRACE
0029F8  2                               SAVE_REGS
0029F8  2                               LDA TRACE_FLAG
0029F8  2                               BEQ NO_TRACE33
0029F8  2                               TXA
0029F8  2                               PHA
0029F8  2                               PRINT_STR FN_CLOSE_STR_ADDR
0029F8  2                               PLA
0029F8  2                               TAX
0029F8  2                               JSR PRTX
0029F8  2                               JSR CROUT
0029F8  2               NO_TRACE33:
0029F8  2                               RESTORE_REGS
0029F8  2               .ENDIF
0029F8  2               
0029F8  2  8A                           TXA
0029F9  2  48                           PHA
0029FA  2               
0029FA  2  A0 03                        LDY #$03                ; PAYLOAD SIZE = ZERO
0029FC  2  8C 4C 32                     STY SP_PAYLOAD
0029FF  2  A0 00                        LDY #$00
002A01  2  8C 4D 32                     STY SP_PAYLOAD+1
002A04  2               
002A04  2  A0 43                        LDY #'C'                ; SEND 'C' TO FUJINET
002A06  2  20 C2 25                     JSR SP_CONTROL
002A09  2  8D 5C 36                     STA FN_LAST_ERR
002A0C  2  90 06                        BCC CLOSE_OK
002A0E  2               
002A0E  2  68                           PLA
002A0F  2  A2 FE                        LDX #FN_ERR
002A11  2               
002A11  2               .IF .NOT STRIP_TRACE
002A11  2                               PRINT_STR CLOSE_ERROR_STR_ADDR
002A11  2               .ENDIF
002A11  2               
002A11  2  18                           CLC
002A12  2  90 07                        BCC CLOSE_DONE
002A14  2               CLOSE_OK:
002A14  2  68                           PLA
002A15  2  AA                           TAX
002A16  2  20 B1 25                     JSR SP_CLOSE
002A19  2               
002A19  2  A2 00                        LDX #FN_OK
002A1B  2               CLOSE_DONE:
002A1B  2  60                           RTS
002A1C  2               
002A1C  2               
002A1C  2               ;******************************************************************
002A1C  2               ; FN_STATUS
002A1C  2               ;  Number of characters in the buffer and if connected
002A1C  2               ;
002A1C  2               ; INPUT
002A1C  2               ; X = UNIT DESTINATION
002A1C  2               ; RETURNS
002A1C  2               ; A = number of bytes waiting lo
002A1C  2               ; Y = number of bytes waiting hi
002A1C  2               ;******************************************************************
002A1C  2               FN_STATUS:
002A1C  2               
002A1C  2               .IF .NOT STRIP_TRACE
002A1C  2               .IF EXT_TRACE
002A1C  2                               SAVE_REGS
002A1C  2                               TXA
002A1C  2                               PHA
002A1C  2                               LDA TRACE_FLAG
002A1C  2                               BEQ NO_TRACE24
002A1C  2               
002A1C  2                               PRINT_STR FN_BYTES_WAITING_STR_ADDR
002A1C  2                               PLA
002A1C  2                               PHA
002A1C  2                               TAX
002A1C  2                               JSR PRTX
002A1C  2               
002A1C  2               NO_TRACE24:
002A1C  2                               PLA
002A1C  2                               RESTORE_REGS
002A1C  2               .ENDIF
002A1C  2               .ENDIF
002A1C  2               
002A1C  2  A0 53                        LDY #'S'
002A1E  2  20 46 26                     JSR SP_STATUS
002A21  2  8D 5C 36                     STA FN_LAST_ERR
002A24  2  90 04                        BCC BW_OK
002A26  2               BW_ERROR:
002A26  2  A2 FE                        LDX #FN_ERR
002A28  2  B0 14                        BCS BW_DONE
002A2A  2               BW_OK:
002A2A  2  AD 4C 32                     LDA SP_PAYLOAD      ; Bytes Waiting
002A2D  2  AC 4D 32                     LDY SP_PAYLOAD+1
002A30  2  8D 73 2D                     STA BW
002A33  2  8C 74 2D                     STY BW+1
002A36  2               
002A36  2  AD 4E 32                     LDA SP_PAYLOAD+2
002A39  2  8D 75 2D                     STA CONNECT
002A3C  2               
002A3C  2  A2 00                        LDX #FN_OK
002A3E  2               
002A3E  2               BW_DONE:
002A3E  2  60                           RTS
002A3F  2               
002A3F  2               ;******************************************************************
002A3F  2               ; FN_FIND_NETWORK
002A3F  2               ; Return the Unit number for a device
002A3F  2               ;
002A3F  2               ; INPUT
002A3F  2               ;   BASIC_UNIT - Set between 0 and 3 as the network device to find
002A3F  2               ; RETURN
002A3F  2               ;   X - FN_ERR or UNIT number of device found
002A3F  2               ;******************************************************************
002A3F  2               FN_FIND_NETWORK:
002A3F  2               
002A3F  2               .IF .NOT STRIP_TRACE
002A3F  2               .IF EXT2_TRACE
002A3F  2                               LDA TRACE_FLAG
002A3F  2                               BEQ NO_TRACE25
002A3F  2                               PRINT_STR FN_FIND_NETWORK_STR_ADDR
002A3F  2                               LDA #SPACE
002A3F  2                               JSR COUT
002A3F  2                               LDX BASIC_UNIT
002A3F  2                               JSR PRTX
002A3F  2                               LDA #SPACE
002A3F  2                               JSR COUT
002A3F  2               
002A3F  2               NO_TRACE25:
002A3F  2               .ENDIF
002A3F  2               .ENDIF
002A3F  2               
002A3F  2  AD 6E 2B                     LDA BASIC_UNIT
002A42  2  C9 01                        CMP #$01
002A44  2  10 0D                        BPL MULTI_NETWORK
002A46  2               
002A46  2                               ; LOOK FOR "NETWORK"
002A46  2  AD A2 31                     LDA NETWORK_STR_ADDR+1
002A49  2  AC A1 31                     LDY NETWORK_STR_ADDR
002A4C  2               
002A4C  2               .IF .NOT STRIP_TRACE
002A4C  2               .IF EXT2_TRACE
002A4C  2                               PRINT_STR NETWORK_STR_ADDR
002A4C  2                               LDA #SPACE
002A4C  2                               JSR COUT
002A4C  2                               LDA NETWORK_STR_ADDR+1
002A4C  2                               LDY NETWORK_STR_ADDR
002A4C  2               .ENDIF
002A4C  2               .ENDIF
002A4C  2               
002A4C  2  20 7B 27                     JSR SP_FIND_DEVICE          ; LOOK FOR "NETWORK"
002A4F  2  E0 FE                        CPX #SP_ERR
002A51  2  D0 1C                        BNE FOUND_IT
002A53  2               
002A53  2               MULTI_NETWORK:
002A53  2                               ; IF WE'RE HERE, THEN WE DIDN'T FIND "NETWORK"
002A53  2                               ; OR A UNIT NUMBER GREATER THAN ZERO WAS SPECIFIED.
002A53  2                               ; NOW LOOK FOR "NETWORK_X"
002A53  2               
002A53  2  AE B0 31                     LDX NETWORK_STR_WITH_NUMBER_INDEX
002A56  2               
002A56  2  AD 6E 2B                     LDA BASIC_UNIT
002A59  2  18                           CLC
002A5A  2  69 30                        ADC #'0'
002A5C  2               
002A5C  2  9D A4 31                     STA NETWORK_STR_WITH_NUMBER,X
002A5F  2               
002A5F  2  AD AF 31                     LDA NETWORK_STR_WITH_NUMBER_ADDR+1
002A62  2  AC AE 31                     LDY NETWORK_STR_WITH_NUMBER_ADDR
002A65  2               
002A65  2               .IF .NOT STRIP_TRACE
002A65  2               .IF EXT2_TRACE
002A65  2                               PRINT_STR NETWORK_STR_WITH_NUMBER_ADDR
002A65  2                               LDA #SPACE
002A65  2                               JSR COUT
002A65  2                               LDA NETWORK_STR_WITH_NUMBER_ADDR+1
002A65  2                               LDY NETWORK_STR_WITH_NUMBER_ADDR
002A65  2               .ENDIF
002A65  2               .ENDIF
002A65  2  20 7B 27                     JSR SP_FIND_DEVICE              ; LOOK FOR "NETWORK_X" WHERE X IS 0-3
002A68  2  E0 FE                        CPX #SP_ERR
002A6A  2  D0 03                        BNE FOUND_IT
002A6C  2               FIND_ERROR:
002A6C  2               .IF .NOT STRIP_TRACE
002A6C  2               .IF EXT2_TRACE
002A6C  2                               PRINT_STR DEVICE_NOT_FOUND_STR_ADDR
002A6C  2                               JSR CROUT
002A6C  2               .ENDIF
002A6C  2               .ENDIF
002A6C  2  A2 FE                        LDX #FN_ERR
002A6E  2  60                           RTS
002A6F  2               FOUND_IT:
002A6F  2  8A                           TXA
002A70  2  A8                           TAY                             ; RETURN IN Y
002A71  2  A2 00                        LDX #FN_OK
002A73  2               
002A73  2               .IF .NOT STRIP_TRACE
002A73  2               .IF EXT2_TRACE
002A73  2                               SAVE_REGS
002A73  2                               JSR PRTAX
002A73  2                               JSR CROUT
002A73  2                               RESTORE_REGS
002A73  2               .ENDIF
002A73  2               .ENDIF
002A73  2  60                           RTS
002A74  2               
002A74  2               
002A74  2               FN_LIST:
002A74  2               ;*******************************
002A74  2               ; FN_LIST
002A74  2               ;   Transfer devices into a buffer
002A74  2               ;**********************************
002A74  2  A2 00                        LDX #$00
002A76  2  A0 00                        LDY #SP_CMD_STATUS
002A78  2  20 46 26                     JSR SP_STATUS
002A7B  2               
002A7B  2  AE 4C 32                     LDX DCOUNT
002A7E  2  E8                           INX
002A7F  2  8E 2B 32                     STX NUM_DEVICES
002A82  2               
002A82  2  A2 01                        LDX #$01
002A84  2  A0 00                        LDY #$00
002A86  2  8C 7A 2E                     STY STRLEN
002A89  2               NEXT_DEV1:
002A89  2  8A                           TXA
002A8A  2  48                           PHA
002A8B  2               
002A8B  2  A0 03                        LDY #SP_STATUS_DIB      ; X = DEVICE
002A8D  2  20 46 26                     JSR SP_STATUS
002A90  2  8D 5C 36                     STA FN_LAST_ERR
002A93  2  B0 36                        BCS FN_LIST_ERROR_OUT   ; SHOULD NEVER HAPPEN, BUT IF IT DOES, JUST EXIT
002A95  2               
002A95  2  A2 00                        LDX #$00
002A97  2               NEXT_CHAR:
002A97  2  BD 51 32                     LDA SP_PAYLOAD+5,X
002A9A  2  AC 7A 2E                     LDY STRLEN
002A9D  2  99 7B 2E                     STA STRBUF,Y
002AA0  2  E8                           INX
002AA1  2  EE 7A 2E                     INC STRLEN
002AA4  2  EC 50 32                     CPX SP_PAYLOAD+4        ; ARE WE AT END OF STRING (NOT NULL TERMINATED)
002AA7  2  D0 EE                        BNE NEXT_CHAR
002AA9  2               
002AA9  2  A9 2C                        LDA #','                 ; ADD A COMMA
002AAB  2  AC 7A 2E                     LDY STRLEN
002AAE  2  99 7B 2E                     STA STRBUF,Y
002AB1  2  EE 7A 2E                     INC STRLEN
002AB4  2               
002AB4  2  68                           PLA                     ; MOVE TO NEXT DEVICE
002AB5  2  AA                           TAX
002AB6  2  E8                           INX
002AB7  2  EC 2B 32                     CPX NUM_DEVICES         ; HAVE WE EXCEEDED DEVICE LIST?
002ABA  2  D0 CD                        BNE NEXT_DEV1
002ABC  2               
002ABC  2               FN_LIST_OK:
002ABC  2  CE 7A 2E                     DEC STRLEN
002ABF  2  AE 7A 2E                     LDX STRLEN
002AC2  2  A9 00                        LDA #$00
002AC4  2  9D 7B 2E                     STA STRBUF,X            ; REMOVE THE LAST COMMA
002AC7  2  A2 00                        LDX #FN_OK
002AC9  2  18                           CLC
002ACA  2  60                           RTS
002ACB  2               
002ACB  2               FN_LIST_ERROR_OUT:
002ACB  2               
002ACB  2  68                           PLA
002ACC  2               
002ACC  2  A2 FE                        LDX #FN_ERR
002ACE  2  38                           SEC
002ACF  2  60                           RTS
002AD0  2               
002AD0  2               ;******************************************************************
002AD0  2               ; FN_ACCEPT
002AD0  2               ;   Accept the specified connection from UNIT
002AD0  2               ;
002AD0  2               ; INPUT
002AD0  2               ; X = UNIT DESTINATION
002AD0  2               ;******************************************************************
002AD0  2               FN_ACCEPT:
002AD0  2               
002AD0  2               .IF .NOT STRIP_TRACE
002AD0  2                               SAVE_REGS
002AD0  2                               LDA TRACE_FLAG
002AD0  2                               BEQ NO_TRACE42
002AD0  2                               TXA
002AD0  2                               PHA
002AD0  2                               PRINT_STR FN_ACCEPT_STR_ADDR
002AD0  2                               PLA
002AD0  2                               TAX
002AD0  2                               JSR PRTX
002AD0  2                               JSR CROUT
002AD0  2               NO_TRACE42:
002AD0  2                               RESTORE_REGS
002AD0  2               .ENDIF
002AD0  2               
002AD0  2               
002AD0  2  A0 03                        LDY #$03                ; PAYLOAD SIZE = ZERO
002AD2  2  8C 4C 32                     STY SP_PAYLOAD
002AD5  2  A0 00                        LDY #$00
002AD7  2  8C 4D 32                     STY SP_PAYLOAD+1
002ADA  2               
002ADA  2  A0 41                        LDY #'A'                ; SEND 'A' TO FUJINET
002ADC  2  20 C2 25                     JSR SP_CONTROL
002ADF  2  8D 5C 36                     STA FN_LAST_ERR
002AE2  2  90 05                        BCC ACCEPT_OK
002AE4  2               
002AE4  2  A2 FE                        LDX #FN_ERR
002AE6  2               
002AE6  2               .IF .NOT STRIP_TRACE
002AE6  2                               PRINT_STR FN_ACCEPT_ERROR_STR_ADDR
002AE6  2               .ENDIF
002AE6  2               
002AE6  2  18                           CLC
002AE7  2  90 02                        BCC ACCEPT_DONE
002AE9  2               ACCEPT_OK:
002AE9  2  A2 00                        LDX #FN_OK
002AEB  2               
002AEB  2               ACCEPT_DONE:
002AEB  2  8E 5C 36                     STX FN_LAST_ERR
002AEE  2  60                           RTS
002AEF  2               
002AEF  2               ;******************************************************************
002AEF  2               ; FN_INPUT
002AEF  2               ;   Read until carriage return is received or 255 characters are
002AEF  2               ; received
002AEF  2               ;
002AEF  2               ; INPUT
002AEF  2               ; X = UNIT DESTINATION
002AEF  2               ;******************************************************************
002AEF  2               
002AEF  2               
002AEF  2               FN_INPUT:
002AEF  2               
002AEF  2               .IF .NOT STRIP_TRACE
002AEF  2                               SAVE_REGS
002AEF  2                               TXA
002AEF  2                               PHA
002AEF  2                               LDA TRACE_FLAG
002AEF  2                               BEQ NO_TRACE47
002AEF  2               
002AEF  2                               PRINT_STR FN_INPUT_STR_ADDR
002AEF  2                               PLA
002AEF  2                               PHA
002AEF  2                               TAX
002AEF  2                               JSR PRTX
002AEF  2                               JSR CROUT
002AEF  2               NO_TRACE47:
002AEF  2                               PLA
002AEF  2                               RESTORE_REGS
002AEF  2               
002AEF  2               .ENDIF
002AEF  2               
002AEF  2               ;'R'
002AEF  2               ;0-1   payload size (bytes to return)
002AEF  2               ;2..   data
002AEF  2               ;
002AEF  2                               ; SET PAYLOAD SIZE
002AEF  2               
002AEF  2               GET_MORE:
002AEF  2  A0 01                        LDY #$01              ; PAYLOAD SIZE 1 BYTE
002AF1  2  8C 4C 32                     STY SP_PAYLOAD
002AF4  2  A9 00                        LDA #$00
002AF6  2  8D 4D 32                     STA SP_PAYLOAD+1
002AF9  2  8D 5A 35                     STA FN_BUFFER_SIZE
002AFC  2               
002AFC  2  A0 52                        LDY #'R'
002AFE  2  20 C2 25                     JSR SP_CONTROL
002B01  2  B0 15                        BCS STOP_INPUT              ; ERROR, JUST RETURN STRING
002B03  2               
002B03  2  AC 5A 35                     LDY FN_BUFFER_SIZE
002B06  2  AD 4E 32                     LDA SP_PAYLOAD+2
002B09  2               
002B09  2  C9 0D                        CMP #13                     ; IS IT A CR?
002B0B  2  F0 0B                        BEQ STOP_INPUT              ; STOP PROCESSING
002B0D  2               
002B0D  2  99 5B 35                     STA FN_BUFFER,Y             ; SAVE THE RECEIVED CHARACTER
002B10  2  C8                           INY
002B11  2  8C 5A 35                     STY FN_BUFFER_SIZE
002B14  2  C0 FF                        CPY #$FF
002B16  2  D0 D7                        BNE GET_MORE                ; KEEP GOING UNTIL BUFFER FULL
002B18  2               
002B18  2               STOP_INPUT:                                  ; ANY ERROR JUST STOP
002B18  2  AE 5A 35                     LDX FN_BUFFER_SIZE
002B1B  2  60                           RTS
002B1C  2               
002B1C  2               
002B1C  2               
002B1C  2               
002B1C  2               
002B1C  1               
002B1C  1               RELOCATE_CODE_END:
002B1C  1               
002B1C  1               ;***********
002B1C  1               ;***********
002B1C  1               ;***********
002B1C  1               ;* DATA SECTION
002B1C  1               ;***********
002B1C  1               ;***********
002B1C  1               ;***********
002B1C  1               
002B1C  1               
002B1C  1               ;**************************************
002B1C  1               
002B1C  1               relocate008:
002B1C  1  75 20        RELOC_NSTART:   .WORD NSTART
002B1E  1               
002B1E  1               COMMANDS:
002B1E  1  4E 4F 50 45                  .ASCIIZ "NOPEN"                 ; NOPEN
002B22  1  4E 00        
002B24  1  0B 21        relocate009:    .WORD   NOPEN-1
002B26  1               
002B26  1  4E 87 00                     .BYTE   'N', TOK_READ, 00       ; NREAD
002B29  1  C1 21        relocate010:    .WORD   NREAD-1
002B2B  1               
002B2B  1  4E 57 52 49                  .ASCIIZ "NWRITE"                ; NWRITE
002B2F  1  54 45 00     
002B32  1  34 22        relocate011:    .WORD   NWRITE-1
002B34  1               
002B34  1  4E 43 54 52                  .ASCIIZ "NCTRL"                 ; NCTRL
002B38  1  4C 00        
002B3A  1  B3 22        relocate012:    .WORD   NCTRL-1
002B3C  1               
002B3C  1  4E 53 54 C5                  .BYTE   "NST", TOK_AT, "US", 0  ; NSTATUS
002B40  1  55 53 00     
002B43  1  09 23        relocate013:    .WORD   NSTATUS-1
002B45  1               
002B45  1  4E 43 4C 4F                  .ASCIIZ "NCLOSE"                ; NCLOSE
002B49  1  53 45 00     
002B4C  1  A1 21        relocate014:    .WORD   NCLOSE-1
002B4E  1               
002B4E  1  4E 80 00                     .BYTE   "N", TOK_END, 0         ; NEND
002B51  1  50 23        relocate015:    .WORD   NEND-1
002B53  1               
002B53  1  4E BC 00                     .BYTE   "N", TOK_LIST, 0        ; NLIST
002B56  1  7E 23        relocate016:    .WORD   NLIST-1
002B58  1               
002B58  1  4E 41 43 43                  .ASCIIZ "NACCEPT"               ; NACCEPT
002B5C  1  45 50 54 00  
002B60  1  B1 23        relocate017:    .WORD   NACCEPT-1
002B62  1               
002B62  1  4E 84 00                     .BYTE   "N", TOK_INPUT, 0       ; NINPUT
002B65  1  C6 23        relocate018:    .WORD   NINPUT-1
002B67  1               
002B67  1               .IF .NOT STRIP_TRACE
002B67  1                               .BYTE   "N", TOK_TRACE, 0       ; NTRACE
002B67  1               trace053:       .WORD   NTRACE-1
002B67  1               
002B67  1                               .BYTE   "N",TOK_NOTRACE, 0      ; NNOTRACE
002B67  1               trace054:       .WORD   NNOTRACE-1
002B67  1               .ENDIF
002B67  1               
002B67  1               ;*******************************************
002B67  1               ;* END OF TABLE
002B67  1               ;*******************************************
002B67  1  00                           .BYTE   00      ; END OF TABLE
002B68  1               
002B68  1               .IF .NOT STRIP_TRACE
002B68  1               TRACE_FLAG:     .BYTE   $01
002B68  1               .ENDIF
002B68  1  0D           RELOC_SIZE:     .BYTE   $0D
002B69  1               
002B69  1  xx xx xx     PREVECT:        .RES    3       ; JUMP TO CONTENTS OF THE PREVIOUS AMPERSAND VECTOR
002B6C  1  xx xx        OLDHIMEM:       .RES    2       ; VALUE OF ORIGINAL HIMEM
002B6E  1               
002B6E  1               
002B6E  1               
002B6E  1               ;***************************************
002B6E  1  00           BASIC_UNIT:     .BYTE   0       ; BASIC UNIT 0-4 NOT FUJINET UNIT
002B6F  1  04           MODE:           .BYTE   4       ; 4=READ ONLY, 6=READ DIRECTORY, 8= WRITE ONLY, 12=READ/WRITE, 13= HTTP POST
002B70  1  00           TRANSLATION:    .BYTE   0       ; 0 = NO TRANSLATION, 1=CR to ATASCII EOL, 2=LF to ATASCII EOL, 3=CR/LF to ATASCII EOL
002B71  1  2D           URL_LEN:        .BYTE   45
002B72  1               URL:
002B72  1               .IF .NOT STRIP_TRACE
002B72  1                               .ASCIIZ "N:HTTPS://www.gnu.org/licenses/gpl-3.0.txt"
002B72  1               .ENDIF
002B72  1  xx xx xx xx                  .RES    255
002B76  1  xx xx xx xx  
002B7A  1  xx xx xx xx  
002C71  1               relocate019:
002C71  1  72 2B        URL_ADDR:       .WORD   URL
002C73  1  00           COMMAND:        .BYTE   0       ; FUJINET COMMAND
002C74  1  xx xx xx xx  BASIC_PAYLOAD:  .RES    255     ; PAYLOAD TO SEND
002C78  1  xx xx xx xx  
002C7C  1  xx xx xx xx  
002D73  1  00 00        BW:             .WORD   0       ; BYTES WAITING
002D75  1  00           CONNECT:        .BYTE   0       ; 1=CONNECTED
002D76  1  00           BUFLEN:         .BYTE   0
002D77  1  xx xx xx xx  BUF:            .RES    255     ; GENERIC BUFFER FOR READ/WRITE
002D7B  1  xx xx xx xx  
002D7F  1  xx xx xx xx  
002E76  1               relocate020:
002E76  1  77 2D        BUF_ADDR:       .WORD   BUF
002E78  1  00 00        STRADDR:        .WORD   0
002E7A  1  00           STRLEN:         .BYTE   0
002E7B  1  xx xx xx xx  STRBUF:         .RES    255
002E7F  1  xx xx xx xx  
002E83  1  xx xx xx xx  
002F7A  1               relocate021:
002F7A  1  7B 2E        STRBUF_ADDR:    .WORD   STRBUF
002F7C  1  FD FD FD FD  NETWORK_CACHE:  .BYTE   FN_NO_NETWORK, FN_NO_NETWORK, FN_NO_NETWORK, FN_NO_NETWORK
002F80  1  FD FD FD FD  OPEN_LIST:      .BYTE   FN_NO_NETWORK, FN_NO_NETWORK, FN_NO_NETWORK, FN_NO_NETWORK      ; BASIC UNIT INDEX TO ACTUAL UNIT
002F84  1  FE FE FE FE  NERR:           .BYTE   FN_ERR, FN_ERR, FN_ERR, FN_ERR                                  ; LAST ERROR
002F88  1               
002F88  1  00           STR_DSC_LEN:    .BYTE   0
002F89  1  00           STR_DSC_LO:     .BYTE   0
002F8A  1  00           STR_DSC_HI:     .BYTE   0
002F8B  1               
002F8B  1               .include "STRINGS.S"
002F8B  2               
002F8B  2               .IF .NOT .DEFINED(EXTADDED_STR)
002F8B  2               
002F8B  2               ; THESE STRINGS ARE USED DURING INITIALIZATION AND
002F8B  2               ; WON'T BE USED AFTERWARDS SO DON'T NEED TO BE RELOCATED
002F8B  2               
002F8B  2  46 55 4A 49  EXTADDED_STR:                               .BYTE   "FUJINET EXTENSIONS ADDED.", $0D, $00
002F8F  2  4E 45 54 20  
002F93  2  45 58 54 45  
002FA6  2  4E 4F 20 53  SP_NOT_FOUND_STR:                           .BYTE   "NO SMARTPORT! EXTENSIONS NOT LOADED", $0D, $00
002FAA  2  4D 41 52 54  
002FAE  2  50 4F 52 54  
002FCB  2  45 58 49 54  EXITING_STR:                                .BYTE   "EXITING...", $0D, $00
002FCF  2  49 4E 47 2E  
002FD3  2  2E 2E 0D 00  
002FD7  2  4F 4C 44 20  HIMEM_IS_STR:                               .ASCIIZ "OLD HIMEM: "
002FDB  2  48 49 4D 45  
002FDF  2  4D 3A 20 00  
002FE3  2  52 45 4C 4F  RELOC_SIZE_STR:                             .ASCIIZ "RELOCATION SIZE: "
002FE7  2  43 41 54 49  
002FEB  2  4F 4E 20 53  
002FF5  2  20 4E 45 57  NEW_HIMEM_STR:                              .ASCIIZ " NEW HIMEM: "
002FF9  2  20 48 49 4D  
002FFD  2  45 4D 3A 20  
003002  2               SIG_SIZE                                     = 7
003002  2  46 55 4A 49  SIGNATURE_STR:                              .ASCIIZ "FUJIAMP"
003006  2  41 4D 50 00  
00300A  2               
00300A  2               .IF .NOT USE_SP
00300A  2               
00300A  2               TEST_BLOCK_LENGTH:      .WORD 806
00300A  2               TEST_BLOCK_READ_INDEX:  .WORD 0
00300A  2               TEST_BLOCK_STR_LEN:     .BYTE 255
00300A  2               TEST_BLOCK_STR:
00300A  2                   .BYTE "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor "
00300A  2                   .BYTE "incididunt ut labore et dolore magna aliqua. Ut enim blandit volutpat maecenas "
00300A  2                   .BYTE "volutpat blandit aliquam etiam erat. Pharetra magna ac placerat vestibulum lectus "
00300A  2                   .BYTE "mauris ultrices eros in. Aliquam purus sit amet luctus venenatis lectus magna fringilla urna. "
00300A  2                   .BYTE "Accumsan lacus vel facilisis volutpat est velit egestas dui. Quam pellentesque nec nam "
00300A  2                   .BYTE "aliquam. Malesuada fames ac turpis egestas sed tempus urna. Nisl vel pretium lectus quam id "
00300A  2                   .BYTE "leo in vitae turpis. Laoreet suspendisse interdum consectetur libero id faucibus. Sed "
00300A  2                   .BYTE "pulvinar proin gravida hendrerit lectus. Diam maecenas sed enim ut sem viverra aliquet "
00300A  2                   .BYTE "eget sit. Urna porttitor rhoncus dolor purus non enim praesent. Nibh tellus molestie nunc "
00300A  2                   .BYTE "non blandit massa enim nec."
00300A  2                   .BYTE $00
00300A  2               trace052:
00300A  2               TEST_BLOCK_STR_ADDR: .WORD TEST_BLOCK_STR
00300A  2               .ENDIF
00300A  2               
00300A  2               .IF .NOT STRIP_TRACE
00300A  2               
00300A  2               ; NOT NEEDED IF WE'RE NOT DEBUGGING
00300A  2               
00300A  2               OPEN_ERR_STR:                               .ASCIIZ "FN_OPEN: OPEN ERR:"
00300A  2               CTRL_ERR_STR:                               .ASCIIZ "FN_OPEN: CTRL ERR:"
00300A  2               
00300A  2               .ENDIF
00300A  2               
00300A  2               ;*******************************************
00300A  2               ; THESE STRING ARE USED AFTER RELOCATING
00300A  2               ;*******************************************
00300A  2               
00300A  2               .IF .NOT STRIP_TRACE
00300A  2               
00300A  2               ; NOT NEEDED IF WE'RE NOT USING TRACE
00300A  2               
00300A  2               NOPEN_STR:                                  .BYTE "NOPEN ", $00
00300A  2               trace000:
00300A  2               NOPEN_STR_ADDR:                             .WORD NOPEN_STR
00300A  2               
00300A  2               NREAD_STR:                                  .BYTE "NREAD ", $00
00300A  2               trace001:
00300A  2               NREAD_STR_ADDR:                             .WORD NREAD_STR
00300A  2               
00300A  2               NCLOSE_STR:                                 .BYTE "NCLOSE ",  $00
00300A  2               trace002:
00300A  2               NCLOSE_STR_ADDR:                            .WORD NCLOSE_STR, $0D, $00
00300A  2               
00300A  2               NSTATUS_STR:                                .BYTE "NSTATUS ", $00
00300A  2               trace003:
00300A  2               NSTATUS_STR_ADDR:                           .WORD NSTATUS_STR
00300A  2               
00300A  2               NEND_STR:                                   .BYTE "NEND", $0D, $00
00300A  2               trace004:
00300A  2               NEND_STR_ADDR:                              .WORD NEND_STR
00300A  2               
00300A  2               NLIST_STR:                                  .BYTE "NLIST", $0D, $00
00300A  2               trace005:
00300A  2               NLIST_STR_ADDR:                             .WORD NLIST_STR
00300A  2               
00300A  2               NTRACE_STR:                                 .BYTE "NTRACE", $0D, $00
00300A  2               trace006:
00300A  2               NTRACE_STR_ADDR:                            .WORD NTRACE_STR
00300A  2               
00300A  2               NWRITE_STR:                                 .BYTE "NWRITE", $0D, $00
00300A  2               trace007:
00300A  2               NWRITE_STR_ADDR:                            .WORD NWRITE_STR
00300A  2               
00300A  2               NCTRL_STR:                                  .BYTE "NCTRL", $0D, $00
00300A  2               trace008:
00300A  2               NCTRL_STR_ADDR:                             .WORD NCTRL_STR
00300A  2               
00300A  2               NACCEPT_STR:                                .BYTE "NACCEPT", $0D, $00
00300A  2               trace009:
00300A  2               NACCEPT_STR_ADDR:                           .WORD NACCEPT_STR
00300A  2               
00300A  2               NINPUT_STR:                                 .BYTE "NINPUT", $0D, $00
00300A  2               trace010:
00300A  2               NINPUT_STR_ADDR:                            .WORD NINPUT_STR
00300A  2               
00300A  2               FIND_SMARTPORT_SLOT_STR:                    .BYTE "FIND_SMARTPORT_SLOT: ", $00
00300A  2               trace011:
00300A  2               FIND_SMARTPORT_SLOT_STR_ADDR:               .WORD FIND_SMARTPORT_SLOT_STR
00300A  2               
00300A  2               GET_SMARTPORT_DISPATCH_ADDRESS_STR:         .BYTE "GET_SMARTPORT_DISPATCH_ADDRESS", $0D, $00
00300A  2               trace012:
00300A  2               GET_SMARTPORT_DISPATCH_ADDRESS_STR_ADDR:    .WORD GET_SMARTPORT_DISPATCH_ADDRESS_STR
00300A  2               
00300A  2               DISPATCHER_ADDRESS_STR:                     .ASCIIZ "DISPATCHER ADDRESS: "
00300A  2               trace013:
00300A  2               DISPATCHER_ADDRESS_STR_ADDR:                .WORD DISPATCHER_ADDRESS_STR
00300A  2               
00300A  2               SP_OPEN_STR:                                .BYTE "SP_OPEN:",    $00
00300A  2               trace014:
00300A  2               SP_OPEN_STR_ADDR:                           .WORD SP_OPEN_STR
00300A  2               
00300A  2               SP_READ_STR:                                .BYTE "SP_READ:", $00
00300A  2               trace015:
00300A  2               SP_READ_STR_ADDR:                           .WORD SP_READ_STR
00300A  2               
00300A  2               SP_WRITE_STR:                               .BYTE "SP_WRITE:", $00
00300A  2               trace016:
00300A  2               SP_WRITE_STR_ADDR:                          .WORD SP_WRITE_STR
00300A  2               
00300A  2               SP_CLOSE_STR:                               .BYTE "SP_CLOSE:",   $00
00300A  2               trace017:
00300A  2               SP_CLOSE_STR_ADDR:                          .WORD SP_CLOSE_STR
00300A  2               
00300A  2               SP_CONTROL_STR:                             .BYTE $0D, "SP_CONTROL:", $00
00300A  2               trace018:
00300A  2               SP_CONTROL_STR_ADDR:                        .WORD SP_CONTROL_STR
00300A  2               
00300A  2               SP_STATUS_STR:                              .BYTE $0D, "SP_STATUS:", $00
00300A  2               trace019:
00300A  2               SP_STATUS_STR_ADDR:                         .WORD SP_STATUS_STR
00300A  2               
00300A  2               CALL_DISPATCHER_STR:                        .BYTE "CALL_DISPATCHER",   $0D, $00
00300A  2               trace020:
00300A  2               CALL_DISPATCHER_STR_ADDR:                   .WORD CALL_DISPATCHER_STR
00300A  2               
00300A  2               DISPLAY_SP_STATUS_STR:                      .BYTE "DISPLAY_SP_STATUS", $0D, $00
00300A  2               trace021:
00300A  2               DISPLAY_SP_STATUS_STR_ADDR:                 .WORD DISPLAY_SP_STATUS_STR
00300A  2               
00300A  2               SP_FIND_DEVICE_STR:                         .BYTE "SP_FIND_DEVICE:",    $00
00300A  2               trace022:
00300A  2               SP_FIND_DEVICE_STR_ADDR:                    .WORD SP_FIND_DEVICE_STR
00300A  2               
00300A  2               REAL_SMARTPORT_STR:                         .BYTE "REAL SMARTPORT", $0D, $00
00300A  2               trace023:
00300A  2               REAL_SMARTPORT_STR_ADDR:                    .WORD REAL_SMARTPORT_STR
00300A  2               
00300A  2               FN_FIND_NETWORK_STR:                        .BYTE "FN_FIND_NETWORK"    , $0D, $00
00300A  2               trace024:
00300A  2               FN_FIND_NETWORK_STR_ADDR:                   .WORD FN_FIND_NETWORK_STR
00300A  2               
00300A  2               FN_BYTES_WAITING_STR:                       .BYTE "FN_BYTES_WAITING:", $00
00300A  2               trace025:
00300A  2               FN_BYTES_WAITING_STR_ADDR:                  .WORD FN_BYTES_WAITING_STR
00300A  2               
00300A  2               FN_IS_CONNECTED_STR:                        .BYTE "FN_IS_CONNECTED:" , $00
00300A  2               trace026:
00300A  2               FN_IS_CONNECTED_STR_ADDR:                   .WORD FN_IS_CONNECTED_STR
00300A  2               
00300A  2               FN_OPEN_STR:                                .BYTE "FN_OPEN:"         , $00
00300A  2               trace027:
00300A  2               FN_OPEN_STR_ADDR:                           .WORD FN_OPEN_STR
00300A  2               
00300A  2               FN_CLOSE_STR:                               .BYTE "FN_CLOSE:"        , $00
00300A  2               trace028:
00300A  2               FN_CLOSE_STR_ADDR:                          .WORD FN_CLOSE_STR
00300A  2               
00300A  2               CPY_URL_TO_PAYLOAD_STR:                     .BYTE "CPY_URL_TO_PAYLOAD", $0D, $00
00300A  2               trace029:
00300A  2               CPY_URL_TO_PAYLOAD_STR_ADDR:                .WORD CPY_URL_TO_PAYLOAD_STR
00300A  2               
00300A  2               URL_STR:                                    .ASCIIZ "URL: "
00300A  2               trace030:
00300A  2               URL_STR_ADDR:                               .WORD URL_STR
00300A  2               
00300A  2               MODE_STR:                                   .ASCIIZ "MODE: "
00300A  2               trace031:
00300A  2               MODE_STR_ADDR:                              .WORD MODE_STR
00300A  2               
00300A  2               TRANS_STR:                                  .ASCIIZ "TRANS: "
00300A  2               trace032:
00300A  2               TRANS_STR_ADDR:                             .WORD TRANS_STR
00300A  2               
00300A  2               LEN_STR:                                    .ASCIIZ "LEN:"
00300A  2               trace033:
00300A  2               LEN_STR_ADDR:                               .WORD LEN_STR
00300A  2               
00300A  2               PAYLOAD_STR:                                .BYTE $0D, "PAY:", $00
00300A  2               trace034:
00300A  2               PAYLOAD_STR_ADDR:                           .WORD PAYLOAD_STR
00300A  2               
00300A  2               CMD_LIST_STR:                               .BYTE $0D, "CMD_LIST: ", $00
00300A  2               trace035:
00300A  2               CMD_LIST_STR_ADDR:                          .WORD CMD_LIST_STR
00300A  2               
00300A  2               FOUND_DEVICE_STR:                           .BYTE "FOUND DEVICE!", $0D, $00
00300A  2               trace036:
00300A  2               FOUND_DEVICE_STR_ADDR:                      .WORD FOUND_DEVICE_STR
00300A  2               
00300A  2               CLOSE_ERROR_STR:                            .BYTE "CLOSE ERROR", $00
00300A  2               trace037:
00300A  2               CLOSE_ERROR_STR_ADDR:                       .WORD CLOSE_ERROR_STR
00300A  2               
00300A  2               FN_READ_STR:                                .BYTE "FN_READ:", $00
00300A  2               trace038:
00300A  2               FN_READ_STR_ADDR:                           .WORD FN_READ_STR
00300A  2               
00300A  2               FN_READ_ERROR_STR:                          .BYTE "FN_READ ERROR", $0D, $00
00300A  2               trace039:
00300A  2               FN_READ_ERROR_STR_ADDR:                     .WORD FN_READ_ERROR_STR
00300A  2               
00300A  2               FN_WRITE_STR:                               .BYTE "FN_WRITE", $00
00300A  2               trace040:
00300A  2               FN_WRITE_STR_ADDR:                          .WORD FN_WRITE_STR
00300A  2               
00300A  2               FN_WRITE_ERROR_STR:                         .BYTE "FN WRITE ERROR", $0D, $00
00300A  2               trace041:
00300A  2               FN_WRITE_ERROR_STR_ADDR:                    .WORD FN_WRITE_ERROR_STR
00300A  2               
00300A  2               FN_ACCEPT_ERROR_STR:                        .BYTE "FN ACCEPT ERROR", $0D, $00
00300A  2               trace042:
00300A  2               FN_ACCEPT_ERROR_STR_ADDR:                   .WORD FN_ACCEPT_ERROR_STR
00300A  2               
00300A  2               SP_READ_ERROR_STR:                          .BYTE "SP_READ ERROR", $0D, $00
00300A  2               trace043:
00300A  2               SP_READ_ERROR_STR_ADDR:                     .WORD SP_READ_ERROR_STR
00300A  2               
00300A  2               NREAD_ERROR_STR:                            .BYTE "NREAD_ERROR", $0D, $00
00300A  2               trace044:
00300A  2               NREAD_ERROR_STR_ADDR:                       .WORD NREAD_ERROR_STR
00300A  2               
00300A  2               SP_FIND_DEVICE_ERROR_STR:                   .BYTE $0D, "SP_FIND_DEVICE ERROR!", $00
00300A  2               trace045:
00300A  2               SP_FIND_DEVICE_ERROR_STR_ADDR:              .WORD SP_FIND_DEVICE_ERROR_STR
00300A  2               
00300A  2               SP_NO_DCOUNT_STR:                           .BYTE $0D, "COULD NOT GET DCOUNT", $00
00300A  2               trace046:
00300A  2               SP_NO_DCOUNT_STR_ADDR:                      .WORD SP_NO_DCOUNT_STR
00300A  2               
00300A  2               SP_DCOUNT_STR:                              .BYTE $0D, "DCOUNT: ", $00
00300A  2               trace047:
00300A  2               SP_DCOUNT_STR_ADDR:                         .WORD SP_DCOUNT_STR
00300A  2               
00300A  2               FN_INPUT_STR:                               .BYTE "FN_INPUT: ", $00
00300A  2               trace048:
00300A  2               FN_INPUT_STR_ADDR:                          .WORD FN_INPUT_STR
00300A  2               
00300A  2               FN_ACCEPT_STR:                              .BYTE "FN_ACCEPT: ", $00
00300A  2               trace049:
00300A  2               FN_ACCEPT_STR_ADDR:                         .WORD FN_ACCEPT_STR
00300A  2               .ENDIF
00300A  2               
00300A  2  46 55 4A 49  FUJIAPPLE_VER_STR:                          .BYTE "FUJIAPPLE VERSION: YYYYMMDD.HHMM", $0D, $00
00300E  2  41 50 50 4C  
003012  2  45 20 56 45  
00302C  2               str000:
00302C  2  0A 30        FUJIAPPLE_VER_STR_ADDR:                     .WORD FUJIAPPLE_VER_STR
00302E  2               
00302E  2  55 4E 49 54  NOT_OPENED_STR:                             .ASCIIZ "UNIT NOT OPENED!"
003032  2  20 4E 4F 54  
003036  2  20 4F 50 45  
00303F  2               str001:
00303F  2  2E 30        NOT_OPENED_STR_ADDR:                        .WORD NOT_OPENED_STR
003041  2               
003041  2  0D 53 4F 4D  CANT_RESTORE_STR:                           .BYTE $0D,"SOMETHING ELSE CHANGED HIMEM; CAN'T RESTORE ORIGINAL HIMEM.", $00
003045  2  45 54 48 49  
003049  2  4E 47 20 45  
00307E  2               str002:
00307E  2  41 30        CANT_RESTORE_STR_ADDR:                      .WORD CANT_RESTORE_STR
003080  2               
003080  2  0D 52 45 53  RESTORE_HIMEM_STR:                          .BYTE   $0D, "RESTORING HIMEM...", $00
003084  2  54 4F 52 49  
003088  2  4E 47 20 48  
003094  2               str003:
003094  2  80 30        RESTORE_HIMEM_STR_ADDR:                     .WORD RESTORE_HIMEM_STR
003096  2               
003096  2  0D 46 55 4A  EXTREMOVED_STR:                             .BYTE   $0D, "FUJINET EXTENSIONS REMOVED.", $0D, $00
00309A  2  49 4E 45 54  
00309E  2  20 45 58 54  
0030B4  2               str004:
0030B4  2  96 30        EXTREMOVED_STR_ADDR:                        .WORD EXTREMOVED_STR
0030B6  2               
0030B6  2  0D 46 55 4A  NOTFOUND_STR:                               .BYTE   $0D, "FUJINET COMMAND NOT FOUND -- FORWARDING TO NEXT AMPERSAND ROUTINE", $0D, $00
0030BA  2  49 4E 45 54  
0030BE  2  20 43 4F 4D  
0030FA  2               str005:
0030FA  2  B6 30        NOT_FOUND_STR_ADDR:                         .WORD NOTFOUND_STR
0030FC  2               
0030FC  2  20 53 4D 41  DEV_LIST_STR:                               .ASCIIZ " SMARTPORT DEVICE LIST "
003100  2  52 54 50 4F  
003104  2  52 54 20 44  
003114  2               str006:
003114  2  FC 30        DEV_LIST_STR_ADDR:                          .WORD DEV_LIST_STR
003116  2               
003116  2  55 4E 49 54  UNIT_STR:                                   .ASCIIZ "UNIT #"
00311A  2  20 23 00     
00311D  2               str007:
00311D  2  16 31        UNIT_STR_ADDR:                              .WORD UNIT_STR
00311F  2               
00311F  2  20 4E 41 4D  NAME_STR:                                   .ASCIIZ " NAME: "
003123  2  45 3A 20 00  
003127  2               str008:
003127  2  1F 31        NAME_STR_ADDR:                              .WORD NAME_STR
003129  2               
003129  2  56 45 4E 44  VENDER_STR:                                 .ASCIIZ "VENDER ID: "
00312D  2  45 52 20 49  
003131  2  44 3A 20 00  
003135  2               str009:
003135  2  29 31        VENDER_STR_ADDR:                            .WORD VENDER_STR
003137  2               
003137  2  56 45 4E 44  VENDER_VERSION_STR:                         .ASCIIZ "VENDER VERSION: "
00313B  2  45 52 20 56  
00313F  2  45 52 53 49  
003148  2               str010:
003148  2  37 31        VENDER_VERSION_STR_ADDR:                    .WORD VENDER_VERSION_STR
00314A  2               
00314A  2  44 45 56 49  COUNT_STR:                                  .ASCIIZ "DEVICE COUNT: "
00314E  2  43 45 20 43  
003152  2  4F 55 4E 54  
003159  2               str011:
003159  2  4A 31        COUNT_STR_ADDR:                             .WORD COUNT_STR
00315B  2               
00315B  2  53 4D 41 52  SP_ERROR_STR:                               .ASCIIZ "SMARTPORT ERROR: "
00315F  2  54 50 4F 52  
003163  2  54 20 45 52  
00316D  2               str012:
00316D  2  5B 31        SP_ERROR_STR_ADDR:                          .WORD SP_ERROR_STR
00316F  2               
00316F  2  53 4D 41 52  SP_SUCCESS_STR:                             .ASCIIZ "SMARTPORT SUCCESS:  "
003173  2  54 50 4F 52  
003177  2  54 20 53 55  
003184  2               str013:
003184  2  6F 31        SP_SUCCESS_STR_ADDR:                        .WORD SP_SUCCESS_STR
003186  2               
003186  2  0E           FUJI_DISK_0_STR_LEN:                        .BYTE 14
003187  2  46 55 4A 49  FUJI_DISK_0_STR:                            .ASCIIZ "FUJINET_DISK_0"
00318B  2  4E 45 54 5F  
00318F  2  44 49 53 4B  
003196  2               str014:
003196  2  87 31        FUJI_DISK_0_STR_ADDR:                       .WORD FUJI_DISK_0_STR
003198  2               
003198  2  07           NETWORK_STR_LEN:                            .BYTE 7
003199  2  4E 45 54 57  NETWORK_STR:                                .ASCIIZ "NETWORK"
00319D  2  4F 52 4B 00  
0031A1  2               str015:
0031A1  2  99 31        NETWORK_STR_ADDR:                           .WORD NETWORK_STR
0031A3  2               
0031A3  2  09           NETWORK_STR_WITH_NUMBER_LEN:                .BYTE 9
0031A4  2  4E 45 54 57  NETWORK_STR_WITH_NUMBER:                    .ASCIIZ "NETWORK_1"
0031A8  2  4F 52 4B 5F  
0031AC  2  31 00        
0031AE  2               str016:
0031AE  2  A4 31        NETWORK_STR_WITH_NUMBER_ADDR:               .WORD NETWORK_STR_WITH_NUMBER
0031B0  2  08           NETWORK_STR_WITH_NUMBER_INDEX:              .BYTE 8
0031B1  2               
0031B1  2  44 45 56 49  DEVICE_NOT_FOUND_STR:                       .ASCIIZ "DEVICE NOT FOUND!"
0031B5  2  43 45 20 4E  
0031B9  2  4F 54 20 46  
0031C3  2               str017:
0031C3  2  B1 31        DEVICE_NOT_FOUND_STR_ADDR:                  .WORD DEVICE_NOT_FOUND_STR
0031C5  2               
0031C5  2  4E 45 54 57  NETWORK_NOT_FOUND_STR:                      .ASCIIZ "NETWORK DEVICE NOT FOUND!"
0031C9  2  4F 52 4B 20  
0031CD  2  44 45 56 49  
0031DF  2               str018:
0031DF  2  C5 31        NETWORK_NOT_FOUND_STR_ADDR:                 .WORD NETWORK_NOT_FOUND_STR
0031E1  2               
0031E1  2               
0031E1  2               
0031E1  2               .IF .NOT USE_SP
0031E1  2               
0031E1  2               ; NOT A STRING, BUT NEEDED ANYWAY
0031E1  2               
0031E1  2               trace050:
0031E1  2               FAKE_DISPATCHER_ADDR:                       .WORD FAKE_DISPATCHER
0031E1  2               
0031E1  2               
0031E1  2               FAKE_SMARTPORT_STR:                         .BYTE "**** FAKE SMARTPORT ****", $0D, $00
0031E1  2               trace051:
0031E1  2               FAKE_SMARTPORT_STR_ADDR:                    .WORD FAKE_SMARTPORT_STR
0031E1  2               
0031E1  2               .ENDIF
0031E1  2               
0031E1  2               .ENDIF
0031E1  2               
0031E1  1               .include "REGS_DATA.S"
0031E1  2  20 58 3A 00  STR_X:          .ASCIIZ " X:"
0031E5  2  20 59 3A 00  STR_Y:          .ASCIIZ " Y:"
0031E9  2  20 41 3A 00  STR_A:          .ASCIIZ " A:"
0031ED  2  20 50 3A 00  STR_P:          .ASCIIZ " P:"
0031F1  2               
0031F1  2  53 54 41 43  STR_STACK:      .ASCIIZ "STACK:T"
0031F5  2  4B 3A 54 00  
0031F9  2               
0031F9  2  01           MACRO_A:        .BYTE 1
0031FA  2  01           TEMP_A:         .BYTE 1
0031FB  2  01           TEMP_X:         .BYTE 1
0031FC  2  01           TEMP_Y:         .BYTE 1
0031FD  2               
0031FD  2  01           TEMP_P:         .BYTE 1
0031FE  2  01           TEMP_AND:       .BYTE 1
0031FF  2  01           TEMP_CHAR:      .BYTE 1
003200  2               
003200  2  57 41 49 54  WAIT_STR: .ASCIIZ "WAITING..."
003204  2  49 4E 47 2E  
003208  2  2E 2E 00     
00320B  2               
00320B  1               .include "FAKESMARTPORT_DATA.S"
00320B  2  FF           REQUESTED_CMD:          .BYTE $FF
00320C  2  FF           REQUESTED_UNIT:         .BYTE $FF
00320D  2  00 00        REQUESTED_BYTES:        .WORD $0000
00320F  2  FF           CONTROL_CMD:            .BYTE $FF
003210  2  00           OPEN_COUNT:             .BYTE $00
003211  2               
003211  2  70           STATUS_FLAG:            .BYTE SP_STATUS_FLAG_WRITE_ALLOWED |SP_STATUS_FLAG_READ_ALLOWED  | SP_STATUS_FLAG_DEVICE_ONLINE
003212  2               
003212  2  10 00        BYTES_WAITING:          .WORD $0010
003214  2               
003214  2  FF           GET_INDEX:              .BYTE $FF
003215  2  FF           STORE_INDEX:            .BYTE $FF
003216  2  xx xx xx xx  SAVED_ZERO_PAGE:        .RES $15
00321A  2  xx xx xx xx  
00321E  2  xx xx xx xx  
00322B  2               
00322B  1               .include "SMARTPORT_DATA.S"
00322B  2  00           NUM_DEVICES:    .BYTE $00
00322C  2               
00322C  2               SMARTPORT_DISPATCHER:
00322C  2  00           DISPATCHER_ADDR_LO:     .BYTE $00
00322D  2  00           DISPATCHER_ADDR_HI:     .BYTE $00
00322E  2               
00322E  2               relocatesp00:
00322E  2  4C 32        SP_PAYLOAD_ADDR:        .WORD  SP_PAYLOAD
003230  2               relocatesp01:
003230  2  51 32        SP_PAYLOAD_STR_ADDR:    .WORD  SP_PAYLOAD+5
003232  2               
003232  2  FF FF        SP_COUNT:               .WORD   $FFFF           ; BYTES IN PAYLOAD?
003234  2  FE           LAST_SP_ERR:            .BYTE   SP_ERR          ; ERROR CODE
003235  2               
003235  2  xx xx xx xx  CMD_LIST:               .RES    $15
003239  2  xx xx xx xx  
00323D  2  xx xx xx xx  
00324A  2               relocatesp02:
00324A  2  35 32        CMD_LIST_ADDR:          .WORD   CMD_LIST
00324C  2               SP_PAYLOAD:
00324C  2  01           DCOUNT:                 .BYTE   $01             ; NUMBER OF DEVICES
00324D  2  FF           INTSTATE:               .BYTE   $FF             ; INTERRUPT STATUS (IF BIT 6 IS SET, THEN NO INTERRUPT)
00324E  2  FF FF        MANUFACTURER:           .WORD   $FFFF           ; DRIVER MANUFACTURER
003250  2                                                               ; $0000 - UNDETERMINED
003250  2                                                               ; $0001 - APPLE
003250  2                                                               ; $0002-$FFFF 3RD PARTY DRIVER
003250  2  FF FF        INTERFACEVER:           .WORD   $FFFF           ; INTERFACE VERSION
003252  2  00 00                                .WORD   $0000           ; RESERVED (MUST BE $0000)
003254  2  xx xx xx xx                          .RES    512             ; RESERVED FOR DATA
003258  2  xx xx xx xx  
00325C  2  xx xx xx xx  
003454  2               
003454  2  00           FIND_DEVICE_BUF_LEN:    .BYTE 0
003455  2  xx xx xx xx  FIND_DEVICE_BUF:        .RES  255
003459  2  xx xx xx xx  
00345D  2  xx xx xx xx  
003554  2               relocatesp03:
003554  2  55 34        FIND_DEVICE_BUF_ADDR:   .WORD FIND_DEVICE_BUF
003556  2  20 00 03 00  SMARTPORT_ID:           .BYTE $20, $00, $03, $00
00355A  2               
00355A  1               .include "FUJINET_DATA.S"
00355A  2  00           FN_BUFFER_SIZE:     .BYTE $00
00355B  2  xx xx xx xx  FN_BUFFER:          .RES  $FF
00355F  2  xx xx xx xx  
003563  2  xx xx xx xx  
00365A  2               relocatefn00:
00365A  2  5B 35        FN_BUFFER_ADDR:     .WORD FN_BUFFER
00365C  2  00           FN_LAST_ERR:        .BYTE $00
00365D  2               
00365D  1               
00365D  1               RELOCATE_DATA_END:
00365D  1               
00365D  1               ; Anything here is only used during setup and doesn't need to be relocated.
00365D  1               
00365D  1               
00365D  1               .include "RELOCATION.S"
00365D  2               ; relocate 6502 code - APPLE II EDITION
00365D  2               ; By Norman Davie
00365D  2               ;
00365D  2               ; Within your code you need the following tables
00365D  2               ; in this order
00365D  2               ;
00365D  2               ;   RELOCATE_CODE_START
00365D  2               ;     <code>
00365D  2               ;   RELOCATE_CODE_END
00365D  2               ;     <data>
00365D  2               ;     reloc000 .WORD <address>
00365D  2               ;   RELOCATE_DATA_END
00365D  2               ;
00365D  2               ;RELOCATION_TABLE:
00365D  2               ;			.WORD	reloc000
00365D  2               ; icl "commn routines with relocation code table"
00365D  2               ;
00365D  2               ;	.WORD 	0 ; end of table
00365D  2               ;			.DS 	255
00365D  2               ;END_RELOCATION_TABLE:
00365D  2               
00365D  2               ; SUBROUTINES IN THIS FILE
00365D  2               ;
00365D  2               ;	RELOCATE_TO_LOMEM
00365D  2               ;       RELOCATE_TO_HIMEM
00365D  2               ;	RELOCATE_TO_TGT_ADDR
00365D  2               ;	MOVE_TO_TARGET
00365D  2               ;	ADJUST_LOMEM
00365D  2               ;       ADJUST_HIMEM
00365D  2               
00365D  2               ; Pointers used by relocator.
00365D  2               
00365D  2                       .include "ZEROPAGE.S"
00365D  3               ;*****************************************************
00365D  3               ; ZEROPAGE
00365D  3               ; "Safe" locations to use in zero page
00365D  3               ;
00365D  3               ; define APPLEII for Apple II zero page
00365D  3               ; define ATARI   for Atari 8-bit zero page
00365D  3               ;
00365D  3               ; By Norman Davie
00365D  3               
00365D  3               .IF .NOT .DEFINED(ZP1)
00365D  3               
00365D  3               .IF .DEFINED(APPLEII)
00365D  3               ZP1             =	$EB
00365D  3               ZP1_LO	        =	$EB
00365D  3               ZP1_HI	        = 	$EC
00365D  3               
00365D  3               ZP2             =	$ED
00365D  3               ZP2_LO	        =	$ED
00365D  3               ZP2_HI          =	$EE
00365D  3               
00365D  3               ZP3             =	$FA
00365D  3               ZP3_LO          =	$FA
00365D  3               ZP3_HI	   	    =	$FB
00365D  3               
00365D  3               ZP4	            =	$FC
00365D  3               ZP4_LO		    =	$FC
00365D  3               ZP4_HI		    =	$FD
00365D  3               
00365D  3               ZP5             =	$EF
00365D  3               
00365D  3               ZP_BLOCK_SIZE   = ZP4_HI - ZP1 + 1
00365D  3               
00365D  3               .ENDIF
00365D  3               
00365D  3               .IF .DEFINED(ATARI)
00365D  3               
00365D  3               ZP1             =	$A2
00365D  3               ZP1_LO	        =	$A2
00365D  3               ZP1_HI	        = 	$A3
00365D  3               
00365D  3               ZP2             =	$A4
00365D  3               ZP2_LO		    =	$A4
00365D  3               ZP2_HI		    =	$A5
00365D  3               
00365D  3               ZP3             =	$A6
00365D  3               ZP3_LO		    =	$A6
00365D  3               ZP3_HI		    =	$A7
00365D  3               
00365D  3               ZP4             =	$A8
00365D  3               ZP4_LO		    =	$A8
00365D  3               ZP4_HI		    =	$A9
00365D  3               
00365D  3               ZP5		    =	$AA
00365D  3               .ENDIF
00365D  3               
00365D  3               
00365D  3               .ENDIF
00365D  3               
00365D  2               
00365D  2               RELOCATE_TABLE		=	ZP1
00365D  2               RELOCATE_TABLE_LO	=	ZP1_LO
00365D  2               RELOCATE_TABLE_HI	= 	ZP1_HI
00365D  2               
00365D  2               SRC_ADDR		=	ZP2
00365D  2               SRC_ADDR_LO	    	=	ZP2_LO
00365D  2               SRC_ADDR_HI		=	ZP2_HI
00365D  2               
00365D  2               TGT_ADDR		=	ZP3
00365D  2               TGT_ADDR_LO		=	ZP3_LO
00365D  2               TGT_ADDR_HI	    	=	ZP3_HI
00365D  2               
00365D  2               MOD_ADDR		=	ZP4
00365D  2               MOD_ADDR_LO		=	ZP4_LO
00365D  2               MOD_ADDR_HI		=	ZP4_HI
00365D  2               
00365D  2               INSTRUCT_SIZE		=	ZP5
00365D  2               
00365D  2               ;====================================
00365D  2               ;
00365D  2               ;   Move the code and data to HIMEM
00365D  2               ; RELOCATE_TO_TGT_ADDRESS
00365D  2               ;   Move the code and data to the address
00365D  2               ;   stored in TGT_ADDRESS
00365D  2               ;
00365D  2               ; REGISTERS AFFECTED
00365D  2               ;   ALL
00365D  2               ;====================================
00365D  2               RELOCATE_TO_HIMEM:
00365D  2               
00365D  2  A5 73                LDA HIMEM
00365F  2  85 FA                STA TGT_ADDR_LO
003661  2  A5 74                LDA HIMEM+1
003663  2  85 FB                STA TGT_ADDR_HI
003665  2  A9 00                LDA #00                         ; ZERO = MOVE UP IN MEMORY
003667  2  8D 34 39             STA MOVE_HIGHER
00366A  2  18                   CLC
00366B  2  90 0D                BCC RELOCATE_TO_TGT_ADDR
00366D  2               
00366D  2               ;====================================
00366D  2               ; RELOCATE_TO_LOMEM
00366D  2               ;   Move the code and data to LOMEM
00366D  2               ; RELOCATE_TO_TGT_ADDRESS
00366D  2               ;   Move the code and data to the address
00366D  2               ;   stored in TGT_ADDRESS
00366D  2               ;
00366D  2               ; REGISTERS AFFECTED
00366D  2               ;   ALL
00366D  2               ;====================================
00366D  2               RELOCATE_TO_LOMEM:
00366D  2               
00366D  2  A5 4A                LDA LOMEM
00366F  2  85 FA                STA TGT_ADDR_LO
003671  2  A5 4B                LDA LOMEM+1
003673  2  85 FB                STA TGT_ADDR_HI
003675  2  A9 01                LDA #01                         ; ONE = MOVE DOWN IN MEMORY
003677  2  8D 34 39             STA MOVE_HIGHER
00367A  2               
00367A  2               RELOCATE_TO_TGT_ADDR:
00367A  2               
00367A  2               ; START ADDRESS of the CODE block
00367A  2               
00367A  2  A9 6D                LDA #<RELOCATE_CODE_START
00367C  2  85 ED                STA SRC_ADDR_LO
00367E  2  A9 20                LDA #>RELOCATE_CODE_START
003680  2  85 EE                STA SRC_ADDR_HI
003682  2               
003682  2               ; Size of just the code block
003682  2               
003682  2  A9 AF                LDA #<(RELOCATE_CODE_END-RELOCATE_CODE_START)
003684  2  8D 2E 39             STA SRC_SIZE_LO
003687  2  8D 30 39             STA CODE_SIZE_LO
00368A  2  A9 0A                LDA #>(RELOCATE_CODE_END-RELOCATE_CODE_START)
00368C  2  8D 2F 39             STA SRC_SIZE_HI
00368F  2  8D 31 39             STA CODE_SIZE_HI
003692  2               
003692  2               ; Figure out how much we need to adjust
003692  2               ; all addresses by
003692  2               
003692  2  AD 34 39             LDA MOVE_HIGHER         ; ZERO = MOVE HIGHER
003695  2  D0 12                BNE MOVE_DOWN1
003697  2               
003697  2               MOVE_UP1:
003697  2               
003697  2  A5 FA                LDA TGT_ADDR_LO
003699  2  38                   SEC
00369A  2  E5 ED                SBC SRC_ADDR_LO
00369C  2  8D 32 39             STA DIFF_LO
00369F  2               
00369F  2  A5 FB                LDA TGT_ADDR_HI
0036A1  2  E5 EE                SBC SRC_ADDR_HI
0036A3  2  8D 33 39             STA DIFF_HI
0036A6  2               
0036A6  2  18                   CLC
0036A7  2  90 0F                BCC SEARCH_RELOC
0036A9  2               
0036A9  2               MOVE_DOWN1:
0036A9  2               
0036A9  2  A5 ED                LDA SRC_ADDR_LO
0036AB  2  38                   SEC
0036AC  2  E5 FA                SBC TGT_ADDR_LO
0036AE  2  8D 32 39             STA DIFF_LO
0036B1  2               
0036B1  2  A5 EE                LDA SRC_ADDR_HI
0036B3  2  E5 FB                SBC TGT_ADDR_HI
0036B5  2  8D 33 39             STA DIFF_HI
0036B8  2               
0036B8  2               
0036B8  2               SEARCH_RELOC:
0036B8  2  A9 5E                LDA #<RELOCATION_TABLE
0036BA  2  85 EB                STA RELOCATE_TABLE_LO
0036BC  2  A9 39                LDA #>RELOCATION_TABLE
0036BE  2  85 EC                STA RELOCATE_TABLE_HI
0036C0  2               
0036C0  2               ; The user may have manually added entries
0036C0  2               ; to the relocation block, so find the end
0036C0  2               ; of the entries
0036C0  2               
0036C0  2               NEXT_RELOC:
0036C0  2  A0 00                LDY #$00
0036C2  2  B1 EB                LDA (RELOCATE_TABLE),Y
0036C4  2  C8                   INY
0036C5  2  11 EB                ORA (RELOCATE_TABLE),Y
0036C7  2  F0 10                BEQ CHECK_INSTRUCTION
0036C9  2  18                   CLC
0036CA  2  A5 EB                LDA RELOCATE_TABLE_LO
0036CC  2  69 02                ADC #$02
0036CE  2  85 EB                STA RELOCATE_TABLE_LO
0036D0  2  A5 EC                LDA RELOCATE_TABLE_HI
0036D2  2  69 00                ADC #$00
0036D4  2  85 EC                STA RELOCATE_TABLE_HI
0036D6  2               
0036D6  2  18                   CLC
0036D7  2  90 E7                BCC NEXT_RELOC
0036D9  2               
0036D9  2               CHECK_INSTRUCTION:
0036D9  2               
0036D9  2  A0 00                LDY #$00
0036DB  2  B1 ED                LDA (SRC_ADDR),Y	; Get the instruction
0036DD  2  AA                   TAX
0036DE  2  BD 2E 38             LDA INSTRUCTION_SIZE,X	; find out how many bytes the instruction takes
0036E1  2  85 EF                STA INSTRUCT_SIZE	; Keep this size so we can move to the next instruction
0036E3  2  D0 03                BNE CHECK_ABSOLUTE
0036E5  2  4C DD 37             JMP ILLEGAL_INSTRUCTION ; can't relocate
0036E8  2               
0036E8  2               CHECK_ABSOLUTE:
0036E8  2  C9 03                CMP #$03		; If it's 3 bytes long, then we have an absolute address
0036EA  2  F0 02                BEQ ABSOLUTE_INSTRUCT	; and we need to see if the address is within our block
0036EC  2               
0036EC  2  D0 56                BNE MOVE_TO_NEXT_INSTRUCTION
0036EE  2               
0036EE  2               ABSOLUTE_INSTRUCT:
0036EE  2               
0036EE  2               ; Store the address into our table even if we're
0036EE  2               ; we may not need it.
0036EE  2               
0036EE  2  A0 00                LDY #$00
0036F0  2  A5 ED                LDA SRC_ADDR_LO
0036F2  2  91 EB                STA (RELOCATE_TABLE), Y
0036F4  2  C8                   INY
0036F5  2  A5 EE                LDA SRC_ADDR_HI
0036F7  2  91 EB                STA (RELOCATE_TABLE), Y
0036F9  2               
0036F9  2               ; We're actually pointing at the instruction
0036F9  2               ; increase the address by one
0036F9  2               
0036F9  2  A0 00                LDY #$00
0036FB  2  18                   CLC				; move the the address
0036FC  2  B1 EB                LDA (RELOCATE_TABLE),Y		; in the instruction
0036FE  2  69 01                ADC #$01
003700  2  91 EB                STA (RELOCATE_TABLE),Y
003702  2  C8                   INY
003703  2  B1 EB                LDA (RELOCATE_TABLE),Y
003705  2  69 00                ADC #$00
003707  2  91 EB                STA (RELOCATE_TABLE),Y
003709  2               
003709  2               ; How we have the address location
003709  2               ; we need to grab the address at that location
003709  2               
003709  2  A0 00                LDY #$00
00370B  2  B1 EB                LDA (RELOCATE_TABLE),Y		; The lo address in the table
00370D  2  85 FC                STA MOD_ADDR_LO
00370F  2               
00370F  2  C8                   INY
003710  2  B1 EB                LDA (RELOCATE_TABLE),Y		; the hi address in the table
003712  2  85 FD                STA MOD_ADDR_HI
003714  2               
003714  2               ; Treat the number in the addresses as unsigned
003714  2               
003714  2               ; IF ADDRESS_HI > END_OF_BLOCK THEN MOVE_TO_NEXT_INSTRUCTION
003714  2               
003714  2  A0 01                LDY #$01
003716  2  B1 FC                LDA (MOD_ADDR),Y		; get the high byte of the address
003718  2  C9 36                CMP #>RELOCATE_DATA_END		; is the address before our block?
00371A  2  F0 08                BEQ LAST_BYTES			; is the high byte equal to our block?  Check if too high
00371C  2  B0 26                BCS MOVE_TO_NEXT_INSTRUCTION	; We're too high, skip it.
00371E  2               
00371E  2               ; IF ADDRESS_HI < STARTING_OF_BLOCK THEN MOVE_TO_NEXT_INSTRUCTION
00371E  2               
00371E  2  C9 20                CMP #>RELOCATE_CODE_START
003720  2  90 22                BCC MOVE_TO_NEXT_INSTRUCTION	; is the address less than our starting address?
003722  2               
003722  2  B0 08                BCS STORE_ADDRESS		; we're within range, so just store address
003724  2               
003724  2               LAST_BYTES:
003724  2               
003724  2               ; We're on the same page as the final block, so we need to check the low portion of address
003724  2               
003724  2  A0 00                LDY #$00
003726  2  B1 FC                LDA (MOD_ADDR),Y		; checking the low byte
003728  2  C9 5D                CMP #<RELOCATE_DATA_END		; is the address after our block
00372A  2  B0 18                BCS MOVE_TO_NEXT_INSTRUCTION
00372C  2               
00372C  2               ; we're between our SOURCE range, so we want to store
00372C  2               ; the address of the instruction in the table
00372C  2               
00372C  2               STORE_ADDRESS:
00372C  2  A0 00                LDY #$00
00372E  2  A5 FC                LDA MOD_ADDR_LO			; store the address of
003730  2  91 EB                STA (RELOCATE_TABLE),Y		; the address
003732  2  C8                   INY
003733  2  A5 FD                LDA MOD_ADDR_HI
003735  2  91 EB                STA (RELOCATE_TABLE),Y
003737  2               
003737  2               ; move to the next entry in the table
003737  2               
003737  2  18                   CLC
003738  2  A5 EB                LDA RELOCATE_TABLE_LO
00373A  2  69 02                ADC #$02
00373C  2  85 EB                STA RELOCATE_TABLE_LO
00373E  2  A5 EC                LDA RELOCATE_TABLE_HI
003740  2  69 00                ADC #$00
003742  2  85 EC                STA RELOCATE_TABLE_HI
003744  2               
003744  2               MOVE_TO_NEXT_INSTRUCTION:
003744  2               
003744  2               ; move to the next instruction
003744  2               ; this updates SRC_ADDR by the
003744  2               ; instruction size
003744  2               
003744  2  18                   CLC
003745  2  A5 ED                LDA SRC_ADDR_LO
003747  2  65 EF                ADC INSTRUCT_SIZE
003749  2  85 ED                STA SRC_ADDR_LO
00374B  2  A5 EE                LDA SRC_ADDR_HI
00374D  2  69 00                ADC #$00
00374F  2  85 EE                STA SRC_ADDR_HI
003751  2               
003751  2               ; substract the instruction size from
003751  2               ; our size counter.  If we've reached
003751  2               ; zero, we are done
003751  2               
003751  2  38                   SEC
003752  2  AD 2E 39             LDA SRC_SIZE_LO
003755  2  E5 EF                SBC INSTRUCT_SIZE
003757  2  8D 2E 39             STA SRC_SIZE_LO
00375A  2  AD 2F 39             LDA SRC_SIZE_HI
00375D  2  E9 00                SBC #$00
00375F  2  8D 2F 39             STA SRC_SIZE_HI
003762  2               
003762  2               ; if both SRC_SIZE and SRC_SIZE+1 are zero
003762  2               ; we're done
003762  2               
003762  2  AD 2E 39             LDA SRC_SIZE_LO
003765  2  0D 2F 39             ORA SRC_SIZE_HI
003768  2  F0 03                BEQ TERMINATE_TABLE
00376A  2  4C D9 36             JMP CHECK_INSTRUCTION
00376D  2               
00376D  2               ; TERMINATE THE TABLE
00376D  2               ; by adding a NULL to the end of the table
00376D  2               
00376D  2               TERMINATE_TABLE:
00376D  2  A9 00                LDA #$00
00376F  2  A8                   TAY
003770  2  91 EB                STA (RELOCATE_TABLE),Y
003772  2  C8                   INY
003773  2  91 EB                STA (RELOCATE_TABLE),Y
003775  2               
003775  2               ;
003775  2               ; At this point we have a completed relocation table!
003775  2               ; So much better than doing it by hand!!
003775  2               ;
003775  2               
003775  2               ; BEGIN AT THE START OF RELOCATION TABLE AGAIN
003775  2               
003775  2  A9 5E                LDA #<RELOCATION_TABLE
003777  2  85 EB                STA RELOCATE_TABLE_LO
003779  2  A9 39                LDA #>RELOCATION_TABLE
00377B  2  85 EC                STA RELOCATE_TABLE_HI
00377D  2               
00377D  2               ; now we are at the first entry in the table
00377D  2               
00377D  2               UPDATE_ADDRESSES:
00377D  2               
00377D  2               ; the table contains all the addresses we need to
00377D  2               ; update the source addresses.
00377D  2               
00377D  2               ; read the address we're to modify
00377D  2  A0 00                LDY #$00
00377F  2               
00377F  2  B1 EB                LDA (RELOCATE_TABLE),Y		; The lo address in the table
003781  2  85 FC                STA MOD_ADDR_LO
003783  2               
003783  2  C8                   INY
003784  2  B1 EB                LDA (RELOCATE_TABLE),Y		; the hi address in the table
003786  2  85 FD                STA MOD_ADDR_HI
003788  2               
003788  2  A5 FC                LDA MOD_ADDR_LO
00378A  2  05 FD                ORA MOD_ADDR_HI
00378C  2  F0 39                BEQ TABLE_EXHAUSTED		; if the entry is NULL, we're done
00378E  2               
00378E  2               ; load the address and subtract the difference
00378E  2               ; save the new address back
00378E  2               
00378E  2  88                   DEY 				; y back to zero
00378F  2               
00378F  2  AD 34 39             LDA MOVE_HIGHER         ; ZERO = MOVE HIGHER
003792  2  D0 13                BNE MOVE_DOWN2
003794  2               
003794  2               MOVE_UP2:
003794  2               
003794  2  B1 FC                LDA (MOD_ADDR),Y        ; add diff to the address!
003796  2  18                   CLC
003797  2  6D 32 39             ADC DIFF_LO
00379A  2  91 FC                STA (MOD_ADDR),Y
00379C  2               
00379C  2  C8                   INY
00379D  2  B1 FC                LDA (MOD_ADDR),Y
00379F  2  6D 33 39             ADC DIFF_HI
0037A2  2  91 FC                STA (MOD_ADDR),Y
0037A4  2               
0037A4  2  18                   CLC
0037A5  2  90 10                BCC MOVE_NEXT
0037A7  2               
0037A7  2               MOVE_DOWN2:
0037A7  2  B1 FC                LDA (MOD_ADDR),Y        ; subtract diff from the address
0037A9  2  38                   SEC
0037AA  2  ED 32 39             SBC DIFF_LO
0037AD  2  91 FC                STA (MOD_ADDR),Y
0037AF  2               
0037AF  2  C8                   INY
0037B0  2  B1 FC                LDA (MOD_ADDR),Y
0037B2  2  ED 33 39             SBC DIFF_HI
0037B5  2  91 FC                STA (MOD_ADDR),Y
0037B7  2               
0037B7  2               MOVE_NEXT:
0037B7  2               
0037B7  2               ; move to the next entry in the table
0037B7  2               
0037B7  2  18                   CLC
0037B8  2  A5 EB                LDA RELOCATE_TABLE_LO
0037BA  2  69 02                ADC #$02
0037BC  2  85 EB                STA RELOCATE_TABLE_LO
0037BE  2  A5 EC                LDA RELOCATE_TABLE_HI
0037C0  2  69 00                ADC #$00
0037C2  2  85 EC                STA RELOCATE_TABLE_HI
0037C4  2               
0037C4  2               ; JMP always
0037C4  2  18                   CLC
0037C5  2  90 B6                BCC UPDATE_ADDRESSES
0037C7  2               
0037C7  2               TABLE_EXHAUSTED:
0037C7  2               
0037C7  2               ; Now we can move the entire block of
0037C7  2               ; modified code and data to the appropriate
0037C7  2               ; memory location
0037C7  2               
0037C7  2  A9 6D                LDA #<RELOCATE_CODE_START
0037C9  2  85 ED                STA SRC_ADDR_LO
0037CB  2  A9 20                LDA #>RELOCATE_CODE_START
0037CD  2  85 EE                STA SRC_ADDR_HI
0037CF  2               
0037CF  2  A9 F0                LDA #<(RELOCATE_DATA_END-RELOCATE_CODE_START)	; THIS SIZE INCLUDES THE DATA
0037D1  2  8D 2E 39             STA SRC_SIZE_LO
0037D4  2  A9 15                LDA #>(RELOCATE_DATA_END-RELOCATE_CODE_START)
0037D6  2  8D 2F 39             STA SRC_SIZE_HI
0037D9  2               
0037D9  2  20 EF 37             JSR MOVE_TO_TARGET
0037DC  2               
0037DC  2  60               	RTS
0037DD  2               
0037DD  2               ; IF WE'RE HERE, WE'VE GOT AN ILLEGAL INSTRUCTION
0037DD  2               ; AND PROBABLY MIXED YOUR DATA WITH YOUR CODE
0037DD  2               ; THE ILLEGAL INSTRUCTION IS AT SRC_ADDR
0037DD  2               ILLEGAL_INSTRUCTION:
0037DD  2               .IF APPLEII
0037DD  2  A9 35                LDA #<ILLEGAL_INSTRUCTION_STR
0037DF  2  A0 39                LDY #>ILLEGAL_INSTRUCTION_STR
0037E1  2  20 3A DB             JSR STROUT
0037E4  2  A6 ED                LDX SRC_ADDR
0037E6  2  A5 EE                LDA SRC_ADDR+1
0037E8  2  20 41 F9             JSR PRTAX
0037EB  2  20 8E FD             JSR CROUT
0037EE  2               .ENDIF
0037EE  2  00                   BRK
0037EF  2               
0037EF  2               ;====================================
0037EF  2               ; MOVE_TO_TARGET
0037EF  2               ;   Generic routine for moving memory
0037EF  2               ; SRC_ADDR - address to take data from
0037EF  2               ; TGT_ADDR - where you want to put data
0037EF  2               ; SRC_SIZE - size in bytes of the block
0037EF  2               ;
0037EF  2               ; REGISTERS AFFECTED
0037EF  2               ;   ALL
0037EF  2               ;====================================
0037EF  2               ;
0037EF  2               ; Generic routine for moving memory
0037EF  2               ; The size of the block is in
0037EF  2               ; COPY_SIZE
0037EF  2               ; The Source is in SRC_ADDR
0037EF  2               ; The Target is in TGT_ADDR
0037EF  2               
0037EF  2               MOVE_TO_TARGET:
0037EF  2               
0037EF  2  A0 00                LDY #0
0037F1  2  AE 2F 39             LDX SRC_SIZE_HI
0037F4  2  F0 0E                BEQ MOVE2
0037F6  2  B1 ED        MOVE1:	LDA (SRC_ADDR),Y ; move a page at a time
0037F8  2  91 FA                STA (TGT_ADDR),Y
0037FA  2  C8                   INY
0037FB  2  D0 F9                BNE MOVE1
0037FD  2  E6 EE                INC SRC_ADDR+1
0037FF  2  E6 FB                INC TGT_ADDR+1
003801  2  CA                   DEX
003802  2  D0 F2                BNE MOVE1
003804  2  AE 2E 39     MOVE2:	LDX SRC_SIZE_LO
003807  2  F0 08        	    BEQ MOVE_COMPLETED
003809  2  B1 ED        MOVE3:	LDA (SRC_ADDR),Y ; move the remaining bytes
00380B  2  91 FA                STA (TGT_ADDR),Y
00380D  2  C8                   INY
00380E  2  CA                   DEX
00380F  2  D0 F8                BNE MOVE3
003811  2               
003811  2               MOVE_COMPLETED:
003811  2  60           	    RTS
003812  2               
003812  2               ;====================================
003812  2               ; ADJUST_HIMEM
003812  2               ;   Using the size in the relocation
003812  2               ; table, adjust HIMEM accordingly
003812  2               ; NOTE:  this routine briefly disables
003812  2               ;        interrupts
003812  2               ;
003812  2               ; REGISTERS AFFECTED
003812  2               ;   Accumulator
003812  2               ;====================================
003812  2               
003812  2               ;
003812  2               ; 	ADJUST HIMEM TO PROTECT US
003812  2               ;
003812  2               ADJUST_HIMEM:
003812  2               
003812  2  A9 F0                LDA #<(RELOCATE_DATA_END-RELOCATE_CODE_START)	; THIS SIZE INCLUDES THE DATA
003814  2  8D 2E 39             STA SRC_SIZE_LO
003817  2  A9 15                LDA #>(RELOCATE_DATA_END-RELOCATE_CODE_START)
003819  2  8D 2F 39             STA SRC_SIZE_HI
00381C  2               
00381C  2               ; Make sure another process
00381C  2               ; doesn't modify our
00381C  2               ; HIMEM, while we are modifying it
00381C  2               
00381C  2  78                   SEI
00381D  2  38                   SEC
00381E  2  A5 73                LDA HIMEM
003820  2  ED 2E 39             SBC SRC_SIZE_LO
003823  2  85 73                STA HIMEM
003825  2  A5 74                LDA HIMEM+1
003827  2  ED 2F 39             SBC SRC_SIZE_HI
00382A  2  85 74                STA HIMEM+1
00382C  2  58                   CLI
00382D  2               
00382D  2  60                   RTS
00382E  2               
00382E  2               
00382E  2               ; Each entry is points to the instruction
00382E  2               ; (not the address) we need to relocate
00382E  2               
00382E  2  01           INSTRUCTION_SIZE:   .BYTE $01 ; $00 BRK
00382F  2  02           		    .BYTE $02 ; $01 ORA X,IND
003830  2  00 00 00                         .BYTE 0,0,0
003833  2  02                               .BYTE $02 ; $05 ORA ZPG
003834  2  02                               .BYTE $02 ; $06 ASL ZPG
003835  2  00                               .BYTE $00
003836  2  01                               .BYTE $01 ; $08 PHP
003837  2  02                               .BYTE $02 ; $09 ORA #
003838  2  01                               .BYTE $01 ; $0A ASL
003839  2  00 00                            .BYTE 0,0
00383B  2  03                               .BYTE $03 ; $0D ORA ABS
00383C  2  03                               .BYTE $03 ; $0E ASL ABS
00383D  2  00                               .BYTE $00
00383E  2               
00383E  2  02                               .BYTE $02 ; $10 BPL
00383F  2  02                               .BYTE $02 ; $11 ORA IND,Y
003840  2  00 00 00                         .BYTE 0,0,0
003843  2  02                               .BYTE $02 ; $15 ORA ZPG,X
003844  2  02                               .BYTE $02 ; $16 AND ZPG
003845  2  00                               .BYTE $00
003846  2  01                               .BYTE $01 ; $18 CLC
003847  2  03                               .BYTE $03 ; $19 ORA ABS,Y
003848  2  00                               .BYTE 0  ;
003849  2  00 00                            .BYTE 0,0
00384B  2  03                               .BYTE $03 ; $1D ORA ABS,X
00384C  2  03                               .BYTE $03 ; $1E ASL ABS,X
00384D  2  00                               .BYTE $00
00384E  2               
00384E  2  03                               .BYTE $03 ; $20 JSR ABS
00384F  2  02                               .BYTE $02 ; $21 AND X,IND
003850  2  00 00                            .BYTE 0,0
003852  2  02                               .BYTE $02 ; $24 BIT ZPG
003853  2  02                               .BYTE $02 ; $25 AND ZPG
003854  2  02                               .BYTE $02 ; $26 ROL ZPG
003855  2  00                               .BYTE $00
003856  2  01                               .BYTE $01 ; $28 PLP
003857  2  02                               .BYTE $02 ; $29 AND #
003858  2  01                               .BYTE $01 ; $2A ROL
003859  2  00                               .BYTE 0
00385A  2  03                               .BYTE $03 ; $2C BIT ABS
00385B  2  03                               .BYTE $03 ; $2D ORA ABS
00385C  2  03                               .BYTE $03 ; $2E ROL ABS
00385D  2  00                               .BYTE $00
00385E  2               
00385E  2  02                               .BYTE $02 ; $30 BMI REL
00385F  2  02                               .BYTE $02 ; $31 AND IND,Y
003860  2  00 00 00                         .BYTE 0,0,0
003863  2  02                               .BYTE $02 ; $35 AND ZPG,X
003864  2  02                               .BYTE $02 ; $36 ROL ZPG,X
003865  2  00                               .BYTE $00
003866  2  01                               .BYTE $01 ; $38 SEC
003867  2  03                               .BYTE $03 ; $39 AND ABS,Y
003868  2  00                               .BYTE 0  ;
003869  2  00 00                            .BYTE 0,0
00386B  2  03                               .BYTE $03 ; $3D AND ABS,X
00386C  2  03                               .BYTE $03 ; $3E ROL ABS,X
00386D  2  00                               .BYTE $00
00386E  2               
00386E  2  01                               .BYTE $01 ; $40 RTI
00386F  2  02                               .BYTE $02 ; $41 EOR X,IND
003870  2  00 00 00                         .BYTE 0,0,0
003873  2  02                               .BYTE $02 ; $45 EOR ZPG
003874  2  02                               .BYTE $02 ; $46 LSR ZPG
003875  2  00                               .BYTE $00
003876  2  01                               .BYTE $01 ; $48 PHA
003877  2  02                               .BYTE $02 ; $49 EOR #
003878  2  01                               .BYTE $01 ; $4A LSR
003879  2  00                               .BYTE 0
00387A  2  03                               .BYTE $03 ; $4C JMP ABS
00387B  2  03                               .BYTE $03 ; $4D EOR ABS
00387C  2  03                               .BYTE $03 ; $4E LSR ABS
00387D  2  00                               .BYTE $00
00387E  2               
00387E  2  02                               .BYTE $02 ; $50 BVC REL
00387F  2  02                               .BYTE $02 ; $51 EOR IND,Y
003880  2  00 00 00                         .BYTE 0,0,0
003883  2  02                               .BYTE $02 ; $55 EOR ZPG,X
003884  2  02                               .BYTE $02 ; $56 LSR ZPG,X
003885  2  00                               .BYTE $00
003886  2  01                               .BYTE $01 ; $58 CLI
003887  2  03                               .BYTE $03 ; $59 EOR ABS,Y
003888  2  00                               .BYTE 0  ;
003889  2  00 00                            .BYTE 0,0
00388B  2  03                               .BYTE $03 ; $5D EOR ABS,X
00388C  2  03                               .BYTE $03 ; $5E LSR ABS,X
00388D  2  00                               .BYTE $00
00388E  2               
00388E  2  01                               .BYTE $01 ; $60 RTS
00388F  2  02                               .BYTE $02 ; $61 ADC X,IND
003890  2  00 00 00                         .BYTE 0,0,0
003893  2  02                               .BYTE $02 ; $65 ADC ZPG
003894  2  02                               .BYTE $02 ; $66 ROR ZPG
003895  2  00                               .BYTE $00
003896  2  01                               .BYTE $01 ; $68 PLA
003897  2  02                               .BYTE $02 ; $69 ADC #
003898  2  01                               .BYTE $01 ; $6A ROR
003899  2  00                               .BYTE 0
00389A  2  03                               .BYTE $03 ; $6C JMP IND
00389B  2  03                               .BYTE $03 ; $6D ADC ABS
00389C  2  03                               .BYTE $03 ; $6E ROR ABS
00389D  2  00                               .BYTE $00
00389E  2               
00389E  2  02                               .BYTE $02 ; $70 BVS REL
00389F  2  02                               .BYTE $02 ; $71 ADC IND,Y
0038A0  2  00 00 00                         .BYTE 0,0,0
0038A3  2  02                               .BYTE $02 ; $75 ADC ZPG,X
0038A4  2  02                               .BYTE $02 ; $76 ROR ZPG,X
0038A5  2  00                               .BYTE $00
0038A6  2  01                               .BYTE $01 ; $78 SEI
0038A7  2  03                               .BYTE $03 ; $79 ADC ABS,Y
0038A8  2  00                               .BYTE 0  ;
0038A9  2  00 00                            .BYTE 0,0
0038AB  2  03                               .BYTE $03 ; $7D ADC ABS,X
0038AC  2  03                               .BYTE $03 ; $7E ROR ABS,X
0038AD  2  00                               .BYTE $00
0038AE  2               
0038AE  2  00                               .BYTE 0
0038AF  2  02                               .BYTE $02 ; $81 STA X,IND
0038B0  2  00 00                            .BYTE 0,0
0038B2  2  02                               .BYTE $02 ; $84 STY ZPG
0038B3  2  02                               .BYTE $02 ; $85 STA ZPG
0038B4  2  02                               .BYTE $02 ; $86 STX ZPG
0038B5  2  00                               .BYTE $00
0038B6  2  01                               .BYTE $01 ; $88 DEY
0038B7  2  09                               .BYTE 9
0038B8  2  01                               .BYTE $01 ; $8A TXA
0038B9  2  00                               .BYTE 0
0038BA  2  03                               .BYTE $03 ; $8C STY ABS
0038BB  2  03                               .BYTE $03 ; $8D STA ABS
0038BC  2  03                               .BYTE $03 ; $8E STX ABS
0038BD  2  00                               .BYTE $00
0038BE  2               
0038BE  2  02                               .BYTE $02 ; $90 BCC REL
0038BF  2  02                               .BYTE $02 ; $91 STA IND,Y
0038C0  2  00 00                            .BYTE 0,0
0038C2  2  02                               .BYTE $02 ; $94 STY ZPG,X
0038C3  2  02                               .BYTE $02 ; $95 STA ZPG,X
0038C4  2  02                               .BYTE $02 ; $96 STX ZPG,X
0038C5  2  00                               .BYTE $00
0038C6  2  01                               .BYTE $01 ; $98 TYA
0038C7  2  03                               .BYTE $03 ; $99 STA ABS,Y
0038C8  2  01                               .BYTE $01 ; $9A TXS
0038C9  2  00 00                            .BYTE 0,0
0038CB  2  03                               .BYTE $03 ; $9D STA ABS,X
0038CC  2  00                               .BYTE 0
0038CD  2  00                               .BYTE $00
0038CE  2               
0038CE  2  02                               .BYTE $02 ; $A0 LDY #
0038CF  2  02                               .BYTE $02 ; $A1 LDA X, IND
0038D0  2  02                               .BYTE $02 ; $A2 LDX #
0038D1  2  00                               .BYTE 0
0038D2  2  02                               .BYTE $02 ; $A4 LDY ZPG
0038D3  2  02                               .BYTE $02 ; $A5 LDA ZPG
0038D4  2  02                               .BYTE $02 ; $A6 LDX ZPG
0038D5  2  00                               .BYTE $00
0038D6  2  01                               .BYTE $01 ; $A8 TAY
0038D7  2  02                               .BYTE $02 ; $A9 LDA #
0038D8  2  01                               .BYTE $01 ; $AA TAX
0038D9  2  00                               .BYTE 0
0038DA  2  03                               .BYTE $03 ; $AC LDY ABS
0038DB  2  03                               .BYTE $03 ; $AD LDA ABS
0038DC  2  03                               .BYTE $03 ; $AE LDX ABS
0038DD  2  00                               .BYTE $00
0038DE  2               
0038DE  2  02                               .BYTE $02 ; $B0 BCS REL
0038DF  2  02                               .BYTE $02 ; $B1 LDA IND,Y
0038E0  2  00 00                            .BYTE 0,0
0038E2  2  02                               .BYTE $02 ; $B4 LDY ZPG,X
0038E3  2  02                               .BYTE $02 ; $B5 LDA ZPG,X
0038E4  2  02                               .BYTE $02 ; $B6 LDX ZPG,Y
0038E5  2  00                               .BYTE $00
0038E6  2  01                               .BYTE $01 ; $B8 CLV
0038E7  2  03                               .BYTE $03 ; $B9 LDA ABS,Y
0038E8  2  01                               .BYTE $01 ; $BA TSX
0038E9  2  00                               .BYTE 0
0038EA  2  03                               .BYTE $03 ; $BC LDY ABS,X
0038EB  2  03                               .BYTE $03 ; $BD LDA ABS,X
0038EC  2  03                               .BYTE $03 ; $BE LDX ABS,Y
0038ED  2  00                               .BYTE $00
0038EE  2               
0038EE  2  02                               .BYTE $02 ; $C0 CPY #
0038EF  2  02                               .BYTE $02 ; $C1 CMP X,IND
0038F0  2  00 00                            .BYTE 0,0
0038F2  2  02                               .BYTE $02 ; $C4 CPY ZPG
0038F3  2  02                               .BYTE $02 ; $C5 CMP ZPG
0038F4  2  02                               .BYTE $02 ; $C6 DEC ZPG
0038F5  2  00                               .BYTE $00
0038F6  2  01                               .BYTE $01 ; $C8 INY
0038F7  2  02                               .BYTE $02 ; $C9 CMP #
0038F8  2  01                               .BYTE $01 ; $CA DEX
0038F9  2  00                               .BYTE 0
0038FA  2  03                               .BYTE $03 ; $CC CPY ABS
0038FB  2  03                               .BYTE $03 ; $CD CMP ABS
0038FC  2  03                               .BYTE $03 ; $CE DEC ABS
0038FD  2  00                               .BYTE $00
0038FE  2               
0038FE  2  02                               .BYTE $02 ; $D0 BNE REL
0038FF  2  02                               .BYTE $02 ; $D1 CMP IND,Y
003900  2  00 00 00                         .BYTE 0,0,0
003903  2  02                               .BYTE $02 ; $D5 CMP ZPG,X
003904  2  02                               .BYTE $02 ; $D6 DEC ZPG,X
003905  2  00                               .BYTE $00
003906  2  01                               .BYTE $01 ; $D8 CLD
003907  2  03                               .BYTE $03 ; $D9 CMP ABS,Y
003908  2  00 00 00                         .BYTE 0,0,0
00390B  2  03                               .BYTE $03 ; $DD CMP ABS,X
00390C  2  03                               .BYTE $03 ; $DE DEC ABS,X
00390D  2  00                               .BYTE $00
00390E  2               
00390E  2  02                               .BYTE $02 ; $E0 CPX #
00390F  2  02                               .BYTE $02 ; $E1 SBC X,IND
003910  2  00 00                            .BYTE 0,0
003912  2  02                               .BYTE $02 ; $E4 CPX ZPG
003913  2  02                               .BYTE $02 ; $E5 SBC ZPG
003914  2  02                               .BYTE $02 ; $E6 INC ZPG
003915  2  00                               .BYTE $00
003916  2  01                               .BYTE $01 ; $E8 INX
003917  2  02                               .BYTE $02 ; $E9 SBC #
003918  2  01                               .BYTE $01 ; $EA NOP
003919  2  00                               .BYTE 0
00391A  2  03                               .BYTE $03 ; $EC CPX ABS
00391B  2  03                               .BYTE $03 ; $ED SBC ABS
00391C  2  03                               .BYTE $03 ; $EE INC ABS
00391D  2  00                               .BYTE $00
00391E  2               
00391E  2  02                               .BYTE $02 ; $F0 BEQ REL
00391F  2  02                               .BYTE $02 ; $F1 SBC IND,Y
003920  2  00 00 00                         .BYTE 0,0,0
003923  2  02                               .BYTE $02 ; $F5 SBC ZPG,X
003924  2  02                               .BYTE $02 ; $F6 INC ZPG,X
003925  2  00                               .BYTE $00
003926  2  01                               .BYTE $01 ; $F8 SED
003927  2  02                               .BYTE $02 ; $F9 SBC #
003928  2  00 00 00                         .BYTE 0,0,0
00392B  2  03                               .BYTE $03 ; $FD SBC ABS,X
00392C  2  03                               .BYTE $03 ; $FE INC ABS,X
00392D  2  00                               .BYTE $00
00392E  2               
00392E  2               
00392E  2               ; RC_SIZE
00392E  2               SRC_SIZE:
00392E  2  00           SRC_SIZE_LO:		.BYTE $00
00392F  2  00           SRC_SIZE_HI:		.BYTE $00
003930  2               
003930  2               ;SRC_ADDR_END_LO:	.BYTE $00
003930  2               ;SRC_ADDR_END_HI:	.BYTE $00
003930  2               
003930  2               ;SRC_DATA_END_LO:	.BYTE $00
003930  2               ;SRC_DATA_END_HI:	.BYTE $00
003930  2               
003930  2  00           CODE_SIZE_LO:		.BYTE $00
003931  2  00           CODE_SIZE_HI:		.BYTE $00
003932  2               
003932  2               DIFF:
003932  2  00           DIFF_LO:		.BYTE $00
003933  2  00           DIFF_HI:		.BYTE $00
003934  2               
003934  2  00           MOVE_HIGHER:              .BYTE $00
003935  2               
003935  2  52 45 4C 4F  ILLEGAL_INSTRUCTION_STR: .ASCIIZ "RELOCATE ERROR, ILLEGAL INSTRUCTION AT: "
003939  2  43 41 54 45  
00393D  2  20 45 52 52  
00395E  2               
00395E  2               
00395E  2               
00395E  1               
00395E  1               RELOCATION_TABLE:
00395E  1               .include "FUJIAPPLE_RELOC.S"
00395E  2               ; in FUJIAPPLE.S
00395E  2  2E 20 34 20  		.WORD 	relocate000+1,relocate001+1,relocate002+1,relocate003+1,relocate004+1,relocate005+1,relocate006+1,relocate007+1,relocate008,relocate009
003962  2  3A 20 40 20  
003966  2  48 20 4E 20  
003972  2  29 2B 32 2B  		.WORD 	relocate010,relocate011,relocate012,relocate013,relocate014,relocate015,relocate016,relocate017,relocate018,relocate019
003976  2  3A 2B 43 2B  
00397A  2  4C 2B 51 2B  
003986  2  76 2E 7A 2F  		.WORD   relocate020,relocate021;,relocate022,relocate023,relocate024,relocate025,relocate026,relocate027,relocate028,relocate029
00398A  2               
00398A  1               .include "STR_RELOC.S"
00398A  2               
00398A  2  2C 30 3F 30  		.WORD 	str000,str001,str002,str003,str004,str005,str006,str007,str008,str009
00398E  2  7E 30 94 30  
003992  2  B4 30 FA 30  
00399E  2  48 31 59 31  		.WORD 	str010,str011,str012,str013,str014,str015,str016,str017,str018;,str019
0039A2  2  6D 31 84 31  
0039A6  2  96 31 A1 31  
0039B0  2               ;		 .WORD   str020,str021,str022,str023,str024,str025,str026,str027,str028,str029
0039B0  2               
0039B0  2               
0039B0  2               
0039B0  2               .IF .NOT STRIP_TRACE
0039B0  2               
0039B0  2               		.WORD 	trace000,trace001,trace002,trace003,trace004,trace005,trace006,trace007,trace008,trace009
0039B0  2               		.WORD 	trace010,trace011,trace012,trace013,trace014,trace015,trace016,trace017,trace018,trace019
0039B0  2               		.WORD   trace020,trace021,trace022,trace023,trace024,trace025,trace026,trace027,trace028,trace029
0039B0  2               		.WORD   trace030,trace031,trace032,trace033,trace034,trace035,trace036,trace037,trace038,trace039
0039B0  2               		.WORD   trace040,trace041,trace042,trace043,trace044,trace045,trace046,trace047,trace048,trace049
0039B0  2               		.WORD	trace053,trace054;,trace055,trace056,trace057,trace058,trace059
0039B0  2               
0039B0  2               .ENDIF
0039B0  2               
0039B0  1               .include "SMARTPORT_RELOC.S"
0039B0  2  2E 32 30 32                 .WORD    relocatesp00,relocatesp01,relocatesp02,relocatesp03;,relocatesp04,relocatesp05,relocatesp06,relocatesp07;,relocatesp08,relocatesp09
0039B4  2  4A 32 54 35  
0039B8  2               ;               .WORD    relocatesp10,relocatesp11,relocatesp12,relocatesp13,relocatesp14,relocatesp15,relocatesp16,relocatesp17,relocatesp18,relocatesp19
0039B8  2               
0039B8  1               .include "FAKESMARTPORT_RELOC.S"
0039B8  2               .IF .NOT STRIP_TRACE
0039B8  2               
0039B8  2               		.WORD	trace050,trace051,trace052
0039B8  2               
0039B8  2               .ENDIF
0039B8  2               
0039B8  1               END_RELOCATION_TABLE:
0039B8  1  00 00                        .WORD 	0 ; end of table
0039BA  1               
0039BA  1               ; We should generate an error if there are too many entries (greater than 255)
0039BA  1               
0039BA  1  EA           ENDOFFILE:      NOP
0039BB  1               
0039BB  1               
