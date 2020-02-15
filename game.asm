SECTION	"GAME", ROM0

; currentScene enum
SCENE_INTRO EQU 0
SCENE_MENU EQU 1

gameInit:
	; do whatever is required, then jump to 
	
	xor a ; load scene 0
	jp gameOnLoadScene

gameOnLoadScene: ;a is the scenenumber to load

	cp SCENE_INTRO
	call z, loadScene0
	
	;cp SCENE_MENU
	;call z, 
		
	jp gameloop
		
gameOnVBlank:

	ld a, [timeFrames]
	ld [camScrollX], a
	
	; setSprite 0,[timeTickCounter],100,1,0
	
	ld a, [currentScene]
	cp 0
	call z, tickIntro
	
	jp gameloop

; =============================
	
loadScene0:
	;load SCENE_INTRO
	di
	call turnScreenOffSafe

	ld hl, hello_world_tile_data
	ld bc, hello_world_tile_data_size
	ld de, _VRAM ;$8000
	call memCopy
	
	ld hl, hello_world_map_data
	ld bc, hello_world_tile_map_size
	ld de, _SCRN0 ;$9800
	call memCopy
	
	ei
	ret

tickIntro:

	ld hl, oamstart
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
	sla a
	ld [hli], a

	ld a, 4 ; <3
	ld [hli], a

	xor a
	ld [hli], a
	
	ret
	;jp .done

.skip:
	ld a, [hl]
	inc a 
	inc a
	ld [hli], a
	ld a, [hli]
	ld a, [hli]
	ld a, [hli]
.done	
	dec b
	jr nz, .next

	ret