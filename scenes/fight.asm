include "game/balls.asm"
include "game/ai.asm"

; entry point to load this scene
LoadFight:
	di 
    call TurnScreenOff

    load_win CatHudMapData, CATHUD_MAP_SIZE
    load_shadow_map CatGroundMapData, CATGROUND_MAP_SIZE

	ld a, 128
	ldh [rLYC], a

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
    ld [wEnemy1Y], a
    ld [wEnemy1State], a

    ld [wEnemy2X], a
    ld [wEnemy2Y], a
    ld [wEnemy2State], a

    ld [wEnemy3X], a
    ld [wEnemy3Y], a
    ld [wEnemy3State], a

    set_sprite_addr wSpritePlayerLeft, PLAYER_Y, 100, TILEIDX_PLAYERLEFT, 0
    set_sprite_addr wSpritePlayerRight, PLAYER_Y, 100+8, TILEIDX_PLAYERRIGHT, 0
    set_sprite_addr wSpritePlayerPawRight, 144+16, 100+16, TILEIDX_PLAYERPAWRIGHT, 0
    set_sprite_addr wSpritePlayerPawLeft, 144+16, 100-8, TILEIDX_PAWLEFT, 0
    set_sprite_addr wSpritePlayerBall, 144+16, 100+16+2, TILEIDX_BALL, 0

    set_sprite_addr wEnemySprites,      ENEMY_Y + 8, 0, TILEIDX_WALL, 0
    set_sprite_addr wEnemySprites + 4,  ENEMY_Y + 8, 0, TILEIDX_WALL, 0
    set_sprite_addr wEnemySprites + 8,  ENEMY_Y +4, 0, TILEIDX_FACELEFTUP, 0
    set_sprite_addr wEnemySprites + 12, ENEMY_Y +4, 0, TILEIDX_FACERIGHTUP, 0
    set_sprite_addr wEnemySprites + 16, 0, 0, TILEIDX_PAWBALL, 0
    
    set_sprite_addr wEnemySprites + 20, ENEMY_Y + 8, 0, TILEIDX_WALL, 0
    set_sprite_addr wEnemySprites + 24, ENEMY_Y + 8, 0, TILEIDX_WALL, 0
    set_sprite_addr wEnemySprites + 28, ENEMY_Y+7, 0, TILEIDX_FACELEFTUP, 0
    set_sprite_addr wEnemySprites + 32, ENEMY_Y+7, 0, TILEIDX_FACERIGHTUP, 0
    set_sprite_addr wEnemySprites + 36, 0, 0, TILEIDX_PAWBALL, 0

    set_sprite_addr wEnemySprites + 40, ENEMY_Y + 8, 0, TILEIDX_WALL, 0
    set_sprite_addr wEnemySprites + 44, ENEMY_Y + 8, 0, TILEIDX_WALL, 0
    set_sprite_addr wEnemySprites + 48, ENEMY_Y+7, 0, TILEIDX_FACELEFTUP, 0
    set_sprite_addr wEnemySprites + 52, ENEMY_Y+7, 0, TILEIDX_FACERIGHTUP, 0
    set_sprite_addr wEnemySprites + 56, 0, 0, TILEIDX_PAWBALL, 0


    call GetNextRandom
    and %00111111
    ld [wEnemy1Timer], a
    call GetNextRandom
    and %00111111
    ld [wEnemy2Timer], a
    call GetNextRandom
    and %00111111
    ld [wEnemy3Timer], a

    call TurnScreenOn
	ei
	ret


; entry point each frame
; do vblank stuff first
TickFight:

; update player sprites
    ld a, [wPlayerX]
    ld d, 8
    ld bc, 4
    ld hl, wSpritePlayer + 1
    ld [hl], a
    add hl, bc
    add a, d
    ld [hl], a
    add hl, bc ;skip paw right
    add hl, bc
    add a, d
    ld [hl], a
    add hl, bc ;ball sprite
    add a, 2
    ld [hl], a

; update enemy sprites
    ; update X positions
    ld a, [wEnemy1X]
    ld [wEnemySprites + 1], a
    ld [wEnemySprites + 8 + 1], a
    add a, 8
    ld [wEnemySprites + 1 + 4], a
    ld [wEnemySprites + 12 + 1], a
    add a, 8
    ld [wEnemySprites + 16 + 1], a

    ; update Y positions
    ld a, [wEnemy1Y]
    ld [wEnemySprites + 8], a
    ld [wEnemySprites + 12], a


    ; update X positions
    ld a, [wEnemy2X]
    ld [wEnemySprites + 20 + 1], a
    ld [wEnemySprites + 20 + 8 + 1], a
    add a, 8
    ld [wEnemySprites + 20 + 1 + 4], a
    ld [wEnemySprites + 20 + 12 + 1], a
    add a, 8
    ld [wEnemySprites + 20 + 16 + 1], a

    ; update Y positions
    xor a
    ld [wEnemySprites + 20 + 16], a ;make arm invisible
    ld a, [wEnemy2State]
    cp ENEMY_STATE_THROW
    ld a, [wEnemy2Y]
    jr nz, .noEnemy2Arm
    ld [wEnemySprites + 20 + 16], a ;make arm visible
.noEnemy2Arm:
    ld [wEnemySprites + 20 + 8], a
    ld [wEnemySprites + 20 + 12], a



    ; update X positions
    ld a, [wEnemy3X]
    ld [wEnemySprites + 40 + 1], a
    ld [wEnemySprites + 40 + 8 + 1], a
    add a, 8
    ld [wEnemySprites + 40 + 1 + 4], a
    ld [wEnemySprites + 40 + 12 + 1], a
    add a, 8
    ld [wEnemySprites + 40 + 16 + 1], a

    ; update Y positions
    xor a
    ld [wEnemySprites + 40 + 16], a ;make arm invisible
    ld a, [wEnemy3State]
    cp ENEMY_STATE_THROW
    ld a, [wEnemy3Y]
    jr nz, .noEnemy3Arm
    ld [wEnemySprites + 40 + 16], a ;make arm visible
