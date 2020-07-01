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

	org	$3000
	
.proc	Start
GotHardware
	lda #<DRIVERSTART
	sec
	sbc MEMLO
	sta Diff
	lda #>DRIVERSTART
	sbc MEMLO+1
	sta Diff+1
	
	ldx #.len[RelocTable]-2
Loop1
	lda RelocTable,x
	sta ptr1
	lda RelocTable+1,x
	sta ptr1+1
	
	ldy #0
	lda (ptr1),y
	sec
	sbc Diff
	sta (ptr1),y
	iny
	lda (ptr1),y
	sbc Diff+1
	sta (ptr1),y
	
	cpx #0
	beq Move
	dex
	dex
	jmp Loop1

Move
	mwa DOSINI resetHandler.initVector
	
	lda MEMLO
	sta ptr2
	sta DOSINI
	clc
	adc #<[DRIVEREND-DRIVERSTART]
	sta MEMLO
	sta resetHandler.driverEndLo
	
	lda MEMLO+1
	sta ptr2+1
	sta DOSINI+1
	adc #>[DRIVEREND-DRIVERSTART]
	sta MEMLO+1
	sta resetHandler.driverEndHi
	
	ldy #0	; move driver code to bottom of free RAM
	mwa #DRIVERSTART ptr1
	mva #<[DRIVEREND-DRIVERSTART] ptr3
	mvx #>[DRIVEREND-DRIVERSTART] ptr3+1
	beq @+
Loop2
	lda (ptr1),y
	sta (ptr2),y
	iny
	bne Loop2
	inc ptr1+1
	inc ptr2+1
	dex
	bne Loop2
@
	ldx ptr3	; lsb of size
	beq Done
Loop3
	lda (ptr1),y
	sta (ptr2),y
	iny
	dex
	bne Loop3
Done

Setup
	jsr IHTBS
Finish
	rts
.endp

.local RelocTable
	.word w7+1,w8,w9,w10
	.word w11,w12+1,w13+1,w14+1,w15+1,w16+1,w17+1,w18+1,w19+1,w20+1
	.word w21+1,w22+1,w23,w24+1,w25+1,w26+1,w27+1,w28+1,w29+1,w30+1
	.word w31+1,w32+1,w33+1,w34+1,w35+1,w36+1,w37+1,w38+1,w39,w40+1
	.word w41+1,w42+1,w43+1,w44+1,w45+1,w46+1,w47,w48+1,w49+1,w50+1
	.word w51+1,w52+1,w53+1,w54+1,w55+1,w56+1,w57+1,w58+1,w59+1,w60+1
	.word w61+1,w62+1,w63+1,w64+1,w65+1,w66+1,w67,w68+1,w69+1,w70+1
	.word w71+1,w72+1,w73+1,w74+1,w75+1,w76+1,w77+1,w78+1,w79+1,w80+1
	.word w81+1,w82+1,w83+1,w84+1,w85+1,w86+1,w87+1,w88,w89+1,w90+1
	.word w91+1,w92+1,w93+1,w94+1,w95+1,w96+1,w97+1,w98+1,w99+1,w100+1
	.word w101,w102+1,w103+1,w104+1,w105+1,w106+1,w107+1,w108+1,w109,w110
	.word w111,w112,w113,w114
.endl
	
DRIVERSTART:	
	
.proc resetHandler
	jsr $FFFF
initVector = *-2
	lda #$ff
driverEndLo = *-1
	sta MEMLO
	lda #$ff
driverEndHi = *-1
	sta MEMLO+1
.def	:w7
	JSR IHTBS		; Insert into HATABS
	rts
.endp
	
CIOHNDPTR:
.def	:w8
	.word CIOHND

BERRORPTR:
.def	:w9
	.word BERROR

BREADYPTR:
.def	:w10
	.word BERROR

PRCVECPTR:
.def	:w11
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
.def	:w12
	LDA	CIOHNDPTR
	STA	HATABS+1,Y
