;************************************************************************
; &NOPEN UNIT,MODE,TRANS,URL$
; &NOPEN UNIT,MODE,TRANS,"URL"
;
; Opens a specified URL for use.
;
; UNIT = 0-4 BASIC NETWORK (not Fujinet unit number)
; MODE = 04-READ ONLY
;        06-READ DIRECTORY
;        08-WRITE ONLY
;        0C-READ AND WRITE
;        0E-HTTP POST
; TRANS= 0-NO TRANSLATION
;        1-CR TO CR (yeah, does nothing)
;        2-LF TO CR 
;        3-CR/LF TO CR
;************************************************************************
NOPEN:

                DISPLAY_TRACE NOPEN_STR_ADDR            ; #<LINNUM> NOPEN

                JSR GETBYT                              ; &NOPEN [UNIT],MODE,TRANS,URL$
                STX BASIC_UNIT        

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE32
                SAVE_REGS
                JSR PRTX
                JSR CROUT
                RESTORE_REGS
NO_TRACE32:
.ENDIF
                CPX #$04                                ; BASIC UNIT HAS TO BE BETWEEN 0-3
                BMI UNIT_OK1                            ; OUT OF RANGE?

                LDX #ILLEGAL_QUANTITY_ERROR             ; MUST BE BETWEEN 0 AND 3
                JMP APPLESOFT_ERROR
               
UNIT_OK1:
                LDX BASIC_UNIT
                CPX #FN_ERR                             ; NETWORK WAS NOT FOUND!
                BNE NOPEN_NETWORK_FOUND

NO_NETWORK_ERROR:
                LDA #FN_ERR_SERVICE_NOT_AVAILABLE       ; CAN'T FIND THE SPECIFIED NETWORK (E.G. NETWORK_1 WAS NOT FOUND)
                STA NERR,X                              ; RECORD THE ERROR
                LDA #FN_ERR                             ; INDICATE THIS BASIC_UNIT IS CLOSED
                STA OPEN_LIST,X
                JSR IGNORE_TO_NEXT_BASIC_STATEMENT
                RTS

NOPEN_NETWORK_FOUND:

                ; NETWORK_CACHE: WW XX YY ZZ - WHERE EACH BYTE IS THE ACTUAL UNIT NUMBER

                LDX BASIC_UNIT                          ; LOAD THE "BASIC" UNIT NUMBER
                LDA NETWORK_CACHE,X
                STA OPEN_LIST, X                        ; STORE THE ACTUAL UNIT NUMBER FOR LATER USE

                JSR CHKCOM                              ; &NOPEN UNIT[,]MODE,TRANS,URL$
                JSR GETBYT                              ; GET MODE
                STX MODE                                ; &NOPEN UNIT,[MODE],TRANS,URL$

                JSR CHKCOM                              ; &NOPEN UNIT,MODE[,]TRANS,URL$
                JSR GETBYT                              ; GET TRANS
                STX TRANSLATION                         ; &NOPEN UNIT,MODE,[TRANS],URL$

                JSR CHKCOM                              ; &NOPEN UNIT,MODE,TRANS[,]URL$
                JSR CHRGOT                              ; WHAT ARE WE POINTING AT IN BASIC
                CMP #QUOTE                              ; IS IT A STATIC STRING?
                BNE VARSTR

                JSR GETSTR                              ; &NOPEN UNIT,MODE,TRANS,["string"]

; WE'RE GOING TO CREATE A NEW DESCRIPTION
; THE SAME WAY APPLESOFT DOES

                LDA STRLEN                              ; GETSTR STORES THE STRING LENGTH HERE
                STA DSCTMP

                LDA STRBUF_ADDR                         ; THE ADDRESS OF OUR STATIC STRING
                STA DSCTMP+1
                LDA STRBUF_ADDR+1
                STA DSCTMP+2
                
                CLC
                BCC STORE

VARSTR:
                JSR GETSTRVAR                           ; &NOPEN UNIT,MODE,TRANS,[URL$]
STORE:
                LDY DSCTMP                              ; GET THE STRING LENGTH
                STY URL_LEN                             
STORING:
                LDA (DSCTMP+1),Y                        ; TRANSER THE STRING TO THE URL BUFFER
                STA URL,Y
                DEY
                BPL STORING

                LDY URL_LEN                             ; C STYLE STRING
                LDA #$00
                STA URL,Y
                INC URL_LEN

                LDX BASIC_UNIT                          ; BASIC UNIT 0-4
                LDA OPEN_LIST,X                         ; FUJINET UNIT
                TAX
                JSR FN_OPEN
                BCC NOPEN_COMPLETE

                LDX BASIC_UNIT                          ; FAILED TO OPEN
                LDA #FN_ERR_NO_DEVICE                   ; INDICATE THE NETWORK IS 
                STA OPEN_LIST,X                         ; NOT IN USE
                LDA FN_LAST_ERR
                STA NERR,X
                RTS

NOPEN_COMPLETE:

                LDY #$00                                ; CLEAR BYTES WAITING
                
                STA BW
                STA BW+1
                LDX BASIC_UNIT
                LDA #FN_OK
                STA NERR,X
                RTS


