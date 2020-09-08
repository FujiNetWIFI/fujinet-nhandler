	;; N: Device Handler
	;; Compile with MADS

	;; Author: Thomas Cherryhomes
	;;   <thom.cherryhomes@gmail.com>
	;; CURRENT IOCB IN ZERO PAGE

	;; Optimizations being done by djaybee!
	;; Thank you so much!
	
ZIOCB   =     $20      ; ZP IOCB
ZICHID  =     ZIOCB    ; ID
ZICDNO  =     ZIOCB+1  ; UNIT #
ZICCOM  =     ZIOCB+2  ; COMMAND
ZICSTA  =     ZIOCB+3  ; STATUS
ZICBAL  =     ZIOCB+4  ; BUF ADR LOW
ZICBAH  =     ZIOCB+5  ; BUF ADR HIGH
ZICPTL  =     ZIOCB+6  ; PUT ADDR L
ZICPTH  =     ZIOCB+7  ; PUT ADDR H
ZICBLL  =     ZIOCB+8  ; BUF LEN LOW
ZICBLH  =     ZIOCB+9  ; BUF LEN HIGH
ZICAX1  =     ZIOCB+10 ; AUX 1
ZICAX2  =     ZIOCB+11 ; AUX 2
ZICAX3  =     ZIOCB+12 ; AUX 3
ZICAX4  =     ZIOCB+13 ; AUX 4
ZICAX5  =     ZIOCB+14 ; AUX 5
ZICAX6  =     ZIOCB+15 ; AUX 6

DOSINI  =     $0C      ; DOSINI

	;; Pointers used by relocator.
ptr1	=	$80
ptr2	=	$82
ptr3	=	$84	
	
       ; INTERRUPT VECTORS
       ; AND OTHER PAGE 2 VARS

VPRCED  =     $0202   ; PROCEED VCTR
COLOR2  =     $02C6   ; MODEF BKG C
MEMLO   =     $02E7   ; MEM LO
DVSTAT  =     $02EA   ; 4 BYTE STATS

       ; PAGE 3
       ; DEVICE CONTROL BLOCK (DCB)

DCB     =     $0300   ; BASE
DDEVIC  =     DCB     ; DEVICE #
DUNIT   =     DCB+1   ; UNIT #
DCOMND  =     DCB+2   ; COMMAND
DSTATS  =     DCB+3   ; STATUS/DIR
DBUFL   =     DCB+4   ; BUF ADR L
DBUFH   =     DCB+5   ; BUF ADR H
DTIMLO  =     DCB+6   ; TIMEOUT (S)
DRSVD   =     DCB+7   ; NOT USED
DBYTL   =     DCB+8   ; BUF LEN L
DBYTH   =     DCB+9   ; BUF LEN H
DAUXL   =     DCB+10  ; AUX BYTE L
DAUXH   =     DCB+11  ; AUX BYTE H

HATABS  =     $031A   ; HANDLER TBL

       ; IOCB'S * 8

IOCB    =     $0340   ; IOCB BASE
ICHID   =     IOCB    ; ID
ICDNO   =     IOCB+1  ; UNIT #
ICCOM   =     IOCB+2  ; COMMAND
ICSTA   =     IOCB+3  ; STATUS
ICBAL   =     IOCB+4  ; BUF ADR LOW
ICBAH   =     IOCB+5  ; BUF ADR HIGH
ICPTL   =     IOCB+6  ; PUT ADDR L
ICPTH   =     IOCB+7  ; PUT ADDR H
ICBLL   =     IOCB+8  ; BUF LEN LOW
ICBLH   =     IOCB+9  ; BUF LEN HIGH
ICAX1   =     IOCB+10 ; AUX 1
ICAX2   =     IOCB+11 ; AUX 2
ICAX3   =     IOCB+12 ; AUX 3
ICAX4   =     IOCB+13 ; AUX 4
ICAX5   =     IOCB+14 ; AUX 5
ICAX6   =     IOCB+15 ; AUX 6

       ; HARDWARE REGISTERS

