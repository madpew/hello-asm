; entry point to load this scene
LoadLoser:

	load_shadow_map CatOverMapData, CATOVER_MAP_SIZE

	ret

; entry point each frame
; do vblank stuff first
TickLoser:

	;scroll bg tile
	ld hl, _VRAM
	call ScrollTileLeftHBlank
	
	is_key_pressed KEY_START
	ret z

    switch_scene SCENE_INTRO
	ret