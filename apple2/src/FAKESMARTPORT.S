FN_STATUS_FLAG_CONNECTED        = %00000010  
FN_STATUS_FLAG_NOT_CONNECTED    = %11111101

.IF .NOT USE_SP

NUMBER_OF_FAKE_UNITS = 4

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
; NOTE: Destroys ZP1
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




REGS_TO_SAVE            = 7

FAKE_DISPATCHER:
                LDX #$00
SAVE_ZP:
                LDA ZP2,X
                STA SAVE_ZERO_PAGE,X
                INX
                CPX #REGS_TO_SAVE
                BNE SAVE_ZP

                ; ADDRESS WE CALLED FROM IS ON STACK
                PLA
                STA ZP1_LO
                PLA
                STA ZP1_HI

;                JSR CALL_DISPATCHER
;
;Y+1:            .BYTE SP_CMD_STATUS             ; STATUS CALL COMMAND NUMBER
;y+2:            .WORD CMD_LIST
;Y+4:            NEXT INSTRUCTION

; let's play, fake the call!

                JSR WIPE_PAYLOAD

                LDA #$01
                LDA (ZP2),y
                STA REQUESTED_CMD         ; SMARTPORT COMMAND

                LDY #$02        ; GET CMD_LIST ADDRESS
                LDA (ZP1),Y
                STA ZP2_LO      ; POINTER TO CMDLIST (STORED_AFTER_CALL)
                INY
                LDA (ZP1),y
                STA ZP2_HI

                ; COMMON TO ALL CALLS
                ; SMARTPORT CONTROLLER CMDLIST
                ; 0   parameter list length
                ; 1   unit number
                ; 2-3 storage
                
                LDY #$01            ; CMD_LIST
                LDA (ZP2),Y         ; UNIT #
                STA REQUESTED_UNIT

                LDY #2
                LDA (ZP2),Y
                STA ZP3_LO
                INY
                LDA (ZP2),Y 
                STA ZP3_HI          ; WHERE TO STORE RESULT

                LDA REQUESTED_CMD
                CMP #SP_CMD_STATUS
                BNE CHECK_READ_CMD

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
                LDA (ZP2),Y
                CMP #SP_STATUS_CODE
                BNE COMPLETE_CMD_            ; DON'T KNOW WHAT TO DO...

                LDY #$00
                LDA #NUMBER_OF_FAKE_UNITS
                STA (ZP3),Y
                CLC
                BCC COMPLETE_CMD_

NON_SMARTPORT_CTRLR:
;               LDA REQUESTED_UNIT
                CMP #1
                BNE NETWORK_DEV0
FUJI_DISK1:                                     ; UNIT 1 - FUJINET DISK 0
                LDA FUJI_DISK_0_STR_ADDR
                LDY FUJI_DISK_0_STR_ADDR+1
                LDX FUJI_DISK_0_STR_LEN
                CLC
                BCC COPY_2_PAYLOAD_2

NETWORK_DEV0:                                   ; UNIT 2 - NETWORK 
;               LDA REQUESTED_UNIT
                CMP #$02
                BNE NETWORK_1_AND_UP

                LDA NETWORK_STR_ADDR
                LDY NETWORK_STR_ADDR+1
                LDX NETWORK_STR_LEN

                CLC
                BCC COPY_2_PAYLOAD_2

NETWORK_1_AND_UP:
;               LDA REQUESTED_UNIT
                CMP #$05
                BPL COMPLETE_CMD_

                TAX
                DEX                             ; UNIT 3/4 = NETWORK_1/2
                DEX
                TXA
                CLC
                ADC #'0'
                LDX NETWORK_STR_WITH_NUMBER_INDEX
                STA NETWORK_STR_WITH_NUMBER,X

                LDA NETWORK_STR_WITH_NUMBER_ADDR
                LDY NETWORK_STR_WITH_NUMBER_ADDR+1
                LDX NETWORK_STR_WITH_NUMBER_LEN
                CLC
                BCC COPY_2_PAYLOAD

