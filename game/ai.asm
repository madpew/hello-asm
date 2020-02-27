StateFuncTable:
dw 	AIStateWait
dw	AIStateUp
dw	AIStateAim
dw	AIStateThrow
dw	AIStateHit
dw	AIStateDown

UpdateAI:

    ld hl, wEnemyData

    ld de, wEnemy1Sprites 
    call ProcessEnemy   ; first

    ld bc, 4 ;size of enemy struct
    add hl, bc
    ld de, wEnemy2Sprites 
    call ProcessEnemy   ; second

    ld bc, 4 ;size of enemy struct
    add hl, bc
    ld de, wEnemy3Sprites 
    call ProcessEnemy   ; third

    ret

ProcessEnemy:
    
    push hl

    ; enemy AI is based on a very basic statemachine and a timer
    ; when the timer hits 0, the statemachine acts accordingly, sets the new state and timer
    ld a, [hl]
    and a
    jr z, .noDecreaseTime
    dec [hl]
.noDecreaseTime:

    inc hl
    ld a, [hl] ;load state, hl now points to timer again
    dec hl
    ld c, a    
    sla c		; shift c left (*2) because our table contains 16bit addresses

    ld b, 0
    lookup_jump StateFuncTable	; do the table jump using the given Table (label) and offset stored in BC
.done:
    pop hl
    ret

; AI State Machine
; Functions get called with hl pointing to the timer when the timer reached zero (the state is completed or changed)
; Functions need to set the timer and state
AIStateWait:
    pop hl
    push hl
    ;hl points at timer
    ld a, [hli]
    and a
    jr nz, ProcessEnemy.done ;keep waiting 

    ;set next state
    ld a, ENEMY_STATE_UP
    ld [hl], a

    ; update EnemyX
    inc hl
    
    call GetSpawnX

    ld [hli], a
    ; set EnemyY
    ld a, ENEMY_Y + 4 
    ld [hl], a

    ;reset sprites
    ld h, d
    ld l, e
    ld de, 2
    add hl, de ;now pointing to tileid-field of first sprite (wall)
    ld de, 4
    add hl, de  ;second wall sprite
    add hl, de  ; first face sprite
    ld a, TILEIDX_FACELEFTUP
    ld [hl], a
    add hl, de
    ld a, TILEIDX_FACERIGHTUP
    ld [hli], a
    inc hl  ;turn off arm sprite
    xor a
    ld [hl], a
    inc hl
    inc hl
    ld a, TILEIDX_PAWBALL
    ld [hl], a

    jr ProcessEnemy.done

AIStateUp:
    pop hl
    push hl
    ; sleeptime can stay at 0 (for fast scrolling)
    ld bc, 3
    add hl, bc

    ; now points at enemyY
    ; move up
    ld a, [hl]
    dec a
    ld [hld], a
    cp a, ENEMY_Y
    jr nz, .continue

    ;advance state
    dec hl
    ld a, ENEMY_STATE_AIM
    ld [hl], a

    dec hl
    ld a, ENEMY_TIME_AIM
    ld [hl], a
.continue:
    jr ProcessEnemy.done

AIStateAim:
    pop hl
    push hl

    ;hl points at timer
    ld a, [hl]
    and a
    jr nz, ProcessEnemy.done ;keep waiting 

    ;aiming is done
    call GetNextRandom
    and %00001000 ;50% chance, random bit
    ld a, ENEMY_TIME_THROW
    ld [hl], a
    ld a, ENEMY_STATE_THROW
    jr nz, .throw
    xor a
    ld [hl], a
    ld a, ENEMY_STATE_DOWN
.throw:
    inc hl
    ld [hl], a
    jr ProcessEnemy.done

