;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;
;;; ;; Find smartport dispatcher.
;;; ;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "CODE"
		
SFINI:	LDA	#$00		; Initialize FA/FB to be used for ($FA),Y 
	STA	$FA		;
	LDA	#$C7		; Starting at $C700
	STA	$FB		;
	;;
SFSCN:	LDY	#$01		; $Cx00+1
	LDA	($FA),Y		;
	CMP	#$20		; Check for $20
	BNE	SFNXT		; Nope, next slot.
	INY			; +2
	INY			;
	LDA	($FA),Y		; $Cx00+3
	CMP	#$00		; Check for $00
	BNE	SFNXT		; Nope, next slot.
	INY			; +2
	INY			;
	LDA	($FA),Y		; $Cx00+5
	CMP	#$03		; Check for $03
	BNE	SFNXT		; Nope, next slot.
	INY			; +2
	INY			; 
	LDA	($FA),Y		; $Cx00+7
	CMP	#$00		; Check for $00
	BNE	SFNXT		; Nope, next slot.
	;; Found
	LDY	#$FF		; $Cx00+$FF
	LDA	($FA),Y		; Grab dispatch table offset
	CLC
	ADC	#$03		; +3 to get SmartPort Dispatch
	STA	$FA		; Store in $FA
	LDA	$FB		; A = MSB
	LDX	$FA		; X = LSB
	CLC			; Clear carry to indicate success
	RTS			; Back to caller.
	;;
SFNXT:	LDA	$FB		; Get MSB
	CMP	$C1		; Check if Already at slot 1.
	BEQ	SFBYE		; Yes, go back to caller.
	DEC	$FB		; Decrement MSB
	BCC	SFSCN		; And continue scan.
SFBYE:	SEC			; Set carry to indicate error.
	RTS			; and go back to caller.
	
	
