!zone write
; ---- CONSTANTS ------------------------
CHARS = $0400
CHARS_HI = $04ff
COLORS = $d800
COLORS_HI = $d8ff

!macro printNum .num {
	ldx .num
	lda .num+1
	jsr $bdcd
}

!macro add16 .num1, .num2, .res {
	clc	
	
	lda .num1	
	adc .num2	
	sta .res	
	
	lda .num1+1	
	adc .num2+1	
	sta .res+1	
}

!macro multiply8to16 .num1, .num2, .res {
	lda #$00	
	tay 	
	sty .res+1	
	beq enterLoop	

doAdd:
	clc
	adc .num1
	tax
	
	tya
	adc .res+1
	tay
	txa
	
loop:
	asl .num1     ; <-
	rol .res+1		
	
enterLoop:
	lsr .num2     ; ->
	bcs doAdd
	bne loop
		
endMult:
	sta .res
	sty .res+1
}

; ----- FUNCTIONS -----------------------
;!macro write .text, .color, .x, .y {    
!macro write .text, .color, .x, .y {    
	; fixed position by now
	;lda #$00
	;sta .pos
	;sta .pos+1
	
	;+multiply8to16 .y, .lineWidth, .res
	
	;lda .x
	;sta .tmp
	;lda #$00
	;sta .tmp+1
	
	;+add16 .res, .tmp, .pos 

	ldx #$00
writeloop:    
    ; if null exit
	lda .text,x    
	cmp #$00
	beq exitWrite
	
	txa
	adc .pos
	tay
	
	lda .text,x
    sta CHARS+40*0,x
    lda .color
    sta COLORS+40*0,x
 
    inx
    jmp writeloop
; --- --- --- ---- ---- --- --- --- --- ---     
;code nver reach this mem pos, then good for vars
.tmp
	!byte $00, $00
.res 
	!byte $00, $00
.pos	
	!byte $00, $00  
.lineWidth:
	!byte $28
    
exitWrite:
	;todo restore registers
	nop
}

