;*****************************************************************************
; smartport.inc - SmartPort transport for the FujiNet network device
;
; The current FujiNet firmware exposes ONE SmartPort device named "NETWORK"
; (lib/device/iwm/network.cpp).  Channels (N1, N2, ...) are sub-selected by
; NETCMD_SET_CHANNEL (0xFA) rather than by separate devices.  We therefore:
;   1. find the SmartPort card slot and its dispatch entry (FINDSP)
;   2. find the "NETWORK" device's SmartPort unit number (FINDNET)
;   3. before each channel op, set the active channel (FN_SETCH)
;
; SmartPort call convention (JSR the dispatcher, inline cmd + param list):
;       JSR CALL_DISPATCHER
;       .byte <cmd>
;       .word <param list>
; On return: A = SmartPort error, carry set on error, X/Y = byte count.
;
; Control lists are length-prefixed: SP_PAYLOAD[0..1] = data byte count,
; SP_PAYLOAD[2..] = the bytes the firmware sees as data_buffer[0..].
; Status/read replies are written straight into SP_PAYLOAD[0..].
;*****************************************************************************

;----------------------------------------------------------------------------
; CALL_DISPATCHER - transfer to the SmartPort firmware entry.  The inline
; cmd/param-list bytes that follow each JSR are consumed by the firmware.
;----------------------------------------------------------------------------
CALL_DISPATCHER:
        JMP (SPDISP)

;----------------------------------------------------------------------------
; FINDSP - locate the SmartPort card (slots 7..1) and compute its dispatch
; address into SPDISP.  Returns carry clear on success, carry set if none.
;----------------------------------------------------------------------------
FINDSP:
        LDA #$C7               ; start at slot 7 ($C700)
        STA SLOTPTR+1
        LDA #$00
        STA SLOTPTR
@scan:
        LDY #$01               ; signature bytes live at offsets 1,3,5,7
        LDX #$00
@match:
        LDA (SLOTPTR),Y
        CMP SP_SIG,X
        BNE @nextslot
        INY
        INY
        INX
        CPX #$04
        BNE @match
        ; found: SLOTPTR = $Cn00.  dispatch = $Cn00 + [$CnFF] + 3
        LDY #$FF
        LDA (SLOTPTR),Y
        CLC
        ADC SLOTPTR
        STA SPDISP
        LDA SLOTPTR+1
        ADC #$00
        STA SPDISP+1
        LDA SPDISP
        CLC
        ADC #$03
        STA SPDISP
        LDA SPDISP+1
        ADC #$00
        STA SPDISP+1
        CLC
        RTS
@nextslot:
        DEC SLOTPTR+1            ; $C700 -> $C600 -> ...
        LDA SLOTPTR+1
        CMP #$C0               ; below slot 1?
        BNE @scan
        SEC                    ; not found
        RTS

;----------------------------------------------------------------------------
; SPDISPATCH - issue the SmartPort call whose command number is in A, with the
; parameter list already built in CMD_LIST.
;
; A direct SmartPort call can leave CSW/KSW ($36-$39) clobbered (the card uses
; page zero as scratch, and may reset the output link to the standard COUT).
; That silently unhooks BASIC.SYSTEM's command wedge, after which CATALOG /
; OPEN / our N-commands all fall through to Applesoft as ?SYNTAX ERROR.  So we
; save $36-$39 before the call and restore them after.  (The original ext.
; escaped this because it ran under plain Applesoft, where a standard COUT link
; is fine.)
;
; Returns A = error, carry = error, X/Y = byte count (also stored in SP_COUNT).
;----------------------------------------------------------------------------
SPDISPATCH:
        STA SPCMDN             ; self-modify the inline command byte
        LDX #3                 ; save CSW/KSW contents ($36-$39, contiguous)
@sv:    LDA CSW,X
        STA SAVHK,X
        DEX
        BPL @sv
        LDA TXTPTR             ; save TXTPTR ($B8/$B9); parse resumes after us
        STA SAVHK+4
        LDA TXTPTR+1
        STA SAVHK+5
        JSR CALL_DISPATCHER
SPCMDN: .byte 0                ; <- patched command number
        .addr CMD_LIST
        ; firmware returns here: A=error, carry, X=count lo, Y=count hi
        STX SP_COUNT
        STY SP_COUNT+1
        PHP                    ; preserve error/carry across the restore
        PHA
        LDX #3                 ; restore CSW/KSW ($36-$39)
@rs:    LDA SAVHK,X
        STA CSW,X
        DEX
        BPL @rs
        LDA SAVHK+4            ; restore TXTPTR
        STA TXTPTR
        LDA SAVHK+5
        STA TXTPTR+1
        PLA
        PLP
        RTS

