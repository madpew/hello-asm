; entry point to load this scene
LoadLoser:

	load_shadow_map CatOverMapData, CATOVER_MAP_SIZE
	call ClearAllSprites

    ;update score-display	
    ld hl, wShadowMap + 32*6 + 7
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
TickLoser:

	;scroll bg tile
	ld hl, _VRAM
	call ScrollTileLeftHBlank
	
	is_key_pressed KEY_START
	ret z

    switch_scene SCENE_INTRO
	ret