; entry point to load this scene
; needs to jump back to GameLoop
LoadIntro:

	di
	call TurnScreenOff

	ld hl, WindowTileData
	ld bc, WINDOW_TILE_LENGTH
	ld de, _VRAM ;$8000
	call MemCopy

	load_shadow_map CatIntroMapData, CATINTRO_MAP_SIZE

	call TurnScreenOn
	ei
	ret

; entry point each frame
; needs to jump back to GameTickDone
; do vblank stuff first
TickIntro:

	; START the game
	is_key_pressed KEY_START
	jr z, .noSwitchGame
	switch_scene SCENE_GAME
	ret
.noSwitchGame:

    ; SELECT the tutorial 
    is_key_pressed KEY_SELECT
	jr z, .noSwitchHelp
    switch_scene SCENE_HELP
	ret
.noSwitchHelp:

	; animate paws
    call AnimateMap

	; wait until LY is past the top-scroller to safely scroll the tiles without getting artefacts
.waitMiddle:
	ldh a, [rLY]
	cp a, 16
	jr c, .waitMiddle

    ;scroll arrow-tiles during hblank
	ld hl, _VRAM + 55*16
	call ScrollTileRightHBlank

	ld hl, _VRAM + 56*16
	call ScrollTileLeftHBlank

	ret

; -----------------
; custom code below


;Animates the paws on the intro screens (alternates left/right tiles)
AnimateMap:
	ld a, [wFrames]
	and $0f ; animation speed divider, careful not to sync with shadow-map copy interval or animation will not be visible (more than 16)
	jr nz, .noAnimation

	ld hl, wShadowMap
	ld bc, 1024
	inc b
    inc c
	dec hl
	jr .checkNext
.animate:
	ld a, [hl]
	cp a, 50
	jr nz, .check51
	inc a
	ld [hl], a
	jr .checkNext
.check51	
	cp a, 51
	jr nz, .checkNext
	dec a
	ld [hl], a

.checkNext:	
	inc hl
	dec c
	jr nz, .animate
	dec b
	jr nz, .animate
.animationDone:
	call QueueShadowUpdate
.noAnimation:
	ret 