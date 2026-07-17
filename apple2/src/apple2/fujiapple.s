;*****************************************************************************
; fujiapple.s - FujiNet BASIC.SYSTEM extension for Apple II / ProDOS 8
;
; A from-scratch rewrite of the FujiNet Applesoft extension.  It installs 17
; network commands (matching the Adam SmartBASIC 1.x FujiNet set) as
; BASIC.SYSTEM *external commands* rather than ampersand routines.
;
; Why external commands instead of "&"?  The "&" vector runs AFTER Applesoft's
; ROM tokenizer has crunched the line, so command names containing embedded
; keywords (NREAD->READ, NSTATUS->AT, NLOAD->LOAD, NJSONPARSE->ON, ...) get
; partially tokenized and must be matched byte-for-byte against ROM-crunched
; forms.  That fragility is the source of the original's subtle bugs.  A
; BASIC.SYSTEM external command instead receives the RAW, untokenized command
; line at $200 - the tokenizer never touches it.
;
; Residency model: the whole image loads at RESSTART ($8000) via BRUN and stays
; put; installation lowers HIMEM to a full 1K below the code (see BUFGUARD),
; syncs BI's cached HIMEM page (RSHIMEM), and hooks EXTRNCMD.  No runtime
; relocation (and thus no relocation-table rot) is needed.
;
; Invocation:
;   ] NOPEN 1,"N:HTTP://...",4,0        (immediate mode, typed bare)
;   100 PRINT CHR$(4);"NOPEN 1,...":..  (in a program, standard ProDOS idiom)
;*****************************************************************************

        .include "equ.inc"

RESSTART = $8000                ; load / resident base (see fn-ext.cfg)

