;
; BASIC.SYSTEM POC for FNTOOLS Commands
;
; Adds extended commands to BASIC.SYSTEM. 
; The commands are found in a table near the end of this
; program.
;
; Rather than having an binary file for each FN command
; (each requiring a redunant command line  parsing routine),
; this will test the command line for any commands found 
; in the table and jump to its corresponding subroutine.
;
; Author: Michael Sternberg
;  <mhsternberg@gmail.com
;
; Adapted from
; "Apple ProDOS: Advanced Features for Programmers" (Little)
;
;
            .setcpu     "6502"
            .segment    "SEG1"

            ; Macros to set high bit for Apple text
            .include "apple2text.inc"

SBLOCK      :=      $3C         ;Parameters for block move
EBLOCK      :=      $3E
FBLOCK      :=      $42
HIMEM       :=      $73         ;Use this as ONLINE buffer
                    
IN          :=      $0200       ;Command input buffer
                    
EXTRNCMD    :=      $BE06       ;External command JMP instruction
ERROUT      :=      $BE09       ;Error handler
XTRNADDR    :=      $BE50       ;Start of external cmd handler
XLEN        :=      $BE52       ;External cmd name length (-1)
XCNUM       :=      $BE53       ;Command # (0 for external)
PBITS       :=      $BE54       ;Command parameter bits
FBITS       :=      $BE56       ;Parameters fond in parse
VPATH1	    :=      $BE6C	;pathname specified
VSLOT       :=      $BE61       ;Slot parameter specified
VDRIV       :=      $BE62       ;Drive parameter specified
VTYPE	    :=      $BE6A       ;Type parameter specified
GETBUFR     :=      $BEF5       ;Get a free space
                    
MLI         :=      $BF00       ;Entry point to MLI
                    
CROUT       :=      $FD8E       ;Print a CR
COUT        :=      $FDED       ;Std. character output subroutine
MOVE        :=      $FE2C       ;Block move subroutine

NET 	    :=      $09         ; Hardcoded network device for now.
	
            .org    $2000

;-----------------------------------------------
; Calculate # of pages that we need to reserve:
;-----------------------------------------------
            SEC
            LDA     #>END
            SBC     #>CMDCODE
            STA     PAGES
            INC     PAGES
                    
            LDA     PAGES
            JSR     GETBUFR     ;Reserve the pages for the
            BCC     INSTALL     ; command handler
                    
            LDA     #14         ;"PROGRAM TOO LARGE" error
            JMP     ERROUT

INSTALL:    STA     PGSTART     ;Save starting page #

;---------------------------------------
; Install the new command handler:
;---------------------------------------
            LDA     EXTRNCMD+1  ;Set up link to
            STA     NEXTCMD+1   ; existing external command.
            LDA     EXTRNCMD+2
            STA     NEXTCMD+2

;****************************************
;* Install the external command handler *
;* by storing its address after the     *
;* JMP at EXTRNCMD.                     *
;****************************************
            LDA     #$00
            STA     EXTRNCMD+1
            LDA     PGSTART
            STA     EXTRNCMD+2

;---------------------------------------
; Relocate the code
;---------------------------------------
            LDX     PGSTART     ; Get new page #

            STX     reloc_T00+2
            STX     reloc_T01
            STX     reloc_T02
            TXA
            INX                 ; Page boundary crossed
            STX     reloc_T03
            STX	    reloc_T04
	    STX     reloc_T05
            INX                 ; Page boundary crossed
	    STX	    reloc_T06
	
            TAX                 ; Revert
            STX     reloc_000+2
            STX     reloc_010+2
            STX     reloc_020+2
            STX     reloc_030+2
            STX     reloc_040+2
            STX     reloc_050+2
            STX     reloc_060+2
            STX     reloc_070+2
            STX     reloc_080+2
            STX     reloc_090+2
            STX     reloc_100+2

            INX                 ; Page boundary crossed
            ;; STX     reloc_110+2	
            ;; STX     reloc_120+2



    ;-----------------------------------
    ; Set up parameters for 
    ; block move to final location:
    ;-----------------------------------
            LDA     #<CMDCODE
            STA     SBLOCK
            LDA     #>CMDCODE
            STA     SBLOCK+1
                    
            LDA     #<END
            STA     EBLOCK
            LDA     #>END
            STA     EBLOCK+1
                    
            LDA     #0
            STA     FBLOCK
            LDA     PGSTART
            STA     FBLOCK+1
                
    ;-----------------------------------
    ; Perform the relocation
    ;-----------------------------------
            LDY     #0
            JMP     MOVE        ;Move it!