;************************************************************************
; &NCLOSE UNIT
;
; Closes a network connection.
;
; UNIT = 0-4 BASIC NETWORK (not Fujinet unit number)
;************************************************************************
NCLOSE:

                DISPLAY_TRACE NCLOSE_STR_ADDR    ; #<LINNUM> NCLOSE

                JSR   GETBYT                    ; GET THE UNIT
                STX   BASIC_UNIT

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE34

                SAVE_REGS
                JSR PRTX
                JSR CROUT
                RESTORE_REGS
NO_TRACE34:
.ENDIF               


                LDX BASIC_UNIT
                LDA OPEN_LIST, X          ; THIS IS THE ACTUAL UNIT NUMBER
                CMP #FN_ERR_NO_DEVICE   ; CLOSING SOMETHING THAT IS NOT ACTUALLY OPEN  
                BEQ JUST_CLOSE
                TAX
                JSR FN_CLOSE

JUST_CLOSE:
                LDX BASIC_UNIT          ; SAVE ANY ERROR THAT OCCURED DURING CLOSE
                STA NERR,X

                LDA #FN_ERR_NO_DEVICE      ; REGARDLESS, INDICATE BASIC UNIT IS CLOSED
                STA OPEN_LIST, X
                RTS

;************************************************************************
; &NREAD UNIT, VAR$, LEN
; Gets "LEN" number of bytes and puts them into string variable var$
;************************************************************************
NREAD:

                DISPLAY_TRACE NREAD_STR_ADDR    ; #<LINNUM> NREAD

                JSR   GETBYT                    ; GET THE UNIT
                STX   BASIC_UNIT

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE36
                SAVE_REGS
                JSR PRTX
                JSR CROUT
                RESTORE_REGS
NO_TRACE36:
.ENDIF

                JSR CHKCOM
                JSR PTRGET                      ; GET THE STRING TO RECEIVED OUR DATA

;Returns the address of variable contents in A-reg (high) and Y-reg (low), 
;as well as in VARPTR at $83.84. If a variable does not exist, it
;is created. TXTPTR points to the next character. 

                LDA VARPTR                      ; SAVE THE STRING DESCRIPTOR LOCATION 
                STA STR_DSC_LEN                 ; FOR LATER
                LDA VARPTR+1
                STY STR_DSC_LO
                LDA VARPTR+2
                STA STR_DSC_HI

                JSR CHKCOM
                JSR GETBYT                      ; GET THE NUMBER OF CHARACTERS TO READ 
                STX BUFLEN
                TXA


                LDX BASIC_UNIT                  ; CONVERT THE BASIC_UNIT TO THE FUJINET UNIT
                LDA OPEN_LIST,X
                CMP #FN_ERR_NO_DEVICE              ; $FF INDICATES IT WAS NEVER OPENED
                BNE UNIT_OK2

                LDA #FN_ERR_NO_DEVICE              ; RETURN ERROR THAT WE WERE NEVER CONNECTED
                STA NERR,X
                RTS

UNIT_OK2:
                TAX
                JSR FN_READ                     ; REQUEST THE DATA FROM FUJINET
                CPX #FN_ERR
                BNE TRANSFER_VALUES

NREAD_ERROR:
                STA NERR,X
                RTS

TRANSFER_VALUES:                
                ; TODO:
                ; Adjust BUFLEN to the actual amount of
                ; characters read

                ; MOVSTR
                ; Source must be in Y(HI) and X(LO)
                ; Destination must be in FRESPC ($71,$72)

                LDA STR_DSC_LEN                 ; RESTORE THE STRING DESCRIPTOR
                STA VARPTR                      ; THAT WE SAVED EARLIER SO WE
                LDA STR_DSC_LO                  
                STA VARPTR+1
                LDA STR_DSC_HI
                STA VARPTR+2

                LDA BUFLEN                      ; THIS IS THE ACTUAL NUMBER OF CHARS WE READ
                JSR STRINI                      ; CREATE NEW STRING OF LENGTH A

                LDY #$00
                LDA DSCTMP                      ; DESCRIPTOR FOR NEW STRING
                STA (VARPTR),Y                  ; UPDATE THE LENGTH
                INY
                LDA DSCTMP+1                    ; UPDATE THE LOCATION OF THE STRING
                STA (VARPTR),Y 
                INY
                LDA DSCTMP+2
                STA (VARPTR),Y

                LDA BUFLEN                      ; USE THE APPLESOFT ROUTINES TO
                LDY SP_PAYLOAD_ADDR+1           ; MOVE THE PAYLOAD INTO THE
                LDX SP_PAYLOAD_ADDR             ; ACTUAL STRING
                JSR MOVSTR                      ; COPY BUFFER TO STRING (VAR$)
                
                RTS