CHECK_READ_CMD:
;               LDA REQUESTED_CMD
                CMP #SP_CMD_READ
                BNE CHECK_WRITE_CMD

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
                LDA (ZP2),Y
                STA REQUESTED_BYTES
                INY
                LDA (ZP2),y
                STA REQUESTED_BYTES+1

                LDA TEST_BLOCK_STR_ADDR
                LDY TEST_BLOCK_STR_ADDR+1
                LDX REQUESTED_BYTES         ; Yeah, I'm cheating, only the low byte

                CLC
                BCC COPY_2_PAYLOAD

COPY_2_PAYLOAD_2:
                BCC COPY_2_PAYLOAD

COMPLETE_CMD_:
                BCC COMPLETE_CMD_2

CHECK_WRITE_CMD:
;               LDA REQUESTED_CMD
                CMP #SP_CMD_WRITE
                BNE CHECK_CONTROL

                ; ***********************
                ; SP_CMD_WRITE
                ; ***********************                
                ;Byte  Definition
                ;0      parameter list length 
                ;1      unit number
                ;2-3    data buffer pointer
                ;4-5    byte count
                ;6-7    address pointer
                CLC
                BCC COMPLETE_CMD

CHECK_CONTROL:
;               LDA REQUESTED_CMD
                CMP #SP_CMD_CONTROL               
                BNE COMPLETE_CMD

                ; ***********************
                ; SP_CMD_CONTROL
                ; ***********************   
                LDY #4
                LDA (ZP2),Y
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
                CLC
                BCC COMPLETE_CMD_2


CTRL_R:
                CMP #'R'
                BNE CTRL_W

CTRL_W:
                CMP #'W'
                BNE CTRL_A 
CTRL_A:
                CMP #'A'
                BNE CTRL_CLOSE_CONNECTION 
CTRL_CLOSE_CONNECTION:
                CMP #'c'
                BNE CTRL_D 
CTRL_D:
                CMP #'D'
                BNE COMPLETE_CMD
                
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
COMPLETE_CMD_2:
                CLC
                BCC COMPLETE_CMD
COPY_2_PAYLOAD:

                ; SP_PAYLOAD+4 LENGTH
                ; SP_PAYLOAD+5 STRING

                STA ZP4_LO                      ; GET THE STRING FROM
                STY ZP4_HI

                INX                             ; ADD NULL
                TXA
                LDY #4                          ; PAYLOAD+4
                STA (ZP3),Y                     ; STORE THE LENGTH
                
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
                LDA (ZP4),Y                     ; GET THE STRING
                LDY STORE_INDEX
                STA (ZP3),Y                     ; STORE THE STRING

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
                LDA (ZP1),Y
                STA ZP2_LO                      ; CMD_LIST
                INY
                LDA (ZP1),y
                STA ZP2_HI

                ; ZP2 NOW POINTS TO THE COMMAND LIST
                ; FIRST ITEM THERE IS THE PCOUNT

                LDY #$00
                LDA (ZP2),Y
                TAY ; ADD ONE
                INY
                TYA
                CLC
                ADC ZP1_LO
                STA ZP1_LO
                LDA ZP1_HI
                ADC #$00
                STA ZP1_HI

                ; ZP1 SHOULD NOT BE POINTING AT THE
                ; INSTRUCTIONS FOLLOWING THE PARAMETERS

                LDX #$00
RESTORE_ZP:
                LDA SAVE_ZERO_PAGE,X
                STA ZP2,X
                
                INX
                CPX #REGS_TO_SAVE
                BNE RESTORE_ZP


                LDA #SP_ERROR_OK
                CLC                             ; NO ERROR

                ; CONTINUE EXECUTION AFTER PARAMETERS
                JMP (ZP1)
                

.ENDIF 