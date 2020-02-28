; entry point to load this scene
LoadLogo:
	di 

    ;copy ball tile
	ld hl, GfxTileData + TILEIDX_BALL * 16
	ld bc, 16
	ld de, _VRAM + $1A * 16
	call MemCopy

    ;copy 4 cat tiles
    ld hl, GfxTileData + TILEIDX_FACELEFTUP * 16
	ld bc, 64
	ld de, _VRAM + $1B * 16
	call MemCopy

    ;balls
    set_sprite 0, 16+8*8, 0, $1A, 0
    set_sprite 1, 16+8*9, 252, $1A, 0

    ;cat
    set_sprite 2, 16+144, 7+64, $1D, 0
    set_sprite 3, 16+144, 7+72, $1B, 0
    set_sprite 4, 16+144, 7+80, $1C, 0
    set_sprite 5, 16+144, 7+88, $1E, 0
    
    xor a
    ld [wAnimationFlags], a

    call TurnScreenOn
    ei
	ret

; entry point each frame
; do vblank stuff first
TickLogo:

; update flying balls
    ; update sprite position
    ld hl, wShadowOam + 1
    ld a, [hl]
    add a, 4
    ld [hl], a

    ; calculate and clear underlying tile
    ld c, a
    ld d, a
    ld b,0
    srl c   
    srl c   
    srl c

    ld hl, _SCRN0 + 32*8-1
    add hl, bc
    call MemSetHBlank

    ; turn off sprite if it passed the screen
    ld a, d
    and a
    jr nz, .keep1
    clear_sprite 0
.keep1:

    ; update sprite position
    ld hl, wShadowOam + 1 + 4
    ld a, [hl]
    sub a, 4
    ld [hl], a

    ; calculate and clear underlying tile
    ld c, a
    ld d, a
    ld b,0
    srl c   
    srl c   
    srl c
    ld hl, _SCRN0 + 32*9
    add hl, bc
    call MemSetHBlank

    ; turn off sprite if it passed the screen
    ld a, d
    and a
    jr nz, .keep2
    clear_sprite 1
.keep2:

; move cat up
    ld a, [wAnimationFlags]
    ld d, a
    bit 0, d
    jr z, .noMoveUp
    ld a, [wFrames]
    and %00000001
    jr nz, .noMoveUp
    ld bc, 4
    ld hl, wShadowOam + 8
    dec [hl]
    add hl, bc
    dec [hl]
    add hl, bc
    dec [hl]
    add hl, bc
    dec [hl]
    add hl, bc

.noMoveUp:

; move cat down    
    bit 1, d
    jr z, .noMoveDown
    ld a, [wFrames]
    and %00000001
    jr nz, .noMoveDown
    ld bc, 4
    ld hl, wShadowOam + 8
    inc [hl]
    add hl, bc
    inc [hl]
    add hl, bc
    inc [hl]
    add hl, bc
    inc [hl]
    add hl, bc
.noMoveDown:

; animation state timeline (set animation flags according to passed framecount)
    ld a, [wFrameCounter]

    cp 1
    jr nz, .skipSfxThrow1
    call SfxThrow
    ret
.skipSfxThrow1

    cp 30
    jr nz, .skipSfxThrow2
    call SfxThrow
    ret
.skipSfxThrow2

    cp 50
    jr nz, .skipCatUp
    ld a, [wAnimationFlags]
    set 0, a
    ld [wAnimationFlags], a
    ret
.skipCatUp

    cp 66
    jr nz, .skipCatStop
    ld a, [wAnimationFlags]
    res 0, a
    ld [wAnimationFlags], a
    ret
.skipCatStop

    cp 75
    jr nz, .skipCatMew
    call SfxMew
    ret
.skipCatMew

    cp 110
    jr nz, .skipCatDown
    ld a, [wAnimationFlags]
    res 0, a
    set 1, a
    ld [wAnimationFlags], a
    ret
.skipCatDown

    ;finish condition
    cp 150
    ret nz    
	
    music_play MusicMenuStartSongData, MUSICMENUSTART_SPEED
    
    switch_scene SCENE_INTRO
	ret