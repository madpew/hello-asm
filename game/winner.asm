; entry point to load this scene
LoadWinner:
    ;update map
	;load_shadow_map winnerdata, winnersize

	ret

; entry point each frame
; do vblank stuff first
TickWinner:

	is_key_pressed KEY_START
	ret z

    switch_scene SCENE_INTRO
	ret