.def	:w13
	LDA	CIOHNDPTR+1
	STA	HATABS+2,Y

	;; And we're done with HATABS

	;; Query FUJINET

.def	:w14
	JSR	STPOLL

	;; Output Ready/Error

OBANR:
	LDX	#$00		; IOCB #0
	LDA	#PUTREC
	STA	ICCOM,X
	LDA	#$28		; 40 CHARS Max
	STA	ICBLL,X
	TXA
	STA	ICBLH,X
	LDA	DSTATS		; Check DSTATS
	BPL	OBRDY		; < 128 = Ready

	;; Status returned error.
	
OBERR:
.def	:w15
	LDA	BERRORPTR
.def	:w16
	LDY	BERRORPTR+1
	BVC	OBCIO

	;; Status returned ready.
	
OBRDY:
.def	:w17
	LDA	BREADYPTR
.def	:w18
	LDY	BREADYPTR+1

OBCIO:
	STA	ICBAL,X
	TYA
	STA	ICBAH,X

	JSR	CIOV
	
	;; Vector in proceed interrupt

SPRCED:
.def	:w19
	LDA	PRCVECPTR
	STA	VPRCED
.def	:w20
	LDA	PRCVECPTR+1
	STA	VPRCED+1

	;; And we are done, back to DOS.
	
	RTS

;;; End Initialization Code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DOSIOV:
.def	:w21
	STA	DODCBL+1
.def	:w22
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

.def	:w23
OPNDCBPTR:
	.word	OPNDCB
	
OPEN:
	;; Prepare DCB
.def	:w24
	JSR	GDIDX		; Get Device ID in X (0-3)
	LDA	ZICDNO		; IOCB UNIT # (1-4)
.def	:w25
	STA	OPNDCB+1	; Store in DUNIT
	LDA	ZICBAL		; Get filename buffer
.def	:w26
	STA	OPNDCB+4	; stuff in DBUF
	LDA	ZICBAH		; ...
.def	:w27
	STA	OPNDCB+5	; ...
	LDA	ZICAX1		; Get desired AUX1/AUX2
.def	:w28
	STA	OPNDCB+10	; Save them, and store in DAUX1/DAUX2
	LDA	ZICAX2		; ...
.def	:w29
	STA	OPNDCB+11	; ...

	;;  Copy DCB template to DCB
.def	:w30
	LDA	OPNDCBPTR
.def	:w31
	LDY	OPNDCBPTR+1

	;;  Send to #FujiNet
.def	:w32	
	JSR	DOSIOV
                                    
	;; Return DSTATS, unless 144, then get extended error
	
OPCERR:
	CPY	#$90		; ERR 144?
	BNE	OPDONE		; NOPE. RETURN DSTATS
       
	;; 144 - get extended error
.def	:w33
	JSR	STPOLL  	; POLL FOR STATUS
	LDY	DVSTAT+3

       ; RESET BUFFER LENGTH + OFFSET
       
OPDONE:
	LDA	#$01
.def	:w34
	STA	TRIP
.def	:w35
	JSR     GDIDX
	LDA     #$00
.def	:w36
	STA     RLEN,X
.def	:w37
	STA     TOFF,X
.def	:w38
	STA     ROFF,X
	TYA
	RTS             ; AY = ERROR

OPNDCB:
	.BYTE      DEVIDN  ; DDEVIC
	.BYTE      $FF     ; DUNIT
	.BYTE      'O'     ; DCOMND
	.BYTE      $80     ; DSTATS
	.BYTE      $FF     ; DBUFL
	.BYTE      $FF     ; DBUFH
	.BYTE      $0F     ; DTIMLO
	.BYTE      $00     ; DRESVD
	.BYTE      $00     ; DBYTL
	.BYTE      $01     ; DBYTH
	.BYTE      $FF     ; DAUX1
	.BYTE      $FF     ; DAUX2
	
;;; End CIO OPEN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CIO CLOSE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.def	:w39
CLODCBPTR:
	.word	CLODCB
	
CLOSE:
.def	:w40
	JSR     DIPRCD		; Disable Interrupts
