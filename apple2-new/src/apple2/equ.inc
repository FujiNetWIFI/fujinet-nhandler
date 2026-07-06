;*****************************************************************************
; equ.inc - Equates for the FujiNet BASIC.SYSTEM extension (Apple II / ProDOS)
;
; Fresh rewrite of the FujiNet Applesoft extension.  Unlike the original
; ampersand version, this installs as a BASIC.SYSTEM *external command*
; (hooking EXTRNCMD at $BE06), so command names are matched against the raw,
; untokenized input line at $200 - the ROM tokenizer never mangles them.
;*****************************************************************************

;----------------------------------------------------------------------------
; Apple II text / character constants
;----------------------------------------------------------------------------
SPACE           = $A0           ; space, high bit set (for COUT)
CR              = $0D           ; carriage return (ASCII)
TOK_CALL        = $8C           ; Applesoft CALL token (for the error-trap line)

;----------------------------------------------------------------------------
; Zero page - "safe" scratch locations (same set the original used)
;----------------------------------------------------------------------------
ZP1             = $EB
ZP1_LO          = $EB
ZP1_HI          = $EC
ZP2             = $ED
ZP2_LO          = $ED
ZP2_HI          = $EE
ZP3             = $FA
ZP3_LO          = $FA
ZP3_HI          = $FB
ZP4             = $FC
ZP4_LO          = $FC
ZP4_HI          = $FD

;----------------------------------------------------------------------------
; Applesoft zero page
;----------------------------------------------------------------------------
TXTTAB          = $67           ; start of the Applesoft program ($0801)
VARTAB          = $69           ; end of program / start of simple variables
ARYTAB          = $6B           ; start of arrays
STREND          = $6D           ; end of arrays / start of free space
FRETOP          = $6F           ; top of string pool (lo/hi)
MEMSIZ          = $73           ; HIMEM (lo/hi) - highest RAM Applesoft may use
CURLIN          = $75           ; current line # ($FFxx = direct/immediate mode)
VARPTR          = $83           ; PTRGET result: address of the located variable
ERRFLG          = $D8           ; bit 7 set = ONERR armed
TRCFLG          = $F2           ; bit 7 set = TRACE on.  NOTE: BASIC.SYSTEM
                                ; parks a sentinel ($A5 - bit 7 set!) here while
                                ; processing a command, so Applesoft run inside
                                ; that window traces unless we silence it
ONRTXT          = $F4           ; ONERR handler text ptr; HANDLERR -> TXTPTR
ONRLIN          = $F6           ; ONERR handler line #;  HANDLERR -> CURLIN
DSCTMP          = $9D           ; string descriptor scratch (shares FAC space)
CHRGET          = $B1           ; advance TXTPTR, return char in A
CHRGOT          = $B7           ; re-fetch current char (no advance)
TXTPTR          = $B8           ; Applesoft "current text" pointer (lo/hi)

;----------------------------------------------------------------------------
; Applesoft ROM entry points
;----------------------------------------------------------------------------
; The error flow (verified from the Apple IIe ROM):
;   SYNERR $DEC9:   LDX #$10 / JMP ERROR
;   ERROR  $D412:   BIT ERRFLG / BPL print-and-RESTART / JMP HANDLERR
;   HANDLERR $F2E9: $DE <- X (code); TXTPTR <- (ONRTXT); CURLIN <- (ONRLIN);
;                   JSR CHRGOT; JSR GOTO; JMP NEWSTT   (no stack unwind)
; CMDENTRY exploits this to trap ROM errors raised inside a command handler.
GETBYT          = $E6F8         ; evaluate expression -> byte in X
CHKCOM          = $DEBE         ; require a comma at TXTPTR
PTRGET          = $DFE3         ; locate/create named variable; addr -> VARPTR
STRINI          = $E3D5         ; make room for a new string
MOVSTR          = $E5E2         ; copy string into string space
GIVAYF          = $E2F2         ; signed word (A=hi,Y=lo) -> FAC
MOVMF           = $EB2B         ; pack FAC -> memory at (Y,A) [X too]

;----------------------------------------------------------------------------
; Monitor ROM
;----------------------------------------------------------------------------
CSW             = $36           ; character output vector (COUT jumps here);
                                ; $36-$39 = CSW+KSW, owned by BI's wedge
COUT            = $FDED         ; print A to current output
CROUT           = $FD8E         ; print carriage return
PRTX            = $F944         ; print X as 2 hex digits

;----------------------------------------------------------------------------
; ProDOS / BASIC.SYSTEM
;----------------------------------------------------------------------------
IN              = $0200         ; BASIC.SYSTEM/monitor input buffer (hi bit set)

; --- BASIC.SYSTEM global page ($BE00-$BEFF) ---
EXTRNCMD        = $BE06         ; external-command hook.  BI does SEC then
                                ; tail-JMPs here after its internal command
                                ; table fails: carry CLEAR on return = claimed,
                                ; carry SET = declined (MUST be explicit!)
OUTVECT1        = $BE12         ; BI per-slot output vector table ($BE10+2n).
                                ; NOTE: planting a RAM routine here does NOT
                                ; make PR#1 work - BI's PR# validates the vector
                                ; and rejects non-slot-ROM addresses with NO
                                ; DEVICE CONNECTED (ProDOS 2.4.3).  Unused; kept
                                ; as hard-won documentation.
