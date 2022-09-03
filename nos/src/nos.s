        ;; nos FujiNet Operating System
        ;; Compile with MADS

        ;; Authors: Thomas Cherryhomes
        ;;   <thom.cherryhomes@gmail.com>
        ;; Michael Sternberg
        ;;   <mhsternberg@gmail.com>
        ;; CURRENT IOCB IN ZERO PAGE

        ;; Optimizations being done by djaybee!
        ;; Thank you so much!

DOSVEC  =   $0A         ; DOSVEC
DOSINI  =   $0C         ; DOSINI

ZIOCB   =   $20         ; ZP IOCB
ZICHID  =   ZIOCB       ; ID
ZICDNO  =   ZIOCB+1     ; UNIT #
ZICCOM  =   ZIOCB+2     ; COMMAND
ZICSTA  =   ZIOCB+3     ; STATUS
ZICBAL  =   ZIOCB+4     ; BUF ADR LOW
ZICBAH  =   ZIOCB+5     ; BUF ADR HIGH
ZICPTL  =   ZIOCB+6     ; PUT ADDR L
ZICPTH  =   ZIOCB+7     ; PUT ADDR H
ZICBLL  =   ZIOCB+8     ; BUF LEN LOW
ZICBLH  =   ZIOCB+9     ; BUF LEN HIGH
ZICAX1  =   ZIOCB+10    ; AUX 1
ZICAX2  =   ZIOCB+11    ; AUX 2
ZICAX3  =   ZIOCB+12    ; AUX 3
ZICAX4  =   ZIOCB+13    ; AUX 4
ZICAX5  =   ZIOCB+14    ; AUX 5
ZICAX6  =   ZIOCB+15    ; AUX 6

LMARGN  =   $52         ; Left margin
FR0     =   $D4         ; Floating Point register 0 (used during Hex->ASCII conversion)
CIX     =   $F2         ; Inbuff cursor
INBUFF  =   $F3         ; Ptr to input buffer ($0580)

;---------------------------------------
; INTERRUPT VECTORS
; AND OTHER PAGE 2 VARS
;---------------------------------------

VPRCED  =   $0202       ; PROCEED VCTR
COLOR2  =   $02C6       ; MODEF BKG C
RUNAD   =   $02E0       ; RUN ADDRESS
INITAD  =   $02E2       ; INIT ADDRESS
MEMLO   =   $02E7       ; MEM LO
DVSTAT  =   $02EA       ; 4 BYTE STATS

;---------------------------------------
; PAGE 3
; DEVICE CONTROL BLOCK (DCB)
;---------------------------------------

DCB     =   $0300       ; BASE
DDEVIC  =   DCB         ; DEVICE #
DUNIT   =   DCB+1       ; UNIT #
DCOMND  =   DCB+2       ; COMMAND
DSTATS  =   DCB+3       ; STATUS/DIR
DBUFL   =   DCB+4       ; BUF ADR L
DBUFH   =   DCB+5       ; BUF ADR H
DTIMLO  =   DCB+6       ; TIMEOUT (S)
DRSVD   =   DCB+7       ; NOT USED
DBYTL   =   DCB+8       ; BUF LEN L
DBYTH   =   DCB+9       ; BUF LEN H
DAUXL   =   DCB+10      ; AUX BYTE L
DAUXH   =   DCB+11      ; AUX BYTE H

HATABS  =   $031A       ; HANDLER TBL

;---------------------------------------
; IOCB'S * 8
;---------------------------------------

IOCB    =   $0340       ; IOCB BASE
ICHID   =   IOCB        ; ID
ICDNO   =   IOCB+1      ; UNIT #
ICCOM   =   IOCB+2      ; COMMAND
ICSTA   =   IOCB+3      ; STATUS
ICBAL   =   IOCB+4      ; BUF ADR LOW
ICBAH   =   IOCB+5      ; BUF ADR HIGH
ICPTL   =   IOCB+6      ; PUT ADDR L
ICPTH   =   IOCB+7      ; PUT ADDR H
ICBLL   =   IOCB+8      ; BUF LEN LOW
ICBLH   =   IOCB+9      ; BUF LEN HIGH
ICAX1   =   IOCB+10     ; AUX 1
ICAX2   =   IOCB+11     ; AUX 2
ICAX3   =   IOCB+12     ; AUX 3
ICAX4   =   IOCB+13     ; AUX 4
ICAX5   =   IOCB+14     ; AUX 5
ICAX6   =   IOCB+15     ; AUX 6

LNBUF   =   $0582       ; Line Buffer (128 bytes)

;---------------------------------------
; HARDWARE REGISTERS
;---------------------------------------

CH      =   $02FC       ; Hardware code for last key pressed
PORTB   =   $D301       ; On XL/XE, used to enable/disable BASIC
PACTL   =   $D302       ; PIA CTRL A

;---------------------------------------
; MATH PACK VECTORS
;---------------------------------------
FASC    =   $D8E6       ; Floating point to ASCII
IFP     =   $D9AA       ; Integer to floating point
;LDBUFA  =   $DA51       ; Set INBUFF to $0580
;SKPSPC  =   $DBA1       ; Increment CIX to next whitespace

;---------------------------------------
; OS ROM VECTORS
;---------------------------------------

CIOV    =   $E456       ; CIO ENTRY
SIOV    =   $E459       ; SIO ENTRY
WARMSV  =   $E474       ; Warmstart entry point
COLDSV  =   $E477       ; Coldstart entry point

;---------------------------------------
; CONSTANTS
;---------------------------------------

GETREC  =   $05         ; CIO CMD TO GET RECORD
PUTREC  =   $09         ; CIO CMD TO PUT RECORD
PUTCHR  =   $0B         ; CIO CMD TO PUT CHAR

DEVIDN  =   $71         ; SIO DEVID
DSREAD  =   $40         ; FUJI->ATARI
DSWRIT  =   $80         ; ATARI->FUJI
MAXDEV  =   4           ; # OF N: DEVS
EOF     =   $88         ; ERROR 136

EOL     =   $9B         ; EOL CHAR
CR      =   $0D         ; Carrige Return
LF      =   $0A         ; Linefeed

ESC_KEY =   $1C         ; Hardware code for ESC

OINPUT  =   $04         ; CIO/SIO direction
OOUTPUT =   $08         ; CIO/SIO direction

; FujiNet SIO command bytes
CMD_DRIVE_CHG       = $01
CMD_CD              = $2C
CMD_COPY            = $A1
CMD_DIR             = $02
CMD_DEL             = $21
CMD_LOAD            = $28
CMD_LOCK            = $23
CMD_MKDIR           = $2A
CMD_NPWD            = $30
CMD_NTRANS          = 'T'
CMD_RENAME          = $20
CMD_RMDIR           = $2B
CMD_SOURCE          = $F0
CMD_TYPE            = $F0
CMD_UNLOCK          = $24
CMD_CAR             = $F0
CMD_CLS             = $F0
CMD_COLD            = $F0
CMD_HELP            = $F0
CMD_NOBASIC         = $F0
CMD_NOSCREEN        = $F0
CMD_PRINT           = $F0
CMD_REENTER         = $F0
CMD_REM             = $F0
CMD_RUN             = $F0
CMD_SCREEN          = $F0
CMD_WARM            = $F0

;;; Macros ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .MACRO DCBC
        .LOCAL
        LDY     #$0C
?DCBL   LDA     %%1,Y
        STA     DCB,Y
        DEY
        BPL     ?DCBL
        .ENDL
        .ENDM

;;; Initialization ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ORG     $0700
        OPT     h-

HDR:    .BYTE   $00                 ; BLFAG: Boot flag equals zero (unused)
        .BYTE   [PGEND-HDR]/128-2   ; BRCNT: Number of consecutive sectors to read
        .WORD   $0700               ; BLDADR: Boot sector load address ($700).
        .WORD   $E4C0               ; BIWTARR: Init addr (addr of RTS in ROM)

START:  LDA     DOSINI
        STA     RESET+1
        LDA     DOSINI+1
        STA     RESET+2

        LDA     #<RESET
        STA     DOSINI
        LDA     #>RESET
        STA     DOSINI+1
        LDA     #<DOS       ; Point to DOS & CP below
        STA     DOSVEC
        LDA     #>DOS
        STA     DOSVEC+1

        JSR     ALTMEML     ; Alter MEMLO
        RTS

RESET:  JSR     $FFFF       ; Jump to extant DOSINI

        LDA     #'N'
        STA     RBUF
        JSR     IHTBS       ; Insert into HATABS

        LDA     #'D'
        STA     RBUF
        JSR     IHTBS       ; Clone N: as D: for compatibility

;---------------------------------------
;  Alter MEMLO
;---------------------------------------
ALTMEML:
        LDA     #<PGEND
        STA     MEMLO
        LDA     #>PGEND
        STA     MEMLO+1

        ;; Back to DOS

        RTS

;---------------------------------------
; Insert entry into HATABS
;---------------------------------------

IHTBS:
        LDY     #$00
IH1     LDA     HATABS,Y
        BEQ     HFND
        ;CMP     #'N'
        CMP     RBUF
        BEQ     HFND
        INY
        INY
        INY
        CPY     #11*3
        BCC     IH1

        ;; Found a slot

HFND:
        ;LDA     #'N'
;--
        LDA     RBUF
        TAX
;--
        STA     HATABS,Y
        LDA     #<CIOHND
        STA     HATABS+1,Y
        LDA     #>CIOHND
        STA     HATABS+2,Y

        CPX     #'D'
        BEQ     HATABS_CONT
        RTS

HATABS_CONT:
        ;; And we're done with HATABS

        ;; Query FUJINET

        JSR     STPOLL

        ;; Output Ready/Error

OBANR:
        LDX     #$00        ; IOCB #0
        LDA     #PUTREC
        STA     ICCOM,X
        LDA     #$28        ; 40 CHARS Max
        STA     ICBLL,X
        TXA
        STA     ICBLH,X
        LDA     DSTATS      ; Check DSTATS
        BPL     OBRDY       ; < 128 = Ready

        ;; Status returned error.

OBERR:
        LDA     #<BERROR
        LDY     #>BERROR
        BVC     OBCIO

        ;; Status returned ready.

OBRDY:
        LDA     #<BREADY
        LDY     #>BREADY

OBCIO:
        STA     ICBAL,X
        TYA
        STA     ICBAH,X

        JSR     CIOV

        ;; Vector in proceed interrupt

SPRCED:
        LDA     #<PRCVEC
        STA     VPRCED
        LDA     #>PRCVEC
        STA     VPRCED+1

        ;; And we are done, back to DOS.
        CLC
        RTS

;;; End Initialization Code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Copy command's template DCB struct to OS's DCB struct (12 bytes)
DOSIOV:
        STA     DODCBL+1
        STY     DODCBL+2
        LDY     #$0C
DODCBL  LDA     $FFFF,Y
        STA     DCB,Y
        DEY
        BPL     DODCBL

SIOVDST:
        JSR     SIOV
        LDY     DSTATS
        TYA
        RTS


;---------------------------------------
; CIO OPEN
;---------------------------------------

OPEN:
        ;; Prepare DCB

        JSR     GDIDX       ; Get Device ID in X (0-3)
        LDA     ZICDNO      ; IOCB UNIT # (1-4)
        STA     OPNDCB+1    ; Store in DUNIT
        LDA     ZICBAL      ; Get filename buffer
        STA     OPNDCB+4    ; stuff in DBUF
        LDA     ZICBAH      ; ...
        STA     OPNDCB+5    ; ...
        LDA     ZICAX1      ; Get desired AUX1/AUX2
        STA     OPNDCB+10   ; Save them, and store in DAUX1/DAUX2
        LDA     ZICAX2      ; ...
        STA     OPNDCB+11   ; ...

        ;;  Copy DCB template to DCB

        LDA     #<OPNDCB
        LDY     #>OPNDCB

        ;;  Send to #FujiNet

        JSR     DOSIOV

        ;; Return DSTATS, unless 144, then get extended error

OPCERR:
        CPY     #$90        ; ERR 144?
        BNE     OPDONE      ; NOPE. RETURN DSTATS

        ;; 144 - get extended error

        JSR     STPOLL      ; POLL FOR STATUS
        LDY     DVSTAT+3

       ; RESET BUFFER LENGTH + OFFSET

OPDONE:
        LDA     #$01
        STA     TRIP
        JSR     GDIDX
        LDA     #$00
        STA     RLEN,X
        STA     TOFF,X
        STA     ROFF,X
        TYA
        RTS                ; AY = ERROR

OPNDCB:
        .BYTE   DEVIDN  ; DDEVIC
        .BYTE   $FF     ; DUNIT
        .BYTE   'O'     ; DCOMND
        .BYTE   $80     ; DSTATS
        .BYTE   $FF     ; DBUFL
        .BYTE   $FF     ; DBUFH
        .BYTE   $0F     ; DTIMLO
        .BYTE   $00     ; DRESVD
        .BYTE   $00     ; DBYTL
        .BYTE   $01     ; DBYTH
        .BYTE   $FF     ; DAUX1
        .BYTE   $FF     ; DAUX2

; End CIO OPEN
;---------------------------------------

;---------------------------------------
; CIO CLOSE 
;---------------------------------------

