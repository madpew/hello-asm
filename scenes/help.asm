; entry point to load this scene
LoadHelp:
	
	load_shadow_map CatTutorialMapData, CATTUTORIAL_MAP_SIZE
	call ClearAllSprites
	ret

; entry point each frame
; do vblank stuff first
TickHelp:

    ;scroll bg tile
	ld hl, _VRAM
	call ScrollTileRightHBlank

    is_key_released KEY_SELECT
	ret z

	switch_scene SCENE_INTRO

	ret