PACTL   =     $D302   ; PIA CTRL A

       ; OS ROM VECTORS

CIOV    =     $E456   ; CIO ENTRY
SIOV    =     $E459   ; SIO ENTRY

       ; CONSTANTS

PUTREC  =     $09     ; CIO PUTREC
DEVIDN  =     $71     ; SIO DEVID
DSREAD  =     $40     ; FUJI->ATARI
DSWRIT  =     $80     ; ATARI->FUJI
MAXDEV  =     4       ; # OF N: DEVS
EOF     =     $88     ; ERROR 136
EOL     =     $9B     ; EOL CHAR

ldax .macro	" "	; load a,x pair
	.if :1 = '#'
		lda #< :2
		ldx #> :2
	.else
		lda :2
		ldx :2+1
	.endif
	.endm

	org	$1300		
	;; org	$1F00
	
	rts
	
DRIVERSTART:
	LDA	#<DRIVEREND
	STA	resetHandler.driverEndLo
	STA	MEMLO
	LDA	#>DRIVEREND
	STA	resetHandler.driverEndHi
	STA	MEMLO+1
	LDA	DOSINI
	STA	resetHandler.initVector
	LDA	DOSINI+1
	STA	resetHandler.initVector+1
	JMP	IHTBS
	
.proc resetHandler
	jsr $FFFF
initVector = *-2
	lda #$ff
driverEndLo = *-1
	sta MEMLO
	lda #$ff
driverEndHi = *-1
	sta MEMLO+1
	JSR IHTBS		; Insert into HATABS
	rts
.endp
	
CIOHNDPTR:
	.word CIOHND

PRCVECPTR:
	.word PRCVEC
	
	;; Insert entry into HATABS
	
IHTBS:
	LDY	#$00
IH1	LDA	HATABS,Y
	BEQ	HFND
	CMP	#'N'
	BEQ	HFND
	INY
	INY
	INY
	CPY	#11*3
	BCC	IH1

	;; Found a slot

HFND:
	LDA	#'N'
	STA	HATABS,Y
	LDA	CIOHNDPTR
	STA	HATABS+1,Y
	LDA	CIOHNDPTR+1
	STA	HATABS+2,Y

	;; And we're done with HATABS	
	;; Vector in proceed interrupt

SPRCED:
	LDA	PRCVECPTR
	STA	VPRCED
	LDA	PRCVECPTR+1
	STA	VPRCED+1

	;; Go ahead and call close on all four IOCBs
	LDA	#$04
	STA	CLODCB+1
	JSR 	CLOSE2
	LDA	#$03
	STA	CLODCB+1
	JSR 	CLOSE2
	LDA	#$02
	STA	CLODCB+1
	JSR 	CLOSE2
	LDA	#$01
	STA	CLODCB+1
	JSR 	CLOSE2
	
	;; And we are done, back to DOS.
	
	RTS

;;; End Initialization Code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DOSIOV:
	STA	DODCBL+1
	STY	DODCBL+2
	LDY	#$0C
DODCBL	LDA	$FFFF,Y
	STA	DCB,Y
	DEY
	BPL	DODCBL

SIOVDST:	
	JSR	SIOV
	LDY	DSTATS
	TYA
	RTS

;;; CIO OPEN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OPNDCBPTR:
	.word	OPNDCB