CLOSE:
        JSR     DIPRCD      ; Disable Interrupts
        JSR     GDIDX
        JSR     PFLUSH      ; Do a Put Flush if needed.

        LDA     ZICDNO      ; IOCB Unit #
        STA     CLODCB+1    ; to DCB...

        LDA     #<CLODCB
        LDY     #>CLODCB

        JMP     DOSIOV

CLODCB .BYTE    DEVIDN      ; DDEVIC
       .BYTE    $FF         ; DUNIT
       .BYTE    'C'         ; DCOMND
       .BYTE    $00         ; DSTATS
       .BYTE    $00         ; DBUFL
       .BYTE    $00         ; DBUFH
       .BYTE    $0F         ; DTIMLO
       .BYTE    $00         ; DRESVD
       .BYTE    $00         ; DBYTL
       .BYTE    $00         ; DBYTH
       .BYTE    $00         ; DAUX1
       .BYTE    $00         ; DAUX2

; End CIO CLOSE
;---------------------------------------

;---------------------------------------
; CIO GET
;---------------------------------------

GET:    JSR     GDIDX       ; IOCB UNIT #-1 into X
        LDA     RLEN,X      ; Get # of RX chars waiting
        BNE     GETDISC     ; LEN > 0?

        ;; If RX buffer is empty, get # of chars waiting...

        JSR     STPOLL      ; Status Poll
        JSR     GDIDX       ; IOCB UNIT -1 into X (because Poll trashes X)
        LDA     DVSTAT      ; # of bytes waiting (0-127)
        STA     RLEN,X      ; Store in RX Len
        BEQ     RETEOF

GETDO:  LDA     ZICDNO      ; Get IOCB UNIT #
        STA     GETDCB+1    ; Store into DUNIT
        LDA     DVSTAT      ; # of bytes waiting
        STA     GETDCB+8    ; Store into DBYT...
        STA     GETDCB+10   ; and DAUX1...

        LDA     #<GETDCB
        LDY     #>GETDCB

        JSR     DOSIOV

        ;; Clear the Receive buffer offset.

        JSR     GDIDX       ; IOCB UNIT #-1 into X
        LDA     #$00
        STA     ROFF,X

GETDISC:
        ;LDA     DVSTAT+2    ; Did we disconnect?
        LDA     DVSTAT+3    ; Did we disconnect?
        BNE     GETUPDP     ; nope, update the buffer cursor.

        ;; We disconnected, emit an EOF.

RETEOF:
        LDY     #EOF
        TYA
        RTS                 ; buh-bye.

GETUPDP:
        DEC     RLEN,X      ; Decrement RX length.
        LDY     ROFF,X      ; Get RX offset cursor.

        ;; Return Next char from appropriate RX buffer.

        LDA     RBUF,Y

        ;; Increment RX offset

GX:     INC     ROFF,X      ; Increment RX offset.
        TAY                 ; stuff returned val into Y temporarily.

        ;; If requested RX buffer is empty, reset TRIP.

        LDA     RLEN,X
        BNE     GETDONE
        STA     TRIP

        ;; Return byte back to CIO.

GETDONE:
        TYA                 ; Move returned val back.
        LDY     #$01        ; SUCCESS

        RTS                 ; DONE...

GETDCB:
       .BYTE    DEVIDN      ; DDEVIC
       .BYTE    $FF         ; DUNIT
       .BYTE    'R'         ; DCOMND
       .BYTE    $40         ; DSTATS
       .BYTE    <RBUF       ; DBUFL
       .BYTE    >RBUF       ; DBUFH
       .BYTE    $0F         ; DTIMLO
       .BYTE    $00         ; DRESVD
       .BYTE    $FF         ; DBYTL
       .BYTE    $00         ; DBYTH
       .BYTE    $FF         ; DAUX1
       .BYTE    $00         ; DAUX2

; End CIO GET
;---------------------------------------

;---------------------------------------
; CIO PUT
;---------------------------------------

PUT:    ;; Add to TX buffer.

        JSR     GDIDX
        LDY     TOFF,X      ; GET TX cursor.
        STA     TBUF,Y      ; TX Buffer

POFF:   INC     TOFF,X      ; Increment TX cursor
        LDY     #$01        ; SUCCESSFUL

        ;; Do a PUT FLUSH if EOL or buffer full.

        CMP     #EOL        ; EOL?
        BEQ     FLUSH       ; FLUSH BUFFER
        JSR     GDIDX       ; GET OFFSET
        LDA     TOFF,X
        CMP     #$7F        ; LEN = $FF?
        BEQ     FLUSH       ; FLUSH BUFFER
        RTS

       ; FLUSH BUFFER, IF ASKED.

FLUSH:  JSR     PFLUSH      ; FLUSH BUFFER
        RTS

PFLUSH:

       ; CHECK CONNECTION, AND EOF
       ; IF DISCONNECTED.

        JSR     STPOLL      ; GET STATUS
        LDA     DVSTAT+3
        BEQ     RETEOF

PF1:    JSR     GDIDX       ; GET DEV X
        LDA     TOFF,X
        BNE     PF2
        JMP     PDONE

       ; FILL OUT DCB FOR PUT FLUSH

PF2:    LDA     ZICDNO
        STA     PUTDCB+1

       ; FINISH DCB AND DO SIOV

TBX:    LDA     TOFF,X
        STA     PUTDCB+8
        STA     PUTDCB+10

        LDA     #<PUTDCB
        LDY     #>PUTDCB
        JSR     DOSIOV

        ; CLEAR THE OFFSET CURSOR
        ; AND LENGTH

        JSR     GDIDX
        LDA     #$00
        STA     TOFF,X

PDONE:  LDY     #$01
        RTS

PUTDCB .BYTE    DEVIDN      ; DDEVIC
       .BYTE    $FF         ; DUNIT
       .BYTE    'W'         ; DCOMND
       .BYTE    $80         ; DSTATS
       .BYTE    $80         ; DBUFL
       .BYTE    >TBUF       ; DBUFH
       .BYTE    $0F         ; DTIMLO
       .BYTE    $00         ; DRESVD
       .BYTE    $FF         ; DBYTL
       .BYTE    $00         ; DBYTH
       .BYTE    $FF         ; DAUX1
       .BYTE    $00         ; DAUX2

; End CIO PUT
;---------------------------------------

;---------------------------------------
; CIO STATUS 
;---------------------------------------

STATUS: JSR     ENPRCD      ; ENABLE PRCD
        JSR     GDIDX       ; GET DEVICE#
        LDA     RLEN,X      ; GET RLEN
        BNE     STSLEN      ; RLEN > 0?
        LDA     TRIP
        BNE     STTRI1      ; TRIP = 1?

        ; NO TRIP, RETURN SAVED LEN

STSLEN: LDA     RLEN,X      ; GET RLEN
        STA     DVSTAT      ; RET IN DVSTAT

        ; If you don't need to preserve Y then use it instead of A
        LDA     #$00
        STA     DVSTAT+1

        ; and INY here
        LDA     #$01
        STA     DVSTAT+2
        STA     DVSTAT+3

        BNE     STDONE

        ; DO POLL AND UPDATE RCV LEN

STTRI1: JSR     STPOLL      ; POLL FOR ST
        STA     RLEN,X

        ; UPDATE TRIP FLAG

STTRIU: BNE     STDONE
        STA     TRIP        ; RLEN = 0

        ; RETURN CONNECTED? FLAG.

STDONE: LDA     DVSTAT+2
        LDY     #$01
        RTS

       ; ASK FUJINET FOR STATUS

STPOLL:
        LDA     ZICDNO      ; IOCB #
        STA     STADCB+1

        LDA     #<STADCB
        LDY     #>STADCB

        JSR     DOSIOV

        ;; > 127 bytes? make it 127 bytes.

        LDA     DVSTAT+1
        BNE     STADJ
        LDA     DVSTAT
        BMI     STADJ
        BVC     STP2        ; <= 127 bytes...

STADJ   LDA     #$7F
        STA     DVSTAT
        
        STA     DVSTAT+1

       ; A = CONNECTION STATUS

STP2:   LDA     DVSTAT+2
        RTS

STADCB: .BYTE   DEVIDN      ; DDEVIC
        .BYTE   $FF         ; DUNIT
        .BYTE   'S'         ; DCOMND
        .BYTE   $40         ; DSTATS
        .BYTE   <DVSTAT     ; DBUFL
        .BYTE   >DVSTAT     ; DBUFH
        .BYTE   $0F         ; DTIMLO
        .BYTE   $00         ; DRESVD
        .BYTE   $04         ; DBYTL
        .BYTE   $00         ; DBYTH
        .BYTE   $00         ; DAUX1
        .BYTE   $00         ; DAUX2

; End CIO STATUS
;---------------------------------------

;---------------------------------------
; CIO SPECIAL
;---------------------------------------

SPEC:   ; HANDLE LOCAL COMMANDS.

        LDA     ZICCOM
        CMP     #$0F        ; 15 = FLUSH
        BNE     S1          ; NO.
        JSR     PFLUSH      ; DO FLUSH
        LDY     #$01        ; SUCCESS
        RTS

S1:     CMP     #40         ; 40 = LOAD AND EXECUTE
        BEQ     S2          ; YES.
        JMP     S3          ; NO. SKIP OVER spec40

S2:     RTS
       ; HANDLE SIO COMMANDS.
       ; GET DSTATS FOR COMMAND
S3:
        LDA     ZICDNO
        STA     SPEDCB+1
        LDA     ZICCOM
        STA     SPEDCB+10

        LDA     #<SPEDCB
        LDY     #>SPEDCB
        JSR     DOSIOV

        BMI     :DSERR

       ; WE GOT A DSTATS INQUIRY
       ; IF $FF, THE COMMAND IS
       ; INVALID

DSOK:   LDA     INQDS
        CMP     #$FF        ; INVALID?
        BNE     DSGO        ; DO THE CMD
        LDY     #$92        ; UNIMP CMD
        TYA
DSERR:
        RTS

        ;; Do the special, since we want to pass in all the IOCB
        ;; Parameters to the DCB, This is being done long-hand.

DSGO:   LDA     ZICCOM
        PHA
        LDA     #$00
        PHA
        LDA     INQDS
        PHA
        LDA     #$01
        PHA
        LDA     ZICBAL
        PHA
        LDA     ZICAX1
        PHA
        LDA     ZICBAH
        PHA
        LDA     ZICAX2
        PHA
        LDY     #$03
DSGOL:
        PLA
        STA     DBYTL,Y
        PLA
        STA     DCOMND,Y
        DEY
        BPL     DSGOL

        JMP     SIOVDST

        ;; Return DSTATS in Y and A

SPEDCB  .BYTE   DEVIDN      ; DDEVIC
        .BYTE   $FF         ; DUNIT
        .BYTE   $FF         ; DCOMND ; inq
        .BYTE   $40         ; DSTATS
        .BYTE   <INQDS      ; DBUFL
        .BYTE   >INQDS      ; DBUFH
        .BYTE   $0F         ; DTIMLO
        .BYTE   $00         ; DRESVD
        .BYTE   $01         ; DBYTL
        .BYTE   $00         ; DBYTH
        .BYTE   $FF         ; DAUX1
        .BYTE   $FF         ; DAUX2

; End CIO SPECIAL
;---------------------------------------

;#######################################
;#                                     #
;#             CIO Functions           # 
;#                                     #
;#######################################


;---------------------------------------
CIOCLOSE:
;---------------------------------------
    ; X must contain IOCB offset ($10,$20,..)
        LDA     #$0C            ; Close #1 first
        STA     ICCOM,X
        JMP     CIOV

;---------------------------------------
CIOOPEN:
;---------------------------------------
    ; Input: 
    ; X = IOCB offset ($10,$20,..)
    ; Y = data direction (4=inp,8=out,12=i/o)
    ; INBUFF contains ICBAL/H
        LDA     #$03            ; 3 = CIO 'OPEN FILE'
        STA     ICCOM,X
        LDA     INBUFF          ; Pointer to filename
        STA     ICBAL,X
        LDA     INBUFF+1        ; Pointer to filename
        STA     ICBAH,X
        TYA
        STA     ICAX1,X         ; Data direction
        LDA     #$00
        STA     ICAX2,X         ; Unused
        JSR     CIOV            ; Call CIO

CIOOPEN_DONE:
        RTS

;---------------------------------------
CIOSTATUS:
;---------------------------------------
        LDA     #$0D
        STA     ICCOM,X
        JSR     CIOV
        BPL     CIOSTATUS_DONE
        JSR     PRINT_ERROR

CIOSTATUS_DONE:
        RTS
        

;---------------------------------------
CIOGET:
;---------------------------------------
    ; Input: 
    ; X = IOCB offset ($10,$20,..)
    ; A = ICBLL
    ; Y = ICBLH
    ; INBUFF contains ICBAL/H
        PHA                 ; Stash Buffer length Lo
        LDA     #$07        ; GET BYTES command
        STA     ICCOM,X
        LDA     INBUFF      ; Get buffer addr from pointer
        STA     ICBAL,X
        LDA     INBUFF+1
        STA     ICBAH,X
        PLA                 ; Retrieve Buffer length Lo
        STA     ICBLL,X
        TYA                 ; Get Buffer length Hi
        STA     ICBLH,X
        JSR     CIOV        ; Bon voyage
        BPL     CIOGET_DONE
;        JMP     PRINT_ERROR

CIOGET_DONE:
        RTS

