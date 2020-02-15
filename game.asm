SECTION	"GAME", ROM0

; currentScene enum
SCENE_INTRO EQU 0
SCENE_MENU EQU 1
SCENE_GAME EQU 2
SCENE_GAME_WIN EQU 3
SCENE_GAME_OVER EQU 4
SCENE_CREDITS EQU 5

gameInit:
	; do whatever is required, then jump to 
	
	xor a ; load scene 0
	jp gameOnLoadScene
	
gameOnVBlank:
	ld a, [timeFrames]
	ld [camScrollX], a
	
	; setSprite 0,[timeTickCounter],100,1,0
	
	ld a, [currentScene]
	case 0, tickIntro
	
	jp gameloop

	
;gameOnTimer:
	
	;call slowFadeOut

	; random data into oam
	;ld b, 160
	;ld hl, oamstart
;filler:
;	ld a, [hl]
;	ld c, a
;	ld a, [rLY]
;	add c
;	xor b
;	ldi [hl], a
;	dec b
;	jp nz, filler
	
;	jp gameloop
	
gameOnLoadScene: ;a is the scenenumber to load

	case SCENE_INTRO, loadScene0
	
	;seta [paletteBg], %01010100 ; debug only to see a difference
	
	; now actually do something?
	;ld hl, $9904 ;start of the nintendo logo in bg map
	;ld bc, oamstart
	;ld d, 43 ;number of tiles we need to loop over

;.intro_logo_spriteify:
;	ld a, [hl]
;	and a
;	jp z, .intro_logo_spriteify_next
;	ld e, a
	
;	ld a, 80
;	ld [bc], a ;y
 ;   inc c
	
;	ld a, c
;	sla a
;	add a, 36
	
;	ld [bc], a ;x
 ;   inc c
    
  ;  ld a, e
   ; ld [bc], a ;tileid
    ;inc c
    
    ;xor a
    ;ld [bc], a ; attribute
    ;inc c
    ;ld a, e
;.intro_logo_spriteify_next:	
;	ldi [hl], a
;	dec d
;	jp nz, .intro_logo_spriteify
		
	jp gameloop
	
	
loadScene0:
	;load SCENE_INTRO
	di
	call turnScreenOffSafe

	; HL - memory position of the start of the copying source
	; DE - memory position of the start of the copying destination
	; BC - the number of bytes to be copied
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
	jp z, .doit

	ld a, 144+15
	cp a, [hl]
	jp nc, .skip

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
	jp nz, .next

	ret