
.IF .NOT .DEFINED(EXTADDED_STR)

; THESE STRINGS ARE USED DURING INITIALIZATION AND
; WON'T BE USED AFTERWARDS SO DON'T NEED TO BE RELOCATED

EXTADDED_STR:                               .BYTE   "FUJINET EXTENSIONS ADDED.", $0D, $00
SP_NOT_FOUND_STR:                           .BYTE   "NO SMARTPORT! EXTENSIONS NOT LOADED", $0D, $00
EXITING_STR:                                .BYTE   "EXITING...", $0D, $00
HIMEM_IS_STR:                               .ASCIIZ "OLD HIMEM: "
RELOC_SIZE_STR:                             .ASCIIZ "RELOCATION SIZE: "
NEW_HIMEM_STR:                              .ASCIIZ " NEW HIMEM: "
SIG_SIZE                                     = 7
SIGNATURE_STR:                              .ASCIIZ "FUJIAMP"

.IF .NOT USE_SP

TEST_BLOCK_LENGTH:      .WORD 806
TEST_BLOCK_READ_INDEX:  .WORD 0
TEST_BLOCK_STR_LEN:     .BYTE 255
TEST_BLOCK_STR:
    .BYTE "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor "
    .BYTE "incididunt ut labore et dolore magna aliqua. Ut enim blandit volutpat maecenas "
    .BYTE "volutpat blandit aliquam etiam erat. Pharetra magna ac placerat vestibulum lectus "
    .BYTE "mauris ultrices eros in. Aliquam purus sit amet luctus venenatis lectus magna fringilla urna. "
    .BYTE "Accumsan lacus vel facilisis volutpat est velit egestas dui. Quam pellentesque nec nam "
    .BYTE "aliquam. Malesuada fames ac turpis egestas sed tempus urna. Nisl vel pretium lectus quam id "
    .BYTE "leo in vitae turpis. Laoreet suspendisse interdum consectetur libero id faucibus. Sed "
    .BYTE "pulvinar proin gravida hendrerit lectus. Diam maecenas sed enim ut sem viverra aliquet "
    .BYTE "eget sit. Urna porttitor rhoncus dolor purus non enim praesent. Nibh tellus molestie nunc "
    .BYTE "non blandit massa enim nec."
    .BYTE $00
trace052:
TEST_BLOCK_STR_ADDR: .WORD TEST_BLOCK_STR
.ENDIF


;*******************************************
; THESE STRING ARE USED AFTER RELOCATING
;*******************************************

.IF .NOT STRIP_TRACE

; NOT NEEDED IF WE'RE NOT USING TRACE

NOPEN_STR:                                  .BYTE "NOPEN ", $00
trace000:
NOPEN_STR_ADDR:                             .WORD NOPEN_STR

NREAD_STR:                                  .BYTE "NREAD ", $00
trace001:
NREAD_STR_ADDR:                             .WORD NREAD_STR

NCLOSE_STR:                                 .BYTE "NCLOSE ",  $00
trace002:
NCLOSE_STR_ADDR:                            .WORD NCLOSE_STR, $0D, $00

NSTATUS_STR:                                .BYTE "NSTATUS ", $00
trace003:
NSTATUS_STR_ADDR:                           .WORD NSTATUS_STR

NEND_STR:                                   .BYTE "NEND", $0D, $00
trace004:
NEND_STR_ADDR:                              .WORD NEND_STR

NLIST_STR:                                  .BYTE "NLIST", $0D, $00
trace005:
NLIST_STR_ADDR:                             .WORD NLIST_STR

NTRACE_STR:                                 .BYTE "NTRACE", $0D, $00 
trace006:
NTRACE_STR_ADDR:                            .WORD NTRACE_STR

NWRITE_STR:                                 .BYTE "NWRITE", $0D, $00
trace007:
NWRITE_STR_ADDR:                            .WORD NWRITE_STR

NCTRL_STR:                                  .BYTE "NCTRL", $0D, $00
trace008:
NCTRL_STR_ADDR:                             .WORD NCTRL_STR

NACCEPT_STR:                                .BYTE "NACCEPT", $0D, $00
trace009:
NACCEPT_STR_ADDR:                           .WORD NACCEPT_STR

NINPUT_STR:                                 .BYTE "NINPUT", $0D, $00
trace010:
NINPUT_STR_ADDR:                            .WORD NINPUT_STR

