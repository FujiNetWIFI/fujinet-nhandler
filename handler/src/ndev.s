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

PUTREC  =     $09     ; CIO PUTREC
DEVIDN  =     $71     ; SIO DEVID
DSREAD  =     $40     ; FUJI->ATARI
DSWRIT  =     $80     ; ATARI->FUJI
MAXDEV  =     4       ; # OF N: DEVS
EOF     =     $88     ; ERROR 136
EOL     =     $9B     ; EOL CHAR

	;; ORG HERE
	ORG	$2100
	
	;; This is for OS/A+

	RTS			; Immediately exit

;;; RESET HANDLER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.proc resetHandler
	JSR	$FFFF		; Modified for original DOSINI
initVec	= *-2
	LDA	#$FF		; Driver end LO
handlerEndLo = *-1
	STA 	MEMLO
	LDA	#$FF		; Driver end HI
handlerEndHi = *-1
	STA	MEMLO+1
	JSR	IHTBS		; Insert into HATABS
	RTS
.endp	
	
;;; END RESET HANDLER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; INTERRUPT HANDLER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INTR:	LDA	#$01		; set trip to 1
	STA	TRIP
	PLA
	RTI
	
;;; END INTERRUPT HANDLER ;;;;;;;;;;;;;;;;;;;;;;;;

;;; DEVICE HANDLER TABLE ;;;;;;;;;;;;;;;;;;;;;;;;;

DEVHDL:	.WORD	OPEN-1
	.WORD	CLOSE-1
	.WORD	GET-1
	.WORD	PUT-1
	.WORD	STATUS-1
	.WORD	SPECIAL-1
	
;;; HANDLER RUNAD HERE ;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
START:
	LDA	#<HANDLEREND	; Find End of code
	STA	resetHandler.handlerEndLo
	STA	MEMLO
	LDA	#>HANDLEREND
	STA	resetHandler.handlerEndHi
	STA	MEMLO+1
	LDA	DOSINI
	STA	resetHandler.initVec
	LDA	DOSINI+1
	STA	resetHandler.initVec+1

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
	
;;; OPEN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OPEN:	
	JMP	SUCC
	
;;; CLOSE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CLOSE:
	JMP	SUCC
	
;;; GET ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GET:
	JMP	SUCC

;;; PUT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUT:
	JMP	SUCC
	
;;; STATUS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
STATUS:
	JMP	SUCC
	
;;; SPECIAL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SPECIAL:
	JMP	SUCC

	;; End of Handler

;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TRIP	.ds	1
	
HANDLEREND	= *

	RUN	START
	END
