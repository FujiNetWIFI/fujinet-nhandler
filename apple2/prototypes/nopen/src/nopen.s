;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;
;;; ;; NOPEN implementation
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
	FBITS	   =  $BE56    ;found bits
	VTYPE	   =  $BE6A    ;Type param (used for mode)
	VPATH1	   =  $BE6C    ;Address of filename buffer.
	XRETURN    =  $BE9E    ;Known RTS instruction.
	
 ;; * FIRST SAVE THE EXTERNAL COMMAND ADDRESS SO YOU WON'T 
 ;; * DISCONNECT ANY PREVIOUSLY CONNECTED COMMAND.
 ;; *

        LDA  EXTRNCMD+1
        STA  NXTCMD
        LDA  EXTRNCMD+2
        STA  NXTCMD+1
	;; 
        LDA  #<NOPEN      ;Install the address of our
        STA  EXTRNCMD+1   ; command handler in the
        LDA  #>NOPEN      ; external command JMP
        STA  EXTRNCMD+2  ; vector.
        RTS
	;; 
NOPEN:	LDX  #0          ;Check for our command.
NXTCHR:	LDA  INBUF,X     ;Get first character.
        CMP  CMD,X       ;Does it match?
        BNE  NOTOURS     ;No, back to CI.
        INX              ;Next character
        CPX  #CMDLEN     ;All characters yet?
        BNE  NXTCHR      ;No, read next one.
	;; 
        LDA  #CMDLEN-1   ;Our cmd! Put cmd length-1
        STA  XLEN        ; in CI global XLEN.
        LDA  #<NOPEN1   ;
        STA  XTRNADDR   ;
        LDA  #>NOPEN1   ; 
	;;
	STA  XTRNADDR+1  ; our command.
        LDA  #0          ;Mark the cmd number as
        STA  XCNUM       ; zero (external).
        STA  PBITS+1     ; to be parsed.
	LDA  #$25
	STA  PBITS		; Try parsing filename
	;;
	CLC
	RTS
	
NOTOURS:
	SEC              ; ALWAYS SET CARRY IF NOT YOUR
        JMP  (NXTCMD)    ; CMD AND LET NEXT COMMAND TRY
			 ; TO CLAIM IT.
CMD:
	.byte 'N'|$80,'O'|$80,'P'|$80,'E'|$80,'N'|$80
	
 CMDLEN =  *-CMD       ; Our command length
	;; 

NXTCMD:
	.word   0           ; STORE THE NEXT EXT CMD'S
				; ADDRESS HERE.

NOPEN1: 
	LDX	#$00
	LDA	#$00
:	STA	$0200,X
	INX
	BNE	:-
	LDA	FBITS
	AND	#$01		; Check for filename
	BNE	NOPEN2
	LDA	#$10		; SYNTAX ERROR
	SEC			; Error, if no filename.
	RTS
	;;
NOPEN2:	LDA	VPATH1
	STA	$FA
	LDA	VPATH1+1
	STA	$FB
	LDY	#$00		; Offset 0 - String length
	STY	$0201
	STY	$0203		; No translation.
	LDA	($FA),Y		; Get length
	TAX
	STA	$FC		; Store it.
	INX			; Command includes mode and translation bytes.
	INX			;
	STX	$0200		; Store it in length low.
	LDA	FBITS
	AND	#$04		; Check for type (open mode)
	BNE	NOPEN3
	LDA	#$0C		; Not specified, default is $0C (12)
	STA	VTYPE		;
NOPEN3:	LDA	VTYPE		; Get desired mode
	STA	$0202		; And store in buffer
	
NOPEN4:	INY			; Offset 1 - first char
	LDA	($FA),Y		; Next char
	STA	$0203,Y		; Copy it
	CPY	$FC		; At end?
	BNE	NOPEN4		; Nope, continue.
	JSR	$C50D
	.BYTE	$04
	.WORD	CTRLOP
	BCC	NOPEN5
	LDA	#$02
NOPEN5:	RTS
	
CTRLOP:
	.byte $03		; CONTROL has 3 params
	.byte $07		; Hard coded to dev 7 for now.
	.byte $00
	.byte $02
	.byte 'O'		; OPEN
