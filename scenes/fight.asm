PLAYER_Y EQU 120+16
ENEMY_Y EQU 16+24

SPRITE_ARM EQU      2
SPRITE_ARM2 EQU     3

PLAYER_HIT EQU      %00000001
PLAYER_HASBALL EQU  %00000010
PLAYER_CATCH EQU    %00000100
PLAYER_THROWING EQU %00001000
PLAYER_GAMEOVER EQU %10000000

include "game/balls.asm"
include "game/ai.asm"

; entry point to load this scene
LoadFight:

    load_shadow_map CatGroundMapData, CATGROUND_MAP_SIZE
    call ClearAllSprites
    call SfxMew ;test sound

    ; init game state
    ld a, 80
    ld [wPlayerX], a

    ld a, 7
    ld [wLives], a
    
    ld a, $99
    ld [wTime], a

    ld a, PLAYER_HASBALL
    ld [wPlayerFlags], a

    ld a, 0
    ld [wScoreLowBcd], a
    ld [wScoreHighBcd], a
    ld [wHitEffectCounter], a
    ld [wBallDirection], a

    ld [wEnemy1X], a
    ld [wEnemy1Timer], a
    ld [wEnemy1State], a

    ld [wEnemy2X], a
    ld [wEnemy2Timer], a
    ld [wEnemy2State], a

    set_sprite  0, PLAYER_Y, 100, TILEIDX_PLAYERLEFT, 0
    set_sprite  1, PLAYER_Y, 100+8, TILEIDX_PLAYERRIGHT, 0
    set_sprite  SPRITE_ARM, 144+16, 100+16, TILEIDX_PAWRIGHT, 0
    set_sprite  SPRITE_ARM2, 144+16, 100-8, TILEIDX_PAWLEFT, 0

	ret

; entry point each frame
; do vblank stuff first
TickFight:

    ;code that runs every frame
    ;update player sprites
    ld a, [wPlayerX]
    ld d, 8
    ld bc, 4
    ld hl, wShadowOam + 1
    ld [hl], a
    add hl, bc
    add a, d
    ld [hl], a
    add hl, bc
    add a, d
    ld [hl], a


    ;reset player flags
    ld a, PLAYER_THROWING | PLAYER_CATCH
    xor $ff
    ld b, a
    ld a, [wPlayerFlags]
    and b
    ld [wPlayerFlags], a


    ;scroll sky
    ld a, [wFrames]
    and %00000011
    jr nz, .noScrollSky
    ld hl, _VRAM
	call ScrollTileRightHBlank

.noScrollSky:

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

    ; update timer
    ld a, [wFrames]
    and $3F ; 63
    jr nz, .noTimerUpdate
    ld a, [wTime]
    dec a
    daa 
    ld [wTime], a
    jr nz, .noTimeUp
    switch_scene SCENE_WIN
    ret
.noTimeUp:
    ;update time display
    ld b, a
    ld hl, wShadowMap + 9
    ld c, TILEIDX_NUMBERS
    ld d, $0f

    swap a
    and d
    add a, c
    ld [hli], a

    ld a, b
    and d
    add a, c
    ld [hl], a

.noTimerUpdate:

    
IF DEBUG
    is_key_pressed KEY_START
    jr z, .noStart
    ld a, 80
    ld d, a
    call SpawnEnemyBall
.noStart:    


    is_key_pressed KEY_SELECT
    jr z, .noSelect
    ld a, [wPlayerFlags]
    or PLAYER_HASBALL
    ld [wPlayerFlags], a
.noSelect:    
ENDC

    ; branch according to player state

    ld a, [wPlayerFlags]
    and PLAYER_HIT
    jp nz, .skipInput
    
    is_key_held KEY_B
    jr z, .notThrow
    
    ld a, [wPlayerFlags]
    set 3, a ; throwing
    ld [wPlayerFlags], a

    ; check if has ball
    ld a, [wPlayerFlags]
    bit 1, a ;hasball
    jr z, .noThrow

    res 1, a ; hasball no more
    ld [wPlayerFlags], a
    
    ; launch projectile
    call SpawnPlayerBall

    ;update hud
    call updateHUDBallStatus
    jr .noThrow
