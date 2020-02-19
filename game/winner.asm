; entry point to load this scene
LoadWinner:
    ;update map
	;load_shadow_map winnerdata, winnersize
	load_shadow_map CatWinMapData, CATWIN_MAP_SIZE
	
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