FN_STATUS_FLAG_CONNECTED        = %00000010  
FN_STATUS_FLAG_NOT_CONNECTED    = %11111101

.IF .NOT USE_SP

NUMBER_OF_FAKE_UNITS = 11

;*******************************
; FIND_SMARTPORT_SLOT
; INPUT:
;   NONE
;***
; RETURN
;   A = $FF - NO SMARTPORT FOUND
;   A = $CX - WHERE X IS THE SLOT
;**********************************
.IF USE_SP

FIND_SMARTPORT_SLOT:

.IF .NOT STRIP_TRACE
                SAVE_REGS
                LDA TRACE_FLAG
                BEQ NO_TRACE29

                PRINT_STR FAKE_SMARTPORT_STR_ADDR

                PRINT_STR FIND_SMARTPORT_SLOT_STR_ADDR

NO_TRACE29:
                RESTORE_REGS
.ENDIF

                LDA #$C5                ; FAKE SMARTPORT FOR TESTING $C500
                LDA SLOT_ADDR_HI
                RTS                     ; WE FOUND IT! A = SLOT ADDRESS

.ENDIF
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
                ; FAKE SMARTPORT DISPATCHER

                LDX FAKE_DISPATCHER_ADDR
                STX DISPATCHER_ADDR_LO
                LDA FAKE_DISPATCHER_ADDR+1
                STA DISPATCHER_ADDR_HI
            
                RTS

; THIS IS JUST FOR TESTING WITH AN EMULATOR




;******************************************************************
; FAKE_DISPATCHER
;   Simulates dispatcher calls so we can test in an emulator
; This routine saves part of the contents of ZP to absolute memory
; and then restores them.
;
; ZP1 = Address from stack
; ZP2 = CMD_LIST
; ZP3 = STORAGE
; ZP4 = address of string to copy
;******************************************************************
;*** fake ***
; 0 - SMARTPORT
; 1 - FUJI_DISK_0
; 2 - NETWORK
; 3 - NETWORK_1
; 4 - NETWORK_2

ADDRESS_ON_STACK        = ZP1
ADDRESS_ON_STACK_LO     = ZP1_LO
ADDRESS_ON_STACK_HI     = ZP1_HI

ZCMD_LIST               = ZP2
ZCMD_LIST_LO            = ZP2_LO
ZCMD_LIST_HI            = ZP2_HI

ZPAYLOAD                = ZP3
ZPAYLOAD_LO             = ZP3_LO
ZPAYLOAD_HI             = ZP3_HI

SRC_STR                 = ZP4
SRC_STR_LO              = ZP4_LO
SRC_STR_HI              = ZP4_HI

UNIT_FN_CLOCK = 9

FAKE_DISPATCHER:
                LDX #$00
SAVE_ZP:
                LDA ZP1,X
                STA SAVED_ZERO_PAGE,X
                INX
                CPX #ZP_BLOCK_SIZE
                BNE SAVE_ZP

                ; ADDRESS OF THE NEXT
                ; INSTRUCTION MINUS 1
                ; THIS WILL BE THE (ADDRESS
                ; OF THE PARAMETERS) - 1

                PLA
                STA ADDRESS_ON_STACK_LO
                PLA
                STA ADDRESS_ON_STACK_HI         ; NWD CONFIRMED CORRECT

;                JSR CALL_DISPATCHER
;
;Y+1:            .BYTE SP_CMD_STATUS            ; STATUS CALL COMMAND NUMBER
;y+2:            .WORD CMD_LIST
;Y+4:            NEXT INSTRUCTION