.notThrow:
.noThrow:   

    is_key_held KEY_A
    jr z, .noCatch
    ld a, [wPlayerFlags]
    or PLAYER_CATCH
    ld [wPlayerFlags], a
.noCatch:   

    ;check for ARM display
.checkArm:
    ld a, [wPlayerFlags]
    and PLAYER_THROWING | PLAYER_CATCH
    jr z, .noArm

    ld a, PLAYER_Y
	ld [wShadowOam + SPRITE_ARM * 4], a
	
	ld a, [wPlayerX]
    add a, 16
	ld [wShadowOam + 1 + SPRITE_ARM * 4], a

    jr .armCheckDone
.noArm
	ld [wShadowOam + SPRITE_ARM * 4], a
.armCheckDone:

;TESTING
  is_key_pressed KEY_UP
    jr z, .noUp

    ;increase score
    ld a, [wScoreLowBcd]
    add a, 4 ;debug add 4 each click
    daa
    ld [wScoreLowBcd], a
    ld b, a
    ld a, [wScoreHighBcd]
    jr nc, .scoreIncDone
    inc a
.scoreIncDone:
    ld [wScoreHighBcd], a

    ;update score-display
    ld hl, wShadowMap + 32*17 + 16
	call PrintScore
.noUp:   


    is_key_held KEY_LEFT
    jr z, .noLeft
    ld a, [wPlayerX]
    cp a, 16
    jr z, .noLeft
    dec a
    ld [wPlayerX], a
.noLeft:    

    is_key_held KEY_RIGHT
    jr z, .noRight
    ld a, [wPlayerX]
    cp a, 160-16
    jr z, .noRight
    inc a
    ld [wPlayerX], a
.noRight:  

.skipInput:

    call UpdateBalls

    call AnimateGrass

    ;make the shadow map update every frame    
    xor $ff
    ld [wShadowMapUpdate], a

    ld a, [wPlayerFlags]
    and PLAYER_GAMEOVER
    ret z

    switch_scene SCENE_LOST
    ret
; ====================================================================================================
PlayerHit:
    push af
    push hl
    push bc

    
    ld a, [wPlayerFlags]
    set 0, a
    ld [wPlayerFlags], a

    ld a, [wLives]
    dec a
    ld [wLives], a
    jr nz, .updateLives
    ld a, [wPlayerFlags]
    or PLAYER_GAMEOVER
    ld [wPlayerFlags], a
    jr .hitDone
.updateLives:
    ;a has lives (use as offset)
    ld b, 0
    ld c, a
    ld hl, wShadowMap + 32*17 + 1
    add hl, bc
    ld [hl], TILEIDX_HEARTEMPTY
    call SfxDmg
    ld a, HIT_DURATION
    ld [wHitEffectCounter], a
.hitDone:
    pop bc
    pop hl
    pop af
    ret


;call on catch or throw, inline
updateHUDBallStatus:
    ld b, TILEIDX_ENERGY
    ld a, [wPlayerFlags]
    and PLAYER_HASBALL
    jr nz, .hasBall
    ld b, TILEIDX_ENERGYEMPTY
.hasBall:
    ld hl, wShadowMap + 32*17 + 10
    ld [hl], b

    ret

;Animates the grass
AnimateGrass:
	ld a, [wFrames]
	and %00011111 ; animation speed divider, careful not to sync with shadow-map copy interval or animation will not be visible (more than 16)
	jr nz, .noAnimation
	ld hl, wShadowMap + 32*4
    ld a, [wFrames]
    and a, %00100000
    jr z, .noAnimationShift
    inc hl
.noAnimationShift:
	ld bc, (32*12)/2
	inc b
    inc c
	dec hl
    dec hl
	jr .checkNext
.animate:
	ld a, [hl]
	cp a, 85
	jr nz, .check86
	inc a
	ld [hl], a
	jr .checkNext
.check86	
	cp a, 86
	jr nz, .checkNext
	dec a
	ld [hl], a

.checkNext:	
	inc hl
    inc hl
	dec c
	jr nz, .animate
	dec b
	jr nz, .animate
.animationDone:
.noAnimation:
	ret 