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
	lb bc, DMACodeEnd - DMACode, LOW(hOAMDMA)	;= ld bc, (DMACodeEnd - DMACode) << 8 | LOW(hOAMDMA)
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

SHADOWMAP_CHUNKS EQU 32
SHADOWMAP_CHUNK_SIZE EQU 64

InterruptVBlank:

	push af
	push hl

	; copy shadow-OAM to OAM using DMA
	call hOAMDMA
	
	; copy shadow-map to map
	ld a, [wShadowMapUpdate]
	and $ff
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
	cp a, (SHADOWMAP_CHUNKS*32/SHADOWMAP_CHUNK_SIZE)
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
	
	;set vblank flag
	ld hl, wInterruptFlags
	set IEF_VBLANK, [hl]

	pop hl
	pop af
	
	reti
	
SECTION "HSYNC", ROM0
InterruptLCDC:
	reti
	push af

	;ld a, [wLFSR]
	;call GetNextRandom
	;and a, %00000001
	;ldh [rSCX], a
	

	ldh a, [rLY]

	; exit if we're past line 143 to not interfere with vblank
	cp a, 143
	
;line 0, turn on sprites again
	jr nz, .notFirstLine
	ldh a, [rSCX]
	ld [wCamScrollX], a
	ldh a, [rLCDC]
	set 1, a
	ldh [rLCDC], a
	jr .done
.notFirstLine:
	;jr nc, .done 

	; on line 12, turn off the window to split it
	cp a, 12
	jr nz, .skipWindowOff
	ld a, 167
	ldh [rWX], a
	jr .done
.skipWindowOff:

	; if line 144-12 turn window on
	cp a, 144-12
	jr nz, .skipWindowOn
	ld a, 7
	ldh [rWX], a
	jr .done
.skipWindowOn:

	; turn off sprites when drawing the hud
	cp a, 144-32
	jr nz, .ignoreSpritesOff

	ldh a, [rLCDC]
	bit 5, a
	jr z, .ignoreSpritesOff
	res 1, a
	ldh [rLCDC], a
.ignoreSpritesOff:

.done: 

	pop af

	reti
