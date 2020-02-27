; entry point to load this scene
LoadWinner:
    ;update map
	

	ld a, [wScoreHighBcd]
	and a
	jr nz, .winner

	ld a, [wScoreLowBcd]
	swap a
	and $0f
	cp a, 4
	jr nc, .winner

	load_shadow_map CatHarderMapData, CATHARDER_MAP_SIZE
	jr .switchDone
.winner:
	load_shadow_map CatWinMapData, CATWIN_MAP_SIZE
.switchDone:

	call ClearAllSprites

    ld hl, wShadowMap + 32*4 + 2
	call PrintScoreText
	ld hl, wShadowMap + 32*4 + 2
	call FixScoreText

	music_play Music_winSongData, MUSIC_WIN_SPEED

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