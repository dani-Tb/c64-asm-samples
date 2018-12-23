!cpu 6502
!to "int04-pixscroll.prg",cbm

!src "mylib/write.asm"

* = $0801                               ; BASIC starts at #2049
!byte $0d,$08,$dc,$07,$9e,$20,$34,$39   ; BASIC to load $c000
!byte $31,$35,$32,$00,$00,$00           ; inserts BASIC line: 2012 SYS 49152
* = $c000     				            ; start address for 6502 code

!zone main

scrollLine = $770 		; $0400+40*22

init:
	jsr clr
	
	sei		; disable irq
	
	lda #$7f ; CIA irq OFF
	sta $dc0d
	
	lda $d01a
	ora #$01
	sta $d01a
	
	lda $d011	; del raster MSB
	and #$7f
	sta $d011
	
	lda #0	; set raster line
	sta $d012		; could be anyone here
	
	lda #<intcode	; set irq addrs
	sta $0314
	lda #>intcode
	sta $0315
	
	cli				; enabe irqs
	
	+write .text,.color, .tx, .ty
	
loop:
	jmp loop
	
intcode:
	lda .modeFlag
	beq scrollOneLine
	jmp restoreScreen

; ---------------------------------
scrollOneLine:
	lda #$01		; invert flag
	sta .modeFlag
	
	lda .color1		; set colors
	sta $d020
	sta $d021
	
	jsr scrollPixel	; do scroll
	
	lda .rasterLine1 ; restore raster line
	sta $d012		; irq ack
	inc $d019		; restore flags
		
	jmp $ea31		; goto system irq routines
	
; --------------------------------
restoreScreen:
	lda #$00		; inverse fag
	sta .modeFlag

	lda .color2		; set colors
	sta $d020
	sta $d021
	
	;scroll quiet
	ldx #0
	stx $d016
	
	lda .rasterLine2 ; restore raster line
	sta $d012		; irq ack
	inc $d019		; restore flags
	
	; restore state to quit clean
	pla
	tay
	pla
	tax
	pla
	
	rti
	
	
; --------------------------------
scrollPixel:
	ldx #7		; 38 cols, scroll h, sweet scroll
	cpx #255
	beq resetSweetScroll
	
	stx $d016
	dec scrollPixel+1
	rts
	 
resetSweetScroll:
	ldx #7
	stx scrollPixel+1
	stx $d016
	jsr scrollChar
	
	rts
	
; --------------------------------
scrollChar:
	
	; --- scroll char to left
	ldx #0	
loopScroll:
	lda scrollLine+1, x
	sta scrollLine, x
	inx
	cpx #39
	bne loopScroll

	; get new char 
testIndex: 			; index of sring in $0400 
	ldx #0	
	lda $0400, x
	sta scrollLine + 39
	
	inx
	cpx #39			; if we reach last line char	
	beq resetIndex	; reset Index
	stx testIndex + 1
	rts
		 
resetIndex:
	ldx #0
	stx testIndex + 1

	rts
	
; ---------------------------------	
.rasterLine1:	
	!byte 200
.rasterLine2:	
	!byte 170
.modeFlag	
	!byte 0	
	
.text:
	!scr "|- - - - - - - hola mon - - - - - - - |"
	!byte $00

.color:
	!byte $01

.color1:
	!byte $00
	
.color2:
	!byte $06

.tx:
	!byte $00
.ty: 
	!byte $00
; ---------------------------------------------------
; ------- MY EXTERNAL DEPENDENCIES FILES ------------
!src "mylib/clr.asm"

	
	