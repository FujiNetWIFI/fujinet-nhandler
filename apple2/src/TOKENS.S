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

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE1
                PRINT_STR NOPEN_STR_ADDR        ; "NOPEN"
NO_TRACE1:
.ENDIF

                JSR GETBYT                      ; GET THE BASIC UNIT
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
                CPX #$04                        ; BASIC UNIT HAS TO BE BETWEEN 0-3
                BMI UNIT_OK1                    ; OUT OF RANGE?

                LDX #ILLEGAL_QUANTITY_ERROR     ; MUST BE BETWEEN 0 AND 3
                JMP APPLESOFT_ERROR
               
UNIT_OK1:
                LDX BASIC_UNIT
                CPX #FN_ERR                     ; NETWORK WAS NOT FOUND!
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

                LDX BASIC_UNIT                  ; LOAD THE "BASIC" UNIT NUMBER
                LDA NETWORK_CACHE,X
                STA OPEN_LIST, X                     ; STORE THE ACTUAL UNIT NUMBER FOR LATER USE

                JSR CHKCOM
                JSR GETBYT                      ; GET MODE
                STX MODE

                JSR CHKCOM
                JSR GETBYT                      ; GET TRANS
                STX TRANSLATION

                JSR CHKCOM
                JSR CHRGOT                      ; WHAT ARE WE POINTING AT IN BASIC
                CMP #QUOTE                      ; IS IT A STATIC STRING?
                BNE VARSTR

                JSR GETSTR                      ; GETS THE STATIC STRING, STORED IN STRBUF

; WE'RE GOING TO CREATE A NEW DESCRIPTION
; THE SAME WAY APPLESOFT DOES

                LDA STRLEN                      ; GETSTR STORES THE STRING LENGTH HERE
                STA DSCTMP

                LDA STRBUF_ADDR                 ; THE ADDRESS OF OUR STATIC STRING
                STA DSCTMP+1
                LDA STRBUF_ADDR+1
                STA DSCTMP+2
                
                CLC
                BCC STORE

VARSTR:
                JSR GETSTRVAR                   ; IT'S A STRING VARIABLE
STORE:
                LDY DSCTMP                      ; GET THE STRING LENGTH
                STY URL_LEN                     ; INCLUDE NULL AT END OF LENGTH
                DEY
STORING:
                LDA (DSCTMP+1),Y                ; TRANSER THE STRING TO THE URL BUFFER
                STA URL,Y
                DEY
                BPL STORING

                ; MAKE THE STRING C COMPATIBLE

                LDY URL_LEN
                LDA #0                          ; NULL TERMINATE THE STRING
                STA URL,Y

                INY                             ; INCLUDE THE NULL TERMINATOR TO THE LENGTH
                STY URL_LEN

                LDX BASIC_UNIT                  ; BASIC UNIT 0-4
                LDA OPEN_LIST,X                   ; FUJINET UNIT
                TAX
                JSR FN_OPEN
                BCC NOPEN_COMPLETE

                LDX BASIC_UNIT                  ; FAILED TO OPEN
                LDA #FN_NO_NETWORK              ; INDICATE THE NETWORK IS 
                STA OPEN_LIST,X                   ; NOT IN USE
                LDA FN_LAST_ERR
                STA NERR,X

NOPEN_COMPLETE:
                LDY #$00
                STA BW
                
                RTS


;************************************************************************
; &NCLOSE UNIT
; Closes a network connection.
;************************************************************************
NCLOSE:

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE2
                PRINT_STR NCLOSE_STR_ADDR       ; "NCLOSE"

NO_TRACE2:                
.ENDIF
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
                CMP #FN_NO_NETWORK   ; CLOSING SOMETHING THAT IS NOT ACTUALLY OPEN  
                BEQ JUST_CLOSE
                TAX
                JSR FN_CLOSE

JUST_CLOSE:
                LDX BASIC_UNIT          ; SAVE ANY ERROR THAT OCCURED DURING CLOSE
                STA NERR,X

                LDA #FN_NO_NETWORK      ; REGARDLESS, INDICATE BASIC UNIT IS CLOSED
                STA OPEN_LIST, X
                RTS

;************************************************************************
; &NREAD UNIT, VAR$, LEN
; Gets "LEN" number of bytes and puts them into string variable var$
;************************************************************************
NREAD:

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE3
                PRINT_STR NREAD_STR_ADDR        ; "NREAD"
NO_TRACE3:                
.ENDIF
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
                CMP #FN_NO_NETWORK              ; $FF INDICATES IT WAS NEVER OPENED
                BNE UNIT_OK2

                LDA #FN_NO_NETWORK              ; RETURN ERROR THAT WE WERE NEVER CONNECTED
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
; Writes "LEN" characters of the string to the unit
;************************************************************************
NWRITE:

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE4      
                PRINT_STR NWRITE_STR_ADDR       ; "NWRITE"
NO_TRACE4:
.ENDIF
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
                CMP #FN_NO_NETWORK
                BNE UNIT_OK5

                PRINT_STR NOT_OPENED_STR_ADDR
                JMP SYNERR

