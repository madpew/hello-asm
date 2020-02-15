SECTION "UTILS", ROM0

turnScreenOffSafe:
	; wait for vblank
    ld  a, [rSTAT]   
    and STATF_BUSY  
    jr  nz,@-4
    
    ; turn if off
	ld      a, [rLCDC]
    res     7, a
    ld      [rLCDC], a
	ret

; HL - memory position of the start of the copying source
; DE - memory position of the start of the copying destination
; BC - the number of bytes to be copied
memCopy:
    inc b
    inc c
    jr  .skip
.loop:
    ld a, [hl+]
    ld [de], a
    inc de
.skip:
    dec c
    jr  nz, .loop
    dec b
    jr nz, .loop
    ret

clearSprites:
	ld hl, oamstart
	ld b, 160
	xor a
.loop:
	ldi [hl], a
	dec b
	jp nz, .loop	
	ret

; a contains duration
BurnWait:
	ld b, a
.WaitLoop:	
	xor a
	ld [rDIV], a
.DivReady:
	ld a, [rDIV]	
	bit 7, a
	jp z, .DivReady
	dec b
	jp nz, .WaitLoop
	ret
	
slowFadeOut:

	ld d, 4

.fadeLoop:	
	ld a, [rBGP]
	sla a
	sla a
	ld [rBGP], a
	
	ld a, [rOBP0]
	sla a
	sla a
	ld [rOBP0], a
	
	ld a, [rOBP1]
	sla a
	sla a
	ld [rOBP1], a
	
	ld a, 64
	call BurnWait
	
	dec d
	jp nz, .fadeLoop
	
	ret