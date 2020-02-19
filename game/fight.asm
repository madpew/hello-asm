; entry point to load this scene
LoadFight:

    load_shadow_map CatGroundMapData, CATGROUND_MAP_SIZE
    
    call SoundTest ;test sound

    ; init game state
    ld a, 80
    ld [wPlayerX], a

    ld a, 7
    ld [wLives], a

    ld a, 0
    ld [wScore], a
    ld [wPlayerFlags], a
    ld [wHitEffectCounter], a

	ret

; entry point each frame
; do vblank stuff first
TickFight:

    ;code that runs every frame

    ld a, [wHitEffectCounter]
    and a
    jr z, .noHitEffect

    dec a
    ld [wHitEffectCounter], a
    jr nz, .doHitEffect

    ;counter just reached 0
    ;reset hit flag
    ld a, [wPlayerFlags]
    res 0, a
    ld [wPlayerFlags], a

    ;reset palette
    ld a, [wPaletteObj0]
    ld [wPaletteBg], a
    jr .noHitEffect
.doHitEffect:
    ;blink the palette    
    ld a, [wPaletteBg]
    xor a, $ff ;something else here
    ld [wPaletteBg], a
.noHitEffect:    


    ; update gfx state

    is_key_pressed KEY_START
    jr z, .noWin
    switch_scene SCENE_WIN
.noWin:    

    is_key_pressed KEY_SELECT
    jr z, .noLoose
    switch_scene SCENE_LOST
.noLoose:    


    ; branch according to player state

    ld a, [wPlayerFlags]
    and PLAYER_HIT
    jr nz, .skipInput
    
    is_key_pressed KEY_B
    jr z, .noThrow
    ;throw
.noThrow:   

    is_key_pressed KEY_A
    jr z, .noCatch
    ;catch
    ;debug: set player hit
    call PlayerHit

.noCatch:   

    is_key_pressed KEY_LEFT
    jr z, .noLeft
    ld a, [wPlayerX]
    cp a, 16
    jr z, .noLeft
    dec a
    ld [wPlayerX], a
.noLeft:    

    is_key_pressed KEY_RIGHT
    jr z, .noRight
    ld a, [wPlayerX]
    cp a, 160-16
    jr z, .noRight
    inc a
    ld [wPlayerX], a
.noRight:  

.skipInput:


    ;make the shadow map update every frame    
    xor $ff
    ld [wShadowMapUpdate], a

    ret

PlayerHit:
    ld a, HIT_DURATION
    ld [wHitEffectCounter], a
    
    ld a, [wPlayerFlags]
    set 0, a
    ld [wPlayerFlags], a

    ld a, [wLives]
    dec a
    ld [wLives], a
    jr nz, .updateLives
    switch_scene SCENE_LOST
    ret
.updateLives:
    ;a has lives (use as offset)
    ld b, 0
    ld c, a
    ld hl, wShadowMap + 32*17 + 1
    add hl, bc
    ld [hl], TILEIDX_HEARTEMPTY
    ret