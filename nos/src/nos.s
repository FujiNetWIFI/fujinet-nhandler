        
        ;; Compile with MADS

        ;; Authors: Thomas Cherryhomes
        ;;   <thom.cherryhomes@gmail.com>

        ;; Michael Sternberg
        ;;   <mhsternberg@gmail.com>


        ;; Optimizations being done by djaybee!
        ;; Thank you so much!


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
MAX_APPKEY_LEN = $42    ; Used with appkey files (2 byte len + 64 bytes)

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
;CMD_COPY            = $A1
CMD_DIR             = $02
CMD_DEL             = $21
CMD_LOAD            = $28
CMD_LOCK            = $23
CMD_LPR             = BOGUS
CMD_MKDIR           = $2A
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
	    ORG	    $06f0
        OPT     h-
	    DTA	    $96,$02,$80,$16,$80
:11     DTA	    $00

;;; Initialization ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HDR:    .BYTE   $00                 ; BLFAG: Boot flag equals zero (unused)
        .BYTE   [BOOTEND-HDR]/128   ; BRCNT: Number of consecutive sectors to read
        .WORD   HDR                 ; BLDADR: Boot sector load address ($700).
        .WORD   $E4C0               ; BIWTARR: Init addr (addr of RTS in ROM)

	    JMP	    START

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
    ; INBUFF contains ICBAL/H (filename)
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
        JSR     PRINT_ERROR

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

    ; Convert char in A from upper-case to lower-case
TOUPPER:
        CMP     #'a'        ; SKip if < 'a'
        BCC     @+
        CMP     #'z'+1      ; Skip if > 'z'
        BCS     @+
        AND     #$5F        ; Disable high-bit and convert to lower
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
        LDA     #<NOBASIC_ERROR_STR
        LDY     #>NOBASIC_ERROR_STR
        JSR     PRINT_STRING
        SEC
        RTS

NOBASIC_ERROR_STR:
        .BYTE   'NO BUILT-IN BASIC',EOL

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

        CMP     #CMD_USER       ; Skip prepending devspec for SSH
        BEQ     DO_GENERIC_NEXT
        CMP     #CMD_PASS
        BEQ     DO_GENERIC_NEXT

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
        STA     STADCB+1        ; Yes. Status (not typo)
;        STA     GENDCB+1   ; 20221105 - commented-out. checking for bug...
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

;;---------------------------------------
;DO_COPY:
;;---------------------------------------
;        LDA     #$B0
;        STA     COLOR2
;        RTS

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
    ; Loop if more data to read
    ;---------------------------------------
        LDA     DVSTAT+1    ; Was there more to read (that is, was hi>0)?
        BNE     DIR_LOOP    ; If yes, then do it again

DIR_NEXT:
        LDA     #$FF        ; Clear key
        STA     CH
        JMP     DIR_CLOSE

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
        STX     DIRODCB+1   ; DUNIT for Open
        STX     STADCB+1    ; DUNIT for Status
        STX     DIRRDCB+1   ; DUNIT for Read
        STX     CLODCB+1    ; DUNIT for Close
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

;---------------------------------------
DIR_ERROR:
;---------------------------------------
        LDA     #<DIR_ERROR_STR
        LDY     #>DIR_ERROR_STR
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
    ; Load 2 bytes into Buffer (BAL/H).
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

