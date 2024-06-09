
        ;; Compile with MADS

        ;; Authors: Thomas Cherryhomes
        ;;   <thom.cherryhomes@gmail.com>

        ;; Michael Sternberg
        ;;   <mhsternberg@gmail.com>

        ;; Optimizations being done by djaybee!
        ;; Thank you so much!

;.DEF BURST_MODE


DOSVEC  =   $0A         ; DOSVEC
DOSINI  =   $0C         ; DOSINI

        ;; CURRENT IOCB IN ZERO PAGE
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
MAX_APPKEY_LEN = $40    ; Used with appkey files
SECTOR_SIZE = $80;

;---------------------------------------
; INTERRUPT VECTORS
; AND OTHER PAGE 2 VARS
;---------------------------------------

VPRCED  =   $0202       ; PROCEED VCTR
COLOR0  =   $02C4       ;
COLOR1  =   $02C5       ;
COLOR2  =   $02C6       ; MODEF BKG C
COLOR3  =   $02C7       ;
COLOR4  =   $02C8       ;
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

ROWCRS  =   $0054
RAMTOP  =   $006A
SCRFLG  =   $02BB       ; Scroll flag
CH      =   $02FC       ; Hardware code for last key pressed
CH1     =   $02F2       ; Prior keyboard character code
BASICF  =   $03F8
LNBUF   =   $0582       ; Line Buffer (128 bytes)
;LNBUF   =   $1880       ; Line Buffer (128 bytes)

;---------------------------------------
; HARDWARE REGISTERS
;---------------------------------------

CONSOL  =   $D01F       ; Console switches
PORTB   =   $D301       ; On XL/XE, used to enable/disable BASIC
PACTL   =   $D302       ; PIA CTRL A

;---------------------------------------
; MATH PACK VECTORS
;---------------------------------------
FASC    =   $D8E6       ; Floating point to ASCII
IFP     =   $D9AA       ; Integer to floating point

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

OPTION  =   $03
ESC_KEY =   $1C         ; Hardware code for ESC
SPC_KEY =   $21         ; Hardware code for SPACE

OINPUT  =   $04         ; CIO/SIO direction
OOUTPUT =   $08         ; CIO/SIO direction
BOGUS   =   $F0         ; Bogus FujiNet SIO command byte

;ROM_BORDER = $92        ; Border color when program in ROM
ROM_BORDER = $06        ; Border color when program in ROM

; FujiNet SIO command bytes.
CMD_DRIVE_CHG       = $01
CMD_CD              = $2C
CMD_DIR             = $02
CMD_DEL             = $21
CMD_DUMP            = BOGUS
CMD_FILL            = BOGUS
CMD_LOAD            = $28
CMD_MKDIR           = $2A
CMD_NCOPY           = BOGUS
CMD_NPWD            = $30
CMD_NTRANS          = 'T'
CMD_PASS            = $FE
CMD_RENAME          = $20
CMD_RMDIR           = $2B
CMD_SAVE            = BOGUS
CMD_SUBMIT          = BOGUS
CMD_TYPE            = BOGUS
CMD_USER            = $FD
CMD_UNLOCK          = $24
CMD_CAR             = BOGUS
CMD_CLS             = BOGUS
CMD_COLD            = BOGUS
CMD_HELP            = BOGUS
CMD_BASIC           = BOGUS
CMD_NOSCREEN        = BOGUS
CMD_PRINT           = BOGUS
CMD_REENTER         = BOGUS
CMD_REM             = BOGUS
CMD_RUN             = BOGUS
CMD_SCREEN          = BOGUS
CMD_WARM            = BOGUS
CMD_XEP             = BOGUS
CMD_AUTORUN         = BOGUS

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

; ATR Header
        ORG     $06f0
        OPT     h-
        DTA     $96,$02,$80,$16,$80
:11     DTA     $00

;;; Initialization ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HDR:    .BYTE   $00                 ; BLFAG: Boot flag equals zero (unused)
        .BYTE   [BOOTEND-HDR]/128   ; BRCNT: Number of consecutive sectors to read
        .WORD   HDR                 ; BLDADR: Boot sector load address ($700).
        .WORD   $E4C0               ; BIWTARR: Init addr (addr of RTS in ROM)

        JMP     START

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

        JMP     ALTMEML     ; Alter MEMLO

RESET:  JSR     $FFFF       ; Jump to extant DOSINI

        LDA     #'N'
        STA     RBUF
        JSR     IHTBS       ; Insert into HATABS

        LDA     #'D'        ; Redirect calls for D: to the
        STA     RBUF        ; N: handler for compatibility
        JSR     IHTBS       ; with software that assumes D:

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
        CMP     RBUF        ; RBUF contains 'N' or 'D'
        BEQ     HFND
        INY
        INY
        INY
        CPY     #11*3
        BCC     IH1

        ;; Found a slot

HFND:
        LDA     RBUF        ; RBUF contains 'N' or 'D'
        TAX
        STA     HATABS,Y
        LDA     #<CIOHND
        STA     HATABS+1,Y
        LDA     #>CIOHND
        STA     HATABS+2,Y

        CPX     #'N'        ; Return if 'N' and we'll be back
        BNE     HATABS_CONT ; one more time for 'D'
        RTS

HATABS_CONT:
        ;; And we're done with HATABS

        ;; Query FUJINET

        JSR     STPOLL

        ;; Output Ready/Error

OBANR:
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
        JSR     PRINT_STRING

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
;        LDY     #$0C
        LDY     #$0B
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
        STA     GETDCB+DCB_IDX.DUNIT
        LDA     DVSTAT      ; # of bytes waiting
        STA     GETDCB+DCB_IDX.DBYTL
        STA     GETDCB+DCB_IDX.DAUX1

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
        STA     PUTDCB+DCB_IDX.DUNIT

       ; FINISH DCB AND DO SIOV

TBX:    LDA     TOFF,X
        STA     PUTDCB+DCB_IDX.DBYTL
        STA     PUTDCB+DCB_IDX.DAUX1

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
        STA     SPEDCB+DCB_IDX.DUNIT
        LDA     ZICCOM
        STA     SPEDCB+DCB_IDX.DAUX1

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
    ; INBUFF contains ICBAL/H (filename)
        LDA     #$03            ; 3 = CIO 'OPEN FILE'
        STA     ICCOM,X
        LDA     INBUFF          ; Pointer to filename
        STA     ICBAL,X
        LDA     INBUFF+1        ; Pointer to filename
        STA     ICBAH,X
        TYA                     ; Y contains 4, 8, 12, etc
        STA     ICAX1,X         ; Data direction
        LDA     #$00
        STA     ICAX2,X         ; Unused
        JMP     CIOV            ; Call CIO
;        JSR     PRINT_ERROR
;
;CIOOPEN_DONE:
;        RTS

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

;;---------------------------------------
;CIOGETREC:
;;---------------------------------------
;    ; Input:
;    ; X = IOCB offset ($10,$20,..)
;    ; A = ICBLL
;    ; Y = ICBLH
;    ; INBUFF contains ICBAL/H
;        PHA                 ; Stash Buffer length Lo
;        LDA     #$05        ; GET RECORD command
;        STA     ICCOM,X
;        LDA     INBUFF      ; Get buffer addr from pointer
;        STA     ICBAL,X
;        LDA     INBUFF+1
;        STA     ICBAH,X
;        PLA                 ; Retrieve Buffer length Lo
;        STA     ICBLL,X
;        TYA                 ; Get Buffer length Hi
;        STA     ICBLH,X
;
;        JSR     CIOV        ; Bon voyage
;        BPL     CIOGETREC_DONE
;;        JMP     PRINT_ERROR
;
;CIOGETREC_DONE:
;        RTS

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

    ; Convert char in A from lower-case to upper
TOUPPER:
        CMP     #'a'        ; SKip if < 'a'
        BCC     @+
        CMP     #'z'+1      ; Skip if > 'z'
        BCS     @+
        AND     #$5F        ; Disable high-bit and convert to upper
 @:     RTS

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
        LDA     #$82        ; Normally $80. 2 for headroom
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
; Return next free IOCB channel
; On return X contains IOCB channel
; such as $10, $20, .. $70
; On return:
; - Carry clear -> success
; - Carry set -> failure 
;---------------------------------------
NEXT_IOCB:
        CLC                     ; Default to success 
        LDX     #$10
NEXT_IOCB_LOOP:
        LDA     IOCB,X
        BMI     NEXT_IOCB_DONE  ; Found $FF = Free channel
        TXA
        ADC     #$10            ; Point to the next channel
        BMI     NEXT_IOCB_ERROR ; If $80, no more and it sets N flag
        TAX
        BNE     NEXT_IOCB_LOOP  ; Try next channel

NEXT_IOCB_ERROR:
        LDA     #<NEXT_IOCB_ERROR_STR
        LDY     #>NEXT_IOCB_ERROR_STR
        JSR     PRINT_STRING
        SEC

NEXT_IOCB_DONE:
        RTS
    
NEXT_IOCB_ERROR_STR:
       .BYTE    'TOO MANY FILES OPEN',EOL

; End NEXT_IOCB
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

        LDA     #PUTREC
        STA     ICCOM,X

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
    ; Call subroutines in ROM to convert error from int to ascii
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
        CMP     #$80        ; Loop until high bit is set
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

; End PRINTSCR
;---------------------------------------

ASCII2ADDR:
    ;---------------------------------------
    ; Convert 4-char ASCII string found in LNBUF
    ; to bytes found at INBUFF.
    ; Ex: "0F1A" --> $1A, $0F
    ;
    ; Input:
    ; LNBUF contains 4-char ASCII string
    ; Y contains offset from LNBUF to start
    ; of ASCII string
    ;
    ; Output:
    ; INBUFF contains 2 bytes
    ;---------------------------------------

    ;---------------------------------------
    ; ASCII hex char to integer conversion
    ; algorithm borrowed from Apple II Monitor
    ;---------------------------------------
        LDA     #$00        ; Initialize output to zero
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

        CLC                 ;
        RTS                 ; INBUFF contains bytes

NOTHEX:
        LDA     #<RUN_ERROR_STR
        LDY     #>RUN_ERROR_STR
        JSR     PRINT_STRING
        SEC
        RTS

RUN_ERROR_STR:
        .BYTE   'ADDR? 0000..FFFF',EOL

;---------------------------------------
PARSE_COMMAS:
;---------------------------------------
    ; On entry,
    ; LNBUF contains command line such as:
    ; SAVE.N1:ABC,1234,2345,,6789
    ; CMDSEP contain offset to beginning of comma-delimited arg
    ;
    ; In the example above CMDSEP = 5 (start of 'N1:ABC')
    ;
    ; On exit, CMDSEP[0..n] contains a sequence of
    ; offsets to each of the comma-delimited
    ; args.  And COMMA_ARGS_BITFIELD has for each bit:
    ; bit=1 if the comma-delimited arg was non-null
    ; bit=0 if the comma-delimited arg was null.
    ;
    ; In the example above,
    ; CMPSEP[0..n] = {5,12,17,22,23}
    ; where 5 -> N1:ABC
    ;      12 -> 1234
    ;      17 -> 2345
    ;      22 -> null
    ;      23 -> 6789
    ;
    ; COMMA_ARGS_BITFIELD =
    ; bit#: 7 6 5 4  3 2 1 0
    ;       0 0 0 1  0 1 1 1
    ; where bit 0 -> arg 1 (N1:ABC -> 1)
    ;       bit 1 -> arg 2 (1234   -> 1)
    ;       bit 2 -> arg 3 (2345   -> 1)
    ;       bit 3 -> arg 4 (null   -> 0)
    ;       bit 4 -> arg 5 (6789   -> 1)
    ;---------------------------------------

    ;---------------------------------------------
    ; Initialize bit field. Each comma-delimited
    ; arg successfully provided will set a bit to 1
    ;---------------------------------------------
        LDA     #%00000001
        STA     COMMA_ARGS_BITFIELD

    ; Replace commas with EOL
    ; Keep offsets to spaces in CMDSEP
        LDX     #$01                ; X is arg counter, incrs with each comma
;        STX     COMMA_ARGS_BITFIELD ; Set bit field for 1st arg
        LDY     CMDSEP

PARSE_COMMAS_LOOP:
        LDA     LNBUF,Y             ; Get char from cmd line
        CMP     #EOL                ; Quit if reached end of cmd line
        BEQ     PARSE_COMMAS_DONE
        CMP     #','                ; Is curr char a comma?
        BNE     PARSE_COMMAS_NEXT2  ; Not a comma, skip next

    ; Peek at next char. If next char is comma or EOL
    ; then this arg is null
        LDA     LNBUF+1,Y           ; Here if comma, peek at next char
        CMP     #','                ; Skip ahead if peek at next char = comma
        BEQ     PARSE_COMMAS_NEXT1                    ;
        CMP     #EOL                ; Skip ahead if peek at next char = EOL
        BEQ     PARSE_COMMAS_NEXT1  ;

    ; if char is comma and arg is non-null
    ; then set flag in bitfield at bit #Y
        TXA                         ; About to clobber X, stash it
        PHA

        INX
        LDA     #%00000000          ; Initialize
        SEC                         ; Inject a 1

@:      ROL                         ; Move flag into position
        DEX
        BNE     @-

        ORA     COMMA_ARGS_BITFIELD ; Set flag in bitfield
        STA     COMMA_ARGS_BITFIELD ;

        PLA                         ; Restore X
        TAX

PARSE_COMMAS_NEXT1:
        LDA     #EOL                ; Here if comma
        STA     LNBUF,Y             ; Replace with EOL
        TYA
        CLC
        ADC     #$01
        STA     CMDSEP,X            ; Store offset to delimiter
        INX                         ; Advance CMDSEP index
PARSE_COMMAS_NEXT2:
        INY                         ; Advance to next char from cmdline
        BNE     PARSE_COMMAS_LOOP   ; Do next char
PARSE_COMMAS_DONE:
        RTS


;---------------------------------------
CHECK_IF_ROM:
;---------------------------------------
    ; Checks if cart space is ROM or RAM
    ;-----------------------------------
    ; On return
    ; If A000 = ROM then Y = 1
    ; If A000 = RAM then Y = 0
    ;-----------------------------------
        LDY     #$01        ; Assume ROM -> Y=1
        LDA     $A000       ; Try altering A000
        INC     $A000       ;
        CMP     $A000       ; If A <> A000 then RAM
        BEQ     @+          ; If A = A000 then ROM (Y=FF)
        DEY                 ; RAM -> Y=0
        STA     $A000       ; Restore altered RAM
@:      RTS

;#######################################
;#                                     #
;#       COMMAND PROCESSOR (CP)        #
;#                                     #
;#######################################

;---------------------------------------
; DOS Entry point (DOSVEC points here)
;---------------------------------------
DOS:
        ; Change border if BASIC (or something else) in ROM
        LDA     COLOR4
        STA     COLOR4_ORIG          ; Preserve border
        JSR     CHECK_IF_ROM
        TYA                         ; Y = 1 if ROM
        BEQ     @+                  ; Skip ahead if A000 is RAM
        LDA     #ROM_BORDER         ; Change border
        STA     COLOR4

        ; Bypass Autorun if OPTION switch held
@:      LDA     CONSOL
        CMP     #OPTION
        BEQ     CPLOOP

        ; Autorun injection
        LDA     #CMD_IDX.AUTORUN    ; Check for AUTORUN
        CMP     AUTORUN_FLG         ; True only on 1st entry (TODO Is this working?)
        BEQ     CPLOOP              ; Skip to Command Processor
        STA     AUTORUN_FLG         ; Change flag
        JSR     SUBMIT_AUTORUN      ; Attempt to execute autorun file