UNIT_OK5:

                TAX
                JSR FN_WRITE

                RTS

;************************************************************************
; &NCTRL UNIT,COMMAND, PAYLOAD$
; Sends a specific control message to the network device 
; to do a special command. The payload for this command 
; is specified as the very last parameter.
;************************************************************************
NCTRL:

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE5
                PRINT_STR NCTRL_STR_ADDR        ; "NCTRL"
NO_TRACE5:
.ENDIF
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
                CMP #FN_NO_NETWORK
                BNE UNIT_OK4

                PRINT_STR NOT_OPENED_STR_ADDR
                JMP SYNERR
                
UNIT_OK4:

                RTS

;************************************************************************
; &NSTATUS UNIT,BW,CONNECTED,NERR
; To get the status of network unit. BW = bytes waiting, 
; CONNECTED equals 1 if connect and NERR returns 
; the network error code
;************************************************************************
NSTATUS:

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE6
                PRINT_STR NSTATUS_STR_ADDR
NO_TRACE6:                
.ENDIF
                JSR GETBYT
                STX BASIC_UNIT       ; STORE THE UNIT NUMBER

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE39
                SAVE_REGS
                JSR PRTX
                JSR CROUT
                RESTORE_REGS
NO_TRACE39:
.ENDIF
                JSR CHKCOM

                LDX BASIC_UNIT
                LDA OPEN_LIST,X                
                CMP #FN_NO_NETWORK
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
                JSR FN_STATUS           ; THIS SETS BW AND CONNECT              

SAVE_INFO:
                ; SEND TO BASIC
                LDA BW+1       ; NUMBER OF BYTES WAITING
                LDY BW
                JSR WORDSAV    ; CONVERT TO FLOAT AND STORE IN BW VAR

                JSR CHKCOM

                LDY CONNECT
                JSR BYTESAV    ; CONVERT TO FLOAT AND STORE IN CONNECT VAR

                JSR CHKCOM

                LDX BASIC_UNIT  ; "BASIC" UNIT, NOT THE ACTUAL UNIT              
                LDA NERR,X      ; GET THE ERROR FOR THIS BASIC UNIT
                TAY
                JSR BYTESAV    ; CONVERT TO FLOAT AND STORE IN NERR VAR
                RTS

;************************************************************************
; &NEND
; Remove the fujiapple vector and
; put the original vector back
; Restore HIMEM if it hasn't been changed since we set it
;************************************************************************
NEND:

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE7
                PRINT_STR NEND_STR_ADDR
NO_TRACE7:
.ENDIF

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
; Display devices or store devices into A$
;************************************************************************
NLIST:

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE8
                PRINT_STR NLIST_STR_ADDR
NO_TRACE8:                
.ENDIF

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
; Accept the incoming connection
;************************************************************************
NACCEPT:
.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE43
                PRINT_STR NACCEPT_STR_ADDR       ; "NACCEPT"

NO_TRACE43:                
.ENDIF
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
                CMP #FN_NO_NETWORK      ; TRYING TO ACCEPT SOMETHING THAT IS NOT ACTUALLY OPEN  
                BEQ ACCEPT_FAILED
                TAX
                JSR FN_ACCEPT

ACCEPT_FAILED:
                RTS

;************************************************************************
; &NINPUT UNIT,VAR$
;   Reads until either Carriage Return is received or 255 characters
; are received
;************************************************************************
NINPUT:

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE44      
                PRINT_STR NINPUT_STR_ADDR       ; "NINPUT"
NO_TRACE44:
.ENDIF
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
                CMP #FN_NO_NETWORK
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

                LDA FN_BUFFER_SIZE              ; THIS IS THE ACTUAL NUMBER OF CHARS WE READ
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

                LDA FN_BUFFER_SIZE              ; USE THE APPLESOFT ROUTINES TO
                LDY FN_BUFFER_ADDR+1            ; MOVE THE PAYLOAD INTO THE
                LDX FN_BUFFER_ADDR              ; ACTUAL STRING
                JSR MOVSTR                      ; COPY BUFFER TO STRING (VAR$)

                RTS

;************************************************************************
; &NPRINT UNIT,VAR$
; &NPRINT UNIT,"STRING"
;  Writes the string to the unit
;************************************************************************
NPRINT:

.IF .NOT STRIP_TRACE
                LDA TRACE_FLAG
                BEQ NO_TRACE4      
                PRINT_STR NPRINT_STR_ADDR       ; "NPRINT"
NO_TRACE4:
.ENDIF
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
                BNE GETVAR2

                JSR GETSTR                      ; GET THE STATIC STRING
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

                LDY BUFLEN
COPYBUF2:
                LDA (DSCTMP+1),Y
                STA BUF,Y
                DEY
                BPL COPYBUF2

                LDX BASIC_UNIT
                LDA OPEN_LIST,X
                CMP #FN_NO_NETWORK
                BNE UNIT_OK7

                PRINT_STR NOT_OPENED_STR_ADDR
                JMP SYNERR

UNIT_OK7:

                TAX
                JSR FN_WRITE

                RTS

