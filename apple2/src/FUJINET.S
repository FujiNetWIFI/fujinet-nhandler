;*****************************************************
; FUJINET.S
; BASIC to Fujinet
; By Norman Davie

    .include "MACROS.S"
    .include "REGS.S"

FN_OK                   = 0
FN_ERR                  = $FE
FN_NO_NETWORK           = $FD

FN_ERR_WRITE_ONLY       = 131	    ;$83 Protocol is in Write-only mode
FN_ERR_INVALID_COMMAND  = 132	    ;$84 Protocol was sent an invalid command
FN_ERR_MISSING_PROTO    = 133	    ;$85 No protocol attached.
FN_ERR_READ_ONLY        = 135	    ;$86 Protocol is in read-only mode
FN_ERR_TIMED_OUT        = 138	    ;$8A Timed out
FN_ERR_CRITICAL         = 144	    ;$90 A critical error occurred. SIO reports this, get the actual Error code from byte 4 of STATUS.
FN_ERR_CMD_NOT_IMPLEMENTED = 146	;$92 Command not implemented
FN_ERR_FILE_EXISTS      = 151	    ;$97 File Exists
FN_ERR_NO_SPACE         = 162	    ;$A2 No space on device
FN_ERR_INVALID_URL      = 165	    ;$A5 Invalid Devicespec
FN_ERR_ACCESS_DENIED    = 167	    ;$A7 Access Denied
FN_ERR_FILE_NOT_FOUND   = 170	    ;$AA File not found (emitted by filesystem adaptors)
FN_ERR_REFUSED          = 200	    ;$C8 Connection Refused (equivalent to errno ECONNREFUSED)
FN_ERR_UNREACHABLE      = 201	    ;$C9 Network Unreachable (equivalent to errno ENETUNREACH)
FN_ERR_CONNECTION_TIMEOUT   = 202	;$CA Connection Timeout (equivalent to errno ETIMEDOUT)
FN_ERR_NETWORK_DOWN     = 203	    ;$CB Network is down (equivalent to errno ENETDOWN)
FN_ERR_CONNECTION_RESET = 204	    ;$CC Connection was reset during read/write (equivalent to errno ECONNRESET)
FN_ERR_CIP              = 205	    ;$CD Connection in progress (EAGAIN)
FN_ERR_ADDRESS_IN_USE   = 206	    ;$CE Address in use (EADDRINUSE)
FN_ERR_NOT_CONNECTED    = 207	    ;$CF Not Connected
FN_ERR_SERVER_NOT_RUNNING = 208	    ;$D0 Server not Running
FN_ERR_NO_CONNECTION_WAITING = 209	;$D1 No connection waiting
FN_ERR_SERVICE_NOT_AVAILABLE = 210	;$D2 Service Not Available
FN_ERR_CONNECTION_ABORTED = 211	    ;$D3 Connection Aborted
FN_ERR_BAD_CREDENTIALS  = 212	    ;$D4 Invalid Username or Password (debating whether to overload as access denied.)
FN_ERR_MEMORY_ERROR     = 255	    ;$FF Could not allocate either receive or transmit buffers.

FN_LAST_ERR:            .BYTE $00

;******************************************************************;
; CPY_STR_TO_SP_PAYLOAD
; Copy the length proceeded string to the Smartport buffer
;
; INPUT
;  A = high address
;  Y = low address
;  X = length
; RETURNS
;  X = String length
;******************************************************************
CPY_STR_TO_SP_PAYLOAD:
                STA ZP1_LO
                STY ZP1_HI
                STX ZP2


                LDY #$00
CONT3:
                LDA (ZP1),Y
                STA SP_PAYLOAD+5,Y 
                INY
                CPY ZP2
                BNE CONT3

GOT_LENGTH2:
                
                STY SP_PAYLOAD+4        ; STORE LENGTH
                LDX SP_PAYLOAD+4
                RTS