OPEN:
	;; Prepare DCB
	JSR	GDIDX		; Get Device ID in X (0-3)
	LDA	ZICDNO		; IOCB UNIT # (1-4)
	STA	OPNDCB+1	; Store in DUNIT
	LDA	ZICBAL		; Get filename buffer
	STA	OPNDCB+4	; stuff in DBUF
	LDA	ZICBAH		; ...
	STA	OPNDCB+5	; ...
	LDA	ZICAX1		; Get desired AUX1/AUX2
	STA	OPNDCB+10	; Save them, and store in DAUX1/DAUX2
	LDA	ZICAX2		; ...
	STA	OPNDCB+11	; ...

	;;  Copy DCB template to DCB
	LDA	OPNDCBPTR
	LDY	OPNDCBPTR+1

	;;  Send to #FujiNet
	JSR	DOSIOV
                                    
	;; Return DSTATS, unless 144, then get extended error
	
OPCERR:
	CPY	#$90		; ERR 144?
	BNE	OPDONE		; NOPE. RETURN DSTATS
       
	;; 144 - get extended error
	JSR	STPOLL  	; POLL FOR STATUS
	LDY	DVSTAT+3

       ; RESET BUFFER LENGTH + OFFSET
       
OPDONE:
	JSR     GDIDX
	LDA     #$00
	STA     RLEN,X
	STA     TOFF,X
	STA     ROFF,X
	STA	DVS2,X
	STA	DVS3,X
	TYA
	RTS             ; AY = ERROR

OPNDCB:
	.BYTE      DEVIDN  ; DDEVIC
	.BYTE      $FF     ; DUNIT
	.BYTE      'O'     ; DCOMND
	.BYTE      $80     ; DSTATS
	.BYTE      $FF     ; DBUFL
	.BYTE      $FF     ; DBUFH
	.BYTE      $1F     ; DTIMLO
	.BYTE      $00     ; DRESVD
	.BYTE      $00     ; DBYTL
	.BYTE      $01     ; DBYTH
	.BYTE      $FF     ; DAUX1
	.BYTE      $FF     ; DAUX2
	
;;; End CIO OPEN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CIO CLOSE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CLODCBPTR:
	.word	CLODCB

CLOSE:
	LDA	#$00
	STA	TRIP		; Clear trip flag.
	STA	DVS2,X
	STA	DVS3,X
	JSR     DIPRCD		; Disable Interrupts
	JSR	GDIDX
	JSR	PFLUSH		; Do a Put Flush if needed.

	LDA     ZICDNO		; IOCB Unit #
	STA     CLODCB+1	; to DCB...

CLOSE2:	LDA	CLODCBPTR
	LDY	CLODCBPTR+1
	JMP	DOSIOV

CLODCB .BYTE	DEVIDN		; DDEVIC
       .BYTE	$FF		; DUNIT
       .BYTE	'C'		; DCOMND
       .BYTE	$00		; DSTATS
       .BYTE	$00		; DBUFL
       .BYTE	$00		; DBUFH
       .BYTE	$1F		; DTIMLO
       .BYTE	$00		; DRESVD
       .BYTE	$00		; DBYTL
       .BYTE	$00		; DBYTH
       .BYTE	$00		; DAUX1
       .BYTE	$00		; DAUX2
	
;;; End CIO CLOSE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CIO GET ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GETDCBPTR:
	.word GETDCB
	
GET:
	JSR	GDIDX		; IOCB UNIT #-1 into X
	LDA	RLEN,X		; Get RX len
	BNE	GETDRAIN	; Continue draining if > 0

	;; Nothing in, Try to fill the buffer

GETWAIT:
	JSR	ENPRCD
	LDA	TRIP		; Something waiting?
	BEQ	GETWAIT		; Nope, spin until something happens.

	;; Something happened, try to fill buffer.

GETFILL:
	JSR	STPOLL		; Do STATUS
	LDA	DVSTAT+3	; Get Error code
	BMI	GETER2		; If disconnected return error code.
	JSR	GDIDX		; Set IOCB-1
	LDA	ZICDNO		; Get IOCB UNIT #
	STA	GETDCB+1	; Store in DUNIT
	LDA	DVSTAT		; Get # of bytes from STATUS
	STA	RLEN,X		; Store into RX cursor
	STA	GETDCB+8	; Store into DBYT
	STA	GETDCB+10	; Store into DAUX1
	LDA	GETDCBPTR	; Set up pointer to Get DCB
	LDY	GETDCBPTR+1
	JSR	DOSIOV		; And do it.

	;; Check if SIO call succeeded, and if so, jump to reset pointers.
	
	LDA	DSTATS		; Get result of SIO call
	CMP	#$01		; Successful?
	BEQ	GETRESET	; Reset pointers if so.

