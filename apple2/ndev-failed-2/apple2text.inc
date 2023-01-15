;-------------------------
; string with high-bit set
;-------------------------
.macro ASCIIHI str
    .repeat .strlen (str), c
        .byte .strat (str, c) | $80
    .endrep
.endmacro

;-------------------------
; string with high-bit set, null-terminated
;-------------------------
.macro ASCIIHIZ str
    .repeat .strlen (str), c
        .byte .strat (str, c) | $80
    .endrep
    .byte 0
.endmacro

;-------------------------
; string, last char with high-bit set
;-------------------------
.macro ASCIIHIL str
    .repeat .strlen (str) - 1, c
        .byte .strat (str, c)
    .endrep
    .byte .strat (str, .strlen (str) - 1) | $80
.endmacro