;---------------------------------------
CIOPUT:
;---------------------------------------
    ; Input: 
    ; X = IOCB offset ($10,$20,..)
    ; A = ICBLL
    ; Y = ICBLH
    ; INBUFF contains ICBAL/H
        PHA                 ; Stash Buffer length Lo
        LDA     #$0B        ; PUT BYTES command
        STA     ICCOM,X
        LDA     INBUFF      ; Get buffer addr from pointer
        STA     ICBAL,X
        LDA     INBUFF+1
        STA     ICBAH,X
        PLA                 ; Retrieve Buffer length Lo
        STA     ICBLL,X
        TYA                 ; Get Buffer length Hi
        STA     ICBLH,X
        JSR     CIOV        ; Bon voyage
        BPL     CIOPUT_DONE
;        JMP     PRINT_ERROR

CIOPUT_DONE:
        RTS

;---------------------------------------
CIOGETREC:
;---------------------------------------
    ; Input: 
    ; X = IOCB offset ($10,$20,..)
    ; A = ICBLL
    ; Y = ICBLH
    ; INBUFF contains ICBAL/H
        PHA                 ; Stash Buffer length Lo
        LDA     #$05        ; GET RECORD command
        STA     ICCOM,X
        LDA     INBUFF      ; Get buffer addr from pointer
        STA     ICBAL,X
        LDA     INBUFF+1
        STA     ICBAH,X
        PLA                 ; Retrieve Buffer length Lo
        STA     ICBLL,X
        TYA                 ; Get Buffer length Hi
        STA     ICBLH,X
        JSR     CIOV        ; Bon voyage
        BPL     CIOGETREC_DONE
;        JMP     PRINT_ERROR

CIOGETREC_DONE:
        RTS

;#######################################
;#                                     #
;#          Utility Functions          #
;#                                     #
;#######################################
        ; ENABLE PROCEED INTERRUPT

ENPRCD: LDA     PACTL
        ORA     #$01        ; ENABLE BIT 0
        STA     PACTL
        RTS

       ; DISABLE PROCEED INTERRUPT

DIPRCD: LDA     PACTL
        AND     #$FE        ; DISABLE BIT0
        STA     PACTL
        RTS

       ; GET ZIOCB DEVNO - 1 INTO X

GDIDX:  LDX     ZICDNO      ; IOCB UNIT #
        DEX                 ; - 1
        RTS

;---------------------------------------
; Proceed Vector
;---------------------------------------

PRCVEC: LDA     #$01
        STA     TRIP
        PLA
        RTI

; End Proceed Vector
;---------------------------------------

;---------------------------------------
; Reset LNBUF
;---------------------------------------
; Normally this routine is at $DA51
; But some programs will bank-switch
; that portion of ROM to RAM
;---------------------------------------

LDBUFA: LDA     #$05
        STA     INBUFF+1
;        LDA     #$80
        LDA     #$82
        STA     INBUFF
        RTS

; End Reset LNBUF
;---------------------------------------

;---------------------------------------
; Skip spaces
;---------------------------------------
; Normally this routine is at $DBA1
; But some programs will bank-switch
; that portion of ROM to RAM
;---------------------------------------

SKPSPC: LDY     CIX
        LDA     #$20
@:      CMP     (INBUFF),Y
        BNE     @+
        INY
        BNE     @-
@:      STY     CIX
        RTS

; End SKPSPC
;---------------------------------------

;---------------------------------------
; Print EOL-terminated string
; A: String Buffer Lo
; Y: String Buffer Hi
;---------------------------------------
PRINT_STRING:

        LDX     #$00
    ;---------------------------------------
    ; String Buffer
    ;---------------------------------------
        STA     ICBAL,X
        TYA
        STA     ICBAH,X

    ;---------------------------------------
    ; String Length
    ;---------------------------------------
        LDA     #$80
        STA     ICBLL,X
        LDA     #$00
        STA     ICBLH,X

    ;---------------------------------------
    ; Call to CIO
    ;---------------------------------------
        LDA     #PUTREC
        STA     ICCOM,X
        JMP     CIOV

;---------------------------------------
; Print integer error number from DOSIOV
; Y: Return code from DOSIOV
;---------------------------------------
PRINT_ERROR:
        CPY     #$01        ; Exit if success (1)
        BEQ     PRINT_ERROR_DONE

    ;-----------------------------------
    ; If error code = 144, then get
    ; extended code from DVSTAT
    ;-----------------------------------
        CPY     #144
        BNE     PRINT_ERROR_NEXT

        LDA     #<STADCB
        LDY     #>STADCB
        JSR     DOSIOV
        LDY     DVSTAT+3    ;

PRINT_ERROR_NEXT:
    ;-----------------------------------
    ; Convert error code to ASCII
    ;-----------------------------------
        STY     FR0
        LDA     #$00
        STA     FR0+1
        JSR     IFP         ; Convert error from int to floating point
        JSR     FASC        ; Convert floating point to ASCII

    ;---------------------------------------
    ; Find last char in ASCII error (noted by high bit)
    ; Unset high bit & append EOL
    ;---------------------------------------
        LDY     #$FF        ; Init counter = 0

@       INY
        LDA     (INBUFF),Y
        CMP     #$80
        BCC     @-

        AND     #$7F        ; Clear high bit
        STA     (INBUFF),Y
        INY
        LDA     #EOL        ; Append EOL
        STA     (INBUFF),Y

        LDA     INBUFF
        LDY     INBUFF+1
        JMP     PRINT_STRING

PRINT_ERROR_DONE:
        RTS

; End Utility Functions
;---------------------------------------


;#######################################
;#                                     #
;#       COMMAND PROCESSOR (CP)        #
;#                                     #
;#######################################

;---------------------------------------
; DOS Entry point
;---------------------------------------

DOS:    JSR     CP          ; Command Processor
        JMP     DOS         ; Keep looping

;---------------------------------------
; Main loop
;---------------------------------------

CP:
        LDA     #$FF        ; Clear command
        STA     CMD

        JSR     SHOWPROMPT
        JSR     GETCMD
        JSR     PARSECMD
        BMI     CP_DONE     ; Skip DOCMD if CMD == $FF
        JSR     DOCMD
CP_DONE:
        RTS

;---------------------------------------
; Show Command Prompt (Nn:)
; Leading EOF requires special CIOV call
;---------------------------------------

;---------------------------------------
SHOWPROMPT:
;---------------------------------------

        LDA     DOSDR       ; Get the 1,2,... for N1,N2,...
        ORA     #'0'        ; Convert, say, 1 to '1'
        STA     PRMPT+2     ; Store in after EOL and N

        LDX     #$00
        LDA     #PUTCHR
        STA     ICCOM,X

        LDA     #<PRMPT
        STA     ICBAL,X
        LDA     #>PRMPT

        STA     ICBAH,X
        LDA     #4          ; Prompt length = 4
        STA     ICBLL,X
        TXA                 ; Still zero
        STA     ICBLH,X

        JMP     CIOV

;---------------------------------------
GETCMD:
;---------------------------------------
        LDX     #$00
        LDA     #GETREC
        STA     ICCOM,X
        LDA     #<LNBUF
        STA     ICBAL,X
        LDA     #>LNBUF
        STA     ICBAH,X
        LDA     #$7F
        STA     ICBLL,X
        JSR     CIOV

GETCMDTEST:
        LDY #$00
        STY CIX
        JSR LDBUFA      ; Reset LNBUF to $0580
        JSR SKPSPC      ; Advance CIX to next space

    ;---------------------------------------
    ; CMDSEP is an sequence of bytes contains
    ; indexes to chars following spaces
    ; Iterate to clear CMDSEP bytes
    ;---------------------------------------
        TYA                 ; A = 0
        LDX     #$02        ; for X = 2 to 0 step -1
GETLOOP:
        STA     CMDSEP,X
        DEX
        BPL     GETLOOP     ; next X

    ; Initial Delimiter to space
        LDA     #' '
        STA     DELIM

    ;---------------------------------------
    ; Loop until EOL is encountered
    ;---------------------------------------
        INX                 ; Reset X to 0
GETCMD_LOOP:
        LDA     (INBUFF),Y
        CMP     #EOL        ; Found EOL?
        BEQ     GETCMD_DONE ; yes. skip
        CMP     DELIM       ; Found space?
        BEQ     GETCMD_REPL ; yes. Replace it
        INY
        BNE     GETCMD_LOOP ; "always" non-zero

    ;---------------------------------------
    ; March through the cmd line and note
    ; the positions of any args as delimited
    ; by spaces or quotes. positions saved
    ; in CMDSEP,X
    ;---------------------------------------
GETCMD_REPL:
        LDA     #EOL
        STA     (INBUFF),Y
        INY
        LDA     (INBUFF),Y  ; Skip any run of spaces
        CMP     #' '
        BEQ     GETCMD_REPL ; Keep skipping spaces

    ; Here if any run of spaces has ended
    ; Are we standing on a double-quote?
        CMP     #'"'
        BNE     GETCMD_WR_OFFSET  ; No. Skip ahead

    ; Here if curr char is a double-quote
        INY                 ; Advance the command line index
        LDA     #'"'        ; Is the curr delim a double-quote?
        CMP     DELIM       ; If not, change delim to double-quote
        BNE     GETCMD_DQ_DELIM

    ; Here if curr delim is a double-quote
    ; Switch delim to space
        LDA     #' '
        STA     DELIM
        BNE     GETCMD_WR_OFFSET

    ; Here if curr delim is space
    ; Switch delim to double-quote
GETCMD_DQ_DELIM:
        STA     DELIM

    ; Note the position for the curr command-line arg
GETCMD_WR_OFFSET:
        TYA
        STA     CMDSEP,X
        INX
        CPX     #$03
        BCC     GETCMD_LOOP ; Continue searching

GETCMD_DONE:
        RTS

CMDSEP: .BYTE $FF,$FF,$FF
DELIM:  .BYTE ' '

;---------------------------------------
PARSECMD:
;---------------------------------------
        LDA     LNBUF
        CMP     #EOL        ; Quit immediately if no cmd
        BEQ     PARSECMD_DONE

        JSR     PARSE_INTRINSIC_COMMAND
        JSR     PARSE_DRIVE_CHANGE
        JSR     PRINT_UNK_CMD
PARSECMD_DONE:
        RTS

PRINT_UNK_CMD:
        LDA     CMD
        CMP     #$FF
        BNE     PRINT_UNK_CMD_DONE
        LDA     #<UNK_CMD_ERR
        LDY     #>UNK_CMD_ERR
        JSR     PRINT_STRING
PRINT_UNK_CMD_DONE:
        RTS

UNK_CMD_ERR:
        .BYTE   'CMD?',EOL

;---------------------------------------
PARSE_INTRINSIC_COMMAND:
;---------------------------------------
        LDX     #$00        ; Initialize X for command code indexing
        LDY     #$00
        STY     CIX
        JSR     LDBUFA      ; Set INBUFF to $0580
        JSR     SKPSPC      ; Skip whitespace

PARSE_INTRINSIC_NEXT_CHAR:
        LDA     (INBUFF),Y
        AND     #$7F
        EOR     COMMAND,X   ; X initialized to 0 in caller
        INY
        ASL
        BEQ     PARSE_INTRINSIC_CHAR_OK

        ; Skip to next command

PARSE_INTRINSIC_NEXT_COMMAND:
        LDA     COMMAND,X
        ASL
        INX
        BCC     PARSE_INTRINSIC_NEXT_COMMAND
        LDY     CIX
        CPX     #COMMAND_SIZE

PARSE_INTRINSIC_CHAR_OK:
        INX
        BCC     PARSE_INTRINSIC_NEXT_CHAR
        STY     CIX
        LDA     (INBUFF),Y
        BMI     PARSE_INTRINSIC_RET

        JSR     SKPSPC

PARSE_INTRINSIC_RET_ERROR:
        LDX     #COMMAND_SIZE+1
PARSE_INTRINSIC_RET:
        LDA     COMMAND,X
        STA     CMD
        STA     CMDPRV
PARSE_INTRINSIC_DONE:
        RTS

; End of PARSE_INTRINSIC_COMMAND
;---------------------------------------

;---------------------------------------
PARSE_DRIVE_CHANGE:
;---------------------------------------
        LDX     #$03        ; Check for EOL in pos 3
        LDA     LNBUF,X
        CMP     #EOL
        BNE     PARSE_DRIVE_CHANGE_DONE
        DEX                 ; go back one char
        LDA     LNBUF,X
        CMP     #':'        ; Check for colon.
        BNE     PARSE_DRIVE_CHANGE_DONE
        LDA     #CMD_IDX.DRIVE_CHG
        STA     CMD
PARSE_DRIVE_CHANGE_DONE:
        RTS

;---------------------------------------
DOCMD:
;---------------------------------------
        LDX     CMD
        BMI     DOCMD_DONE      ; Unassigned command = $FF
        LDA     CMD_TAB_H,X     ; Get hi-byte of subroutine's addr
        PHA                     ; Push it to the stack
        LDA     CMD_TAB_L,X     ; Get lo-byte of subroutine's addr
        PHA                     ; Push it to the stack
DOCMD_DONE:
        RTS                     ; Use stack & RTS to jump to subroutine

; End of DOCMD
;---------------------------------------