;******************************************************************
; CPY_URL_TO_SP_PAYLOAD
; Copy the BASIC URL into the Smartport buffer as a zero
; terminated string
;
; INPUT
;  A = high address
;  Y = low address
; RETURNS
;
;******************************************************************
CPY_URL_TO_SP_PAYLOAD:


                LDX URL_LEN
                LDA #$00
                STA SP_PAYLOAD+4,X  ; NULL TERMINATE STRING

                LDA URL_ADDR        ; STRING WITHOUT LENGTH
                LDY URL_ADDR+1

                STX ZP2
                STA ZP1_LO
                STY ZP1_HI
                
                LDX #$00
                LDY #$00
KEEP_CALM_AND_CARRY_ON:
                LDA (ZP1),Y
                STA SP_PAYLOAD+4,X
                CPX ZP2
                BEQ CPY_DONE
                INY
                INX
                CLC
                BCC KEEP_CALM_AND_CARRY_ON

CPY_DONE:                   

                RTS

;******************************************************************
; CPY_BUF_TO_SP_PAYLOAD
; Copy the BASIC URL into the Smartport buffer as a zero
; terminated string
;
; INPUT
;  A = high address
;  Y = low address
; RETURNS
;
;******************************************************************
CPY_BUF_TO_CTRL_SP_PAYLOAD:
                
                STX ZP2
                STA ZP1_LO
                STY ZP1_HI
                
                LDX #$00
                LDY #$00
KEEP_CALM:
                LDA (ZP1),Y
                STA SP_PAYLOAD+2,X
                CPX ZP2
                BEQ CPY_DONE2
                INY
                INX
                CLC
                BCC KEEP_CALM

CPY_DONE2:
                RTS

CPY_BUF_TO_WRITE_SP_PAYLOAD:
                
                STX ZP2
                STA ZP1_LO
                STY ZP1_HI
                
                LDX #$00
                LDY #$00
KEEP_CALM3:
                LDA (ZP1),Y
                STA SP_PAYLOAD,X
                CPX ZP2
                BEQ CPY_DONE3
                INY
                INX
                CLC
                BCC KEEP_CALM3

CPY_DONE3:
                RTS
;******************************************************************
; FN_OPEN
; Open the specified UNIT, gets it ready for reading or writing
; 
; INPUT
; X = UNIT DESTINATION
;******************************************************************
FN_OPEN:

.IF .NOT STRIP_TRACE
                SAVE_REGS
                TXA
                PHA
                LDA TRACE_FLAG
                BEQ NO_TRACE20
                PRINT_STR FN_OPEN_STR_ADDR
                PLA
                PHA
                TAX
                JSR PRTX
                LDA #SPACE
                JSR COUT

NO_TRACE20:     
                PLA           
                RESTORE_REGS
.ENDIF

                TXA                         ; X CONTAINS THE UNIT NUMBER
                PHA

                ; STAGE #1
                ; OPEN THE DEVICE #X
                JSR SP_OPEN 
                STA FN_LAST_ERR
                BCC CONT2
OPEN_ERR:

.IF .NOT STRIP_TRACE
.IF .NOT EXT_TRACE
                LDA #<OPEN_ERR_STR
                LDY #>OPEN_ERR_STR

                JSR STROUT
                LDX FN_LAST_ERR
                JSR PRTX
                JSR CROUT
.ENDIF
.ENDIF
                PLA
                SEC
                LDX #FN_ERR
                LDA FN_LAST_ERR
                RTS

CONT2:
                PLA                         ; GET BACK UNIT NUMBER
                PHA
                TAX

; FUJINET SPECIFC
;Byte   Definition
; 'O'-open
;0-1    payload size
;2      mode read or write or both
;3      translation
;4...   url
                ; STAGE #2
                ; SET PAYLOAD SIZE
                LDY #$04                    ; PAYLOAD SIZE = 3 + NULL ON STRING
                STY SP_PAYLOAD
                LDY #$00
                STY SP_PAYLOAD+1

                LDA URL_LEN                 ; PAYLOAD += URL_LEN
                CLC
                ADC SP_PAYLOAD
                STA SP_PAYLOAD
                LDA SP_PAYLOAD+1
                ADC #$00                    
                STA SP_PAYLOAD+1
       
                ; FILL PAYLOAD - Read/write mode
                LDA MODE                    ; READ OR WRITE OR BOTH
                STA SP_PAYLOAD+2
                
                ; FILL PAYLOAD - Character translation
                LDA TRANSLATION             ; CHARACTER TRANSLATION
                STA SP_PAYLOAD+3

                ; FILL PAYLOAD - Transfer BASIC URL to payload
                JSR CPY_URL_TO_SP_PAYLOAD   ; TRANSFER THE URL