GETERR:	JSR	STPOLL		; Do a status poll
GETER2:	LDY	DVSTAT+3	; Get Error code
	RTS			; And leave.

GETRESET:
	JSR	GDIDX		; IOCB UNIT #-1 into X
	LDA	#$00
	STA	ROFF,X		; Reset RX cursor
	
	;; Drain the Buffer
	
GETDRAIN:
	JSR	DIPRCD		; Disable PROCEED
	DEC	RLEN,X		; Decrement RX len
	LDY	ROFF,X		; Get RX offset cursor.
	LDA	RBUF,Y		; Get next character
	INC	ROFF,X		; Increment RX offset cursor.
	TAY			; Stuff in Y for a moment

	;; If RX buffer is now empty, turn off TRIP
	LDA	RLEN,X
	BNE	GETDONE
	STA	TRIP

GETDONE:
	TYA			; Move returned value back.
	LDY	#$01		; SUCCESS
	RTS
	
GETDCB .BYTE     DEVIDN  ; DDEVIC
       .BYTE     $FF     ; DUNIT
       .BYTE     'R'     ; DCOMND
       .BYTE     $40     ; DSTATS
       .WORD	 RBUF	 ; DBUF
       .BYTE     $1F     ; DTIMLO
       .BYTE     $00     ; DRESVD
       .BYTE     $FF     ; DBYTL
       .BYTE     $00     ; DBYTH
       .BYTE     $FF     ; DAUX1
       .BYTE     $00     ; DAUX2
	
;;; End CIO GET ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CIO PUT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUTDCBPTR:
	.word	PUTDCB

PUT:
	;; Add to TX buffer.

	JSR	GDIDX
	LDY	TOFF,X  ; GET TX cursor.
	STA	TBUF,Y		; TX Buffer

POFF:	INC	TOFF,X		; Increment TX cursor
	LDY	#$01		; SUCCESSFUL

	;; Do a PUT FLUSH if EOL or buffer full.

	CMP     #EOL    ; EOL?
	BEQ     FLUSH  ; FLUSH BUFFER
	JSR     GDIDX   ; GET OFFSET
	LDA     TOFF,X
        CMP     #$7F    ; LEN = $FF?
        BEQ     FLUSH  ; FLUSH BUFFER
        RTS

       ; FLUSH BUFFER, IF ASKED.

FLUSH  JSR     PFLUSH  ; FLUSH BUFFER
       RTS

PFLUSH:	

       ; CHECK CONNECTION, AND EOF
       ; IF DISCONNECTED.

       JSR     STPOLL  ; GET STATUS
PF1:   JSR     GDIDX   ; GET DEV X
       LDA     TOFF,X
       BNE     PF2
       JMP     PDONE

       ; FILL OUT DCB FOR PUT FLUSH

PF2:   LDA     ZICDNO
       STA     PUTDCB+1
	
       ; FINISH DCB AND DO SIOV

TBX:	LDA     TOFF,X
	STA     PUTDCB+8
	STA     PUTDCB+10

	LDA	PUTDCBPTR
	LDY	PUTDCBPTR+1
	JSR     DOSIOV
       
       ; CLEAR THE OFFSET CURSOR
       ; AND LENGTH

       JSR     GDIDX
       LDA     #$00
       STA     TOFF,X

PDONE:	LDY     #$01
       RTS

