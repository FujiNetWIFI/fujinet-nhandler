;*****************************************************
; FUJINET.S
; BASIC to Fujinet
; By Norman Davie

    .include "MACROS.S"
    .include "REGS.S"

FN_OK                   = 0
FN_ERR                  = $FE
FN_ERR_NO_DEVICE        = $FD

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

;******************************************************************
; CPY_BUF_TO_SP_PAYLOAD
; Copies 'X' bytes to the Smartport buffer 
;
; INPUT
;  BUF = source of the data
;  X = bytes to copy
;  A = high address
;  Y = low address
; RETURNS
;
;******************************************************************
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
; CPY_BUF_TO_QUERY_SP_PAYLOAD
; Copies 'X' bytes to the Smartport buffer+2
; Set the initial 2 bytes of the buffer with the length of
; the data; as $X $0 ; thus a maximum of 255 bytes of data
;
; INPUT
;  BUF = source of the data
;  X = bytes to copy
;  A = high address
;  Y = low address
; RETURNS
;
;******************************************************************
CPY_BUF_TO_QUERY_SP_PAYLOAD:
                
                JSR WIPE_PAYLOAD
                STX ZP2
                STA ZP1_LO
                STY ZP1_HI
                
                STX SP_PAYLOAD      ; LOW BYTE OF LENGTH OF BUFFER
                LDX #$00
                STX SP_PAYLOAD+1    ; HIGH BYTE OF LENGTH OF BUFFER
                LDY #$00
KEEP_CALM4:
                LDA (ZP1),Y
                STA SP_PAYLOAD+2,X
                CPX ZP2
                BEQ CPY_DONE4
                INY
                INX
                CLC
                BCC KEEP_CALM4

CPY_DONE4:
                RTS


;******************************************************************
; CPY_SP_PAYLOAD_TO_BUF
; Copies 'X' bytes from the Smartport buffer into BUF

;
; INPUT
;  BUFLEN = number of bytes to transfer
;
; RETURNS
;  BUF = smartport data
;******************************************************************
CPY_SP_PAYLOAD_TO_BUF:
                
                LDX BUFLEN
                
KEEP_CALM5:
                LDA SP_PAYLOAD,X
                STA BUF,X
                DEX
                BPL KEEP_CALM5

CPY_DONE5:
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
                
                JSR DUMP_SP_PAYLOAD        ; PRINT THE URL

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


;******************************************************************
; FN_READ - SMARTPORT VERSION
; Read the specified UNIT
;
; INPUT
; X = UNIT DESTINATION
; BUFLEN = NUMBER OF BYTES TO READ
; OUTPUT:
; SP_PAYLOAD
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
                ; X = DEVICE
                LDY BUFLEN              ; MAX PAYLOAD IS 255         
                JSR SP_READ
                STA FN_LAST_ERR
                BCC READ_OK


READ_ERR:

.IF .NOT STRIP_TRACE  
.IF EXT_TRACE              
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
.IF EXT_TRACE                
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
                PLA
                TAX
                JSR PRTX
                JSR CROUT
NO_TRACE33:                
                RESTORE_REGS
.ENDIF

                TXA
                PHA
                
                LDY #$03                ; PAYLOAD SIZE = ZERO
                STY SP_PAYLOAD
                LDY #$00
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
; X = FN_OK or FN_ERR
;******************************************************************
FN_STATUS:

.IF .NOT STRIP_TRACE
.IF EXT_TRACE
                SAVE_REGS
                TXA
                PHA
                LDA TRACE_FLAG
                BEQ NO_TRACE24

                PRINT_STR FN_STATUS_STR_ADDR
                PLA
                PHA
                TAX
                JSR PRTX

NO_TRACE24:     
                PLA           
                RESTORE_REGS
.ENDIF
.ENDIF

                LDA #FN_OK
                STA FN_LAST_ERR

                LDY #'S'
                JSR SP_STATUS
                STA FN_LAST_ERR
                BCC BW_OK
BW_ERROR:                
                LDX #FN_ERR
                BCC BW_OK
                STA FN_LAST_ERR
                LDX #FN_ERR
                BCC BW_OK
                STA FN_LAST_ERR
                BCS BW_DONE
BW_OK:
                LDA SP_PAYLOAD      ; Bytes Waiting
                LDY SP_PAYLOAD+1
                STA BW
                STY BW+1

                LDA SP_PAYLOAD+2 
                STA CONNECT

.IF EXT_TRACE
    SAVE_REGS
    PRINT_STR BYTES_WAITING_STR_ADDR
    LDA BW+1
    LDX BW
    JSR PRTAX
    PRINT_STR IS_CONNECTED_STR_ADDR
    LDX CONNECT
    JSR PRTX
    JSR CROUT
    RESTORE_REGS
