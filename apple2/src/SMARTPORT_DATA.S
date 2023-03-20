NUM_DEVICES:    .BYTE $00

SMARTPORT_DISPATCHER: 
DISPATCHER_ADDR_LO:     .BYTE $00
DISPATCHER_ADDR_HI:     .BYTE $00

relocatesp00:
SP_PAYLOAD_ADDR:        .WORD  SP_PAYLOAD
relocatesp01:
SP_PAYLOAD_STR_ADDR:    .WORD  SP_PAYLOAD+5

SP_COUNT:               .WORD   $FFFF           ; BYTES IN PAYLOAD?
LAST_SP_ERR:            .BYTE   SP_ERR          ; ERROR CODE

CMD_LIST:               .RES    $15   
relocatesp02:            
CMD_LIST_ADDR:          .WORD   CMD_LIST
SP_PAYLOAD:
DCOUNT:                 .BYTE   $01             ; NUMBER OF DEVICES
INTSTATE:               .BYTE   $FF             ; INTERRUPT STATUS (IF BIT 6 IS SET, THEN NO INTERRUPT)
MANUFACTURER:           .WORD   $FFFF           ; DRIVER MANUFACTURER
                                                ; $0000 - UNDETERMINED
                                                ; $0001 - APPLE
                                                ; $0002-$FFFF 3RD PARTY DRIVER
INTERFACEVER:           .WORD   $FFFF           ; INTERFACE VERSION
                        .WORD   $0000           ; RESERVED (MUST BE $0000)
                        .RES    512             ; RESERVED FOR DATA

FIND_DEVICE_BUF_LEN:    .BYTE 0
FIND_DEVICE_BUF:        .RES  255
relocatesp03:
FIND_DEVICE_BUF_ADDR:   .WORD FIND_DEVICE_BUF
SMARTPORT_ID:           .BYTE $20, $00, $03, $00 