.IF .NOT STRIP_TRACE
.IF EXT_TRACE
                SAVE_REGS
                LDA TRACE_FLAG
                BEQ NO_TRACE21

                PRINT_STR MODE_STR_ADDR
                LDX MODE
                JSR PRINT_X

                PRINT_STR TRANS_STR_ADDR
                LDX TRANSLATION
                JSR PRINT_X
                
                PRINT_STR PAYLOAD_STR_ADDR
                ;JSR DUMP_SP_PAYLOAD        ; PRINT THE URL
                JSR CROUT
NO_TRACE21:              
                RESTORE_REGS
.ENDIF
.ENDIF

                PLA                         ; GET BACK OUR DEVICE NUMBER
                TAX

                ; STAGE #3
                ; CALL FUJINET OPEN
                LDY #'O'                    ; SEND 'O' TO FUJINET
                JSR SP_CONTROL
                STA FN_LAST_ERR
                BCC OPEN_OK2
CTRL_ERR:

.IF .NOT STRIP_TRACE
                LDA #<CTRL_ERR_STR
                LDY #>CTRL_ERR_STR
                JSR STROUT
                LDX FN_LAST_ERR
                JSR PRTX
                JSR CROUT
.ENDIF
                SEC
                LDX #FN_ERR
                LDA FN_LAST_ERR
                RTS

OPEN_OK2:
                LDX #FN_OK
                RTS


;
; 'C'-close
;0-1    payload size $00
;
;'R'
;0-1   payload size (bytes to return)
;2..   data
;
;'W'
; 0-1  payload size (bytes to write)
; 2..  data
;
;'A'
; accept connection
;
; 'c'
; close client connection
;
;'D'
; set UDP destination


SMARTPORT_READ  = 1
SMARTPORT_WRITE = 1
.IF SMARTPORT_READ
;******************************************************************
; FN_READ - SMARTPORT VERSION
; Read the specified UNIT
;
; INPUT
; X = UNIT DESTINATION
; BUFLEN = NUMBER OF BYTES TO READ
;******************************************************************
FN_READ:

.IF .NOT STRIP_TRACE
                SAVE_REGS
                TXA
                PHA
                LDA TRACE_FLAG
                BEQ NO_TRACE22

                PRINT_STR FN_READ_STR_ADDR
                PRINT_STR UNIT_STR_ADDR
                PLA
                PHA
                TAX
                JSR PRTX
                JSR CROUT
NO_TRACE22:     
                PLA          
                RESTORE_REGS

.ENDIF
                ; X = DEVICE
                LDY BUFLEN              ; MAX PAYLOAD IS 255         
                JSR SP_READ
                STA FN_LAST_ERR
                BCC READ_OK


READ_ERR:

.IF .NOT STRIP_TRACE  
.IF EXT2_TRACE              
                PRINT_STR FN_READ_ERROR_STR_ADDR
                JSR DUMP_SP_PAYLOAD
.ENDIF
.ENDIF

                LDX #FN_ERR
                LDA FN_LAST_ERR
                CLC
                BCC READ_DONE
READ_OK:
   
                LDX #FN_OK
READ_DONE:
                LDY SP_COUNT
                LDA LAST_SP_ERR
                RTS
.ELSE

;******************************************************************
; FN_READ - **** CONTROL VERSION ****
; Read the specified UNIT
;
; INPUT
; X = UNIT DESTINATION
; BUFLEN = NUMBER OF BYTES TO READ
;******************************************************************

FN_READ:

.IF .NOT STRIP_TRACE
                SAVE_REGS
                TXA
                PHA
                LDA TRACE_FLAG
                BEQ NO_TRACE22

                PRINT_STR FN_READ_STR_ADDR
                PLA
                PHA
                TAX
                JSR PRTX
                JSR CROUT
