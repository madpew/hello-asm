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

	ld a, [wFrames]
	ld [wCamScrollX], a
	
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

	ld hl, hello_world_tile_data
	ld bc, hello_world_tile_data_size
	ld de, _VRAM ;$8000
	call MemCopy
	
	ld hl, hello_world_map_data
	ld bc, hello_world_tile_map_size
	ld de, _SCRN0 ;$9800
	call MemCopy
	
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
	sla a
	ld [hli], a

	ld a, 4 ; <3
	ld [hli], a

	xor a
	ld [hli], a
	
	;ret
	jp .done

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