;;---------------------------------------
;LOAD_GETDAT:
;;---------------------------------------
;
;    ;---------------------------------------
;    ; Fill out the DCB
;    ;---------------------------------------
;        JSR     GET_DOSDR
;        STX     BINDCB+1        ; DUNIT
;
;        LDA     STL
;        STA     BINDCB+4        ; DBUFL 
;        LDA     STH
;        STA     BINDCB+5        ; DBUFH
;        LDA     BLL
;        STA     BINDCB+8        ; DBYTL
;        STA     BINDCB+10
;        LDA     BLH
;        STA     BINDCB+9        ; DBYTH
;        STA     BINDCB+11
;
;    ;---------------------------------------
;    ; Send Read request to SIO
;    ;---------------------------------------
;        LDA     #<BINDCB
;        LDY     #>BINDCB
;        JSR     DOSIOV
;        JSR     PRINT_ERROR     ; Show any errors
;
;    ;---------------------------------------
;    ; Get status (updates DVSTAT, DSTATS)
;    ;---------------------------------------
;        LDA     BINDCB+1
;        STA     STADCB+1
;        LDA     #<STADCB
;        LDY     #>STADCB
;        JSR     DOSIOV
;
;    ; Check if EOF (current requested chunk completed?)
;        LDA     #EOF
;        CMP     DVSTAT+3
;        BEQ     LOAD_GETDAT_DONE
;        JMP     PRINT_ERROR
;
;LOAD_GETDAT_DONE:
;    ; Check if 0 bytes remaining
;        LDA     DVSTAT
;        BNE     LOAD_GETDAT_DONE2
;        LDA     DVSTAT+1
;        BNE     LOAD_GETDAT_DONE2
;        LDY     #$FF
;        RTS
;
;LOAD_GETDAT_DONE2:
;        LDY     #$01            ; Return success
;        RTS
;        
;BINDCB:
;       .BYTE    DEVIDN      ; DDEVIC
;       .BYTE    $FF         ; DUNIT
;       .BYTE    'R'         ; DCOMND
;       .BYTE    $40         ; DSTATS
;       .BYTE    $FF         ; DBUFL
;       .BYTE    $FF         ; DBUFH
;       .BYTE    $0F         ; DTIMLO
;       .BYTE    $00         ; DRESVD
;       .BYTE    $FF         ; DBYTL
;       .BYTE    $FF         ; DBYTH
;       .BYTE    $FF         ; DAUX1
;       .BYTE    $FF         ; DAUX2

;---------------------------------------
LOAD_GETDAT:
;---------------------------------------
    ; Definitions:
    ; HEAD = requested bytes that will be found in current cache (< 512 bytes)
    ; BODY = contiguous 512 byte sections. BODY = n * 512 bytes)
    ; TAIL = any bytes remaining after BODY (< 512 bytes)

        JSR     GET_DOSDR
        STX     BINDCB+1

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
        LDA     BINDCB+1
        STA     STADCB+1
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


;---------------------------------------
LOAD_CLOSE:
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
DO_LPR:
;---------------------------------------
        LDA     #$B0
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
    ; then skip printing output
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
        .BYTE   DEVIDN  ; DDEVIC
        .BYTE   $FF     ; DUNIT
        .BYTE   'T'     ; DCOMND
        .BYTE   $00     ; DSTATS
        .BYTE   $00     ; DBUFL
        .BYTE   $00     ; DBUFH
        .BYTE   $1F     ; DTIMLO
        .BYTE   $00     ; DRESVD
        .BYTE   $00     ; DBYTL
        .BYTE   $00     ; DBYTH
        .BYTE   $00     ; DAUX1
        .BYTE   $00     ; DAUX2

; End of DO_NTRANS
;---------------------------------------

;---------------------------------------
DO_AUTORUN:
;---------------------------------------
    ; Change URL stored in AUTORUN app key
    ;-----------------------------------
        LDA     CMDSEP          ; Check if there's any arg
        BNE     AUTORUN_NEXT1   ; If arg found, skip ahead

    ; Here if no command line arg found
    ; Print error message and exit
        LDA     #<AUTORUN_ERROR_STR
        LDY     #>AUTORUN_ERROR_STR
        JMP     PRINT_STRING

AUTORUN_NEXT1:
    ; Point to start of arg on command line
        CLC
        ADC     INBUFF          ; INBUFF += CMDSEP
        STA     INBUFF
        STA     APPKEYWRITEDCB+4

    ; If "AUTORUN ?" Then abuse AUTORUN_SUBMIT to print appkey
        LDY     #$00
        LDA     #'?'
        STA     AUTORUN_QUERY_FLG
        CMP     (INBUFF),Y
        BEQ     SUBMIT_AUTORUN

    ; Open app key
        LDA     #$01            ; Open for write (1)
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
        STY     APPKEYWRITEDCB+10   ; Y = strlen
        LDA     #<APPKEYWRITEDCB
        LDY     #>APPKEYWRITEDCB
        JSR     DOSIOV

    ; Close app key
        LDA     #<APPKEYCLOSEDCB
        LDY     #>APPKEYCLOSEDCB
        JMP     DOSIOV