NPRINT_STR:                                 .BYTE "NPRINT", $0D, $00
trace055:
NPRINT_STR_ADDR:                            .WORD NPRINT_STR

NSETEOL_STR:                                .BYTE "NSETEOL", $0D, $00
trace056:
NSETEOL_STR_ADDR:                           .WORD NSETEOL_STR

NTIME_STR:                                  .BYTE "NTIME", $0D, $00
trace057:
NTIME_STR_ADDR:                             .WORD NTIME_STR

NQUERY_STR:                                 .BYTE "NQUERY", $0D, $00
trace058:
NQUERY_STR_ADDR:                            .WORD NQUERY_STR

NJSON_STR:                                  .BYTE "NJSON", $0D, $00
trace059:
NJSON_STR_ADDR:                             .WORD NJSON_STR

FIND_SMARTPORT_SLOT_STR:                    .BYTE "FIND_SMARTPORT_SLOT: ", $00
trace011:
FIND_SMARTPORT_SLOT_STR_ADDR:               .WORD FIND_SMARTPORT_SLOT_STR

GET_SMARTPORT_DISPATCH_ADDRESS_STR:         .BYTE "GET_SMARTPORT_DISPATCH_ADDRESS", $0D, $00
trace012:
GET_SMARTPORT_DISPATCH_ADDRESS_STR_ADDR:    .WORD GET_SMARTPORT_DISPATCH_ADDRESS_STR

DISPATCHER_ADDRESS_STR:                     .ASCIIZ "DISPATCHER ADDRESS: " 
trace013:
DISPATCHER_ADDRESS_STR_ADDR:                .WORD DISPATCHER_ADDRESS_STR

SP_OPEN_STR:                                .BYTE "SP_OPEN:",    $00
trace014:
SP_OPEN_STR_ADDR:                           .WORD SP_OPEN_STR

SP_READ_STR:                                .BYTE "SP_READ:", $00
trace015:
SP_READ_STR_ADDR:                           .WORD SP_READ_STR

SP_WRITE_STR:                               .BYTE "SP_WRITE:", $00
trace016:
SP_WRITE_STR_ADDR:                          .WORD SP_WRITE_STR

SP_CLOSE_STR:                               .BYTE "SP_CLOSE:",   $00
trace017:
SP_CLOSE_STR_ADDR:                          .WORD SP_CLOSE_STR

SP_CONTROL_STR:                             .BYTE $0D, "SP_CONTROL:", $00
trace018:
SP_CONTROL_STR_ADDR:                        .WORD SP_CONTROL_STR

SP_STATUS_STR:                              .BYTE $0D, "SP_STATUS:", $00
trace019:
SP_STATUS_STR_ADDR:                         .WORD SP_STATUS_STR

CALL_DISPATCHER_STR:                        .BYTE "CALL_DISPATCHER",   $0D, $00
trace020:
CALL_DISPATCHER_STR_ADDR:                   .WORD CALL_DISPATCHER_STR

DISPLAY_SP_STATUS_STR:                      .BYTE "DISPLAY_SP_STATUS", $0D, $00
trace021:
DISPLAY_SP_STATUS_STR_ADDR:                 .WORD DISPLAY_SP_STATUS_STR

SP_FIND_DEVICE_STR:                         .BYTE "SP_FIND_DEVICE:",    $00
trace022:
SP_FIND_DEVICE_STR_ADDR:                    .WORD SP_FIND_DEVICE_STR

FN_FIND_NETWORK_STR:                        .BYTE "FN_FIND_NETWORK"    , $0D, $00
trace024:
FN_FIND_NETWORK_STR_ADDR:                   .WORD FN_FIND_NETWORK_STR

BYTES_WAITING_STR:                          .BYTE "BYTES:", $00
trace025:
BYTES_WAITING_STR_ADDR:                     .WORD BYTES_WAITING_STR

IS_CONNECTED_STR:                           .BYTE "CONNECTED:" , $00
trace026:
IS_CONNECTED_STR_ADDR:                      .WORD IS_CONNECTED_STR

FN_OPEN_STR:                                .BYTE "FN_OPEN:"         , $00
trace027:
FN_OPEN_STR_ADDR:                           .WORD FN_OPEN_STR

FN_CLOSE_STR:                               .BYTE "FN_CLOSE:"        , $00
trace028:
FN_CLOSE_STR_ADDR:                          .WORD FN_CLOSE_STR


FN_STATUS_STR:                              .BYTE "FN_STATUS:"        , $00
trace050:
FN_STATUS_STR_ADDR:                          .WORD FN_STATUS_STR