;---------------------------------------
DO_DRIVE_CHG:
;---------------------------------------
        LDA     LNBUF
        STA     PRMPT+1
        LDA     LNBUF+1
        CMP     #'1'        ; Skip if '0' or less
        BCC     DO_DRIVE_CHG_ERROR
        CMP     #'9'        ; Skip if '9' or more
        BCS     DO_DRIVE_CHG_ERROR
        AND     #$0F        ; Convert, say, to 1-8
        STA     DOSDR
        RTS
DO_DRIVE_CHG_ERROR:
        LDA     #<CDERR
        LDY     #>CDERR
        JMP     PRINT_STRING

; End of DOCMD

;---------------------------------------
; Returns DOSDR in X
; If arg1 contains Nn: then reg X = n
; Otherwise X = DOSDR (from curr prompt)
;---------------------------------------
GET_DOSDR:
;---------------------------------------

        JSR     LDBUFA      ; Reset INBUFF to LNBUF
        LDX     DOSDR       ; Set DUNIT(X) to curr drive

    ;---------------------------------------
    ; Consider arg1 = N2:TNFS://localhost/
    ; Check arg1 for ":" in 3rd position
    ; if found then use char in 2nd position ('2') as DOSDR
    ; First, change INBUFF to point to beg. of 1st arg
    ;---------------------------------------
        LDA     CMDSEP              ; arg offset
        BEQ     GET_DOSDR_DONE      ; first, if arg1 not pop, leave X as-is & quit

        CLC                         ; Advance pointer to LNBUF
        ADC     INBUFF
        STA     INBUFF
        BCC     GET_DOSDR_NEXT
        INC     INBUFF+1

GET_DOSDR_NEXT:
        LDY     #$02            ; Check for ':' in 3rd pos
        LDA     (INBUFF),Y
        CMP     #':'
        BNE     GET_DOSDR_DONE  ; Not found, skip & use default
        DEY
        LDA     (INBUFF),Y
        AND     #$0F            ; Convert, say, '2' to 2
        TAX                     ; Return DOSDR in X

GET_DOSDR_DONE:
        RTS

;---------------------------------------
DO_GENERIC:
;---------------------------------------

    ;---------------------------------------
    ; SIO call for NCD,{MK,RM}DIR,DEL,RENAME
    ;---------------------------------------

    ;---------------------------------------
    ; Get Fujinet SIO command (~ $21 for DEL)
    ; X = table index from caller
    ;---------------------------------------
        LDA     CMD_DCOMND,X
        STA     GENDCB+2

    ;---------------------------------------
    ; Get DOSDR from either arg1 or curr drive
    ;---------------------------------------
        JSR     GET_DOSDR    ; X will contain int of n in Nn:
        STX     GENDCB+1
        JSR     PREPEND_DRIVE

    ;---------------------------------------
    ; If this is NCD ensure a '/' char is the last char
    ;---------------------------------------
        LDA     GENDCB+2
        CMP     #CMD_CD         ; Is this an NCD command?
        BNE     DO_GENERIC_NEXT ; No. skip

        LDA     CMDSEP
        BEQ     NCD_ERROR
        JSR     APPEND_SLASH    ; Append '/' to path if missing

DO_GENERIC_NEXT:
    ;---------------------------------------
    ; Populate the DCB
    ;---------------------------------------
        LDA     DOSDR
        STA     STADCB+1
        LDA     INBUFF
        STA     GENDCB+4
        LDA     INBUFF+1
        STA     GENDCB+5

    ;---------------------------------------
    ; Send the command to FujiNet
    ;---------------------------------------
        LDA     #<GENDCB
        LDY     #>GENDCB
        JSR     DOSIOV
        JSR     PRINT_ERROR

GEN_UNMOUNT:
    ;---------------------------------------
    ; if DEL or RENAME, then remount drive
    ;---------------------------------------
        LDA     CMDPRV
        CMP     #CMD_IDX.DEL
        BEQ     GEN_REMOUNT
        CMP     #CMD_IDX.RENAME
        BNE     GENDONE
GEN_REMOUNT:
        JMP     REMOUNT_DRIVE

GENDONE:
        RTS

;---------------------------------------
NCD_ERROR:
;---------------------------------------
        LDA     #<NCD_ERROR_STR
        LDY     #>NCD_ERROR_STR
        JSR     PRINT_STRING
        LDY     #$01        ; Return error
        RTS
    ;---------------------------------------
    ; Close 
    ;---------------------------------------
        LDX     #$10            ; File #1
        LDA     #$0C            ; Close #1 first
        STA     ICCOM,X
        JSR     CIOV

NCD_ERROR_STR:
        .BYTE   'PATH?',EOL

;---------------------------------------
GENDCB:
        .BYTE      DEVIDN  ; DDEVIC
        .BYTE      $FF     ; DUNIT
        .BYTE      $FF     ; DCOMND
        .BYTE      $80     ; DSTATS
        .BYTE      $FF     ; DBUFL
        .BYTE      $FF     ; DBUFH
        .BYTE      $1F     ; DTIMLO
        .BYTE      $00     ; DRESVD
        .BYTE      $00     ; DBYTL
        .BYTE      $01     ; DBYTH
        .BYTE      $00     ; DAUX1
        .BYTE      $00     ; DAUX2

; End of DO_GENERIC
;---------------------------------------

;;---------------------------------------
;DO_COPY:
;;---------------------------------------
;
;        LDA     #$20
;        STA     COLOR2
;
;        LDA     #<CPYDCB
;        LDY     #>CPYDCB
;        JSR     DOSIOV
;
;        LDA     #$20
;        STA     COLOR2
;
;        RTS
;
;CPYDCB:
;        .BYTE      DEVIDN  ; DDEVIC
;        .BYTE      $FF     ; DUNIT
;        .BYTE      $D8     ; DCOMND
;        .BYTE      $80     ; DSTATS
;        .BYTE      <COPYSPEC  ; DBUFL
;        .BYTE      >COPYSPEC ; DBUFH
;        .BYTE      $FE     ; DTIMLO
;        .BYTE      $00     ; DRESVD
;        .BYTE      $00     ; DBYTL
;        .BYTE      $01     ; DBYTH
;        .BYTE      3       ; DAUX1
;        .BYTE      2       ; DAUX2
;
;COPYSPEC:
;        .BYTE 'iss.po|iss.po',$00

;---------------------------------------
DO_COPY:
;---------------------------------------
        LDA     #$B0
        STA     COLOR2
        RTS

;        JSR     COPY_PARSE_FILES    ; locate comma, replace with EOL
;        BMI     COPY_DONE
;
;        LDA     CMDSEP
;        STA     CMDSEP+2
;
;        LDA     CMDSEP+1
;        STA     CMDSEP
;
;        JSR     COPY_OPEN_DEST      ; use CIO to open file 2 for write
;        BMI     COPY_DONE
;
;        LDA     CMDSEP+2
;        STA     CMDSEP
;        JSR     COPY_OPEN_SRC       ; use CIO to open file 1 for read
;        BMI     COPY_DONE
;
;@:      JSR     COPY_GET_SRC
;        JSR     COPY_PUT_DEST
;        ;BNE     @-
;
;COPY_DONE:
;    ; Close files
;        LDX     #$10
;        JSR     CIOCLOSE
;        LDX     #$20
;        JMP     CIOCLOSE
;
;;---------------------------------------
;COPY_PARSE_FILES:
;;---------------------------------------
;    ; Find position of comma in line buffer
;    ; Return X = position of comma
;    ;---------------------------------------
;        LDX     CMDSEP
;COPY_PARSE_LOOP:
;        LDA     LNBUF,X
;        CMP     #','
;        BEQ     COPY_PARSE_FILES_DONE
;        CMP     #EOL
;        BEQ     COPY_SHOW_USAGE
;        INX
;        BNE     COPY_PARSE_LOOP
;COPY_PARSE_FILES_DONE:
;    ;---------------------------------------
;    ; Here if comma found.
;    ; Inject EOL where the comma was found
;    ;---------------------------------------
;        LDA     #EOL
;        STA     LNBUF,X
;        INX                 ; Advance to start of 2nd arg
;        STX     CMDSEP+1    ; Point to 2nd arg now
;        RTS
;    ;---------------------------------------
;    ; Here if no comma found.
;    ; Print usage
;    ;---------------------------------------
;COPY_SHOW_USAGE:
;        LDA     #<COPY_SHOW_USAGE_STR
;        LDY     #>COPY_SHOW_USAGE_STR
;        JSR     PRINT_STRING
;        LDY     #$FF
;        RTS
;
;COPY_SHOW_USAGE_STR:
;        .BYTE   'COPY SOURCE,DEST',EOL
;
;; End of COPY_COMMA_POS:
;;---------------------------------------
;
;;---------------------------------------
;COPY_OPEN_SRC:
;;---------------------------------------
;        JSR     GET_DOSDR       ; Get DUNIT
;        JSR     PREPEND_DRIVE
;
;        LDX     #$10            ; File #1
;        JSR     CIOCLOSE        ; Assert file #1 is closed
;        LDY     #$04            ; Open for input
;        JSR     CIOOPEN         ; Open filename @ (INBUFF)
;        BPL     COPY_OPEN_SRC_DONE
;
;        LDA     #<COPY_OPEN_SRC_ERR_STR
;        LDY     #>COPY_OPEN_SRC_ERR_STR
;        JMP     PRINT_STRING
;
;COPY_OPEN_SRC_DONE:
;        RTS
;        
;COPY_OPEN_SRC_ERR_STR:
;        .BYTE   'UNABLE TO OPEN SOURCE',EOL
;
;;End of COPY_OPEN_SRC
;;---------------------------------------
;
;;---------------------------------------
;COPY_OPEN_DEST:
;;---------------------------------------
;    ; Advance offset to arg2
;        
;@:      JSR     GET_DOSDR       ; Get DUNIT
;        JSR     PREPEND_DRIVE
;
;        LDX     #$20            ; Assert file #2 is closed
;        JSR     CIOCLOSE
;
;        LDY     #$08            ; Open for write
;        JSR     CIOOPEN
;        BPL     COPY_OPEN_DEST_DONE  ; If success, skip ahead
;
;        LDA     #<COPY_OPEN_DEST_ERR_STR
;        LDY     #>COPY_OPEN_DEST_ERR_STR
;        JMP     PRINT_STRING
;
;COPY_OPEN_DEST_DONE:
;        RTS
;        
;COPY_OPEN_DEST_ERR_STR:
;        .BYTE   'UNABLE TO OPEN DEST',EOL
;
;;End of COPY_OPEN_SRC
;;---------------------------------------
;
;;---------------------------------------
;COPY_GET_SRC:
;;---------------------------------------
;        ;LDX     #$10
;        ;JSR     CIOSTATUS
;
;        LDX     #$10
;        LDA     #<TBUF
;        STA     INBUFF      ; Buffer addr Lo
;        LDA     #>TBUF
;        STA     INBUFF+1    ; Buffer addr Hi
;        LDA     #$80        ; Buffer size Lo
;        LDY     #$00        ; Buffer size Hi
;        JSR     CIOGET
;        BPL     COPY_GET_SRC_DONE
;        CPY     #EOF
;        BEQ     COPY_GET_SRC_DONE
; 
;        LDA     #<COPY_GET_SRC_STR
;        LDY     #>COPY_GET_SRC_STR
;        JMP     PRINT_STRING
;
;COPY_GET_SRC_DONE:
;        RTS
;
;COPY_GET_SRC_STR:
;        .BYTE   'ERROR READING FROM SOURCE',EOL
;
;;---------------------------------------
;COPY_PUT_DEST:
;;---------------------------------------
;        ;LDX     #$20
;        ;JSR     CIOSTATUS
;
;        LDX     #$20
;        LDA     #<TBUF
;        STA     INBUFF      ; Buffer addr Lo
;        LDA     #>TBUF
;        STA     INBUFF+1    ; Buffer addr Hi
;        LDA     #$06        ; Buffer size Lo
;        LDY     #$00        ; Buffer size Hi
;        JSR     CIOPUT
;        BPL     COPY_PUT_DEST_DONE
;        CPY     #EOF
;        BEQ     COPY_PUT_DEST_DONE
; 
;        LDA     #<COPY_PUT_DEST_STR
;        LDY     #>COPY_PUT_DEST_STR
;        JMP     PRINT_STRING
;
;COPY_PUT_DEST_DONE:
;        RTS
;
;COPY_PUT_DEST_STR:
;        .BYTE   'ERROR WRITING TO DEST',EOL
;

;---------------------------------------
DO_DIR:
;---------------------------------------
        JSR     DIR_INIT    ; set dunits
        JSR     DIR_OPEN    ; open with dir request
        CPY     #$01        ; success (1) ?
        BEQ     DIR_LOOP    ; if success, jump ahead
        JMP     PRINT_ERROR ; exit

DIR_LOOP:

    ;---------------------------------------
    ; Send Status request to SIO
    ;---------------------------------------
        LDA     #<STADCB
        LDY     #>STADCB
        JSR     DOSIOV

    ;---------------------------------------
    ; Status returns DVSTAT
    ;---------------------------------------
        LDX     #$00
        CPX     DVSTAT+1    ; if byte count < 255 (that is, hi=0)
        BEQ     DIR_LT_255  ; then skip

    ;---------------------------------------
    ; Branch 1: Read 255 bytes (max)
    ;---------------------------------------
        DEX                 ; X now 255 (Read FF Bytes)
        STX     DIRRDCB+8   ; DBYTL
        STX     DIRRDCB+10  ; DAUX1
        BMI     DIR_NEXT1   ; "always" true. skip down SIO call

    ;---------------------------------------
    ; Branch 2: Read < 255 bytes
    ;---------------------------------------