NO_TRACE22:     
                PLA          
                RESTORE_REGS

.ENDIF

;'R'
;0-1   payload size (bytes to return)
;2..   data
;
                ; SET PAYLOAD SIZE

                LDY BUFLEN              ; PAYLOAD SIZE
                STY SP_PAYLOAD
                LDA #$00
                STA SP_PAYLOAD+1

                LDY #'R'
                JSR SP_CONTROL
                STA FN_LAST_ERR
                BCC READ_OK

READ_ERR:

.IF .NOT STRIP_TRACE
.IF EXT2_TRACE                
                PRINT_STR FN_READ_ERROR_STR_ADDR
                JSR DUMP_SP_PAYLOAD
.ENDIF
.ENDIF

                LDX #FN_ERR
                LDA FN_LAST_ERR
                CLC
                BCC READ_DONE
READ_OK:

.IF .NOT STRIP_TRACE
                JSR DUMP_SP_PAYLOAD_HEX   
.ENDIF
                LDX #FN_OK
READ_DONE:
                LDY SP_COUNT
                LDA LAST_SP_ERR
                RTS
.ENDIF


.IF SMARTPORT_WRITE
;******************************************************************
; FN_WRITE - SMARTPORT VERSION
; Read the specified UNIT
;
; INPUT
; X = UNIT DESTINATION
; BUF    = THE CONTENT TO SEND
; BUFLEN = NUMBER OF BYTES TO WRITE
;******************************************************************
FN_WRITE:

.IF .NOT STRIP_TRACE
                SAVE_REGS
                TXA
                PHA
                LDA TRACE_FLAG
                BEQ NO_TRACE41

                PRINT_STR FN_WRITE_STR_ADDR
                PLA
                PHA
                TAX
                JSR PRTX
                JSR CROUT
NO_TRACE41:     
                PLA          
                RESTORE_REGS

.ENDIF

                TXA
                PHA

                LDX BUFLEN
                LDA BUF_ADDR 
                LDY BUF_ADDR+1
                JSR CPY_BUF_TO_WRITE_SP_PAYLOAD

                PLA
                TAX
                ; X = DEVICE
                LDY BUFLEN              ; MAX PAYLOAD IS 255         
                JSR SP_WRITE
                BCC WRITE_OK


WRITE_ERR:

                STA FN_LAST_ERR
.IF .NOT STRIP_TRACE
.IF EXT2_TRACE                
                PRINT_STR FN_WRITE_ERROR_STR_ADDR
                JSR DUMP_SP_PAYLOAD
.ENDIF
.ENDIF

                LDX #FN_ERR
                LDA FN_LAST_ERR
                CLC
                BCC WRITE_DONE
WRITE_OK:
   
                LDX #FN_OK
                STX FN_LAST_ERR
WRITE_DONE:
                LDY SP_COUNT
                
                RTS
.ELSE

;******************************************************************
; FN_WRITE - **** CONTROL VERSION ****
; Read the specified UNIT
;
; INPUT
; X      = UNIT DESTINATION
; BUFLEN = NUMBER OF BYTES TO WRITE
; BUF    = BUFFER TO SEND
;******************************************************************
FN_WRITE:

                TXA
                PHA

.IF .NOT STRIP_TRACE
                SAVE_REGS
                TXA
                PHA
                LDA TRACE_FLAG
                BEQ NO_TRACE41

                PRINT_STR FN_WRITE_STR_ADDR
                PLA
                PHA
                TAX
                JSR PRTX
                JSR CROUT
NO_TRACE41:     
                PLA          
                RESTORE_REGS

.ENDIF

                LDX BUFLEN                  ; MAX SIZE 255
                LDA BUF_ADDR 
                LDY BUF_ADDR+1

                JSR CPY_BUF_TO_CTRL_SP_PAYLOAD

;'W'
; 0-1  payload size (bytes to write)
; 2..  data

                ; SET PAYLOAD SIZE

                ; x = destination
                PLA
                TAX

                LDY BUFLEN              ; PAYLOAD SIZE
                STY SP_PAYLOAD
                LDA #$00
                STA SP_PAYLOAD+1

                LDY #'W'
                JSR SP_CONTROL
                STA FN_LAST_ERR
                BCC WRITE_OK