;************************************************************************
; &NWRITE UNIT,VAR$,LEN
; &NWRITE UNIT,"STRING",LEN
;
; Writes "LEN" characters of the string to the unit
;
; UNIT = 0-4 BASIC NETWORK (not Fujinet unit number)
; VAR$ = The byte data to send to the unit
; LEN  = The number of bytes within the string to send
;************************************************************************
NWRITE:

                DISPLAY_TRACE NWRITE_STR_ADDR   ; #<LINNUM> NWRITE

                JSR GETBYT                      ; GET UNIT
                STX BASIC_UNIT

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE37
                SAVE_REGS
                JSR PRTX
                JSR CROUT
                RESTORE_REGS
NO_TRACE37:
.ENDIF

                JSR CHKCOM
                JSR CHRGOT                      ; WHAT ARE WE POINTING AT IN BASIC?
                CMP #QUOTE                      ; IS IT A STATIC STRING?
                BNE GETVAR

                JSR GETSTR                      ; GET THE STATIC STRING

                ; WE'RE GOING TO CREATE A NEW DESCRIPTION
                ; THE SAME WAY APPLESOFT DOES

                LDA STRLEN                      ; GETSTR STORES THE STRING LENGTH HERE
                STA DSCTMP

                LDA STRBUF_ADDR                 ; THE ADDRESS OF OUR STATIC STRING
                STA DSCTMP+1
                LDA STRBUF_ADDR+1
                STA DSCTMP+2
                CLC
                BCC STORE2

GETVAR:
                JSR GETSTRVAR                   ; GET VAR$

                LDA DSCTMP                      ; SAVE THE STRING DESCRIPTOR LOCATION 
                STA STR_DSC_LEN                 ; FOR LATER
                LDA DSCTMP+1
                STA STR_DSC_LO
                LDA DSCTMP+2
                STA STR_DSC_HI

STORE2:
                JSR CHKCOM
                JSR GETBYT                    ; GET LENGTH REQUESTED
                STX BUFLEN

                LDY #$00
                LDA STR_DSC_LEN
                STA DSCTMP,Y 
                INY
                LDA STR_DSC_LO
                STA DSCTMP,Y  
                INY
                LDA STR_DSC_HI
                STA DSCTMP,Y

                LDY BUFLEN
COPYBUF:
                LDA (DSCTMP+1),Y
                STA BUF,Y
                DEY
                BPL COPYBUF

                LDX BASIC_UNIT
                LDA OPEN_LIST,X
                CMP #FN_ERR_NO_DEVICE
                BNE UNIT_OK5

                PRINT_STR NOT_OPENED_STR_ADDR
                JMP SYNERR

UNIT_OK5:

                TAX
                JSR FN_WRITE

                RTS

;************************************************************************
; &NCTRL UNIT,COMMAND, PAYLOAD$
;
; Sends a specific control message to the network device 
; to do a special command. The payload for this command 
; is specified as the very last parameter.
;************************************************************************
NCTRL:

                DISPLAY_TRACE NCTRL_STR_ADDR    ; #<LINNUM> NCTRL

                JSR GETBYT     ; GET UNIT
                STX BASIC_UNIT

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE38
                SAVE_REGS
                JSR PRTX
                JSR CROUT
                RESTORE_REGS
NO_TRACE38:
.ENDIF

                JSR CHKCOM
                JSR GETBYT     ; GET COMMAND
                STX COMMAND

                JSR CHKCOM
                JSR CHRGOT     ; WHAT ARE WE POINTING AT IN BASIC?
                CMP #QUOTE     ; IS IT A STATIC STRING?
                BNE GETVAR3

                JSR GETSTR     ; GET THE STATIC STRING

                ; WE'RE GOING TO CREATE A NEW DESCRIPTION
                ; THE SAME WAY APPLESOFT DOES

                LDA STRLEN                      ; GETSTR STORES THE STRING LENGTH HERE
                STA DSCTMP

                LDA STRBUF_ADDR                 ; THE ADDRESS OF OUR STATIC STRING
                STA DSCTMP+1
                LDA STRBUF_ADDR+1
                STA DSCTMP+2
                CLC
                BCC STORE3

GETVAR3:
                JSR GETSTRVAR

STORE3:

; MOVE STRING TO PAYLOAD

                LDY DSCTMP
CPY2BUF:
                LDA (DSCTMP+1),Y
                STA BASIC_PAYLOAD,Y
                DEY
                BPL CPY2BUF

                LDA BASIC_UNIT
                TAX
                LDA OPEN_LIST,X
                CMP #FN_ERR_NO_DEVICE
                BNE UNIT_OK4

                PRINT_STR NOT_OPENED_STR_ADDR
                JMP SYNERR
                
UNIT_OK4:

                RTS

;************************************************************************
; &NSTATUS UNIT,BW,CN,NERR
;
; To get the status of network unit.
;
; UNIT = 0-4 BASIC NETWORK (not Fujinet unit number)
; BW   = Bytes waiting to be read
; CN   = Connection status 
; NERR = Last error generated by UNIT
;************************************************************************
NSTATUS:

                DISPLAY_TRACE NSTATUS_STR_ADDR  ; #<LINNUM> NSTATUS

                JSR GETBYT                      ; &NSTATUS [UNIT],BW,CN,NERR
                STX BASIC_UNIT                  ; STORE THE UNIT NUMBER

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE39
                SAVE_REGS
                JSR PRTX
                JSR CROUT
                RESTORE_REGS
