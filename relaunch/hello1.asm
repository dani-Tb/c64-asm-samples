!cpu 6502
!to "hello1.prg",cbm

* = $0801                               ; BASIC starts at #2049
!byte $0d,$08,$dc,$07,$9e,$20,$34,$39   ; BASIC to load $c000
!byte $31,$35,$32,$00,$00,$00           ; inserts BASIC line: 2012 SYS 49152
* = $c000     				            ; start address for 6502 code

;---- CONSTANTS ---------------------
BORDER = $d020
BACKGROUND = $d021
CHAR_COLOR = $0286

RASTER = $d012
SCREEN = $0400
COLORS = $d800

;----- MAIN -------------------------
init:
    jsr clr
    
    lda #$04
    sta BORDER
    sta BACKGROUND

    jsr write
	
	lda #25
	sta FRAMECOUNTER
	
mainLoop:
	jsr waitFrame

	jsr changeColors
	;jsr clr
	
    jsr write
    
    jmp mainLoop    

; ------------- SUBROUTINES --------------

text:
    !scr " - - - - - - - hello world - - - - - - - - "

clr:    
    ;lda #$00
    ;tax 
    lda #' '
    ldx #$00
clrloop:    
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    dex
    bne clrloop
    rts

changeColors:
    inc BORDER
    inc BACKGROUND
    inc CHAR_COLOR
    rts
    
write:    
	ldx #$00
	ldy CHAR_COLOR
writeloop:    
    lda text,x    
    sta SCREEN+40*12,x
    tya
    sta COLORS+40*12,x
 
    inx
    iny
    cpx #40
    bne writeloop
    
    rts
; -------------------- SYNC FRAMES ---------------------    
waitFrame:
	lda $d012
	cmp #$f8	
	beq waitFrame
.waitFrameStep2:
	lda $d012
	cmp #$f8
	bne .waitFrameStep2
	
	inc COUNTER
	lda COUNTER
	cmp FRAMECOUNTER
	bne waitFrame
	jsr counterReset
	rts 
	
counterReset:		
	lda #0		
	sta COUNTER		
	rts		
		
COUNTER 	
	!byte 0	

FRAMECOUNTER:
	!byte 0

	