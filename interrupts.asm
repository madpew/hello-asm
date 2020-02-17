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
	ld bc, (DMACodeEnd - DMACode) << 8 | LOW(hOAMDMA)
	ld hl, DMACode
.loop:
	ld a, [hli]
	ldh [c], a
	inc c
	dec b
	jr nz, .loop
	
	ret

DMACode:
	ld a, HIGH(wOamStart)
	ldh [rDMA], a
	ld a, 40
	
.waitDMA:
	dec a
	jr nz, .waitDMA
	
	ret
DMACodeEnd:
	
InterruptVBlank:

	push af
	push bc
	push hl

	; dma-update OAM
	call hOAMDMA
	
	; update palettes
	ld a, [wPaletteBg]
	ld [rBGP], a
	
	ld a, [wPaletteObj0]
	ld [rOBP0], a
	
	ld a, [wPaletteObj1]
	ld [rOBP1], a
	
	; reset/update scroll
	ld a, [wCamScrollX]
	ld [rSCX], a
	ld a, [wCamScrollY]
	ld [rSCY], a
	
	;set vblank flag
	ld hl, wInterruptFlags
	set IEF_VBLANK, [hl]
	
	pop hl
	pop bc
	pop af
	
	reti
	


SECTION "HSYNC", ROM0
InterruptLCDC:
	push af

	ld a, [rLY]

	; exit if we're past line 143 to not interfere with vblank
	cp a, 143
	jr nc, .done 

	; turn off sprites when drawing the hud
	cp a, 144-32
	jr nz, .ignoreSpritesOff

	ld a, [rLCDC]
	res 1, a
	ld [rLCDC], a
.ignoreSpritesOff:

.done: 
	pop af

	reti