PAGES:      .res    1           ;Length of command handler
PGSTART:    .res    1           ;Starting page of command handler
            .align  $0100       ; Align to next page boundary

;---------------------------------------
; Relocated code begins here
;---------------------------------------

CMDCODE     :=      *

    ;-----------------------------------
    ; Moved the command tables to here
    ; to help ease the burden of updating
    ; the relocation table.
    ;-----------------------------------

reloc_T00:  JMP PARSER          ; Jump over the command tables

;---------------------------------------
; Command Tables
;---------------------------------------

CMD:        .res    1           ; Index to matched command (0=NPREFIX, 1=NPWD, ..)

            .enum CMD_IDX
                NPREFIX
                NPWD
                NDEL
	        NMKDIR
	        NOPEN
	        NCLOSE
            .endenum

COMMAND:
            ASCIIHI "NPREFIX"
            .byte   $00
            .byte   CMD_IDX::NPREFIX

            ASCIIHI "NPWD"
            .byte   $00
            .byte   CMD_IDX::NPWD

            ASCIIHI "NDEL"
            .byte   $00
            .byte   CMD_IDX::NDEL

	    ASCIIHI "NMKDIR"
	    .byte   $00
	    .byte   CMD_IDX::NMKDIR

	    ASCIIHI "NOPEN"
	    .byte   $00
	    .byte   CMD_IDX::NOPEN

	    ASCIIHI "NCLOSE"
	    .byte   $00
	    .byte   CMD_IDX::NCLOSE

COMMAND_SIZE = * - COMMAND - 1

CMD_TAB_L:  
            .byte   <DO_NPREFIX
            .byte   <DO_NPWD
            .byte   <DO_NDEL
            .byte   <DO_NMKDIR	
	    .byte   <DO_NOPEN
	    .byte   <DO_NCLOSE
	
CMD_TAB_H:  
reloc_T01:  .byte   >DO_NPREFIX
reloc_T02:  .byte   >DO_NPWD
reloc_T03:  .byte   >DO_NDEL
reloc_T04:  .byte   >DO_NMKDIR
reloc_T05:  .byte   >DO_NOPEN
reloc_T06:  .byte   >DO_NCLOSE
	
PBITS_TAB_L:
            .byte   $10         ; 0 - NPREFIX
            .byte   $10         ; 1 - NPWD
            .byte   $10         ; 2 - NDEL
            .byte   $10         ; 3 - NMKDIR
	    .byte   $25	        ; 4 - NOPEN
	    .byte   $04         ; 5 - NCLOSE
	
PBITS_TAB_H:  
            .byte   $04         ; 0 - NPREFIX
            .byte   $04         ; 1 - NPWD
            .byte   $04         ; 2 - NDEL
	    .byte   $04         ; 3 - NMKDIR
            .byte   $00         ; 4 - NOPEN
	    .byte   $00         ; 5 - NCLOSE
	
BUFFER:     .addr   $0000

;************************************
; This is the command checker. It  *
; scans the input buffer to see    *
; if any of the commands in the command table
; have been entered.
;************************************

PARSER:     CLD                 ; Used as flag

    ;------------------------------------
    ; Skip leading spaces
    ;------------------------------------
            LDY     #$00        ; Init index to command table
            LDX     #$FF        ; Init index to cmd line
SKPSPC:     INX
            LDA     IN,X        ; Get char from cmd line
            CMP     #$A0        ; If space, go to next
            BEQ     SKPSPC

    ;------------------------------------
    ; Get char from cmd line
    ;------------------------------------
            DEX                 ; Kludge
CHKCMD:     INX                 ; Advance index to cmd line char
CHKCMD1:    LDA     IN,X        ; Get cmd line char
            CMP     #$8D        ; Terminate if EOL
            BEQ     CMDSKP1     ; 
            CMP     #$A0        ; Terminate if space
            BNE     CMDSKP2     ; Otherwise use face value
CMDSKP1:    LDA     #$00        ; Convert EOL or space to null

    ;--------------------------------------------
    ; Compare cmd line char to command table char
    ;--------------------------------------------
CMDSKP2:
reloc_000:  CMP     COMMAND,Y   ; Do chars match?
            BNE     SKPCMD      ; No. Skip to next cmd entry and try again

    ;------------------------------------
    ; Found matching character
    ;------------------------------------
reloc_010:  LDA     COMMAND,Y       ; Check if curr char is null ($00)
            BEQ     SETRULES        ; At end of command string (null)?
            CPY     #COMMAND_SIZE-1 ; At end of command table?
            BEQ     NOTFOUND        ; If yes, quit
            INY                     ; Advance to next char in command table
            BNE     CHKCMD          ; Continue checking chars
            
    ;------------------------------------
    ; Skip to next entry in command table
    ;------------------------------------
