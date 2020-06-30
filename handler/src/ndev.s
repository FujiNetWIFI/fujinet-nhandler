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

RESETPTR:	
.def	:w0
	.word	RESET
	
START:	
	LDA	DOSINI
.def	:w1
	STA	RESET+1
	LDA	DOSINI+1
.def	:w2
	STA	RESET+2
	LDA	RESETPTR
	STA	DOSINI
	LDA	RESETPTR+1
	STA	DOSINI+1

	;;  Alter MEMLO
.def	:w3
	JSR	ALTMEML

	BVC	IHTBS

RESET:
	JSR	$FFFF		; Jump to extant DOSINI
.def	:w4
	JSR	IHTBS		; Insert into HATABS

	;;  Alter MEMLO

ALTMEMLPTR:
.def	:w5
	.word	PGEND
	
ALTMEML:	
.def	:w6
	LDA	ALTMEMLPTR		
	STA	MEMLO
.def	:w7
	LDA	ALTMEMLPTR+1
	STA	MEMLO+1

	;; Back to DOS
	
	RTS

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

.def	:w39
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

.def	:w40
CLODCBPTR:
	.word	CLODCB
	
CLOSE:
.def	:w41
	JSR     DIPRCD		; Disable Interrupts
.def	:w42
	JSR	GDIDX
.def	:w43
	JSR	PFLUSH		; Do a Put Flush if needed.

	LDA     ZICDNO		; IOCB Unit #
.def	:w44
	STA     CLODCB+1	; to DCB...

.def	:w45
	LDA	CLODCBPTR
.def	:w46
	LDY	CLODCBPTR+1
.def	:w47
	JMP	DOSIOV

.def	:w48
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

.def	:w49
GETDCBPTR:
	.word GETDCB
	
GET:
.def	:w50
	JSR	GDIDX		; IOCB UNIT #-1 into X
.def	:w51
	LDA	RLEN,X		; Get # of RX chars waiting
	BNE     GETDISC		; LEN > 0?

	;; If RX buffer is empty, get # of chars waiting...

.def	:w52
	JSR	STPOLL		; Status Poll
.def	:w53
	JSR	GDIDX		; IOCB UNIT -1 into X (because Poll trashes X)
	LDA	DVSTAT		; # of bytes waiting (0-127)
.def	:w54
	STA	RLEN,X		; Store in RX Len
	BEQ	RETEOF

GETDO:
	LDA	ZICDNO		; Get IOCB UNIT #
.def	:w55
	STA	GETDCB+1	; Store into DUNIT
	LDA	DVSTAT		; # of bytes waiting
.def	:w56
	STA	GETDCB+8	; Store into DBYT...
.def	:w57
	STA	GETDCB+10	; and DAUX1...

.def	:w58
	LDA	GETDCBPTR
.def	:w59
	LDY	GETDCBPTR+1
.def	:w60
	JSR	DOSIOV

	;; Clear the Receive buffer offset.
.def	:w61
	JSR	GDIDX		; IOCB UNIT #-1 into X
	LDA	#$00
.def	:w62
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
.def	:w63
	DEC     RLEN,X		; Decrement RX length.
.def	:w64
	LDY     ROFF,X		; Get RX offset cursor.

	;; Return Next char from appropriate RX buffer.
.def	:w65	
	LDA	RBUF,Y
	
	;; Increment RX offset
.def	:w66	
GX:	INC	ROFF,X		; Increment RX offset.
	TAY			; stuff returned val into Y temporarily.

	;; If requested RX buffer is empty, reset TRIP.
.def	:w67
	LDA	RLEN,X
	BNE	GETDONE
.def	:w68
	STA     TRIP

	;; Return byte back to CIO.
	
GETDONE:
	TYA			; Move returned val back.
	LDY	#$01		; SUCCESS

	RTS			; DONE...

.def	:w69
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

.def	:w70
PUTDCBPTR:
	.word	PUTDCB
	
PUT:
	;; Add to TX buffer.

.def	:w71
	JSR	GDIDX
.def	:w72
	LDY	TOFF,X  ; GET TX cursor.
.def	:w73
	STA	TBUF,Y		; TX Buffer

.def	:w74
POFF:	INC	TOFF,X		; Increment TX cursor
	LDY	#$01		; SUCCESSFUL

	;; Do a PUT FLUSH if EOL or buffer full.

	CMP     #EOL    ; EOL?
	BEQ     FLUSH  ; FLUSH BUFFER
.def	:w75
	JSR     GDIDX   ; GET OFFSET
