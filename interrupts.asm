SECTION	"INT_Vblank",ROM0[$0040]
	jp intVBlank
	
SECTION	"INT_LCDC",ROM0[$0048]
	jp intLCDC

SECTION	"INT_Timer_Overflow",ROM0[$0050]
	reti

SECTION	"INT_Serial",ROM0[$0058]
	reti
	
SECTION	"INT_p1thru4",ROM0[$0060]
	reti



SECTION "VBLANK", ROM0

; setup OAM-DMA routine in high ram
initDMA:

	ld c, $80
	ld b, 10
	ld hl, dmacode
.loop:
	ld a, [hli]
	ld [c], a
	inc c
	dec b
	jr nz, .loop
	
	ret


dmacode:
	; $c000 is the location to copy from (shadow oam)
	
	ld a, $c0
	ld [rDMA], a
	
	ld a, 40
	
.waitDMA:
	dec a
	jr nz, .waitDMA
	
	ret
	
intVBlank:

	push af
	push bc
	push hl

	; dma-update OAM
	call $ff80
	
	; update palettes
	ld a, [paletteBg]
	ld [rBGP], a
	
	ld a, [paletteObj0]
	ld [rOBP0], a
	
	ld a, [paletteObj1]
	ld [rOBP1], a
	
	; reset/update scroll
	ld a, [camScrollX]
	ld [rSCX], a
	ld a, [camScrollY]
	ld [rSCY], a
	
	;set vblank flag
	ld a, [intFlags]
	set IEF_VBLANK, a
	ld [intFlags], a
	
	pop hl
	pop bc
	pop af
	
	reti
	


SECTION "HSYNC", ROM0
intLCDC:

	push af

	;check scene
	;ld a, [currentScene]
	;cp 0
	;jp nz, .done
	
	ld a, [rLY]
	cp a, 140
	jr nc, .done ; exit if we're past line 140
	
	
	cp a, 92+16
	jr c, .done ; LY < cmp 
	;LY > 92+16
	ld a, %01000100
	ld [rOBP0], a
	
.done: 
	pop af

	reti
