!cpu 6502
!to "int01.prg",cbm

!src "mylib/write.asm"

* = $0801                               ; BASIC starts at #2049
!byte $0d,$08,$dc,$07,$9e,$20,$34,$39   ; BASIC to load $c000
!byte $31,$35,$32,$00,$00,$00           ; inserts BASIC line: 2012 SYS 49152
* = $c000     				            ; start address for 6502 code

!zone main

;--- MAIN
init: 
	jsr clr
	
	sei		;disable interrupts to avoid them while changing ptrs	
		
	;init raster interruptions	
	lda #$7f	; flags to disable CIA irqs	
	sta $dc0d	; set'em	
		
	lda $d01a 	; activate raster irq	
	ora #$01	;	
	sta $d01a	
		
	lda $d011	; del raster MSB (current raster line bit 8)
	and #$7f
	sta $d011
	
	lda .rasterLine 	; set raster line
	sta $d012	; LSB could be anithing here
		
	;init interuptions	
	lda #<intcode	; change interrupt addr ptr
	sta $0314	
	lda #>intcode	
	sta $0315	
	cli		;enable interrupts again	
	
mainLoop:			; endless loop
	jmp mainLoop	

mainFrame:
	inc $d020
	inc $d021
	inc .color
	
	+write .text,.color, .tx, .ty

	rts
	;jmp mainLoop	

; ----- OUR SUPER INTERRUPTION RUTINE
intcode:
	jsr mainFrame
	
	;lda #$ff	; no optimizada
	;sta $d019
	
	inc $d019	; optimizada
	
	lda .rasterLine		; set raster line again
	sta $d012
	
	jmp $ea31 

; variables
.text:
    !scr "| - hello world - |"
    !byte $00   ; --- must end with a null
.color:
	!byte 1

.rasterLine
	!byte 0
	
; currently not used
.tx
	!byte 0
.ty
	!byte 0

	
; ---------------------------------------------------
; ------- MY EXTERNAL DEPENDENCIES FILES ------------
!src "mylib/clr.asm"

	
	