SKPCMD:     INY
reloc_020:  LDA     COMMAND,Y       ; Skip to null char
            BNE     SKPCMD
            ;----
            INY                     ; Advance to next command table entry
            CPY     #COMMAND_SIZE   ; At end of command table?
            BCS     NOTFOUND        ; Yes (Y>=COMMAND_SIZE), then quit
            INY                     ; 
            LDX     #$00            ; Reset index to cmd line
            BEQ     CHKCMD1         ; Try next entry in command table

;---------------------------------------
NOTFOUND:   
;---------------------------------------
            SEC 
NEXTCMD:    JMP     $0000           ;(Fill in when installed)

;---------------------------------------
SETRULES:
;---------------------------------------
            INY                     ; Advance to command index in table
reloc_030:  LDA     COMMAND,Y       ; Get command index
reloc_040:  STA     CMD             ; Store Command index
            DEX
            STX     XLEN            ; Store command length - 1
            TAX
reloc_050:  LDA     CMD_TAB_L,X     ; Get address of command subroutine
            STA     XTRNADDR
reloc_060:  LDA     CMD_TAB_H,X     ; Get address of command subroutine
            STA     XTRNADDR+1

            LDA     #$00
            STA     XCNUM           ;External cmd number = 0

;---------------------------------------
; Set up string parsing rules:
;---------------------------------------
reloc_070:  LDA     PBITS_TAB_L,X
            STA     PBITS
reloc_080:  LDA     PBITS_TAB_H,X
            STA     PBITS+1

            LDA     HIMEM
reloc_090:  STA     BUFFER
            LDA     HIMEM+1
reloc_100:  STA     BUFFER+1

;---------------------------------------
; Exit
;---------------------------------------
            CLC                     ;Clear carry to indicate success
            RTS                     ;Finished

;---------------------------------------
; BASIC.SYSTEM comes here after it has
; successfully parsed the command line:
;---------------------------------------

;---------------------------------------
DO_NPREFIX:     
;---------------------------------------
NPREFIX1: 
	LDX	#$00
	LDA	#$00
:	STA	$0200,X
	INX
	BNE	:-
	LDA	FBITS
	AND	#$01		; Check for filename
	BNE	NPREFIX2
	LDA	#$01		; zero out len
	STA	$0200
	BCC	NPREFIX35		; Send out empty payload to reset ncd
	;;
NPREFIX2:	LDA	VPATH1
	STA	$FA
	LDA	VPATH1+1
	STA	$FB
	LDY	#$00		; Offset 0 - String length
	STY	$0201
	LDA	($FA),Y		; Get length
	TAX
	STA	$FC		; Store it.
	INX			;
	STX	$0200		; Store it in length low.
	LDA	FBITS
NPREFIX3:   INY				
	LDA	($FA),Y		; Next char
	STA	$0201,Y		; Copy it
	CPY	$FC		; At end?
	BNE	NPREFIX3		; Nope, continue.
NPREFIX35:	JSR	$C50D
	.BYTE	$04
	.WORD	NPREFIXOP
	
	BCC	NPREFIX4
	LDA	#$02
NPREFIX4:
	CLC
	RTS

NPREFIXOP:	
	.byte	$03		; Control has 3 params
	.byte	NET		; to Network device
	.word	IN		; Buffer is at $0200
	.byte	','		; NPREFIX command

;---------------------------------------
DO_NPWD:     
;---------------------------------------
NPWD:   LDX	#$00
	LDA	#$00
:	STA	$0200,X
	INX
	BNE	:-
	JSR	$C50D		; Call Smartport
	.BYTE	$00		; Status
	.WORD	NPWDOP		; Use NPWDOP for params
	BCS	NPWDON		; error? done.
	JSR	CROUT
	LDX	#$00
:	LDA	IN,X
	BEQ	NPWDOK
	ORA	#$80		; Make normal text
	JSR	COUT
	INX
	BNE	:-
NPWDOK:	JSR	CROUT
	JSR	CROUT
	CLC
NPWDON:	RTS
NPWDOP:
	.byte	$03		; Status is 3 params
	.byte	NET		; to network device
	.word	IN		; Destination is input buf
	.byte	'0'		; PWD command.
	
NPWD_DONE:  RTS

;---------------------------------------
DO_NDEL:     
;---------------------------------------
	LDX	#$00
	LDA	#$00
:	STA	$0200,X
	INX
	BNE	:-
	LDA	FBITS
	AND	#$01		; Check for filename
	BNE	:+
	LDA	#$01		; zero out len
	STA	$0200
	BCC	NDELDO		; Send out empty payload to reset ncd
	;;