PUTDCB .BYTE      DEVIDN  ; DDEVIC
       .BYTE      $FF     ; DUNIT
       .BYTE      'W'     ; DCOMND
       .BYTE      $80     ; DSTATS
       .WORD      TBUF   ; DBUFH
       .BYTE      $1F     ; DTIMLO
       .BYTE      $00     ; DRESVD
       .BYTE      $FF     ; DBYTL
       .BYTE      $00     ; DBYTH
       .BYTE      $FF     ; DAUX1
       .BYTE      $00     ; DAUX2
	
;;; End CIO PUT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;;; CIO STATUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

STADCBPTR:
	.word	STADCB

STATUS:
	JSR	ENPRCD		; Let's turn on interrupts in case.
	
	;; Return cached value if we still have data in RX
	
	JSR	GDIDX		; Get Device ID
	LDA	RLEN,X		; Get RX len
	BNE	STRETC		; Drain buffer if != 0

	;; Only do a poll _IF_ we have an interrupt.

	LDA	TRIP		; Get interrupt flag
	BEQ	STRETC		; No interrupt? Return cached.

	;; Do Poll

	JSR	STPOLL		; Do status poll
	LDA	DVSTAT+3	; Get Error code
	TAY			; Move into (Y) error register
	RTS
	
STRETC:
	STA	DVSTAT	 ; Return RX len
	LDA	#$00
	STA	DVSTAT+1	; no more than 127 bytes.
	LDA	DVS2,X	 ; Get cached DVSTAT+2
	STA	DVSTAT+2 ; Return it
	LDA	DVS3,X	 ; Get cached DVSTAT+3
	STA	DVSTAT+3 ; Return it.
	TAY		 ; Return error code in Y too
	STY	$02C8
	RTS		 ; Exit

	;; Poll for status ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

STPOLL:
	JSR	GDIDX		; Get IOCB-1
	LDA	ZICDNO		; Get unit #
	STA	STADCB+1	; Store into DUNIT
	LDA	STADCBPTR	; Set up DCB Pointer L
	LDY	STADCBPTR+1	; Set up DCB Pointer H
	JSR	DOSIOV		; Do SIO Call
	
	JSR	DIPRCD		; Mask interrupt.
	LDA	#$00		; Reset trip...
	STA	TRIP		; ...because we've serviced it.

	;; Adjust RX len if greater than 127 bytes

	LDA	DVSTAT+1	; > 255 bytes?
	BNE	STPADJ		; Yes, adjust.
	LDA	DVSTAT		; > 127 bytes?
	BMI	STPADJ		; Yes, adjust.
	JMP	STPDON		; Done with poll.

STPADJ:	LDA	#$7F		; Set RX len to 127 bytes
	STA	DVSTAT		;
	LDA	#$00		;
	STA	DVSTAT+1	;

STPDON:	LDA	DVSTAT		; Get new RX Len
	STA	RLEN,X		; Store.
	LDA	DVSTAT+2	; Get Connection status
	STA	DVS2,X		; Store.
	LDA	DVSTAT+3	; Get Error code
	STA	DVS3,X		; Store.
	TAY			; And return in error code
	RTS

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
STADCB .BYTE      DEVIDN  ; DDEVIC
       .BYTE      $FF     ; DUNIT
       .BYTE      'S'     ; DCOMND
       .BYTE      $40     ; DSTATS
       .BYTE      $EA     ; DBUFL
       .BYTE      $02     ; DBUFH
       .BYTE      $1F     ; DTIMLO
       .BYTE      $00     ; DRESVD
       .BYTE      $04     ; DBYTL
       .BYTE      $00     ; DBYTH
       .BYTE      $00     ; DAUX1
       .BYTE      $00     ; DAUX2
	
;;; End CIO STATUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CIO SPECIAL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPEDCBPTR:
	.word SPEDCB

