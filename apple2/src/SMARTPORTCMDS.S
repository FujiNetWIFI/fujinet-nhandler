;*****************************************************
; Smartport Commands
;
; Generic smartport commands for use with Fujinet
; By Norman Davie
;
; NOTE: Relocation code does not expect data to be mixed
;       with code.  As a result, we need to put NOPs where
;       CMDLIST would be then fill it later


        .include "APPLEEQU.S"
        .include "ZEROPAGE.S"
        .include "MACROS.S"

SP_ERR                  =       $FE

SP_CMD_STATUS           =       $00
SP_CMD_READ_BLOCK       =       $01
SP_CMD_WRITE_BLOCK      =       $02
SP_CMD_FORMAT           =       $03
SP_CMD_CONTROL          =       $04
SP_CMD_INIT             =       $05
SP_CMD_OPEN             =       $06
SP_CMD_CLOSE            =       $07
SP_CMD_READ             =       $08
SP_CMD_WRITE            =       $09

SP_STATUS_CODE          =       $00     ; RETURN DEVICE STATUS
SP_STATUS_DIB           =       $03     ; RETURN DEVICE INFORMATION BLOCK
SP_STATUS_DIB_EXTRA     =       $04     ; RETURN DEVICE INFORMATION BLOCK EXTRA
SP_STATUS_LAST_ERROR    =       $05
SP_STATUS_RETURN_DATA   =       $06     ; RETURN BYTES/BLOCK PARAMETER FOR DEVICE

SP_ERROR_OK             =       $00
SP_ERROR_BAD_CMD        =       $01
SP_ERROR_BAD_PCNT       =       $02     ; BAD CALL PARAMETER COUNT
SP_ERROR_BUS_ERR        =       $06     ; bus error in IWM chip
SP_ERROR_BAD_UNIT       =       $11     ; UNIT NUMBER $00 WAS USED
SP_ERROR_BAD_CTRL       =       $21     ; CTRL OR STATUS CODE WAS NOT SUPPORTED
SP_ERROR_BAD_CTRL_PARM  =       $22     ; CTRL PARAMTER LIST CONTAINS INVALID INFO
SP_ERROR_IO_ERROR       =       $27     ; CAN'T ACCESS DEVICE OR DEVICE ERROR
SP_ERROR_NO_DRIVE       =       $28     ; DEVICE IS NOT CONNECTED
SP_ERROR_NO_WRITE       =       $2B     ; MEDIUM IS WRITE PROTECTED
SP_ERROR_BAD_BLOCK      =       $2D     ; BLOCK NUMBER IS OUTSIDE OF RANGE
SP_ERROR_DISK_SW        =       $2E     ; DISK SWITCH TOOK PLACE
SP_ERROR_OFFLINE        =       $2F     ; DEVICE OFFLINE OR NO DISK IN DRIVE
SP_ERROR_DEV_SPEC0      =       $30     ; DEVICE SPECIFIC ERRORS
SP_ERROR_DEV_SPECF      =       $3F     ; DEVICE SPECIFIC ERRORS
;SP_ERROR_RESERVED $40-$4F
SP_ERROR_NON_FATAL50    =       $50     ; DEVICE SPECIFIC WARNING
SP_ERROR_NON_FATAL7F    =       $7F     ; DEVICE SPECIFIC WARNING        

SP_INIT_PARAM_COUNT     =       1 
SP_OPEN_PARAM_COUNT     =       1 
SP_CLOSE_PARAM_COUNT    =       1 
SP_READ_PARAM_COUNT     =       4
SP_WRITE_PARAM_COUNT    =       4 
SP_STATUS_PARAM_COUNT   =       3
SP_CONTROL_PARAM_COUNT  =       3


SP_ERROR_NOT_FOUND      =       SP_ERROR_NON_FATAL50


SP_STATUS_FLAG_BLOCK_DEVICE     = %10000000
SP_STATUS_FLAG_WRITE_ALLOWED    = %01000000
SP_STATUS_FLAG_READ_ALLOWED     = %00100000
SP_STATUS_FLAG_DEVICE_ONLINE    = %00010000
SP_STATUS_FLAG_FORMAT_ALLOWED   = %00001000
SP_STATUS_FLAG_WRITE_PROTECTED  = %00000100
SP_STATUS_FLAG_DEVICE_INTERRUPT = %00000010
SP_STATUS_FLAG_DEVICE_OPEN      = %00000001


