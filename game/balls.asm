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

; Moves all active balls and checks for collisions/catching
UpdateBalls:
    ld a, [wBallDirection]
    ld d, a
    ld e, 1     ;e ball mask
    ld bc, 4    ;increaser
    ld hl, wBallSprites

.nextBall:
    ld a, [hl]
    and a
    jp z, .advanceBall
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

; TOP WALL collisions
    cp a, 40
    jr nc, .topCheckPassed
    
    call SfxMiss
    inc hl ;it get's dec'd down  there
    jp .removeBall
.topCheckPassed:

; ENEMY COLLISIONS
    cp a, ENEMY_Y+8
    jr nc, .skipEnemyCollision
    cp a, ENEMY_Y
    jr c, .skipEnemyCollision

    ld a, d ; check if ball is moving down
    and e
    jr z, .skipEnemyCollision

    inc hl ; now ballX

; enemy 1 collision check
    ld a, [wEnemy1State]
    and a
    jr z, .noEnemy1Collision

    ld a, [wEnemy1X]
    sub a, 8    
    cp a, [hl]
    jr nc, .noEnemy1Collision

    ld a, [wEnemy1X]
    add a, 16
    cp a, [hl]
    jr c, .noEnemy1Collision

    ;enemy 1 collision
    call PlayerScore
    jr .removeBall
.noEnemy1Collision:

;todo: repeat for other enemies


.noEnemyCollision:
    dec hl
    jr .advanceBall
.skipEnemyCollision:

; PLAYER AND BOTTOM COLLISIONS
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
    
    call SfxCatch
    call UpdateHUDBallStatus

    jr .removeBall
.ballHit:
    call PlayerHit
    jr .removeBall
.ballMissed:
    call SfxMiss
    jr .removeBall
.bottomCheckPassed:

    ;no collisions so far
    jr .advanceBall
.removeBall:
    dec hl
    xor a
    ld [hl], a
.advanceBall:
    add hl, bc
    sla e
    jp nz, .nextBall

    ret