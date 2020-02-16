SECTION	"GAME", ROM0

; currentScene enum
SCENE_INTRO EQU 0
SCENE_MENU EQU 1

GameInit:
	; do whatever is required, then jump to 
	
	xor a ; load scene 0
	jp GameLoadScene

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
	
	jp GameLoop

; =============================
	
LoadScene0:
	;load SCENE_INTRO
	di
	call TurnScreenOff

	;ld hl, hello_world_tile_data
	;ld bc, hello_world_tile_data_size
	;ld de, _VRAM ;$8000
	;call MemCopy
	ld hl, concept_tile_data
	ld bc, concept_tile_data_size
	ld de, _VRAM ;$8000
	call MemCopy
	

	ld de, Menu_map_data
	ld hl, _SCRN0
	ld bc, BLOCK_SIZE_SCREEN
	call MemCopyBlock

	;ld hl, Menu_map_data
	;ld bc, Menu_map_data_size
	;ld de, _SCRN0 ;$9800
	;call MemCopy

	
	ei
	ret

TickIntro:

	ld hl, wOamStart
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

	ld a, 5 ; O
	ld [hli], a

	xor a
	ld [hli], a
	
	jp .spriteMoveDone ; .done

.skip:
	ld a, [hl]
	inc a 
	inc a
	ld [hli], a
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
.done:	
	dec b
	jr nz, .next
.spriteMoveDone:

	ld b, KEY_A
	call CheckKeyPressed
	jr z, .noFlash

	ld a, [wPaletteBg]
	xor $ff
	ld [wPaletteBg], a

.noFlash:

	ld b, KEY_LEFT
	call CheckKeyHeld
	jr z, .noScrollLeft
	ld a, [wCamScrollX]
	dec a
	ld [wCamScrollX], a
.noScrollLeft:

	ld b, KEY_RIGHT
	call CheckKeyHeld
	jr z, .noScrollRight
	ld a, [wCamScrollX]
	inc a
	ld [wCamScrollX], a
.noScrollRight:

	ld b, KEY_UP
	call CheckKeyHeld
	jr z, .noScrollUp
	ld a, [wCamScrollY]
	dec a
	ld [wCamScrollY], a
.noScrollUp:

	ld b, KEY_DOWN
	call CheckKeyHeld
	jr z, .noScrollDown
	ld a, [wCamScrollY]
	inc a
	ld [wCamScrollY], a
.noScrollDown:

	ret