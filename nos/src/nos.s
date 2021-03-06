	;; N: Device Handler
	;; Compile with MADS

	;; Author: Thomas Cherryhomes
	;;   <thom.cherryhomes@gmail.com>
	;; CURRENT IOCB IN ZERO PAGE

	;; Optimizations being done by djaybee!
	;; Thank you so much!

DOSVEC  =     $0A       	; DOSVEC
DOSINI  =     $0C      ; DOSINI

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
	
CIX	=     $F2      ; Inbuff cursor
INBUFF	=     $F3      ; Ptr to input buffer ($0580)
	
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

LNBUF   =     $0580   ; Line Buffer (128 bytes)

       ; HARDWARE REGISTERS

PACTL   =     $D302   ; PIA CTRL A

	;; MATH PACK VECTORS

LDBUFA	=	$DA51		; Set INBUFF to $0580
SKPSPC	=	$DBA1		; Increment CIX to next whitespace
	
       ; OS ROM VECTORS

CIOV    =     $E456   ; CIO ENTRY
SIOV    =     $E459   ; SIO ENTRY

       ; CONSTANTS

GETREC	=	$05		; CIO GET RECORD
PUTREC  =     $09     ; CIO PUTREC
PUTCHR	=	$0B   ; CIO PUTCHR
	
DEVIDN  =     $71     ; SIO DEVID
DSREAD  =     $40     ; FUJI->ATARI
DSWRIT  =     $80     ; ATARI->FUJI
MAXDEV  =     4       ; # OF N: DEVS
EOF     =     $88     ; ERROR 136
EOL     =     $9B     ; EOL CHAR

CMD_DRIVE_CHANGE	= $01
CMD_CD			= $2C
CMD_COPY		= $A1
CMD_DIR			= $02
CMD_DEL			= $21
CMD_LOAD		= $28
CMD_LOCK		= $23
CMD_MKDIR		= $2A
CMD_RMDIR		= $2B
CMD_UNLOCK		= $24
	
;;; Macros ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.MACRO DCBC
	.LOCAL
	LDY	#$0C
?DCBL	LDA	%%1,Y
	STA	DCB,Y
	DEY
	BPL	?DCBL
	.ENDL
	.ENDM
		
;;; Initialization ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ORG	$0700
	OPT	h-
	
HDR:	.BYTE	$00
	.BYTE	$10
	.BYTE	$00
	.BYTE	$07
	.BYTE	$C0
	.BYTE	$E4
	
START:	
	LDA	DOSINI
	STA	RESET+1
	LDA	DOSINI+1
	STA	RESET+2
	LDA	#<RESET
	STA	DOSINI
	LDA	#>RESET
	STA	DOSINI+1
	LDA	#<DOS
	STA	DOSVEC
	LDA	#>DOS
	STA	DOSVEC+1

	JSR	ALTMEML

	RTS
	
RESET:
	JSR	$FFFF		; Jump to extant DOSINI
	JSR	IHTBS		; Insert into HATABS

	;;  Alter MEMLO
	
ALTMEML:	
	LDA	#<PGEND		
	STA	MEMLO
	LDA	#>PGEND
	STA	MEMLO+1

	;; Back to DOS
	
	RTS

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
	LDA	#<CIOHND
	STA	HATABS+1,Y
	LDA	#>CIOHND
	STA	HATABS+2,Y

	;; And we're done with HATABS

	;; Query FUJINET

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
	LDA	#<BERROR
	LDY	#>BERROR
	BVC	OBCIO

	;; Status returned ready.
	
OBRDY:	
	LDA	#<BREADY
	LDY	#>BREADY

OBCIO:
	STA	ICBAL,X
	TYA
	STA	ICBAH,X

	JSR	CIOV

	;; Vector in proceed interrupt

SPRCED:
	LDA	#<PRCVEC
	STA	VPRCED
	LDA	#>PRCVEC
	STA	VPRCED+1

	;; And we are done, back to DOS.
	CLC
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
	
	LDA	#<OPNDCB
	LDY	#>OPNDCB

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
	LDA	#$01
	STA	TRIP
	JSR     GDIDX
	LDA     #$00
	STA     RLEN,X
	STA     TOFF,X
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

CLOSE:	
	JSR     DIPRCD		; Disable Interrupts
	JSR	GDIDX
	JSR	PFLUSH		; Do a Put Flush if needed.

	LDA     ZICDNO		; IOCB Unit #
	STA     CLODCB+1	; to DCB...
	
	LDA	#<CLODCB
	LDY	#>CLODCB

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