.noEnemy3Arm:
    ld [wEnemySprites + 40 + 8], a
    ld [wEnemySprites + 40 + 12], a
;end of enemy sprites

  
; reset player flags
    ld a, [wFrames]
    and %00000011
    jr nz, .noFlagReset
    ld a, PLAYER_THROWING | PLAYER_CATCH
    xor $ff
    ld b, a
    ld a, [wPlayerFlags]
    and b
    ld [wPlayerFlags], a
.noFlagReset:

; scroll sky
    ld a, [wFrames]
    and %00000011
    jr nz, .noScrollSky
    ld hl, _VRAM
	call ScrollTileRightHBlank
.noScrollSky:

; hit effect
    ld a, [wHitEffectCounter]
    and a
    jr z, .noHitEffect

    dec a
    ld [wHitEffectCounter], a
    jr nz, .doHitEffect

    ;counter just reached 0
    ;reset palette
    ld a, [wPaletteObj1]
    ld [wPaletteBg], a
    ld [wPaletteObj0], a

    ;clear flag
    ld a, [wPlayerFlags]
    res 0, a
    ld [wPlayerFlags], a

    ;check for gameover
.checkGameOver:
    ld a, [wLives]
    and a
    jr nz, .noHitEffect
    
    switch_scene SCENE_LOST
    ret

.doHitEffect:
    ;blink the palette    
    ld a, [wPaletteBg]
    xor a, $ff ;something else here
    ld [wPaletteBg], a
    ld [wPaletteObj0], a
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


; debug input handling    
;IF DEBUG

    is_key_pressed KEY_START
    jr z, .noStart
    call GetNextRandom
    srl a
    ld d, a
    call SpawnEnemyBall
.noStart:    

;ENDC


; skip player input if we're hit
    ld a, [wPlayerFlags]
    and PLAYER_HIT
    jp nz, .skipInput

; Input - Throw  
    is_key_held KEY_B
    jr z, .noThrow
    
    ld a, [wPlayerFlags]
    set 3, a ; throwing
    ld [wPlayerFlags], a

    ; check if has ball
    bit 1, a
    jr z, .noThrow

    res 1, a
    ld [wPlayerFlags], a
    
    ; launch ball
    call SpawnPlayerBall

    ; update hud
    call UpdateHUDBallStatus
.noThrow:   

; Input - Catch (only set flag, actual logic is handled in the collisions)
    is_key_held KEY_A
    jr z, .noCatch
    ld a, [wPlayerFlags]
    or PLAYER_CATCH
    ld [wPlayerFlags], a
.noCatch:   

;will b with speed
    ld b, 2
    ld a, [wPlayerFlags]
    and PLAYER_CATCH
    jr z, .fastMove
    ld b, 1
.fastMove:

; Input - Move Left
    is_key_held KEY_LEFT
    jr z, .noLeft
    call GetNextRandom
    ld a, [wPlayerX]
    sub a, b
    cp a, 16
    jr c, .noLeft
    ld [wPlayerX], a
.noLeft:    

; Input - Move Right
    is_key_held KEY_RIGHT
    jr z, .noRight
    call GetNextRandom
    ld a, [wPlayerX]
    add a, b
    cp a, 160-16
    jr nc, .noRight
    ld [wPlayerX], a
.noRight:  

.skipInput:

; Paw Rendering
.checkArm:
    ld a, [wPlayerFlags]
    and PLAYER_THROWING | PLAYER_CATCH
    jr z, .noArm

    ld a, [wPlayerFlags]
    and PLAYER_HASBALL
    jr z, .noBall

    ld a, PLAYER_Y - 2 
    ld [wSpritePlayerBall], a

.noBall:
    ld [wSpritePlayerBall], a

    ld a, PLAYER_Y
	ld [wSpritePlayerPawRight], a
    jr .armCheckDone
.noArm
	ld [wSpritePlayerPawRight], a
    ld [wSpritePlayerBall], a

.armCheckDone:

    call UpdateBalls

    call UpdateAI

    call AnimateGrass

    ;make the shadow map update every frame    
    xor $ff
    ld [wShadowMapUpdate], a

    ret

; ====================================================================================================

; Updates the player score
PlayerScore:
    push af
    push de
    push hl

    ;increase score
    ld a, [wScoreLowBcd]
    add a, b
    daa
    ld [wScoreLowBcd], a
    ld b, a
    ld a, [wScoreHighBcd]
    jr nc, .scoreIncDone
    inc a
.scoreIncDone:
    ld [wScoreHighBcd], a

    ;update score-display
    ld hl, _SCRN1 + 32 + 16
	call PrintScore
    call SfxHit
    
    pop hl
    pop de
    pop af
    
    ret

; Player got hit by a bullet. Reduce Lives, update HUD, play sound and check for GameOver
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
.updateLives:
    ;a has lives (use as offset)
    ld b, 0
    ld c, a
    ld hl, _SCRN1 + 32 + 1
    add hl, bc
    call WaitVRam
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
UpdateHUDBallStatus:
    push hl
    push bc
    ld b, TILEIDX_ENERGY
    ld a, [wPlayerFlags]
    and PLAYER_HASBALL
    jr nz, .hasBall
    ld b, TILEIDX_ENERGYEMPTY
.hasBall:
    call WaitVRam
    ld hl, _SCRN1 + 32 + 10
    ld [hl], b

    pop bc
    pop hl
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