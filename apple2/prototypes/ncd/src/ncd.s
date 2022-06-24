;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;
;;; ;; NCD implementation
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
        LDA  #<NCD      ;Install the address of our
        STA  EXTRNCMD+1   ; command handler in the
        LDA  #>NCD      ; external command JMP
        STA  EXTRNCMD+2  ; vector.
        RTS
	;; 
NCD:	LDX  #0          ;Check for our command.
NXTCHR:	LDA  INBUF,X     ;Get first character.
        CMP  CMD,X       ;Does it match?
        BNE  NOTOURS     ;No, back to CI.
        INX              ;Next character
        CPX  #CMDLEN     ;All characters yet?
        BNE  NXTCHR      ;No, read next one.
	;; 
        LDA  #CMDLEN-1   ;Our cmd! Put cmd length-1
        STA  XLEN        ; in CI global XLEN.
        LDA  #<NCD1   ;
        STA  XTRNADDR   ;
        LDA  #>NCD1   ; 
	;;
	STA  XTRNADDR+1  ; our command.
        LDA  #0          ;Mark the cmd number as
        STA  XCNUM       ; zero (external).
        STA  PBITS+1     ; to be parsed.
	LDA  #$01
	STA  PBITS		; Try parsing filename
	;;
	CLC
	RTS
	
NOTOURS:
	SEC              ; ALWAYS SET CARRY IF NOT YOUR
        JMP  (NXTCMD)    ; CMD AND LET NEXT COMMAND TRY
			 ; TO CLAIM IT.
CMD:
	.byte 'N'|$80,'C'|$80,'D'|$80
	
 CMDLEN =  *-CMD       ; Our command length
	;; 

NXTCMD:
	.word   0           ; STORE THE NEXT EXT CMD'S
				; ADDRESS HERE.

NCD1: 
	LDX	#$00
	LDA	#$00
:	STA	$0200,X
	INX
	BNE	:-
	LDA	FBITS
	AND	#$01		; Check for filename
	BNE	NCD2
	LDA	#$01		; zero out len
	STA	$0200
	BCC	NCD35		; Send out empty payload to reset ncd
	;;
NCD2:	LDA	VPATH1
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
NCD3:   INY				
	LDA	($FA),Y		; Next char
	STA	$0201,Y		; Copy it
	CPY	$FC		; At end?
	BNE	NCD3		; Nope, continue.
NCD35:	JSR	$C50D
	.BYTE	$04
	.WORD	CTRLOP
	BCC	NCD4
	LDA	#$02
NCD4:	RTS
	
CTRLOP:
	.byte $03		; CONTROL has 3 params
	.byte $07		; Hard coded to dev 7 for now.
	.byte $00
	.byte $02
	.byte ','		; NCD