GET:
	JSR	GDIDX		; IOCB UNIT #-1 into X 
	LDA	RLEN,X		; Get # of RX chars waiting
	BNE     GETDISC		; LEN > 0?

	;; If RX buffer is empty, get # of chars waiting...
	
	JSR	STPOLL		; Status Poll
	JSR	GDIDX		; IOCB UNIT -1 into X (because Poll trashes X)
	LDA	DVSTAT		; # of bytes waiting (0-127)
	STA	RLEN,X		; Store in RX Len
	BEQ	RETEOF

GETDO:
	LDA	ZICDNO		; Get IOCB UNIT #
	STA	GETDCB+1	; Store into DUNIT
	LDA	DVSTAT		; # of bytes waiting
	STA	GETDCB+8	; Store into DBYT...
	STA	GETDCB+10	; and DAUX1...
       
	LDA	#<GETDCB
	LDY	#>GETDCB
	
	JSR	DOSIOV

	;; Clear the Receive buffer offset.
	
	JSR	GDIDX		; IOCB UNIT #-1 into X
	LDA	#$00
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
	DEC     RLEN,X		; Decrement RX length.
	LDY     ROFF,X		; Get RX offset cursor.

	;; Return Next char from appropriate RX buffer.
	
	LDA	RBUF,Y
	
	;; Increment RX offset
	
GX:	INC	ROFF,X		; Increment RX offset.
	TAY			; stuff returned val into Y temporarily.

	;; If requested RX buffer is empty, reset TRIP.

	LDA	RLEN,X
	BNE	GETDONE
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
       LDA     DVSTAT+2
	BEQ	RETEOF

PF1:	JSR     GDIDX   ; GET DEV X
       LDA     TOFF,X
       BNE     PF2
       JMP     PDONE

       ; FILL OUT DCB FOR PUT FLUSH

PF2:	LDA     ZICDNO
       STA     PUTDCB+1
	
       ; FINISH DCB AND DO SIOV

TBX:	LDA     TOFF,X
	STA     PUTDCB+8
	STA     PUTDCB+10

	LDA	#<PUTDCB
	LDY	#>PUTDCB
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

STATUS:
	JSR     ENPRCD  ; ENABLE PRCD
       JSR     GDIDX   ; GET DEVICE#
       LDA     RLEN,X  ; GET RLEN
       BNE     STSLEN  ; RLEN > 0?
       LDA     TRIP
       BNE     STTRI1  ; TRIP = 1?

       ; NO TRIP, RETURN SAVED LEN

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

STTRI1 JSR     STPOLL  ; POLL FOR ST
	STA	RLEN,X
		
       ; UPDATE TRIP FLAG

STTRIU BNE     STDONE
       STA     TRIP    ; RLEN = 0

       ; RETURN CONNECTED? FLAG.

STDONE LDA     DVSTAT+2
	LDY	#$01
       RTS

       ; ASK FUJINET FOR STATUS

STPOLL:	
       LDA     ZICDNO  ; IOCB #
       STA     STADCB+1

	LDA	#<STADCB
	LDY	#>STADCB

	JSR	DOSIOV

	;; > 127 bytes? make it 127 bytes.

	LDA	DVSTAT+1
	BNE	STADJ
	LDA	DVSTAT
	BMI	STADJ
	BVC	STP2		; <= 127 bytes...

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

SPEC:
       ; HANDLE LOCAL COMMANDS.

       LDA     ZICCOM
       CMP     #$0F    ; 15 = FLUSH
       BNE     S1      ; NO.
       JSR     PFLUSH  ; DO FLUSH
       LDY     #$01    ; SUCCESS
       RTS

S1:	
	CMP	#40	 ; 40 = LOAD AND EXECUTE	
	BEQ	S2	 ; YES.
	JMP	S3	 ; NO. SKIP OVER spec40
	
S2:
	RTS
       ; HANDLE SIO COMMANDS.
       ; GET DSTATS FOR COMMAND
S3:
	LDA	ZICDNO
	STA	SPEDCB+1
	LDA	ZICCOM
	STA	SPEDCB+10
	
	LDA	#<SPEDCB
	LDY	#>SPEDCB
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

;;; CP is here ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; Called to do drive change
	
DO_DRIVE_CHANGE:
	LDA	LNBUF
	STA	PRMPT+1
	LDA	LNBUF+1
	SEC
	SBC	#$30
	STA	DOSDR
	RTS

	;; Show the prompt, consisting of current device.
	
SHOWPROMPT:
	LDX	#$00
	CLC
	LDA	DOSDR
	ADC	#$30
	STA	PRMPT+2
	LDA	#PUTCHR
	STA	ICCOM,X
	LDA	#<PRMPT
	STA	ICBAL,X
	LDA	#>PRMPT
	STA	ICBAH,X
	LDA	#$04
	STA	ICBLL,X
	TXA			; 0
	STA	ICBLH,X
	JSR	CIOV
	RTS

	;; Get line of input
	