CPLOOP:
        JSR     CP          ; Command Processor
        JMP     CPLOOP      ; Keep looping

;---------------------------------------
; Main loop
;---------------------------------------
CP:
        LDA     #$FF        ; Clear command
        STA     CMD
        JSR     SHOWPROMPT
        JSR     GETCMD
AUTORUN_DO:
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
        LDY     #$00
        STY     CIX
        JSR     LDBUFA      ; Reset LNBUF to $0580
        JSR     SKPSPC      ; Advance CIX to next space

    ;---------------------------------------
    ; CMDSEP is an sequence of bytes contains
    ; indexes to chars following spaces
    ; Iterate to clear CMDSEP bytes
    ;---------------------------------------
        TYA                 ; A = 0
;NOTE DO_SAVE Experiment
;        LDX     #$02        ; for X = 2 to 0 step -1
        LDX     #$04        ; for X = 2 to 0 step -1
GETLOOP:
        STA     CMDSEP,X
        DEX
        BPL     GETLOOP     ; next X

    ; Initialize Delimiter to space
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

CMDSEP: .BYTE $FF,$FF,$FF,$FF,$FF
DELIM:  .BYTE ' '

;---------------------------------------
PARSECMD:
;---------------------------------------
        ;LDA     LNBUF
        LDY     #$00
        LDA     (INBUFF),Y
        CMP     #EOL        ; Quit immediately if no cmd
        BEQ     PARSECMD_DONE

        JSR     PARSE_INTRINSIC_COMMAND
        JSR     PARSE_DRIVE_CHANGE
        JSR     PARSE_EXTRINSIC_COMMAND
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
        JSR     LDBUFA      ; Set INBUFF to $0580, er make that TBUF

@:      JSR     SKPSPC      ; Skip whitespace

PARSE_INTRINSIC_NEXT_CHAR:
        LDA     (INBUFF),Y
        AND     #$5F        ; Disable high-bit and convert to upper
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
PARSE_EXTRINSIC_COMMAND:
;---------------------------------------
    ; Quit if CMD has been found earlier
        LDX     CMD         ; Undefined CMD = $FF
        INX                 ; now 0 if undefined
        BNE     PARSE_DRIVE_CHANGE_DONE ; Exit if defined CMD

    ; Here if  CMD is undefined.
    ; From here we'll assume it's a filename for a executable
    ; and attempt to LOAD it. But first append a ".COM"
    ; and shift the filename to the right

    ; Find offset to EOL
        LDY     #$FF
@       INY
        LDA     (INBUFF),Y
        CMP     #EOL
        BNE     @-

    ; Y contains offset to last char & stash it
        TYA
        PHA

    ; Advance Y to allow the 5 chars of '.COM',EOL
        CLC
        ADC     #$05
        TAY

    ; Append .COM, EOL
        LDX     #$04
@:      LDA     CMDEXT,X
        STA     (INBUFF),Y
        DEY
        DEX                     ;
        BPL     @-

    ; Shift executable name to the right to allow room for PREPEND_DRIVE
    ; Stack contains offset to last char
    ; Y is still counting down from where '.COM' was appended.
        PLA                 ; Get offset to last char of executable
        TAX                 ; It'll be used for indexing
        DEX                 ; Skip original EOF
SHIFT_LOOP:
        LDA     LNBUF,X     ; Get source ch
@:      STA     (INBUFF),Y  ; Copy ch to new location
        DEY                 ; Point to next dest ch
        DEX                 ; Point to next source ch
        BPL     SHIFT_LOOP  ; Until X = 0

    ; Let DO_LOAD attempt to execute the file
        LDA     #$01        ; Point to start of filename
        STA     CMDSEP      ; so DO_LOAD will treat it like
        PLA                 ; Strip the last return addr off the stack.
        PLA                 ; Othwerwise unknown cmd error later.
        JMP     DO_LOAD     ; 'LOAD filename'

CMDEXT:
        .BYTE   '.COM',EOL

; End of PARSE_EXTRINSIC_COMMAND
;---------------------------------------

;---------------------------------------
DOCMD:
;---------------------------------------
        LDX     CMD
        BMI     DOCMD_DONE  ; Unassigned command = $FF
        LDA     CMD_TAB_H,X ; Get hi-byte of subroutine's addr
        PHA                 ; Push it to the stack
        LDA     CMD_TAB_L,X ; Get lo-byte of subroutine's addr
        PHA                 ; Push it to the stack
DOCMD_DONE:
        RTS                 ; Use stack & RTS to jump to subroutine

; End of DOCMD
;---------------------------------------

;---------------------------------------
DO_DRIVE_CHG:
;---------------------------------------
        LDA     LNBUF
        AND     #%11011111  ; Convert lower to upper
        CMP     #'N'
        BNE     DO_DRIVE_CHG_ERROR
        STA     PRMPT+1
        LDA     LNBUF+1
        CMP     #'1'        ; Skip if < '1'
        BCC     DO_DRIVE_CHG_ERROR
        CMP     #'9'        ; Skip if >= '9'
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

GET_DOSDR_ALT_ENTRY:
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
        STA     GENDCB+DCB_IDX.DCOMND

        CMP     #CMD_USER       ; Skip prepending devspec for SSH
        BEQ     DO_GENERIC_NEXT
        CMP     #CMD_PASS
        BEQ     DO_GENERIC_NEXT

    ;---------------------------------------
    ; Get DOSDR from either arg1 or curr drive
    ;---------------------------------------
        JSR     GET_DOSDR    ; X will contain int of n in Nn:
        STX     GENDCB+DCB_IDX.DUNIT
        JSR     PREPEND_DRIVE

    ;---------------------------------------
    ; If this is NCD ensure a '/' char is the last char
    ;---------------------------------------
        LDA     GENDCB+DCB_IDX.DCOMND
        CMP     #CMD_CD         ; Is this an NCD command?
        BNE     DO_GENERIC_NEXT ; No. skip

        LDA     CMDSEP
        BEQ     NCD_ERROR
        ;JSR     APPEND_SLASH    ; Append '/' to path if missing

DO_GENERIC_NEXT:
    ;---------------------------------------
    ; Populate the DCB
    ;---------------------------------------
        LDA     DOSDR
        STA     STADCB+DCB_IDX.DUNIT ; Yes. Status (not typo)
;        STA     GENDCB+1   ; 20221105 - commented-out. checking for bug...
        LDA     INBUFF
        STA     GENDCB+DCB_IDX.DBUFL
        LDA     INBUFF+DCB_IDX.DUNIT
        STA     GENDCB+DCB_IDX.DBUFH

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
        LDX     #$10        ; File #1
        LDA     #$0C        ; Close #1 first
        STA     ICCOM,X
        JSR     CIOV

NCD_ERROR_STR:
        .BYTE   'PATH?',EOL

;---------------------------------------
GENDCB:
        .BYTE   DEVIDN      ; DDEVIC
        .BYTE   $FF         ; DUNIT
        .BYTE   $FF         ; DCOMND
        .BYTE   $80         ; DSTATS
        .BYTE   $FF         ; DBUFL
        .BYTE   $FF         ; DBUFH
        .BYTE   $1F         ; DTIMLO
        .BYTE   $00         ; DRESVD
        .BYTE   $00         ; DBYTL
        .BYTE   $01         ; DBYTH
        .BYTE   $00         ; DAUX1
        .BYTE   $00         ; DAUX2

; End of DO_GENERIC
;---------------------------------------

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
        JSR     LOAD_NTRANS     ; Disable any EOL translation
        JSR     LOAD_SETUP      ; Set up run and init to RTS
        LDA     #OINPUT         ; A arg needed in LOAD_OPEN
        JSR     LOAD_OPEN       ; Open the file
        CPY     #$01            ; Quit if unable to open
        BNE     R

        LDA     #$FF
        STA     BIN_1ST
        JSR     LOAD_READ2
        JSR     LOAD_CHKFF
        CPY     #$01
        BNE     R

        INC     BIN_1ST
    ; Process each payload
GETFIL: JSR     LOAD_READ2      ; Get two bytes (binary header)
        BMI     R               ; Exit if EOF hit
        JSR     LOAD_INIT       ; Set init default
        LDX     #$01
        JSR     LOAD_CHKFF      ; Check if header (and start addr, too)
        JSR     LOAD_STRAD      ; Put start address in
        JSR     LOAD_READ2      ; Get to more butes (end addr)
        JSR     LOAD_ENDAD      ; Put end address in
        JSR     LOAD_BUFLEN     ; Calculate buffer length
        JSR     LOAD_GETDAT     ; Get the data record
        BPL     @+              ; Was EOF detected?
        JSR     JSTART          ; Yes. Go to RUNAD
@:      JSR     JINIT           ; Attempt initialization
        JMP     GETFIL          ; Process next payload

JINIT:  JMP     (INITAD)        ; Will either RTS or perform INIT
JSTART: JMP     (RUNAD)         ; Godspeed.
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
        PHA                     ; Save data direction passed in A
        JSR     GET_DOSDR       ; Get DUNIT
        STX     OPNDCB+DCB_IDX.DUNIT
        STX     GETDCB+DCB_IDX.DUNIT ; Set DUNIT FOR READ
        JSR     PREPEND_DRIVE

        LDA     INBUFF          ; Register location of filename
        STA     OPNDCB+DCB_IDX.DBUFL
        LDA     INBUFF+DCB_IDX.DUNIT
        STA     OPNDCB+DCB_IDX.DBUFH

        PLA                     ; A = data direction (4=in, 8=out)
        STA     OPNDCB+DCB_IDX.DAUX1
        LDA     #$00            ; AUX2: No translation
        STA     OPNDCB+DCB_IDX.DAUX2

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
        STX     NTRDCB+DCB_IDX.DUNIT
        LDA     #$00            ; Translation mode (0 = NONE)
        STA     NTRDCB+DCB_IDX.DAUX2
        LDA     #<NTRDCB
        LDY     #>NTRDCB
        JSR     DOSIOV
        JMP     PRINT_ERROR

;---------------------------------------
LOAD_READ2:
;---------------------------------------

    ;---------------------------------------
    ; This is accomplished by abusing the LOAD_GETDAT
    ; routine by stuffing the buffer addr (BAL/H)
    ; into the payload Start/End addrs. We're doing
    ; this in case a payload  header straddles a
    ; cache boundary. LOAD_GETDAT has the logic for
    ; dealing with that.
    ;---------------------------------------
        LDA     #<BAL
        STA     STL         ; Payload start address
        LDA     #>BAL
        STA     STH

        LDA     #<BAH
        STA     ENL         ; Payload end address
        LDA     #>BAH
        STA     ENH

        LDX     #$02
        STX     BLL         ; Payload size (2)
        LDA     #$00
        STA     BLH

        JMP     LOAD_GETDAT ; Read 2 bytes

;---------------------------------------
LOAD_CHKFF:
;---------------------------------------
    ; On 1st pass, check for binary signature (FF FF)
    ; On 2..n passes, Skip FF FF (if found)
    ; and read next 2 bytes
    ;---------------------------------------

        LDA     #$FF
        CMP     BAL         ; Is 1st byte FF?
        BNE     NOTFF       ; If no, skip down.
        CMP     BAH         ; Is 2nd byte FF?
        BNE     NOTFF       ; If no, skip down.

    ;---------------------------------------
    ; Here if FF FF tags found.
    ; On 1st pass, we're done.
    ; On 2..n passes, read next 2 bytes and leave.
    ;---------------------------------------
        CMP     BIN_1ST     ; Is this 1st pass?
        BEQ     NOTFF_DONE  ; If yes, then we're done here.
        JMP     LOAD_READ2  ;

    ;---------------------------------------
    ; Here if FF FF tags NOT found.
    ; On 1st pass, print error.
    ; On 2..n passes, the 2 bytes = payload start addr.
    ;---------------------------------------
NOTFF:  LDY     #$01        ; Preload success return code
        CMP     BIN_1ST     ; A still has FF. BIN_1ST = FF on first pass
        BNE     NOTFF_DONE  ; Not 1st pass, exit with success.

NOTFF_ERR:
        LDA     #<LOAD_ERROR_STR2
        LDY     #>LOAD_ERROR_STR2
        JSR     PRINT_STRING

        LDY     #$FF        ; Return failure
NOTFF_DONE:
        RTS

LOAD_ERROR_STR2:
        .BYTE   'NOT A BINARY FILE',EOL

;---------------------------------------
LOAD_STRAD:
;---------------------------------------
    ; Save payload start address into STL2/STLH2.
    ; Otherwise it will get clobbered
    ; when reading payload end address.
        LDA     RBUF
        STA     STL2
        LDA     RBUF+1
        STA     STH2
        RTS

;---------------------------------------
LOAD_ENDAD:
;---------------------------------------
    ; Save payload end address
        LDA     STL2
        STA     STL
        LDA     STH2
        STA     STH

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


.IFDEF BURST_MODE
;---------------------------------------
LOAD_GETDAT:
;---------------------------------------
    ;---------------------------------------
    ; Fill out the DCB
    ;---------------------------------------
        JSR     GET_DOSDR
        STX     BINDCB+1        ; DUNIT

        LDA     STL
        STA     BINDCB+4        ; DBUFL
        LDA     STH
        STA     BINDCB+5        ; DBUFH
        LDA     BLL
        STA     BINDCB+8        ; DBYTL
        STA     BINDCB+10
        LDA     BLH
        STA     BINDCB+9        ; DBYTH
        STA     BINDCB+11

    ;---------------------------------------
    ; Send Read request to SIO
    ;---------------------------------------
        LDA     #<BINDCB
        LDY     #>BINDCB
        JSR     DOSIOV
        JSR     PRINT_ERROR     ; Show any errors

    ;---------------------------------------
    ; Get status (updates DVSTAT, DSTATS)
    ;---------------------------------------
        LDA     BINDCB+1
        STA     STADCB+1
        LDA     #<STADCB
        LDY     #>STADCB
        JSR     DOSIOV

    ; Check if EOF (current requested chunk completed?)
        LDA     #EOF
        CMP     DVSTAT+3
        BEQ     LOAD_GETDAT_DONE
        JMP     PRINT_ERROR

LOAD_GETDAT_DONE:
    ; Check if 0 bytes remaining
        LDA     DVSTAT
        BNE     LOAD_GETDAT_DONE2
        LDA     DVSTAT+1
        BNE     LOAD_GETDAT_DONE2
        LDY     #$FF
        RTS

LOAD_GETDAT_DONE2:
        LDY     #$01            ; Return success
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

.ELSE
;---------------------------------------
LOAD_GETDAT:
;---------------------------------------
    ; Definitions:
    ; HEAD = requested bytes that will be found in current cache (< 512 bytes)
    ; BODY = contiguous 512 byte sections. BODY = n * 512 bytes)
    ; TAIL = any bytes remaining after BODY (< 512 bytes)

        JSR     GET_DOSDR
        STX     BINDCB+DCB_IDX.DUNIT

        JSR     GETDAT_CHECK_EOF    ; Check EOF before proceeding
        BPL     GETDAT_NEXT1        ; If true, then EOF found. Exit
        RTS

    ; Check if bytes requested BL < DVSTAT (bytes waiting in cache)
GETDAT_NEXT1:
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

;---------------------------------------
GETDAT_DOSIOV:
;---------------------------------------
    ; Bail if BL = 0
        LDA     BLL
        BNE     @+
        LDA     BLH
        BEQ     CHECK_EOF_DONE