; let's play, fake the call!

                JSR WIPE_PAYLOAD                ; CLEAR OUR PAYLOAD

                LDY #$01
                LDA (ADDRESS_ON_STACK),Y
                STA REQUESTED_CMD               ; SMARTPORT COMMAND

                LDY #$02                        ; GET CMD_LIST ADDRESS
                LDA (ADDRESS_ON_STACK),Y        
                STA ZCMD_LIST_LO                ; POINTER TO CMDLIST (STORED_AFTER_CALL)
                INY ; #$03
                LDA (ADDRESS_ON_STACK),Y
                STA ZCMD_LIST_HI                ; NWD CONFIRMED CORRECT

                ; COMMON TO ALL CALLS
                ; SMARTPORT CONTROLLER CMDLIST
                ; 0   parameter list length
                ; 1   unit number
                ; 2-3 storage
                
                LDY #$01                        ; CMD_LIST
                LDA (ZCMD_LIST),Y               ; UNIT #
                STA REQUESTED_UNIT              ; NWD CONFIRMED CORRECT

                LDY #$02
                LDA (ZCMD_LIST),Y               ; where to store
                STA ZPAYLOAD_LO
                INY ; #$03
                LDA (ZCMD_LIST),Y               ; NWD CONFIRMED CORRECT
                STA ZPAYLOAD_HI                 ; WHERE TO STORE RESULT

.IF EXT3_TRACE
    LDA REQUESTED_UNIT
    LDX REQUESTED_CMD
    JSR PRTAX
    JSR CROUT
.ENDIF

                LDA REQUESTED_CMD
                CMP #SP_CMD_STATUS
                BNE CHECK_READ_CMD_

                ; ***********************
                ; SP_CMD_STATUS
                ; ***********************

                LDA REQUESTED_UNIT
                CMP #$00            ; SMARTPORT_CONTROLLER
                BNE NON_SMARTPORT_CTRLR

                ; SMARTPORT CONTROLLER CMDLIST
                ; 0   parameter list length
                ; 1   unit number
                ; 2-3  status list pointer (lsb-msb)
                ; 4   status code

                LDY #4
                LDA (ZCMD_LIST),Y
                CMP #SP_STATUS_CODE
                BNE COMPLETE_CMD_            

                LDY #$00
                LDA #NUMBER_OF_FAKE_UNITS
                STA (ZPAYLOAD),Y
                CLC
                BCC COMPLETE_CMD_


NON_SMARTPORT_CTRLR:
;               LDA REQUESTED_UNIT
                CMP #5
                BPL NETWORK_DEV0

;---------------------------------------------------------------------------------
FUJI_DISK1:                                     ; UNIT 1 - 4 FUJINET DISK 0-3
                SEC
                SBC #$01                        ; SUBSTRACT 1 FROM UNIT NUMBER
                CLC
                ADC #'0'                        ; CONVERT TO ASCII

                LDX DISK_STR_WITH_NUMBER_INDEX
                STA FUJI_DISK_0_STR,X

                LDA FUJI_DISK_0_STR_ADDR
                LDY FUJI_DISK_0_STR_ADDR+1
                LDX FUJI_DISK_0_STR_LEN
                CLC
                BCC COPY_2_PAYLOAD_3

COMPLETE_CMD_:
                BCC COMPLETE_CMD_4

NETWORK_DEV0:                                   ; UNIT 2 - NETWORK 
;               LDA REQUESTED_UNIT
                CMP #$05
                BNE NETWORK_1_AND_UP
;---------------------------------------------------------------------------------

                LDA NETWORK_STR_ADDR
                LDY NETWORK_STR_ADDR+1
                LDX NETWORK_STR_LEN

                CLC
                BCC COPY_2_PAYLOAD_3

NETWORK_1_AND_UP:
;               LDA REQUESTED_UNIT 5,6,7
                CMP #UNIT_FN_CLOCK
                BPL FN_CLOCK_

;---------------------------------------------------------------------------------
                SEC 
                SBC #$05    ; SUBTRACT 6 FROM THE UNIT REQUESTED
                CLC
                ADC #'0'    ; CONVERT TO ASCII

                LDX NETWORK_STR_WITH_NUMBER_INDEX
                STA NETWORK_STR_WITH_NUMBER,X

                LDA NETWORK_STR_WITH_NUMBER_ADDR
                LDY NETWORK_STR_WITH_NUMBER_ADDR+1
                LDX NETWORK_STR_WITH_NUMBER_LEN
                CLC
COPY_2_PAYLOAD_3:
                BCC COPY_2_PAYLOAD_2
CHECK_READ_CMD_:
                BCC CHECK_READ_CMD