;----------------------------------------------------------------------------
; SmartPort primitives.  Each sets up CMD_LIST then tail-calls SPDISPATCH.
;   SP_STATUS  X=unit  Y=status code   -> reply in SP_PAYLOAD, count in X/Y
;   SP_CONTROL X=unit  Y=control code  -> control list in SP_PAYLOAD
;   SP_READ    X=unit  Y=byte count    -> data in SP_PAYLOAD, count in SP_COUNT
;   SP_WRITE   X=unit  Y=byte count    -> data taken from SP_PAYLOAD
;----------------------------------------------------------------------------
SP_STATUS:
        LDA #3
        STA CMD_LIST           ; param count
        STX CMD_LIST+1         ; unit
        LDA #<SP_PAYLOAD
        STA CMD_LIST+2         ; status list pointer
        LDA #>SP_PAYLOAD
        STA CMD_LIST+3
        STY CMD_LIST+4         ; status code
        LDA #SP_CMD_STATUS
        JMP SPDISPATCH

SP_CONTROL:
        LDA #3
        STA CMD_LIST
        STX CMD_LIST+1         ; unit
        LDA #<SP_PAYLOAD
        STA CMD_LIST+2         ; control list pointer
        LDA #>SP_PAYLOAD
        STA CMD_LIST+3
        STY CMD_LIST+4         ; control code
        LDA #SP_CMD_CONTROL
        JMP SPDISPATCH

SP_READ:
        LDA #4
        STA CMD_LIST
        STX CMD_LIST+1         ; unit
        LDA #<SP_PAYLOAD
        STA CMD_LIST+2         ; data buffer pointer
        LDA #>SP_PAYLOAD
        STA CMD_LIST+3
        STY CMD_LIST+4         ; byte count lo
        LDA #0
        STA CMD_LIST+5         ; byte count hi (reads capped at 255)
        STA CMD_LIST+6         ; address (unused for network)
        STA CMD_LIST+7
        STA CMD_LIST+8
        LDA #SP_CMD_READ
        JMP SPDISPATCH

SP_WRITE:
        LDA #4
        STA CMD_LIST
        STX CMD_LIST+1         ; unit
        LDA #<SP_PAYLOAD
        STA CMD_LIST+2         ; data buffer pointer
        LDA #>SP_PAYLOAD
        STA CMD_LIST+3
        STY CMD_LIST+4         ; byte count lo
        LDA #0
        STA CMD_LIST+5         ; byte count hi
        STA CMD_LIST+6
        STA CMD_LIST+7
        STA CMD_LIST+8
        LDA #SP_CMD_WRITE
        JMP SPDISPATCH

;----------------------------------------------------------------------------
; FINDDEV - scan the SmartPort devices for one whose 7-char DIB name matches the
; 7 bytes at FDNAMEBUF.  Compared with absolute addressing (no zero-page pointer
; at risk across the SP_STATUS calls).  Returns the matching unit number in A,
; or 0 if not found.
;----------------------------------------------------------------------------
FINDDEV:
        LDX #0                 ; unit 0, status code 0 -> device count
        LDY #SP_STATUS_CODE
        JSR SP_STATUS
        LDA SP_PAYLOAD         ; first status byte = number of devices
        STA DCOUNT
        LDX #1                 ; devices are numbered from 1
@loop:
        STX CURDEV
        LDY #SP_STATUS_DIB     ; device information block
        JSR SP_STATUS
        LDA SP_PAYLOAD+4       ; DIB id-string length
        CMP #7                 ; both "NETWORK" and "PRINTER" are 7 chars
        BNE @next
        LDX #0
@cmp:
        LDA SP_PAYLOAD+5,X
        CMP FDNAMEBUF,X
        BNE @next
        INX
        CPX #7
        BNE @cmp
        LDA CURDEV             ; matched
        RTS
@next:
        LDX CURDEV
        INX
        CPX DCOUNT
        BCC @loop              ; more devices below the count
        BEQ @loop              ; also test the last device (unit == count)
        LDA #0                 ; exhausted, not found
        RTS

;----------------------------------------------------------------------------
; FINDNET / FINDPRINTER - copy the target name into FDNAMEBUF, locate the unit
; via FINDDEV, and store it in SPUNIT / SPPUNIT (0 = not found).
;----------------------------------------------------------------------------
FINDNET:
        LDX #6
@cp:    LDA NETNAME,X
        STA FDNAMEBUF,X
        DEX
        BPL @cp
        JSR FINDDEV
        STA SPUNIT
        RTS

FINDPRINTER:
        LDX #6