VECOUT          = $BE30         ; BI's ACTIVE output vector (default COUT1 $FDF0);
                                ; BI sends every char here after wedge processing.
                                ; THE working hook point for output redirection.
XTRNADDR        = $BE50         ; post-parse jump target (lo/hi)
XLEN            = $BE52         ; command keyword length - 1
XCNUM           = $BE53         ; command number (0 for external)
PBITS           = $BE54         ; parse rules (PBITS, PBITS+1)
XRETURN         = $BE9E         ; a bare RTS in the global page (chain default)
GETBUFR         = $BEF5         ; reserve A pages; BI lowers HIMEM + registers it
                                ; (unusable on ProDOS 2.4.3's BASIC.SYSTEM for a
                                ; fixed-ORG resident - returned page != $80)
FREEBUFR        = $BEF8         ; release the space taken by GETBUFR
RSHIMEM         = $BEFB         ; BI's cached HIMEM page: restored into MEMSIZ+1
                                ; whenever the last file buffer is freed

;----------------------------------------------------------------------------
; BASIC.SYSTEM error codes (Table 5-6 in "Advanced Features for Programmers")
;----------------------------------------------------------------------------
BE_RANGE        = $02           ; RANGE ERROR   (bad device #, out of range)
BE_NODEV        = $03           ; NO DEVICE CONNECTED
BE_WRITEPROT    = $04
BE_PATHNF       = $06           ; PATH NOT FOUND
BE_EOD          = $05           ; END OF DATA
BE_IOERROR      = $08           ; I/O ERROR
BE_BADPARM      = $0B           ; INVALID PARAMETER
BE_TYPEMISMATCH = $0D           ; FILE TYPE MISMATCH
BE_TOOLARGE     = $0E           ; PROGRAM TOO LARGE
BE_SYNTAX       = $10           ; SYNTAX ERROR

;----------------------------------------------------------------------------
; SmartPort call numbers / status codes
;----------------------------------------------------------------------------
SP_CMD_STATUS   = $00
SP_CMD_READBLK  = $01
SP_CMD_WRITEBLK = $02
SP_CMD_FORMAT   = $03
SP_CMD_CONTROL  = $04
SP_CMD_INIT     = $05
SP_CMD_OPEN     = $06
SP_CMD_CLOSE    = $07
SP_CMD_READ     = $08
SP_CMD_WRITE    = $09

SP_STATUS_CODE  = $00           ; device status
SP_STATUS_DIB   = $03           ; device information block (name, type)

;----------------------------------------------------------------------------
; FujiNet network channel status codes (the "err" byte of a STATUS reply).
; Values from fujinet-firmware lib/network-protocol/status_error_codes.h.
;----------------------------------------------------------------------------
NERR_SUCCESS    = 1             ; all is well
NERR_EOF        = 136           ; end of data (a fine state, not a failure)
NERR_FNF        = 170           ; file not found

;----------------------------------------------------------------------------
; FujiNet network command bytes (SmartPort CONTROL/STATUS codes).
; Values confirmed against fujinet-firmware include/fujiCommandID.h.
;----------------------------------------------------------------------------
NETCMD_OPEN         = 'O'       ; $4F open: mode, trans, url
NETCMD_CLOSE        = 'C'       ; $43 close
NETCMD_READ         = 'R'       ; $52 read (via STATUS)
NETCMD_WRITE        = 'W'       ; $57 write
NETCMD_STATUS       = 'S'       ; $53 status (bytes waiting / connected / error)
NETCMD_PARSE        = 'P'       ; $50 JSON parse
NETCMD_QUERY        = 'Q'       ; $51 JSON query
NETCMD_ACCEPT       = 'A'       ; $41 TCP accept (NETCMD_CONTROL)
NETCMD_CHDIR        = ','       ; $2C NCD - change directory / set prefix
NETCMD_MKDIR        = '*'       ; $2A NMKDIR
NETCMD_RMDIR        = '+'       ; $2B NRMDIR
NETCMD_DELETE       = '!'       ; $21 NDEL
NETCMD_GETCWD       = '0'       ; $30 get current prefix
NETCMD_HTTPMODE     = 'M'       ; $4D HTTP channel mode (NETCMD_SET_CHANNEL_MODE)
NETCMD_CHANNEL_MODE = $FC       ; channel mode (0=protocol, 1=JSON)
NETCMD_USERNAME     = $FD       ; set username for next open
NETCMD_PASSWORD     = $FE       ; set password for next open
NETCMD_SET_CHANNEL  = $FA       ; select the active network channel/unit

;----------------------------------------------------------------------------
; FujiNet open modes / translation (match Adam SmartBASIC semantics)
;----------------------------------------------------------------------------
MODE_READ       = 4
MODE_WRITE      = 8
MODE_RDWR       = 12
MODE_POST       = 13
MODE_DIR        = 6             ; directory open mode (NDIR)

;----------------------------------------------------------------------------
; Scratch channel for the devicespec-only filesystem commands (NCD/NDIR/NMKDIR/
; NRMDIR/NDEL/NLOAD/NSAVE).  User channels are 1..15 (see CHKCHAN); channel 0
; can never be a user-opened channel, so filesystem ops here never clobber a
; live connection.
;----------------------------------------------------------------------------
SCRATCH_CHAN    = 0