:	LDA	VPATH1
	STA	$FA
	LDA	VPATH1+1
	STA	$FB
	LDY	#$00		; Offset 0 - String length
	STY	$0201
	LDA	($FA),Y		; Get length
	TAX
	STA	$FC		; Store it.
	INX			;
	STX	$0200		; Store it in length low.
	LDA	FBITS

:   	INY				
	LDA	($FA),Y		; Next char
	STA	$0201,Y		; Copy it
	CPY	$FC		; At end?
	BNE	:-		; Nope, continue.
	
NDELDO:	JSR	$C50D
	.BYTE	$04
	.WORD	NDELOP
	
	BCC	NDEL4
	LDA	#$02
NDEL4:
	CLC
	RTS

NDELOP:	
	.byte	$03		; Control has 3 params
	.byte	NET		; to Network device
	.word	IN		; Buffer is at $0200
	.byte	'!'		; NDEL command

;---------------------------------------
DO_NMKDIR:     
;---------------------------------------
	LDX	#$00
	LDA	#$00
:	STA	$0200,X
	INX
	BNE	:-
	LDA	FBITS
	AND	#$01		; Check for filename
	BNE	:+
	LDA	#$01		; zero out len
	STA	$0200
	BCC	NMKDIRDO		; Send out empty payload to reset ncd
	;;
:	LDA	VPATH1
	STA	$FA
	LDA	VPATH1+1
	STA	$FB
	LDY	#$00		; Offset 0 - String length
	STY	$0201
	LDA	($FA),Y		; Get length
	TAX
	STA	$FC		; Store it.
	INX			;
	STX	$0200		; Store it in length low.
	LDA	FBITS

:   	INY				
	LDA	($FA),Y		; Next char
	STA	$0201,Y		; Copy it
	CPY	$FC		; At end?
	BNE	:-		; Nope, continue.
	
NMKDIRDO:	JSR	$C50D
	.BYTE	$04
	.WORD	NMKDIROP
	
	BCC	NMKDIR4
	LDA	#$02
NMKDIR4:
	CLC
	RTS

NMKDIROP:	
	.byte	$03		; Control has 3 params
	.byte	NET		; to Network device
	.word	IN		; Buffer is at $0200
	.byte	'*'		; NMKDIR command

;---------------------------------------
DO_NOPEN:     
;---------------------------------------
	LDX	#$00
	LDA	#$00
:	STA	$0200,X
	INX
	BNE	:-
	LDA	FBITS
	AND	#$01		; Check for filename
	BNE	:+
	LDA	#$01		; zero out len
	STA	$0200
	BCC	NOPENDO		; Send out empty payload to reset ncd
	;;
:	LDA	VPATH1
	STA	$FA
	LDA	VPATH1+1
	STA	$FB
	LDY	#$00		; Offset 0 - String length
	STY	IN+1
	LDA	($FA),Y		; Get length
	TAX
	STA	$FC		; Store it.
	INX
	INX
	INX
	STX	$0200		; Store it in length low.
	LDY	#$FF
	
:	INY
	LDA	($FA),Y		; Next char
	STA	IN+4,Y		; Copy it
	CPY	$FC		; At end?
	BNE	:-		; Nope, continue.

	LDA	#$0C		; READ/WRITE by default
	STA	IN+2
	LDA	#$00		; No Translation
	STA	IN+3

	LDA	FBITS
	AND	#$04		; T set?
	BEQ	NOPENDO		; Nope, go to open
	LDA	VTYPE		; Yes, get T param
	STA	IN+2		; Store in first byte of buffer
	
NOPENDO:
	JSR	$C50D
	.BYTE	$04
	.WORD	NOPENOP
	
	BCS	NOPEN5
NOPEN4:
	RTS

NOPEN5:	LDA	#$08		; I/O ERROR
	SEC
	JSR	$BE09
	RTS
	
NOPENOP:	
	.byte	$03		; Control has 3 params
	.byte	NET		; to Network device
	.word	IN		; Buffer is at $0200
	.byte	'O'		; NOPEN command

;---------------------------------------
DO_NCLOSE:     
;---------------------------------------

	LDA	#$01
	STA	IN
        LDA     #$00
	STA	IN+1
	JSR	$C50D		; Do close
	.BYTE	$04
	.WORD	NCLOSEOP	; Do close
	BCS	NCDON
NCDON:	CLC
	RTS

NCLOSEOP:
	.byte	$03		; Control has 3 params
	.byte	NET		; Network device
	.WORD	IN		; Doesn't matter
	.byte	'C'		; Close
	
END         :=      *