NO_TRACE39:
.ENDIF
                JSR CHKCOM                      ; &NSTATUS UNIT[,]BW,CN,NERR

                LDX BASIC_UNIT
                LDA OPEN_LIST,X                
                CMP #FN_ERR_NO_DEVICE
                BNE INFO

                LDA #$FF                        ; USER HASN'T OPENED THE
                STA BW                          ; CONNECTION, SO JUST
                STA BW+1                        ; SET EVERYTHING TO -1/255

                LDA #$00
                STA CONNECT                     ; NO CONNECTION
                CLC
                BCC SAVE_INFO

                ; we have a network

INFO:
                TAX                
                JSR FN_STATUS                   ; THIS SETS BW AND CONNECT              

SAVE_INFO:
                ; SEND TO BASIC
                LDA BW+1                        ; NUMBER OF BYTES WAITING
                LDY BW                          ; &NSTATUS UNIT,[BW],CN,NERR
                JSR WORDSAV                     ; CONVERT TO FLOAT AND STORE IN BW VAR

                JSR CHKCOM                      ; &NSTATUS UNIT,BW[,]CN,NERR

                LDY CONNECT                     ; &NSTATUS UNIT,BW,[CN],NERR
                JSR BYTESAV                     ; CONVERT TO FLOAT AND STORE IN CONNECT VAR

                JSR CHKCOM                      ; &NSTATUS UNIT,BW,CN[,]NERR

                LDX BASIC_UNIT                  ; "BASIC" UNIT, NOT THE ACTUAL UNIT              
                LDA NERR,X                      ; GET THE ERROR FOR THIS BASIC UNIT
                TAY
                JSR BYTESAV                     ; &NSTATUS UNIT,BW,CN,[NERR]
                RTS

;************************************************************************
; &NEND
;
; Remove the fujiapple vector and
; put the original vector back
; Restore HIMEM if it hasn't been changed since we set it
;************************************************************************
NEND:

                DISPLAY_TRACE NEND_STR_ADDR    ; #<LINNUM> NEND

.IF RELOCATE

                LDA HIMEM
                CMP RELOC_NSTART
                BNE NO_RESTORE
                LDA HIMEM+1
                CMP RELOC_NSTART+1
                BNE NO_RESTORE

                PRINT_STR RESTORE_HIMEM_STR_ADDR

                LDA OLDHIMEM
                STA HIMEM
                LDA OLDHIMEM+1
                STA HIMEM+1

                JMP RESTORE_VECT

NO_RESTORE:
                PRINT_STR CANT_RESTORE_STR_ADDR

.ENDIF

;*****************************************************
RESTORE_VECT:

                LDA PREVECT
                STA AMPVECT
                LDA PREVECT+1
                STA AMPVECT+1
                LDA PREVECT+2
                STA AMPVECT+2

                PRINT_STR EXTREMOVED_STR_ADDR      ; LET THE USER KNOW
                RTS

;************************************************************************
; &NLIST
; &NLIST A$
;
; Display devices or store devices into A$ as comma separated
;************************************************************************
NLIST:

                DISPLAY_TRACE NLIST_STR_ADDR    ; #<LINNUM> NLIST

                JSR CHRGOT
                BEQ NO_ARG
                CMP #':'
                BEQ NO_ARG

                JSR FN_LIST

                JSR PTRGET                      ; GET THE STRING TO RECEIVED OUR DATA

                LDA STRLEN                      ; USE THE APPLESOFT ROUTINES TO
                JSR STRINI                      ; CREATE A NEW STRING OF APPROPRIATE SIZE

                LDY #$00
                LDA DSCTMP                      ; DESCRIPTOR FOR NEW STRING
                STA (VARPTR),Y                  ; UPDATE THE LENGTH
                INY
                LDA DSCTMP+1                    ; UPDATE THE LOCATION OF THE STRING
                STA (VARPTR),Y 
                INY
                LDA DSCTMP+2
                STA (VARPTR),Y

                LDY STRBUF_ADDR+1               ; MOVE OUR STRING BUFFER INTO THE
                LDX STRBUF_ADDR                 ; ACTUAL STRING
                JSR MOVSTR                      ; COPY BUFFER TO STRING (VAR$)
               
                RTS

NO_ARG:
                JSR DISPLAY_SP_DEVICES

                RTS


.IF .NOT STRIP_TRACE
;************************************************************************
; &NTRACE
; Display debug messages
;************************************************************************
NTRACE:

                PRINT_STR FUJIAPPLE_VER_STR_ADDR

                PRINT_STR NTRACE_STR_ADDR
             
                LDA #$01
                STA TRACE_FLAG

                RTS

;************************************************************************
; &NNOTRACE
; No longer display debug messages
;************************************************************************
NNOTRACE:

                LDA #$00
                STA TRACE_FLAG

                RTS
.ENDIF

