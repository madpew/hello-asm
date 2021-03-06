; entry point to load this scene
LoadLoser:
	load_shadow_map CatOverMapData, CATOVER_MAP_SIZE
	call ClearAllSprites

    ld hl, wShadowMap + 32*6 + 7
	call PrintScoreText
	ld hl, wShadowMap + 32*6 + 7
	call FixScoreText

	music_play MusicLostSongData, MUSICLOST_SPEED

	ret

; entry point each frame
; do vblank stuff first
TickLoser:

	;scroll bg tile
	ld hl, _VRAM
	call ScrollTileLeftHBlank
	
	is_key_released KEY_START
	ret z

    switch_scene SCENE_INTRO
	ret