SPEC:
	;; Clear trip
	LDA	#$00
	STA	TRIP
	
       ; HANDLE LOCAL COMMANDS.

       LDA     ZICCOM
       CMP     #$0F    ; 15 = FLUSH
       BNE     S1      ; NO.
       JSR     PFLUSH  ; DO FLUSH
       LDY     #$01    ; SUCCESS
       RTS

       ; HANDLE SIO COMMANDS.
       ; GET DSTATS FOR COMMAND

S1:	LDA	ZICDNO
	STA	SPEDCB+1
	LDA	ZICCOM
	STA	SPEDCB+10

	LDA	SPEDCBPTR
	LDY	SPEDCBPTR+1
	JSR	DOSIOV

	BMI	:DSERR

	; WE GOT A DSTATS INQUIRY
       ; IF $FF, THE COMMAND IS
       ; INVALID

DSOK:
	LDA     INQDS
       CMP     #$FF    ; INVALID?
       BNE     DSGO   ; DO THE CMD
       LDY     #$92    ; UNIMP CMD
       TYA
DSERR:
       RTS

	;; Do the special, since we want to pass in all the IOCB
	;; Parameters to the DCB, This is being done long-hand.
	
DSGO:	LDA	ZICCOM
	PHA
	LDA	#$00
	PHA
	LDA	INQDS
	PHA
	LDA	#$01
	PHA
	LDA	ZICBAL
	PHA
	LDA	ZICAX1
	PHA
	LDA	ZICBAH
	PHA
	LDA	ZICAX2
	PHA
	LDY	#$03
DSGOL:
	PLA
	STA	DBYTL,Y
	PLA
	STA	DCOMND,Y
	DEY
	BPL DSGOL

	JMP	SIOVDST

	;; Return DSTATS in Y and A

SPEDCB .BYTE      DEVIDN  ; DDEVIC
       .BYTE      $FF     ; DUNIT
       .BYTE      $FF     ; DCOMND ; inq
       .BYTE      $40     ; DSTATS
       .WORD      INQDS    ; DBUFL
       .BYTE      $1F     ; DTIMLO
       .BYTE      $00     ; DRESVD
       .BYTE      $01     ; DBYTL
       .BYTE      $00     ; DBYTH
       .BYTE      $FF     ; DAUX1
       .BYTE      $FF     ; DAUX2	
	
;;; End CIO SPECIAL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Utility Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

       ; ENABLE PROCEED INTERRUPT

ENPRCD:
	LDA     PACTL
       ORA     #$01    ; ENABLE BIT 0
       STA     PACTL
       RTS

       ; DISABLE PROCEED INTERRUPT

DIPRCD:
	LDA     PACTL
       AND     #$FE    ; DISABLE BIT0
       STA     PACTL
       RTS

       ; GET ZIOCB DEVNO - 1 INTO X
       
GDIDX:	
       LDX     ZICDNO  ; IOCB UNIT #
       DEX             ; - 1
       RTS

;;; End Utility Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Proceed Vector ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PRCVEC	
	LDA     #$01
	STA     TRIP
       PLA
       RTI
	
;;; End Proceed Vector ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Variables

       ; DEVHDL TABLE FOR N:
CIOHND
	.WORD      OPEN-1
	.WORD      CLOSE-1
	.WORD      GET-1
	.WORD      PUT-1
	.WORD      STATUS-1
       .WORD      SPEC-1

       ; VARIABLES

DIFF	.DS	2	
TRIP   .BYTE      0       ; INTR FLAG
RLEN   .DS      MAXDEV  ; RCV LEN
ROFF   .DS      MAXDEV  ; RCV OFFSET
TOFF   .DS      MAXDEV  ; TRX OFFSET
INQDS  .DS      1       ; DSTATS INQ
DVS2   .BYTE      0,0,0,0	; DVSTAT+2 SAVE
DVS3   .BYTE 	  0,0,0,0	; DVSTAT+3 SAVE

RBUF	.DS	128
TBUF	.DS	128	
	
DRIVEREND	= *
	
	RUN	DRIVERSTART
	END