DIR_LT_255:
        LDA     DVSTAT      ; Get count of bytes remaining
        BEQ     DIR_ERROR   ; If here then DVSTAT = $0000 (error)
        STA     DIRRDCB+8   ; DBYTL
        STA     DIRRDCB+10  ; DAUX1

    ;-------------------------
    ; Send Read request to SIO
    ;-------------------------
DIR_NEXT1:
        LDA     #<DIRRDCB
        LDY     #>DIRRDCB
        JSR     DOSIOV      ; Fetch directory listing
        JSR     DIR_PRINT   ; xfer payload to screen

    ;---------------------------------------
    ; Exit loop if ESC key code found
    ;---------------------------------------
        LDA     CH
        CMP     #ESC_KEY    ; hardware code for ESC key
        BEQ     DIR_NEXT

    ;---------------------------------------
    ; Loop if more data to read
    ;---------------------------------------
        LDA     DVSTAT+1    ; Was there more to read (that is, was hi>0)?
        BNE     DIR_LOOP    ; If yes, then do it again

DIR_NEXT:
        JMP     DIR_CLOSE

DIRRDCB:
        .BYTE      DEVIDN  ; DDEVIC
        .BYTE      $FF     ; DUNIT
        .BYTE      'R'     ; DCOMND
        .BYTE      $40     ; DSTATS
        .BYTE      <RBUF   ; DBUFL
        .BYTE      >RBUF   ; DBUFH
        .BYTE      $1F     ; DTIMLO
        .BYTE      $00     ; DRESVD
        .BYTE      $00     ; DBYTL
        .BYTE      $00     ; DBYTH
        .BYTE      $00     ; DAUX1
        .BYTE      $00     ; DAUX2

;---------------------------------------
; Set DUNITs in all DCBs used by DIR
;---------------------------------------
DIR_INIT:
;---------------------------------------
        JSR     GET_DOSDR       ; On return, X <- n in Nn:
        STX     DIRODCB+1       ; DUNIT for Open
        STX     STADCB+1        ; DUNIT for Status
        STX     DIRRDCB+1       ; DUNIT for Read
        STX     CLODCB+1        ; DUNIT for Close
        RTS

;---------------------------------------
DIR_OPEN:
;---------------------------------------
        JSR     PREPEND_DRIVE

    ;-----------------------------------
    ; Default to arg1
    ;-----------------------------------
        LDX     INBUFF
        LDY     INBUFF+1

    ;-----------------------------------
    ; But use Nn:*.* if no arg1
    ;-----------------------------------
        LDA     CMDSEP          ; 0 means no arg1
        BNE     DIR_OPEN_NEXT   ; If arg1 present then skip

    ;-----------------------------------
    ; Here if no arg1
    ;-----------------------------------
        LDX     #<DIR_OPEN_STR
        LDY     #>DIR_OPEN_STR

        LDA     DOSDR
        ORA     #'0'            ; Convert, say, 1 to '1'
        STA     DIR_OPEN_STR+1  ; Inject DOSDR into string

DIR_OPEN_NEXT:
        STX     DIRODCB+4       ; DBUFL
        STY     DIRODCB+5       ; DBUFH

        LDA     #<DIRODCB
        LDY     #>DIRODCB
        JMP     DOSIOV

DIR_OPEN_STR:
        .BYTE   'N :*.*',EOL

DIRODCB:
        .BYTE   DEVIDN      ; DDEVIC
        .BYTE   $FF         ; DUNIT
        .BYTE   'O'         ; DCOMND
        .BYTE   $80         ; DSTATS
        .BYTE   $FF         ; DBUFL
        .BYTE   $FF         ; DBUFH
        .BYTE   $1F         ; DTIMLO
        .BYTE   $00         ; DRESVD
        .BYTE   $00         ; DBYTL
        .BYTE   $01         ; DBYTH
        .BYTE   $06         ; DAUX1
        .BYTE   $80         ; DAUX2 (Long Dir)

; End of DIR_OPEN
;---------------------------------------

;---------------------------------------
DIR_ERROR:
;---------------------------------------
        LDA     #<DIR_ERROR_STR
        LDY     #>DIR_ERROR_STR
        JSR     PRINT_STRING
        LDY     #$01        ; Return error
        RTS

DIR_ERROR_STR:
        .BYTE   'UNABLE TO READ DIR',EOL

;---------------------------------------
DIR_PRINT:
;---------------------------------------
        ; Print results using CIO
        LDX     #$00
        LDA     #PUTCHR
        STA     ICCOM,X

        ; Fill out buffer loc
        LDA     #<RBUF
        STA     ICBAL,X
        LDA     #>RBUF
        STA     ICBAH,X

        ; Fill out size loc
        LDA     DIRRDCB+8
        STA     ICBLL,X
        TXA
        STA     ICBLH,X
        JMP     CIOV

;---------------------------------------
DIR_CLOSE:
;---------------------------------------
        ; Close
        LDA     #<CLODCB
        LDY     #>CLODCB
        JMP     DOSIOV

;---------------------------------------
DO_LOAD:
;---------------------------------------
    ; Binary Loader based on work by Richard J. Kalagher 07-AUG-1983

    ; Open file
        LDA     CMDSEP          ; Quit if no arg1
        BNE     LOAD_NEXT1
        JMP     LOAD_ERROR

LOAD_NEXT1:
    ; Point INBUFF to start of filename
        CLC
        ADC     INBUFF          ; [A] contains offset to arg1
        STA     INBUFF
        BCC     LOAD_NEXT2
        INC     INBUFF+1

LOAD_NEXT2:
        JSR     LOAD_NTRANS     ; Disable any EOL transation
        JSR     LOAD_SETUP      ; Set up run and init to RTS
        LDA     #OINPUT         ; A arg needed in LOAD_OPEN
        JSR     LOAD_OPEN       ; Open the file
        CPY     #$01            ; Quit if unable to open
        BNE     R
GETFIL: JSR     LOAD_READ2      ; Get two bytes (binary header)
        JSR     LOAD_INIT       ; Set init default
        JSR     LOAD_CHKFF      ; Check if header (and start addr, too)
        JSR     LOAD_STRAD      ; Put start address in
        JSR     LOAD_READ2      ; Get to more butes (end addr)
        JSR     LOAD_ENDAD      ; Put end address in
        JSR     LOAD_BUFLEN     ; Calculate buffer length
        JSR     LOAD_GETDAT     ; Get the data record
        BPL     @+
        JSR     JSTART
@:      JSR     JINIT           ; Attempt initialization
        JMP     GETFIL
JINIT:  JMP     (INITAD)        ; Will either RTS or perform INIT
JSTART: JSR     JINIT           ; Some binfiles launch from INITAD
        JMP     (RUNAD)         ; Godspeed.

R:      RTS                     ; Stunt-double for (INITAD),(RUNAD)

;---------------------------------------
LOAD_SETUP:
;---------------------------------------
        LDA     #<R
        STA     RUNAD
        LDA     #>R
        STA     RUNAD+1
        RTS

;---------------------------------------
LOAD_INIT:
;---------------------------------------
        LDA     #<R
        STA     INITAD
        LDA     #>R
        STA     INITAD+1
        RTS


;---------------------------------------
LOAD_OPEN:
;---------------------------------------
        PHA                     ; A = data direction (4=in, 8=out)
        JSR     GET_DOSDR       ; Get DUNIT
        STX     OPNDCB+1        ; Set DUNIT
        STX     GETDCB+1        ; Set DUNIT FOR READ
        JSR     PREPEND_DRIVE

        LDA     INBUFF          ; Register location of filename
        STA     OPNDCB+4
        LDA     INBUFF+1
        STA     OPNDCB+5

        PLA                     ; A = data direction (4=in, 8=out)
        STA     OPNDCB+10
        LDA     #$00            ; AUX2: No translation
        STA     OPNDCB+11

        LDA     #<OPNDCB
        LDY     #>OPNDCB

        JSR     DOSIOV
        PHA
        JSR     PRINT_ERROR
        PLA
        TAY

        RTS

;---------------------------------------
LOAD_NTRANS:
;---------------------------------------
    ; Disable any EOL transation otherwise
    ; binary data will be corrupted during load
    ;---------------------------------------
        JSR     GET_DOSDR       ; Get DUNIT
        STX     NTRDCB+1        ; Set DUNIT
        LDA     #$00
        STA     NTRDCB+11       ; Translation mode (0 = NONE)
        JMP     NTRANS_CALL     ; Reuse code in DO_NTRANS

;---------------------------------------
LOAD_READ2:
;---------------------------------------

        LDA     #$02
        STA     GETDCB+8
        STA     GETDCB+10

        LDA     #$00
        STA     GETDCB+9
        STA     GETDCB+11

        LDA     #<GETDCB
        LDY     #>GETDCB

        JSR     DOSIOV
        JSR     PRINT_ERROR

        LDA     GETDCB+1
        STA     STADCB+1
        LDA     #<STADCB
        LDY     #>STADCB
        JSR     DOSIOV

        RTS

;---------------------------------------
LOAD_CHKFF:
;---------------------------------------
    ; Check for binary file signature ($FF $FF)
        LDX     BAL
        INX
        BEQ     TEST2
        RTS
TEST2:  LDX     BAH
        INX
        BEQ     ITSFF
        RTS
ITSFF:  JSR     LOAD_READ2  ; Get start address and return
        RTS

;        LDA     #<LOAD_ERROR_STR2
;        LDY     #>LOAD_ERROR_STR2
;        JMP     PRINT_STRING

LOAD_ERROR_STR2:
        .BYTE   'NOT A BINARY FILE',EOL

;---------------------------------------
LOAD_STRAD:
;---------------------------------------
    ; Save payload start address
        LDA     RBUF
        STA     STL
        LDA     RBUF+1
        STA     STH
        RTS

;---------------------------------------
LOAD_ENDAD:
;---------------------------------------
    ; Save payload end address
        LDA     RBUF
        STA     ENL
        LDA     RBUF+1
        STA     ENH
        RTS

;---------------------------------------
LOAD_BUFLEN:
;---------------------------------------
    ; Calculate buffer length (end-start+1)

    ; Calc buffer size Lo
        LDA     ENL
        SEC
        SBC     STL
        STA     BLL     ; Buffer Length Lo

    ; Calc buffer size Hi
        LDA     ENH     ; Calc buffer size Hi
        SBC     STH
        STA     BLH     ; Buffer Length Hi

    ; Add 1
        CLC
        LDA     BLL
        ADC     #$01
        STA     BLL

        LDA     BLH
        ADC     #$00    ; Take care of any carry
        STA     BLH

        RTS

;---------------------------------------
LOAD_GETDAT:
;---------------------------------------
    ; Definitions:
    ; HEAD = requested bytes that will be found in current cache (< 512 bytes)
    ; BODY = contiguous 512 byte sections. BODY = n * 512 bytes)
    ; TAIL = any bytes remaining after BODY (< 512 bytes)

        JSR     GET_DOSDR
        STX     BINDCB+1

    ; Check if bytes requested BL < DVSTAT (bytes waiting in cache)
        LDA     DVSTAT
        CMP     BLL
        LDA     DVSTAT+1
        SBC     BLH
        BCS     GETDAT_OPT2     ; BL <= BW (bytes waiting)

GETDAT_OPT1:
    ;--------------------------------
    ; Here if bytes requested > bytes 
    ; remaining in cache
    ;--------------------------------

    ;-------------------------------
    ; Head = BW (bytes waiting)
    ;-------------------------------
        LDA     DVSTAT
        STA     HEADL
        LDA     DVSTAT+1
        STA     HEADH

    ;-------------------------------
    ; Tail = (BL - HEAD) mod 512
    ;-------------------------------
        SEC
        LDA     BLL
        SBC     HEADL
        AND     #$FF
        STA     TAILL
        LDA     BLH
        SBC     HEADH
        AND     #$01
        STA     TAILH

    ;-----------------------------------
    ; Body = BL - HEAD - TAIL
    ;-----------------------------------
        ; 1. Body = BL - HEAD
        ;-------------------------------
        SEC
        LDA     BLL
        SBC     HEADL
        STA     BODYL
        LDA     BLH
        SBC     HEADH
        STA     BODYH

        ;-------------------------------
        ; 2. Body = Body - HEAD
        ;-------------------------------
        SEC
        LDA     BODYL
        SBC     TAILL
        STA     BODYL
        LDA     BODYH
        SBC     TAILH
        STA     BODYH

        JMP     GETDAT_READ

GETDAT_OPT2:
    ;--------------------------------
    ; Here if bytes requested <= bytes 
    ; remaining in cache
    ;--------------------------------
    ; Head = BL, TAIL = BODY = 0
    ;--------------------------------
        LDA     BLL
        STA     HEADL
        LDA     BLH
        STA     HEADH
        LDA     #$00
        STA     TAILL
        STA     TAILH
        STA     BODYL
        STA     BODYH

