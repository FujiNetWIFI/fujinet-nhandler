;*****************************************************
; ZEROPAGE
; "Safe" locations to use in zero page
;
; define APPLEII for Apple II zero page
; define ATARI   for Atari 8-bit zero page
;
; By Norman Davie

.IF .NOT .DEFINED(ZP1)

.IF .DEFINED(APPLEII)
ZP1	        =	$EB
ZP1_LO	        =	$EB
ZP1_HI	        = 	$EC

ZP2	        =	$ED
ZP2_LO	        =	$ED
ZP2_HI		=	$EE

ZP3	        =	$FA
ZP3_LO		=	$FA
ZP3_HI	   	=	$FB

ZP4	        =	$FC
ZP4_LO		=	$FC
ZP4_HI		=	$FD

ZP5             =	$EF
.ENDIF

.IF .DEFINED(ATARI)

ZP1		=	$A2
ZP1_LO	        =	$A2
ZP1_HI	        = 	$A3

ZP2             =	$A4
ZP2_LO		=	$A4
ZP2_HI		=	$A5

ZP3             =	$A6
ZP3_LO		=	$A6
ZP3_HI		=	$A7

ZP4             =	$A8
ZP4_LO		=	$A8
ZP4_HI		=	$A9

ZP5		=	$AA
.ENDIF


.ENDIF