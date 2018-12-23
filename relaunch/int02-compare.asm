!cpu 6502
!to "int02-compare.prg",cbm

* = $0801                               ; BASIC starts at #2049
!byte $0d,$08,$dc,$07,$9e,$20,$34,$39   ; BASIC to load $c000
!byte $31,$35,$32,$00,$00,$00           ; inserts BASIC line: 2012 SYS 49152
* = $c000     				            ; start address for 6502 code


; C&P from https://mscifu.wordpress.com/2018/04/15/interrupciones-por-raster-basico/
COLOUR1 = 0
COLOUR2 = 1
LINE1 = 20
LINE2 = 150

main:

	sei                           ; Todo esto es lo mismo que 
				      ; en ejemplos anteriores

	lda #$7f
	sta $dc0d

	lda $d01a
	ora #$01
	sta $d01a

	lda $d011
	and #$7f
	sta $d011

	lda #LINE1
	sta $d012 

	lda #<intcode
	sta 788      
	lda #>intcode
	sta 789

	cli          
	;rts          

loop:
	jmp loop

intcode:

	lda modeflag                  ; vemos si estamos en la parte
	                              ; superior o inferior
	beq mode1 		      ; de la pantalla
	jmp mode2

mode1:

	lda #$01                  ; invertimos el modeflag
	sta modeflag		  ; para que la proxima vez vaya a 
				  ; la otra parte del codigo
	
	ldx COLOUR1                  ; ponemos color 
	inx
	stx COLOUR1
	sta $d020

	lda LINE1                    ; seteamos nuevamente la
	sta $d012                     ; linea de interrupción

	inc $d019		 ; acusamos recibo de interrupción

	jmp $ea31                     ; esta parte va a las rutinas 
				      ; del kernel en ROM

mode2:
	lda #$00                      ; invertimos el modeflag
	sta modeflag

	ldx COLOUR2                  ; ponemos el color
	inx
	stx COLOUR2
	sta $d020

	lda LINE2                    ; seteamos linea de raster
	sta $d012                     


	; lda $#ff		      ; interesante en este ejemplo
	; sta $d019                  ; la diferencia de usar 
				      ; uno u otro metodo.

	inc $d019		      ; acusamos recibo


				  ; PEEERO: 
	pla                       ; Aqui salimos completamente
	tay                       ; esta es la forma de salir de la
	pla                       ; interrupción, restaurando
	tax                       ; los registros.
	pla           ; lo explico con mas detalle a continuación
	rti

modeflag: 
	!byte 0