.def	:w41
	JSR	GDIDX
.def	:w42
	JSR	PFLUSH		; Do a Put Flush if needed.

	LDA     ZICDNO		; IOCB Unit #
.def	:w43
	STA     CLODCB+1	; to DCB...

.def	:w44
	LDA	CLODCBPTR
.def	:w45
	LDY	CLODCBPTR+1
.def	:w46
	JMP	DOSIOV

CLODCB .BYTE	DEVIDN		; DDEVIC
       .BYTE	$FF		; DUNIT
       .BYTE	'C'		; DCOMND
       .BYTE	$00		; DSTATS
       .BYTE	$00		; DBUFL
       .BYTE	$00		; DBUFH
       .BYTE	$0F		; DTIMLO
       .BYTE	$00		; DRESVD
       .BYTE	$00		; DBYTL
       .BYTE	$00		; DBYTH
       .BYTE	$00		; DAUX1
       .BYTE	$00		; DAUX2
	
;;; End CIO CLOSE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CIO GET ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.def	:w47
GETDCBPTR:
	.word GETDCB
	
GET:
.def	:w48
	JSR	GDIDX		; IOCB UNIT #-1 into X
.def	:w49
	LDA	RLEN,X		; Get # of RX chars waiting
	BNE     GETDISC		; LEN > 0?

	;; If RX buffer is empty, get # of chars waiting...

.def	:w50
	JSR	STPOLL		; Status Poll
.def	:w51
	JSR	GDIDX		; IOCB UNIT -1 into X (because Poll trashes X)
	LDA	DVSTAT		; # of bytes waiting (0-127)
.def	:w52
	STA	RLEN,X		; Store in RX Len
	BEQ	RETEOF

GETDO:
	LDA	ZICDNO		; Get IOCB UNIT #
.def	:w53
	STA	GETDCB+1	; Store into DUNIT
	LDA	DVSTAT		; # of bytes waiting
.def	:w54
	STA	GETDCB+8	; Store into DBYT...
.def	:w55
	STA	GETDCB+10	; and DAUX1...

.def	:w56
	LDA	GETDCBPTR
.def	:w57
	LDY	GETDCBPTR+1
.def	:w58
	JSR	DOSIOV

	;; Clear the Receive buffer offset.
.def	:w59
	JSR	GDIDX		; IOCB UNIT #-1 into X
	LDA	#$00
.def	:w60
	STA     ROFF,X

GETDISC:
	LDA     DVSTAT+2	; Did we disconnect?
	BNE     GETUPDP		; nope, update the buffer cursor.

	;; We disconnected, emit an EOF.

RETEOF:	
	LDY	#EOF
	TYA
	RTS			; buh-bye.

GETUPDP:
.def	:w61
	DEC     RLEN,X		; Decrement RX length.
.def	:w62
	LDY     ROFF,X		; Get RX offset cursor.

	;; Return Next char from appropriate RX buffer.
.def	:w63	
	LDA	RBUF,Y
	
	;; Increment RX offset
.def	:w64	
GX:	INC	ROFF,X		; Increment RX offset.
	TAY			; stuff returned val into Y temporarily.

	;; If requested RX buffer is empty, reset TRIP.
.def	:w65
	LDA	RLEN,X
	BNE	GETDONE
.def	:w66
	STA     TRIP

	;; Return byte back to CIO.
	
GETDONE:
	TYA			; Move returned val back.
	LDY	#$01		; SUCCESS

	RTS			; DONE...

GETDCB .BYTE     DEVIDN  ; DDEVIC
       .BYTE     $FF     ; DUNIT
       .BYTE     'R'     ; DCOMND
       .BYTE     $40     ; DSTATS
       .BYTE     $00     ; DBUFL
       .BYTE     >RBUF   ; DBUFH
       .BYTE     $0F     ; DTIMLO
       .BYTE     $00     ; DRESVD
       .BYTE     $FF     ; DBYTL
       .BYTE     $00     ; DBYTH
       .BYTE     $FF     ; DAUX1
       .BYTE     $00     ; DAUX2
	