;************************************************************************
; &NACCEPT UNIT
;
; Accept the incoming connection
;
; UNIT = 0-4 BASIC NETWORK (not Fujinet unit number)
;***********************************************
NACCEPT:
                DISPLAY_TRACE NACCEPT_STR_ADDR  ; #<LINNUM> NACCEPT

                JSR   GETBYT                    ; GET THE UNIT
                STX   BASIC_UNIT

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE45

                SAVE_REGS
                JSR PRTX
                JSR CROUT
                RESTORE_REGS
NO_TRACE45:
.ENDIF               

                LDX BASIC_UNIT
                LDA OPEN_LIST, X        ; THIS IS THE ACTUAL UNIT NUMBER
                CMP #FN_ERR_NO_DEVICE      ; TRYING TO ACCEPT SOMETHING THAT IS NOT ACTUALLY OPEN  
                BEQ ACCEPT_FAILED
                TAX
                JSR FN_ACCEPT

ACCEPT_FAILED:
                RTS

;************************************************************************
; &NINPUT UNIT,VAR$
;
;   Reads until either EOL character is received or 255 characters
; are received (see NSETEOL)
;
; UNIT = 0-4 BASIC NETWORK (not Fujinet unit number)
; VAR$ = Buffer to receive the data
;************************************************************************
NINPUT:

                DISPLAY_TRACE NINPUT_STR_ADDR   ; #<LINNUM> NINPUT

                JSR GETBYT                      ; GET UNIT
                STX BASIC_UNIT

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE46
                SAVE_REGS
                JSR PRTX
                JSR CROUT
                RESTORE_REGS
NO_TRACE46:
.ENDIF

                JSR CHKCOM

                JSR PTRGET                      ; GET THE STRING TO RECEIVED OUR DATA

;Returns the address of variable contents in A-reg (high) and Y-reg (low), 
;as well as in VARPTR at $83.84. If a variable does not exist, it
;is created. TXTPTR points to the next character. 

                LDA VARPTR                      ; SAVE THE STRING DESCRIPTOR LOCATION 
                STA STR_DSC_LEN                 ; FOR LATER
                LDA VARPTR+1
                STY STR_DSC_LO
                LDA VARPTR+2
                STA STR_DSC_HI

                LDX BASIC_UNIT
                LDA OPEN_LIST,X
                CMP #FN_ERR_NO_DEVICE
                BNE UNIT_OK6

                PRINT_STR NOT_OPENED_STR_ADDR
                JMP SYNERR

UNIT_OK6:
                TAX
                JSR FN_INPUT

                LDA STR_DSC_LEN                 ; RESTORE THE STRING DESCRIPTOR
                STA VARPTR                      ; THAT WE SAVED EARLIER SO WE
                LDA STR_DSC_LO                  
                STA VARPTR+1
                LDA STR_DSC_HI
                STA VARPTR+2

                LDA STRLEN              ; THIS IS THE ACTUAL NUMBER OF CHARS WE READ
                JSR STRINI                      ; CREATE NEW STRING OF LENGTH A

                LDY #$00
                LDA DSCTMP                      ; DESCRIPTOR FOR NEW STRING
                STA (VARPTR),Y                  ; UPDATE THE LENGTH
                INY
                LDA DSCTMP+1                    ; UPDATE THE LOCATION OF THE STRING
                STA (VARPTR),Y 
                INY
                LDA DSCTMP+2
                STA (VARPTR),Y

                LDA STRLEN                      ; USE THE APPLESOFT ROUTINES TO
                LDY STRBUF_ADDR+1               ; MOVE THE PAYLOAD INTO THE
                LDX STRBUF_ADDR                 ; ACTUAL STRING
                JSR MOVSTR                      ; COPY BUFFER TO STRING (VAR$)

                RTS

;************************************************************************
; &NPRINT UNIT,VAR$[;]
; &NPRINT UNIT,"STRING"[;]
;
;  Writes the string to the unit
;
; UNIT = 0-4 BASIC NETWORK (not Fujinet unit number)
; VAR$ = Data to be sent to the unit.  The data will be followed by the
;        EOL character (see NSETEOL) if the semicolon is absent
;************************************************************************
NPRINT:

                DISPLAY_TRACE NPRINT_STR_ADDR    ; #<LINNUM> NPRINT

                JSR GETBYT                      ; GET UNIT
                STX BASIC_UNIT

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE51
                SAVE_REGS
                JSR PRTX
                JSR CROUT
                RESTORE_REGS
NO_TRACE51:
.ENDIF

                JSR CHKCOM
                JSR CHRGOT                      ; WHAT ARE WE POINTING AT IN BASIC?
                CMP #QUOTE                      ; IS IT A STATIC STRING?
                BNE GETVAR2

                JSR GETSTR                      ; GET THE STATIC STRING

                ; WE'RE GOING TO CREATE A NEW DESCRIPTION
                ; THE SAME WAY APPLESOFT DOES

                LDA STRLEN                      ; GETSTR STORES THE STRING LENGTH HERE
                STA STR_DSC_LEN

                LDA STRBUF_ADDR                 ; THE ADDRESS OF OUR STATIC STRING
                STA STR_DSC_LO
                LDA STRBUF_ADDR+1
                STA STR_DSC_HI

                CLC
                BCC STORE4