@:
    ; SIO READ
        LDA     STL
        STA     BINDCB+DCB_IDX.DBUFL    ; Start Address Lo
        LDA     STH
        STA     BINDCB+DCB_IDX.DBUFH    ; Start Address Hi
        LDA     BLL
        STA     BINDCB+DCB_IDX.DBYTL    ; Buffer Size Lo
        STA     BINDCB+DCB_IDX.DAUX1
        LDA     BLH
        STA     BINDCB+DCB_IDX.DBYTH    ; Buffer Size Hi
        STA     BINDCB+DCB_IDX.DAUX2

    ;---------------------------------------
    ; Send Read request to SIO
    ;---------------------------------------
        LDA     #<BINDCB
        LDY     #>BINDCB
        JSR     DOSIOV
        JSR     PRINT_ERROR

    ;---------------------------------------
    ; Advance start address by buffer length
    ;---------------------------------------
        CLC
        LDA     STL
        ADC     BLL
        STA     STL

        LDA     STH
        ADC     BLH
        STA     STH

GETDAT_CHECK_EOF:
    ; Get status (updates DVSTAT, DSTATS)
        LDA     BINDCB+DCB_IDX.DUNIT
        STA     STADCB+DCB_IDX.DUNIT
        LDA     #<STADCB
        LDY     #>STADCB
        JSR     DOSIOV

    ; Return -1 if DVSTAT == $0000 and DVSTAT+3 == EOF
        LDA     DVSTAT
        BNE     CHECK_EOF_DONE

        LDA     DVSTAT+1
        BNE     CHECK_EOF_DONE

        LDA     #EOF
        CMP     DVSTAT+3        ; Is it EOF
        BNE     CHECK_EOF_DONE  ; No? Go to success
        LDY     #$FF            ; Yes? Return -1
        RTS

CHECK_EOF_DONE:
        LDY     #$01        ; Return success
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
.ENDIF

;---------------------------------------
LOAD_CLOSE:
;---------------------------------------
        LDA     BINDCB+DCB_IDX.DUNIT
        STA     CLODCB+DCB_IDX.DUNIT
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
DO_AUTORUN:
;---------------------------------------
    ; Load sector from NOS ATR into RAM and jump to it.
        LDX     #OVL_IDX.AUTORUN
        JMP     DO_OVERLAY

;---------------------------------------
DO_BASIC:
;---------------------------------------
    ; Load sector from NOS ATR into RAM and jump to it.
        LDX     #OVL_IDX.BASIC
        BNE     JMP_OVERLAY

;---------------------------------------
DO_DIR:
;---------------------------------------
    ; Load sector from NOS ATR into RAM and jump to it.
        LDX     #OVL_IDX.DIR
        BNE     JMP_OVERLAY

;---------------------------------------
DO_DUMP:
;---------------------------------------
    ; Load sector from NOS ATR into RAM and jump to it.
        LDX     #OVL_IDX.DUMP
        BNE     JMP_OVERLAY

;---------------------------------------
DO_FILL:
;---------------------------------------
    ; Load sector from NOS ATR into RAM and jump to it.
        LDX     #OVL_IDX.FILL
        BNE     JMP_OVERLAY

;---------------------------------------
DO_HELP:
;---------------------------------------
    ; Load sector from NOS ATR into RAM and jump to it.
        LDX     #OVL_IDX.HELP
        BNE     JMP_OVERLAY

;---------------------------------------
DO_NCOPY:
;---------------------------------------
        LDA     #$FF        ; Force DO_OVERLAY to always re-read
        STA     OVLPRV      ; code from ATR sector (cache confusion)
        LDX     #OVL_IDX.NCOPY
        BNE     JMP_OVERLAY

;---------------------------------------
DO_NCOPY1:
;---------------------------------------
        LDA     #$FF        ; Force DO_OVERLAY to always re-read
        STA     OVLPRV      ; code from ATR sector (cache confusion)
        LDX     #OVL_IDX.NCOPY1
        BNE     JMP_OVERLAY

;---------------------------------------
DO_NCOPY2:
;---------------------------------------
        LDX     #OVL_IDX.NCOPY2
        BNE     JMP_OVERLAY

;---------------------------------------
DO_NTRANS:
;---------------------------------------
    ; Load sector from NOS ATR into RAM and jump to it.
        LDX     #OVL_IDX.NTRANS
        BNE     JMP_OVERLAY

;---------------------------------------
DO_REENTER:
;---------------------------------------
    ; Load sector from NOS ATR into RAM and jump to it.
        LDX     #OVL_IDX.REENTER
        BNE     JMP_OVERLAY

;---------------------------------------
DO_SAVE:
;---------------------------------------
    ; Load sector from NOS ATR into RAM and jump to it.
        LDX     #OVL_IDX.SAVE
        BNE     JMP_OVERLAY

;---------------------------------------
DO_XEP:
;---------------------------------------
        LDX     #OVL_IDX.XEP
JMP_OVERLAY:
        JMP     DO_OVERLAY

;---------------------------------------
DO_OVERLAY:
;---------------------------------------
    ; Use table to get sector where overlay is stored
        LDA     OVL_SECT_TAB_L,X 
        STA     GET_SECTOR_DCB+DCB_IDX.DAUX1

    ; Currently, all overlays exist in sectors < 01xx,
    ; so $00 can be assumed for high byte of sector number.
;        LDA     OVL_SECT_TAB_H,X
        LDA     #$00
        STA     GET_SECTOR_DCB+DCB_IDX.DAUX2

    ; Get the number of sectors to load
        LDA     OVL_SECT_CNT_TAB,X 
        STA     SECT_CNT

    ; Quit if requested overlay command is already in memory
        LDA     CMD             ; Get current command
        CMP     OVLPRV          ; Is this already in memory?
        BEQ     OVERLAY_DONE    ; Quit if already in memory
        STA     OVLPRV          ; Update previous overlay command

    ; Initialize the base address for the code to be loaded
        LDA     #<OVLBUF
        STA     GET_SECTOR_DCB+DCB_IDX.DBUFL
        LDA     #>OVLBUF
        STA     GET_SECTOR_DCB+DCB_IDX.DBUFH

    ; Get number of sectors to read
OVERLAY_LOOP:
        LDA     #<GET_SECTOR_DCB
        LDY     #>GET_SECTOR_DCB
        JSR     DOSIOV
        DEC     SECT_CNT
        BEQ     OVERLAY_DONE
    ; Increment the load sector by 1
        CLC
        INC     GET_SECTOR_DCB+DCB_IDX.DAUX1
        BCC     @+
        INC     GET_SECTOR_DCB+DCB_IDX.DAUX2
    ; Increment load address by 1 sector distance ($80)
@:      CLC
        LDA     GET_SECTOR_DCB+DCB_IDX.DBUFL
        ADC     #SECTOR_SIZE
        STA     GET_SECTOR_DCB+DCB_IDX.DBUFL
        BCC     @+
        INC     GET_SECTOR_DCB+DCB_IDX.DBUFH
@:      JMP     OVERLAY_LOOP
OVERLAY_DONE:
        JMP     OVLBUF

GET_SECTOR_DCB:
       .BYTE    $31         ; DDEVIC - Floppy
       .BYTE    $01         ; DUNIT
       .BYTE    'R'         ; DCOMND
       .BYTE    $40         ; DSTATS
       .BYTE    <OVLBUF     ; DBUFL - Destination
       .BYTE    >OVLBUF     ; DBUFH
       .BYTE    $0F         ; DTIMLO
       .BYTE    $00         ; DRESVD
       .BYTE    $80         ; DBYTL - Bytes to read
       .BYTE    $00         ; DBYTH
       .BYTE    $FF         ; DAUX1 - Sector
       .BYTE    $FF         ; DAUX2

;---------------------------------------
DO_NPWD:
;---------------------------------------
        LDA     #EOL        ; Truncate buffer
        STA     RBUF

        JSR     GET_DOSDR   ; X will contain n in Nn:
NPWD_ENTRY:
        STX     PWDDCB+DCB_IDX.DUNIT

        LDA     #<PWDDCB
        LDY     #>PWDDCB
        JSR     DOSIOV
        JSR     PRINT_ERROR

    ;---------------------------------------
    ; If we entered DO_NPWD from REMOUNT_DRIVE
    ; then skip printing output
    ;---------------------------------------
        LDA     CMDPRV
        CMP     #CMD_IDX.DEL
        BEQ     NPWD_DONE
        CMP     #CMD_IDX.RENAME
        BEQ     NPWD_DONE
        CMP     #CMD_IDX.NCOPY
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
        .BYTE   DEVIDN      ; DDEVIC
        .BYTE   $FF         ; DUNIT
        .BYTE   $30         ; DCOMND
        .BYTE   $40         ; DSTATS
        .BYTE   <RBUF       ; DBUFL
        .BYTE   >RBUF       ; DBUFH
        .BYTE   $1F         ; DTIMLO
        .BYTE   $00         ; DRESVD
        .BYTE   $00         ; DBYTL
        .BYTE   $01         ; DBYTH
        .BYTE   $00         ; DAUX1
        .BYTE   $00         ; DAUX2

; End of DO_NPWD
;---------------------------------------


AUTORUN_APPKEY:
        .WORD   $DB79               ; creator ID
        .BYTE   $00                 ; app ID
        .BYTE   $00                 ; key ID
        .BYTE   $00                 ; read or write mode
        .BYTE   $00                 ; unused

APPKEYCLOSEDCB:
        .BYTE   $70                 ; DDEVIC
        .BYTE   $01                 ; DUNIT
        .BYTE   $DB                 ; DCOMND
        .BYTE   $00                 ; DSTATS
        .BYTE   $00                 ; DBUFL
        .BYTE   $00                 ; DBUFH
        .BYTE   $0F                 ; DTIMLO
        .BYTE   $00                 ; DRESVD
        .BYTE   $00                 ; DBYTL
        .BYTE   $00                 ; DBYTH
        .BYTE   $00                 ; DAUX1
        .BYTE   $00                 ; DAUX2

APPKEYOPENDCB:
        .BYTE   $70                 ; DDEVIC
        .BYTE   $01                 ; DUNIT
        .BYTE   $DC                 ; DCOMND
        .BYTE   $80                 ; DSTATS
        .BYTE   <AUTORUN_APPKEY     ; DBUFL
        .BYTE   >AUTORUN_APPKEY     ; DBUFH
        .BYTE   $0F                 ; DTIMLO
        .BYTE   $00                 ; DRESVD
        .BYTE   $06                 ; DBYTL
        .BYTE   $00                 ; DBYTH
        .BYTE   $00                 ; DAUX1
        .BYTE   $00                 ; DAUX2

