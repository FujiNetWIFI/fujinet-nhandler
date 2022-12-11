;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;
;;; ;; #FujiNet N: handler for ProDOS
;;; ;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "CODE"
	
	INBUF      =  $0200     ;GETLN input buffer.
 	WAIT       =  $FCA8    ;Monitor wait routine.
	BELL       =  $FF3A    ;Monitor bell routine.
	EXTRNCMD   =  $BE06    ;External cmd JMP vector.
	XTRNADDR   =  $BE50    ;Ext cmd implementation addr.
	XLEN       =  $BE52    ;length of command string-1.
	XCNUM      =  $BE53    ;CI cmd no. (ext cmd - 0).
	PBITS      =  $BE54    ;Command parameter bits.
	XRETURN    =  $BE9E    ;Known RTS instruction.
	
 ;; * FIRST SAVE THE EXTERNAL COMMAND ADDRESS SO YOU WON'T 
 ;; * DISCONNECT ANY PREVIOUSLY CONNECTED COMMAND.
 ;; *

        LDA  EXTRNCMD+1
        STA  NXTCMD
        LDA  EXTRNCMD+2
        STA  NXTCMD+1
	;; 
        LDA  #<BEEP      ;Install the address of our
        STA  EXTRNCMD+1  ; command handler in the
        LDA  #>BEEP      ; external command JMP
        STA  EXTRNCMD+2  ; vector.
        RTS
	;; 
BEEP:	LDX  #0          ;Check for our command.
NXTCHR:	LDA  INBUF,X     ;Get first character.
        CMP  CMD,X       ;Does it match?
        BNE  NOTOURS     ;No, back to CI.
        INX              ;Next character
        CPX  #CMDLEN     ;All characters yet?
        BNE  NXTCHR      ;No, read next one.
	;; 
        LDA  #CMDLEN-1   ;Our cmd! Put cmd length-1
        STA  XLEN        ; in CI global XLEN.
        LDA  #<START   ;Point XTRNADDR to a known
        STA  XTRNADDR    ; RTS since we'll handle
        LDA  #>START   ; at the time we intercept
	;;
	STA  XTRNADDR+1  ; our command.
        LDA  #0          ;Mark the cmd number as
        STA  XCNUM       ; zero (external).
        STA  PBITS       ;And indicate no parameters
        STA  PBITS+1     ; to be parsed.
	;;
	CLC
	RTS
	
NOTOURS:
	SEC              ; ALWAYS SET CARRY IF NOT YOUR
        JMP  (NXTCMD)    ; CMD AND LET NEXT COMMAND TRY
			 ; TO CLAIM IT.

START:	LDA	#$00		; 256 bytes
	STA	$0200
	LDA	#$01
	STA	$0201
	LDA	#$0C		; GET
	STA	$0202
	LDA	#$80		; NONE
	STA	$0203

	;; Strip hi bit.
FXT:	LDA	INBUF,X
	AND	#$7F
	STA	INBUF,X
	INX
	BNE	FXT
	
	JSR  $C50D		; Hardcoded
	.BYTE	$04		; CTRL
	.WORD	CLCTRL

	BCS	CONNECTED
CONNECTED:
IN:	LDA	$C000
	BPL	OUT
	AND	#$7F
	STA	$0202
	STA	$C010
	LDA	#$00
	STA	$0201
	LDA	#$01
	STA	$0200
	LDA	#'W'
	STA	CLCTRL+4
	JSR	$C50D
	.BYTE	$04
	.WORD	CLCTRL
	BCS	OUT	
OUT:
	JSR	$C50D
	.BYTE	$00
	.WORD	CLSTAT
	BCS	OUT1
OUT1:	LDA	$0200
	BEQ	IN
	LDA	#$01
	STA	CLREAD+4
	STA	TMP
	JSR	$C50D
	.BYTE	$08
	.WORD	CLREAD
	BCS	OUT2
OUT2:	LDA	$0200
	ORA	$80
	JSR	$FDED
	JMP	OUT	

CMD:
	.byte 'N'+$80,'E'+$80,'T'+$80 ; 'NET'
	
 CMDLEN =  *-CMD       ; Our command length
	;; 

NXTCMD:
	.word   0           ; STORE THE NEXT EXT CMD'S
				; ADDRESS HERE.

TMP:	.byte $00
	
CLCTRL:
	.byte $03		; CONTROL has 3 params
	.byte $07		; Hard coded to dev 7 for now.
	.byte $00
	.byte $02
	.byte 'O'		; OPEN

CLSTAT:
	.byte $03
	.byte $07
	.byte $00
	.byte $02
	.byte 'S'

CLREAD:
	.byte $04
	.byte $07
	.byte $00
	.byte $02
	.byte $00
	.byte $00