GETVAR2:
                JSR GETSTRVAR                   ; GET VAR$

                LDA DSCTMP                      ; SAVE THE STRING DESCRIPTOR LOCATION 
                STA STR_DSC_LEN                 ; FOR LATER
                LDA DSCTMP+1
                STA STR_DSC_LO
                LDA DSCTMP+2
                STA STR_DSC_HI

STORE4:
                LDA STR_DSC_LEN
                STA BUFLEN

                LDY #$00
                LDA STR_DSC_LEN
                STA DSCTMP,Y 
                INY
                LDA STR_DSC_LO
                STA DSCTMP,Y  
                INY
                LDA STR_DSC_HI
                STA DSCTMP,Y

STORE2BUF:
                LDY BUFLEN
COPYBUF2:
                LDA (DSCTMP+1),Y
                STA BUF,Y
                DEY
                BPL COPYBUF2

                LDX BASIC_UNIT
                LDA OPEN_LIST,X
                CMP #FN_ERR_NO_DEVICE
                BNE UNIT_OK7

                PRINT_STR NOT_OPENED_STR_ADDR
                JMP SYNERR

UNIT_OK7:
                JSR CHRGOT          ; If a semicolon is present, don't send EOL
                CMP #SEMICOLON 
                BNE ADD_EOL
                JSR CHRGET
                CLC
                BCC SEND_BUF


ADD_EOL:
                LDX BUFLEN          ; Add an EOL character to the end of the buffer
                LDA EOL
                STA BUF,X
                INX
                STX BUFLEN          
SEND_BUF:
                LDX BASIC_UNIT
                LDA OPEN_LIST,X
                TAX      
                JSR FN_WRITE
                RTS

;************************************************************************
; &NTIME YEAR, MONTH, DAY, HOUR, MINUTE, SECOND
;
;   Get the current time
;
;************************************************************************
NTIME:
                DISPLAY_TRACE NTIME_STR_ADDR  ; #<LINNUM> NTIME

                JSR   FN_CLOCK

                LDY YEAR
                JSR BYTESAV    ; CONVERT TO FLOAT AND STORE IN YEAR VAR
                JSR CHKCOM
          
                LDY MONTH
                JSR BYTESAV    ; CONVERT TO FLOAT AND STORE IN MONTH VAR
                JSR CHKCOM          

                LDY DAY
                JSR BYTESAV    ; CONVERT TO FLOAT AND STORE IN DAY VAR
                JSR CHKCOM

                LDY HOUR
                JSR BYTESAV    ; CONVERT TO FLOAT AND STORE IN HOUR VAR
                JSR CHKCOM

                LDY MINUTE
                JSR BYTESAV    ; CONVERT TO FLOAT AND STORE IN MINUTE VAR
                JSR CHKCOM

                LDY SECOND
                JSR BYTESAV    ; CONVERT TO FLOAT AND STORE IN SECOND VAR
                RTS

;************************************************************************
; &SETEOL EOL
;   
;   Set the End-of-line character used with the the NPRINT and NINPUT 
; commands.  If not set the default is carriage return ($0D/13)
;************************************************************************
NSETEOL:
                DISPLAY_TRACE NSETEOL_STR_ADDR  ; #<LINNUM> NSETEOL

                JSR GETBYT                      ; GET UNIT
                STX EOL
                RTS


;************************************************************************
; &NJSON UNIT, ONOFF
;   
;   Set the channel to JSON mode
;************************************************************************

NJSON:
                DISPLAY_TRACE NJSON_STR_ADDR  ; #<LINNUM> NSETEOL

                JSR GETBYT                      ; &NJSON [UNIT], ONOFF
                STX BASIC_UNIT

                LDA OPEN_LIST,X
                CMP #FN_ERR_NO_DEVICE
                BNE UNIT_OK8

                PRINT_STR NOT_OPENED_STR_ADDR
                JMP SYNERR
UNIT_OK8:
                JSR CHKCOM                      ; &NJSON UNIT[,]ONOFF
                JSR GETBYT                      ; &NJSON UNIT,[ONOFF]
                TXA
                TAY

                LDX BASIC_UNIT
                LDA OPEN_LIST,X 
                TAX     

                JSR FN_JSON

                CPX #FN_ERR
                BNE NJSON_DONE

                LDX BASIC_UNIT
                STA NERR,X

NJSON_DONE:

                RTS


;************************************************************************
; &NQUERY UNIT,QUERY$, VALUE$
;
;   From the open unit, get the value of query   
;
; UNIT = 0-4 BASIC NETWORK (not Fujinet unit number)
; QUERY$ = The value to query
; VALUE$ = The data retrieved
;************************************************************************
NQUERY:
                DISPLAY_TRACE NQUERY_STR_ADDR    ; #<LINNUM> NREAD

                JSR   GETBYT                    ; &NQUERY [UNIT],QUERY$, VALUE$
                STX   BASIC_UNIT

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE47
                SAVE_REGS
                JSR PRTX
                JSR CROUT
                RESTORE_REGS