URL_STR:                                    .ASCIIZ "URL: "
trace030:
URL_STR_ADDR:                               .WORD URL_STR

MODE_STR:                                   .ASCIIZ "MODE: "
trace031:
MODE_STR_ADDR:                              .WORD MODE_STR

TRANS_STR:                                  .ASCIIZ "TRANS: "
trace032:
TRANS_STR_ADDR:                             .WORD TRANS_STR

LEN_STR:                                    .ASCIIZ "LEN:"
trace033:
LEN_STR_ADDR:                               .WORD LEN_STR

PAYLOAD_STR:                                .BYTE $0D, "PAY:", $00
trace034:
PAYLOAD_STR_ADDR:                           .WORD PAYLOAD_STR

CMD_LIST_STR:                               .BYTE $0D, "CMD_LIST: ", $00
trace035:
CMD_LIST_STR_ADDR:                          .WORD CMD_LIST_STR


CLOSE_ERROR_STR:                            .BYTE "CLOSE ERROR", $00
trace037:
CLOSE_ERROR_STR_ADDR:                       .WORD CLOSE_ERROR_STR

FN_READ_STR:                                .BYTE "FN_READ:", $00
trace038:       
FN_READ_STR_ADDR:                           .WORD FN_READ_STR

FN_READ_ERROR_STR:                          .BYTE "FN_READ ERROR", $0D, $00
trace039:
FN_READ_ERROR_STR_ADDR:                     .WORD FN_READ_ERROR_STR

FN_WRITE_STR:                               .BYTE "FN_WRITE", $00
trace040:
FN_WRITE_STR_ADDR:                          .WORD FN_WRITE_STR

FN_WRITE_ERROR_STR:                         .BYTE "FN WRITE ERROR", $0D, $00
trace041:
FN_WRITE_ERROR_STR_ADDR:                    .WORD FN_WRITE_ERROR_STR

FN_ACCEPT_ERROR_STR:                        .BYTE "FN ACCEPT ERROR", $0D, $00
trace042:
FN_ACCEPT_ERROR_STR_ADDR:                   .WORD FN_ACCEPT_ERROR_STR

SP_READ_ERROR_STR:                          .BYTE "SP_READ ERROR", $0D, $00
trace043:
SP_READ_ERROR_STR_ADDR:                     .WORD SP_READ_ERROR_STR

NREAD_ERROR_STR:                            .BYTE "NREAD_ERROR", $0D, $00
trace044:
NREAD_ERROR_STR_ADDR:                       .WORD NREAD_ERROR_STR

SP_NO_DCOUNT_STR:                           .BYTE $0D, "COULD NOT GET DCOUNT", $00
trace046:
SP_NO_DCOUNT_STR_ADDR:                      .WORD SP_NO_DCOUNT_STR

FN_INPUT_STR:                               .BYTE "FN_INPUT: ", $00
trace048:
FN_INPUT_STR_ADDR:                          .WORD FN_INPUT_STR

FN_ACCEPT_STR:                              .BYTE "FN_ACCEPT: ", $00
trace049:
FN_ACCEPT_STR_ADDR:                         .WORD FN_ACCEPT_STR

FN_QUERY_STR:                               .BYTE "FN_QUERY: ", $00
trace045:
FN_QUERY_STR_ADDR:                          .WORD FN_QUERY_STR

FN_JSON_STR:                                .BYTE "FN_JSON: ", $00
trace060:
FN_JSON_STR_ADDR:                           .WORD FN_JSON_STR
.ENDIF

FUJIAPPLE_VER_STR:                          .BYTE "FUJIAPPLE VERSION: YYYYMMDD.HHMM", $0D, $00
str000:
FUJIAPPLE_VER_STR_ADDR:                     .WORD FUJIAPPLE_VER_STR

NOT_OPENED_STR:                             .ASCIIZ "UNIT NOT OPENED!"
str001:
NOT_OPENED_STR_ADDR:                        .WORD NOT_OPENED_STR

CANT_RESTORE_STR:                           .BYTE $0D,"SOMETHING ELSE CHANGED HIMEM; CAN'T RESTORE ORIGINAL HIMEM.", $00
str002:
CANT_RESTORE_STR_ADDR:                      .WORD CANT_RESTORE_STR 

RESTORE_HIMEM_STR:                          .BYTE   $0D, "RESTORING HIMEM...", $00
str003:
RESTORE_HIMEM_STR_ADDR:                     .WORD RESTORE_HIMEM_STR

