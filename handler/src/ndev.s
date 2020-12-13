	;; N: Device Handler
	;; Compile with MADS

	;; Author: Thomas Cherryhomes
	;;   <thom.cherryhomes@gmail.com>

	;; CURRENT IOCB IN ZERO PAGE

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

VPRCED  =     $0202   ; PROCEED VCTR
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

DEVIDN  =     $71     ; SIO DEVID
DSREAD  =     $40     ; FUJI->ATARI
DSWRIT  =     $80     ; ATARI->FUJI
MAXDEV  =     4       ; # OF N: DEVS
EOF     =     $88     ; ERROR 136
EOL     =     $9B     ; EOL CHAR

	;; ORG HERE
	ORG	$2200
	
	;; This is for OS/A+

	RTS			; Immediately exit

;;; RESET HANDLER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RESET:	
	JSR	$FFFF		; Modified for original DOSINI
	LDA	#$FF		; Driver end LO
	STA 	MEMLO
	LDA	#$FF		; Driver end HI
	STA	MEMLO+1
	JSR	IHTBS		; Insert into HATABS
	JSR	CLALL
	RTS
	
;;; END RESET HANDLER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; INTERRUPT HANDLER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INTR:	LDA	#$01		; set trip to 1
	STA	TRIP
	PLA
	RTI
	
;;; END INTERRUPT HANDLER ;;;;;;;;;;;;;;;;;;;;;;;;

;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; GET IOCB UNIT # INTO X
	
GDIDX:	LDX	ZICDNO		; CURRENT IOCB UNIT #
	DEX			; -1
	RTS

	;; Poll for Status

POLL:	LDA	ZICDNO		; Get Unit #
	STA	POLDCB+1	; Put into Table
	LDA	#<POLDCB	; Set up STATUS POLL DCB table
	LDY	#>POLDCB
	JSR	DOSIOV		; And do SIOV
	
	RTS

POLDCB:	.BYTE      DEVIDN  ; DDEVIC
	.BYTE      $FF     ; DUNIT
	.BYTE      'S'     ; DCOMND
	.BYTE      DSREAD     ; DSTATS
	.WORD	   DVSTAT  ; DBUF
	.BYTE      $1F     ; DTIMLO
	.BYTE      $00     ; DRESVD
	.WORD	   4	   ; 4 bytes
	.BYTE      $00     ; DAUX1
	.BYTE      $00     ; DAUX2

	;; Save DVSTAT values

SVSTAT: JSR	GDIDX	   	; Get Unit into X
	LDA	BURST		; Are we in burst mode?
	BNE	SVSTAS		; Yes, do not cap values, just save them.
	JSR	CAPRX		; Cap RX values
SVSTAS:	LDA	DVSTAT		; Get RX bytes waiting
	STA	RLEN,X		; Save RX bytes waiting
	LDA	DVSTAT+2	; Get Server Client connected/disconnected?
	STA	DVS2,X		; Save 
	LDA	DVSTAT+3	; Get last error
	STA	DVS3,X		; Save
	RTS
	
	;; Enable PROCEED interrupt

ENPRCD:	LDA	PACTL		; Get PACTL register
	ORA	#$01		; Enable PROCEED
	STA	PACTL		; Store it back
	RTS

	;; Disable PROCEED interrupt
	
DIPRCD:	LDA	PACTL		; Get PACTL register
	AND	#$FE		; Disable PROCEED
	STA	PACTL		; store it back.
	RTS

	;; Flush TX Buffer out
	