NO_TRACE47:
.ENDIF

                LDX BASIC_UNIT                  ; CONVERT THE BASIC_UNIT TO THE FUJINET UNIT
                LDA OPEN_LIST,X
                CMP #FN_ERR_NO_DEVICE           ; $FF INDICATES IT WAS NEVER OPENED
                BNE UNIT_OK9

                LDA #FN_ERR_NO_DEVICE           ; RETURN ERROR THAT WE WERE NEVER CONNECTED
                STA NERR,X
                JSR IGNORE_TO_NEXT_BASIC_STATEMENT
                RTS
UNIT_OK9:

                JSR CHKCOM                      ; &NQUERY UNIT[,]QUERY$, VALUE$

                JSR GETSTRVAR                   ; &NQUERY UNIT,[QUERY$], VALUE$

                LDA DSCTMP                      ; SAVE THE STRING DESCRIPTOR LOCATION 
                STA STR_DSC_LEN                 ; FOR LATER
                LDA DSCTMP+1
                STA STR_DSC_LO
                LDA DSCTMP+2
                STA STR_DSC_HI

                ; TRANSFER QUERY VARIABLE DATA TO BUF

                LDA STR_DSC_LEN
                STA BUFLEN

                LDY #$00
                LDA STR_DSC_LEN
                STA DSCTMP,Y 
                INY
                LDA STR_DSC_LO
                STA DSCTMP,Y  
                INY
                LDA STR_DSC_HI
                STA DSCTMP,Y

                LDY BUFLEN
                INY
COPYBUF3:
                LDA (DSCTMP+1),Y
                STA BUF,Y
                DEY
                BPL COPYBUF3

                LDA #$00
                LDY BUFLEN
                STA BUF,Y

                LDX BASIC_UNIT
                LDA OPEN_LIST,X
                TAX
                JSR FN_QUERY                    ; REQUEST THE DATA FROM FUJINET

                CPX #FN_ERR
                BNE TRANSFER_VALUES2

NQUERY_ERROR:
                LDX BASIC_UNIT
                STA NERR,X
                JSR IGNORE_TO_NEXT_BASIC_STATEMENT
                RTS

TRANSFER_VALUES2:
                JSR CHKCOM                      ; &NQUERY UNIT,QUERY$[,]VALUE$

                JSR GETSTRVAR                   ; &NQUERY UNIT,QUERY$,[VALUE$]

                LDA DSCTMP                      ; SAVE THE STRING DESCRIPTOR LOCATION 
                STA STR_DSC_LEN                 ; FOR LATER
                LDA DSCTMP+1
                STA STR_DSC_LO
                LDA DSCTMP+2
                STA STR_DSC_HI
                
                LDA BUFLEN                      ; THIS IS NUMBER OF CHARACTERS OF THE RESPONSE
                JSR STRINI                      ; CREATE NEW STRING OF LENGTH A

                LDY #$00
                LDA DSCTMP                      ; DESCRIPTOR FOR NEW STRING
                STA (VARPTR),Y                  ; UPDATE THE LENGTH
                INY
                LDA DSCTMP+1                    ; UPDATE THE LOCATION OF THE STRING
                STA (VARPTR),Y 
                INY
                LDA DSCTMP+2
                STA (VARPTR),Y

                ; MOVSTR
                ; Source must be in Y(HI) and X(LO)
                ; Destination must be in FRESPC ($71,$72)

                LDA BUFLEN                      ; USE THE APPLESOFT ROUTINES TO
                LDY SP_PAYLOAD_ADDR+1           ; MOVE THE PAYLOAD INTO THE
                LDX SP_PAYLOAD_ADDR             ; ACTUAL STRING
                JSR MOVSTR                      ; COPY BUFFER TO STRING (VAR$)

                
                RTS

;************************************************************************
; &NLET VAR%=VALUE
;
;   Sets an array/matrix to a specific value.  VAR cannot be a string   
;
; VAR   = array to alter
; VALUE = value to set each element in the integer array to
;************************************************************************

ARRAY_HEADER   = ZP2
ELEMENT_ADDRESS= ZP3

NLET:
                JSR GETARYPT                    ; &NLET [VAR%],VALUE

                LDA LOWTR
                STA ARRAY_HEADER
                LDA LOWTR+1
                STA ARRAY_HEADER+1
                ;--------------------------------
                ;   NOW $9B,9C HAVE ADDRESS OF START OF ARRAY
                ;   NEED TO MOVE POINTER UP TO FIRST ELEMENT
                ;
                ; DIM LO%(47,79)
                ;   HEADER IS:
                ; CC CF  L O  - Both with high bit set   = integer array
                ;             - Both with high bit clear = real array
                ;             - first high bit clear, second high bit set = string array
                ; 09 1E  Offset to next array
                ; 02 00  # of dimensions
                ; 30 00  48
                ; 50 00  80
                ; DATA
                ;--------------------------------
                LDY #0
                LDA (ARRAY_HEADER),Y 
                INY
                EOR (ARRAY_HEADER),Y
                AND #$80        ; IS BITS DIFFERENT THEN STRING ARRAY
                BEQ NUMERIC_ARRAY
                JMP SYNERR