SLOT_ADDR		=	ZP2
SLOT_ADDR_LO	    	=	ZP2_LO
SLOT_ADDR_HI		=	ZP2_HI


CLEAR_CMD_LIST:
                LDA #$EA

                STA cmd_list0
                STA cmd_list1
                STA cmd_list2
                STA cmd_list3
                STA cmd_list4
                STA cmd_list5

                STA cmd_list0+1
                STA cmd_list1+1
                STA cmd_list2+1
                STA cmd_list3+1
                STA cmd_list4+1
                STA cmd_list5+1

                STA cmd_open
                STA cmd_close
                STA cmd_control
                STA cmd_read
                STA cmd_write 
                STA cmd_status

                RTS


FILL_CMD_LIST:
                LDA CMD_LIST_ADDR
                STA cmd_list0
                STA cmd_list1
                STA cmd_list2
                STA cmd_list3
                STA cmd_list4
                STA cmd_list5

                LDA CMD_LIST_ADDR+1
                STA cmd_list0+1
                STA cmd_list1+1
                STA cmd_list2+1
                STA cmd_list3+1
                STA cmd_list4+1
                STA cmd_list5+1

                LDA #SP_CMD_OPEN
                STA cmd_open
                LDA #SP_CMD_CLOSE
                STA cmd_close
                LDA #SP_CMD_CONTROL
                STA cmd_control
                LDA #SP_CMD_READ
                STA cmd_read
                LDA #SP_CMD_WRITE
                STA cmd_write 
                LDA #SP_CMD_STATUS
                STA cmd_status

                RTS

;*******************************
; WIPE_PAYLOAD
;   Clear the contents of the payload
;**********************************

WIPE_PAYLOAD:
                SAVE_REGS

                LDA #$00

                LDY #>PAYLOAD_SIZE
                LDX #<PAYLOAD_SIZE
CLR:                
                STA SP_PAYLOAD,X 
                DEX
                BNE CLR
                DEY
                BNE CLR

                RESTORE_REGS
                RTS

;*******************************
; PRINT_SP_PAYLOAD
;   Display the ASCII contents
; of the payload buffer.  Buffer
; is NULL terminated and Length is
; not stored at start of buffer.
;**********************************
PRINT_SP_PAYLOAD:
                SAVE_REGS

                LDX #$00