;---------------------------------------
GETDAT_READ:
;---------------------------------------
    ;---------------------------------------
    ; Read HEAD bytes
    ;---------------------------------------
        LDA     HEADL
        STA     BLL
        LDA     HEADH
        STA     BLH
        JSR     GETDAT_DOSIOV
        BPL     GETDAT_BODY ; Skip ahead if no problems
        RTS                 ; Bail if error

    ;---------------------------------------
    ; Read BODY bytes
    ;---------------------------------------
GETDAT_BODY:
        LDX     BODYH
GETDAT_BODY_LOOP:
        BEQ     GETDAT_TAIL ; Skip if less than a page to read

        LDA     #$00
        STA     BLL         ; Buffer length
        LDA     #$02        ; 512 bytes at a time
        STA     BLH

        TXA                 ; Stash our loop index (X)
        PHA                 ; onto the stack
        JSR     GETDAT_DOSIOV   
        BPL     @+          ; Skip ahead if no problems
        PLA                 ; Here if problem. Clean up stack
        TYA                 ; Reset N status flag before returning
        RTS                 ; Bail if error

@:      PLA                 ; Retrieve our loop index
        TAX                 ; and xfer it back into X
        DEX                 ; -2 (we pull 0200 bytes at a time)
        DEX                 ; 
        BNE     GETDAT_BODY_LOOP

GETDAT_TAIL:
    ;---------------------------------------
    ; Read TAIL bytes
    ;---------------------------------------
        LDA     TAILL
        STA     BLL
        LDA     TAILH
        STA     BLH
        JMP     GETDAT_DOSIOV

;---------------------------------------
GETDAT_DOSIOV:
;---------------------------------------
    ; Bail if BL = 0
        LDA     BLL
        BNE     @+
        LDA     BLH
        BEQ     GETDAT_DONE

@:
    ; SIO READ
        LDA     STL
        STA     BINDCB+4    ; Start Address Lo
        LDA     STH
        STA     BINDCB+5    ; Start Address Hi
        LDA     BLL
        STA     BINDCB+8    ; Buffer Size Lo
        STA     BINDCB+10
        LDA     BLH
        STA     BINDCB+9    ; Buffer Size Hi
        STA     BINDCB+11

    ;---------------------------------------
    ; Send Read request to SIO
    ;---------------------------------------
        LDA     #<BINDCB
        LDY     #>BINDCB
        JSR     DOSIOV
        JSR     PRINT_ERROR

        ; Note: STADCB+1 SET DURING READ2
        LDA     #<STADCB
        LDY     #>STADCB
        JSR     DOSIOV

    ; Advance Starting Address
    ; ST = ST + PAYLOAD
        CLC
        LDA     STL
        ADC     BLL
        STA     STL

        LDA     STH
        ADC     BLH
        STA     STH

GETDAT_DOSIOV_DONE:
    ; Skip if no bytes left to read
        LDA     DVSTAT
        BNE     GETDAT_DONE
        LDA     DVSTAT+1
        BEQ     @+

    ; If at the start of a new case (Bytes waiting = 0200)
        CMP     #$02
        BEQ     @+
        BNE     GETDAT_DONE
@:      LDA     #EOF        ; 
        CMP     DVSTAT+3    ; Is status EOF?
        BNE     GETDAT_DONE ; No?  Return 1
        LDY     #$FF        ; Yes? Return -1
GETDAT_RTS:
        RTS

GETDAT_DONE:        
        LDY     #$01        ; Return 0
        RTS

BINDCB:
       .BYTE    DEVIDN      ; DDEVIC
       .BYTE    $FF         ; DUNIT
       .BYTE    'R'         ; DCOMND
       .BYTE    $40         ; DSTATS
       .BYTE    $FF         ; DBUFL
       .BYTE    $FF         ; DBUFH
       .BYTE    $0F         ; DTIMLO
       .BYTE    $00         ; DRESVD
       .BYTE    $FF         ; DBYTL
       .BYTE    $FF         ; DBYTH
       .BYTE    $FF         ; DAUX1
       .BYTE    $FF         ; DAUX2


;---------------------------------------
LOAD_CLOSE
;---------------------------------------
        LDA     BINDCB+1
        STA     CLODCB+1
        LDA     #<CLODCB
        LDY     #>CLODCB
        JMP     DOSIOV

;---------------------------------------
LOAD_ERROR:
;---------------------------------------
        LDA     #<MISSING_FILE_STR
        LDY     #>MISSING_FILE_STR
        JMP     PRINT_STRING

;---------------------------------------
DO_LOCK:
;---------------------------------------
        LDA     #$60
        STA     COLOR2
        RTS

;---------------------------------------
DO_NPWD:
;---------------------------------------
        LDA     #EOL        ; Truncate buffer
        STA     RBUF

        JSR     GET_DOSDR   ; X will contain n in Nn:
        STX     PWDDCB+1

        LDA     #<PWDDCB
        LDY     #>PWDDCB
        JSR     DOSIOV
        JSR     PRINT_ERROR

    ;---------------------------------------
    ; If we entered DO_NPWD from REMOUNT_DRIVE
    ; then scipt printing output
    ;---------------------------------------
        LDA     CMDPRV
        CMP     #CMD_IDX.DEL
        BEQ     NPWD_DONE
        CMP     #CMD_IDX.RENAME
        BEQ     NPWD_DONE

NPWD_LOOP:
        LDA     #<RBUF
        LDY     #>RBUF
        JSR     PRINT_STRING

        LDA     #<STADCB
        LDY     #>STADCB
        JSR     DOSIOV
        JSR     PRINT_ERROR

    ;---------------------------------------
    ; Loop if more data to read
    ;---------------------------------------
        LDA     DVSTAT+1    ; Was there more to read (that is, was hi>0)?
        BNE     NPWD_LOOP   ; If yes, then do it again

NPWD_DONE:
        RTS

PWDDCB:
        .BYTE      DEVIDN  ; DDEVIC
        .BYTE      $FF     ; DUNIT
        .BYTE      $30     ; DCOMND
        .BYTE      $40     ; DSTATS
        .BYTE      <RBUF   ; DBUFL
        .BYTE      >RBUF   ; DBUFH
        .BYTE      $1F     ; DTIMLO
        .BYTE      $00     ; DRESVD
        .BYTE      $00     ; DBYTL
        .BYTE      $01     ; DBYTH
        .BYTE      $00     ; DAUX1
        .BYTE      $00     ; DAUX2

; End of DO_NPWD
;---------------------------------------

;---------------------------------------
DO_NTRANS:
;---------------------------------------
        LDX     CMDSEP          ; Check if there's any args
        BEQ     NTRANS_ERROR    ; No. Show usage and quit

        LDA     DOSDR           ; Go with current drive for now
        STA     NTRDCB+1        ; it'll be overwritten later if req'd

    ;---------------------------------------
    ; Check for argc = 2
    ;---------------------------------------
        LDY     CMDSEP          ; Stash offset to arg1 in Y
        LDX     CMDSEP+1        ; Is there an arg2?
        BEQ     PARSE_MODE      ; No. parse arg1 as mode (0-3)

    ;---------------------------------------
    ; Here if argc = 2 (arg1 = Nn: arg2 = mode)
    ;---------------------------------------
        LDX     CMDSEP          ; Get offset to arg1 (Nn:)
        LDA     LNBUF,X         ; Is arg1's (N[n]:) 1st char = 'N'?
        CMP     #'N'            ;
        BNE     NTRANS_ERROR    ; No? Then quit
        LDA     LNBUF+1,X
        CMP     #':'            ; Is arg1's (N[n]:) 2nd char = ':'?
        BEQ     PARSE_MODE      ; Yes, stick with default drive

    ;---------------------------------------
    ; Parse drive number
    ;---------------------------------------
        CMP     #'1'            ; Quit if n in Nn not 1..4
        BCC     NTRANS_ERROR    ; Quit if < '1'
        CMP     #'9'
        BCS     NTRANS_ERROR    ; Quit if >= '9'
        EOR     #%00110000
        STA     NTRDCB+1
        LDY     CMDSEP+1

    ;---------------------------------------
    ; Confirm valid parameter
    ;---------------------------------------
PARSE_MODE:
        LDA     LNBUF,Y         ; Quit if mode not 0..3
        CMP     #'0'
        BCC     NTRANS_ERROR
        CMP     #'4'
        BCS     NTRANS_ERROR
        EOR     #%00110000      ; Here if valid parameter
        STA     NTRDCB+11       ; Assign parameter to DCB

    ;---------------------------------------
    ; Call SIO
    ;---------------------------------------
NTRANS_CALL:
        LDA     #<NTRDCB
        LDY     #>NTRDCB
        JSR     DOSIOV
        JMP     PRINT_ERROR

NTRANS_ERROR:
        LDA     #<NTRANS_ERROR_STR
        LDY     #>NTRANS_ERROR_STR
        JMP     PRINT_STRING

NTRANS_ERROR_STR:
        .BYTE   'MODE? 0=NONE, 1=CR, 2=LF, 3=CR/LF',EOL

NTRDCB:
        .BYTE      DEVIDN  ; DDEVIC
        .BYTE      $FF     ; DUNIT
        .BYTE      'T'     ; DCOMND
        .BYTE      $00     ; DSTATS
        .BYTE      $00     ; DBUFL
        .BYTE      $00     ; DBUFH
        .BYTE      $1F     ; DTIMLO
        .BYTE      $00     ; DRESVD
        .BYTE      $00     ; DBYTL
        .BYTE      $00     ; DBYTH
        .BYTE      $00     ; DAUX1
        .BYTE      $00     ; DAUX2

; End of DO_NTRANS
;---------------------------------------

;---------------------------------------
DO_SOURCE:
;---------------------------------------
        LDA     CMDSEP
        BNE     SOURCE_NEXT1

    ; Filename required
        LDA     #<MISSING_FILE_STR
        LDY     #>MISSING_FILE_STR
        JMP     PRINT_STRING

SOURCE_NEXT1:

    ; Default to NOSCREEN
        LDA     #$00
        STA     CURSCR

    ; Prep file path
        JSR     GET_DOSDR       ; Get DUNIT
        JSR     PREPEND_DRIVE

    ; Assert FILE #1 is closed
        LDX     #$10
        JSR     CIOCLOSE
        
    ; OPEN #1, 4, 0, file path
        LDX     #$10            ; File #1
        LDY     #$04            ; Open for input
        JSR     CIOOPEN         ; Open filename @ (INBUFF)
        BPL     SOURCE_NEXT2
        JMP     PRINT_ERROR

SOURCE_NEXT2:
        JSR     LDBUFA      ; Reset INBUFF to $0580
        LDA     #$FF        ; Clear command
        STA     CMD

    ; INPUT #1, INBUFF
        LDX     #$10
        LDY     #$04
        JSR     CIOGETREC

    ; Check for error
        LDX     #$10
        LDA     ICSTA,X
        CMP     #EOF
        BEQ     SOURCE_DONE ; No error, try parsing cmd

SOURCE_NEXT3:
        LDA     CURSCR      ; Skip echo if SCREEN is disabled
        BEQ     SOURCE_NEXT4
        LDA     LNBUF
        CMP     #'@'
        BEQ     SOURCE_NEXT4

    ; Echo commands
        LDA     INBUFF
        LDY     INBUFF+1
        JSR     PRINT_STRING

SOURCE_NEXT4:
        JSR     GETCMDTEST
        JSR     PARSECMD
        JSR     DOCMD
        SEC
        BCS     SOURCE_NEXT2

SOURCE_DONE
        LDX     #$10
        JSR     CIOCLOSE
        RTS

; End of DO_SOURCE
;---------------------------------------

;---------------------------------------
DO_TYPE:
;---------------------------------------
        LDA     CMDSEP
        BNE     TYPE_SKIP

TYPE_USAGE:
        LDA     #<MISSING_FILE_STR
        LDY     #>MISSING_FILE_STR
        JMP     PRINT_STRING

TYPE_SKIP:
        JSR     GET_DOSDR       ; Get DUNIT
        JSR     PREPEND_DRIVE

    ; Assert input file closed
        LDX     #$10            ; File #1
        JSR     CIOCLOSE        ; Assert file #1 is closed

    ; Open input file
        LDX     #$10            ; File #1
        LDY     #$04            ; Open for input
        JSR     CIOOPEN         ; Open filename @ (INBUFF)
        BPL     TYPE_NEXT

    ; If open failed, Print error
        LDX     #$10            ; File #1
        LDY     ICSTA,X
        JMP     PRINT_ERROR

TYPE_NEXT:

    ; Bail if ESC key is pressed
        LDA     CH
        CMP     #ESC_KEY
        BEQ     TYPE_DONE

    ; Read from file
        LDX     #$10
        LDA     #$01
        LDY     #$00
        JSR     CIOGET

    ; Quit if EOF
        LDX     #$10
        LDA     ICSTA,X
        CMP     #EOF
        BEQ     TYPE_DONE

    ; Convert CRLF or LF --> EOL
        LDY     #$00
        LDA     (INBUFF),Y
        CMP     #CR     ; Skip CR
        BEQ     TYPE_NEXT3
        CMP     #LF     ; Convert LF --> EOL
        BNE     TYPE_NEXT2
        LDA     #EOL
        STA     (INBUFF),Y

TYPE_NEXT2:
    ; Write to screen
        LDX     #$00
        LDA     #$01
        LDY     #$00
        JSR     CIOPUT