AUTORUN_ERROR_STR:
        .BYTE   'PATH?',EOL

AUTORUN_APPKEY:
        .WORD   $DB79           ; creator ID
        .BYTE   $00             ; app ID
        .BYTE   $00             ; key ID
        .BYTE   $00             ; read or write mode
        .BYTE   $00             ; unused

APPKEYCLOSEDCB:
        .BYTE   $70             ; DDEVIC
        .BYTE   $01             ; DUNIT
        .BYTE   $DB             ; DCOMND
        .BYTE   $00             ; DSTATS
        .BYTE   $00             ; DBUFL
        .BYTE   $00             ; DBUFH
        .BYTE   $0F             ; DTIMLO
        .BYTE   $00             ; DRESVD
        .BYTE   $00             ; DBYTL
        .BYTE   $00             ; DBYTH
        .BYTE   $00             ; DAUX1
        .BYTE   $00             ; DAUX2

APPKEYOPENDCB:
        .BYTE   $70             ; DDEVIC
        .BYTE   $01             ; DUNIT
        .BYTE   $DC             ; DCOMND
        .BYTE   $80             ; DSTATS
        .BYTE   <AUTORUN_APPKEY ; DBUFL
        .BYTE   >AUTORUN_APPKEY ; DBUFH
        .BYTE   $0F             ; DTIMLO
        .BYTE   $00             ; DRESVD
        .BYTE   $06             ; DBYTL
        .BYTE   $00             ; DBYTH
        .BYTE   $00             ; DAUX1
        .BYTE   $00             ; DAUX2

APPKEYREADDCB:
        .BYTE   $70             ; DDEVIC
        .BYTE   $01             ; DUNIT
        .BYTE   $DD             ; DCOMND
        .BYTE   $40             ; DSTATS
        .BYTE   <LNBUF          ; DBUFL
        .BYTE   >LNBUF          ; DBUFH
        .BYTE   $01             ; DTIMLO - minimize timeout
        .BYTE   $00             ; DRESVD
        .BYTE   MAX_APPKEY_LEN  ; DBYTL
        .BYTE   $00             ; DBYTH
        .BYTE   $00             ; DAUX1
        .BYTE   $00             ; DAUX2