@cp:    LDA PRNAME,X
        STA FDNAMEBUF,X
        DEX
        BPL @cp
        JSR FINDDEV
        STA SPPUNIT
        RTS

;============================================================================
; FujiNet channel operations, layered on the primitives above.
;
; SP_PAYLOAD is shared, and FN_SETCH runs a full SET_CHANNEL round-trip using
; it.  So the rule is: a command handler calls FN_SETCH ONCE (right after it
; parses the channel), and the operations below assume the active channel is
; already selected and never call FN_SETCH themselves.  That way an operation
; is free to stage data into SP_PAYLOAD without a later SET_CHANNEL clobbering
; it.
;============================================================================

;----------------------------------------------------------------------------
; FN_SETCH - make channel A the active network unit (NETCMD_SET_CHANNEL).
;----------------------------------------------------------------------------
FN_SETCH:
        STA SP_PAYLOAD+2       ; data_buffer[0] = channel
        LDA #1
        STA SP_PAYLOAD         ; count = 1 byte
        LDA #0
        STA SP_PAYLOAD+1
        LDX SPUNIT
        LDY #NETCMD_SET_CHANNEL
        JMP SP_CONTROL

;----------------------------------------------------------------------------
; FN_OPEN - open the active channel to URLBUF (URLLEN bytes) with MODE / TRANS.
;----------------------------------------------------------------------------
FN_OPEN:
        LDA MODE
        STA SP_PAYLOAD+2       ; data_buffer[0] = mode
        LDA TRANS
        STA SP_PAYLOAD+3       ; data_buffer[1] = trans
        LDX #0                 ; copy URL -> data_buffer[2..]
@cp:
        CPX URLLEN
        BEQ @cpdone
        LDA URLBUF,X
        STA SP_PAYLOAD+4,X
        INX
        BNE @cp
@cpdone:
        LDA #0
        STA SP_PAYLOAD+4,X     ; NUL terminate
        ; count = mode + trans + url + NUL = URLLEN + 3
        LDA URLLEN
        CLC
        ADC #3
        STA SP_PAYLOAD
        LDA #0
        ADC #0
        STA SP_PAYLOAD+1
        LDX SPUNIT
        LDY #NETCMD_OPEN
        JMP SP_CONTROL

;----------------------------------------------------------------------------
; FN_CLOSE - close the active channel.
;----------------------------------------------------------------------------
FN_CLOSE:
        LDA #0
        STA SP_PAYLOAD         ; empty control list
        STA SP_PAYLOAD+1
        LDX SPUNIT
        LDY #NETCMD_CLOSE
        JMP SP_CONTROL

;----------------------------------------------------------------------------
; FN_STATUS - query the active channel; on return
; SP_PAYLOAD = [avail_lo][avail_hi][conn][err]
;----------------------------------------------------------------------------
FN_STATUS:
        LDX SPUNIT
        LDY #NETCMD_STATUS
        JMP SP_STATUS

;----------------------------------------------------------------------------
; FN_READ - read A bytes from the active channel into SP_PAYLOAD;
; SP_COUNT = actual bytes read.
;----------------------------------------------------------------------------
FN_READ:
        TAY
        LDX SPUNIT
        JMP SP_READ

;----------------------------------------------------------------------------
; FN_WRITE - write A bytes from SP_PAYLOAD[0..] to the active channel.  The
; caller must have staged the data in SP_PAYLOAD already (after FN_SETCH).
;----------------------------------------------------------------------------
FN_WRITE:
        TAY
        LDX SPUNIT
        JMP SP_WRITE

;----------------------------------------------------------------------------
; FN_CONTROL_DS - control command whose data is the devicespec in URLBUF/URLLEN
; (used by NCD/NMKDIR/NRMDIR/NDEL).  Y = control code.  The caller has already
; selected the channel.
;----------------------------------------------------------------------------
FN_CONTROL_DS:
        STY FNCTMP             ; save control code
        LDX #0
@cp:
        CPX URLLEN
        BEQ @done
        LDA URLBUF,X
        STA SP_PAYLOAD+2,X
        INX
        BNE @cp
@done:
        LDA #0
        STA SP_PAYLOAD+2,X     ; NUL terminate
        LDA URLLEN             ; count = URLLEN + 1 (NUL)
        CLC
        ADC #1
        STA SP_PAYLOAD
        LDA #0
        ADC #0
        STA SP_PAYLOAD+1
        LDX SPUNIT
        LDY FNCTMP
        JMP SP_CONTROL

NETNAME: .byte "NETWORK"
PRNAME:  .byte "PRINTER"
SP_SIG:  .byte $20,$00,$03,$00