FN_CLOCK_:
                CMP #UNIT_FN_CLOCK
                BNE FN_CPM

;---------------------------------------------------------------------------------
                LDY #4
                LDA (ZCMD_LIST),Y
                CMP #'T'
                BNE CLOCK_NAME
REQUEST_TIME:
                LDY #$00                ; SET THE CLOCK TO 1/2/3 4:5.6
SET_CLOCK:
                TYA
                STA (ZPAYLOAD),Y 
                INY 
                CPY #7
                BNE SET_CLOCK
                CLC
                BCC COMPLETE_CMD_
CLOCK_NAME:
                LDA CLOCK_STR_ADDR
                LDY CLOCK_STR_ADDR+1
                LDX CLOCK_STR_LEN
                CLC
                BCC COPY_2_PAYLOAD_2
COMPLETE_CMD_4:
                BCC COMPLETE_CMD_3
FN_CPM:
                CMP #$0A
                BNE FN_PRINTER

;---------------------------------------------------------------------------------
                LDA CPM_STR_ADDR
                LDY CPM_STR_ADDR+1
                LDX CPM_STR_LEN
                CLC
                BCC COPY_2_PAYLOAD_2

FN_PRINTER:
                CMP #$0B
                BNE COMPLETE_CMD_3

;---------------------------------------------------------------------------------
                LDA PRINTER_STR_ADDR
                LDY PRINTER_STR_ADDR+1
                LDX PRINTER_STR_LEN
                CLC
                BCC COPY_2_PAYLOAD_2


CHECK_READ_CMD:
                LDA REQUESTED_CMD
                CMP #SP_CMD_READ
                BNE CHECK_WRITE_CMD

;---------------------------------------------------------------------------------

                ; ***********************
                ; SP_CMD_READ
                ; ***********************
                ;Byte  Definition
                ;0      parameter list length ($04)
                ;1      unit number
                ;2-3    input buffer pointer (lsb-msb)
                ;4-5    byte count
                ;6-7    address pointer

                LDY #4
                LDA (ZCMD_LIST),Y
                STA REQUESTED_BYTES
                INY
                LDA (ZCMD_LIST),y
                STA REQUESTED_BYTES+1

                LDA TEST_BLOCK_STR_ADDR
                LDY TEST_BLOCK_STR_ADDR+1
                LDX REQUESTED_BYTES         ; Yeah, I'm cheating, only the low byte

COPY_2_PAYLOAD_2:
                CLC
                BCC COPY_2_PAYLOAD

                CLC
 COMPLETE_CMD_3:
                BCC COMPLETE_CMD_2


CHECK_WRITE_CMD:
;               LDA REQUESTED_CMD
                CMP #SP_CMD_WRITE
                BNE CHECK_CONTROL

;---------------------------------------------------------------------------------
                ; ***********************
                ; SP_CMD_WRITE
                ; ***********************                
                ;Byte  Definition
                ;0      parameter list length 
                ;1      unit number
                ;2-3    data buffer pointer
                ;4-5    byte count
                ;6-7    address pointer

.IF EXT3_TRACE
                JSR DUMP_SP_PAYLOAD
.ENDIF

                CLC
                BCC COMPLETE_CMD_2

CHECK_CONTROL:
;               LDA REQUESTED_CMD
                CMP #SP_CMD_CONTROL               
                BNE COMPLETE_CMD_2

                ; ***********************
                ; SP_CMD_CONTROL
                ; ***********************   
                LDY #4
                LDA (ZCMD_LIST),Y
                STA CONTROL_CMD

                CMP #'O'
                BNE CTRL_CLOSE 

                ; ***********************
                ; 'O'
                ; ***********************  
                INC OPEN_COUNT
                LDA #255
                STA BYTES_WAITING
                LDA STATUS_FLAG
                ORA #FN_STATUS_FLAG_CONNECTED
                STA STATUS_FLAG

CTRL_CLOSE:
                CMP #'C'
                BNE CTRL_R

                LDA OPEN_COUNT
                BEQ NO_OPENED_FILES
                DEC OPEN_COUNT