EXTREMOVED_STR:                             .BYTE   $0D, "FUJINET EXTENSIONS REMOVED.", $0D, $00
str004:
EXTREMOVED_STR_ADDR:                        .WORD EXTREMOVED_STR

DEV_LIST_STR:                               .ASCIIZ " SMARTPORT DEVICE LIST "
str006:
DEV_LIST_STR_ADDR:                          .WORD DEV_LIST_STR

UNIT_STR:                                   .ASCIIZ "UNIT #"
str007:         
UNIT_STR_ADDR:                              .WORD UNIT_STR

NAME_STR:                                   .ASCIIZ " NAME: "
str008:
NAME_STR_ADDR:                              .WORD NAME_STR

VENDER_STR:                                 .ASCIIZ "VENDER ID: "
str009:
VENDER_STR_ADDR:                            .WORD VENDER_STR

VENDER_VERSION_STR:                         .ASCIIZ "VENDER VERSION: "
str010:
VENDER_VERSION_STR_ADDR:                    .WORD VENDER_VERSION_STR

COUNT_STR:                                  .ASCIIZ "DEVICE COUNT: "
str011:
COUNT_STR_ADDR:                             .WORD COUNT_STR

SP_ERROR_STR:                               .ASCIIZ "SMARTPORT ERROR: "
str012:
SP_ERROR_STR_ADDR:                          .WORD SP_ERROR_STR


.IF .NOT USE_SP
FUJI_DISK_0_STR_LEN:                        .BYTE 14
.ENDIF
; NOTE:  WITH FAKEPORT, THIS STRING WILL HAVE THE "0" MODIFIED
FUJI_DISK_0_STR:                            .ASCIIZ "FUJINET_DISK_0"
str014:
FUJI_DISK_0_STR_ADDR:                       .WORD FUJI_DISK_0_STR
.IF .NOT USE_SP
DISK_STR_WITH_NUMBER_INDEX:                 .BYTE 13
.ENDIF

.IF .NOT USE_SP
NETWORK_STR_LEN:                            .BYTE 7
.ENDIF
NETWORK_STR:                                .ASCIIZ "NETWORK"
str015:
NETWORK_STR_ADDR:                           .WORD NETWORK_STR

.IF .NOT USE_SP
NETWORK_STR_WITH_NUMBER_LEN:                .BYTE 9
.ENDIF
NETWORK_STR_WITH_NUMBER:                    .ASCIIZ "NETWORK_1"
str016:
NETWORK_STR_WITH_NUMBER_ADDR:               .WORD NETWORK_STR_WITH_NUMBER
NETWORK_STR_WITH_NUMBER_INDEX:              .BYTE 8


.IF .NOT USE_SP
CLOCK_STR_LEN:                              .BYTE 8
.ENDIF
CLOCK_STR:                                  .ASCIIZ "FN_CLOCK"
str019:
CLOCK_STR_ADDR:                             .WORD CLOCK_STR

.IF .NOT USE_SP
CPM_STR_LEN:                                .BYTE 3
.ENDIF
CPM_STR:                                    .ASCIIZ "CPM"
str020:
CPM_STR_ADDR:                               .WORD CPM_STR

.IF .NOT USE_SP
PRINTER_STR_LEN:                            .BYTE 8
.ENDIF
PRINTER_STR:                                .ASCIIZ "PRINTER"
str021:
PRINTER_STR_ADDR:                           .WORD PRINTER_STR

DEVICE_NOT_FOUND_STR:                       .ASCIIZ "DEVICE NOT FOUND!"
str017:
DEVICE_NOT_FOUND_STR_ADDR:                  .WORD DEVICE_NOT_FOUND_STR

NETWORK_NOT_FOUND_STR:                      .ASCIIZ "NETWORK DEVICE NOT FOUND!"
str018:
NETWORK_NOT_FOUND_STR_ADDR:                 .WORD NETWORK_NOT_FOUND_STR



.IF .NOT USE_SP

; NOT A STRING, BUT NEEDED ANYWAY

trace050:
FAKE_DISPATCHER_ADDR:                       .WORD FAKE_DISPATCHER


FAKE_SMARTPORT_STR:                         .BYTE "**** FAKE SMARTPORT ****", $0D, $00
trace051:
FAKE_SMARTPORT_STR_ADDR:                    .WORD FAKE_SMARTPORT_STR

.ENDIF

.ENDIF