FLUSH:	JSR	GDIDX		; UNIT NUMBER into X
	LDA	ZICDNO		; IOCB UNIT #
	STA	FLUDCB+1	; Put into table.
	LDA	TOFF,X		; get Transmit offset (# of bytes to send)
	BEQ	FLDONE		; Don't do anything if TX cursor is at 0.
	STA	FLUDCB+8	; Put into Table (Len and Aux)
	STA	FLUDCB+10
	LDA	#<FLUDCB	; Copy Table to DCB
	LDY	#>FLUDCB
	JSR	DOSIOV		; And call SIOV
	JSR	GDIDX		; Get Unit into X
	LDA	#$00		; Clear TOFF
	STA	TOFF,X
	LDY	DSTATS
FLDONE:	RTS			; Done, LDY has DSTATS

FLUDCB:	.BYTE      DEVIDN  	; DDEVIC
	.BYTE      $FF     	; DUNIT
	.BYTE      'W'     	; DCOMND
	.BYTE      DSWRIT     	; DSTATS
	.WORD      TBUF    	; DBUFL
	.BYTE      $1F     	; DTIMLO
	.BYTE      $00     	; DRESVD
	.BYTE      $FF     	; DBYTL
	.BYTE      $00     	; DBYTH
	.BYTE      $FF     	; DAUX1
	.BYTE      $00     	; DAUX2

	;; Cap RX to 127 bytes (temporary routine)

CAPRX:	LDA	DVSTAT+1	; Get hi-byte
	BNE	CAPADJ		; Adjust if > 256 bytes
	LDA	DVSTAT		; Get lo-byte
	BPL	CAPDON		; Exit if < 127 bytes
CAPADJ:	LDA	#$7F		; 127 bytes
	STA	DVSTAT		; into DVSTAT/DVSTAT+1
	LDA	#$00
	STA	DVSTAT+1
CAPDON:	RTS			; Done

	;; Close all IOCBs

CLALL:	LDA	#MAXDEV		; Close all 4 N: devices
	STA	TRIP		; Temporarily use trip
CLLP:	LDA	TRIP		; Get
	STA	ZICDNO		; Store into unit #
	JSR	CLOSE		; Close Nx:
	DEC	TRIP		; Decrement
	LDA	TRIP		; Get it
	BNE	CLLP		; Loop until done.
	RTS	

	;; Do read from ZIOCB unit

READ:	JSR	GDIDX	  	; unit into X
	LDA	ZICDNO		; Get Unit #
	STA	READCB+1	; Put into Read DCB table
	LDA	BURST		; Are we in burst mode?
	BEQ	READNB		; no, do non-bursted read.
READB:	JSR	POLL		; do status poll to get available bytes
	LDA	ZICBLH		; Get hi byte of # of bytes requested
	CMP	DVSTAT+1	; compare with # of bytes available (H)
	BCC	READBC		; if < then go ahead and set up the read
	LDA	ZICBLL		; Get lo byte of # of bytes requested
	CMP	DVSTAT		; compare with # of bytes available (L)
	BCC	READBC		; if < then go ahead and set up the read
READBJ:	LDA	DVSTAT		; Get bytes available (L)
	STA	ZICBLL		; Store in requested bytes available (L)
	LDA	DVSTAT+1	; Get bytes available (H)
	STA	ZICBLH		; Store in requested bytes available (H)
READBC: SEC			; Set up for subtraction
	LDA	ZICBLL		; Get requested length
	SBC	#$01		; subtract 1
	STA	ZICBLL		; store back
	BCC	READBD		; Continue on if done.
	DEC	ZICBLH		; Decrement high byte if needed.	
READBD:	LDA	BURST		; are we in burst?
	BEQ	READBE		; nope continue on
	LDA	#$00		; Store 0
	STA	RLEN,X		; Into RLEN
	STA	DVSTAT+1
	STA	ROFF,X		; and ROFF, so that next read will get remaining byte.
READBE:	LDA	ZICBAL		; Get requested destination buffer (L)
	STA	READCB+4	; Store into table
	LDA	ZICBAH		; Get requested destination buffer (H)
	STA	READCB+5	; Store into table
	LDA	ZICBLL		; Get requested length L (which may have been adjusted)
	STA	READCB+8	; Store into table in DBYTL
	STA	READCB+10	; ...and DAUX1
	LDA	ZICBLH		; Get requested length H
	STA	READCB+9	; Store into table in DBYTH
	STA	READCB+11	; ...and DAUX2
	JMP	READ2		; And do the read.	
READNB:	LDA	#<RBUF		; point to non-burst buffer
	STA	READCB+4	; put in DBUFL
	LDA	#>RBUF		; point to non-burst buffer
	STA	READCB+5	; put in DBUFH
	LDA	#$00		; Set 0 into
	STA	ROFF,X		; RXD cursor.
	STA	READCB+9	; zero out high byte of DBYTH
	STA	READCB+11	; ...and DAUX2
	LDA	RLEN		; Get RLEN (from status)
	BEQ	RDONE		; If RLEN=0 then abort read.
	STA	READCB+8	; Store in DBYTL
	STA	READCB+10	; Store in DAUX1
READ2:	LDA	#<READCB	; Set up Read DCB
	LDY	#>READCB	; ...
	JSR	DOSIOV		; Do SIO call
	LDY	DSTATS		; Get DSTATS for error
READ3:	CPY	#144		; Is it 144?
	BNE	RDONE		; No, simply return DSTATS in Y
	JSR	POLL		; Otherwise, do a poll to get extended error
	LDY	DVSTAT+3	; And return it in Y.
RDONE:	RTS			; Done.

READCB .BYTE     DEVIDN  	; DDEVIC
       .BYTE     $FF     	; DUNIT
       .BYTE     'R'     	; DCOMND
       .BYTE     DSREAD     	; DSTATS
       .WORD	 RBUF	 	; DBUF
       .BYTE     $1F     	; DTIMLO
       .BYTE     $00     	; DRESVD
       .BYTE     $FF     	; DBYTL
       .BYTE     $00     	; DBYTH
       .BYTE     $FF     	; DAUX1
       .BYTE     $00     	; DAUX2

	;; set burst = 1
SETB:	LDA	#$01		; 1 to
	STA	BURST		; burst mode flag
	RTS

	;; set burst = 0
CLRB:	LDA	#$00		; 0 to
	STA	BURST		; burst mode flag
	RTS
	
;;; END SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;;; DEVICE HANDLER TABLE ;;;;;;;;;;;;;;;;;;;;;;;;;

DEVHDL:	.WORD	OPEN-1
	.WORD	CLOSE-1
	.WORD	GET-1
	.WORD	PUT-1
	.WORD	STATUS-1
	.WORD	SPECIAL-1
	
;;; HANDLER RUNAD HERE ;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
START:	LDA	DOSINI
	STA	RESET+1
	LDA	DOSINI+1
	STA	RESET+2
	LDA	#<RESET
	STA	DOSINI
	LDA	#>RESET
	STA	DOSINI+1
	LDA	#<HANDLEREND
	STA	MEMLO
	STA	RESET+4
	LDA	#>HANDLEREND
	STA	MEMLO+1
	STA	RESET+9
	JSR	CLALL		; Close all
	
;;; Insert Handler entry into HATABS ;;;;;;;;;;;

IHTBS:	LDY	#$00		; Start at beginning of HATABS
IH1:	LDA	HATABS,Y
	BEQ	HFND		; Did we find a blank ($00) entry?
	CMP	#'N'		; or did we find our existing 'N' entry?
	BEQ	HFND		; If so, insert our entry here.
	INY			; Otherwise, scoot forward to next entry.
	INY			
	INY
	CPY	#11*3		; Are we at the end of the table?
	BCC	IH1		; Check again.

	;; We found a slot, insert it in.

HFND:	LDA	#'N'		; We are the N: device
	STA	HATABS,Y	; first byte in our entry
	LDA	#<DEVHDL	; Get address of our handler table
	STA	HATABS+1,Y	; and put it in Hatabs
	LDA	#>DEVHDL
	STA	HATABS+2,Y
	
	;; And vector in PROCEED.

VPRCD:	LDA	#<INTR		; Get Addr of interrupt handler
	STA	VPRCED		; Store it in PROCEED vector
	LDA	#>INTR
	STA	VPRCED+1
	
	;; We're done, back to DOS.

	RTS

;;; INDICATE SUCCESS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUCC:	LDY	#$01 		; Indicate success
	RTS			; Back to caller.

;;; CLEAR BUFFERS FOR UNIT X ;;;;;;;;;;;;;;;;;;;;
	
CLRBUF:	LDA	#$00
	STA	RLEN,X
	STA	TOFF,X
	STA	ROFF,X
	STA	DVS2,X
	STA	DVS3,X
	RTS
	
;;; COPY TABLE TO DCB AND DO SIO CALL ;;;;;;;;;;;

DOSIOV: STA	DODCBL+1	; Set source address
	STY	DODCBL+2
	LDY	#$0C		; 12 bytes
DODCBL	LDA	$FFFF,Y		; Changed above.
	STA	DCB,Y		; To DCB table
	DEY			; Count down
	BPL	DODCBL		; Until done

SIOVDST:	
	JSR	SIOV		; Call SIOV
	LDY	DSTATS		; Get STATUS in Y
	TYA			; Copy it into A
	RTS			; Done
	
;;; OPEN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; Fill in the OPEN table
	
OPEN:   JSR	GDIDX		; Set IOCB OFFSET TO UNIT #
	JSR	CLRBUF		; Clear Buffers
	LDA	ZICDNO		; GET Desired unit #
	STA	OPNDCB+1	; Store in open table
	LDA	ZICBAL		; Get desired buffer LO
	STA	OPNDCB+4	; Store in open table
	LDA	ZICBAH		; Get desired buffer HI
	STA	OPNDCB+5	; Store in open table
	LDA	ZICAX1		; Get requested Aux1
	STA	OPNDCB+10	; Store in open table
	LDA	ZICAX2		; Get requested Aux2
	STA	OPNDCB+11	; Store in open table

	;; Do the SIOV call
	
	LDA	#<OPNDCB
	LDY	#>OPNDCB
	JSR	DOSIOV

	;; Return DSTATS in Y, unless 144, then get ext err.

	CPY	#144		; Did we get an ERROR- 144?
	BNE	OPDONE		; Nope, keep DSTATS in Y

	;; We got a 144, get error from STATUS call
	JSR	POLL		; Do Status poll
	LDY	DVSTAT+3	; Get error code

OPDONE:	RTS

	;; OPEN DCB TABLE

OPNDCB:
	.BYTE      DEVIDN  	; DDEVIC
	.BYTE      $FF     	; DUNIT
	.BYTE      'O'     	; DCOMND
	.BYTE      DSWRIT     	; DSTATS
	.BYTE      $FF     	; DBUFL
	.BYTE      $FF     	; DBUFH
	.BYTE      $1F     	; DTIMLO
	.BYTE      $00     	; DRESVD
	.BYTE      $00     	; DBYTL
	.BYTE      $01     	; DBYTH
	.BYTE      $FF     	; DAUX1
	.BYTE      $FF     	; DAUX2

;;; CLOSE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CLOSE:	JSR	DIPRCD		; Disable PROCEED
	JSR	FLUSH		; do PUT flush if needed.
	JSR	CLRBUF		; Clear buffer pointers
	LDA	ZICDNO		; Unit #
	STA	CLODCB+1	; Put into table
	LDA	#<CLODCB	; Close DCB table
	LDY	#>CLODCB
	JSR	DOSIOV		; Do SIOV
	JMP	SUCC		; Always return success

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

;;; GET ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; GET entry point for CIO
	
GET:	JSR	GDIDX		; Unit into X
	JSR	CLRB		; Clear burst flag.
	LDA	ZICCOM		; Get command
	CMP	#5		; GET RECORD?
	BEQ	GETNOB		; Bypass burst
	LDA	ZICBLH		; high byte of length
	BEQ	GETNOB		; set burst if > 0
	LDA	ZICBLL		; low byte of length
	BPL	GETNOB		; set burst if > 127
	JSR	SETB		; Set burst flag if above conditions fall through.
	LDA	BURST		; Are we now in burst mode?
	BNE	GETWAI		; Yeah, Wait for some data
GETNOB:	LDA	RLEN,X		; Get current RX len from last STATUS
	BNE	GETDRN		; If RLEN > 0 then drain.

	;; Otherwise, we wait for something to happen.

GETWAI:	JSR	ENPRCD		; Enable Proceed
	LDA	TRIP		; Did trip change?
	BEQ	GETWAI		; Nope, not yet...

	;; Something happened, try to poll for data.

	JSR	POLL		; Do Status Poll
	JSR	SVSTAT		; Save Status
	JSR	READ		; Do read

	;; If RLEN=0 then determine if error.

	LDA	BURST		; Are we in burst mode?
	BNE	GETERR		; Yes, check for error.
	LDA	DVSTAT		; Get RLEN Again
	BNE	GETDRN		; If RLEN > 1, then drain.
GETERR:	LDY	DVSTAT+3	; Get ext err
	CPY	#136		; EOF?
	BEQ	GETDNE		; Yes, return it.
	LDY	DSTATS		; Else, get DSTATS from status/read.
	CPY	#144		; is it 144?
	BNE	GETDNE		; Nope, simply return it in Y, done.
	LDY	DVSTAT+3	; Get Extended error
	BNE	GETDNE		; Done.

	;; Drain
	
GETDRN:	JSR	DIPRCD		; Disable PROCEED
	JSR	GDIDX		; Get Unit into X again
	DEC	RLEN,X		; Decrement length
	LDY	ROFF,X		; Get Current Offset into X
	LDA	RBUF,Y		; Get next character
	INC	ROFF,X		; Increment cursor
	TAY			; Store in Y for a moment

	;; If RX buffer empty, turn off trip.

	LDA	RLEN,X		; Get RLEN
	BNE	GETDN2		; some left, just go done with success
	STA	TRIP		; Otherwise store 0 into trip
	
GETDN2:	TYA			; Bring back char into A
	LDY	#$01		; 
GETDNE: CPY	#$00		; Reset flag to negative.
	RTS
	
;;; PUT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUT:	JSR	GDIDX		; Get Unit # into X
	LDY	TOFF,X		; Get TX cursor
	STA	TBUF,Y		; Put char into buffer ptd by cursor

	INC	TOFF,X		; Increment TX cursor

	;; Do a FLUSH if EOL or buffer full

	CMP	#EOL		; EOL?
	BEQ	PFLUSH		; Do flush
	CPY	#$7F		; At end of buffer?
	BNE	PUTDON		; Nope, done.
PFLUSH:	JSR	FLUSH		; Do Flush.
PUTDON:	RTS			; We're done.
	
;;; STATUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

STATUS:	JSR	ENPRCD		; Enable PROCEED.

	;; Return cached value if we still have data in RX

	JSR	GDIDX		; Unit into X
	LDA	RLEN,X		; Get RX len
	BNE	STRETC		; Return cached value if RLEN > 0

	LDA	TRIP		; Get TRIP?
	BEQ	STRETC		; No trip? Return cached.

	JSR	POLL		; RLEN = 0, do poll.
	JSR	SVSTAT		; Save DVSTAT values
	JSR	READ		; Do read.
	
STRETC:	LDA	RLEN,X		; Get Saved DVSTAT+0 val
	STA	DVSTAT		; Store into DVSTAT
	LDA	DVS2,X		; Get Saved DVSTAT+2 val
	STA	DVSTAT+2	; Store
	LDA	DVS3,X		; Get Saved DVSTAT+3 val
	STA	DVSTAT+3
	TAY			; copy it into Y for error output.
	
	RTS			; Done.	
	
;;; SPECIAL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPECIAL:
	
	;; Clear Trip

	LDA	#$00
	STA	TRIP

	;; Handle Local Commands

	LDA	ZICCOM
	CMP	#$0F		; 15 = FLUSH
	BNE	SPQ		; No. Handle protocol commands
	JSR	FLUSH		; Yes. Do flush.
	LDY	#$01		; Flush always successful
	JMP	SPCDNE		; We're done.

	;; Handle Protocol commands, do INQDS Query

SPQ:	LDA	#$FF		; Set INQDS
	STA	SPEDCB+2		; To DCOMND
	LDA	ZICDNO		; Get Unit #
	STA	SPEDCB+1	; Store in table
	LDA	ZICCOM		; Get Command
	STA	SPEDCB+10	; Put in AUX1 for query
	LDA	#$01		; 1 byte
	STA	SPEDCB+8	;
	LDA	#$00		;
	STA	SPEDCB+9	;
	LDA	#<INQDS		; Stora INQDS address
	STA	SPEDCB+4	; ...
	LDA	#>INQDS		; ...
	STA	SPEDCB+5
	LDA	#$40		; <-Atari
	STA	SPEDCB+3
	LDA	#<SPEDCB	; Set up SPECIAL DCB TABLE
	LDY	#>SPEDCB	;
	JSR	DOSIOV		; Do Query
	LDY	DSTATS		; Get DSTATS
	BMI	SPCDNE		; SIO error, return in Y. There is no ext err.

	;; We got a query, if it's $FF, return unimplemented.
	LDA	INQDS		; Get the Returned DSTATS value from inquiry
	CMP	#$FF		; Is it $FF ?
	BNE	SPDO		; Nope, let's do it.
	LDY	#146		; ERROR- 146  Unimplemented Command
	JMP	SPCDNE		; Done.

	;; Do the Special, get all IOCB params, push onto stack
	
SPDO:	LDA	ZICDNO		; Unit #
	STA	SPEDCB+1
	LDA	ZICCOM		; Command
	STA	SPEDCB+2
	LDA	INQDS		; Result of Inquiry
	STA	SPEDCB+3
	LDA	ZICBAL		; Ptr to passed in devicespec
	STA	SPEDCB+4
	LDA	ZICBAH		; 
	STA	SPEDCB+5
	LDA #$00
	STA SPEDCB+8
	LDA #$01
	STA SPEDCB+9
	LDA	ZICAX1		; Aux1
	STA	SPEDCB+10
	LDA	ZICAX2		; Aux2
	STA	SPEDCB+11
	LDA	#<SPEDCB
	LDY	#>SPEDCB
	JSR	DOSIOV

	;; Get error and return extended if needed.

	LDY	DSTATS		; Get DSTATS
	CPY	#144		; Is it 144?
	BNE	SPCDNE		; Nope, just return it.

	JSR	POLL		; Get status, for error
	LDY	DVSTAT+3	; Get extended error.
	
SPCDNE:	RTS

SPEDCB .BYTE      DEVIDN  ; DDEVIC
       .BYTE      $FF     ; DUNIT
       .BYTE      $FF     ; DCOMND ; inq
       .BYTE      DSREAD     ; DSTATS
       .WORD      INQDS    ; DBUFL
       .BYTE      $1F     ; DTIMLO
       .BYTE      $00     ; DRESVD
       .BYTE      $01     ; DBYTL
       .BYTE      $00     ; DBYTH
       .BYTE      $FF     ; DAUX1
       .BYTE      $FF     ; DAUX2	
	
	;; End of Handler

;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TRIP	.ds	1		; Interrupt Tripped?
RLEN	.ds	MAXDEV		; RXD Len
ROFF	.ds	MAXDEV		; RXD offset cursor
TOFF	.ds	MAXDEV		; TXD offset cursor
INQDS	.ds	1		; DSTATS to return in inquiry
DVS2	.ds	MAXDEV		; DVSTAT+2 SAVE
DVS3	.ds	MAXDEV		; DVSTAT+3 SAVE
BURST	.ds	1		; Is this operation in burst mode?
	
RBUF	.ds	128		; RXD buffer
TBUF	.ds	128		; TXD buffer
	
HANDLEREND	= *

	RUN	START
	END
