; load window tiles
	;ld hl, WindowTileData
	;ld bc, WINDOW_TILE_LENGTH
	;don't reset de, as it still points to the next tile location
	;call MemCopy

;fix block
	;ld e, CONCEPT_TILE_COUNT
	;ld hl, _SCRN1
	;ld bc, 32*3
	;call MemFixOffset

    	; load window content
	ld de, CatHudMapData
	ld hl, _SCRN1
	ld bc, CATHUD_MAP_SIZE
	call MemCopyBlock

; RAIN (just a simple test effect to have objects around while testing)
; fills up unused sprites with raindrops that get moved to the bottom of the screen (and reset)
; todo: fix bug, make sure it doesn't scroll other (non rain) sprites
; note: for real rain, make the y-limit dynamic (random) and add splashes on removal to simulate them hitting the floor
DoRainFx:
	ld hl, wShadowOam
	ld b, 40
.next:
	xor a
	cp a, [hl]
	jr z, .doit

	ld a, 144+15
	cp a, [hl]
	jr nc, .skip

.doit:
	ld a, 1
	ld [hli], a

	ldh a, [rDIV]
	ld c, a
	ldh a, [rTIMA]
	add a, c
	add a,l
	ld [hli], a

	ld a, 48 ; raindrop sprite
	ld [hli], a

	xor a
	ld [hli], a
	
	jp .spriteMoveDone ; .done

.skip:
	ld a, [hl]
	inc a 
	inc a
	inc a
	inc a
	ld [hli], a
	ld a, [hl]
	inc a
	ld [hli], a
	ld a, [hli]
	ld a, [hli]
.done:	
	dec b
	jr nz, .next
.spriteMoveDone:
	ret




;call DoRainFX

	; A - flip palette
	ld b, KEY_A
	call CheckKeyPressed
	jr z, .noFlash

	ld a, [wPaletteBg]
	xor $ff
	ld [wPaletteBg], a

	call GetNextRandom

.noFlash:

	; LEFT - scroll background
	ld b, KEY_LEFT
	call CheckKeyHeld
	jr z, .noScrollLeft
	ld a, [wCamScrollX]
	dec a
	ld [wCamScrollX], a
.noScrollLeft:

	; RIGHT - scroll background
	ld b, KEY_RIGHT
	call CheckKeyHeld
	jr z, .noScrollRight
	ld a, [wCamScrollX]
	inc a
	ld [wCamScrollX], a
.noScrollRight:

	; UP - scroll background
	ld b, KEY_UP
	call CheckKeyHeld
	jr z, .noScrollUp
	ld a, [wCamScrollY]
	dec a
	ld [wCamScrollY], a
.noScrollUp:

	; DOWN - scroll background
	ld b, KEY_DOWN
	call CheckKeyHeld
	jr z, .noScrollDown
	ld a, [wCamScrollY]
	inc a
	ld [wCamScrollY], a
.noScrollDown:


; B - spawn a mouse at a random location
	ld b, KEY_B
	call CheckKeyPressed
	jr z, .noSpawn

	ldh a, [rDIV]
	ld hl, wShadowMap
	ld b, 0
	ld c, a
	add hl, bc
	
	ld a, 46 ; mouse
	ld [hl], a

	ld a, $ff
	ld [wShadowMapUpdate], a
.noSpawn:


	; SELECT - Toggle Window
	ld b, KEY_SELECT
	call CheckKeyPressed
	jr z, .noToggleWindow

	ldh a, [rLCDC]
	and LCDCF_WINON
	jr nz, .turnOffWindow

	; window setup could be made during init
	; also it might be a good idea to animate the window scrolling in from the bottom?
	ld a, 7
	ldh [rWX], a

	ld a, 144-8
	ldh [rWY], a

	ldh a, [rLCDC]
	or LCDCF_WINON
	ldh [rLCDC], a

	jr .noToggleWindow
.turnOffWindow:	
	ldh a, [rLCDC]
	res 5, a
	ldh [rLCDC], a
.noToggleWindow:


hblank:
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