PPAYLOAD:   
                LDA SP_PAYLOAD+4,X      ; STRING
                ORA #$80
                JSR COUT
                INX
                CLC              ; "NULL" TERMINATED (we just or'd this)
                BCC PPAYLOAD

                RESTORE_REGS
END_PAYLOAD:
                RTS


;*******************************
; PRINT_SP_PAYLOAD_STR
;   Display the ASCII contents
; of the payload buffer.  Buffer
; length is the first byte at the
; start of buffer.
;**********************************
PRINT_SP_PAYLOAD_STR:
                SAVE_REGS

                LDX #$00

PPAYLOAD2:   
                LDA SP_PAYLOAD+5,X      ; STRING
                ORA #$80
                JSR COUT
                INX
                CPX SP_PAYLOAD+4        ; LENGTH OF STRING 
                BNE PPAYLOAD2

                RESTORE_REGS
                RTS

.IF .NOT STRIP_TRACE


;*******************************
; DUMP_SP_PAYLOAD_HEX
;   Display the HEX contents
; of the payload buffer
;**********************************

DUMP_SIZE = 16

DUMP_SP_PAYLOAD_HEX:
                SAVE_REGS

                PRINT_STR PAYLOAD_STR_ADDR

                LDX #$00
PPAYLOAD4:   
                TXA
                PHA                     ; SAVE X PUSH +1

                LDA SP_PAYLOAD,X      ; STRING
                TAX
                JSR PRINT_X

                PLA                     ; RESTORE X -1
                TAX

                INX
                CPX #DUMP_SIZE
                BNE PPAYLOAD4

                RESTORE_REGS
                RTS



;*******************************
; DUMP_SP_PAYLOAD
;   Display the HEX and ASCII contents
; of the payload buffer
;**********************************
DUMP_SP_PAYLOAD:
                JSR DUMP_SP_PAYLOAD_HEX

                SAVE_REGS

                PRINT_STR PAYLOAD_STR_ADDR
                LDX #$00
PPAYLOAD1: 
                TXA
                PHA                     ; SAVE OUR X

                LDA SP_PAYLOAD,X        ; STRING
                CMP #$20
                BPL PRINT_IT 
                LDA #'.'                ; NON-PRINTABLE CHARACTERS ARE SHOWN AN '.'
PRINT_IT:
                ORA #$80                ; MAKE SURE THE HIGH BIT IS
                JSR COUT                ; SET SO IT DOESN'T LOOK INVERSE
                LDA #SPACE
                JSR COUT                ; TWO SPACES
                JSR COUT

                PLA                     ; RESTORE OUR X
                TAX
                INX
                CPX #DUMP_SIZE
                BNE PPAYLOAD1

                JSR CROUT

                RESTORE_REGS

                RTS

;*******************************
; DUMP_CMD_LIST
;   Display the CMD_LIST in HEX 
;**********************************

DUMP_CMD_LIST:
                SAVE_REGS

                PRINT_STR CMD_LIST_STR_ADDR

                LDX #$00
CMDLIST0:   
                TXA
                PHA                     ; SAVE X PUSH +1

                LDA CMD_LIST,X      ; STRING
                TAX
                JSR PRINT_X

                PLA                     ; RESTORE X -1
                TAX

                INX
                CPX #7
                BNE CMDLIST0

                RESTORE_REGS

                RTS


;**********************************

DUMP_SP_PAYLOAD_STR:
                SAVE_REGS

                PRINT_STR LEN_STR_ADDR

                LDA #'['
                JSR COUT
                LDX SP_PAYLOAD+4
                JSR PRTX
                LDA #']'
                JSR COUT


                LDX #$00
PPAYLOAD3:  
                TXA
                PHA
                LDA SP_PAYLOAD+5,X      ; STRING
                ORA #$80
                JSR COUT
                PLA
                TAX
                INX
                CPX SP_PAYLOAD+4
                BNE PPAYLOAD3

                JSR CROUT
                RESTORE_REGS

                RTS

.ENDIF


.IF USE_SP

;*******************************
; FIND_SMARTPORT_SLOT
; INPUT:
;   NONE
;***
; RETURN
;   A = $FF - NO SMARTPORT FOUND
;   A = $CX - WHERE X IS THE SLOT
;**********************************

FIND_SMARTPORT_SLOT:

                DISPLAY_EXT2_TRACE_NO_UNIT FIND_SMARTPORT_SLOT_STR_ADDR

                LDA     #$C7            ; START AT SLOT 7 ($C700)
                STA     SLOT_ADDR_HI
                LDA     #$00
                STA     SLOT_ADDR_LO

SCAN:
                LDY #$01                ; LOOK AT BYTES 1,3,5,AND 7
                LDX #$00

NEXT_MATCH:
                LDA (SLOT_ADDR),Y       ; COMPARE TO THE MAGIC NUMBERS
                CMP SMARTPORT_ID,X      ; 
                BNE NEXT_SLOT           ; NOT THE SAME, SO GO TO NEXT SLOT

                INY                     ; PREPARE TO CHECK THE NEXT NUMBER
                INY
                INX                     ; POINTER TO NEXT NUMBER TO CHECK
                CPX #$04                ; HAVE WE COMPARED ALL 4 NUMBERS?
                BEQ FOUND               ; YES, WE'VE FOUND IT
                BNE NEXT_MATCH          ; MORE TO MATCH

NEXT_SLOT:
                LDX SLOT_ADDR_HI        ; MOVE TO THE NEXT LOWER SLOT
                DEX                     ; $C700 -> $C600
                STX SLOT_ADDR_HI
                CPX #$C0                ; HAVE WE GONE BELOW SLOT 1?
                BEQ NOT_FOUND           ; WE'RE DONE
                BNE SCAN                ; CONTINUE SCANNING

FOUND:
                TXA                    
                CLC
                BCC SLOT_FIND_DONE

NOT_FOUND:
                LDA #$FF                ; WE DIDN'T FIND IT
                STA SLOT_ADDR_LO
                STA SLOT_ADDR_HI

SLOT_FIND_DONE:

.IF .NOT STRIP_TRACE   
.IF EXT2_TRACE 
                SAVE_REGS
                LDA TRACE_FLAG
                BEQ NO_TRACE28
                LDA SLOT_ADDR_HI
                LDX SLOT_ADDR_LO
                JSR PRTAX
                JSR CROUT
 NO_TRACE28:               
                RESTORE_REGS 
.ENDIF 
.ENDIF

                RTS
        
;*******************************
; GET_SMARTPORT_DISPATCH_ADDRESS
; INPUT:
;   NONE
;***
; RETURN
;   -A DISPATCHER ADDRESS HIGH
;   -X DISPATCHER ADDRESS LOW
; OR A AND X WILL BE SET TO $FF
; IF DISPATCHER NOT FOUND
;**********************************
GET_SMARTPORT_DISPATCH_ADDRESS:

                DISPLAY_EXT2_TRACE_NO_UNIT GET_SMARTPORT_DISPATCH_ADDRESS_STR_ADDR

                JSR FIND_SMARTPORT_SLOT 
                CMP #$FF                ; IF A == $FF THEN NOT FOUND
                BEQ NO_DISPATCHER

                LDA SLOT_ADDR_HI
                STA DISPATCHER_ADDR_HI  ; A = $CX WHERE X IS THE SLOT
                LDA SLOT_ADDR_LO
                STA DISPATCHER_ADDR_LO  ; COMPLETE ADDRESS IS $CX00
                
                LDY #$FF
                LDA (SLOT_ADDR),Y        ; j= peek(a+0xFF)
                CLC
                ADC DISPATCHER_ADDR_LO   ; DISPATCHER_ADDR += J
                STA DISPATCHER_ADDR_LO

                LDA DISPATCHER_ADDR_HI
                ADC #$00
                STA DISPATCHER_ADDR_HI

                CLC                     ; DISPATCHER_ADDR += 3
                LDA DISPATCHER_ADDR_LO
                ADC #$03
                STA DISPATCHER_ADDR_LO
                
                LDA DISPATCHER_ADDR_HI
                ADC #$00
                STA DISPATCHER_ADDR_HI

                CLC
                BCC DONE

NO_DISPATCHER:
                LDA #$FF                ; NO ADDRESS FOUND
                LDX #$FF
                STA DISPATCHER_ADDR_HI  ; PUT ADDRESS IN A AND X
                STX DISPATCHER_ADDR_LO
DONE:        
                LDA DISPATCHER_ADDR_HI  ; PUT ADDRESS IN A AND X
                LDX DISPATCHER_ADDR_LO

                RTS

.ENDIF

;******************************************************************
; SP_OPEN
; The Open command opens a logical me on the target device for data I/0. This
; command is used for character devices only. The parameter list for this call is as
; follows:
; Byte Definition
; 0     parameter list length ($03)
; 1     unit number 
; INPUT
; X = UNIT DESTINATION
;******************************************************************
SP_OPEN:

                DISPLAY_EXT2_TRACE SP_OPEN_STR_ADDR

                LDA #SP_OPEN_PARAM_COUNT        ; 3
                STA CMD_LIST                    ; PARAMETER COUNT
                STX CMD_LIST+1                  ; DESTINATION DEVICE
                JSR CALL_DISPATCHER

cmd_open:       .BYTE $EA       ; SP_CMD_OPEN
cmd_list0:      .WORD $EAEA     ; CMD_LIST
                
                BCC SP_OPEN_DONE

OPEN_ERROR:
.IF EXT2_TRACE
                PHA
                PRINT_STR SP_ERROR_STR_ADDR
                PLA
                TAX
                JSR PRTX
                JSR CROUT
.ENDIF
SP_OPEN_DONE:

                RTS

;******************************************************************
; SP_CLOSE
; The Close command closes a logical file on the target device after a data I/O
; sequence is completed. This command is used for character devices only. The
; parameter list for this call is as follows:
; Byte Definition
; 0     parameter list length ($03)
; 1     unit number
; INPUT
; X = UNIT DESTINATION
;******************************************************************
SP_CLOSE:

                DISPLAY_EXT2_TRACE SP_CLOSE_STR_ADDR

                LDA #SP_CLOSE_PARAM_COUNT       ; 3
                STA CMD_LIST                    ; PARAMETER COUNT
                STX CMD_LIST+1                  ; DESTINATION DEVICE
                JSR CALL_DISPATCHER

cmd_close:      .BYTE $EA       ; SP_CMD_CLOSE
cmd_list1:      .WORD $EAEA     ; CMD_LIST
                
                BCC SP_CLOSE_DONE
CLOSE_ERROR:
.IF EXT2_TRACE
                PRINT_STR SP_ERROR_STR_ADDR

                LDX CMD_LIST+1
                JSR PRTX
                JSR CROUT
.ENDIF
SP_CLOSE_DONE:

                RTS


;******************************************************************
; SP_CONTROL
;The Control command provides two basic functions. The first is to execute device
;control routines designed by Apple. The second is to execute Fujinet commands. 
;Although each control code has its own parameter list.
;
; CMD_LIST:
;  0    - PARAMETER
;  1    - UNIT
;  2-3  - CTRL LIST POINTER
;  4    - CTRL CODE
;
; FUJINET SPECIFC
;Byte   Definition
; 'O'-open
;0-1    payload size
;2      mode read or write or both
;3      translation
;4...   url
;
; 'C'-close
;0-1    payload size $00
;
; 'R'-read
;0-1   payload size (bytes to return)
;2..   data
;
; 'W'-write
; 0-1  payload size (bytes to write)
; 2..  data
;
; 'A'-accept
; accept connection
;0-1    payload size $00?
;
; 'c'-close connection
; close client connection
;0-1    payload size $00?
;
;'D'-udp destination
; set UDP destination
;0-1    payload size?
;2...   url?
;
; INPUT
;  X = UNIT
;  Y = CONTROL CODE
;******************************************************************
SP_CONTROL:

.IF .NOT STRIP_TRACE
.IF EXT2_TRACE
                SAVE_REGS
                LDA TRACE_FLAG
                BEQ NO_TRACE14

                TXA
                PHA

                PRINT_STR SP_CONTROL_STR_ADDR
                PLA
                TAX
                
                JSR PRTX
                LDA #'['
                JSR COUT
                LDA CMD_LIST+4
                JSR COUT
                LDA #']'
                JSR COUT
                LDX CMD_LIST+4
                JSR PRTX
                JSR CROUT
NO_TRACE14:                
                RESTORE_REGS
.ENDIF
.ENDIF

                LDA #SP_CONTROL_PARAM_COUNT     ; 3
                STA CMD_LIST                    ; PARAMETER COUNT
                STX CMD_LIST+1                  ; DESTINATION DEVICE     param 1
                LDA SP_PAYLOAD_ADDR             ; CONTROL LIST POINTER   param 2
                STA CMD_LIST+2
                LDA SP_PAYLOAD_ADDR+1           ;                        param 2.5
                STA CMD_LIST+3
                STY CMD_LIST+4                  ; CONTROL CODE           param 3

                ; OTHER ITEMS WILL NEED TO BE
                ; SET BEFORE CALLING THIS ROUTINE
                
.IF .NOT STRIP_TRACE
.IF EXT2_TRACE
        SAVE_REGS
        JSR DUMP_CMD_LIST
        JSR DUMP_SP_PAYLOAD
        RESTORE_REGS
.ENDIF
.ENDIF

                JSR CALL_DISPATCHER

cmd_control:    .BYTE $EA       ; SP_CMD_CONTROL
cmd_list2:      .WORD $EAEA     ; CMD_LIST

                BCC SP_CTRL_DONE

CTRL_ERROR:

.IF EXT_TRACE
                PHA
                PHA
                PRINT_STR SP_ERROR_STR_ADDR
                PLA
                TAX
                JSR PRTX
                JSR CROUT
                PLA
                SEC
.ENDIF

SP_CTRL_DONE:
                RTS

;******************************************************************
; SP_READ
;The Read command reads a specified number of bytes from the target device
;specified in the unit number parameter. The bytes read by this command are
;written into RAM, beginning at the address specified in the data buffer pointer. The
;number of bytes to be read is specified in the byte count parameter. The parameter
;list for this call is as follows:
;
;Byte  Definition
;0      parameter list length ($04)
;1      unit number
;2-3    input buffer pointer (lsb-msb)
;4-5    byte count
;6-7    address pointer
;
;Parameter description
;input buffer pointer: This parameter contains the beginning address of the host data
;buffer to which the target bytes are written.
;byte count: This parameter contains the number of bytes to be read 
;address pointer: This parameter contains the block address of the target block.
;******************************************************************
SP_READ:
                DISPLAY_EXT2_TRACE SP_READ_STR_ADDR

                LDA #SP_READ_PARAM_COUNT
                STA CMD_LIST                    ; [0] PARAMETER COUNT
                STX CMD_LIST+1                  ; [1] X = DESTINATION DEVICE
                LDA SP_PAYLOAD_ADDR
                STA CMD_LIST+2                  ; [2] WHERE TO STORE DATA LO
                LDA SP_PAYLOAD_ADDR+1
                STA CMD_LIST+3                  ; [3] WHERE TO STORE DATA HI
                STY CMD_LIST+4                  ; [4] Y = LENGTH LO ; yeah, max 255 byte payload...
                LDA #$00
                STA CMD_LIST+5                  ; [5] LENGTH HI

                
                JSR CALL_DISPATCHER

cmd_read:       .BYTE $EA       ; SP_CMD_READ               ; READ CALL COMMAND NUMBER
cmd_list3:      .WORD $EAEA     ; CMD_LIST

                STX SP_COUNT
                STY SP_COUNT+1
                STA LAST_SP_ERR
                BCC SP_READ_DONE

ERROR:
.IF EXT2_TRACE
                PHA
                PRINT_STR SP_ERROR_STR_ADDR
                PLA
                TAX
                JSR PRTX
                JSR CROUT
.ENDIF
                SEC

SP_READ_DONE:
                RTS


;******************************************************************
; SP_WRITE
;The Write command writes a specified number of bytes to the target device
;specified in the unit number p4rameter. The bytes written by this command are
;read from RAM, beginning at the address specified in the data buffer pointer. The
;number of bytes to be written is specified in the byte count parameter. The
;parameter list for this call is as follows:
;
;Byte  Definition
;0      parameter list length 
;1      unit number
;2-3    data buffer pointer
;4-5    byte count
;6-7    address pointer
;
;data buffer pointer: This parameter contains the beginning address of the data
;buffer from which the target bytes are written.
;byte count: This parameter contains the number of bytes to write for this
;command.
;address pointer: This parameter contains the block address of the target block.
;
; INPUT
;    X - DEVICE
;    Y - LENGTH
;    SP_PAYLOAD - CONTAINS DATA
;******************************************************************
SP_WRITE:
                DISPLAY_EXT2_TRACE SP_WRITE_STR_ADDR

                LDA #SP_WRITE_PARAM_COUNT
                STA CMD_LIST                    ; PARAMETER COUNT
                STX CMD_LIST+1                  ; DESTINATION DEVICE
                LDA SP_PAYLOAD_ADDR
                STA CMD_LIST+2                  ; DATA BUFFER
                LDA SP_PAYLOAD_ADDR+1
                STY CMD_LIST+4                  ; Y=LENGTH LO
                LDA #$00         
                STA CMD_LIST+5                  ; LENGTH HI
                STA CMD_LIST+6                  ; ADDRESS POINTER LOW
                STA CMD_LIST+7                  ; ADDRESS POINTER MID
                STA CMD_LIST+8                  ; ADDRESS POINTER HI
   
                JSR CALL_DISPATCHER

cmd_write:      .BYTE $EA       ; SP_CMD_WRITE             ; STATUS CALL COMMAND NUMBER
cmd_list4:      .WORD $EAEA     ; CMD_LIST

                STX SP_COUNT
                STY SP_COUNT+1
                STA LAST_SP_ERR
                BCC SP_WRITE_DONE

ERROR2:

.IF .NOT STRIP_TRACE
.IF EXT2_TRACE
                PHA
                PRINT_STR SP_ERROR_STR_ADDR
                PLA
                PHA
                TAX
                JSR PRTX
                JSR CROUT
                PLA ; A = ERROR CODE
.ENDIF
.ENDIF
                SEC
SP_WRITE_DONE:
                RTS




;******************************************************************
; SP_STATUS
;   The Status command returns information about a specific device.
; The information returned by this command is determined by status code.
; On return from a Status call, the microprocessor X and Y registers are set to
; indicate the number of bytes transferred to the Apple II by the command. The X
; register is set to the low byte of the count, and the Y register is set to the high byte.
; The parameter list for this call is as follows:
; Byte Definition
;  0   parameter list length
;  1   unit number
; 2-3  status list pointer (lsb-msb)
;  4   status code
; INPUT
;   X - UNIT DESTINATION
;   Y - STATUS CODE
;       Y='S' return SP[0..1] = Bytes waiting, SP[2] & 0x02 = connected 
;******************************************************************
; examples
;          Params
;               dest
;                      storage
;                                 status code
; CMD_LIST: 03   07    36 3c         53    
;        
; CMD_LIST: 03 07 36 3c 53 
; payload:  00 02 01 01 4e 3a 48 54 54
;                        N  :  H  T  T
;
; CMD_LIST: 03 00 36 3c 00
; payload:  09
;
; CMD_LIST: 03 01 36 3c 03
; payload:  fc 18 01 00 0e 46 55 4a 49 4e 45 54 5f 44 49 53
;                           F  U  J  I  N  E  T  _  D  I  S
; this program
;
; CMD_LIST: 03 00 60 27 00
; payload:  09
;
; CMD_LIST: 03 01 36 3c 03
; payload:  fc 18 01 00 0e 46 55 4a 49 4e 45 54 5f 44 49 53

SP_STATUS:

                DISPLAY_EXT2_TRACE SP_STATUS_STR_ADDR

                LDA #SP_STATUS_PARAM_COUNT
                STA CMD_LIST                    ; PARAMETER COUNT

                STX CMD_LIST+1                  ; X = DESTINATION DEVICE

                LDA SP_PAYLOAD_ADDR             
                STA CMD_LIST+2                  ; STATUS LIST POINTER LO
                LDA SP_PAYLOAD_ADDR+1    
                STA CMD_LIST+3                  ; STATUS LIST POINTER HI

                STY CMD_LIST+4                  ; Y = STATUS CODE

                JSR CALL_DISPATCHER

cmd_status:     .BYTE $EA       ; SP_CMD_STATUS             ; STATUS CALL COMMAND NUMBER
cmd_list5:      .WORD $EAEA     ; CMD_LIST

                STX SP_COUNT
                STY SP_COUNT+1
                STA LAST_SP_ERR

                BCC SP_STATUS_DONE

ERROR3:

SP_STATUS_DONE:
                RTS


;*******************************
; CALL_DISPATCHER
;   Call this routine as a JSR
; INPUT:
;   Immediately following the 
; JSR put the following data
; into your code
; BYTE - Command Number
; WORD - Address for return values
;**********************************
CALL_DISPATCHER:
                JMP (SMARTPORT_DISPATCHER)

;*******************************
; DISPLAY_SP_STATUS
;   Displays the device count,
; vender id, and version number
;**********************************
DISPLAY_SP_STATUS:

                DISPLAY_EXT2_TRACE DISPLAY_SP_STATUS_STR_ADDR

                LDX #$00                                ; SMARTPORT DEVICE ZERO
                LDY #$00
                JSR SP_STATUS
                STX DCOUNT                              ; DCOUNT = NUMBER OF DEVICES

                PRINT_STR COUNT_STR_ADDR
                LDX DCOUNT
                JSR PRTX
                JSR CROUT

                PRINT_STR VENDER_STR_ADDR
                LDA MANUFACTURER
                LDX MANUFACTURER+1
                JSR PRTAX
                JSR CROUT

                PRINT_STR VENDER_VERSION_STR_ADDR
                LDA INTERFACEVER
                LDX INTERFACEVER+1
                JSR PRTAX
                JSR CROUT

                RTS




;*******************************
; DISPLAY_SP_DEVICES
;   Display all the devices on
; the smartport
;**********************************
DISPLAY_SP_DEVICES:

                JSR SETINV
                PRINT_STR DEV_LIST_STR_ADDR
                JSR SETNORM

                JSR CROUT
                JSR CROUT

                LDX #$00
                LDY #SP_CMD_STATUS
                JSR SP_STATUS

                LDX DCOUNT
                INX
                STX NUM_DEVICES

                LDX #$01
                STX BCD
NEXT_DEV:               
                TXA
                PHA

                PRINT_STR UNIT_STR_ADDR

                LDA BCD
                TAX
                JSR PRTX
                
                PRINT_STR NAME_STR_ADDR

                PLA                     ; GET BACK OUR VALUE OF X
                PHA
                TAX

                LDY #SP_STATUS_DIB      ; X = DEVICE 
                JSR SP_STATUS
                BCS DISPLAY_ERROR_OUT   ; SHOULD NEVER HAPPEN, BUT IF IT DOES, JUST EXIT

                JSR PRINT_SP_PAYLOAD_STR

                JSR CROUT

                LDA BCD                 ; WHEN DISPLAYING DEVICE UNITS
                SED                     ; USE DECIMAL NOT HEX
                CLC
                ADC #$01
                STA BCD
                CLD 

                PLA
                TAX
                INX
                CPX NUM_DEVICES
                BNE NEXT_DEV
                CLC
                RTS

DISPLAY_ERROR_OUT:

                PLA
                SEC
                RTS

;***************************************************************

;*******************************
; SP_FIND_DEVICE
;   Looks for the specified smartport device
; INPUT
;   Put NULL terminated string of device to
;   search for in FIND_DEVICE_STR
; RETURNS
;   A = High byte address of string
;   Y = Low byte address of string
;   X = Device number or $FF on failure
;*********************************

SP_FIND_DEVICE:

                DISPLAY_EXT2_TRACE_NO_UNIT SP_FIND_DEVICE_STR_ADDR       ; "SP_FIND_DEVICE:"

                STA ZP1_HI                              ; STORE THE STRING ADDRESS
                STY ZP1_LO
                
                LDX #$00
                LDY #$00
LOOK_FOR_NULL:
                LDA (ZP1),Y                             ; START OF STRING WITHOUT LENGTH
                STA FIND_DEVICE_BUF,X                   
                BEQ GOT_LENGTH                          ; STOP WHEN WE GET TO NULL
                INY
                INX
                CLC
                BCC LOOK_FOR_NULL
GOT_LENGTH:     
                STX FIND_DEVICE_BUF_LEN                 ; SAVE THE LENGTH INCLUDES NULL

.IF .NOT STRIP_TRACE
.IF EXT2_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE19
                PRINT_STR FIND_DEVICE_BUF_ADDR          ; DISPLAY THE STRING WE COLLECTED
                JSR CROUT                               ; CARRIAGE RETURN
NO_TRACE19:                
.ENDIF
.ENDIF

                LDX #$00
                LDY #SP_CMD_STATUS                      ; ASK FOR SMARTPORT STATUS
                JSR SP_STATUS
                
 ;               BCC GOT_DEVICE_COUNT                    ; GOT AN ERROR
 ;               PRINT_STR SP_NO_DCOUNT_STR_ADDR
 ;               SEC
 ;               BCS ERROR_OUT2

GOT_DEVICE_COUNT:
                LDX DCOUNT                              ; THE NUMBER OF DEVICES
                INX
                STX NUM_DEVICES

                LDX #$01                                ; START AT DEVICE #1

NEXT_DEV2: 
                TXA
                PHA 

.IF .NOT STRIP_TRACE
.IF EXT2_TRACE
                JSR PRTX
                PLA
                PHA
                TAX
.ENDIF
.ENDIF

                LDY #SP_STATUS_DIB                      ; X IS DEVICE 
                JSR SP_STATUS                           ; GET INFO
                BCS ERROR_OUT                           ; QUIT IF WE GET AN ERROR
                
                LDA SP_PAYLOAD+4                        ; LENGTH OF STRING
                CMP FIND_DEVICE_BUF_LEN                 ; IS IT THE SAME SIZE AS THE STRING WE'RE LOOKING FOR?
                BNE NEXT_DEVICE                         ; NOPE, CHECK NEXT DEVICE

                ; SAME SIZE STRING, NOW CHECK AND SEE IF IT
                ; IS THE DEVICE WE'RE LOOKING FOR

.IF .NOT STRIP_TRACE
.IF EXT2_TRACE
                LDA #'>'
                JSR COUT
                JSR DUMP_SP_PAYLOAD
.ENDIF
.ENDIF

                LDX #$00        
SCAN_CHAR:

                LDA SP_PAYLOAD+5,X                      ; INFO STRING
                CMP FIND_DEVICE_BUF,X                   ; DEVICE WE'RE LOOKING FOR
                BNE NEXT_DEVICE                         ; NOT THE SAME, CHECK NEXT DEVICE

                INX                                     ; MOVE TO NEXT DEVICE
                CPX SP_PAYLOAD+4                        ; HAVE WE FINISHED LOOKING AT THE SAME NUMBER OF CHARACTERS?
                BNE SCAN_CHAR                           ; NOPE, KEEP GOING                           

                CLC
                BCC FOUND_DEVICE                        ; WE FOUND OUR DEVICE
NEXT_DEVICE:
                PLA                                     ; REMOVE THE DEVICE NUMBER OFF STACK
                TAX                                     
                INX                                     ; AND INCREMENT IT
                CPX NUM_DEVICES                         ; HAVE WE CHECKED ALL DEVICES?
                BNE NEXT_DEV2                           ; NOPE, KEEP GOING

                ; EXHAUSTED OUR LIST

                LDX #SP_ERR                                ; NOT FOUND
                LDA #SP_ERROR_NOT_FOUND
                CLC
                BCC FOUND_DONE

ERROR_OUT:      
                PLA
ERROR_OUT2:
                ; ERROR STRING HERE

                LDX #SP_ERR                               ; ERROR
                RTS

FOUND_DEVICE:
                PLA
                TAX

FOUND_DONE:    
                RTS