.def	:w76
	LDA     TOFF,X
        CMP     #$7F    ; LEN = $FF?
        BEQ     FLUSH  ; FLUSH BUFFER
        RTS

       ; FLUSH BUFFER, IF ASKED.

.def	:w77
FLUSH  JSR     PFLUSH  ; FLUSH BUFFER
       RTS

PFLUSH:	

       ; CHECK CONNECTION, AND EOF
       ; IF DISCONNECTED.

.def	:w78
       JSR     STPOLL  ; GET STATUS
       LDA     DVSTAT+2
	BEQ	RETEOF

.def	:w79
PF1:	JSR     GDIDX   ; GET DEV X
.def	:w80
       LDA     TOFF,X
	BNE     PF2
.def	:w81
       JMP     PDONE

       ; FILL OUT DCB FOR PUT FLUSH

PF2:	LDA     ZICDNO
.def	:w82
       STA     PUTDCB+1
	
       ; FINISH DCB AND DO SIOV

.def	:w83
TBX:	LDA     TOFF,X
.def	:w84
	STA     PUTDCB+8
.def	:w85
	STA     PUTDCB+10

.def	:w86
	LDA	PUTDCBPTR
.def	:w87
	LDY	PUTDCBPTR+1
.def	:w88
	JSR     DOSIOV
       
       ; CLEAR THE OFFSET CURSOR
       ; AND LENGTH

.def	:w89
       JSR     GDIDX
	LDA     #$00
.def	:w90
       STA     TOFF,X

PDONE:	LDY     #$01
       RTS

.def	:w91
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

.def	:w92
STADCBPTR:
	.word	STADCB
	
STATUS:
.def	:w93
	JSR     ENPRCD  ; ENABLE PRCD
.def	:w94
	JSR     GDIDX   ; GET DEVICE#
.def	:w95
       LDA     RLEN,X  ; GET RLEN
	BNE     STSLEN  ; RLEN > 0?
.def	:w96
       LDA     TRIP
       BNE     STTRI1  ; TRIP = 1?

       ; NO TRIP, RETURN SAVED LEN

.def	:w97
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

.def	:w98
STTRI1 JSR     STPOLL  ; POLL FOR ST
.def	:w99	
	STA	RLEN,X
		
       ; UPDATE TRIP FLAG

STTRIU BNE     STDONE
.def	:w100	
       STA     TRIP    ; RLEN = 0

       ; RETURN CONNECTED? FLAG.

STDONE LDA     DVSTAT+2
	LDY	#$01
       RTS

       ; ASK FUJINET FOR STATUS

STPOLL:	
	LDA     ZICDNO  ; IOCB #
.def	:w101
       STA     STADCB+1

.def	:w102
	LDA	STADCBPTR
.def	:w103
	LDY	STADCBPTR+1
.def	:w104
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

.def	:w105
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

.def	:w106
SPEDCBPTR:
	.word SPEDCB
	
SPEC:
       ; HANDLE LOCAL COMMANDS.

       LDA     ZICCOM
       CMP     #$0F    ; 15 = FLUSH
	BNE     S1      ; NO.
.def	:w107
       JSR     PFLUSH  ; DO FLUSH
       LDY     #$01    ; SUCCESS
       RTS

       ; HANDLE SIO COMMANDS.
       ; GET DSTATS FOR COMMAND

S1:	LDA	ZICDNO
.def	:w108
	STA	SPEDCB+1
	LDA	ZICCOM
.def	:w109
	STA	SPEDCB+10

.def	:w110
	LDA	SPEDCBPTR
.def	:w111
	LDY	SPEDCBPTR+1
.def	:w112
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

.def	:w113	
	JMP	SIOVDST

	;; Return DSTATS in Y and A

.def	:w114
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
.def	:w115
CIOHND .WORD      OPEN-1
       .WORD      CLOSE-1
       .WORD      GET-1
       .WORD      PUT-1
       .WORD      STATUS-1
       .WORD      SPEC-1

       ; BANNERS

BREADY .BYTE      '#FUJINET READY',$9B
BERROR .BYTE      '#FUJINET ERROR',$9B

       ; VARIABLES

TRIP   .DS      1       ; INTR FLAG
RLEN   .DS      MAXDEV  ; RCV LEN
ROFF   .DS      MAXDEV  ; RCV OFFSET
TOFF   .DS      MAXDEV  ; TRX OFFSET
INQDS  .DS      1       ; DSTATS INQ

       ; BUFFERS (PAGE ALIGNED)

	.ALIGN	$100
	
RBUF	.DS	$80		; 128 bytes
TBUF	.DS	$80		; 128 bytes
	
PGEND	= *
	
	RUN	START
       END
s
