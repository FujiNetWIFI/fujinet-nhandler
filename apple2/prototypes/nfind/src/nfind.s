;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ;;
;;; ;; Find first network device, return in A.
;;; ;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.segment "CODE"

	INBUF		= $0200
	SPDISPATCH	= $C50D
	
	;; Get # of SmartPort devices
	JSR	SPDISPATCH
	.BYTE	$00		; Status
	.WORD	CLSNM		; Get global status into $0200
	;; 
	LDX	INBUF		; # of devices
	INX
	INX
	STX	$FA
NFSCAN:	LDA	$FA
	STA	CLSDB+1		; Store current in it
	JSR	SPDISPATCH
	.BYTE	$00
	.WORD	CLSDB
	LDY	#$05		; 5 = start of ID string
	LDA	INBUF,Y
	CMP	#'N'
	BNE	NXTDEV
	INY
	LDA	INBUF,Y
	CMP	#'E'
	BNE	NXTDEV
	INY
	LDA	INBUF,Y
	CMP	#'T'
	BNE	NXTDEV
	LDA	#$00
	CLC
	LDA	$FA		; A = Found Network Device
	RTS
	;; 
NXTDEV:	DEC	$FA
	LDA	$FA
	BNE	NFSCAN
	SEC
	RTS

CLSNM:	.BYTE	$03		; 3 Parameters
	.BYTE	$00		; Destination (0 = HOST)
	.BYTE	$00		; put payload in $0200
	.BYTE	$02		;
	.BYTE	$00		; Status code 0 = (Smartport global status)

CLSDB:	.BYTE	$03		; 3 parameters
	.BYTE	$00		; Destination (changes in loop
	.BYTE	$00		; put payload in $0200
	.BYTE	$02		;
	.BYTE	$03		; Status code 3 = (DIB)
