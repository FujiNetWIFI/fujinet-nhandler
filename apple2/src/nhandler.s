;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;
;;; ;; #FujiNet N: handler for ProDOS
;;; ;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "CODE"
	
	INBUF      =  $200     ;GETLN input buffer.
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
        LDA  #>BEEP      ;Install the address of our
        STA  EXTRNCMD+1  ; command handler in the
        LDA  #<BEEP      ; external command JMP
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
        LDA  #>XRETURN   ;Point XTRNADDR to a known
        STA  XTRNADDR    ; RTS since we'll handle
        LDA  #<XRETURN   ; at the time we intercept
	;;
	STA  XTRNADDR+1  ; our command.
        LDA  #0          ;Mark the cmd number as
        STA  XCNUM       ; zero (external).
        STA  PBITS       ;And indicate no parameters
        STA  PBITS+1     ; to be parsed.
	;; 
        LDX  #5          ;Number of desired beeps.
NXTBEEP:
	JSR  BELL        ;Else, beep once.
	LDA  #$80        ;Set up the delay
        JSR  WAIT        ; and wait.
        DEX              ;Decrement index and
        BNE  NXTBEEP     ; repeat until X = 0.
	;; 
        CLC              ;All done successfully.
        RTS              ; RETURN WITH THE CARRY CLEAR.
 
NOTOURS:
	SEC              ; ALWAYS SET CARRY IF NOT YOUR
        JMP  (NXTCMD)    ; CMD AND LET NEXT COMMAND TRY
			 ; TO CLAIM IT.
CMD:
	.byte  "BEEP"   	; Our command
 CMDLEN =  *-CMD       ; Our command length
	;; 

NXTCMD:
	.word   0           ; STORE THE NEXT EXT CMD'S
				; ADDRESS HERE.
	