TYPE_NEXT3:
    ; Do next
        JMP     TYPE_NEXT
        
TYPE_DONE:
        LDX     #$10            ; Close File #1
        JMP     CIOCLOSE        ; 

TYPE_OPEN_ERR_STR:
        .BYTE   'UNABLE TO OPEN FILE',EOL

;---------------------------------------
DO_UNLOCK:
;---------------------------------------
        LDA     #$90
        STA     COLOR2
        RTS

;---------------------------------------
DO_CAR:
;---------------------------------------

    ;---------------------------------------
    ; Is cart address space RAM or ROM?
    ;---------------------------------------
        LDA     $A000
        INC     $A000
        CMP     $A000
        BEQ     DO_CAR_NEXT

    ;---------------------------------------
    ; RAM found
    ;---------------------------------------
        STA     $A000
        LDA     #<DO_CAR_ERR
        LDY     #>DO_CAR_ERR
        JMP     PRINT_STRING

DO_CAR_NEXT
        LDA     #$FF
        STA     $08         ; Warmstart
        JMP     ($BFFA)

DO_CAR_ERR:
        .BYTE   'NO CARTRIDGE FOUND',EOL

;---------------------------------------
DO_CLS:
;---------------------------------------
        LDA     #<CLS_STR
        LDY     #>CLS_STR
        JMP     PRINT_STRING

CLS_STR:
        .BYTE   125,EOL

;---------------------------------------
DO_COLD:
;---------------------------------------
        JMP     COLDSV

;---------------------------------------
DO_HELP:
;---------------------------------------
    ; Append either "HELP" or arg1 to URL
        LDX     #$00        ; index to start of article buf
        LDY     CMDSEP      ; index to cmd line arg
        
HELP_LOOP1:
        LDA     (INBUFF),Y
        CMP     #EOL
        BEQ     HELP_NEXT1  ; Exit loop at end of arg
        CPX     #22
        BPL     HELP_DONE   ; Exit if arg is too long
        STA     HELP_ARTICLE,X
        INX
        INY
        BNE     HELP_LOOP1  ; Always true

    ; Append .DOC extension to article name
HELP_EXT:
        .BYTE   '.DOC',EOL,$00

HELP_NEXT1:
        LDY     #$00

HELP_LOOP2:
        LDA     HELP_EXT,Y
        STA     HELP_ARTICLE,X  ; Store null term too
        BEQ     HELP_NEXT2      ; Skip ahead if terminator
        INX
        INY
        BNE     HELP_LOOP2  ; Always true

HELP_NEXT2:
    ; Copy URL to LNBUFF
        LDX     #$00    ; Index to start of HELP_URL
        LDY     #$05    ; Index to start at arg1 for "TYPE "
    
HELP_LOOP3:
        LDA     HELP_URL,X  ; Get source byte
        STA     LNBUF,Y     ; Write to target location
        BEQ     HELP_DONE   ; Exit loop on null terminator
        INX                 ; Advance indices
        INY
        BNE     HELP_LOOP3  ; Always true
        
HELP_DONE:        
        LDA     #$05        ; Trick TYPE to look for URL in arg1
        STA     CMDSEP
        JMP     DO_TYPE

HELP_URL:
;        .BYTE   'N8:HTTP://localhost:6502/'
        .BYTE   'N8:HTTPS://raw.githubusercontent.com/michaelsternberg/fujinet-nhandler/master/nos/HELP'
HELP_ARTICLE:
        .BYTE   $00,$00,$00,$00, $00,$00,$00,$00
        .BYTE   $00,$00,$00,$00, $00,$00,$00,$00
        .BYTE   $00,$00,$00,$00, $00,$00,$00,$00

;;---------------------------------------
;DO_HELP:
;;---------------------------------------
;    ; Copy the requested help topic to 
;    ; the HELP_ARTICLE buffer
;
;        LDX     CMDSEP      ; Point to either HELP or article (arg1)
;        LDY     #$00
;
;HELP_COPY_ARTICLE:
;        LDA     LNBUF,X
;        STA     HELP_ARTICLE,Y
;
;    ; Quit loop if EOL
;        CMP     #EOL
;        BEQ     HELP_NEXT
;
;    ; Quit loop if too long
;        CPX     #23
;        BPL     HELP_DONE
;
;    ; Iterate (always true)
;        INX
;        INY
;        BNE     HELP_COPY_ARTICLE 
;        
;HELP_NEXT:
;    ; Append .TXT to help topic
;        LDY     #$00
;@:      LDA     HELP_EXT,Y
;        BEQ     @+      
;        STA     HELP_ARTICLE,X
;        INX
;        INY
;        BNE     @-
;
;    ; Initialize loop counters
;@:      LDX     #$FF
;        LDY     #$04
;
;HELP_COPY_URL:
;        INY
;        INX
;
;        LDA     HELP_URL,X
;        STA     (INBUFF),Y
;        CMP     #EOL
;        BNE     HELP_COPY_URL
;
;HELP_DONE:
;    ; Force arg1 to point to URL
;        LDA     #$05
;        STA     CMDSEP
;        JMP     DO_TYPE
;
;HELP_EXT:
;        .BYTE   '.TXT',EOL,$00
;
;HELP_URL:
;        .BYTE   'N8:HTTP://localhost:6502/'
;
;HELP_ARTICLE:
;        .BYTE   $00,$00,$00,$00, $00,$00,$00,$00
;        .BYTE   $00,$00,$00,$00, $00,$00,$00,$00
;        .BYTE   $00,$00,$00,$00, $00,$00,$00,$00

;---------------------------------------
DO_NOBASIC:
;---------------------------------------
    ; Quit if 400/800
        LDA     $FFF7
        CMP     #$FF        ; ????
        BEQ     NOBASIC_ERROR
        CMP     #$DD        ; OSA NTSC
        BEQ     NOBASIC_ERROR
        CMP     #$F3        ; OSB NTSC
        BEQ     NOBASIC_ERROR
        CMP     #$D6        ; OSA PAL
        BEQ     NOBASIC_ERROR
        CMP     #$22        ; OSB PAL
        BEQ     NOBASIC_ERROR
        CMP     #$0A        ; OSA 1200XL
        BEQ     NOBASIC_ERROR
        CMP     #$0B        ; OSB 1200XL
        BEQ     NOBASIC_ERROR
        
    ; Disable BASIC
        LDA     PORTB
        ORA     #%00000010  ; if Bit 1 = 1 then BASIC is disabled
        STA     PORTB
        RTS

;---------------------------------------
NOBASIC_ERROR:
;---------------------------------------
        LDA     #<NOBASIC_ERROR_STR
        LDY     #>NOBASIC_ERROR_STR
        JMP     PRINT_STRING

NOBASIC_ERROR_STR:
        .BYTE   'NO BUILT-IN BASIC',EOL

;---------------------------------------
DO_NOSCREEN:
;---------------------------------------
        LDA     #$00
        STA     CURSCR
        RTS

;---------------------------------------
DO_SCREEN:
;---------------------------------------
        LDA     #$01
        STA     CURSCR
        RTS

;---------------------------------------
DO_PRINT:
;---------------------------------------
        LDA     CMDSEP
        BEQ     PRINT_DONE

        CLC
        ADC     INBUFF
        LDY     INBUFF+1
        JMP     PRINT_STRING

PRINT_DONE:
        RTS

;---------------------------------------
DO_REENTER:
;---------------------------------------
    ; Jump to the address stored in RUNAD or INITAD
    ; Do the one that isn't pointing to R (RUNAD first)

    ; Skip it all if both contain $0000
        LDA     INITAD
        BNE     DO_REENTER_CONT
        LDA     INITAD+1
        BNE     DO_REENTER_CONT
        LDA     RUNAD
        BNE     DO_REENTER_CONT
        LDA     RUNAD+1
        BNE     DO_REENTER_CONT

        LDA     #<DO_REENTER_ERR
        LDY     #>DO_REENTER_ERR
        JMP     PRINT_STRING

DO_REENTER_CONT:
        LDA     RUNAD
        CMP     #>R
        BNE     DO_REENTER_RUNAD
        LDA     RUNAD+1
        CMP     #>R
        BEQ     DO_REENTER_INITAD

DO_REENTER_RUNAD:
        JMP     (RUNAD)     ; Godspeed

DO_REENTER_INITAD:
        JMP     (INITAD)    ; Godspeed

DO_REENTER_ERR:
        .BYTE   'NO ADDR IN INITAD OR RUNAD',EOL

;---------------------------------------
DO_REM:
;---------------------------------------
        RTS

;---------------------------------------
DO_RUN:
;---------------------------------------
        LDA     CMDSEP      ; Get position for address arg
        TAY
        CLC
        ADC     #$04
        STA     RBUF

    ;---------------------------------------
    ; ASCII hex char to integer conversion
    ; algorithm borrowed from Apple II Monitor
    ;---------------------------------------
        LDA     #$00
        STA     INBUFF      ; L
        STA     INBUFF+1    ; H
NEXTHEX:
        LDA     LNBUF,Y     ; Get character for hex test.
        EOR     #%00110000  ; Maps digits to $0-$9
        CMP     #$0A        ; Digit?
        BCC     DIG         ; Yes.
        ADC     #$88        ; Map letter "A"-"F" to $FA-FF.
        CMP     #$FA        ; Hex letter?
        BCC     NOTHEX      ; No, character not hex.

DIG:    ASL
        ASL
        ASL
        ASL
        LDX     #$04        ; Shift count.

HEXSHIFT:
        ASL
        ROL     INBUFF      ; Rotate into LSD.
        ROL     INBUFF+1    ; Rotate into MSD's.
        DEX                 ; Done 4 shifts?
        BNE     HEXSHIFT    ; No, loop.
        INY                 ; Advance text index
        CPY     RBUF        ; Processed 4 characters?
        BNE     NEXTHEX     ; No, get next character.

        JMP     (INBUFF)    ; Goto requested address. Godspeed.

NOTHEX:
        LDA     #<RUN_ERROR_STR
        LDY     #>RUN_ERROR_STR
        JMP     PRINT_STRING

RUN_ERROR_STR:
        .BYTE   'ADDR? 0000..FFFF',EOL

;---------------------------------------
DO_WARM:
;---------------------------------------
        JMP     WARMSV

;---------------------------------------
REMOUNT_DRIVE:
;---------------------------------------

    ;---------------------------------------
    ; Workaround for timeout issue regarding idempotent commands that
    ; unmount the server.  So far, these are DEL and RENAME. This
    ; routine, remounts the TNFS URL by calling NPWD and attempts
    ; a MKDIR on the returned mount point. Hopefully this is an
    ; non-consequential operation since the directory already exists.
    ;---------------------------------------

        JSR     DO_NPWD         ; Curr dir for drive now in RBUF

        LDA     RBUF            ; Quit if not TNFS. Only TNFS is affected.
        CMP     #'T'            ; TODO More letters needed if...
        BNE     REMOUNT_DONE    ; ...another Txxx protocol exists

        LDA     #'N'
        STA     RBUF+0
        LDA     DOSDR           ; Get drive number
        ORA     #'0'            ; Convert, say, 1 to '1'
        STA     RBUF+1
        LDA     #':'
        STA     RBUF+2

        LDA     #CMD_MKDIR
        STA     GENDCB+2
        LDA     #<RBUF          ; TODO Is this needed
        STA     GENDCB+4        ; TODO or is it hardcoded in DO_GENERIC?
        LDA     #>RBUF
        STA     GENDCB+5

        LDA     #<GENDCB
        LDY     #>GENDCB
        JMP     DOSIOV

REMOUNT_DONE:
        RTS

;---------------------------------------
PREPEND_DRIVE:
;---------------------------------------
        ; Inject "Nn:" in front of a plain filename
        ; before passing it to the FujiNet
        LDY     #$00
        LDA     #'N'
        CMP     (INBUFF),Y  ; Does arg1 already begin with N?

        LDY     #$02
        LDA     #':'
        CMP     (INBUFF),Y
        BEQ     PREPEND_DRIVE_DONE
        DEY
        CMP     (INBUFF),Y
        BEQ     PREPEND_DRIVE_DONE

        ; Move input buffer pointer back 3 bytes
        SEC
        LDA     INBUFF
        SBC     #$03
        STA     INBUFF
        LDA     INBUFF+1
        SBC     #$00
        STA     INBUFF+1

        ; Inject PRMPT to front of arg1
        LDY     #$03
PREPEND_DRIVE_LOOP:
        LDA     PRMPT,Y
        DEY
        STA     (INBUFF),Y
        BNE     PREPEND_DRIVE_LOOP

PREPEND_DRIVE_DONE:
        LDY     #$01
        RTS             ; Y = $00 here

;---------------------------------------
APPEND_SLASH:
;---------------------------------------
    ;---------------------------------------
    ; Skip if relative path (..)
    ;---------------------------------------
        LDY     #$00
        LDA     #'.'
        CMP     (INBUFF),Y
        BEQ     APPEND_SLASH_DONE

        LDY     #$FF        ; Iterate thru arg2 until EOF
