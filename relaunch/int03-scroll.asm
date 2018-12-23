!cpu 6502
!to "int03-scroll.prg",cbm

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
	
	lda .rasterLine	; set raster line
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
	jsr scrollChar

	inc $d019	; irq ack
	
	lda .rasterLine	; restore raster line
	sta $d012
	
	jmp	$ea31		; jmp to sytem irqs

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
.rasterLine:	
	!byte 100	
	
.text:
	!scr "|- - - - - - - hola mon - - - - - - - |"
	!byte $00

.color:
	!byte $01

.tx:
	!byte $00
.ty: 
	!byte $00
; ---------------------------------------------------
; ------- MY EXTERNAL DEPENDENCIES FILES ------------
!src "mylib/clr.asm"

	
	