WRITE_ERR:


.IF .NOT STRIP_TRACE
.IF EXT2_TRACE                
                PRINT_STR FN_WRITE_ERROR_STR_ADDR
                JSR DUMP_SP_PAYLOAD
.ENDIF
.ENDIF

                LDX #FN_ERR
                LDA FN_LAST_ERR
                CLC
                BCC WRITE_DONE
WRITE_OK:
   
                LDX #FN_OK
WRITE_DONE:
                LDY SP_COUNT
                LDA LAST_SP_ERR
                RTS

.ENDIF

;******************************************************************
; FN_CLOSE
; Close the specified UNIT
;
; INPUT
; X = UNIT DESTINATION
;******************************************************************
FN_CLOSE:

.IF .NOT STRIP_TRACE
                SAVE_REGS
                LDA TRACE_FLAG
                BEQ NO_TRACE33
                TXA
                PHA
                PRINT_STR FN_CLOSE_STR_ADDR
                PRINT_STR UNIT_STR_ADDR
                PLA
                TAX
                JSR PRTX
                JSR CROUT
NO_TRACE33:                
                RESTORE_REGS
.ENDIF

                TXA
                PHA
                
                LDY #$00                ; PAYLOAD SIZE = ZERO
                STY SP_PAYLOAD
                STY SP_PAYLOAD+1
                
                LDY #'C'                ; SEND 'C' TO FUJINET
                JSR SP_CONTROL
                STA FN_LAST_ERR
                BCC CLOSE_OK

                PLA
                LDX #FN_ERR

.IF .NOT STRIP_TRACE                
                PRINT_STR CLOSE_ERROR_STR_ADDR
.ENDIF

                CLC
                BCC CLOSE_DONE
CLOSE_OK:
                PLA
                TAX
                JSR SP_CLOSE

                LDX #FN_OK
CLOSE_DONE:
                RTS


;******************************************************************
; FN_STATUS
;  Number of characters in the buffer and if connected
;
; INPUT
; X = UNIT DESTINATION
; RETURNS
; A = number of bytes waiting lo
; Y = number of bytes waiting hi
;******************************************************************
FN_STATUS:

.IF .NOT STRIP_TRACE
.IF EXT_TRACE
                SAVE_REGS
                TXA
                PHA
                LDA TRACE_FLAG
                BEQ NO_TRACE24

                PRINT_STR FN_BYTES_WAITING_STR_ADDR
                PLA
                PHA
                TAX
                JSR PRTX

NO_TRACE24:     
                PLA           
                RESTORE_REGS
.ENDIF
.ENDIF

;  sp_status(net,'S');
;
;  bw = sp_payload[0];
;  bw |= (sp_payload[1]) << 8;
;
;  if (bw==0)
;    return;
;  sp_status(net,'S');
;  return sp_payload[2] & 0x02; // Bit 2 = Connected?

                LDY #'S'
                JSR SP_STATUS
                STA FN_LAST_ERR
                BCC BW_OK
BW_ERROR:                
                LDX #FN_ERR
                BCS BW_DONE
BW_OK:
                LDA SP_PAYLOAD      ; Bytes Waiting
                LDY SP_PAYLOAD+1
                STA BW
                STY BW+1

                LDA SP_PAYLOAD+2 
                AND #$02
                STA CONNECT

                LDX #FN_OK

BW_DONE:
                RTS
        
;******************************************************************
; FN_FIND_NETWORK
; Return the Unit number for a device
;
; INPUT
;   BASIC_UNIT - Set between 0 and 3 as the network device to find
; RETURN
;   X - FN_ERR or UNIT number of device found
;******************************************************************
FN_FIND_NETWORK:

.IF .NOT STRIP_TRACE

                LDA TRACE_FLAG
                BEQ NO_TRACE25
                PRINT_STR FN_FIND_NETWORK_STR_ADDR