.ENDIF

BW_DONE:
                LDX #FN_OK
                LDA FN_LAST_ERR
                BEQ BW_COMPLETE
                LDX #FN_ERR
BW_COMPLETE:
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
.IF EXT2_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE25
                PRINT_STR FN_FIND_NETWORK_STR_ADDR
                LDA #SPACE
                JSR COUT
                LDX BASIC_UNIT
                JSR PRTX
                LDA #SPACE
                JSR COUT

NO_TRACE25:                
.ENDIF
.ENDIF

                LDA BASIC_UNIT
                CMP #$01
                BPL MULTI_NETWORK

                ; LOOK FOR "NETWORK"
                LDA NETWORK_STR_ADDR+1
                LDY NETWORK_STR_ADDR

.IF .NOT STRIP_TRACE
.IF EXT2_TRACE
                PRINT_STR NETWORK_STR_ADDR
                LDA #SPACE
                JSR COUT
                LDA NETWORK_STR_ADDR+1
                LDY NETWORK_STR_ADDR
.ENDIF
.ENDIF
    
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

.IF .NOT STRIP_TRACE
.IF EXT2_TRACE
                PRINT_STR NETWORK_STR_WITH_NUMBER_ADDR
                LDA #SPACE
                JSR COUT
                LDA NETWORK_STR_WITH_NUMBER_ADDR+1
                LDY NETWORK_STR_WITH_NUMBER_ADDR 
.ENDIF
.ENDIF
                JSR SP_FIND_DEVICE              ; LOOK FOR "NETWORK_X" WHERE X IS 0-3
                CPX #SP_ERR
                BNE FOUND_IT
FIND_ERROR:
.IF .NOT STRIP_TRACE
.IF EXT2_TRACE
                PRINT_STR DEVICE_NOT_FOUND_STR_ADDR
                JSR CROUT
.ENDIF        
.ENDIF        
                LDX #FN_ERR
                RTS
FOUND_IT:
                TXA
                TAY                             ; RETURN IN Y
                LDX #FN_OK

.IF .NOT STRIP_TRACE
.IF EXT2_TRACE
                SAVE_REGS
                JSR PRTAX
                JSR CROUT
                RESTORE_REGS
.ENDIF
.ENDIF
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
                STX BCD              
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

                
                LDY #$03                ; PAYLOAD SIZE = ZERO
                STY SP_PAYLOAD
                LDY #$00
                STY SP_PAYLOAD+1
                
                LDY #'A'                ; SEND 'A' TO FUJINET
                JSR SP_CONTROL
                STA FN_LAST_ERR
                BCC ACCEPT_OK

                LDX #FN_ERR

.IF .NOT STRIP_TRACE                
                PRINT_STR FN_ACCEPT_ERROR_STR_ADDR
.ENDIF

                CLC
                BCC ACCEPT_DONE
ACCEPT_OK:
                LDX #FN_OK

ACCEPT_DONE:
                STX FN_LAST_ERR  
                RTS

;******************************************************************
; FN_INPUT
;   Read until carriage return is received or 255 characters are
; received
;
; INPUT
; X = UNIT DESTINATION
;******************************************************************
FN_INPUT:

.IF .NOT STRIP_TRACE
                SAVE_REGS
                TXA
                PHA
                LDA TRACE_FLAG
                BEQ @skip

                PRINT_STR FN_INPUT_STR_ADDR
                PLA
                PHA
                TAX
                JSR PRTX
                JSR CROUT
@skip:     
                PLA          
                RESTORE_REGS

.ENDIF

                LDA #$00
                STA STRLEN
GET_NEXT_CHAR:
                ; X = DEVICE
                TXA                 ; SAVE THE DEVICE
                PHA
                LDY #1              ; READ ONE CHARACTER        
                JSR SP_READ
                BCC INPUT_OK      ; IF NO CHARACTERS TO READ, THEN QUIT
INPUT_ERR:
                PLA
                CLC
                BCC INPUT_STOP

INPUT_OK:
                PLA
                TAX                     ; RESTORE THE DEVICE #
                LDY STRLEN
                LDA SP_PAYLOAD
                STA STRBUF,Y
                CMP EOL                 ; DON'T "SAVE" THE EOL IN THE BUFFER
                BEQ INPUT_STOP          ; STOP IF WE RECEIVE A EOL

                INC STRLEN
                BNE GET_NEXT_CHAR       ; MAX 255 CHARACTERS


INPUT_STOP:
                LDX #FN_OK
                RTS

