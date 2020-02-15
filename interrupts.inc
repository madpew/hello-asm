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



SECTION "VSYNC", ROM0
intVBlank:

	push af
	push bc
	push hl

	; setup OAM-DMA routine in High Ram
	ld c, $80
	ld b, 12
	ld hl, dmacode
.loop:
	ld a, [hli]
	ld [c], a
	inc c
	dec b
	jr nz, .loop	
	
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
	xor a
	set IEF_VBLANK, a
	ld [intFlags], a
	
	
	pop hl
	pop bc
	pop af
	
	reti
	
; short code fragment that gets loaded into hiram to initiate dma-transfer
; $c0 is the location to copy from	
dmacode:
	;db	$3e, $c0, $e0, $46, $3e, $28, $3d, $20, $fd, $c9
	db $f3, $3e, $c0, $e0, $46, $3e, $38, $3d, $20, $fd, $fb, $c9 ;safer version with disabled interrupts
	;extended wait from $28 to $38

SECTION "HSYNC", ROM0
intLCDC:

	push af

	;check scene
	;ld a, [currentScene]
	;cp 0
	;jp nz, .done
	
	ld a, [rLY]
	cp a, 100
	jp nc, .done
	
	ld a, [rOBP0]
	xor a, $FF
	ld [rOBP0], a
	
.done: 
	pop af

	reti