APPKEYWRITEDCB:
        .BYTE   $70             ; DDEVIC
        .BYTE   $01             ; DUNIT
        .BYTE   $DE             ; DCOMND
        .BYTE   $80             ; DSTATS
        .BYTE   $FF             ; DBUFL
        .BYTE   $05             ; DBUFH (expect page 5)
        .BYTE   $0F             ; DTIMLO
        .BYTE   $00             ; DRESVD
        .BYTE   MAX_APPKEY_LEN  ; DBYTL
        .BYTE   $00             ; DBYTH
        .BYTE   $FF             ; DAUX1 (# actual bytes)
        .BYTE   $00             ; DAUX2

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

    ; Assert FILE #1 is closed
        LDX     #$10
        JSR     CIOCLOSE
        
    ; OPEN #1, 4, 0, file path
        LDX     #$10            ; File #1
        LDY     #$04            ; Open for input
        JSR     CIOOPEN         ; Open filename @ (INBUFF)
        BPL     SUBMIT_NEXT2
        JMP     PRINT_ERROR

    ; Read batch file character by character
    ; This allows it be end-of-line agnostic
    ; Branch forward when an end-of-line is interpretted.

SUBMIT_NEXT2:
        JSR     LDBUFA      ; Reset INBUFF to $0580
        DEC     INBUFF      ; Init 1 byte before buffer
        LDA     #$FF        ; Clear command
        STA     CMD

SUBMIT_GETCH:
        INC     INBUFF          ; Advance pointer
        BNE     SUBMIT_NEXT3
        INC     INBUFF+1

SUBMIT_NEXT3:
        LDX     #$10            ; OPEN #1
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
        LDX     #$10            ; Channel #1
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

SUBMIT_DONE
        LDX     #$10
        JMP     CIOCLOSE

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
        LDX     #$10            ; IOCB offset (channel)
        LDA     #$01            ; ICBLL (buffer length lo) Request 1 byte
        LDY     #$00            ; ICBLH (buffer length hi)
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
        JMP     TYPE_LOOP
        
TYPE_DONE:
        LDA     #$FF
        STA     CH
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

    ; Convert lower-case to upper-case
        JSR     TOUPPER
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
    ; Copy URL to LNBUF
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
        .BYTE   'N8:HTTPS://raw.githubusercontent.com/michaelsternberg/fujinet-nhandler/nos/nos/HELP/'

HELP_ARTICLE:
    :24 .BYTE   $00

;---------------------------------------
DO_BASIC:
;---------------------------------------
    ; Enable or disable BASIC (or, say, U1MB ROM)
    ; Usage: [BASIC|ROM] [ON|OFF]
    
    ; Quit if no internal BASIC
        JSR     CHECK_INTERNAL_BASIC
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
        LDA     #<BASIC_ERROR
        LDY     #>BASIC_ERROR
        JMP     PRINT_STRING

BASIC_ERROR:
        .BYTE   '[BASIC|ROM] [ON|OFF]',EOL

;;---------------------------------------
;DO_NOBASIC:
;;---------------------------------------
;        JSR     CHECK_INTERNAL_BASIC
;        BCS     NOBASIC_QUIT


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
        TAY                 ; Offset to arg used later
        CLC
        ADC     #$04
        STA     RBUF

        JSR     ASCII2ADDR  ; Convert text to an addr
        BCS     DO_REM      ; Re-use nearby RTS
        
        JMP     (INBUFF)    ;

;---------------------------------------
DO_SAVE:
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
        BNE     @-

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

    ; Open file for write
        LDX     #$10
        JSR     CIOCLOSE

    ; Inbuff already contains filename
        LDX     #$10
        LDY     #OOUTPUT
        JSR     CIOOPEN

    ; Save binary file header
        LDX     #$10
        LDA     #<SAVE_HEADER
        STA     INBUFF
        LDA     #>SAVE_HEADER
        STA     INBUFF+1
        LDA     #$06            ; A = ICBLL
        LDY     #$00            ; Y = ICBLH
        JSR     CIOPUT
        JSR     PRINT_ERROR
        
    ; Save binary payload
        LDX     #$10
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

        LDX     #$10
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

        LDX     #$10
        LDA     #<SAVE_RUN
        STA     INBUFF
        LDA     #>SAVE_RUN
        STA     INBUFF+1
        LDA     #$06        ; Writing 6 bytes
        LDY     #$00
        JSR     CIOPUT
        JSR     PRINT_ERROR

DO_SAVE_QUIT:
        LDX     #$10
        JSR     CIOCLOSE

        RTS

SAVE_ERROR_STR:
        .BYTE   'SAVE Nn:FILE,START,END(,INIT)(,RUN)',EOL

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
;
; End of DO_SAVE
;---------------------------------------

;---------------------------------------
DO_WARM:
;---------------------------------------
        JMP     WARMSV

;---------------------------------------
DO_XEP:
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
        LDA     #<EDEV
        STA     ICBAL,X
        LDA     #>EDEV
        STA     ICBAH,X
        LDA     #$2C
        STA     ICAX1,X
        LDA     #$00
        STA     ICAX2,X
        JSR     CIOV
        JMP     DO_CLS

EDEV:   .BYTE   "E:",EOL
        
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
;               COPY                ;  1
                DIR                 ;  2
                DEL                 ;  3
                LOAD                ;  4
                LOCK                ;  5
                LPR                 ;  6
                MKDIR               ;  7
                NPWD                ;  8
                NTRANS              ;  9
                PASS                ; 10
                RENAME              ; 11
                RMDIR               ; 12
                SAVE                ; 13
                SUBMIT              ; 14
                TYPE                ; 15
                USER                ; 16
                UNLOCK              ; 17
                AUTORUN             ; 18
                CAR                 ; 19
                CLS                 ; 20
                COLD                ; 21
                HELP                ; 22
                BASIC               ; 23
                NOSCREEN            ; 24
                PRINT               ; 25
                REENTER             ; 26
                REM                 ; 27
                RUN                 ; 28
                SCREEN              ; 29
                WARM                ; 20
                XEP                 ; 31
                DRIVE_CHG           ; 32
        .ENDE

CMD_DCOMND:
        .BYTE   CMD_CD              ;  0 NCD
;       .BYTE   CMD_COPY            ;  1 COPY
        .BYTE   CMD_DIR             ;  2 DIR
        .BYTE   CMD_DEL             ;  3 DEL
        .BYTE   CMD_LOAD            ;  4 LOAD
        .BYTE   CMD_LOCK            ;  5 LOCK
        .BYTE   CMD_LPR             ;  6 LPR
        .BYTE   CMD_MKDIR           ;  7 MKDIR
        .BYTE   CMD_NPWD            ;  8 NPWD
        .BYTE   CMD_NTRANS          ;  9 NTRANS
        .BYTE   CMD_PASS            ; 10 PASS
        .BYTE   CMD_RENAME          ; 11 RENAME
        .BYTE   CMD_RMDIR           ; 12 RMDIR
        .BYTE   CMD_SAVE            ; 13 SAVE
        .BYTE   CMD_SUBMIT          ; 14 SUBMIT
        .BYTE   CMD_TYPE            ; 15 TYPE
        .BYTE   CMD_USER            ; 16 USER
        .BYTE   CMD_UNLOCK          ; 17 UNLOCK
        .BYTE   CMD_AUTORUN         ; 18 AUTORUN
        .BYTE   CMD_CAR             ; 19 CAR
        .BYTE   CMD_CLS             ; 20 CLS
        .BYTE   CMD_COLD            ; 21 COLD
        .BYTE   CMD_HELP            ; 22 HELP
        .BYTE   CMD_BASIC           ; 23 BASIC
        .BYTE   CMD_NOSCREEN        ; 24 NOSCREEN
        .BYTE   CMD_PRINT           ; 25 PRINT
        .BYTE   CMD_REENTER         ; 26 REENTER
        .BYTE   CMD_REM             ; 27 REM
        .BYTE   CMD_RUN             ; 28 RUN
        .BYTE   CMD_SCREEN          ; 29 SCREEN
        .BYTE   CMD_WARM            ; 20 WARM
        .BYTE   CMD_XEP             ; 31 XEP
        .BYTE   CMD_DRIVE_CHG       ; 32

COMMAND:
        .CB     "NCD"               ;  0 NCD
        .BYTE   CMD_IDX.NCD            

;       .CB     "COPY"              ;  1 COPY
;       .BYTE   CMD_IDX.COPY           

        .CB     "DIR"               ;  2 DIR
        .BYTE   CMD_IDX.DIR              

        .CB     "DEL"               ;  3 DEL
        .BYTE   CMD_IDX.DEL              

        .CB     "LOAD"              ;  4 LOAD
        .BYTE   CMD_IDX.LOAD             

        .CB     "LOCK"              ;  5 LOCK
        .BYTE   CMD_IDX.LOCK             

        .CB     "LPR"               ;  6 LPR
        .BYTE   CMD_IDX.LPR              
                                        
        .CB     "MKDIR"             ;  7 MKDIR
        .BYTE   CMD_IDX.MKDIR           
                                        
        .CB     "NPWD"              ;  8 NPWD
        .BYTE   CMD_IDX.NPWD             
                                        
        .CB     "NTRANS"            ;  9 NTRANS
        .BYTE   CMD_IDX.NTRANS            
                                        
        .CB     "PASS"              ; 10 PASS
        .BYTE   CMD_IDX.PASS             
                                         
        .CB     "RENAME"            ; 11 RENAME
        .BYTE   CMD_IDX.RENAME          
                                        
        .CB     "RMDIR"             ; 12 RMDIR
        .BYTE   CMD_IDX.RMDIR           
                                        
        .CB     "SAVE"              ; 13 SAVE
        .BYTE   CMD_IDX.SAVE            
                                         
        .CB     "SUBMIT"            ; 14 SUBMIT
        .BYTE   CMD_IDX.SUBMIT             
                                        
        .CB     "TYPE"              ; 15 TYPE
        .BYTE   CMD_IDX.TYPE                
                                          
        .CB     "USER"              ;  16 USER
        .BYTE   CMD_IDX.USER              
                                        
        .CB     "UNLOCK"            ; 17 UNLOCK
        .BYTE   CMD_IDX.UNLOCK            
                                        
        .CB     "AUTORUN"           ; 18 AUTORUN
        .BYTE   CMD_IDX.AUTORUN           
                                          
        .CB     "CAR"               ; 19 CAR
        .BYTE   CMD_IDX.CAR             
                                        
        .CB     "CLS"               ; 20 CLS
        .BYTE   CMD_IDX.CLS             
                                        
        .CB     "COLD"              ; 21 COLD
        .BYTE   CMD_IDX.COLD              
                                        
        .CB     "HELP"              ; 22 HELP
        .BYTE   CMD_IDX.HELP               

        .CB     "BASIC"             ; 23 NOBASIC
        .BYTE   CMD_IDX.BASIC           
                                        
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

        .CB     "SOURCE"            ; SOURCE = SUBMIT
        .BYTE   CMD_IDX.SUBMIT

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
;       .BYTE   <(DO_COPY-1)        ;  1 COPY
        .BYTE   <(DO_DIR-1)         ;  2 DIR
        .BYTE   <(DO_GENERIC-1)     ;  3 DEL
        .BYTE   <(DO_LOAD-1)        ;  4 LOAD
        .BYTE   <(DO_GENERIC-1)     ;  5 LOCK
        .BYTE   <(DO_LPR-1)         ;  6 LPR
        .BYTE   <(DO_GENERIC-1)     ;  7 MKDIR
        .BYTE   <(DO_NPWD-1)        ;  8 NPWD
        .BYTE   <(DO_NTRANS-1)      ;  9 NTRANS
        .BYTE   <(DO_GENERIC-1)     ; 10 PASS
        .BYTE   <(DO_GENERIC-1)     ; 11 RENAME
        .BYTE   <(DO_GENERIC-1)     ; 12 RMDIR
        .BYTE   <(DO_SAVE-1)        ; 13 SAVE
        .BYTE   <(DO_SUBMIT-1)      ; 14 SUBMIT
        .BYTE   <(DO_TYPE-1)        ; 15 TYPE
        .BYTE   <(DO_GENERIC-1)     ; 16 USER
        .BYTE   <(DO_GENERIC-1)     ; 17 UNLOCK
        .BYTE   <(DO_AUTORUN-1)     ; 18 AUTORUN
        .BYTE   <(DO_CAR-1)         ; 19 CAR
        .BYTE   <(DO_CLS-1)         ; 20 CLS
        .BYTE   <(DO_COLD-1)        ; 21 COLD
        .BYTE   <(DO_HELP-1)        ; 22 HELP
        .BYTE   <(DO_BASIC-1)       ; 23 BASIC
        .BYTE   <(DO_NOSCREEN-1)    ; 24 NOSCREEN
        .BYTE   <(DO_PRINT-1)       ; 25 PRINT
        .BYTE   <(DO_REENTER-1)     ; 26 REENTER
        .BYTE   <(DO_REM-1)         ; 27 REM
        .BYTE   <(DO_RUN-1)         ; 28 RUN
        .BYTE   <(DO_SCREEN-1)      ; 29 SCREEN
        .BYTE   <(DO_WARM-1)        ; 20 WARM
        .BYTE   <(DO_XEP-1)         ; 31 XEP
        .BYTE   <(DO_DRIVE_CHG-1)   ; 32

CMD_TAB_H:
        .BYTE   >(DO_GENERIC-1)     ;  0 NCD
;       .BYTE   >(DO_COPY-1)        ;  1 COPY
        .BYTE   >(DO_DIR-1)         ;  2 DIR
        .BYTE   >(DO_GENERIC-1)     ;  3 DEL
        .BYTE   >(DO_LOAD-1)        ;  4 LOAD
        .BYTE   >(DO_GENERIC-1)     ;  5 LOCK
        .BYTE   >(DO_LPR-1)         ;  6 LPR
        .BYTE   >(DO_GENERIC-1)     ;  7 MKDIR
        .BYTE   >(DO_NPWD-1)        ;  8 NPWD
        .BYTE   >(DO_NTRANS-1)      ;  9 NTRANS
        .BYTE   >(DO_GENERIC-1)     ; 10 PASS
        .BYTE   >(DO_GENERIC-1)     ; 11 RENAME
        .BYTE   >(DO_GENERIC-1)     ; 12 RMDIR
        .BYTE   >(DO_SAVE-1)        ; 13 SAVE
        .BYTE   >(DO_SUBMIT-1)      ; 14 SUBMIT
        .BYTE   >(DO_TYPE-1)        ; 15 TYPE
        .BYTE   >(DO_GENERIC-1)     ; 16 USER
        .BYTE   >(DO_GENERIC-1)     ; 17 UNLOCK
        .BYTE   >(DO_AUTORUN-1)     ; 18 AUTORUN
        .BYTE   >(DO_CAR-1)         ; 19 CAR
        .BYTE   >(DO_CLS-1)         ; 20 CLS
        .BYTE   >(DO_COLD-1)        ; 21 COLD
        .BYTE   >(DO_HELP-1)        ; 22 HELP
        .BYTE   >(DO_BASIC-1)       ; 23 BASIC
        .BYTE   >(DO_NOSCREEN-1)    ; 24 NOSCREEN
        .BYTE   >(DO_PRINT-1)       ; 25 PRINT
        .BYTE   >(DO_REENTER-1)     ; 26 REENTER
        .BYTE   >(DO_REM-1)         ; 27 REM
        .BYTE   >(DO_RUN-1)         ; 28 RUN
        .BYTE   >(DO_SCREEN-1)      ; 29 SCREEN
        .BYTE   >(DO_WARM-1)        ; 20 WARM
        .BYTE   >(DO_XEP-1)         ; 31 XEP
        .BYTE   >(DO_DRIVE_CHG-1)   ; 32

        ; DEVHDL TABLE FOR N:

CIOHND  .WORD   OPEN-1
        .WORD   CLOSE-1
        .WORD   GET-1
        .WORD   PUT-1
        .WORD   STATUS-1
        .WORD   SPEC-1

       ; BANNERS

BREADY  .BYTE   '#FUJINET NOS v0.6.1-alpha',EOL
BERROR  .BYTE   '#FUJINET ERROR',EOL

        ; MESSAGES

CDERR   .BYTE   'Nn?',EOL

        ; STRING CONSTANTS

MISSING_FILE_STR:
        .BYTE   'FILE?',EOL

        ; VARIABLES

DOSDR       .BYTE   $01     ; DOS DRIVE
CMD         .BYTE   $01
CMDPRV      .BYTE   $01
ECHO_FLG    .BYTE   $01     ; Echo batch cmds (1=enabled,0=disabled)
AUTORUN_FLG .BYTE   $00     ; Checked at DOS entry. Runs only on first pass

TRIP        .BYTE   $01     ; INTR FLAG
RLEN    :MAXDEV .BYTE $00   ; RCV LEN
ROFF    :MAXDEV .BYTE $00   ; RCV OFFSET
TOFF    :MAXDEV .BYTE $00   ; TRX OFFSET
INQDS       .BYTE   $01     ; DSTATS INQ

DVS2    :MAXDEV .BYTE $00   ; DVSTAT+2 SAVE
DVS3    :MAXDEV .BYTE $00   ; DVSTAT+3 SAVE

COLOR4_ORIG .BYTE   $00     ; Hold prev border color

       ; BUFFERS (PAGE ALIGNED)
        .ALIGN  $100, $00
BOOTEND:

RBUF:   :$80 .BYTE $00      ; 128 bytes
TBUF:   :$80 .BYTE $00      ; 128 bytes

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

; Following used in DO_SAVE
INITADL = TBUF+4    ; Init Addr (lo)
INITADH = TBUF+5    ; Init Addr (hi)
RUNADL  = TBUF+6    ; Run Addr (lo)
RUNADH  = TBUF+7    ; Run Addr (hi)
COMMA_ARGS_BITFIELD = RBUF+10    ; Bit field for which addrs provided

AUTORUN_QUERY_FLG   = TBUF+17   ; Flag for printing contents of autorun appkey

PGEND   = *

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
    DTA $60,$C3,$02,$04,$00,C"5 v0.6.1   "
    DTA $60,$C3,$02,$04,$00,C"6  alpha   "
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
