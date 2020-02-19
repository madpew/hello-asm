; entry point to load this scene
LoadLoser:
    ;update map
	;load_shadow_map loserdata, losersize

	ret

; entry point each frame
; do vblank stuff first
TickLoser:

	is_key_pressed KEY_START
	ret z

    switch_scene SCENE_INTRO
	ret