;******************************************************************
; FN_CLOCK
;   Get the current time from the Fujinet Clock
;
;******************************************************************
FN_CLOCK:

                JSR WIPE_PAYLOAD 

                LDX FN_CLOCK_CACHE
                CPX #FN_ERR_NO_DEVICE
                BEQ @skip

                LDY #'T'
                JSR SP_STATUS
@skip:
                LDA SP_PAYLOAD
                STA CENTURY 
                LDA SP_PAYLOAD+1
                STA YEAR 
                LDA SP_PAYLOAD+2
                STA MONTH
                LDA SP_PAYLOAD+3
                STA DAY 
                LDA SP_PAYLOAD+4
                STA HOUR 
                LDA SP_PAYLOAD+5
                STA MINUTE 
                LDA SP_PAYLOAD+6
                STA SECOND 
NO_CLOCK:
                RTS


;******************************************************************
; FN_JSON
;   Set JSON mode
;
;******************************************************************
FN_JSON:

.IF .NOT STRIP_TRACE
                SAVE_REGS
                TXA
                PHA
                LDA TRACE_FLAG
                BEQ @skip

                PRINT_STR FN_JSON_STR_ADDR
                PLA
                PHA
                TAX
                JSR PRTX
                JSR CROUT
@skip:     
                PLA          
                RESTORE_REGS

.ENDIF

                TXA
                PHA                         ; SAVE THE CHANNEL

                LDA #FN_OK
                STA FN_LAST_ERR

                LDA #01 
                STA SP_PAYLOAD      ; PAYLOAD LENGTH = 1
                LDA #$00
                STA SP_PAYLOAD+1

                STY SP_PAYLOAD+2    ; SET TO JSON MODE = Y

                PLA                 ; GET BACK OUR UNIT
                PHA
                TAX

                LDY #$FC            
                JSR SP_CONTROL
                BCC JSON_OK1

                STA FN_LAST_ERR
                BCS JSON_DONE
JSON_OK1:
                PLA                 ; GET BACK OUR UNIT
                TAX

                LDY #'P'
                JSR SP_CONTROL
                BCC JSON_DONE

                STA FN_LAST_ERR

JSON_DONE:
                LDX #FN_OK
                LDA FN_LAST_ERR
                BEQ JSON_COMPLETE
                LDX #FN_ERR
JSON_COMPLETE:
                RTS

;******************************************************************
; FN_QUERY
;   Set JSON mode
;
;******************************************************************
FN_QUERY:

.IF .NOT STRIP_TRACE
                SAVE_REGS
                TXA
                PHA
                LDA TRACE_FLAG
                BEQ @skip

                PRINT_STR FN_QUERY_STR_ADDR
                PLA
                PHA
                TAX
                JSR PRTX
                JSR CROUT
@skip:     
                PLA          
                RESTORE_REGS
.ENDIF

                TXA                     ; SAVE OUR CHANNEL
                PHA

                LDA #FN_OK
                STA FN_LAST_ERR

                ; FORMAT IS SP[0] = LEN
                ;           SP[1] = LEN+1
                ;           SP[2]... ITEM TO QUERY WITHOUT NULL

                LDX BUFLEN
                LDA BUF_ADDR 
                LDY BUF_ADDR+1
                JSR CPY_BUF_TO_QUERY_SP_PAYLOAD

                PLA                     ; GET BACK OUR CHANNEL
                PHA
                TAX

                ; X = DEVICE
                LDY #'Q'              ; MAX PAYLOAD IS 255    
                JSR SP_CONTROL
                BCC QUERY_OK1

                STA FN_LAST_ERR 
                BNE QUERY_DONE               
QUERY_OK1:
                LDY #3
                STY ZP5
TRY_AGAIN:
                PLA
                PHA
                TAX

                JSR FN_STATUS
                CPX #FN_OK
                BEQ QUERY_OK2

                STA FN_LAST_ERR 
                BNE QUERY_DONE   

QUERY_OK2:

                LDA BW
                ORA BW+1
                BNE QUERY_CONTINUE

                DEC ZP5
                BNE TRY_AGAIN

                LDA #FN_ERR_TIMED_OUT
                STA FN_LAST_ERR
                BNE QUERY_DONE

QUERY_CONTINUE:

                LDA BW
                STA BUFLEN

                PLA
                PHA
                TAX

                JSR FN_READ
                CPX #FN_OK
                BEQ QUERY_OK3

                STA FN_LAST_ERR
                BNE QUERY_DONE
QUERY_OK3: 
      
                JSR CPY_SP_PAYLOAD_TO_BUF

QUERY_DONE:

                PLA

                LDX #FN_OK
                LDA FN_LAST_ERR
                BEQ QUERY_COMPLETE
              
                LDX #FN_ERR
QUERY_COMPLETE:

                RTS