APPEND_SLASH_LOOP:
        INY                 ; Zero on 1st pass
        LDA     (INBUFF),Y
        CMP     #EOL
        BNE     APPEND_SLASH_LOOP

        DEY                 ; Move pointer back one character
        LDA     (INBUFF),Y
        CMP     #'/'        ; If already slash then skip rest
        BEQ     APPEND_SLASH_DONE
        CMP     #':'        ; If a drive, skip
        BEQ     APPEND_SLASH_DONE

        INY                 ; Else inject '/' + EOL
        LDA     #'/'
        STA     (INBUFF),Y
        INY
        LDA     #EOL
        STA     (INBUFF),Y

APPEND_SLASH_DONE:
        RTS

PRMPT:
        .BYTE   EOL,'N :'

;;; End CP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Variables

        .ENUM   CMD_IDX
        ;---------------
                NCD                 ;  0
                COPY                ;  1
                DIR                 ;  2
                DEL                 ;  3
                LOAD                ;  4
                LOCK                ;  5
                MKDIR               ;  6
                NPWD                ;  7
                NTRANS              ;  8
                RENAME              ;  9
                RMDIR               ; 10
                SOURCE              ; 11
                TYPE                ; 12
                UNLOCK              ; 13
                CAR                 ; 14
                CLS                 ; 15
                COLD                ; 16
                HELP                ; 17
                NOBASIC             ; 18
                NOSCREEN            ; 19
                PRINT               ; 20
                REENTER             ; 21
                REM                 ; 22
                RUN                 ; 23
                SCREEN              ; 24
                WARM                ; 25
                DRIVE_CHG           ; 26
        .ENDE

CMD_DCOMND:
        .BYTE   CMD_CD              ;  0 NCD
        .BYTE   CMD_COPY            ;  1 COPY
        .BYTE   CMD_DIR             ;  2 DIR
        .BYTE   CMD_DEL             ;  3 DEL
        .BYTE   CMD_LOAD            ;  4 LOAD
        .BYTE   CMD_LOCK            ;  5 LOCK
        .BYTE   CMD_MKDIR           ;  6 MKDIR
        .BYTE   CMD_NPWD            ;  7 NPWD
        .BYTE   CMD_NTRANS          ;  8 NTRANS
        .BYTE   CMD_RENAME          ;  9 RENAME
        .BYTE   CMD_RMDIR           ; 10 RMDIR
        .BYTE   CMD_SOURCE          ; 11 SOURCE
        .BYTE   CMD_TYPE            ; 12 TYPE
        .BYTE   CMD_UNLOCK          ; 13 UNLOCK
        .BYTE   CMD_CAR             ; 14 CAR
        .BYTE   CMD_CLS             ; 15 CLS
        .BYTE   CMD_COLD            ; 16 COLD
        .BYTE   CMD_HELP            ; 17 HELP
        .BYTE   CMD_NOBASIC         ; 18 NOBASIC
        .BYTE   CMD_NOSCREEN        ; 19 NOSCREEN
        .BYTE   CMD_PRINT           ; 20 PRINT
        .BYTE   CMD_REENTER         ; 21 REENTER
        .BYTE   CMD_REM             ; 22 REM
        .BYTE   CMD_RUN             ; 23 RUN
        .BYTE   CMD_SCREEN          ; 24 SCREEN
        .BYTE   CMD_WARM            ; 25 WARM
        .BYTE   CMD_DRIVE_CHG       ; 26

COMMAND:
        .CB     "NCD"               ;  0 NCD
        .BYTE   CMD_IDX.NCD            

        .CB     "COPY"              ;  1 COPY
        .BYTE   CMD_IDX.COPY           

        .CB     "DIR"               ;  2 DIR
        .BYTE   CMD_IDX.DIR              

        .CB     "DEL"               ;  3 DEL
        .BYTE   CMD_IDX.DEL              

        .CB     "LOAD"              ;  4 LOAD
        .BYTE   CMD_IDX.LOAD             

        .CB     "LOCK"              ;  5 LOCK
        .BYTE   CMD_IDX.LOCK             

        .CB     "MKDIR"             ;  6 MKDIR
        .BYTE   CMD_IDX.MKDIR            

        .CB     "NPWD"              ;  7 NPWD
        .BYTE   CMD_IDX.NPWD             

        .CB     "NTRANS"            ;  8 NTRANS
        .BYTE   CMD_IDX.NTRANS          

        .CB     "RENAME"            ;  9 RENAME
        .BYTE   CMD_IDX.RENAME          

        .CB     "RMDIR"             ; 10 RMDIR
        .BYTE   CMD_IDX.RMDIR           

        .CB     "SOURCE"            ; 11 SOURCE
        .BYTE   CMD_IDX.SOURCE             

        .CB     "TYPE"              ; 12 SOURCE
        .BYTE   CMD_IDX.TYPE              

        .CB     "UNLOCK"            ; 13 UNLOCK
        .BYTE   CMD_IDX.UNLOCK            

        .CB     "CAR"               ; 14 CAR
        .BYTE   CMD_IDX.CAR             

        .CB     "CLS"               ; 15 CLS
        .BYTE   CMD_IDX.CLS             

        .CB     "COLD"              ; 16 COLD
        .BYTE   CMD_IDX.COLD              

        .CB     "HELP"              ; 17 HELP
        .BYTE   CMD_IDX.HELP                
                                        
        .CB     "NOBASIC"           ; 18 NOBASIC
        .BYTE   CMD_IDX.NOBASIC         
                                        
        .CB     "@NOSCREEN"         ; 19 @NOSCREEN
        .BYTE   CMD_IDX.NOSCREEN         
                                        
        .CB     "PRINT"             ; 20 PRINT
        .BYTE   CMD_IDX.PRINT           
                                        
        .CB     "REENTER"           ; 21 REENTER
        .BYTE   CMD_IDX.REENTER         
                                        
        .CB     "REM"               ; 22 REM
        .BYTE   CMD_IDX.REM             
                                        
        .CB     "RUN"               ; 23 RUN
        .BYTE   CMD_IDX.RUN             
                                        
        .CB     "@SCREEN"           ; 24 @SCREEN
        .BYTE   CMD_IDX.SCREEN

        .CB     "WARM"              ; 25 WARM
        .BYTE   CMD_IDX.WARM

; Aliases
        .CB     "CD"                ; CD = NCD
        .BYTE   CMD_IDX.NCD           

        .CB     "CWD"               ; CWD = NCD
        .BYTE   CMD_IDX.NCD           

        .CB     "ERASE"             ; ERASE = DEL
        .BYTE   CMD_IDX.DEL           

        .CB     "ERA"               ; ERA = DEL
        .BYTE   CMD_IDX.DEL           

        .CB     "X"                 ; X = LOAD
        .BYTE   CMD_IDX.LOAD

        .CB     "PWD"               ; PWD = NPWD
        .BYTE   CMD_IDX.NPWD             

        .CB     "REE"               ; R = REENTER
        .BYTE   CMD_IDX.REENTER             

        .CB     "REN"               ; REN = RENAME
        .BYTE   CMD_IDX.RENAME

        .CB     "@"                 ; @ = SOURCE
        .BYTE   CMD_IDX.SOURCE

        ; Drive Change intentionally omitted

COMMAND_SIZE = * - COMMAND - 1
        .BYTE   $FF

CMD_TAB_L:
        .BYTE   <(DO_GENERIC-1)     ;  0 NCD
        .BYTE   <(DO_COPY-1)        ;  1 COPY
        .BYTE   <(DO_DIR-1)         ;  2 DIR
        .BYTE   <(DO_GENERIC-1)     ;  3 DEL
        .BYTE   <(DO_LOAD-1)        ;  4 LOAD
        .BYTE   <(DO_LOCK-1)        ;  5 LOCK
        .BYTE   <(DO_GENERIC-1)     ;  6 MKDIR
        .BYTE   <(DO_NPWD-1)        ;  7 NPWD
        .BYTE   <(DO_NTRANS-1)      ;  8 NTRANS
        .BYTE   <(DO_GENERIC-1)     ;  9 RENAME
        .BYTE   <(DO_GENERIC-1)     ; 10 RMDIR
        .BYTE   <(DO_SOURCE-1)      ; 11 SOURCE
        .BYTE   <(DO_TYPE-1)        ; 12 TYPE
        .BYTE   <(DO_UNLOCK-1)      ; 13 UNLOCK
        .BYTE   <(DO_CAR-1)         ; 14 CAR
        .BYTE   <(DO_CLS-1)         ; 15 CLS
        .BYTE   <(DO_COLD-1)        ; 16 COLD
        .BYTE   <(DO_HELP-1)        ; 17 HELP
        .BYTE   <(DO_NOBASIC-1)     ; 18 NOBASIC
        .BYTE   <(DO_NOSCREEN-1)    ; 19 NOSCREEN
        .BYTE   <(DO_PRINT-1)       ; 20 PRINT
        .BYTE   <(DO_REENTER-1)     ; 21 REENTER
        .BYTE   <(DO_REM-1)         ; 22 REM
        .BYTE   <(DO_RUN-1)         ; 22 RUN
        .BYTE   <(DO_SCREEN-1)      ; 23 SCREEN
        .BYTE   <(DO_WARM-1)        ; 24 WARM
        .BYTE   <(DO_DRIVE_CHG-1)   ; 25

CMD_TAB_H:
        .BYTE   >(DO_GENERIC-1)     ;  0 NCD
        .BYTE   >(DO_COPY-1)        ;  1 COPY
        .BYTE   >(DO_DIR-1)         ;  2 DIR
        .BYTE   >(DO_GENERIC-1)     ;  3 DEL
        .BYTE   >(DO_LOAD-1)        ;  4 LOAD
        .BYTE   >(DO_LOCK-1)        ;  5 LOCK
        .BYTE   >(DO_GENERIC-1)     ;  6 MKDIR
        .BYTE   >(DO_NPWD-1)        ;  7 NPWD
        .BYTE   >(DO_NTRANS-1)      ;  8 NTRANS
        .BYTE   >(DO_GENERIC-1)     ;  9 RENAME
        .BYTE   >(DO_GENERIC-1)     ; 10 RMDIR
        .BYTE   >(DO_SOURCE-1)      ; 11 SOURCE
        .BYTE   >(DO_TYPE-1)        ; 12 TYPE
        .BYTE   >(DO_UNLOCK-1)      ; 13 UNLOCK
        .BYTE   >(DO_CAR-1)         ; 14 CAR
        .BYTE   >(DO_CLS-1)         ; 15 CLS
        .BYTE   >(DO_COLD-1)        ; 16 COLD
        .BYTE   >(DO_HELP-1)        ; 17 HELP
        .BYTE   >(DO_NOBASIC-1)     ; 18 NOBASIC
        .BYTE   >(DO_NOSCREEN-1)    ; 19 NOSCREEN
        .BYTE   >(DO_PRINT-1)       ; 20 PRINT
        .BYTE   >(DO_REENTER-1)     ; 21 REENTER
        .BYTE   >(DO_REM-1)         ; 22 REM
        .BYTE   >(DO_RUN-1)         ; 23 RUN
        .BYTE   >(DO_SCREEN-1)      ; 24 SCREEN
        .BYTE   >(DO_WARM-1)        ; 25 WARM
        .BYTE   >(DO_DRIVE_CHG-1)   ; 26

        ; DEVHDL TABLE FOR N:

CIOHND  .WORD   OPEN-1
        .WORD   CLOSE-1
        .WORD   GET-1
        .WORD   PUT-1
        .WORD   STATUS-1
        .WORD   SPEC-1

       ; BANNERS

BREADY  .BYTE   '#FUJINET NOS v0.3.0-alpha',EOL
BERROR  .BYTE   '#FUJINET ERROR',EOL

        ; MESSAGES

CDERR   .BYTE   'N#?',EOL

        ; STRING CONSTANTS

MISSING_FILE_STR:
        .BYTE   'FILE?',EOL

        ; VARIABLES

DOSDR   .BYTE   1           ; DOS DRIVE
CMD     .DS     1
CMDPRV  .DS     1
CURSCR  .BYTE   $01         ; echo batch cmds (1=enabled,0=disabled)

TRIP    .DS     1           ; INTR FLAG
RLEN    .DS     MAXDEV      ; RCV LEN
ROFF    .DS     MAXDEV      ; RCV OFFSET
TOFF    .DS     MAXDEV      ; TRX OFFSET
INQDS   .DS     1           ; DSTATS INQ

DVS2    .DS     MAXDEV      ; DVSTAT+2 SAVE
DVS3    .DS     MAXDEV      ; DVSTAT+3 SAVE

       ; BUFFERS (PAGE ALIGNED)
        .ALIGN  $100

RBUF    .DS     $80         ; 128 bytes
TBUF    .DS     $80         ; 128 bytes

; Binary loader working variables
BAL     = RBUF
BAH     = RBUF+1    ;
STL     = TBUF      ; Payload Start address
STH     = TBUF+1
ENL     = TBUF+2    ; Payload End address
ENH     = TBUF+3
BLL     = TBUF+4    ; Payload Buffer Length
BLH     = TBUF+5
HEADL   = TBUF+6    ; Bytes read from existing cache
HEADH   = TBUF+7
BODYL   = TBUF+8    ; Total bytes read in contiguous 512-byte blocks
BODYH   = TBUF+9
TAILL   = TBUF+10   ; Bytes read from last cache
TAILH   = TBUF+11
BODYSZL = TBUF+12   ; # Bytes to read at a time in Body
BODYSZH = TBUF+13

PGEND   = *

       END