;;; End CIO GET ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CIO PUT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.def	:w67
PUTDCBPTR:
	.word	PUTDCB
	
PUT:
	;; Add to TX buffer.

.def	:w68
	JSR	GDIDX
.def	:w69
	LDY	TOFF,X  ; GET TX cursor.
.def	:w70
	STA	TBUF,Y		; TX Buffer

.def	:w71
POFF:	INC	TOFF,X		; Increment TX cursor
	LDY	#$01		; SUCCESSFUL

	;; Do a PUT FLUSH if EOL or buffer full.

	CMP     #EOL    ; EOL?
	BEQ     FLUSH  ; FLUSH BUFFER
.def	:w72
	JSR     GDIDX   ; GET OFFSET
.def	:w73
	LDA     TOFF,X
        CMP     #$7F    ; LEN = $FF?
        BEQ     FLUSH  ; FLUSH BUFFER
        RTS

       ; FLUSH BUFFER, IF ASKED.

.def	:w74
FLUSH  JSR     PFLUSH  ; FLUSH BUFFER
       RTS

PFLUSH:	

       ; CHECK CONNECTION, AND EOF
       ; IF DISCONNECTED.

.def	:w75
       JSR     STPOLL  ; GET STATUS
       LDA     DVSTAT+2
	BEQ	RETEOF

.def	:w76
PF1:	JSR     GDIDX   ; GET DEV X
.def	:w77
       LDA     TOFF,X
	BNE     PF2
.def	:w78
       JMP     PDONE

       ; FILL OUT DCB FOR PUT FLUSH

PF2:	LDA     ZICDNO
.def	:w79
       STA     PUTDCB+1
	
       ; FINISH DCB AND DO SIOV

.def	:w80
TBX:	LDA     TOFF,X
.def	:w81
	STA     PUTDCB+8
.def	:w82
	STA     PUTDCB+10

.def	:w83
	LDA	PUTDCBPTR
.def	:w84
	LDY	PUTDCBPTR+1
.def	:w85
	JSR     DOSIOV
       
       ; CLEAR THE OFFSET CURSOR
       ; AND LENGTH

.def	:w86
       JSR     GDIDX
	LDA     #$00
.def	:w87
       STA     TOFF,X

PDONE:	LDY     #$01
       RTS

PUTDCB .BYTE      DEVIDN  ; DDEVIC
       .BYTE      $FF     ; DUNIT
       .BYTE      'W'     ; DCOMND
       .BYTE      $80     ; DSTATS
       .BYTE      $80     ; DBUFL
       .BYTE      >TBUF   ; DBUFH
       .BYTE      $0F     ; DTIMLO
       .BYTE      $00     ; DRESVD
       .BYTE      $FF     ; DBYTL
       .BYTE      $00     ; DBYTH
       .BYTE      $FF     ; DAUX1
       .BYTE      $00     ; DAUX2
	
;;; End CIO PUT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;;; CIO STATUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.def	:w88
STADCBPTR:
	.word	STADCB
	
STATUS:
.def	:w89
	JSR     ENPRCD  ; ENABLE PRCD
.def	:w90
	JSR     GDIDX   ; GET DEVICE#
.def	:w91
       LDA     RLEN,X  ; GET RLEN
	BNE     STSLEN  ; RLEN > 0?
.def	:w92
       LDA     TRIP
       BNE     STTRI1  ; TRIP = 1?

       ; NO TRIP, RETURN SAVED LEN

.def	:w93
STSLEN LDA     RLEN,X  ; GET RLEN
       STA     DVSTAT  ; RET IN DVSTAT
; If you don't need to preserve Y then use it instead of A
       LDA     #$00
	STA     DVSTAT+1
; and INY here
	LDA	#$01
	STA	DVSTAT+2
	STA	DVSTAT+3
	
	BNE	STDONE

       ; DO POLL AND UPDATE RCV LEN

.def	:w94
STTRI1 JSR     STPOLL  ; POLL FOR ST
.def	:w95	
	STA	RLEN,X
		
       ; UPDATE TRIP FLAG

