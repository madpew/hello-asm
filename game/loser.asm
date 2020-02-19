; entry point to load this scene
; needs to jump back to GameLoop
LoadLoser:
    ;update map
	;load_shadow_map loserdata, losersize

	ret

; entry point each frame
; needs to jump back to GameTickDone
; do vblank stuff first
TickLoser:

	is_key_pressed KEY_START
	ret z

    switch_scene SCENE_INTRO
	ret