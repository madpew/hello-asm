; entry point to load this scene
LoadWinner:
    ;update map
	;load_shadow_map winnerdata, winnersize
	load_shadow_map CatWinMapData, CATWIN_MAP_SIZE
	call ClearAllSprites

	
    ;update score-display	
    ld hl, wShadowMap + 32*4 + 2
    ld c, TILEIDX_NUMBERS
    ld d, $0f

    ld a, [wScoreHighBcd]
    and d
    add a, c
    ld [hli], a

	ld a, [wScoreLowBcd]
    ld b, a
    swap a
    and d
    add a, c
    ld [hli], a

    ld a, b
    and d
    add a, c
    ld [hl], a

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