NO_TRACE25:                
.ENDIF

                LDA BASIC_UNIT
                CMP #$01
                BPL MULTI_NETWORK

                ; LOOK FOR "NETWORK"
                LDA NETWORK_STR_ADDR+1
                LDY NETWORK_STR_ADDR
         
                JSR SP_FIND_DEVICE          ; LOOK FOR "NETWORK"
                CPX #SP_ERR
                BNE FOUND_IT

MULTI_NETWORK:
                ; IF WE'RE HERE, THEN WE DIDN'T FIND "NETWORK"
                ; OR A UNIT NUMBER GREATER THAN ZERO WAS SPECIFIED.
                ; NOW LOOK FOR "NETWORK_X"

                LDX NETWORK_STR_WITH_NUMBER_INDEX

                LDA BASIC_UNIT
                CLC
                ADC #'0'
              
                STA NETWORK_STR_WITH_NUMBER,X

                LDA NETWORK_STR_WITH_NUMBER_ADDR+1
                LDY NETWORK_STR_WITH_NUMBER_ADDR 

                JSR SP_FIND_DEVICE              ; LOOK FOR "NETWORK_X" WHERE X IS 0-3
                CPX #SP_ERR
                BNE FOUND_IT
FIND_ERROR:                
                LDX #FN_ERR
FOUND_IT:
                TXA
                TAY                             ; RETURN IN Y

                RTS


FN_LIST:
;*******************************
; FN_LIST
;   Transfer devices into a buffer
;**********************************
                LDX #$00
                LDY #SP_CMD_STATUS
                JSR SP_STATUS

                LDX DCOUNT
                INX
                STX NUM_DEVICES

                LDX #$01
                LDY #$00
                STY STRLEN
NEXT_DEV1:               
                TXA
                PHA

                LDY #SP_STATUS_DIB      ; X = DEVICE 
                JSR SP_STATUS
                STA FN_LAST_ERR
                BCS FN_LIST_ERROR_OUT   ; SHOULD NEVER HAPPEN, BUT IF IT DOES, JUST EXIT

                LDX #$00              
NEXT_CHAR:
                LDA SP_PAYLOAD+5,X
                LDY STRLEN
                STA STRBUF,Y
                INX
                INC STRLEN
                CPX SP_PAYLOAD+4        ; ARE WE AT END OF STRING (NOT NULL TERMINATED)
                BNE NEXT_CHAR
                    
                LDA #','                 ; ADD A COMMA
                LDY STRLEN
                STA STRBUF,Y
                INC STRLEN

                PLA                     ; MOVE TO NEXT DEVICE
                TAX
                INX
                CPX NUM_DEVICES         ; HAVE WE EXCEEDED DEVICE LIST?
                BNE NEXT_DEV1

FN_LIST_OK:
                DEC STRLEN
                LDX STRLEN
                LDA #$00
                STA STRBUF,X            ; REMOVE THE LAST COMMA
                LDX #FN_OK
                CLC
                RTS

FN_LIST_ERROR_OUT:

                PLA

                LDX #FN_ERR
                SEC
                RTS

;******************************************************************
; FN_ACCEPT
;   Accept the specified connection from UNIT
;
; INPUT
; X = UNIT DESTINATION
;******************************************************************
FN_ACCEPT:

.IF .NOT STRIP_TRACE
                SAVE_REGS
                LDA TRACE_FLAG
                BEQ NO_TRACE42
                TXA
                PHA
                PRINT_STR FN_ACCEPT_STR_ADDR
                PLA
                TAX
                JSR PRTX
                JSR CROUT
NO_TRACE42:                
                RESTORE_REGS
.ENDIF

                TXA
                PHA
                
                LDY #$00                ; PAYLOAD SIZE = ZERO
                STY SP_PAYLOAD
                STY SP_PAYLOAD+1
                
                LDY #'A'                ; SEND 'A' TO FUJINET
                JSR SP_CONTROL
                STA FN_LAST_ERR
                BCC ACCEPT_OK

                PLA
                LDX #FN_ERR

.IF .NOT STRIP_TRACE                
                PRINT_STR ACCEPT_ERROR_STR_ADDR
.ENDIF

                CLC
                BCC ACCEPT_DONE
ACCEPT_OK:

                LDX #FN_OK

ACCEPT_DONE:
                STX FN_LAST_ERR  
                RTS