NO_OPENED_FILES:
                LDA OPEN_COUNT
                BNE NO_OPENED_FILES2

                LDA STATUS_FLAG         ; CLEAR CONNECTED FLAG
                AND #FN_STATUS_FLAG_NOT_CONNECTED
                STA STATUS_FLAG

NO_OPENED_FILES2:
                ; TODO: SAVE FLAGS
COMPLETE_CMD_2:
                CLC
                BCC COMPLETE_CMD


CTRL_R:
                CMP #'R'
                BNE CTRL_W

                CLC
                BCC COMPLETE_CMD
                
CTRL_W:
                CMP #'W'
                BNE CTRL_A 

                CLC
                BCC COMPLETE_CMD
                
CTRL_A:
                CMP #'A'
                BNE CTRL_CLOSE_CONNECTION 

                CLC
                BCC COMPLETE_CMD

CTRL_CLOSE_CONNECTION:
                CMP #'c'
                BNE CTRL_D 
                
                CLC
                BCC COMPLETE_CMD
                

CTRL_D:
                CMP #'D'
                BNE COMPLETE_CMD

                CLC
                BCC COMPLETE_CMD
                
                
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

COPY_2_PAYLOAD:

                ; SP_PAYLOAD+4 LENGTH
                ; SP_PAYLOAD+5 STRING

                STA SRC_STR_LO                      ; GET THE STRING FROM
                STY SRC_STR_HI

                TXA
                LDY #4                          ; PAYLOAD+4
                STA (ZPAYLOAD),Y                     ; STORE THE LENGTH
                
                TXA                             ; LENGTH OF STRING
                TAY
                STY GET_INDEX

                INY
                INY
                INY
                INY
                INY
                
                STY STORE_INDEX
                INX
CPY2PAYLOAD:
                LDY GET_INDEX
                LDA (SRC_STR),Y                     ; GET THE STRING
                LDY STORE_INDEX
                STA (ZPAYLOAD),Y                     ; STORE THE STRING

                DEC STORE_INDEX
                DEC GET_INDEX
                DEX
                BNE CPY2PAYLOAD            

COMPLETE_CMD: 
                LDX #255                        ; buf buffer, but we don't care
                STX SP_COUNT
                LDY #$00
                STY SP_COUNT+1
              
                ; INCREASE ADDRESS BY NUMBER OF PARAMETERS

                LDY #$02
                LDA (ADDRESS_ON_STACK),Y
                STA ZCMD_LIST_LO                      ; CMD_LIST
                INY
                LDA (ADDRESS_ON_STACK),Y
                STA ZCMD_LIST_HI

                LDY #$00
                LDA (ZCMD_LIST),Y           ; NUMBER OF PARAMETERS
                TAY                         ; ADD ONE
                INY
                TYA
                CLC                         ; ADD THE NUMBER OF PARAMETERS + 1TO THE 
                ADC ADDRESS_ON_STACK_LO     ; ADDRESS THAT WAS ON THE STACK
                STA ADDRESS_ON_STACK_LO     ; WHEN WE CAME HERE.
                LDA ADDRESS_ON_STACK_HI     ; THAT GIVES US THE ADDRESS WE ARE
                ADC #$00                    ; TO CONTINUE FROM
                STA ADDRESS_ON_STACK_HI

                LDA ADDRESS_ON_STACK_LO
                STA CONTINUE_ADDRESS        ; CONTINUE ADDRESS IS NOW POINTING
                LDA ADDRESS_ON_STACK_HI     ; TO THE ADDRESS FOLLOWING THE PARAMETERS
                STA CONTINUE_ADDRESS+1

                LDY #$00                    ; RESTORE THE ZERO PAGE DATA
RESTORE_ZP:
                LDA SAVED_ZERO_PAGE,Y
                STA ZP1,Y
                
                INY
                CPY #ZP_BLOCK_SIZE
                BNE RESTORE_ZP

                LDA #SP_ERROR_OK
                CLC                         ; NO ERROR

                ; CONTINUE EXECUTION AFTER PARAMETERS

                .BYTE $4C                   ; JMP
CONTINUE_ADDRESS:
                .WORD $0000                

                

.ENDIF 