APPKEYREADDCB:
        .BYTE   $70                 ; DDEVIC
        .BYTE   $01                 ; DUNIT
        .BYTE   $DD                 ; DCOMND
        .BYTE   $40                 ; DSTATS
        .BYTE   <LNBUF              ; DBUFL
        .BYTE   >LNBUF              ; DBUFH
        .BYTE   $01                 ; DTIMLO - minimize timeout
        .BYTE   $00                 ; DRESVD
        .BYTE   MAX_APPKEY_LEN+2    ; DBYTL (+2 for # bytes)
        .BYTE   $00                 ; DBYTH
        .BYTE   $00                 ; DAUX1
        .BYTE   $00                 ; DAUX2

APPKEYWRITEDCB:
        .BYTE   $70                 ; DDEVIC
        .BYTE   $01                 ; DUNIT
        .BYTE   $DE                 ; DCOMND
        .BYTE   $80                 ; DSTATS
        .BYTE   $FF                 ; DBUFL
        .BYTE   $05                 ; DBUFH (expect page 5)
        .BYTE   $0F                 ; DTIMLO
        .BYTE   $00                 ; DRESVD
        .BYTE   MAX_APPKEY_LEN      ; DBYTL
        .BYTE   $00                 ; DBYTH
        .BYTE   $FF                 ; DAUX1 (# actual bytes)
        .BYTE   $00                 ; DAUX2

;---------------------------------------
SUBMIT_AUTORUN:
;---------------------------------------
    ; At initial DOS boot, read URL for
    ; app key file from SD card's
    ; FujiNet folder.
    ;
    ; filename: db790000.key
    ; contents: url to a batch file
    ;---------------------------------------
        JSR     LDBUFA

    ; Open app key
        LDA     #$00            ; Open for read
        STA     AUTORUN_APPKEY+4
        LDA     #<APPKEYOPENDCB
        LDY     #>APPKEYOPENDCB
        JSR     DOSIOV

        CPY     #$01            ; Was open successful?
        BEQ     AUTOSUB_NEXT    ; Yes. Continue.
        RTS                     ; No. Exit

AUTOSUB_NEXT:
    ; Read app key
        LDA     #<APPKEYREADDCB
        LDY     #>APPKEYREADDCB
        JSR     DOSIOV

    ; Close app key
        LDA     #<APPKEYCLOSEDCB
        LDY     #>APPKEYCLOSEDCB
        JSR     DOSIOV

    ; Does the returned URL contain something?
        LDX     LNBUF           ; X contains strlen of AUTORUN path
        BNE     AUTORUN_CALL_SUBMIT


AUTOSUB_DONE:
        RTS

AUTORUN_CALL_SUBMIT:
    ; Replace end-of-line in buffer with null terminator
        DEX                     ; Move index back 1 position
        LDA     #$00            ;
        STA     LNBUF+2,X       ; Write null-terminator
        LDA     #$02            ; Change arg1 location...
        STA     CMDSEP          ;  to point to filename

    ;---------------------------------------
    ; If here because of "AUTORUN ?", then
    ; print contents of appkey file. But first
    ; we have to terminate appkey string with EOL
    ;---------------------------------------
        LDA     AUTORUN_QUERY_FLG
        CMP     #'?'
        BNE     SUBMIT_NEXT1

        LDA     #EOL            ; Inject EOL to terminate string
        STA     LNBUF+2,X
        LDA     #<(LNBUF+2)
        LDY     #>(LNBUF+2)
        JMP     PRINT_STRING    ; Print AUTORUN path and sneak out

;---------------------------------------
DO_SUBMIT:
;---------------------------------------
        LDA     CMDSEP
        BNE     SUBMIT_NEXT1

    ; Filename required
        LDA     #<MISSING_FILE_STR
        LDY     #>MISSING_FILE_STR
        JMP     PRINT_STRING

SUBMIT_NEXT1:
    ; Default to NOSCREEN
        LDA     #$00
        STA     ECHO_FLG

    ; Prep file path
        JSR     GET_DOSDR       ; Get DUNIT
        JSR     PREPEND_DRIVE

    ; OPEN #1, 4, 0, file path
        JSR     NEXT_IOCB       ; X will be like $10
        BCC     @+              ; Skip ahead if success
        RTS                     ; Quit if no available channels

@:      STX     SUBMIT_IOCB
        LDY     #OINPUT         ; Open for input
        JSR     CIOOPEN         ; Open filename @ (INBUFF)
        BPL     SUBMIT_NEXT2
        JMP     PRINT_ERROR

    ; Read batch file character by character
    ; This allows it be end-of-line agnostic
    ; Branch forward when an end-of-line is interpretted.

SUBMIT_NEXT2:
        JSR     LDBUFA      ; Reset INBUFF to $0582
        DEC     INBUFF      ; Init 1 byte before buffer
        LDA     #$FF        ; Clear command
        STA     CMD

SUBMIT_GETCH:
        INC     INBUFF          ; Advance pointer
        BNE     SUBMIT_NEXT3
        INC     INBUFF+1

SUBMIT_NEXT3:
        LDX     SUBMIT_IOCB     ; X will be like $10
        LDA     #$01            ; Get 1 byte
        LDY     #$00            ; ditto

        JSR     CIOGET          ; Get byte from file
        LDY     #$00            ;
        LDA     (INBUFF),Y      ; byte will be here

        CMP     #CR             ; Just skip if Windows CR
        BEQ     SUBMIT_GETCH

        CMP     #LF             ; Convert LF to EOL
        BNE     SUBMIT_EOL
        LDA     #EOL
        STA     (INBUFF),Y

SUBMIT_EOL:
        CMP     #EOL            ; At end of command line?
        BNE     SUBMIT_GETCH    ; No. Get next byte.

    ; Here if we've reached the end of a command line.
    ; At end of file?
        LDX     SUBMIT_IOCB     ; X will be like $10
        LDA     ICSTA,X         ; Inspect return code
        CMP     #EOF
        BEQ     SUBMIT_DONE     ; No error, try parsing cmd

        LDA     ECHO_FLG        ; Skip echo if SCREEN is disabled
        BEQ     SUBMIT_NEXT4
        LDA     LNBUF
        CMP     #'@'            ; Skip lines beginning with @
        BEQ     SUBMIT_NEXT4

    ; Echo commands
        JSR     LDBUFA
        LDA     INBUFF
        LDY     INBUFF+1
        JSR     PRINT_STRING

SUBMIT_NEXT4:
        JSR     GETCMDTEST
        JSR     PARSECMD
        JSR     DOCMD
        SEC
        BCS     SUBMIT_NEXT2

SUBMIT_DONE:
        LDX     #$10
        JMP     CIOCLOSE

SUBMIT_IOCB:
        .BYTE   $00             ; Place to store channel

; End of DO_SUBMIT
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

    ; Open input file
        JSR     NEXT_IOCB       ; Get next available IOCB channel
        BCC     @+              ; Carry is set on failure
        RTS                     ; Unable to find available channel

@:      STX     TYPE_IOCB       ; X will be like $10
        LDY     #$04            ; Open for input
        JSR     CIOOPEN         ; Open filename @ (INBUFF)
        BPL     TYPE_NEXT

    ; If open failed, Print error
        LDX     #$10            ; File #1
        LDY     ICSTA,X
        JMP     PRINT_ERROR

TYPE_NEXT:
    ; Initialize pagination
        JSR     DO_CLS
        LDA     #21
        STA     SCRFLG

TYPE_LOOP:
    ; Bail if ESC key is pressed
        LDA     CH
        CMP     #ESC_KEY
        BEQ     TYPE_DONE

    ; Check if page is full
        LDA     SCRFLG
        CMP     #22             ; if SCRFLG < 21
        BCC     TYPE_READ       ; then skip to read

    ; Here if page is full
    ; Wait for keypress
        LDA     #$FF            ; Clear keypress
        STA     CH

TYPE_WAIT:
        LDX     CH              ; Will be $FF if no keypress
        INX                     ; $FF --> $00
        BEQ     TYPE_WAIT       ; Keep waiting if $00

        CPX     #ESC_KEY        ; Leave if ESC key pressed
        BEQ     TYPE_DONE

    ; Reset pagination
        LDA     #$00
        STA     SCRFLG

TYPE_READ:
    ; Read from file
;        LDX     #$10            ; IOCB offset (channel)
        LDX     TYPE_IOCB
        LDA     #$01            ; ICBLL (buffer length lo) Request 1 byte
        LDY     #$00            ; ICBLH (buffer length hi)
        JSR     CIOGET

    ; Quit if EOF
;        LDX     #$10
        LDX     TYPE_IOCB
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
        JMP     TYPE_LOOP

TYPE_DONE:
        LDA     #$FF
        STA     CH
;        LDX     #$10            ; Close File #1
        LDX     TYPE_IOCB
        JMP     CIOCLOSE        ;

TYPE_OPEN_ERR_STR:
        .BYTE   'UNABLE TO OPEN FILE',EOL

TYPE_IOCB:
        .BYTE   $00             ; IOCB Channel for open file

;---------------------------------------
DO_CAR:
;---------------------------------------

    ;---------------------------------------
    ; Is cart address space RAM or ROM?
    ;---------------------------------------
        JSR     CHECK_IF_ROM    ; returns Y=1 -> ROM. Y=0 -> RAM.
        TYA                     ; Xfer affects Z flag
        BNE     DO_CAR_NEXT     ; if Y=1 (ROM) skip ahead

    ;---------------------------------------
    ; RAM found
    ;---------------------------------------
        LDA     #<DO_CAR_ERR
        LDY     #>DO_CAR_ERR
        JMP     PRINT_STRING    ; Print error and bail

DO_CAR_NEXT:
    ;---------------------------------------
    ; Border used to indicate program in ROM
    ; Revert border before returning to ROM
    ;---------------------------------------
        LDA     COLOR4_ORIG
        STA     COLOR4          ; Reset border to orig color

    ;---------------------------------------
    ; Warmstart
    ;---------------------------------------
        LDA     #$FF
        STA     $08
        JMP     ($BFFA)         ; Bye

DO_CAR_ERR:
        .BYTE   'NO CARTRIDGE',EOL

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
DO_NOSCREEN:
;---------------------------------------
        LDA     #$00
        STA     ECHO_FLG    ; Disable echo in batch processing
        RTS

;---------------------------------------
DO_SCREEN:
;---------------------------------------
        LDA     #$01
        STA     ECHO_FLG    ; Enable echo in batch processing
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
DO_REM:
;---------------------------------------
        RTS

;---------------------------------------
DO_RUN:
;---------------------------------------
        LDA     CMDSEP      ; Get position for address arg
        TAY                 ; Offset to arg used later
        CLC
        ADC     #$04
        STA     RBUF

        JSR     ASCII2ADDR  ; Convert text to an addr
        BCS     DO_REM      ; Re-use nearby RTS

        JMP     (INBUFF)    ;

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
        STA     GENDCB+DCB_IDX.DCOMND
        LDA     #<RBUF                  ; TODO Is this needed
        STA     GENDCB+DCB_IDX.DBUFL    ; TODO or is it hardcoded in DO_GENERIC?
        LDA     #>RBUF
        STA     GENDCB+DCB_IDX.DBUFH

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
        BNE     PREPEND_DRIVE_DONE_NEXT_2

    ; Check if 2nd char is : as in N:
        INY
        LDA     #':'
        CMP     (INBUFF),Y
        BNE     PREPEND_DRIVE_DONE_NEXT_1

    ; Here if N: 
    ; Change to Nn: where n is prompt digit char such as 2 in N2:
        DEC     INBUFF
        LDY     #$00
        LDA     #'N'
        STA     (INBUFF),Y

        INY
        LDA     PRMPT+2
        STA     (INBUFF),Y
        JMP     PREPEND_DRIVE_DONE

    ; Here if 2nd char is not :
    ; Check if 3rd char is :
PREPEND_DRIVE_DONE_NEXT_1:
        INY
        CMP     (INBUFF),Y
        BEQ     PREPEND_DRIVE_DONE  ; Done if 3rd char is :

    ; Otherwise inject Nn: into filename
    ; Move input buffer pointer back 3 bytes
PREPEND_DRIVE_DONE_NEXT_2:
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

;;---------------------------------------
;PREPEND_DRIVE:
;;---------------------------------------
;        ; Inject "Nn:" in front of a plain filename
;        ; before passing it to the FujiNet
;        LDY     #$00
;        LDA     #'N'
;        CMP     (INBUFF),Y  ; Does arg1 already begin with N?
;
;        LDY     #$02
;        LDA     #':'
;        CMP     (INBUFF),Y
;        BEQ     PREPEND_DRIVE_DONE
;        DEY
;        CMP     (INBUFF),Y
;        BEQ     PREPEND_DRIVE_DONE
;
;        ; Move input buffer pointer back 3 bytes
;        SEC
;        LDA     INBUFF
;        SBC     #$03
;        STA     INBUFF
;        LDA     INBUFF+1
;        SBC     #$00
;        STA     INBUFF+1
;
;        ; Inject PRMPT to front of arg1
;        LDY     #$03
;PREPEND_DRIVE_LOOP:
;        LDA     PRMPT,Y
;        DEY
;        STA     (INBUFF),Y
;        BNE     PREPEND_DRIVE_LOOP
;
;PREPEND_DRIVE_DONE:
;        LDY     #$01
;        RTS             ; Y = $00 here

;;---------------------------------------
;APPEND_SLASH:
;;---------------------------------------
;    ;---------------------------------------
;    ; Skip if relative path (..)
;    ;---------------------------------------
;        LDY     #$00
;        LDA     #'.'
;        CMP     (INBUFF),Y
;        BEQ     APPEND_SLASH_DONE
;
;        LDY     #$FF        ; Iterate thru arg2 until EOF
;APPEND_SLASH_LOOP:
;        INY                 ; Zero on 1st pass
;        LDA     (INBUFF),Y
;        CMP     #EOL
;        BNE     APPEND_SLASH_LOOP
;
;        DEY                 ; Move pointer back one character
;        LDA     (INBUFF),Y
;        CMP     #'/'        ; If already slash then skip rest
;        BEQ     APPEND_SLASH_DONE
;        CMP     #':'        ; If a drive, skip
;        BEQ     APPEND_SLASH_DONE
;
;        INY                 ; Else inject '/' + EOL
;        LDA     #'/'
;        STA     (INBUFF),Y
;        INY
;        LDA     #EOL
;        STA     (INBUFF),Y
;
;APPEND_SLASH_DONE:
;        RTS

PRMPT:
        .BYTE   EOL,'N :'

;;; End CP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Variables

NTRDCB:
        .BYTE   DEVIDN  ; DDEVIC
        .BYTE   $FF     ; DUNIT
        .BYTE   'T'     ; DCOMND
        .BYTE   $00     ; DSTATS
        .BYTE   $00     ; DBUFL
        .BYTE   $00     ; DBUFH
        .BYTE   $0F     ; DTIMLO
        .BYTE   $00     ; DRESVD
        .BYTE   $00     ; DBYTL
        .BYTE   $00     ; DBYTH
        .BYTE   $00     ; DAUX1
        .BYTE   $00     ; DAUX2

        .ENUM   DCB_IDX
        ;---------------
                DDEVIC              ; 0
                DUNIT               ; 1
                DCOMND              ; 2
                DSTATS              ; 3
                DBUFL               ; 4
                DBUFH               ; 5
                DTIMLO              ; 6
                DRESVD              ; 7
                DBYTL               ; 8
                DBYTH               ; 9
                DAUX1               ; 10
                DAUX2               ; 11
        .ENDE

        .ENUM   CMD_IDX
        ;---------------
                NCD                 ;  0
                DIR                 ;  1
                DEL                 ;  2
                LOAD                ;  3
                MKDIR               ;  4
                NCOPY               ;  5
                NPWD                ;  6
                NTRANS              ;  7
                PASS                ;  8
                RENAME              ;  9
                RMDIR               ; 10
                SAVE                ; 11
                SUBMIT              ; 12
                TYPE                ; 13
                USER                ; 14
                AUTORUN             ; 15
                BASIC               ; 16
                CAR                 ; 17
                CLS                 ; 18
                COLD                ; 19
                DUMP                ; 20
                FILL                ; 21
                HELP                ; 22
                NOSCREEN            ; 23
                PRINT               ; 24
                REENTER             ; 25
                REM                 ; 26
                RUN                 ; 27
                SCREEN              ; 28
                WARM                ; 29
                XEP                 ; 30
                DRIVE_CHG           ; 31
        .ENDE

CMD_DCOMND:
        .BYTE   CMD_CD              ;  0 NCD
        .BYTE   CMD_DIR             ;  1 DIR
        .BYTE   CMD_DEL             ;  2 DEL
        .BYTE   CMD_LOAD            ;  3 LOAD
        .BYTE   CMD_MKDIR           ;  4 MKDIR
        .BYTE   CMD_NCOPY           ;  5 NCOPY
        .BYTE   CMD_NPWD            ;  6 NPWD
        .BYTE   CMD_NTRANS          ;  7 NTRANS
        .BYTE   CMD_PASS            ;  8 PASS
        .BYTE   CMD_RENAME          ;  9 RENAME
        .BYTE   CMD_RMDIR           ; 10 RMDIR
        .BYTE   CMD_SAVE            ; 11 SAVE
        .BYTE   CMD_SUBMIT          ; 12 SUBMIT
        .BYTE   CMD_TYPE            ; 13 TYPE
        .BYTE   CMD_USER            ; 14 USER
        .BYTE   CMD_AUTORUN         ; 15 AUTORUN
        .BYTE   CMD_BASIC           ; 16 BASIC
        .BYTE   CMD_CAR             ; 17 CAR
        .BYTE   CMD_CLS             ; 18 CLS
        .BYTE   CMD_COLD            ; 19 COLD
        .BYTE   CMD_DUMP            ; 20 DUMP
        .BYTE   CMD_FILL            ; 21 FILL
        .BYTE   CMD_HELP            ; 22 HELP
        .BYTE   CMD_NOSCREEN        ; 23 NOSCREEN
        .BYTE   CMD_PRINT           ; 24 PRINT
        .BYTE   CMD_REENTER         ; 25 REENTER
        .BYTE   CMD_REM             ; 26 REM
        .BYTE   CMD_RUN             ; 27 RUN
        .BYTE   CMD_SCREEN          ; 28 SCREEN
        .BYTE   CMD_WARM            ; 29 WARM
        .BYTE   CMD_XEP             ; 30 XEP
        .BYTE   CMD_DRIVE_CHG       ; 31

COMMAND:
        .CB     "NCD"               ;  0 NCD
        .BYTE   CMD_IDX.NCD

        .CB     "DIR"               ;  1 DIR
        .BYTE   CMD_IDX.DIR

        .CB     "DEL"               ;  2 DEL
        .BYTE   CMD_IDX.DEL             
                                        
        .CB     "LOAD"              ;  3 LOAD
        .BYTE   CMD_IDX.LOAD            
                                        
        .CB     "MKDIR"             ;  4 MKDIR
        .BYTE   CMD_IDX.MKDIR           
                                        
        .CB     "NCOPY"             ;  5 NCOPY
        .BYTE   CMD_IDX.NCOPY         
                                      
        .CB     "NPWD"              ;  6 NPWD
        .BYTE   CMD_IDX.NPWD            
                                        
        .CB     "NTRANS"            ;  7 NTRANS
        .BYTE   CMD_IDX.NTRANS          
                                        
        .CB     "PASS"              ;  8 PASS
        .BYTE   CMD_IDX.PASS            
                                        
        .CB     "RENAME"            ;  9 RENAME
        .BYTE   CMD_IDX.RENAME          
                                        
        .CB     "RMDIR"             ; 10 RMDIR
        .BYTE   CMD_IDX.RMDIR           
                                        
        .CB     "SAVE"              ; 11 SAVE
        .BYTE   CMD_IDX.SAVE            
                                        
        .CB     "SUBMIT"            ; 12 SUBMIT
        .BYTE   CMD_IDX.SUBMIT          
                                        
        .CB     "TYPE"              ; 13 TYPE
        .BYTE   CMD_IDX.TYPE            
                                        
        .CB     "USER"              ; 14 USER
        .BYTE   CMD_IDX.USER            
                                        
        .CB     "AUTORUN"           ; 15 AUTORUN
        .BYTE   CMD_IDX.AUTORUN         
                                        
        .CB     "BASIC"             ; 16 NOBASIC
        .BYTE   CMD_IDX.BASIC             
                                          
        .CB     "CAR"               ; 17 CAR
        .BYTE   CMD_IDX.CAR             
                                        
        .CB     "CLS"               ; 18 CLS
        .BYTE   CMD_IDX.CLS             
                                        
        .CB     "COLD"              ; 19 COLD
        .BYTE   CMD_IDX.COLD            
                                        
        .CB     "DUMP"              ; 20 DUMP
        .BYTE   CMD_IDX.DUMP            
                                        
        .CB     "FILL"              ; 21 FILL
        .BYTE   CMD_IDX.FILL              
                                          
        .CB     "HELP"              ; 23 HELP
        .BYTE   CMD_IDX.HELP            
                                        
        .CB     "@NOSCREEN"         ; 24 @NOSCREEN
        .BYTE   CMD_IDX.NOSCREEN        
                                        
        .CB     "PRINT"             ; 25 PRINT
        .BYTE   CMD_IDX.PRINT           
                                        
        .CB     "REENTER"           ; 26 REENTER
        .BYTE   CMD_IDX.REENTER         
                                        
        .CB     "REM"               ; 27 REM
        .BYTE   CMD_IDX.REM             
                                        
        .CB     "RUN"               ; 28 RUN
        .BYTE   CMD_IDX.RUN             
                                        
        .CB     "@SCREEN"           ; 29 @SCREEN
        .BYTE   CMD_IDX.SCREEN          
                                        
        .CB     "WARM"              ; 30 WARM
        .BYTE   CMD_IDX.WARM          
                                      
        .CB     "XEP"               ; 31 XEP
        .BYTE   CMD_IDX.XEP             
                                        
        ; Drive Change intentionally omitted

; Aliases
        .CB     "CD"                ; CD = NCD
        .BYTE   CMD_IDX.NCD

        .CB     "CWD"               ; CWD = NCD
        .BYTE   CMD_IDX.NCD

        .CB     "COPY"              ; COPY = NCOPY
        .BYTE   CMD_IDX.NCOPY

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

        .CB     "@"                 ; @ = SUBMIT
        .BYTE   CMD_IDX.SUBMIT

        .CB     "#"                 ; # = REM
        .BYTE   CMD_IDX.REM

        .CB     "'"                 ; ' = REM
        .BYTE   CMD_IDX.REM

        ; With U1MB, a non-BASIC program might reside
        ; in ROM, then BASIC and NOBASIC feel awkward.
        ; So, ROMON and ROMOFF. (I know. Inconsistent.)

        .CB     "ROM"               ; ROMON = BASIC
        .BYTE   CMD_IDX.BASIC

COMMAND_SIZE = * - COMMAND - 1
        .BYTE   $FF

CMD_TAB_L:
        .BYTE   <(DO_GENERIC-1)     ;  0 NCD
        .BYTE   <(DO_DIR-1)         ;  1 DIR
        .BYTE   <(DO_GENERIC-1)     ;  2 DEL
        .BYTE   <(DO_LOAD-1)        ;  3 LOAD
        .BYTE   <(DO_GENERIC-1)     ;  4 MKDIR
        .BYTE   <(DO_NCOPY-1)       ;  5 NCOPY
        .BYTE   <(DO_NPWD-1)        ;  6 NPWD
        .BYTE   <(DO_NTRANS-1)      ;  7 NTRANS
        .BYTE   <(DO_GENERIC-1)     ;  8 PASS
        .BYTE   <(DO_GENERIC-1)     ;  9 RENAME
        .BYTE   <(DO_GENERIC-1)     ; 10 RMDIR
        .BYTE   <(DO_SAVE-1)        ; 11 SAVE
        .BYTE   <(DO_SUBMIT-1)      ; 12 SUBMIT
        .BYTE   <(DO_TYPE-1)        ; 13 TYPE
        .BYTE   <(DO_GENERIC-1)     ; 14 USER
        .BYTE   <(DO_AUTORUN-1)     ; 15 AUTORUN
        .BYTE   <(DO_BASIC-1)       ; 16 BASIC
        .BYTE   <(DO_CAR-1)         ; 17 CAR
        .BYTE   <(DO_CLS-1)         ; 18 CLS
        .BYTE   <(DO_COLD-1)        ; 19 COLD
        .BYTE   <(DO_DUMP-1)        ; 20 DUMP
        .BYTE   <(DO_FILL-1)        ; 21 FILL
        .BYTE   <(DO_HELP-1)        ; 22 HELP
        .BYTE   <(DO_NOSCREEN-1)    ; 23 NOSCREEN
        .BYTE   <(DO_PRINT-1)       ; 24 PRINT
        .BYTE   <(DO_REENTER-1)     ; 25 REENTER
        .BYTE   <(DO_REM-1)         ; 26 REM
        .BYTE   <(DO_RUN-1)         ; 27 RUN
        .BYTE   <(DO_SCREEN-1)      ; 28 SCREEN
        .BYTE   <(DO_WARM-1)        ; 29 WARM
        .BYTE   <(DO_XEP-1)         ; 30 XEP
        .BYTE   <(DO_DRIVE_CHG-1)   ; 31

CMD_TAB_H:
        .BYTE   >(DO_GENERIC-1)     ;  0 NCD
        .BYTE   >(DO_DIR-1)         ;  1 DIR
        .BYTE   >(DO_GENERIC-1)     ;  2 DEL
        .BYTE   >(DO_LOAD-1)        ;  3 LOAD
        .BYTE   >(DO_GENERIC-1)     ;  4 MKDIR
        .BYTE   >(DO_NCOPY-1)       ;  5 NCOPY
        .BYTE   >(DO_NPWD-1)        ;  6 NPWD
        .BYTE   >(DO_NTRANS-1)      ;  7 NTRANS
        .BYTE   >(DO_GENERIC-1)     ;  8 PASS
        .BYTE   >(DO_GENERIC-1)     ;  9 RENAME
        .BYTE   >(DO_GENERIC-1)     ; 10 RMDIR
        .BYTE   >(DO_SAVE-1)        ; 11 SAVE
        .BYTE   >(DO_SUBMIT-1)      ; 12 SUBMIT
        .BYTE   >(DO_TYPE-1)        ; 13 TYPE
        .BYTE   >(DO_GENERIC-1)     ; 14 USER
        .BYTE   >(DO_AUTORUN-1)     ; 15 AUTORUN
        .BYTE   >(DO_BASIC-1)       ; 16 BASIC
        .BYTE   >(DO_CAR-1)         ; 17 CAR
        .BYTE   >(DO_CLS-1)         ; 18 CLS
        .BYTE   >(DO_COLD-1)        ; 19 COLD
        .BYTE   >(DO_DUMP-1)        ; 20 DUMP
        .BYTE   >(DO_FILL-1)        ; 21 FILL
        .BYTE   >(DO_HELP-1)        ; 22 HELP
        .BYTE   >(DO_NOSCREEN-1)    ; 23 NOSCREEN
        .BYTE   >(DO_PRINT-1)       ; 24 PRINT
        .BYTE   >(DO_REENTER-1)     ; 25 REENTER
        .BYTE   >(DO_REM-1)         ; 26 REM
        .BYTE   >(DO_RUN-1)         ; 27 RUN
        .BYTE   >(DO_SCREEN-1)      ; 28 SCREEN
        .BYTE   >(DO_WARM-1)        ; 29 WARM
        .BYTE   >(DO_XEP-1)         ; 30 XEP
        .BYTE   >(DO_DRIVE_CHG-1)   ; 31

        ; Overlay tables

        .ENUM   OVL_IDX
                AUTORUN
                BASIC
                DIR
                DUMP
                FILL
                HELP
                NCOPY
                NCOPY1
                NCOPY2
                NTRANS
                REENTER
                SAVE
                XEP
        .ENDE

        ; Derive ATR Sector where code is stored
OVL_SECT_TAB_L:
        .BYTE   <(OVL_AUTORUN/SECTOR_SIZE-$0D)
        .BYTE   <(OVL_BASIC/SECTOR_SIZE-$0D)
        .BYTE   <(OVL_DIR/SECTOR_SIZE-$0D)
        .BYTE   <(OVL_DUMP/SECTOR_SIZE-$0D)
        .BYTE   <(OVL_FILL/SECTOR_SIZE-$0D)
        .BYTE   <(OVL_HELP/SECTOR_SIZE-$0D)
        .BYTE   <(OVL_NCOPY/SECTOR_SIZE-$0D)
        .BYTE   <(OVL_NCOPY1/SECTOR_SIZE-$0D)
        .BYTE   <(OVL_NCOPY2/SECTOR_SIZE-$0D)
        .BYTE   <(OVL_NTRANS/SECTOR_SIZE-$0D)
        .BYTE   <(OVL_REENTER/SECTOR_SIZE-$0D)
        .BYTE   <(OVL_SAVE/SECTOR_SIZE-$0D)
        .BYTE   <(OVL_XEP/SECTOR_SIZE-$0D)

;OVL_SECT_TAB_H:
;        .BYTE   >(OVL_AUTORUN/SECTOR_SIZE-$0D)
;        .BYTE   >(OVL_BASIC/SECTOR_SIZE-$0D)
;        .BYTE   >(OVL_DIR/SECTOR_SIZE-$0D)
;        .BYTE   >(OVL_DUMP/SECTOR_SIZE-$0D)
;        .BYTE   >(OVL_FILL/SECTOR_SIZE-$0D)
;        .BYTE   >(OVL_HELP/SECTOR_SIZE-$0D)
;        .BYTE   >(OVL_NCOPY/SECTOR_SIZE-$0D)
;        .BYTE   >(OVL_NCOPY1/SECTOR_SIZE-$0D)
;        .BYTE   >(OVL_NCOPY2/SECTOR_SIZE-$0D)
;        .BYTE   >(OVL_NTRANS/SECTOR_SIZE-$0D)
;        .BYTE   >(OVL_REENTER/SECTOR_SIZE-$0D)
;        .BYTE   >(OVL_SAVE/SECTOR_SIZE-$0D)
;        .BYTE   >(OVL_XEP/SECTOR_SIZE-$0D)

        ; Derive number of ATR sectors used to store code
OVL_SECT_CNT_TAB:
        .BYTE   [END_OVL_AUTORUN-OVL_AUTORUN]/SECTOR_SIZE
        .BYTE   [END_OVL_BASIC-OVL_BASIC]/SECTOR_SIZE
        .BYTE   [END_OVL_DIR-OVL_DIR]/SECTOR_SIZE
        .BYTE   [END_OVL_DUMP-OVL_DUMP]/SECTOR_SIZE
        .BYTE   [END_OVL_FILL-OVL_FILL]/SECTOR_SIZE
        .BYTE   [END_OVL_HELP-OVL_HELP]/SECTOR_SIZE
        .BYTE   [END_OVL_NCOPY-OVL_NCOPY]/SECTOR_SIZE
        .BYTE   [END_OVL_NCOPY1-OVL_NCOPY1]/SECTOR_SIZE
        .BYTE   [END_OVL_NCOPY2-OVL_NCOPY2]/SECTOR_SIZE
        .BYTE   [END_OVL_NTRANS-OVL_NTRANS]/SECTOR_SIZE
        .BYTE   [END_OVL_REENTER-OVL_REENTER]/SECTOR_SIZE
        .BYTE   [END_OVL_SAVE-OVL_SAVE]/SECTOR_SIZE
        .BYTE   [END_OVL_XEP-OVL_XEP]/SECTOR_SIZE

        ; DEVHDL TABLE FOR N:
CIOHND  .WORD   OPEN-1
        .WORD   CLOSE-1
        .WORD   GET-1
        .WORD   PUT-1
        .WORD   STATUS-1
        .WORD   SPEC-1

       ; BANNERS

BREADY  .BYTE   '#FUJINET NOS v0.7.1',EOL
BERROR  .BYTE   '#FUJINET ERROR',EOL

        ; MESSAGES

CDERR   .BYTE   'Nn?',EOL

        ; STRING CONSTANTS

MISSING_FILE_STR:
        .BYTE   'FILE?',EOL

SAVE_ERROR_STR:
        .BYTE   'SAVE Nn:FILE,START,END[,INIT][,RUN]',EOL

SAVE_ADDR_FLG:
        .BYTE   %00000001
        .BYTE   %00000010
        .BYTE   %00000100
        .BYTE   %00001000
        .BYTE   %00010000

SAVE_HEADER:
        .BYTE   $FF,$FF,$00,$00,$00,$00,$00,$00
SAVE_INIT:
        .BYTE   $E2,$02,$E3,$02,$00,$00
SAVE_RUN:
        .BYTE   $E0,$02,$E1,$02,$00,$00


        ; VARIABLES

DOSDR           .BYTE   $01 ; DOS DRIVE
CMD             .BYTE   $01
CMDPRV          .BYTE   $01
OVLPRV          .BYTE   $FF ; Previous Overlay Command
ECHO_FLG        .BYTE   $01 ; Echo batch cmds (1=enabled,0=disabled)
AUTORUN_FLG     .BYTE   $00 ; Checked at DOS entry. Runs only on first pass
WRITEMODE       .BYTE   $00 ; Used for open, truncate or open, append
SOURCE_IOCB     .BYTE   $00 ; Used in NCOPY
TARGET_IOCB     .BYTE   $00 ; Used in NCOPY

TRIP            .BYTE   $01 ; INTR FLAG
RLEN    :MAXDEV .BYTE   $00 ; RCV LEN
ROFF    :MAXDEV .BYTE   $00 ; RCV OFFSET
TOFF    :MAXDEV .BYTE   $00 ; TRX OFFSET
INQDS           .BYTE   $01 ; DSTATS INQ

DVS2    :MAXDEV .BYTE   $00 ; DVSTAT+2 SAVE
DVS3    :MAXDEV .BYTE   $00 ; DVSTAT+3 SAVE

COLOR4_ORIG     .BYTE   $00 ; Hold prev border color

       ; BUFFERS (PAGE ALIGNED)
        .ALIGN  $100, $00
BOOTEND:

; Overlay command RAM (2 sectors)
OVLBUF: :$100   .BYTE   $00

RBUF:   :$80    .BYTE   $00 ; 128 bytes
TBUF:   :$80    .BYTE   $00 ; 128 bytes

; Binary loader working variables
BAL     = RBUF
BAH     = RBUF+1    ;
STL     = TBUF      ; Payload Start address
STH     = TBUF+1
ENL     = TBUF+2    ; Payload End address
ENH     = TBUF+3
HEADL   = TBUF+4    ; Bytes read from existing cache
HEADH   = TBUF+5
BODYL   = TBUF+6    ; Total bytes read in contiguous 512-byte blocks
BODYH   = TBUF+7
BLL     = TBUF+8    ; Payload Buffer Length
BLH     = TBUF+9
TAILL   = TBUF+10   ; Bytes read from last cache
TAILH   = TBUF+11
BODYSZL = TBUF+12   ; # Bytes to read at a time in Body
BODYSZH = TBUF+13
STL2    = TBUF+14   ; Payload Start address (working var)
STH2    = TBUF+15
BIN_1ST = TBUF+16   ; Flag for binary loader signature (FF -> 1st pass)

; Following for DUMP
DUMP_START = TBUF
DUMP_END   = TBUF+2

; Following for FILL
FILL_START = TBUF
FILL_END   = TBUF+2
FILL_BYTE  = TBUF+4
FILL_DIST  = TBUF+5

; Following used in DO_SAVE
INITADL = TBUF+4    ; Init Addr (lo)
INITADH = TBUF+5    ; Init Addr (hi)
RUNADL  = TBUF+6    ; Run Addr (lo)
RUNADH  = TBUF+7    ; Run Addr (hi)
COMMA_ARGS_BITFIELD = RBUF+10    ; Bit field for which addrs provided

; Used in DO_OVERLAY
SECT_CNT = TBUF

AUTORUN_QUERY_FLG   = TBUF+17   ; Flag for printing contents of autorun appkey

PGEND   = *

; =================================================================
;         O  V  E  R  L  A  Y       R  O  U  T  I  N  E  S
;------------------------------------------------------------------
; Overlay commands reside on sectors not loaded into RAM during
; boot. When the corresponding command is executed by the user,
; the DO_OVERLAY routine will load the 1 or 2 sectors into RAM
; at OVLBUF (currently $1600) and then jump to the code there.
;
; Some addresses need to be assembled as if the code were already
; loaded into OVLBUF, so you will see some assembler math used to
; derive the address needed at runtime.
; =================================================================

;---------------------------------------
OVL_AUTORUN:
;---------------------------------------
    ; Change URL stored in AUTORUN app key
    ;-----------------------------------
        LDA     CMDSEP          ; Check if there's any arg
        BNE     AUTORUN_NEXT1   ; If arg found, skip ahead

    ; Here if no command line arg found
    ; Print error message and exit
        LDA     #<(OVLBUF-OVL_AUTORUN+AUTORUN_ERROR_STR)
        LDY     #>(OVLBUF-OVL_AUTORUN+AUTORUN_ERROR_STR)
        JMP     PRINT_STRING

AUTORUN_NEXT1:
    ; Point to start of arg on command line
        CLC
        ADC     INBUFF          ; INBUFF += CMDSEP
        STA     INBUFF
        STA     APPKEYWRITEDCB+DCB_IDX.DBUFL

    ; If "AUTORUN ?" Then abuse AUTORUN_SUBMIT to print appkey
        LDY     #$00
        LDA     #'?'
        STA     AUTORUN_QUERY_FLG
        CMP     (INBUFF),Y
        BNE     @+
        JMP     SUBMIT_AUTORUN

    ; Open app key
@:      LDA     #$01            ; Open for write (1)
        STA     AUTORUN_QUERY_FLG
        STA     AUTORUN_APPKEY+4
        LDA     #<APPKEYOPENDCB
        LDY     #>APPKEYOPENDCB
        JSR     DOSIOV

    ; Find length of URL (arg1)
        LDY     #$FF            ; Init strlen
AUTORUN_LOOP1
        INY                     ; Incr strlen
        LDA     (INBUFF),Y
        CMP     #EOL            ; At end of string?
        BNE     AUTORUN_LOOP1   ; No. Keep counting

        LDA     #LF             ; Convert EOL to LF
        STA     (INBUFF),Y
        INY                     ; One more for strlen

AUTORUN_NEXT2:
    ; Write app key
        STY     APPKEYWRITEDCB+DCB_IDX.DAUX1    ; Y = strlen
        LDA     #<APPKEYWRITEDCB
        LDY     #>APPKEYWRITEDCB
        JSR     DOSIOV

    ; Close app key
        LDA     #<APPKEYCLOSEDCB
        LDY     #>APPKEYCLOSEDCB
        JMP     DOSIOV

AUTORUN_ERROR_STR:
        .BYTE   'PATH?',EOL

        .ALIGN SECTOR_SIZE, $00     ; Align to ATR sector
END_OVL_AUTORUN:

;---------------------------------------
OVL_BASIC:
;---------------------------------------
    ; Enable or disable BASIC (or, say, U1MB ROM)
    ; Usage: [BASIC|ROM] [ON|OFF]

    ; Quit if no internal BASIC
        JSR     OVLBUF-OVL_BASIC+CHECK_INTERNAL_BASIC
        BCS     BASIC_QUIT

    ; Check for usage. arg (BASIC ON|OFF)
        LDX     CMDSEP
        LDA     LNBUF,X
        AND     #%11011111  ; Convert lower to upper
        CMP     #'O'        ; Is 1st char O? as in ON|OFF
        BNE     BASIC_USAGE
        INX
        LDA     LNBUF,X
        AND     #%11011111  ; Convert lower to upper
        CMP     #'F'        ; Is 2nd char F? as in OFF?
        BEQ     BASIC_OFF
        CMP     #'N'        ; Is 2nd char N? as in ON?
        BNE     BASIC_USAGE

    ;---------------------------------------
    ; We are here if BASIC ON or ROM ON was the command.
    ; Do a favor and jump to CAR if ROM is already enabled
    ;---------------------------------------
        LDA     PORTB
        AND     #%00000010
        BNE     BASIC_ON
        JMP     DO_CAR

BASIC_ON:
    ;---------------------------------------
    ; Source: ANTIC Volume 4 #10 Feb 1986
    ; BASIC ON/OFF Switcher [Chadwick]

    ;---------------------------------------
    ; Enable BASIC in XL/XE
    ;---------------------------------------
        LDA     #$00
        STA     BASICF      ; BASIC RAM FLAG
        LDA     #$52
        STA     $03EB       ; CARTRIDGE CHECKSUM

        LDA     PORTB
        AND     #%11111101  ; If Bit 1 = 0 then BASIC is enabled
        STA     PORTB       ; BASIC ROM FLAG
        BNE     BASIC_WARM  ; Always jump

BASIC_OFF:
    ;---------------------------------------
    ; Disable BASIC in XL/XE
    ;---------------------------------------
        LDA     #$01
        STA     BASICF
    ;---------------------------------------
    ; Change border color as reminder that
    ; we're working with limited addr space
    ;---------------------------------------
        LDA     COLOR4_ORIG
        STA     COLOR4

BASIC_WARM:
        JMP     WARMSV  ; XL/XE WARMSTART

BASIC_QUIT:
        RTS

BASIC_USAGE:
        LDA     #<(OVLBUF-OVL_BASIC+BASIC_ERROR)
        LDY     #>(OVLBUF-OVL_BASIC+BASIC_ERROR)
        JMP     PRINT_STRING

BASIC_ERROR:
        .BYTE   '[BASIC|ROM] [ON|OFF]',EOL

;---------------------------------------
CHECK_INTERNAL_BASIC:
;---------------------------------------
    ; Check for internal BASIC found in XL/XEs
    ; On return:
    ;   CARRY is clear if not found
    ;   CARRY is set if found
    ;-----------------------------------
        CLC
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
        RTS

;---------------------------------------
NOBASIC_ERROR:
;---------------------------------------
        LDA     #<(OVLBUF-OVL_BASIC+NOBASIC_ERROR_STR)
        LDY     #>(OVLBUF-OVL_BASIC+NOBASIC_ERROR_STR)
        JSR     PRINT_STRING
        SEC
        RTS

NOBASIC_ERROR_STR:
        .BYTE   'NO BUILT-IN BASIC',EOL

        .ALIGN SECTOR_SIZE, $00     ; Align to ATR sector
END_OVL_BASIC:

;---------------------------------------
OVL_DIR:
;---------------------------------------
        JSR     OVLBUF-OVL_DIR+DIR_INIT   ; JSR DIR_INIT
        JSR     OVLBUF-OVL_DIR+DIR_OPEN   ; JSR_DIR_OPEN
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
        STX     OVLBUF-OVL_DIR+DIRRDCB+DCB_IDX.DBYTL
        STX     OVLBUF-OVL_DIR+DIRRDCB+DCB_IDX.DAUX1
        BMI     DIR_NEXT1   ; "always" true. skip down SIO call

    ;---------------------------------------
    ; Branch 2: Read < 255 bytes
    ;---------------------------------------
DIR_LT_255:
        LDA     DVSTAT      ; Get count of bytes remaining
        BEQ     DIR_ERROR   ; If here then DVSTAT = $0000 (error)
        STA     OVLBUF-OVL_DIR+DIRRDCB+DCB_IDX.DBYTL
        STA     OVLBUF-OVL_DIR+DIRRDCB+DCB_IDX.DAUX1

    ;-------------------------
    ; Send Read request to SIO
    ;-------------------------
DIR_NEXT1:
        LDA     #<(OVLBUF-OVL_DIR+DIRRDCB)
        LDY     #>(OVLBUF-OVL_DIR+DIRRDCB)
        JSR     DOSIOV      ; Fetch directory listing
        JSR     OVLBUF-OVL_DIR+DIR_PRINT   ; JSR DIR_PRINT

    ;---------------------------------------
    ; Pause output if SPACE key code found
    ;---------------------------------------
DIR_WAIT:
        LDA     CH
        CMP     #SPC_KEY
        BEQ     DIR_WAIT

    ;---------------------------------------
    ; Exit loop if ESC key code found
    ;---------------------------------------
        LDA     CH
        CMP     #ESC_KEY    ; hardware code for ESC key
        BEQ     DIR_NEXT

    ;---------------------------------------
    ; Exit loop if Break key code pressed
    ;---------------------------------------

    ;---------------------------------------
    ; Loop if more data to read
    ;---------------------------------------
        LDA     DVSTAT+1    ; Was there more to read (that is, was hi>0)?
        BNE     DIR_LOOP    ; If yes, then do it again

DIR_NEXT:
        LDA     #$FF        ; Clear key
        STA     CH
        JMP     OVLBUF-OVL_DIR+DIR_CLOSE

DIRRDCB:
        .BYTE   DEVIDN      ; DDEVIC
        .BYTE   $FF         ; DUNIT
        .BYTE   'R'         ; DCOMND
        .BYTE   $40         ; DSTATS
        .BYTE   <RBUF       ; DBUFL
        .BYTE   >RBUF       ; DBUFH
        .BYTE   $1F         ; DTIMLO
        .BYTE   $00         ; DRESVD
        .BYTE   $00         ; DBYTL
        .BYTE   $00         ; DBYTH
        .BYTE   $00         ; DAUX1
        .BYTE   $00         ; DAUX2

;---------------------------------------
; Set DUNITs in all DCBs used by DIR
;---------------------------------------
DIR_INIT:
;---------------------------------------
        JSR     GET_DOSDR   ; On return, X <- n in Nn:
        STX     OVLBUF-OVL_DIR+DIRODCB+DCB_IDX.DUNIT   ; DUNIT for Open
        STX     STADCB+DCB_IDX.DUNIT    ; DUNIT for Status
        STX     OVLBUF-OVL_DIR+DIRRDCB+DCB_IDX.DUNIT   ; DUNIT for Read
        STX     CLODCB+DCB_IDX.DUNIT    ; DUNIT for Close
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
        LDX     #<(OVLBUF-OVL_DIR+DIR_OPEN_STR)
        LDY     #>(OVLBUF-OVL_DIR+DIR_OPEN_STR)

        LDA     DOSDR
        ORA     #'0'            ; Convert, say, 1 to '1'
        STA     OVLBUF-OVL_DIR+DIR_OPEN_STR+1  ; Inject DOSDR into string

DIR_OPEN_NEXT:
        STX     OVLBUF-OVL_DIR+DIRODCB+DCB_IDX.DBUFL
        STY     OVLBUF-OVL_DIR+DIRODCB+DCB_IDX.DBUFH

        LDA     #<(OVLBUF-OVL_DIR+DIRODCB)
        LDY     #>(OVLBUF-OVL_DIR+DIRODCB)
        JMP     DOSIOV

;---------------------------------------
DIR_ERROR:
;---------------------------------------
        LDA     #<(OVLBUF-OVL_DIR+DIR_ERROR_STR)
        LDY     #>(OVLBUF-OVL_DIR+DIR_ERROR_STR)
        JSR     PRINT_STRING
        LDY     #$01            ; Return error
        RTS

DIR_ERROR_STR:
        .BYTE   'UNABLE TO READ DIR',EOL

DIR_OPEN_STR:
        .BYTE   'N :*.*',EOL

DIRODCB:
        .BYTE   DEVIDN          ; DDEVIC
        .BYTE   $FF             ; DUNIT
        .BYTE   'O'             ; DCOMND
        .BYTE   $80             ; DSTATS
        .BYTE   $FF             ; DBUFL
        .BYTE   $FF             ; DBUFH
        .BYTE   $1F             ; DTIMLO
        .BYTE   $00             ; DRESVD
        .BYTE   $00             ; DBYTL
        .BYTE   $01             ; DBYTH
        .BYTE   $06             ; DAUX1
        .BYTE   $80             ; DAUX2 (Long Dir)

; End of DIR_OPEN
;---------------------------------------

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
        LDA     OVLBUF-OVL_DIR+DIRRDCB+DCB_IDX.DBYTL
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

        .ALIGN SECTOR_SIZE, $00     ; Align to ATR sector
END_OVL_DIR:

;---------------------------------------
OVL_DUMP:
;---------------------------------------
    ; Dump a range of memory to the screen

    ; Convert comma-delimiters to offsets
        JSR     PARSE_COMMAS

    ; Quit if no args
        LDA     CMDSEP      ; Will contain zero if no arg 1
        BNE     DUMP_NEXT0  ; Skip ahead if args are present

    ; Otherwise show usage
        LDA     #<(OVLBUF-OVL_DUMP+DUMP_ERROR_STR)
        LDY     #>(OVLBUF-OVL_DUMP+DUMP_ERROR_STR)
        JMP     PRINT_STRING

DUMP_NEXT0:
    ; Convert arg1 (start address) from hex string to word
        TAY                 ; Y will hold offset to hex string
        CLC
        ADC     #$04        ; Expected length of hex string
        STA     RBUF        ; RBUF is used by ASCII2ADDR
        JSR     ASCII2ADDR
        BCC     @+
        RTS                 ; Quit if bad ascii 2 addr conversion

    ; Save start address as variable
    ; Also, initialize end address = start address + 7
    ; (I suspect I have an off-by-one error here or at the
    ; bound check, but it's working the way I want as it is).
@:      LDA     INBUFF
        STA     DUMP_START
        CLC
        ADC     #$07
        STA     DUMP_END
        LDA     INBUFF+1
        STA     DUMP_START+1
        STA     DUMP_END+1
        BCC     @+
        INC     DUMP_END+1

    ; Check for arg 2
@:      LDY     CMDSEP+1    ; Offset needed in Y for ASCII2ADDR
        BEQ     DUMP_NEXT2  ; Skip ahead if arg 2 (end address) is not given

DUMP_NEXT1:
    ; Arg 2 given, convert string to address
        ; Convert hex string to int
        TYA                 ; Y = CMDSEP+1 - needed for ASCII2ADDR
        CLC                 ; Offset + 4 needed needed for ASCII2ADDR
        ADC     #$04
        STA     RBUF
        JSR     ASCII2ADDR  ; LNBUF,Y contains 4-char addr
        BCC     @+
        RTS                 ; Quit if bad ascii 2 addr conv

@:      LDA     INBUFF
        STA     DUMP_END
        LDA     INBUFF+1
        STA     DUMP_END+1

DUMP_NEXT2:
    ; Initalize index into memory being dumped
        LDY     #$00

    ; Get address
        LDA     DUMP_START
        STA     INBUFF
        PHA                                 ; Push DUMP_START (Lo byte)

        LDA     DUMP_START+1
        STA     INBUFF+1

    ; Print address
        JSR     OVLBUF-OVL_DUMP+INT2ASCII   ; Print Hi byte. Re-use X = 0

        PLA                                 ; Pull DUMP_START (Lo byte)
        JSR     OVLBUF-OVL_DUMP+INT2ASCII   ; Print Lo byte

    ; Loop for 8 bytes
DUMP_LOOP0:
        LDA     #' '            ; Put a space between hex bytes
        STA     RBUF,X
        INX

    ; Fetch byte from memory
        LDA     (INBUFF),Y
    ; and convert/put hex string into RBUF
        JSR     OVLBUF-OVL_DUMP+INT2ASCII   

    ; Advance to next position
    ; Loop until 8 bytes displayed
        INY
        CPX     #$1A
        BCC     DUMP_LOOP0

    ; Here if done fetching, converting, displaying 8 bytes
        LDA     #EOL
        STA     RBUF,X
        
    ; Print the whole line of addr + bytes
        LDA     #<RBUF
        LDY     #>RBUF
        JSR     PRINT_STRING

    ; Increment address
        CLC
        LDA     #$08
        ADC     DUMP_START      ; Start += 8
        STA     DUMP_START
        BCC     @+

        CLC
        LDA     #$01            ; Use ADC to catch carry
        ADC     DUMP_START+1
        STA     DUMP_START+1
        BCS     DUMP_DONE       ; Quit if we went from FFxx to 00xx

    ; Are we done yet? Is START <= END?
@:      LDA     DUMP_END
        CMP     DUMP_START
        LDA     DUMP_END+1
        SBC     DUMP_START+1
        BCS     @+
        
DUMP_DONE:
        RTS

@:  ; Check for keypress
        LDA     CH              ; Will be $FF if no keypress
        CMP     #ESC_KEY        ; Leave if ESC key pressed
        BEQ     DUMP_DONE
    ; Process next line
        JMP     OVLBUF-OVL_DUMP+DUMP_NEXT2

;--------------
INT2ASCII:
;--------------
    ; Input A contains byte, X contains offset to output string
    ; Output RBUF+X contains string
    ; Stolen from WOZMON disassembly by Jeff Tranter
        PHA                 ; Save A for LSD
        LSR
        LSR
        LSR
        LSR                 ; MSD to LSD position.
        JSR     OVLBUF-OVL_DUMP+PRHEX
        PLA
PRHEX:  AND     #$0F        ; Mask LSD for hex print
        ORA     #'0'        ; Add "0".
        CMP     #$3A        ; Digit?
        BCC     ECHO        ; Yes, skip ahead
        ADC     #$06        ; Add offset for letter
ECHO:   STA     RBUF,X
        INX
        RTS

DUMP_ERROR_STR:
        .BYTE   'DUMP START [END]',EOL

        .ALIGN SECTOR_SIZE, $00     ; Align to ATR sector
END_OVL_DUMP:

;---------------------------------------
OVL_FILL:
;---------------------------------------
    ; Fill a range of memory with a given byte
    
    ; Convert comma-delimiters to offsets
        JSR     PARSE_COMMAS

    ; Quit if 3 args not given
        LDA     CMDSEP      ; Will contain zero if no arg 1
        BNE     FILL_NEXT0

    ; Otherwise show usage
FILL_ERROR:
        LDA     #<(OVLBUF-OVL_FILL+FILL_ERROR_STR)
        LDY     #>(OVLBUF-OVL_FILL+FILL_ERROR_STR)
        JMP     PRINT_STRING

FILL_NEXT0:
    ; Convert arg1 (start address) from hex string to word
        JSR     OVLBUF-OVL_FILL+FILL_ASCII2ADDR
        BCS     FILL_HOP0

    ; Save start address as variable
        LDA     INBUFF
        STA     FILL_START
        LDA     INBUFF+1
        STA     FILL_START+1

        LDA     CMDSEP+1
        BEQ     FILL_ERROR

    ; Convert arg2 (end address) from hex string to word
        JSR     OVLBUF-OVL_FILL+FILL_ASCII2ADDR
FILL_HOP0:
        BCS     FILL_QUIT

    ; Save end address as variable
        LDA     INBUFF
        STA     FILL_END
        LDA     INBUFF+1
        STA     FILL_END+1

    ; Convert arg3 (fill byte) from hex string to byte
        LDY     CMDSEP+2
        BEQ     FILL_ERROR

        LDA     LNBUF+2,Y
        CMP     #EOL
        BNE     FILL_ERROR

        LDA     #'0'
        STA     LNBUF+2,Y
        STA     LNBUF+3,Y
        LDA     #EOL
        STA     LNBUF+4,Y
        TYA
        JSR     OVLBUF-OVL_FILL+FILL_ASCII2ADDR
        BCS     FILL_ERROR
      
    ; Save fill byte
        LDA     INBUFF
        STA     FILL_BYTE
        LDA     INBUFF+1
        STA     FILL_BYTE

    ; Find distance between start and end addresses
    ; fill_dist = end - start + 1
        SEC
        LDA     FILL_END
        SBC     FILL_START 
        STA     FILL_DIST
        LDA     FILL_END+1
        SBC     FILL_START+1
        STA     FILL_DIST+1
    
    ; Quit if fill_end < fill_start
        BMI     FILL_ERROR

    ; Ready to start filling
    ; Initialize to start address
        LDA     FILL_START
        STA     INBUFF
        LDA     FILL_START+1
        STA     INBUFF+1

    ; Loop to fill 
@:      LDA     FILL_BYTE
        LDY     #$00
FILL_LOOP01:
        LDA     FILL_BYTE
        STA     (INBUFF),Y

    ; Exit loop if inbuff >= fill_end
        LDA     INBUFF
        CMP     FILL_END
        LDA     INBUFF+1
        SBC     FILL_END+1
        BCS     FILL_QUIT

    ; Increment address
        CLC
        LDA     #$01
        ADC     INBUFF
        STA     INBUFF
        BCC     @+
        INC     INBUFF+1

    ; Do again
@:      JMP     OVLBUF-OVL_FILL+FILL_LOOP01

FILL_QUIT:
        RTS

FILL_ASCII2ADDR:
        TAY
        CLC
        ADC     #$04
        STA     RBUF
        JSR     ASCII2ADDR
        RTS

FILL_ERROR_STR:
        .BYTE   'FILL START END XX',EOL

        .ALIGN SECTOR_SIZE, $00     ; Align to ATR sector
END_OVL_FILL:
;---------------------------------------
OVL_HELP:
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

    ; Convert lower-case to upper-case
        JSR     TOUPPER
        STA     OVLBUF-OVL_HELP+HELP_ARTICLE,X
        INX
        INY
        BNE     HELP_LOOP1  ; Always true

    ; Append .DOC extension to article name
HELP_EXT:
        .BYTE   '.DOC',EOL,$00

HELP_NEXT1:
        LDY     #$00

HELP_LOOP2:
        LDA     OVLBUF-OVL_HELP+HELP_EXT,Y
        STA     OVLBUF-OVL_HELP+HELP_ARTICLE,X  ; Store null term too
        BEQ     HELP_NEXT2      ; Skip ahead if terminator
        INX
        INY
        BNE     HELP_LOOP2  ; Always true

HELP_NEXT2:
    ; Copy URL to LNBUF
        LDX     #$00    ; Index to start of HELP_URL
        LDY     #$05    ; Index to start at arg1 for "TYPE "

HELP_LOOP3:
        LDA     OVLBUF-OVL_HELP+HELP_URL,X  ; Get source byte
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
        .BYTE   'N8:HTTPS://raw.githubusercontent.com/michaelsternberg/fujinet-nhandler/nos/nos/HELP/'

HELP_ARTICLE:
    :24 .BYTE   $00

        .ALIGN SECTOR_SIZE, $00     ; Align to ATR sector
END_OVL_HELP:

;---------------------------------------
OVL_NCOPY:
;---------------------------------------
    ; Check if an arg exists
        LDY     CMDSEP          ; Check if there's any args
        BEQ     NCOPY_ERROR     ; No. Show usage and quit

    ; Default to Open with Truncate
    ; Later, if we find 'A' as 3rd arg
    ; Then we'll change the mode to Append
        LDA     #$08            ; Open with Truncate mode
        STA     WRITEMODE

    ; Find comma, convert comma to EOL
        JSR     PARSE_COMMAS

    ; Check if 3rd arg exists
        LDY     CMDSEP+2
        BEQ     NCOPY_ARG2

    ; Here if 3rd arg found
    ; Is it an A (for APPEND option)?
        LDA     (INBUFF),Y
        JSR     TOUPPER
        CMP     #'A'
        BNE     NCOPY_ARG2
        INY
        LDA     (INBUFF),Y
        CMP     #EOL
        BNE     NCOPY_ARG2
        LDA     #$09            ; Open with Append mode
        STA     WRITEMODE

NCOPY_ARG2:
    ; Check if 2nd arg exists
        LDX     #$02            ; Used later for counting colon test passes 
        LDY     CMDSEP+1        ; Check if there's any args
        BEQ     NCOPY_ERROR     ; No. Show usage and quit
        LDA     (INBUFF),Y
        CMP     #EOL            ; Check if arg2 is empty
        BNE     NCOPY_NEXT0

NCOPY_ERROR:
        LDA     #<(OVLBUF-OVL_NCOPY+NCOPY_ERROR_STR)
        LDY     #>(OVLBUF-OVL_NCOPY+NCOPY_ERROR_STR)
        JMP     PRINT_STRING

NCOPY_ERROR_STR:
        .BYTE   'NCOPY FROM,TO[,A]',EOL

NCOPY_NEXT0:
    ; Check if 2nd arg ends in '/'
    ; First find end of 2nd arg
        DEY
NCOPY_LOOP:
        INY     
        LDA     (INBUFF),Y
        CMP     #EOL
        BNE     NCOPY_LOOP

    ; Check if prev char is '/'
        DEY
        LDA     (INBUFF),Y
        CMP     #'/'
        BNE     NCOPY_IS_NEOL
        INY
        BNE     NCOPY_JUMP

NCOPY_IS_NEOL:
    ; Check if 2nd arg is in the form of N:<EOL> or Nn:<EOL>
        LDY     CMDSEP+1
        LDA     (INBUFF),Y      ; First, does arg start with "N"?
        CMP     #'N'            ;
        BNE     NCOPY_NEXT_A    ; No. Give up and skip ahead.

    ; Is next char :?
NCOPY_IS_COLON:
        INY                     ; Advance to next char in arg
        LDA     (INBUFF),Y      ; 
        CMP     #':'            ; 
        BEQ     NCOPY_NEXT01    ; Yes, it's a ":", skip ahead 

        DEX                     ; Test this only 2 times
        BEQ     NCOPY_NEXT_A    ; No. Give up and skip ahead
        
    ; Is char digit (0-4)?
        CMP     #'0'
        BCC     NCOPY_NEXT_A
        CMP     #'4'
        BCS     NCOPY_NEXT_A

    ; Here if Nn. Jump back to check if next char is ':'
        BCC     NCOPY_IS_COLON
        
    ; Here if Nn: or N: 
    ; Is next char EOL?
NCOPY_NEXT01:
        INY                     ; Advance to next char in arg
        LDA     (INBUFF),Y      ;
        CMP     #EOL            ; Is the arg just Nn:<EOL> / N:<EOL>?
        BNE     NCOPY_NEXT_A    ; No. Give up and skip ahead.

    ; Here if Nn:<EOL> or N:<EOL>
    ; Copy source filename to target
    ; So, say, N1:<EOL> becomes N1:MYFILE<EOL>
NCOPY_JUMP:
        STY     OVLBUF-OVL_NCOPY+NCOPY_POS       ; Current target file offset
        LDX     CMDSEP          ; Get offset to beginning of filename

NCOPY_LOOP0:
        LDA     $0582,X
        CMP     #'/'            ; if '/' or
        BEQ     NCOPY_RESET_OFFSET
        CMP     #':'            ; if ':' then erase path so far
        BNE     NCOPY_CONTINUE
NCOPY_RESET_OFFSET:
        LDY     OVLBUF-OVL_NCOPY+NCOPY_POS
;        DEY
    BNE     @+
NCOPY_CONTINUE:
        STA     (INBUFF),Y
        INY
@:
        INX
        CMP     #EOL
        BNE     NCOPY_LOOP0
        
NCOPY_NEXT_A:
        CLC
        LDA     CMDSEP
        ADC     INBUFF
        STA     INBUFF
        BCC     NCOPY_NEXT_B
        INC     INBUFF+1

    ; Prepend Drive to source file (if necessary)
NCOPY_NEXT_B:
        JSR     PREPEND_DRIVE
        JMP     DO_NCOPY1           ; Load next portion of code and run it

NCOPY_POS:
        .BYTE   $00

        .ALIGN SECTOR_SIZE, $00     ; Align to ATR sector
END_OVL_NCOPY:

;---------------------------------------
OVL_NCOPY1:
;---------------------------------------
    ; Save copy source to TBUF.
    ; Needed for string comparison later between source and target
    ; Parsing target may clobber part of source string 
    ; where it currently is.
        LDY     #$FF
NCOPY_LOOP1:
        INY
        LDA     (INBUFF),Y
        STA     TBUF,Y
        CMP     #EOL
        BNE     NCOPY_LOOP1

;    ; Check if Channel 1 should be closed prior to opening
;        LDX     #$10            ; Channel 1
;        LDA     IOCB,X          ; Will be $FF if closed
;        BMI     NCOPY_NEXT1     ; Skip if already closed
;        JSR     CIOCLOSE

    ; Open source file for read
NCOPY_NEXT1:
;        LDX     #$10            ; Channel 1
        JSR     NEXT_IOCB
        BCC     @+
        RTS

@:      STX     SOURCE_IOCB
        LDY     #$04            ; Open for read
        JSR     CIOOPEN
        CPY     #$80
        BCC     NCOPY_NEXT2
        JSR     PRINT_ERROR
        JMP     OVLBUF-OVL_NCOPY1+NCOPY_CLOSE

NCOPY_NEXT2:
    ; Change INBUFF to point to target filename
        CLC
        LDA     #<LNBUF         ; Low byte of line buffer
        ADC     CMDSEP+1        ; Offset to start of arg 2
        STA     INBUFF          ; Store it in pointer address
        BCC     NCOPY_NEXT3A
        INC     INBUFF+1

    ; Prepend Drive to target file
NCOPY_NEXT3A:
    ; Do no prepend drive if another device is specified
    ; such as P:, P1:, E:
        LDY     #$00
        LDA     (INBUFF),Y
        CMP     #'N'
        BEQ     NCOPY_NEXT3B    ; If 1st char is N, proceed, stop checking
        INY
        LDA     (INBUFF),Y      ; If 2nd char is :, skip filename processing
        CMP     #':'
        BEQ     NCOPY_OPEN_20
        INY
        LDA     (INBUFF),Y
        CMP     #':'            ; If 3rd char is :, skip filename procssing
        BEQ     NCOPY_OPEN_20

NCOPY_NEXT3B:
        JSR     PREPEND_DRIVE 
        LDY     #$00            ; Check if N: device
        LDA     (INBUFF),Y
        CMP     #'N'
        BNE     NCOPY_OPEN_20   ; No? Skip ahead.

    ; Compare source and target. Quit if the same.
    ; Note: this is a very limited comparison. If
    ; the source and target have different paths
    ; but point to the same file then the source will
    ; get clobbered when the target is opened for write.
    ; A work-around would to open the target for read and
    ; fail if successful, that is, the target already 
    ; exists when it shouldn't. An exception would be needed
    ; for append mode.
        LDY     #$FF
NCOPY_LOOP2:
        INY
        LDA     (INBUFF),Y
        CMP     TBUF,Y
        BNE     NCOPY_NEXT4
        CMP     #EOL
        BEQ     NCOPY_SAME_ERR
        BNE     NCOPY_LOOP2

    ; Source and target are the same file. Quit
NCOPY_SAME_ERR:
        LDA     #<(OVLBUF-OVL_NCOPY1+NCOPY_SAME_TXT)
        LDY     #>(OVLBUF-OVL_NCOPY1+NCOPY_SAME_TXT)
        JSR     PRINT_STRING
        JMP     OVLBUF-OVL_NCOPY1+NCOPY_CLOSE
        
NCOPY_NEXT4:
    ; Get NPWD of target
        LDY     #$01
        LDA     (INBUFF),Y      ; Get n in Nn: for target
        AND     #$0F            ; Convert '2' to 2
        TAX                     ; X needs to have DUNIT
        JSR     NPWD_ENTRY

    ; Find location of EOL for NPWD
        LDX     #$FF
NCOPY_LOOP3:
        INX
        LDA     RBUF,X
        CMP     #EOL
        BNE     NCOPY_LOOP3

    ; Copy target file to tail of NPWD
        DEX             ; Step back 1 char pos
        LDY     #$02    ; Point to 1 char before filename
NCOPY_LOOP4:
        INY
        INX
        LDA     (INBUFF),Y
        STA     RBUF,X
        CMP     #EOL
        BNE     NCOPY_LOOP4

    ; Copy N8: to the start of the path
        LDY     #$02
NCOPY_LOOP5:
        LDA     OVLBUF-OVL_NCOPY1+NCOPY_N8,Y
        STA     RBUF-3,Y
        DEY
        BPL     NCOPY_LOOP5

    ; Use new path found in RBUF for filename
        LDA     #<(RBUF-3)
        STA     INBUFF
        LDA     #>(RBUF-3)
        STA     INBUFF+1

NCOPY_OPEN_20:
    ; Open target file
        JSR     NEXT_IOCB   ; On return, X will be like $20
        BCS     NCOPY_QUIT1 ; On failure, close source IOCB and quit
        STX     TARGET_IOCB
        LDY     WRITEMODE   ; 8=truncate 9=append
        JSR     CIOOPEN
        CPY     #$80        ; Check for error
        BCC     NCOPY_CONT  ; Jump ahead if no error
        JSR     PRINT_ERROR 
        JMP     OVLBUF-OVL_NCOPY1+NCOPY_CLOSE   ; Close IOCBs and exit

    ; We've run out of space at OVLBUF
    ; Process the next part as another 
    ; overlay command.

NCOPY_CONT:
        LDA     #$FF        ; Clear prev overlay id
        STA     OVLPRV      ; to avoid caching confusion
        JMP     DO_NCOPY2

    ; Close routine
NCOPY_CLOSE:
        LDX     TARGET_IOCB
        JSR     CIOCLOSE
NCOPY_QUIT1:
        LDX     SOURCE_IOCB
        JSR     CIOCLOSE
NCOPY_QUIT2:
        RTS


NCOPY_SAME_TXT:
        .BYTE   'SAME FILE?',EOL

NCOPY_N8:
        .BYTE   'N8:'

        .ALIGN SECTOR_SIZE, $00     ; Align to ATR sector
END_OVL_NCOPY1:

;---------------------------------------
OVL_NCOPY2:
;---------------------------------------
        LDA     #$00
        STA     OVLBUF-OVL_NCOPY2+NCOPY2_LOOP_FLG

    ; Use the 2nd half of the Overlay buffer
    ; to store data in transit
        LDA     #<(OVLBUF+$80)
        STA     INBUFF
        LDA     #>(OVLBUF+$80)
        STA     INBUFF+1

NCOPY2_NEXT2:
        LDX     SOURCE_IOCB         ; X will be like $10
        LDA     #$80
        LDY     #$00                ; Request $0080  bytes
        JSR     CIOGET
        BPL     NCOPY2_WRITE

    ; Here if error code, if not EOF, print error and bail
        CPY     #136                ; EOF?
        BEQ     NCOPY2_EOF_FOUND    ; Yes, skip ahead

    ; Here of error code other than EOF
        JSR     PRINT_ERROR
        BNE     NCOPY2_CLOSE

NCOPY2_EOF_FOUND:
        STY     OVLBUF-OVL_NCOPY2+NCOPY2_LOOP_FLG
    ; Presumably we've reached the EOF
    ; Self-modify code ahead to adjust
    ; for the remaining bytes
        LDX     SOURCE_IOCB         ; X will be like $10
        LDA     ICBLL,X   ; Remaining bytes found in IOCB
        STA     OVLBUF-OVL_NCOPY2+NCOPY2_ICBLL+1

NCOPY2_WRITE:
        LDX     TARGET_IOCB         ; X will be like $10
NCOPY2_ICBLL:
        LDA     #$80
        LDY     #$00
        JSR     CIOPUT
        LDA     OVLBUF-OVL_NCOPY2+NCOPY2_LOOP_FLG
        BEQ     NCOPY2_NEXT2

NCOPY2_CLOSE:
        LDX     SOURCE_IOCB         ; X will be like $10
        JSR     CIOCLOSE
        LDX     TARGET_IOCB         ; X will be like $20
        JMP     CIOCLOSE

NCOPY2_LOOP_FLG:
        .BYTE  $00

        .ALIGN SECTOR_SIZE, $00     ; Align to ATR sector
END_OVL_NCOPY2:

;---------------------------------------
OVL_NTRANS:
;---------------------------------------
    ; Tell the FujiNet how to translate (or not) end-of-line
    ; characters between the ATARI and the remote computer
    ;---------------------------------------
        LDX     CMDSEP          ; Check if there's any args
        BEQ     NTRANS_ERROR    ; No. Show usage and quit

        LDA     DOSDR           ; Go with current drive for now
        ;STA     OVLBUF-OVL_NTRANS+NTRDCB+DCB_IDX.DUNIT    ; it'll be overwritten later if req'd
        STA     NTRDCB+DCB_IDX.DUNIT    ; it'll be overwritten later if req'd

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
        ;STA     OVLBUF-OVL_NTRANS+NTRDCB+DCB_IDX.DUNIT
        STA     NTRDCB+DCB_IDX.DUNIT
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
        ;STA     OVLBUF-OVL_NTRANS+NTRDCB+DCB_IDX.DAUX2    ; Assign parameter to DCB
        STA     NTRDCB+DCB_IDX.DAUX2    ; Assign parameter to DCB

    ;---------------------------------------
    ; Call SIO
    ;---------------------------------------
NTRANS_CALL:
        LDA     #<NTRDCB        ; DCB can't be in Overlay
        LDY     #>NTRDCB        ; as it is used by DO_LOAD
        JSR     DOSIOV
        JMP     PRINT_ERROR

NTRANS_ERROR:
        LDA     #<(OVLBUF-OVL_NTRANS+NTRANS_ERROR_STR)
        LDY     #>(OVLBUF-OVL_NTRANS+NTRANS_ERROR_STR)
        JMP     PRINT_STRING

NTRANS_ERROR_STR:
        .BYTE   'MODE? 0=NONE, 1=CR, 2=LF, 3=CR/LF',EOL

        .ALIGN SECTOR_SIZE, $00     ; Align to ATR sector
END_OVL_NTRANS:

;---------------------------------------
OVL_REENTER:
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

        LDA     #<(OVLBUF-OVL_REENTER+DO_REENTER_ERR)
        LDY     #>(OVLBUF-OVL_REENTER+DO_REENTER_ERR)
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

        .ALIGN SECTOR_SIZE, $00     ; Align to ATR sector
END_OVL_REENTER:

;---------------------------------------
OVL_SAVE:
;---------------------------------------
    ; INBUFF points to Filename
    ; LNBUF,Y is start of 4 char ASCII hex string
    ;---------------------------------------

    ;---------------------------------------------
    ; Convert commas to EOLs & store offsets in CMDSEP[I]
    ;---------------------------------------------
        JSR     PARSE_COMMAS
    ;---------------------------------------------
    ; Convert hex strings in arg list to lo/hi pairs
    ;---------------------------------------------
        LDX     #$00            ; Index to TBUF,X for output
        LDY     #$01            ; Index to CMDSEP for list of addr strings
    ;---------------------------------------------
    ; Prep 'ascii to addr' subroutine inputs
    ;---------------------------------------------
SAVE_LOOP:
        LDA     SAVE_ADDR_FLG,Y
        AND     COMMA_ARGS_BITFIELD
        BEQ     SAVE_SKIP       ; If arg is null then skip
        TYA
        PHA
        LDA     CMDSEP,Y
        TAY                     ; Y -> offset into CMDSEP
        CLC
        ADC     #$04            ; offset to end of arg
        STA     RBUF
    ;---------------------------------------------
    ; Call 'ascii to addr' subroutine
    ;---------------------------------------------
        TXA
        PHA
        JSR     ASCII2ADDR      ; Y contains offset into LNBUF
        PLA
        TAX
        PLA
        TAY
        BCS     SAVE_USAGE      ; Quit if invalid addr
    ;---------------------------------------------
    ; Save conversion function outputs (lo/hi)
    ;---------------------------------------------
        LDA     INBUFF          ; Get lo byte
        STA     STL,X           ; Store output of ASCII2ADDR (STL = Start Addr Lo)
        LDA     INBUFF+1        ; Get hi byte
        STA     STL+1,X         ; Store output of ASCII2ADDR
SAVE_SKIP:
        INX
        INX
        INY
        CPY     #$05
        BNE     SAVE_LOOP

    ;---------------------------------------------
    ; Quit if required filename, start, end addr not provided
    ;---------------------------------------------
        LDA     #%00000111      ; bit 0->filename bit 1->start bit 2->end
        AND     COMMA_ARGS_BITFIELD
        CMP     #%00000111      ; Quit if not all 3 provided
        BEQ     SAVE_SKIP2

SAVE_USAGE:
        LDA     #<SAVE_ERROR_STR
        LDY     #>SAVE_ERROR_STR
        JMP     PRINT_STRING

SAVE_SKIP2:
    ; Calc header (Result in BLL,BLH)
        JSR     LOAD_BUFLEN

        LDX     #$04
@:      LDA     STL,X
        STA     SAVE_HEADER+2,X
        DEX
        BPL     @-

        LDA     BLL
        STA     SAVE_HEADER+6
        LDA     BLH
        STA     SAVE_HEADER+7

   ; Save initad (this may contain garbage but will be skipped if unnecessary)
        LDA     INITADL
        STA     SAVE_INIT+4
        LDA     INITADH
        STA     SAVE_INIT+5

    ; Save runad (this may contain garbage but will be skipped if unnecessary)
        LDA     RUNADL
        STA     SAVE_RUN+4
        LDA     RUNADH
        STA     SAVE_RUN+5

    ;---------------------------------------------
    ; Get filename
    ;---------------------------------------------
        JSR     GET_DOSDR
        JSR     PREPEND_DRIVE

;    ; Open file for write
;        LDX     #$10
;        JSR     CIOCLOSE

    ; Inbuff already contains filename
;        LDX     #$10
        JSR     NEXT_IOCB       ; Get next available IOCB channel
        BCC     @+              ; Carry set if no available channels
        RTS                     ; Quit
@:      STX     TARGET_IOCB     ; X will be like $100
        LDY     #OOUTPUT
        JSR     CIOOPEN

    ; Save binary file header
;        LDX     #$10
        LDX     TARGET_IOCB
        LDA     #<SAVE_HEADER
        STA     INBUFF
        LDA     #>SAVE_HEADER
        STA     INBUFF+1
        LDA     #$06            ; A = ICBLL
        LDY     #$00            ; Y = ICBLH
        JSR     CIOPUT
        JSR     PRINT_ERROR

    ; Save binary payload
        ;LDX     #$10
        LDX     TARGET_IOCB
        LDA     SAVE_HEADER+2   ; Start Address (Lo)
        STA     INBUFF
        LDA     SAVE_HEADER+3   ; Start Address (Hi)
        STA     INBUFF+1
        LDA     SAVE_HEADER+6   ; BLL
        LDY     SAVE_HEADER+7   ; BLH
        JSR     CIOPUT
        JSR     PRINT_ERROR

    ; Optionally save init address block
        LDA     #%00001000
        AND     COMMA_ARGS_BITFIELD
        BEQ     DO_SAVE_RUNAD

        ;LDX     #$10
        LDX     TARGET_IOCB
        LDA     #<SAVE_INIT
        STA     INBUFF
        LDA     #>SAVE_INIT
        STA     INBUFF+1
        LDA     #$06        ; Writing 6 bytes
        LDY     #$00
        JSR     CIOPUT
        JSR     PRINT_ERROR

    ; Optionally save run address block
DO_SAVE_RUNAD:
        LDA     #%00010000
        AND     COMMA_ARGS_BITFIELD
        BEQ     DO_SAVE_QUIT

        ;LDX     #$10
        LDX     TARGET_IOCB
        LDA     #<SAVE_RUN
        STA     INBUFF
        LDA     #>SAVE_RUN
        STA     INBUFF+1
        LDA     #$06        ; Writing 6 bytes
        LDY     #$00
        JSR     CIOPUT
        JSR     PRINT_ERROR

DO_SAVE_QUIT:
        ;LDX     #$10
        LDX     TARGET_IOCB
        JSR     CIOCLOSE

        RTS

        .ALIGN SECTOR_SIZE, $00     ; Align to ATR sector
END_OVL_SAVE:

;---------------------------------------
OVL_XEP:
;---------------------------------------
        LDY     #$19        ; CMD = $19 (enter 40 col)
        LDX     CMDSEP
        LDA     LNBUF,X
        CMP     #'4'
        BEQ     @+
        DEY                 ; CMD = $18 (enter 80 col)
@:
        LDX     #$00
        TYA
        STA     ICCOM,X
        LDA     #<(OVLBUF-OVL_XEP+EDEV)
        STA     ICBAL,X
        LDA     #>(OVLBUF-OVL_XEP+EDEV)
        STA     ICBAH,X
        LDA     #$2C
        STA     ICAX1,X
        LDA     #$00
        STA     ICAX2,X
        JSR     CIOV
        JMP     DO_CLS

EDEV:   .BYTE   "E:",EOL
        .ALIGN SECTOR_SIZE, $00     ; Align to ATR sector
END_OVL_XEP:


; =================================================================
; VTOC and Directory
;

; $10 is the added ATR-header
:($B390-*+HDR-$10) DTA $00
VTOCSTA:
    DTA $02,$BD,$02
VTOCEND:

; Fill the remaining bytes of the VTOC sector
    :($80+VTOCSTA-VTOCEND) DTA $00

DIRSTA:
    DTA $60,$C3,$02,$04,$00,C"0**********"
    DTA $60,$C3,$02,$04,$00,C"1 FujiNet  "
    DTA $60,$C3,$02,$04,$00,C"2 Network  "
    DTA $60,$C3,$02,$04,$00,C"3   OS     "
    DTA $60,$C3,$02,$04,$00,C"4          "
    DTA $60,$C3,$02,$04,$00,C"5  v0.7.1  "
    DTA $60,$C3,$02,$04,$00,C"6          "
    DTA $60,$C3,$02,$04,$00,C"7**********"
    DTA $C0
DIREND:

; Fill the remaining sectors of the directory
;    :($400+DIRSTA-DIREND) DTA $00
    :($400+DIRSTA-DIREND) DTA $A0

; Sectors behind directory
;    :($80*352) DTA $00
    :($80*352) DTA $C0

       END
