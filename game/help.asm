; entry point to load this scene
; needs to jump back to GameLoop
LoadHelp:
	
	load_shadow_map CatTutorialMapData, CATTUTORIAL_MAP_SIZE
	
	ret

; entry point each frame
; needs to jump back to GameTickDone
; do vblank stuff first
TickHelp:

    is_key_pressed KEY_SELECT
	ret z

	switch_scene SCENE_INTRO

	ret