STTRIU BNE     STDONE
.def	:w96	
       STA     TRIP    ; RLEN = 0

       ; RETURN CONNECTED? FLAG.

STDONE LDA     DVSTAT+2
	LDY	#$01
       RTS

       ; ASK FUJINET FOR STATUS

STPOLL:	
	LDA     ZICDNO  ; IOCB #
.def	:w97
       STA     STADCB+1

.def	:w98
	LDA	STADCBPTR
.def	:w99
	LDY	STADCBPTR+1
.def	:w100
	JSR	DOSIOV

	;; > 127 bytes? make it 127 bytes.

	LDA	DVSTAT+1
	BNE	STADJ
	LDA	DVSTAT
	BMI	STADJ
	JMP	STP2		; <= 127 bytes...

STADJ	LDA	#$7F
	STA	DVSTAT
	LDA	#$00
	STA	DVSTAT+1
	
       ; A = CONNECTION STATUS

STP2   LDA     DVSTAT+2
       RTS

STADCB .BYTE      DEVIDN  ; DDEVIC
       .BYTE      $FF     ; DUNIT
       .BYTE      'S'     ; DCOMND
       .BYTE      $40     ; DSTATS
       .BYTE      $EA     ; DBUFL
       .BYTE      $02     ; DBUFH
       .BYTE      $0F     ; DTIMLO
       .BYTE      $00     ; DRESVD
       .BYTE      $04     ; DBYTL
       .BYTE      $00     ; DBYTH
       .BYTE      $00     ; DAUX1
       .BYTE      $00     ; DAUX2
	
;;; End CIO STATUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CIO SPECIAL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.def	:w101
SPEDCBPTR:
	.word SPEDCB
	
SPEC:
       ; HANDLE LOCAL COMMANDS.

       LDA     ZICCOM
       CMP     #$0F    ; 15 = FLUSH
	BNE     S1      ; NO.
.def	:w102
       JSR     PFLUSH  ; DO FLUSH
       LDY     #$01    ; SUCCESS
       RTS

       ; HANDLE SIO COMMANDS.
       ; GET DSTATS FOR COMMAND

S1:	LDA	ZICDNO
.def	:w103
	STA	SPEDCB+1
	LDA	ZICCOM
.def	:w104
	STA	SPEDCB+10

.def	:w105
	LDA	SPEDCBPTR
.def	:w106
	LDY	SPEDCBPTR+1
.def	:w107
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

.def	:w108	
	JMP	SIOVDST

	;; Return DSTATS in Y and A

SPEDCB .BYTE      DEVIDN  ; DDEVIC
       .BYTE      $FF     ; DUNIT
       .BYTE      $FF     ; DCOMND ; inq
       .BYTE      $40     ; DSTATS
       .BYTE      <INQDS  ; DBUFL
       .BYTE      >INQDS  ; DBUFH
       .BYTE      $0F     ; DTIMLO
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
.def	:w109
	.WORD      OPEN-1
.def	:w110
	.WORD      CLOSE-1
.def	:w111
	.WORD      GET-1
.def	:w112	
	.WORD      PUT-1
.def	:w113
	.WORD      STATUS-1
.def	:w114
       .WORD      SPEC-1

       ; BANNERS

BREADY .BYTE      '#FUJINET READY',$9B
BERROR .BYTE      '#FUJINET ERROR',$9B

       ; VARIABLES

DIFF	.DS	2	
TRIP   .DS      1       ; INTR FLAG
RLEN   .DS      MAXDEV  ; RCV LEN
ROFF   .DS      MAXDEV  ; RCV OFFSET
TOFF   .DS      MAXDEV  ; TRX OFFSET
INQDS  .DS      1       ; DSTATS INQ

       ; BUFFERS (PAGE ALIGNED)

	.ALIGN	$100
	
RBUF	.DS	$80		; 128 bytes
TBUF	.DS	$80		; 128 bytes
	
DRIVEREND	= *
	
	RUN	START
       END
s
