SECTION	"GAME", ROM0

; currentScene enum
SCENE_INTRO EQU 0
SCENE_MENU EQU 1

GameInit:
	; do whatever is required, then jump to 
	
	xor a ; load scene 0
	jr GameLoadScene

GameLoadScene: ;a is the scenenumber to load

	cp SCENE_INTRO
	call z, LoadScene0
	
	;cp SCENE_MENU
	;call z, 

	jp GameLoop
		
GameTick:

	; setSprite 0,[timeTickCounter],100,1,0
	
	ld a, [wCurrentScene]
	cp 0
	call z, TickIntro
	
	ret

; =============================
	
LoadScene0:
	;load SCENE_INTRO
	di
	call TurnScreenOff

	ld hl, ConceptTileData
	ld bc, CONCEPT_TILE_LENGTH
	ld de, _VRAM ;$8000
	call MemCopy

	;load window content
	ld de, GardenMapData
	ld hl, _SCRN1
	lb bc, 20, 3
	call MemCopyBlock

	ld de, IntroMapData
	ld hl, wShadowMap
	ld bc, INTRO_MAP_SIZE ;Test2_width << 8 | Test2_height
	call MemCopyBlock

	ld a, $ff
	ld [wShadowMapUpdate], a

	call TurnScreenOn
	ei
	ret

TickIntro:

	; RAIN (just a simple test effect to have objects around while testing)
	; fills up unused sprites with raindrops that get moved to the bottom of the screen (and reset)
	; todo: fix bug, make sure it doesn't scroll other (non rain) sprites
	; note: for real rain, make the y-limit dynamic (random) and add splashes on removal to simulate them hitting the floor

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

	ld a, [rDIV]
	ld c, a
	ld a, [rTIMA]
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

	; A - flip palette
	ld b, KEY_A
	call CheckKeyPressed
	jr z, .noFlash

	ld a, [wPaletteBg]
	xor $ff
	ld [wPaletteBg], a

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

	; START - copy map data to shadow map, set flagToUpdate
	ld b, KEY_START
	call CheckKeyHeld
	jr z, .noUpdateShadowMap
	ld de, WildernessMapData
	ld hl, wShadowMap
	ld bc, WILDERNESS_MAP_SIZE
	call MemCopyBlock
	ld a, $ff
	ld [wShadowMapUpdate], a
.noUpdateShadowMap:

	; B - spawn a mouse at a random location
	ld b, KEY_B
	call CheckKeyPressed
	jr z, .noSpawn

	ld a, [rDIV]
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

	ld a, [rLCDC]
	and LCDCF_WINON
	jr nz, .turnOffWindow

	; window setup could be made during init
	; also it might be a good idea to animate the window scrolling in from the bottom?
	ld a, 7
	ld [rWX], a

	ld a, 144-24
	ld [rWY], a

	ld a, [rLCDC]
	or LCDCF_WINON
	ld [rLCDC], a

	jr .noToggleWindow
.turnOffWindow:	
	ld a, [rLCDC]
	res 5, a
	ld [rLCDC], a
.noToggleWindow:

	; test bg animation

	;GrassTile Indices 0 / 18 
	ld a, [wFrames]
	and $0f ; animation divider, careful not to sync with shadow-map copy interval or animation will not be visible (more than 16)
	jr nz, .noAnimation

	ld hl, wShadowMap
	ld bc, 1024
	inc b
    inc c
	dec hl
	jr .checkNext
.animate:
	ld a, [hl]
	and $ff
	jr nz, .check18
	; it's 0, replace with 18
	ld a, 18
	ld [hl], a
	jr .checkNext
.check18	
	cp a, 18
	jr nz, .checkNext

	ld a, 0
	ld [hl], a

.checkNext:	
	inc hl
	dec c
	jr nz, .animate
	dec b
	jr nz, .animate
.animationDone:
	ld a, $ff
	ld [wShadowMapUpdate], a
.noAnimation:


	ld hl, _VRAM + 40*16
	call ScrollTileLeftHBlank

	ld hl, _VRAM + 5*16
	call ScrollTileRightHBlank

	ret