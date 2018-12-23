!zone clr
clr:    
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
