.IF .NOT .DEFINED(AMPVECT)

SPACE                   =   $A0         ; SPACE CHARACTER FOR COUT
COLON                   =   ':'+$80     ; COLON CHARACTER FOR COUT

FRESPC                  =   $71         ; Applesoft pointer at the string storage area, used when a new string is created.
AMPVECT                 =   $03F5       ; AMPERSAND VECTOR FOR APPLESOFT
GETBYT                  =   $E6F8       ; EVAL BYTE -> X
CHKCOM                  =   $DEBE       ; CHECK FOR COMMA
FRMNUM                  =   $DD67       ; EVALUATE NUMERIC EXPRESSION
GETADR                  =   $E752       ; CONVERT FAC TO INT (MAX 65535)
PTRGET                  =   $DFE3       ; FIND NAMED VARIABLE (ADDRESS IN VARPTR)
STRINI                  =   $E3D5       ; CREATE NEW STRING SPACE
MOVSTR                  =   $E5E2       ; MOVE STRING INTO NEW SPACE A=LEN Y-HI SRC X=LO SRC, DESC in FRESPC
MOVFM                   =   $EAF9       ; UNPACK (Y,A) TO FAC
MOVMF                   =   $EB2B       ; PACK FAC TO (Y,A)
GIVAYF                  =   $E2F2       ; CONVERT SIGNED WORD (A,Y) TO FLOAT
SNGFLT                  =   $E301       ; CONVERT UNSIGNED BYTE Y TO FLOAT
FLOAT                   =   $EB90       ; CONVERT SIGNED BYTE A TO FLOAT
COUT                    =   $FDED       ; DISPLAY A AS CHAR ON SCREEN
CROUT                   =   $FD8E       ; END OF LINE (CARRIAGE RETURN)
STROUT                  =   $DB3A       ; PRINTS STRING POINT BY Y (HI) AND A(LO)
CONINT                  =   $E6FB       ; CONVERT FAC TO INT (MAX 255)
SYNERR                  =   $DEC9       ; ?SYNTAX ERROR
PRTYX                   =   $F940       ; PRINT Y AND X AS HEX
PRTAX                   =   $F941       ; PRINT A AND X AS HEX
PRTX                    =   $F944       ; PRINT X AS HEX
DOSWARM                 =   $03D0       ; CALL TO EXIT BRUN'D PROGRAM
TXTPTR                  =   $B8         ; WHERE WE ARE IN THE BASIC FILE
VARPTR                  =   $83         ; POINTER TO OUR VARIABLE
DSCTMP                  =   $9D         ; TEMPORARY DESCRIPTION STORAGE
CHRGET                  =   $B1         ; ADVANCE TXTPTR, GET CHAR INTO A
CHRGOT                  =   $B7         ; CHARACTER ALREADY PROCESSED BY BASIC
HIMEM                   =   $73         ; APPLESOFT HIMEM
LOMEM                   =   $4A         ; INTEGER BASIC LOMEM
KYBD                    =   $C000       ; KEYBOARD LOCATION
STROBE                  =   $C010       ; 

TOK_READ                =       135     ; APPLESOFT TOKEN FOR READ
TOK_AT                  =       197     ; APPLESOFT TOKEN FOR AT
TOK_END                 =       128     ; APPLESOFT TOKEN FOR END
QUOTE                   =       $22     ; ASCII QUOTE CHARACTER
TOK_LIST                =       188     ; APPLESOFT TOKEN FOR LIST                          
TOK_TRACE               =       155     ; APPLESOFT TOKEN FOR TRACE       
TOK_NOTRACE             =       156     ; APPLESOFT TOKEN FOR NOTRACE
TOK_INPUT               =       132     ; APPLESOFT TOKEN FOR INPUT  
TOK_PRINT               =       186     ; APPLESOFT TOKEN FOR PRINT


NEXT_WITHOUT_FOR        =   0
SYNTAX_ERROR            =  16
RETURN_WITHOUT_GOSUB    =  22
OUT_OF_DATA             =  42
ILLEGAL_QUANTITY_ERROR  =  53
OVERFLOW                =  69
OUT_OF_MEMORY           =  77
UNDEFINED_STATEMENT     =  90
BAD_SUBSCRIPT           = 107
REDIMINSIONED_ARRAY     = 120
DIVISION_BY_ZERO        = 133
TYPE_MISMATCH           = 163
STRING_TOO_LONG         = 176
FORMULA_TOO_COMPLEX     = 191
UNDEFINED_FUNCTION      = 224
BAD_RESPONSE_TO_INPUT   = 254
CTRL_C_INTERRUPT        = 255

APPLESOFT_ERROR         = $D412


.ENDIF