GETCMD: LDX	#$00
	LDA	#GETREC
	STA	ICCOM,X
	LDA	#$80
	STA	ICBAL,X
	LDA	#$05
	STA	ICBAH,X
	LDA	#$7F
	STA	ICBLL,X
	JSR	CIOV
	RTS

	;; Check for a drive change command
	
PARSE_DRIVE_CHANGE:
	LDX	#$03		; Check for EOL in pos 3
	LDA	LNBUF,X
	CMP	#$9B
	BNE	PARSE_DRIVE_CHANGE_DONE
	DEX			; go back one char
	LDA	LNBUF,X
	CMP	#':'		; Check for colon.
	BNE	PARSE_DRIVE_CHANGE_DONE
	LDA	#CMD_DRIVE_CHANGE
	STA	CMD
PARSE_DRIVE_CHANGE_DONE:
	RTS

	;; Routine to parse intrinsic command
	
PARSE_INTRINSIC_COMMAND:
	LDY	#$00
	STY	CIX
	JSR	LDBUFA		; Set INBUFF to $0580
	JSR	SKPSPC		; Skip whitespace

PARSE_INTRINSIC_NEXT_CHAR:
	LDA	(INBUFF),y
	AND	#$7F
	EOR	COMMAND,X
	INY

	ASL
	BEQ	PARSE_INTRINSIC_CHAR_OK

	;; Skip to next command

PARSE_INTRINSIC_NEXT_COMMAND:
	LDA	COMMAND,X
	ASL
	INX
	BCC	PARSE_INTRINSIC_NEXT_COMMAND
	LDY	CIX
	CPX	#COMMAND_SIZE

PARSE_INTRINSIC_CHAR_OK:
	INX
	BCC	PARSE_INTRINSIC_NEXT_CHAR
	STY	CIX
	LDA	(INBUFF),Y
	BMI	PARSE_INTRINSIC_RET

	JSR	SKPSPC

PARSE_INTRINSIC_RET_ERROR:
	LDX	#COMMAND_SIZE+1
PARSE_INTRINSIC_RET:
	LDA	COMMAND,X
	STA	CMD
PARSE_INTRINSIC_DONE:	
	RTS

	;; Parse command (main)
	
PARSECMD:
	LDA	ICBLL,X
	CMP	#$9B
	BEQ	PARSECMD_DONE
	JSR	PARSE_INTRINSIC_COMMAND
	JSR	PARSE_DRIVE_CHANGE
PARSECMD_DONE:	
	RTS
	
DOCMD:
	LDA	CMD
	CMP	#$01
	BNE	DOCMD_DONE
	JSR	DO_DRIVE_CHANGE
DOCMD_DONE:
	LDA	CMD
	STA	$02C6
	LDA	#$FF
	STA	CMD
	RTS
	
PROMPT:
	JSR	SHOWPROMPT
	JSR	GETCMD
	JSR	PARSECMD
	JSR	DOCMD
	RTS
	
DOS:
	JSR	PROMPT
	JMP	DOS
	RTS

PRMPT:
	.BYTE	$9b,'N :'		; Prompt start
	
;;; End CP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Variables

	;; Command table
COMMAND:
	.CB	"CD"
	.BYTE	CMD_CD
	.CB	"COPY"
	.BYTE	CMD_COPY
	.CB	"DIR"
	.BYTE	CMD_DIR
	.CB	"DEL"
	.BYTE	CMD_DEL
	.CB	"LOAD"
	.BYTE	CMD_LOAD
	.CB	"LOCK"
	.BYTE	CMD_LOCK
	.CB	"MKDIR"
	.BYTE	CMD_MKDIR
	.CB	"RMDIR"
	.BYTE	CMD_RMDIR
	.CB	"UNLOCK"
	.BYTE	CMD_UNLOCK
	
COMMAND_SIZE = * - COMMAND - 1
	.byte $FF
	
       ; DEVHDL TABLE FOR N:

CIOHND .WORD      OPEN-1
       .WORD      CLOSE-1
       .WORD      GET-1
       .WORD      PUT-1
       .WORD      STATUS-1
       .WORD      SPEC-1

       ; BANNERS
       
BREADY .BYTE      '#FUJINET NOS',$9B
BERROR .BYTE      '#FUJINET ERROR',$9B

       ; VARIABLES

DOSDR	.BYTE	1		; DOS DRIVE
CMD	.DS	1
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
	
       END
