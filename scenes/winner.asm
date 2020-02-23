; entry point to load this scene
LoadWinner:
    ;update map
	;load_shadow_map winnerdata, winnersize
	load_shadow_map CatWinMapData, CATWIN_MAP_SIZE
	call ClearAllSprites

    ld hl, wShadowMap + 32*4 + 2
	call PrintScore
    
	ret

; entry point each frame
; do vblank stuff first
TickWinner:
  	;scroll bg tile
	ld hl, _VRAM
	call ScrollTileRightHBlank

	is_key_pressed KEY_START
	ret z

    switch_scene SCENE_INTRO
	ret