SECTION	"INT_Vblank",ROM0[$0040]
	jp InterruptVBlank
	
SECTION	"INT_LCDC",ROM0[$0048]
	jp InterruptLCDC

SECTION	"INT_Timer_Overflow",ROM0[$0050]
	reti

SECTION	"INT_Serial",ROM0[$0058]
	reti
	
SECTION	"INT_p1thru4",ROM0[$0060]
	reti


SECTION "OAM DMA", HRAM
hOAMDMA:
	ds 8

SECTION "VBLANK", ROM0

; setup OAM-DMA routine in high ram
InitializeDMA:
	ld16 bc, DMACodeEnd - DMACode, LOW(hOAMDMA)	;= ld bc, (DMACodeEnd - DMACode) << 8 | LOW(hOAMDMA)
	ld hl, DMACode
.loop:
	ld a, [hli]
	ldh [c], a
	inc c
	dec b
	jr nz, .loop
	
	ret

DMACode:
	ld a, HIGH(wShadowOam)
	ldh [rDMA], a
	ld a, 40
	
.waitDMA:
	dec a
	jr nz, .waitDMA
	
	ret
DMACodeEnd:

SHADOWMAP_CHUNKS EQU 9
SHADOWMAP_CHUNK_SIZE EQU 64

InterruptVBlank:

	push af
	push hl

	; copy shadow-OAM to OAM using DMA
	call hOAMDMA
	
	; copy shadow-map to map
	ld a, [wShadowMapUpdate]
	and a
	jr z, .shadowMapUpdateDone

	push bc
	push de

	ld hl, 0
	ld bc, SHADOWMAP_CHUNK_SIZE
	ld a, [wShadowMapCopyLine]
	inc a
	jr .nextOffset
.offset:
	add hl, bc
.nextOffset:
	dec a
	jr nz, .offset

	ld b, h
	ld c, l
	;bc is now the offset
	
	ld hl, _SCRN0
	add hl, bc
	ld d, h
	ld e, l

	ld hl, wShadowMap
	add hl, bc

	ld bc, SHADOWMAP_CHUNK_SIZE
	call MemCopy

	;update line counter
	ld a, [wShadowMapCopyLine]
	inc a
	ld [wShadowMapCopyLine], a

	pop de
	pop bc

	;check if we're done
	cp SHADOWMAP_CHUNKS
	jr nz, .shadowMapUpdateDone

	;finished, set update and line to 0	
	xor a
	ld [wShadowMapCopyLine], a
	ld [wShadowMapUpdate], a

.shadowMapUpdateDone:

	; update palettes
	ld a, [wPaletteBg]
	ldh [rBGP], a
	
	ld a, [wPaletteObj0]
	ldh [rOBP0], a
	
	ld a, [wPaletteObj1]
	ldh [rOBP1], a
	
	; reset/update scroll
	ld a, [wCamScrollX]
	ldh [rSCX], a
	ld a, [wCamScrollY]
	ldh [rSCY], a

	ldh a, [rLCDC]
	res 3, a
	ldh [rLCDC], a
	
	;set vblank flag
	ld hl, wInterruptFlags
	set IEF_VBLANK, [hl]

	pop hl
	pop af
	
	reti
	
SECTION "HSYNC", ROM0
InterruptLCDC:
	push af
	
	ld a, [wCurrentScene]
	cp 2 ;scene game
	jr nz, .done
	
	;switch screens
	ldh a, [rLCDC]
	set 3, a
	ldh [rLCDC], a

	ld a, 132
	ldh [rSCY], a

.done:
	pop af

	reti