NUMERIC_ARRAY:
                JSR CHKCOM      ; &NLET VAR%[,]VALUE
                LDY #0
                LDA (ARRAY_HEADER),Y 
                INY
                AND (ARRAY_HEADER),Y
                AND #$80        ; IS HIGH BITS CLEAR THEN INTEGER ARRAY
                BEQ FLOAT_ARRAY

 INTEGER_ARRAY:
                LDA #2
                STA ELEMENT_SIZE

                JSR FRMNUM      ; &NLET VAR%,[VALUE]
                JSR GETADR      ; RESULT STORED IN LINNUM

                LDA LINNUM+1
                STA ELEMENT
                LDA LINNUM
                STA ELEMENT+1
                CLC
                BCC GET_START_OF_DATA

FLOAT_ARRAY:
                LDA #5
                STA ELEMENT_SIZE

                JSR FRMNUM      ; &NLET VAR%,[VALUE]
                LDY #$00
@loop:
                LDA FAC,Y 
                STA ELEMENT,Y 
                INY
                CPY ELEMENT_SIZE
                BNE @loop

GET_START_OF_DATA:

                ; Z2 POINTS TO HEADER
                ;
                ;    CC CF  L O  - Both with high bit set   = integer array
                ;                 - Both with high bit clear = real array
                ;                 - first high bit clear, second high bit set = string array
                ;    09 1E  Offset to next array
                ;--> 02 00  # of dimensions
                ;    30 00  48 DIM 1
                ;    50 00  80 DIM 2
                ;

                ; calculate how much header to skip
                ; before we get to data

                LDY #4                      ; POINT AT LSB OF # DIMENSIONS
                LDA (ARRAY_HEADER),Y
                ASL                         ; DOUBLE IT (IGNORE MSB, #<120) 
                ADC #5                      ; POINT AT FIRST ELEMENT
                STA HEADER_SIZE             ; NUMBER OF BYTES IN HEADER TO SKIP


                ;--------------------------------
                ;      NOW COMPUTE FULL ADDRESS OF FIRST ELEMENT
                ;--------------------------------
                CLC
                LDA HEADER_SIZE             ; SIZE OF HEADER
                ADC ARRAY_HEADER
                STA START_OF_ARRAY          ; ARRAY_START_LO
                LDA ARRAY_HEADER+1
                ADC #0
                STA START_OF_ARRAY+1        ; ARRAY_START_HI


                ;--------------------------------
                ;      NOW COMPUTE FULL ADDRESS OF LAST ELEMENT
                ;--------------------------------
                LDY #2                      ; POINT AT LSB OF OFFSET TO NEXT ARRAY
                CLC                         ; COMPUTE ADDRESS JUST PAST END OF THE HEADER
                LDA ARRAY_HEADER
                ADC (ARRAY_HEADER),Y
                STA END_OF_ARRAY
                INY
                LDA ARRAY_HEADER+1
                ADC (ARRAY_HEADER),Y
                STA END_OF_ARRAY+1           

                ;--------------------------------
                ; COMPUTE THE NUMBER OF BYTES IN THE ARRAY
                ;--------------------------------

                SEC
                LDA END_OF_ARRAY
                SBC START_OF_ARRAY
                STA ARRAY_BYTES_LEFT

                LDA END_OF_ARRAY+1
                SBC START_OF_ARRAY+1
                STA ARRAY_BYTES_LEFT+1


                LDA START_OF_ARRAY
                STA ELEMENT_ADDRESS
                LDA START_OF_ARRAY+1
                STA ELEMENT_ADDRESS+1

@are_we_done:
                LDA ARRAY_BYTES_LEFT        ; WHEN BOTH ARE ZERO WE ARE DONE
                ORA ARRAY_BYTES_LEFT+1
                BEQ WE_ARE_DONE 


                LDY #$00
@loop:
                ; COPY 1 ELEMENT
                LDA ELEMENT,Y 
                STA (ELEMENT_ADDRESS),Y 
                INY
                CPY ELEMENT_SIZE
                BNE @loop

                ; INCREASE THE ADDRESS

                CLC
                LDA ELEMENT_ADDRESS
                ADC ELEMENT_SIZE
                STA ELEMENT_ADDRESS
                LDA ELEMENT_ADDRESS+1
                ADC #$00
                STA ELEMENT_ADDRESS+1

                ; DECREASE THE COUNT

                SEC 
                LDA ARRAY_BYTES_LEFT
                SBC ELEMENT_SIZE
                STA ARRAY_BYTES_LEFT
                LDA ARRAY_BYTES_LEFT+1
                SBC #$00
                STA ARRAY_BYTES_LEFT+1
                CLC 
                BCC @are_we_done

                
WE_ARE_DONE:
                RTS