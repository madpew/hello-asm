SECTION "UTILS", ROM0

TurnScreenOff:
	; wait for vblank
	ld a, [rSTAT]   
	and STATF_BUSY  
	jr nz, TurnScreenOff

	; turn it off
	ld a, [rLCDC]
	res 7, a
	ld [rLCDC], a
	
	ret

; HL - memory position of the start of the copying source
; DE - memory position of the start of the copying destination
; BC - the number of bytes to be copied
MemCopy:
    inc b
    inc c
    jr .skip
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

ClearAllSprites:
	ld hl, wOamStart
	ld b, 160
	xor a
.loop:
	ldi [hl], a
	dec b
	jr nz, .loop	
	
	ret