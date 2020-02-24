BALL_SPEED EQU 2


SpawnPlayerBall:
    ;find free ball-sprite slot
    ;set sprite Position & wBallDirection
    
    ld e, 1     ;mask
    ld bc, 4    ;increaser
    ld hl, wBallSprites
.nextSlot:
    ld a, [hl]
    and a
    jr nz, .advanceBall

    ;found an empty slot
    ld a, PLAYER_Y - 2
    ld [hli], a
    ld a, [wPlayerX]
    add a, 16 + 2
    ld [hli], a
    ld a, TILEIDX_BALL
    ld [hli], a
    xor a
    ld [hli], a

    ld a, [wBallDirection]
    or e
    ld [wBallDirection], a 
    call SfxThrow
    ret
.advanceBall:
    add hl, bc
    sla e
    jr nz, .nextSlot
    ret

; @param D EnemyX Position
SpawnEnemyBall:
    ;find free ball-sprite slot
    ;set sprite Position & wBallDirection
    ld e, 1     ;mask
    ld bc, 4    ;increaser
    ld hl, wBallSprites
.nextSlot:
    ld a, [hl]
    and a
    jr nz, .advanceBall

    ;found an empty slot
    ld a, ENEMY_Y + 2
    ld [hli], a
    ld a, d 
    add a, 16 + 2
    ld [hli], a
    ld a, TILEIDX_BALL
    ld [hli], a
    xor a
    ld [hli], a

    ld a, [wBallDirection] ;double xor to set the bit to 0
    xor $ff
    or e
    xor $ff
    ld [wBallDirection], a 
    call SfxThrow
    ret
.advanceBall:
    add hl, bc
    sla e
    jr nz, .nextSlot
    ret

UpdateBalls:
    ld a, [wBallDirection]
    ld d, a
    ld e, 1     ;e ball mask
    ld bc, 4    ;increaser
    ld hl, wBallSprites

.nextBall:
    ld a, [hl]
    and a
    jr z, .advanceBall
    ;check ball direction
    ld a, d
    and e
    jr z, .moveDown
.moveUp:
    ld a, [hl]
    sub a, BALL_SPEED
    ld [hl], a
    jr .checkCollisions
.moveDown:
    ld a, [hl]
    add a, BALL_SPEED
    ld [hl], a

.checkCollisions:
    ;collision check, a = ball Y

    ;check top wall
    cp a, 40
    jr nc, .topCheckPassed
    xor a
    ld [hl], a
    call SfxMiss
.topCheckPassed:

    ;check bottom collision (player or wall) also catching!
    cp a, PLAYER_Y
    jr c, .bottomCheckPassed

    ;push bc ; we need some registers to work with
    inc hl ;advance to ballX
    ld a, [wPlayerX]
    sub a, 8    
    cp a, [hl]
    jr nc, .ballMissed ; playerX - 8 > ballX, the ball missed

    ld a, [wPlayerX]
    add a, 16 + 8 ;offset for arm    
    cp a, [hl]
    jr c, .ballMissed ; playerX < ballX, the ball missed

    ld a, [wPlayerX]
    add a, 16
    cp a, [hl]
    jr nc, .ballHit ; playerX +16 > ballX, the ball hit

    ; check if catching, else ballMiss
.catchCheck:
    ld a, [wPlayerFlags]
    and PLAYER_CATCH
    jr z, .ballMissed

    ;we're catching and the ball hit the arm
    or PLAYER_HASBALL
    ld [wPlayerFlags], a

    ;clear ball
    dec hl
    xor a
    ld [hl], 0

    call SfxCatch
    call UpdateHUDBallStatus

    jr .bottomCheckDone
.ballHit:
    dec hl
    xor a
    ld [hl], 0
    call PlayerHit
    jr .bottomCheckDone
.ballMissed:
    dec hl
    xor a
    ld [hl], a
    call SfxMiss
.bottomCheckDone:
    ;pop bc
.bottomCheckPassed:
    
.advanceBall:
    add hl, bc
    sla e
    jr nz, .nextBall

    ret