; BASIC.SYSTEM puts the FIRST open file's 1K buffer at [HIMEM, HIMEM+$400) -
; ABOVE HIMEM (that's what the stock $9600-$99FF gap under BI is for).  So
; HIMEM must sit a full 1K below the resident, or the first CATALOG/OPEN
; shreds our code with a directory block (whose leading $00 00 becomes a BRK
; right at CMDHANDLER - the "NEW after CATALOG" monitor break).
BUFGUARD = $0400
HIMEMTOP = RESSTART - BUFGUARD  ; $7C00: what we set MEMSIZ/FRETOP/RSHIMEM to

; Zero-page pointers we borrow for indirect addressing (must be in ZP).
TBLP     = ZP1                  ; keyword-table walk pointer ($EB/$EC)
STRP     = ZP3                  ; PUTS string pointer        ($FA/$FB)
SLOTPTR  = ZP2                  ; SmartPort slot scan ptr    ($ED/$EE)
GUSRC    = ZP4                  ; GETURL source string ptr   ($FC/$FD)

        .segment "CODE"

;=============================================================================
; Fixed entry table at the resident base (RESSTART).  BRUN runs the first slot;
; the others are stable CALL targets independent of code layout:
;   CALL 32768 ($8000) - (BRUN) install
;   CALL 32771 ($8003) - printer redirect ON  (COUT -> FujiNet PRINTER)
;   CALL 32774 ($8006) - printer redirect OFF (restore previous output)
;   CALL 32777 ($8009) - INTERNAL: error-trap recovery (see CMDENTRY).  It is
;                        reached only via the trap's fake program line; calling
;                        it by hand would restore a stale stack pointer.
;=============================================================================
ENTRY:
        JMP INSTALL
        JMP PRON
        JMP PROFF
        JMP RECOVER

;=============================================================================
; INSTALL - runs once when the BIN is BRUN.  Protects the resident with HIMEM
; and chains our recognizer into the BASIC.SYSTEM external-command vector.
;=============================================================================
INSTALL:
        ; --- verify there is room below the current HIMEM for the resident ---
        LDA MEMSIZ+1            ; current HIMEM hi
        CMP #>RES_END
        BCC @toolow            ; HIMEM hi < RES_END hi  -> no room
        BNE @room              ; HIMEM hi > RES_END hi  -> ok
        LDA MEMSIZ             ; equal hi: compare lo
        CMP #<RES_END
        BCS @room
@toolow:
        JMP @noroom            ; (out of BCC range; hop via a near JMP)
@room:
        ; --- claim the resident: HIMEM goes to HIMEMTOP ($7C00), a full 1K
        ; BELOW the code, because BI parks the first open file's buffer in the
        ; 1K ABOVE HIMEM (see BUFGUARD above).  Also sync BI's cached HIMEM
        ; page (RSHIMEM): BI allocates further buffers by subtracting pages
        ; from live MEMSIZ, but when the last buffer closes it restores MEMSIZ
        ; from RSHIMEM and reorganizes - a mismatch there re-exposes the
        ; resident.  With all three in sync, every buffer lands below $8000
        ; and the close-time restore is a no-op.  (Behavior disassembled from
        ; ProDOS 2.4.3's BASIC.SYSTEM; its GETBUFR vector proved unusable for
        ; a fixed-ORG resident.)
        LDA #<HIMEMTOP
        STA MEMSIZ
        STA FRETOP
        LDA #>HIMEMTOP
        STA MEMSIZ+1
        STA FRETOP+1
        STA RSHIMEM

        LDA #0
        STA CURTRANS           ; default translation = none (NTRANS/NTYPE)

        ; --- chain into EXTRNCMD ($BE06 = JMP; target @ $BE07/$BE08) ---
        LDA EXTRNCMD+1         ; save the previous handler so we can daisy-chain
        STA NEXTCMD+1
        LDA EXTRNCMD+2
        STA NEXTCMD+2
        LDA #<CMDHANDLER
        STA EXTRNCMD+1
        LDA #>CMDHANDLER
        STA EXTRNCMD+2

        JSR PRINTBANNER

        ; --- locate the SmartPort card and the FujiNet "NETWORK" device ---
        JSR FINDSP
        BCS @nosp
        ; INSTALL runs from inside the STARTUP program (via BRUN).  The SmartPort
        ; device scan below scribbles Applesoft zero page (the emulator's host
        ; firmware uses it as scratch), which would corrupt STARTUP's execution
        ; state and later crash the first DOS command + NEW.  Snapshot all of
        ; zero page around the scan and restore it (results land in SPUNIT/
        ; SPPUNIT in BSS, so this is safe; unlike the per-command path there is
        ; no interleaved Applesoft parsing here to disturb).  ARGBUF is free at
        ; install time, so it doubles as the snapshot buffer.
        LDX #0
@svzp:  LDA $00,X
        STA ARGBUF,X
        INX
        BNE @svzp
        JSR FINDNET
        JSR FINDPRINTER        ; optional; SPPUNIT stays 0 if there is no printer
        LDX #0
@rszp:  LDA ARGBUF,X
        STA $00,X
        INX
        BNE @rszp
        LDA SPUNIT
        BEQ @nonet
        LDA #<MSG_NETOK        ; "FUJINET NETWORK DEVICE AT SP UNIT $"
        LDY #>MSG_NETOK
        JSR PUTS
        LDA SPUNIT
        JSR PUTHEX
        JSR CROUT
        LDA SPPUNIT            ; printer found?
        BEQ @noprint
        LDA VECOUT             ; sane PROFF default even if PRON never ran
        STA SAVVEC
        LDA VECOUT+1
        STA SAVVEC+1
        LDA #<MSG_PROK
        LDY #>MSG_PROK
        JSR PUTS
        LDA SPPUNIT
        JSR PUTHEX
        JSR CROUT
@noprint:
        RTS
@nosp:
        LDA #<MSG_NOSP
        LDY #>MSG_NOSP
        JSR PUTS
        RTS
@nonet:
        LDA #<MSG_NONET
        LDY #>MSG_NONET
        JSR PUTS
        RTS

@noroom:
        LDA #<MSG_NOROOM
        LDY #>MSG_NOROOM
        JSR PUTS
        RTS

;=============================================================================
; CMDHANDLER - installed at EXTRNCMD.  When BASIC.SYSTEM's internal command
; table fails to match a typed line, it does SEC and tail-JMPs into $BE06, so
; our RTS returns straight to BI's caller and CARRY is the claim flag.  The
; raw command line is at $200, ASCII with the high bit set.
;
;   match one of our keywords  -> set up the parse vectors, return CLC
;   no match                   -> SEC (decline - MANDATORY, see @nomatch) and
;                                 daisy-chain to the previous handler (NEXTCMD)
;=============================================================================
CMDHANDLER:
        CLD                    ; identification byte for future BASIC.SYSTEMs

        ; Find where the command keyword starts (skip leading blanks).
        LDX #0
@skipsp:
        LDA IN,X
        CMP #SPACE             ; space with high bit set
        BNE @scan
        INX
        BNE @skipsp

@scan:
        ; X = index in $200 of first non-blank char.  Walk the keyword table.
        STX CMDSTART
        LDA #<CMDTABLE
        STA TBLP
        LDA #>CMDTABLE
        STA TBLP+1

@nextcmd:
        LDY #0                 ; Y walks the table entry's name
        LDX CMDSTART           ; X walks the input line
        LDA (TBLP),Y           ; first name byte
        BEQ @nomatch          ; $00 first byte -> end of table

@cmp:
        LDA (TBLP),Y
        BEQ @endname          ; reached the NUL that ends this name
        EOR IN,X              ; compare (table = plain ASCII, input = hi-bit)
        AND #$7F              ; ignore the input's high bit
        BNE @advance          ; mismatch -> try next table entry
        INY
        INX
        BNE @cmp

@endname:
        ; Keyword characters all matched.  Require a delimiter next so that
        ; e.g. "NCD" does not swallow a longer word.
        LDA IN,X
        AND #$7F
        CMP #' '+1            ; space, CR, NUL, anything <= space -> delimiter
        BCC @matched
        CMP #','
        BEQ @matched
        CMP #'"'
        BEQ @matched
        ; not a delimiter -> not really our command
@advance:
        ; skip to the byte after this entry's NUL, then past its 2 addr bytes
        LDY #0
@toz:
        LDA (TBLP),Y
        INY                    ; Y advances; A keeps the byte just read
        CMP #0
        BNE @toz               ; keep going until we consumed the NUL
        ; Y now points just past the NUL; skip the 2 handler-address bytes
        INY
        INY
        TYA
        CLC
        ADC TBLP
        STA TBLP
        BCC @nextcmd
        INC TBLP+1
        BNE @nextcmd           ; (always)

@matched:
        ; X indexes the first argument character in $200.  Remember it.
        STX ARGSTART
        ; Y indexes the table NUL; the 2 bytes after it are the handler addr.
        ; Stash the real handler in HANDLERVEC and point BASIC.SYSTEM at the
        ; CMDENTRY trampoline instead, so every command's Applesoft text state
        ; is saved/restored around it (see CMDENTRY).
        INY
        LDA (TBLP),Y
        STA HANDLERVEC
        INY
        LDA (TBLP),Y
        STA HANDLERVEC+1
        LDA #<CMDENTRY
        STA XTRNADDR
        LDA #>CMDENTRY
        STA XTRNADDR+1

        ; XLEN = keyword length - 1 = (ARGSTART - CMDSTART) - 1
        SEC
        LDA ARGSTART
        SBC CMDSTART
        SEC
        SBC #1
        STA XLEN
        LDA #0
        STA XCNUM              ; external command number
        STA PBITS              ; PBITS = 0  -> BASIC.SYSTEM does no parsing
        STA PBITS+1
        CLC                    ; claimed, no error
        RTS

@nomatch:
        ; Not ours.  The protocol REQUIRES carry SET on decline; our table walk
        ; reaches here with carry CLEAR (the final CLC/ADC entry advance), which
        ; told BASIC.SYSTEM we CLAIMED the line.  It then dispatched through the
        ; STALE XTRNADDR/XLEN/PBITS of the previous command - so after any
        ; N-command, every typed line we don't recognize (NEW, CALL -151, ...)
        ; re-entered the old handler against a garbage buffer and crashed inside
        ; the keyboard wedge.  SEC = decline, cleanly.
        SEC
        JMP NEXTCMD            ; hand off to the previously installed handler

; NEXTCMD's operand is patched at install time to the prior EXTRNCMD target
; (defaults to XRETURN, the global page's do-nothing RTS).
NEXTCMD:
        JMP XRETURN

;=============================================================================
; CMDENTRY - single dispatch trampoline for every command.  BASIC.SYSTEM
; JSRs here (via XTRNADDR) after CMDHANDLER claims a keyword.
;
; It does two jobs:
;
; 1. TEXT STATE.  Our handlers repoint Applesoft's TXTPTR into ARGBUF (via
;    SETARGS) so the ROM evaluators can parse the argument tail.  BASIC.SYSTEM
;    does not save TXTPTR/CURLIN for us, so snapshot them here and restore on
;    the way out, making us behaviourally identical to a well-behaved external
;    command.  The handler's return status (carry, A) survives the restore.
;
; 2. THE ERROR TRAP.  The ROM evaluators bail out through Applesoft's ERROR
;    on bad input (SYNERR from a misplaced argument, type mismatch, ...).
;    That path never returns to BASIC.SYSTEM's dispatch, leaving its command
;    wedge wedged: afterwards every command line - ours AND the built-ins -
;    falls through to Applesoft as ?SYNTAX ERROR until reboot.  So run the
;    handler under a fake ONERR frame (flow verified from the ROM, see
;    equ.inc): ERROR with ERRFLG set jumps to HANDLERR, which loads TXTPTR
;    from ONRTXT and CURLIN from ONRLIN, then GOTOs the line number found at
;    TXTPTR, searching the program at TXTTAB.  We point ONRTXT at the text
;    "0" and TXTTAB at FAKEPROG, a one-line program reading "0 CALL 32777" -
;    whose target is RECOVER below.  RECOVER unwinds the stack to the level
;    recorded in TRAPSP and exits through CMDFAIL: the command fails with a
;    clean, ONERR-catchable SYNTAX ERROR and BASIC.SYSTEM lives on.
;
;    Because TXTTAB is swapped during the handler, NLOAD/NSAVE/RELINK read
;    the real value from SAVTTAB instead.
;=============================================================================
CMDENTRY:
        LDA TXTPTR             ; --- snapshot Applesoft text state ---
        STA SAVTXT
        LDA TXTPTR+1
        STA SAVTXT+1
        LDA CURLIN
        STA SAVCURLIN
        LDA CURLIN+1
        STA SAVCURLIN+1
        LDA ERRFLG             ; --- snapshot the user's ONERR state ---
        STA SAVONERR
        LDA ONRTXT
        STA SAVONERR+1
        LDA ONRTXT+1
        STA SAVONERR+2
        LDA ONRLIN
        STA SAVONERR+3
        LDA ONRLIN+1
        STA SAVONERR+4
        LDA TRCFLG             ; BI parks $A5 here during command processing;
        STA SAVONERR+5         ; bit 7 reads as TRACE and would print "#0"
        LDA #0                 ; when the trap's decoy line runs.  Silence it
        STA TRCFLG             ; for the handler's duration.
        LDA TXTTAB
        STA SAVTTAB
        LDA TXTTAB+1
        STA SAVTTAB+1
        LDA #<FAKETGT          ; --- arm the trap ---
        STA ONRTXT
        LDA #>FAKETGT
        STA ONRTXT+1
        LDA #0
        STA ONRLIN             ; CURLIN 0 makes GOTO search from TXTTAB
        STA ONRLIN+1
        LDA #<FAKEPROG
        STA TXTTAB
        LDA #>FAKEPROG
        STA TXTTAB+1
        LDA #$80
        STA ERRFLG
        TSX                    ; stack level RECOVER unwinds to
        STX TRAPSP
        JSR CMDCALL            ; run the real handler; RTS returns here
        PHP                    ; preserve error/carry + A across the restore
        PHA
        JMP CMDRESTOR
CMDFAIL:
        ; Entered from RECOVER after a trapped ROM error: the stack is back
        ; at CMDENTRY's level, so exiting through the common restore returns
        ; to BASIC.SYSTEM exactly like a normal failed command.
        LDA #BE_SYNTAX
        SEC
        PHP
        PHA
CMDRESTOR:
        LDA SAVTXT             ; --- restore text state ---
        STA TXTPTR
        LDA SAVTXT+1
        STA TXTPTR+1
        LDA SAVCURLIN
        STA CURLIN
        LDA SAVCURLIN+1
        STA CURLIN+1
        LDA SAVONERR           ; --- disarm: restore the user's ONERR ---
        STA ERRFLG
        LDA SAVONERR+1
        STA ONRTXT
        LDA SAVONERR+2
        STA ONRTXT+1
        LDA SAVONERR+3
        STA ONRLIN
        LDA SAVONERR+4
        STA ONRLIN+1
        LDA SAVONERR+5         ; give BI its $F2 sentinel back
        STA TRCFLG
        LDA SAVTTAB
        STA TXTTAB
        LDA SAVTTAB+1
        STA TXTTAB+1
        PLA
        PLP
        RTS
CMDCALL:
        JMP (HANDLERVEC)

; RECOVER - the target of the trap's "0 CALL 32777" line.  An Applesoft error
; fired inside a handler; the ROM has already vectored through HANDLERR ->
; GOTO -> NEWSTT -> CALL to get here.  Throw away everything above CMDENTRY's
; recorded stack level and fail the command cleanly.
RECOVER:
        LDX TRAPSP
        TXS
        JMP CMDFAIL

;=============================================================================
; SETARGS - point Applesoft's TXTPTR at a clean copy of the argument tail so
; the ROM evaluators (GETBYT / CHKCOM / FRMNUM / PTRGET) can parse it.
;
; The line at $200 has the high bit set on every byte; the ROM routines expect
; plain ASCII.  Copy from $200+ARGSTART up to the CR into ARGBUF with the high
; bits stripped and a $00 terminator, then set TXTPTR = ARGBUF-1 (CHRGET
; pre-increments).  Every command handler calls this first.
;=============================================================================
SETARGS:
        LDX ARGSTART
        LDY #0
@cp:
        LDA IN,X
        AND #$7F
        CMP #CR
        BEQ @done
        STA ARGBUF,Y
        INX
        INY
        CPY #250
        BCC @cp
@done:
        LDA #0
        STA ARGBUF,Y           ; NUL terminate
        LDA #<(ARGBUF-1)
        STA TXTPTR
        LDA #>(ARGBUF-1)
        STA TXTPTR+1
        ; Prime the pump: the ROM evaluators (FRMNUM/GETBYT/PTRGET/CHKCOM) work
        ; on the CURRENT char via CHRGOT - they do NOT CHRGET first.  Set
        ; TXTPTR = ARGBUF-1 above, then CHRGET once to advance onto ARGBUF[0]
        ; (skipping leading spaces) so CHRGOT sees the first real arg character.
        ; Without this, FRMNUM reads the uninitialized byte before ARGBUF and
        ; dies with ?SYNTAX ERROR before ever looking at the argument.
        JSR CHRGET
        RTS

;=============================================================================
; Command handlers (second phase).  BASIC.SYSTEM reaches these via the CMDENTRY
; trampoline (which saves/restores Applesoft's TXTPTR/CURLIN) after a successful
; claim.  Each must return: CLC + A=0 on success, or SEC + A=error code (a
; BASIC.SYSTEM code) to raise an ONERR-catchable error.
;=============================================================================
;--- NOPEN d, url$, mode, trans -------------------------------------------
H_NOPEN:
        JSR CHKDEV
        BCS @err
        JSR SETARGS
        JSR GETBYT
        JSR CHKCHAN            ; -> CHAN (1..15) or SEC + A=range error
        BCS @err
        LDA CHAN
        JSR FN_SETCH           ; select channel once
        JSR CHKCOM
        JSR GETURL             ; url$ -> URLBUF / URLLEN
        JSR CHKCOM
        JSR GETBYT
        STX MODE
        JSR CHKCOM
        JSR GETBYT
        STX TRANS
        JSR ISHTTP
        BCS @http
        JSR OPENCK             ; verify the open; PATH NOT FOUND / I/O ERROR
        BCS @err
        CLC
        LDA #0
        RTS
@http:
        JSR FN_OPEN            ; HTTP(S): a status here would fire the request
        CLC                    ; early (breaking NHTTPMODE header setup), so
        LDA #0                 ; open errors surface via NSTATUS instead
@err:   RTS

;--- NCLOSE d --------------------------------------------------------------
H_NCLOSE:
        JSR CHKDEV
        BCS @err
        JSR SETARGS
        JSR GETBYT
        JSR CHKCHAN
        BCS @err
        LDA CHAN
        JSR FN_SETCH
        JSR FN_CLOSE
        CLC
        LDA #0
@err:   RTS

;--- NSTATUS d, bw, conn, err ---------------------------------------------
H_NSTATUS:
        JSR CHKDEV
        BCS @err
        JSR SETARGS
        JSR GETBYT
        JSR CHKCHAN
        BCS @err
        LDA CHAN
        JSR FN_SETCH
        JSR FN_STATUS          ; SP_PAYLOAD = [avail_lo][avail_hi][conn][err]
        JSR CHKCOM
        LDA SP_PAYLOAD+1       ; bytes-waiting hi
        LDY SP_PAYLOAD         ; bytes-waiting lo
        JSR WORDSAV            ; store word into bw variable
        JSR CHKCOM
        LDY SP_PAYLOAD+2       ; connected
        JSR BYTESAV
        JSR CHKCOM
        LDY SP_PAYLOAD+3       ; device error
        JSR BYTESAV
        CLC
        LDA #0
@err:   RTS

;--- NREAD d, buf$, len ----------------------------------------------------
H_NREAD:
        JSR CHKDEV
        BCS @err
        JSR SETARGS
        JSR GETBYT
        JSR CHKCHAN
        BCS @err
        LDA CHAN
        JSR FN_SETCH
        JSR CHKCOM
        JSR PTRGET             ; locate buf$ ; descriptor addr -> VARPTR
        LDA VARPTR
        STA RDVAR
        LDA VARPTR+1
        STA RDVAR+1
        JSR CHKCOM
        JSR GETBYT
        STX BUFLEN             ; requested length (0..255)
        LDA BUFLEN
        JSR FN_READ            ; SP_COUNT = actual bytes, data in SP_PAYLOAD
        JSR STORESTR           ; buf$ = exactly the bytes actually read
        CLC
        LDA #0
@err:   RTS

;--- NWRITE d, buf$, len ---------------------------------------------------
H_NWRITE:
        JSR CHKDEV
        BCS @err
        JSR SETARGS
        JSR GETBYT
        JSR CHKCHAN
        BCS @err
        LDA CHAN
        JSR FN_SETCH           ; select channel BEFORE staging data
        JSR CHKCOM
        JSR GETURL             ; buf$ -> URLBUF / URLLEN
        JSR CHKCOM
        JSR GETBYT
        STX BUFLEN             ; requested length
        LDA BUFLEN             ; clamp to LEN(buf$)
        CMP URLLEN
        BCC @wlen
        LDA URLLEN
        STA BUFLEN
@wlen:
        LDX #0                 ; stage buf$ bytes -> SP_PAYLOAD
@wcp:
        CPX BUFLEN
        BEQ @wgo
        LDA URLBUF,X
        STA SP_PAYLOAD,X
        INX
        BNE @wcp
@wgo:
        LDA BUFLEN
        JSR FN_WRITE
        CLC
        LDA #0
@err:   RTS
;--- NJSONPARSE d ------------------------------------------------------------
; Put channel d into JSON mode and parse the JSON document it is reading, so a
; following NJSONQUERY can pull values out of it.
H_NJSONPARSE:
        JSR CHKDEV
        BCC @jp1
        RTS
@jp1:
        JSR SETARGS
        JSR GETBYT
        JSR CHKCHAN
        BCC @jp2
        RTS
@jp2:
        LDA CHAN
        JSR FN_SETCH
        LDA #1                 ; channel mode -> JSON: data_buffer[0]=1
        STA SP_PAYLOAD+2
        LDA #1
        STA SP_PAYLOAD         ; length = 1
        LDA #0
        STA SP_PAYLOAD+1
        LDX SPUNIT
        LDY #NETCMD_CHANNEL_MODE
        JSR SP_CONTROL
        LDA #0                 ; parse: empty control list
        STA SP_PAYLOAD
        STA SP_PAYLOAD+1
        LDX SPUNIT
        LDY #NETCMD_PARSE
        JSR SP_CONTROL
        JMP SPRESULT

;--- NJSONQUERY d, result$, query$ -------------------------------------------
; Send a JSONPath-ish query on channel d (already parsed via NJSONPARSE) and
; read the resulting value into result$.
H_NJSONQUERY:
        JSR CHKDEV
        BCC @jq1
        RTS
@jq1:
        JSR SETARGS
        JSR GETBYT
        JSR CHKCHAN
        BCC @jq2
        RTS
@jq2:
        LDA CHAN
        JSR FN_SETCH
        JSR CHKCOM
        JSR PTRGET             ; locate result$ ; descriptor addr -> VARPTR
        LDA VARPTR
        STA RDVAR
        LDA VARPTR+1
        STA RDVAR+1
        JSR CHKCOM
        JSR GETURL             ; query$ -> URLBUF / URLLEN
        LDX #0                 ; stage the query (no NUL, like the original)
@qcp:   CPX URLLEN
        BEQ @qgo
        LDA URLBUF,X
        STA SP_PAYLOAD+2,X
        INX
        BNE @qcp
@qgo:
        STX SP_PAYLOAD         ; count = URLLEN
        LDA #0
        STA SP_PAYLOAD+1
        LDX SPUNIT
        LDY #NETCMD_QUERY
        JSR SP_CONTROL
        LDA #16                ; bounded poll for the value to become available
        STA JQRETRY
@poll:
        JSR FN_STATUS          ; SP_PAYLOAD = [avail_lo][avail_hi][conn][err]
        LDA SP_PAYLOAD
        ORA SP_PAYLOAD+1
        BNE @have
        DEC JQRETRY
        BNE @poll
        LDA #0                 ; timed out -> empty result$
        STA SP_COUNT
        STA SP_COUNT+1
        JSR STORESTR
        CLC
        LDA #0
        RTS
@have:
        LDA SP_PAYLOAD         ; read min(avail,255) bytes
        LDX SP_PAYLOAD+1
        BEQ @rd
        LDA #255
@rd:    JSR FN_READ            ; -> SP_PAYLOAD, SP_COUNT
        JSR STORESTR           ; result$ = the value bytes
        CLC
        LDA #0
        RTS
;--- devicespec-only filesystem commands: NCD/NMKDIR/NRMDIR/NDEL --------------
; Each takes a single devicespec and issues one FujiNet CONTROL command against
; the scratch channel; the firmware parses the devicespec fresh (no OPEN needed).
H_NCD:        LDY #NETCMD_CHDIR      ; set prefix / change directory
              JMP NCTL
H_NMKDIR:     LDY #NETCMD_MKDIR
              JMP NCTL
H_NRMDIR:     LDY #NETCMD_RMDIR
              JMP NCTL
H_NDEL:       LDY #NETCMD_DELETE
              JMP NCTL

; NCTL - common body.  Y = FujiNet control code.  Parse the devicespec, select
; the scratch channel, send the control, and surface a device error as I/O ERROR.
NCTL:
        STY NCTLCMD            ; GETURL clobbers Y, so stash the control code
        JSR CHKDEV
        BCS @err
        JSR SETARGS
        JSR GETURL             ; devicespec -> URLBUF / URLLEN
        LDA #SCRATCH_CHAN
        JSR FN_SETCH
        LDY NCTLCMD
        JSR FN_CONTROL_DS      ; returns carry = SmartPort/device error
        JMP SPRESULT
@err:   RTS

;--- NCAT / NCATALOG devicespec ----------------------------------------------
; Open the devicespec as a directory (mode 6) and print the ProDOS-style listing
; the firmware formats for us: NCAT requests the 40-column CAT layout, NCATALOG
; the 80-column CATALOG layout (selected via the TRANS byte).  Read and print
; the listing a chunk at a time until no bytes remain, then close.  Prints
; straight to the screen (no string variable), so it doubles as an end-to-end
; read-path test.
H_NCAT:
        LDA #DIRFMT_CAT
        BNE NCATCOM            ; (always: DIRFMT_CAT != 0)
H_NCATALOG:
        LDA #DIRFMT_CATALOG
NCATCOM:
        STA TRANS              ; survives the parse below (only dir handlers write TRANS)
        JSR CHKDEV
        BCS @err
        JSR SETARGS
        JSR GETURL             ; devicespec -> URLBUF / URLLEN
        LDA #SCRATCH_CHAN
        JSR FN_SETCH
        LDA #MODE_DIR
        STA MODE
        JSR OPENCK             ; bad path -> PATH NOT FOUND instead of silence
        BCS @err
@loop:
        JSR FN_STATUS          ; SP_PAYLOAD = [avail_lo][avail_hi][conn][err]
        LDA SP_PAYLOAD
        ORA SP_PAYLOAD+1
        BEQ @done              ; nothing waiting -> end of listing
        LDA SP_PAYLOAD+1       ; >= 256 waiting?
        BNE @full
        LDA SP_PAYLOAD         ; else read the (1..255) available
        BNE @rd                ; (always: the ORA above proved lo|hi nonzero)
@full:  LDA #255
@rd:    JSR FN_READ            ; A bytes -> SP_PAYLOAD, SP_COUNT = actual
        LDA SP_COUNT
        ORA SP_COUNT+1
        BEQ @done              ; defensive: read returned nothing
        LDX #0
@pr:    CPX SP_COUNT
        BEQ @loop
        LDA SP_PAYLOAD,X
        CMP #$0A               ; the firmware ends each entry with CR+LF, but
        BEQ @next              ; COUT treats LF as a line feed too -> blank
        ORA #$80               ; lines.  Drop the LF; let the CR do the newline.
        JSR COUT
@next:  INX
        BNE @pr
        BEQ @loop              ; (always)
@done:
        JSR FN_CLOSE
        CLC
        LDA #0
@err:   RTS

;--- NTYPE devicespec --------------------------------------------------------
; Open the devicespec on channel 1 (mode READ) using the current NTRANS
; translation, print its contents to the screen a chunk at a time, and close.
; Structurally NCAT with MODE_READ and a user-set TRANS; output is faithful
; (each byte COUT'd with the high bit set, no LF-dropping) - line-ending
; handling is the caller's choice via NTRANS.
H_NTYPE:
        JSR CHKDEV
        BCS @err
        JSR SETARGS
        JSR GETURL             ; devicespec -> URLBUF / URLLEN
        LDA #1                 ; channel 1 (NTRANS/NTYPE operate on channel 1)
        JSR FN_SETCH
        LDA #MODE_READ
        STA MODE
        LDA CURTRANS
        STA TRANS
        JSR OPENCK             ; bad path -> PATH NOT FOUND / I/O ERROR
        BCS @err
@loop:
        JSR FN_STATUS          ; SP_PAYLOAD = [avail_lo][avail_hi][conn][err]
        JSR POLLKEY            ; CTRL-C aborts, CTRL-S pauses while we wait
        BCS @abort
        LDA SP_PAYLOAD
        ORA SP_PAYLOAD+1
        BNE @rd                ; bytes waiting -> read them
        LDA SP_PAYLOAD+2       ; none waiting: still connected?
        BNE @loop              ; yes -> wait for more
        BEQ @done              ; no -> EOF
@rd:
        LDA SP_PAYLOAD+1       ; chunk = min(avail, 255)
        BEQ @lo
        LDA #255
        BNE @go
@lo:    LDA SP_PAYLOAD
@go:    JSR FN_READ            ; A bytes -> SP_PAYLOAD, SP_COUNT = actual
        LDA SP_COUNT
        ORA SP_COUNT+1
        BEQ @done              ; defensive: read returned nothing
        LDX #0
@pr:    CPX SP_COUNT
        BEQ @loop
        JSR POLLKEY            ; CTRL-C aborts, CTRL-S pauses the scroll
        BCS @abort
        LDA SP_PAYLOAD,X
        ORA #$80               ; COUT wants the high bit set
        JSR COUT
        INX
        BNE @pr
        BEQ @loop              ; (always)
@abort:
        JSR CROUT              ; end the partial line cleanly
        JSR FN_CLOSE           ; CTRL-C: close the channel and bail out
        CLC
        LDA #0
        RTS
@done:
        JSR FN_CLOSE
        CLC
        LDA #0
@err:   RTS
;--- NSAVE devicespec --------------------------------------------------------
; Write the tokenized Applesoft program (TXTTAB..VARTAB, including the $0000
; end marker) to the network file.  Reads program memory only - non-destructive.
H_NSAVE:
        JSR CHKDEV
        BCC @ns1
        RTS
@ns1:
        JSR SETARGS
        JSR GETURL             ; devicespec -> URLBUF / URLLEN
        LDA #SCRATCH_CHAN
        JSR FN_SETCH
        LDA #MODE_WRITE
        STA MODE
        LDA #0
        STA TRANS
        JSR OPENCK             ; unwritable target -> error, not silence
        BCC @nsok
        RTS
@nsok:
        LDA SAVTTAB            ; PRGPTR = TXTTAB (real value; the error trap
        STA GUSRC              ; has TXTTAB swapped - see CMDENTRY)
        LDA SAVTTAB+1
        STA GUSRC+1
@wloop:
        SEC                    ; remaining = VARTAB - PRGPTR
        LDA VARTAB
        SBC GUSRC
        STA SVLEN
        LDA VARTAB+1
        SBC GUSRC+1
        STA SVLEN+1
        LDA SVLEN
        ORA SVLEN+1
        BEQ @wdone
        LDA SVLEN+1            ; chunk = min(remaining, 255)
        BNE @wfull
        LDA SVLEN
        JMP @wchunk
@wfull: LDA #255
@wchunk:
        STA BUFLEN
        LDY #0                 ; copy chunk from (PRGPTR) into SP_PAYLOAD
@wcp:   CPY BUFLEN
        BEQ @wgo
        LDA (GUSRC),Y
        STA SP_PAYLOAD,Y
        INY
        BNE @wcp
@wgo:
        LDA BUFLEN
        JSR FN_WRITE
        LDA GUSRC              ; PRGPTR += chunk
        CLC
        ADC BUFLEN
        STA GUSRC
        BCC @wloop
        INC GUSRC+1
        JMP @wloop
@wdone:
        JSR FN_CLOSE
        CLC
        LDA #0
        RTS

;--- NLOAD devicespec --------------------------------------------------------
; Read a tokenized Applesoft program from the network into TXTTAB until EOF,
; then rebuild the line links (which also sets VARTAB) and reset the variable
; pointers so the loaded program LISTs and RUNs.
H_NLOAD:
        JSR CHKDEV
        BCC @nl1
        RTS
@nl1:
        JSR SETARGS
        JSR GETURL             ; devicespec -> URLBUF / URLLEN
        LDA #SCRATCH_CHAN
        JSR FN_SETCH
        LDA #MODE_READ
        STA MODE
        LDA #0
        STA TRANS
        JSR OPENCK             ; missing file -> PATH NOT FOUND, and the
        BCC @nlok              ; program in memory is left untouched
        RTS
@nlok:
        ; [TXTTAB-1] must be $00 for Applesoft.  (SAVTTAB = the real TXTTAB;
        ; the error trap has TXTTAB itself swapped - see CMDENTRY.)
        LDA SAVTTAB
        SEC
        SBC #1
        STA GUSRC
        LDA SAVTTAB+1
        SBC #0
        STA GUSRC+1
        LDY #0
        TYA
        STA (GUSRC),Y
        LDA SAVTTAB            ; PRGPTR = TXTTAB
        STA GUSRC
        LDA SAVTTAB+1
        STA GUSRC+1
@rloop:
        ; Bounds guard: the program must stay below HIMEM.  A chunk is at most
        ; 255 bytes, so stopping once the pointer reaches the HIMEMTOP page
        ; keeps every write below RESSTART (the worst case spills into the
        ; 1K buffer guard band, never the resident).
        LDA GUSRC+1
        CMP #>HIMEMTOP
        BCS @rtoobig
        JSR FN_STATUS          ; SP_PAYLOAD = [avail_lo][avail_hi][conn][err]
        LDA SP_PAYLOAD
        ORA SP_PAYLOAD+1
        BNE @rread
        LDA SP_PAYLOAD+2       ; no bytes: still connected?
        BNE @rloop             ; yes -> wait for more
        BEQ @rdone             ; no -> EOF
@rread:
        LDA SP_PAYLOAD+1       ; chunk = min(avail, 255)
        BEQ @rlo
        LDA #255
        BNE @rgo
@rlo:   LDA SP_PAYLOAD
@rgo:
        JSR FN_READ            ; -> SP_PAYLOAD, SP_COUNT
        LDY #0                 ; copy SP_COUNT bytes into (PRGPTR)
@rcp:   CPY SP_COUNT
        BEQ @radv
        LDA SP_PAYLOAD,Y
        STA (GUSRC),Y
        INY
        BNE @rcp
@radv:
        LDA GUSRC              ; PRGPTR += SP_COUNT
        CLC
        ADC SP_COUNT
        STA GUSRC
        BCC @rloop
        INC GUSRC+1
        JMP @rloop
@rdone:
        JSR FN_CLOSE
        JSR RELINK             ; rebuild links, set VARTAB
        JSR NLVARS             ; reset the variable pointers
        CLC
        LDA #0
        RTS
@rtoobig:
        ; File exceeds program space.  Close the channel, scrap the partial
        ; load (leave a clean empty program so LIST/RUN behave like after NEW),
        ; and raise PROGRAM TOO LARGE.
        JSR FN_CLOSE
        LDA SAVTTAB
        STA GUSRC
        LDA SAVTTAB+1
        STA GUSRC+1
        LDA #0
        TAY
        STA (GUSRC),Y          ; $0000 end marker at TXTTAB = empty program
        INY
        STA (GUSRC),Y
        JSR RELINK             ; VARTAB <- TXTTAB+2
        JSR NLVARS
        LDA #BE_TOOLARGE
        SEC
        RTS

; NLVARS - point the Applesoft variable-space pointers at a clean state after
; the program (or its scrapped remains) was replaced: no variables, no arrays,
; empty string pool.
NLVARS:
        LDA VARTAB             ; ARYTAB = STREND = VARTAB
        STA ARYTAB
        STA STREND
        LDA VARTAB+1
        STA ARYTAB+1
        STA STREND+1
        LDA MEMSIZ             ; FRETOP = HIMEM (empty string pool)
        STA FRETOP
        LDA MEMSIZ+1
        STA FRETOP+1
        RTS

;=============================================================================
; RELINK - rebuild the forward line links of the program at TXTTAB and set
; VARTAB to just past the $0000 end-of-program marker.  Re-scans each line for
; its $00 terminator, so it does not trust the (possibly stale) stored links.
; Applesoft line: [link lo][link hi][line# lo][line# hi][tokens...][$00];
; the program ends with a $0000 where the next link would be.
;=============================================================================
RELINK:
        LDA SAVTTAB            ; the real TXTTAB (see CMDENTRY's error trap)
        STA GUSRC
        LDA SAVTTAB+1
        STA GUSRC+1
@line:
        LDY #0
        LDA (GUSRC),Y          ; link lo
        INY
        ORA (GUSRC),Y          ; | link hi  -> both zero means end marker
        BNE @fix
        LDA GUSRC              ; VARTAB = PRGPTR + 2
        CLC
        ADC #2
        STA VARTAB
        LDA GUSRC+1
        ADC #0
        STA VARTAB+1
        RTS
@fix:
        LDY #4                 ; scan past link(2)+line#(2) for the $00
@scan:
        LDA (GUSRC),Y
        BEQ @eol
        INY
        BNE @scan
@eol:
        TYA                    ; NEXTPTR = PRGPTR + Y + 1
        SEC
        ADC GUSRC
        STA NEXTPTR
        LDA GUSRC+1
        ADC #0
        STA NEXTPTR+1
        LDY #0                 ; store NEXTPTR as this line's link
        LDA NEXTPTR
        STA (GUSRC),Y
        INY
        LDA NEXTPTR+1
        STA (GUSRC),Y
        LDA NEXTPTR            ; PRGPTR = NEXTPTR
        STA GUSRC
        LDA NEXTPTR+1
        STA GUSRC+1
        JMP @line
;--- NACCEPT d ---------------------------------------------------------------
; Accept an incoming connection on TCP listener channel d (opened with a
; "N:TCP://:port" devicespec).
H_NACCEPT:
        JSR CHKDEV
        BCC @ac1
        RTS
@ac1:
        JSR SETARGS
        JSR GETBYT
        JSR CHKCHAN
        BCC @ac2
        RTS
@ac2:
        LDA CHAN
        JSR FN_SETCH
        LDA #0                 ; empty control list
        STA SP_PAYLOAD
        STA SP_PAYLOAD+1
        LDX SPUNIT
        LDY #NETCMD_ACCEPT     ; 'A' -> accept_connection()
        JSR SP_CONTROL
        JMP SPRESULT
;--- NLOGIN d, user$, pass$ --------------------------------------------------
; Stash the username/password on channel d for its NEXT open (the firmware keeps
; them per-channel).  Sent as two control commands (USERNAME then PASSWORD).
H_NLOGIN:
        JSR CHKDEV
        BCS @lgerr
        JSR SETARGS
        JSR GETBYT
        JSR CHKCHAN
        BCS @lgerr
        LDA CHAN
        JSR FN_SETCH
        JSR CHKCOM
        JSR GETURL             ; user$ -> URLBUF / URLLEN
        LDY #NETCMD_USERNAME
        JSR FN_CONTROL_DS
        JSR CHKCOM
        JSR GETURL             ; pass$ -> URLBUF / URLLEN
        LDY #NETCMD_PASSWORD
        JSR FN_CONTROL_DS
        JMP SPRESULT
@lgerr: RTS

;--- NHTTPMODE d, mode -------------------------------------------------------
; Set the HTTP channel sub-mode on an already-open HTTP channel d.  mode:
;   0=BODY 1=COLLECT_HEADERS 2=GET_HEADERS 3=SET_HEADERS 4=SET_POST_DATA
; The firmware (process_http) reads the mode from data_buffer[1].
H_NHTTPMODE:
        JSR CHKDEV
        BCS @hmerr
        JSR SETARGS
        JSR GETBYT
        JSR CHKCHAN
        BCS @hmerr
        LDA CHAN
        JSR FN_SETCH
        JSR CHKCOM
        JSR GETBYT             ; mode -> X
        ; The firmware source reads the mode from data_buffer[1] (aux2), but the
        ; deployed binary behaves as if it reads data_buffer[0] (aux1).  Put the
        ; mode in BOTH so it works whichever slot the running firmware reads.
        STX SP_PAYLOAD+2       ; data_buffer[0] = aux1 = mode
        STX SP_PAYLOAD+3       ; data_buffer[1] = aux2 = mode
        LDA #0
        STA SP_PAYLOAD+4       ; pad
        LDA #3
        STA SP_PAYLOAD         ; control-list length = 3 bytes
        LDA #0
        STA SP_PAYLOAD+1
        LDX SPUNIT
        LDY #NETCMD_HTTPMODE
        JSR SP_CONTROL
        JMP SPRESULT
@hmerr: RTS

;--- NTRANS d, mode ----------------------------------------------------------
; Record the current translation mode used by NTYPE (channel 1).  The firmware
; can only set translation at OPEN time (the IWM set-translation control is a
; stub), so this just stashes a byte for NTYPE's next open to consume - no
; SmartPort command is issued.  mode: 0=NONE 1=CR 2=LF 3=CR/LF 4=PETSCII.
; d is validated (1..15) for consistency; a single value is kept.
H_NTRANS:
        JSR CHKDEV
        BCS @err
        JSR SETARGS
        JSR GETBYT
        JSR CHKCHAN            ; validate channel 1..15
        BCS @err
        JSR CHKCOM
        JSR GETBYT             ; mode -> X
        STX CURTRANS
        CLC
        LDA #0
@err:   RTS

;=============================================================================
; SPRESULT - turn the SmartPort carry (set on entry = device error) into a
; command return: CLC + A=0 on success, or SEC + A = I/O ERROR so ONERR can
; catch it.  Tail-called by the filesystem commands.
;=============================================================================
SPRESULT:
        BCS @err
        CLC
        LDA #0
        RTS
@err:
        LDA #BE_IOERROR
        SEC
        RTS

;=============================================================================
; STORESTR - assign the SP_COUNT bytes in SP_PAYLOAD to the string variable
; whose descriptor address was saved in RDVAR (by an earlier PTRGET).  Makes
; fresh string space of exactly SP_COUNT bytes and copies the data in.
; Used by NREAD and NJSONQUERY.
;=============================================================================
STORESTR:
        LDA RDVAR
        STA VARPTR
        LDA RDVAR+1
        STA VARPTR+1
        LDA SP_COUNT
        JSR STRINI             ; make string space (len A); DSCTMP = descriptor
        LDY #0
        LDA DSCTMP
        STA (VARPTR),Y         ; length
        INY
        LDA DSCTMP+1
        STA (VARPTR),Y         ; addr lo
        INY
        LDA DSCTMP+2
        STA (VARPTR),Y         ; addr hi
        LDA SP_COUNT
        LDX #<SP_PAYLOAD
        LDY #>SP_PAYLOAD
        JMP MOVSTR             ; copy data into the new string space; ends in RTS

;=============================================================================
; Printer redirect - route BASIC.SYSTEM console output to the FujiNet
; SmartPort PRINTER device.
;
; CALL 32771 = printer on, CALL 32774 = back to the screen.
;
; BI's I/O architecture (global page): CSW/KSW stay pointed at BI's wedge; BI
; delivers each character through its ACTIVE output vector VECOUT ($BE30,
; default COUT1).  PRON/PROFF swap VECOUT - the only hook point that works:
;   - hooking CSW directly does NOT survive (BI re-syncs CSW; the hook drops
;     out after a character - observed on hardware);
;   - PR#n and the PR#n,A<addr> address form both fail with NO DEVICE
;     CONNECTED: BI validates the vector before use and rejects anything that
;     is not a real slot ROM, so neither planting PRHOOK in the $BE10+2n slot
;     table nor the address form can select a RAM routine (ProDOS 2.4.3).
;
; PROFF also flushes a pending partial line (a PRINT ending in ";").
;=============================================================================
PRON:
        LDA SPPUNIT            ; no printer found at install time -> do nothing
        BNE @go
        RTS
@go:
        LDA #0
        STA PRLEN
        LDA VECOUT             ; remember the active output device for PROFF
        STA SAVVEC
        LDA VECOUT+1
        STA SAVVEC+1
        LDA #<PRHOOK           ; and make the printer the output device
        STA VECOUT
        LDA #>PRHOOK
        STA VECOUT+1
        RTS

PROFF:
        JSR PRFLUSH            ; push out any pending partial line
        LDA SAVVEC             ; restore the previous output device
        STA VECOUT
        LDA SAVVEC+1
        STA VECOUT+1
        RTS

; PRHOOK - the output DEVICE routine (installed in VECOUT by PRON).  A =
; character (high bit set).  Line-buffer it and flush to the printer on CR or
; at 80 columns.  Terminal: no screen echo, like a PR#-selected printer card.
; Preserves A/X/Y like COUT1.
PRHOOK:
        STA PRCH               ; stash the char
        TXA
        PHA
        TYA
        PHA
        LDA PRCH
        AND #$7F               ; printers want plain ASCII
        LDY PRLEN
        STA PRLINEBUF,Y
        INC PRLEN
        CMP #CR
        BEQ @flush
        LDA PRLEN
        CMP #80
        BCC @done
@flush:
        JSR PRFLUSH
@done:
        PLA
        TAY
        PLA
        TAX
        LDA PRCH               ; restore the char (COUT contract)
        RTS

; PRFLUSH - write the buffered line (PRLEN bytes) to the PRINTER unit, then
; reset the buffer.  The SmartPort write goes through SPDISPATCH, which saves
; and restores CSW/KSW/TXTPTR, so running it from inside the output hook is safe.
PRFLUSH:
        LDA PRLEN
        BEQ @done
        LDX #0                 ; stage the line into SP_PAYLOAD
@cp:    CPX PRLEN
        BEQ @go
        LDA PRLINEBUF,X
        STA SP_PAYLOAD,X
        INX
        BNE @cp
@go:
        LDY PRLEN              ; Y = byte count
        LDX SPPUNIT            ; X = printer unit
        JSR SP_WRITE
        LDA #0
        STA PRLEN
@done:
        RTS

;=============================================================================
; PUTS - print a NUL-terminated ASCII string at (A=lo, Y=hi).  The high bit is
; set on each byte for normal (non-inverse) COUT display; $00 terminates.
;=============================================================================
PUTS:
        STA STRP
        STY STRP+1
        LDY #0
@lp:    LDA (STRP),Y
        BEQ @done
        ORA #$80
        JSR COUT
        INY
        BNE @lp
@done:  RTS

PRINTBANNER:
        LDA #<MSG_BANNER
        LDY #>MSG_BANNER
        JMP PUTS

;=============================================================================
; PUTHEX - print A as two hex digits.
;=============================================================================
PUTHEX:
        TAX
        JMP PRTX

;=============================================================================
; CHKDEV - fail (SEC + A = NO DEVICE) if no FujiNet NETWORK device was found.
;=============================================================================
CHKDEV:
        LDA SPUNIT
        BNE @ok
        LDA #BE_NODEV
        SEC
        RTS
@ok:    CLC
        RTS

;=============================================================================
; POLLKEY - flow-control keyboard poll for NTYPE's output.
;   CTRL-S pauses: consume it, then wait here until the next key.  If that key
;          is CTRL-C, fall through to abort; any other key resumes.
;   CTRL-C aborts: consume it and return carry SET so the caller stops.
;   Any other key (or no key) is left queued; return carry CLEAR.
; Preserves X and Y (touches A only), so it can sit inside the byte loop.
;=============================================================================
POLLKEY:
        LDA KBD
        BPL @none              ; bit7 clear -> no key waiting
        CMP #CTRL_C
        BEQ @abort
        CMP #CTRL_S
        BNE @none              ; other key -> ignore, leave it queued
        BIT KBDSTRB            ; consume the CTRL-S
@wait:  LDA KBD                ; paused: hold until the next key
        BPL @wait
        BIT KBDSTRB            ; consume the resume key
        CMP #CTRL_C            ; ...but CTRL-C while paused still aborts
        BEQ @abrt
@none:  CLC
        RTS
@abort: BIT KBDSTRB            ; consume the CTRL-C
@abrt:  SEC
        RTS

;=============================================================================
; OPENCK - FN_OPEN on the already-selected channel, then verify the open
; actually succeeded.  The firmware's OPEN reply is ALWAYS "no error" (a
; failed protocol open only records its error in channel status - see
; iwmNetwork::open() in the firmware), so ask FN_STATUS and inspect the error
; byte: below 128, or 136 (EOF - an empty file is a fine open), is success.
; On failure: close the channel and return SEC with A = PATH NOT FOUND for
; err 170, I/O ERROR for anything else.
;
; Deliberately NOT used for HTTP(S) opens in H_NOPEN: an HTTP status call
; fires the pending transaction (the firmware performs the request on the
; first status/read), which would break the NHTTPMODE set-headers-then-fetch
; recipe.  HTTP open errors stay deferred to NSTATUS, as documented.
;=============================================================================
OPENCK:
        JSR FN_OPEN
        JSR FN_STATUS          ; SP_PAYLOAD = [avail lo][avail hi][conn][err]
        LDA SP_PAYLOAD+3
        CMP #128
        BCC @ok                ; informational -> open succeeded
        CMP #NERR_EOF
        BEQ @ok                ; empty-but-open is not a failure
        STA OPENERR            ; failed: clean up, then map the code
        JSR FN_CLOSE
        LDA OPENERR
        CMP #NERR_FNF
        BEQ @fnf
        LDA #BE_IOERROR
        SEC
        RTS
@fnf:   LDA #BE_PATHNF
        SEC
        RTS
@ok:    CLC
        RTS

;=============================================================================
; ISHTTP - carry set if the spec in URLBUF names an HTTP or HTTPS protocol:
; the four characters after the first ':' spell "HTTP" (case-insensitive).
;=============================================================================
ISHTTP:
        LDX #0
@fc:    CPX URLLEN             ; find the first ':'
        BCS @no                ; none -> not HTTP
        LDA URLBUF,X
        INX
        CMP #':'
        BNE @fc
        LDY #0
@cm:    LDA URLBUF,X
        AND #$DF               ; uppercase ASCII letters
        CMP HTTPSTR,Y
        BNE @no
        INX
        INY
        CPY #4
        BNE @cm
        SEC
        RTS
@no:    CLC
        RTS

;=============================================================================
; CHKCHAN - validate the device number in X (1..15) and store it in CHAN.
; Returns CLC on success, or SEC + A = RANGE error.
;=============================================================================
CHKCHAN:
        CPX #1
        BCC @bad
        CPX #16
        BCS @bad
        STX CHAN
        CLC
        RTS
@bad:
        LDA #BE_RANGE
        SEC
        RTS

;=============================================================================
; GETURL - parse a string argument at TXTPTR (literal "..." or a string
; variable) into URLBUF, length in URLLEN.
;=============================================================================
GETURL:
        JSR CHRGOT
        CMP #'"'
        BEQ @lit
        ; --- string variable ---
        JSR PTRGET             ; VARPTR -> descriptor [len][lo][hi]
        LDY #0
        LDA (VARPTR),Y
        STA URLLEN
        INY
        LDA (VARPTR),Y
        STA GUSRC
        INY
        LDA (VARPTR),Y
        STA GUSRC+1
        LDX #0
        LDY #0
@vcp:
        CPX URLLEN
        BEQ @done
        LDA (GUSRC),Y
        STA URLBUF,X
        INX
        INY
        BNE @vcp
@done:
        RTS
        ; --- quoted literal ---
        ; TXTPTR points AT the opening quote.  Copy the raw bytes after it up to
        ; the closing quote (or end-of-line), then advance TXTPTR past what we
        ; consumed so the caller's next CHKCOM sees the following delimiter.
        ;
        ; We must NOT use CHRGET here: it skips spaces and treats ':' as an
        ; end-of-statement marker, so it would truncate every "N:..." devicespec
        ; at the first colon and leave TXTPTR on the ':' (-> ?SYNTAX ERROR).
@lit:
        LDX #0
        LDY #1                 ; index 0 is the opening quote; body starts at 1
@lcp:
        LDA (TXTPTR),Y
        BEQ @lend              ; NUL -> end of line, no closing quote
        CMP #'"'
        BEQ @lclose
        STA URLBUF,X
        INX
        INY
        BNE @lcp
@lclose:
        INY                    ; step past the closing quote
@lend:
        STX URLLEN
        TYA                    ; advance TXTPTR by the Y bytes we scanned
        CLC
        ADC TXTPTR
        STA TXTPTR
        BCC @ldone
        INC TXTPTR+1
@ldone:
        RTS

;=============================================================================
; WORDSAV / BYTESAV - store a value into the numeric variable named at TXTPTR.
;   WORDSAV: A = value high, Y = value low
;   BYTESAV: Y = value (0..255)
;=============================================================================
BYTESAV:
        LDA #0
WORDSAV:
        JSR GIVAYF             ; (A=hi, Y=lo) -> FAC
        JSR PTRGET             ; parse variable name; A=addr lo, Y=addr hi
        TAX                    ; X = addr lo (Y already = addr hi)
        JSR MOVMF              ; pack FAC into the variable
        RTS

        .include "smartport.inc"

;=============================================================================
; Keyword table.  Each entry: plain-ASCII name, $00, handler address (lo,hi).
; Terminated by a $00 first byte.  No entry may be a prefix of another (a
; trailing delimiter is required at match time, which also guards this).
;=============================================================================
        .segment "RODATA"

CMDTABLE:
        .byte "NOPEN",0
        .addr H_NOPEN
        .byte "NCLOSE",0
        .addr H_NCLOSE
        .byte "NSTATUS",0
        .addr H_NSTATUS
        .byte "NREAD",0
        .addr H_NREAD
        .byte "NWRITE",0
        .addr H_NWRITE
        .byte "NJSONPARSE",0
        .addr H_NJSONPARSE
        .byte "NJSONQUERY",0
        .addr H_NJSONQUERY
        .byte "NCD",0
        .addr H_NCD
        .byte "NCAT",0
        .addr H_NCAT
        .byte "NCATALOG",0
        .addr H_NCATALOG
        .byte "NMKDIR",0
        .addr H_NMKDIR
        .byte "NRMDIR",0
        .addr H_NRMDIR
        .byte "NDEL",0
        .addr H_NDEL
        .byte "NLOAD",0
        .addr H_NLOAD
        .byte "NSAVE",0
        .addr H_NSAVE
        .byte "NACCEPT",0
        .addr H_NACCEPT
        .byte "NLOGIN",0
        .addr H_NLOGIN
        .byte "NHTTPMODE",0
        .addr H_NHTTPMODE
        .byte "NTRANS",0
        .addr H_NTRANS
        .byte "NTYPE",0
        .addr H_NTYPE
        .byte 0                 ; end of table

MSG_BANNER:
        .byte $8D               ; CR
        .byte "FUJINET BASIC EXTENSION INSTALLED",$8D
        .byte "20 COMMANDS - NOPEN..NTYPE",$8D
        .byte 0
MSG_NOROOM:
        .byte $8D,"FUJINET: NOT ENOUGH ROOM BELOW HIMEM",$8D,0
MSG_NETOK:
        .byte "FUJINET NETWORK DEVICE AT SP UNIT $",0
MSG_PROK:
        .byte "FUJINET PRINTER AT SP UNIT $",0
MSG_NOSP:
        .byte "SMARTPORT CARD NOT FOUND",$8D,0
MSG_NONET:
        .byte "FUJINET NETWORK DEVICE NOT FOUND",$8D,0

HTTPSTR:
        .byte "HTTP"            ; protocol sniff for ISHTTP

; --- the error trap's decoys (see CMDENTRY) ---
; FAKETGT is where HANDLERR points TXTPTR: the ASCII line number its GOTO
; parses.  FAKEPROG is where the swapped TXTTAB points: a one-line tokenized
; program, "0 CALL 32777", whose CALL lands in RECOVER via the entry table.
FAKETGT:
        .byte "0",0
FAKEPROG:
        .addr FPEND             ; line link
        .word 0                 ; line number 0
        .byte TOK_CALL,"32777",0
FPEND:  .word 0                 ; end-of-program marker

;=============================================================================
; Resident variables + scratch buffers (uninitialized; protected by HIMEM).
;=============================================================================
        .segment "BSS"

CMDSTART:  .res 1              ; index in $200 where the keyword starts
ARGSTART:  .res 1              ; index in $200 where the arguments start
HANDLERVEC: .res 2             ; real command handler addr (CMDENTRY jumps here)
SAVTXT:    .res 2              ; Applesoft TXTPTR saved across a command
SAVCURLIN: .res 2              ; Applesoft CURLIN saved across a command
SAVONERR:  .res 6              ; ERRFLG + ONRTXT + ONRLIN + TRCFLG across a command
SAVTTAB:   .res 2              ; the REAL TXTTAB while the error trap is armed
TRAPSP:    .res 1              ; stack level RECOVER unwinds to

; --- transport / command state ---
SPDISP:    .res 2              ; SmartPort dispatch address (JMP (SPDISP))
SPUNIT:    .res 1              ; SmartPort unit # of the "NETWORK" device (0=none)
SPPUNIT:   .res 1              ; SmartPort unit # of the "PRINTER" device (0=none)
SAVVEC:    .res 2              ; output device saved by PRON, restored by PROFF
PRLEN:     .res 1              ; printer line-buffer fill level
PRCH:      .res 1              ; printer hook: saved output character
FDNAMEBUF: .res 7              ; FINDDEV: 7-char target device name
PRLINEBUF: .res 88            ; printer line buffer (flushed at 80 / on CR)
DCOUNT:    .res 1              ; SmartPort device count
CURDEV:    .res 1              ; device being probed by FINDNET
SP_COUNT:  .res 2              ; bytes moved by the last SmartPort read/write
SAVHK:     .res 6              ; saved CSW/KSW ($36-$39) + TXTPTR ($B8/$B9)
FNCTMP:    .res 1              ; scratch: saved control code
NCTLCMD:   .res 1              ; NCTL: control code held across devicespec parse
OPENERR:   .res 1              ; OPENCK: channel error held across the cleanup close
JQRETRY:   .res 1              ; NJSONQUERY: status-poll retry counter
SVLEN:     .res 2              ; NSAVE: bytes of program left to write
NEXTPTR:   .res 2              ; RELINK: next-line address scratch
CHAN:      .res 1              ; current channel (1..15)
MODE:      .res 1              ; open mode
TRANS:     .res 1              ; open translation
CURTRANS:  .res 1              ; NTRANS: standing translation for NTYPE (chan 1)
BUFLEN:    .res 1              ; requested read/write length
URLLEN:    .res 1              ; length of URLBUF contents
RDVAR:     .res 2              ; saved buf$ descriptor address across a read
CMD_LIST:  .res 16             ; SmartPort parameter list

; --- big buffers ---
ARGBUF:    .res 256            ; clean (hi-bit-stripped, NUL-term) argument copy
                               ; (also the install-time zero-page snapshot)
URLBUF:    .res 256            ; parsed devicespec / string argument
SP_PAYLOAD: .res 320           ; SmartPort control-list / read-write data buffer

RES_END:                       ; end of the resident image (for the room check)