AIStateThrow:
    pop hl
    push hl

    ;set paw sprite to enemy y while throwing
    ld h, d
    ld l, e
    ld bc, 16
    add hl, bc

    ld a, ENEMY_Y 
    ld [hl], a

    pop hl
    push hl

    ;check timer if we should advance
    ld a, [hl]
    and a
    jr nz, ProcessEnemy.done

    ld h, d
    ld l, e
    ld bc, 18
    add hl, bc

    ld a, TILEIDX_PAWRIGHT
    ld [hl], a

    pop hl
    push hl

    ld a, ENEMY_TIME_THROW
    ld [hl], a

    inc hl
    ld a, ENEMY_STATE_DOWN
    ld [hli], a
    ld a, [hl] ;enemyX
    ld d, a

    call SpawnEnemyBall

    jp ProcessEnemy.done

;same as "Down", but slower animation + changed tiles
AIStateHit:
    pop hl
    push hl

    ;set sprites
    ld h, d
    ld l, e
    ld de, 2
    add hl, de ;now pointing to tileid-field of first sprite (wall)
    ld de, 4
    add hl, de  ;second wall sprite
    add hl, de  ; first face sprite
    ld a, TILEIDX_FACELEFTX
    ld [hl], a
    add hl, de
    ld a, TILEIDX_FACERIGHTX
    ld [hli], a ;hli to skip the obj-flags
    inc hl ; advance to next sprite (paw)
    xor a
    ld [hl], a ; disable sprite since we were hit

    pop hl
    push hl
    ; sleeptime can stay at 0 (for fast scrolling)
    ld bc, 3
    add hl, bc

    ; now points at enemyY
    ; move up
    ld a, [wFrames]
    and %00000111
    jr nz, .continue

    ld a, [hl]
    inc a
    ld [hld], a
    cp a, ENEMY_Y + 8
    jr nz, .continue

    ;advance state
    dec hl
    ld a, ENEMY_STATE_WAIT
    ld [hl], a

    dec hl
    call GetNextRandom
    res 7, a
    ld [hl], a
.continue:
    jp ProcessEnemy.done

AIStateDown:
    pop hl
    push hl

    ;check timer if we should advance
    ld a, [hl]
    and a
    jp nz, ProcessEnemy.done

    ;set paw sprite to enemy y while throwing
    ld h, d
    ld l, e
    ld bc, 16
    add hl, bc

    xor a
    ld [hl], a

    pop hl
    push hl

    ld bc, 3
    add hl, bc
    ; now points at enemyY
    ; move down
    ld a, [hl]
    inc a
    ld [hld], a
    cp a, ENEMY_Y + 8
    jr nz, .continue

    ;points at X (move offscreen)
    ld a, 167
    ld [hld], a
    ;advance state
    ld a, ENEMY_STATE_WAIT
    ld [hl], a

    dec hl
    call GetNextRandom
    res 7, a
    ld [hl], a
.continue:
    jp ProcessEnemy.done


GetSpawnX:
    push bc
    push de

.takeAGuess:
    call GetNextRandom
    and $0f ;0-15
    add a, 2 ; 2 tiles + offscreen
    sla a ; *8 to align with tiles
    sla a
    sla a
    
    ld d, a ;move it to d

    ; check new X(left) against existing enemy-locations
    ld a, [wEnemy1X]
    ld b, a
    add a, 24
    ld c, a
    ld a, d
    ;a = newX, b = enemy1x, c = enemy1x + 24
    cp a, c
    jr nc, .check1passed
    add a, 16
    cp a, b
    jr c, .check1passed
    jr .takeAGuess
.check1passed:   

    ld a, [wEnemy2X]
    ld b, a
    add a, 24
    ld c, a
    ld a, d
    ;d = newX, b = enemy1x, c = enemy1x + 15
    cp a, c
    jr nc, .check2passed
    add a, 16
    cp a, b
    jr c, .check2passed
    jr .takeAGuess
.check2passed:   

    ld a, [wEnemy3X]
    ld b, a
    add a, 24
    ld c, a
    ld a, d
    ;d = newX, b = enemy1x, c = enemy1x + 15
    cp a, c
    jr nc, .check3passed
    add a, 16
    cp a, b
    jr c, .check3passed
    jr .takeAGuess
.check3passed:   

    ld a, d

    pop de
    pop bc

    ret