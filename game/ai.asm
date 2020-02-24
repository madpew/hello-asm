StateFuncTable:
dw 	AIStateWait
dw	AIStateUp
dw	AIStateAim
dw	AIStateThrow
dw	AIStateHit
dw	AIStateDown

UpdateAI:

    ld hl, wEnemyData

    call ProcessEnemy   ; first

    ;ld bc, 4 ;size of enemy struct
    ;add hl, bc
    ;call ProcessEnemy   ; second

    ;ld bc, 4 ;size of enemy struct
    ;add hl, bc
    ;call ProcessEnemy   ; third

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

ENEMY_TIME_AIM  equ 60

ENEMY_STATE_WAIT equ    0   ;turn off sprites, set timer to random interval, set random x
ENEMY_STATE_UP  equ     1   ; move enemy up
ENEMY_STATE_AIM equ     2   ; wait 
ENEMY_STATE_THROW equ   3   ; shoot or don't and wait
ENEMY_STATE_HIT equ     4   ; hit animation
ENEMY_STATE_DOWN equ    5   ; move down

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
    call GetNextRandom
    sla a ; *8 to align with tiles
    sla a
    sla a
    or a, 7 ; always set low 8 bits
    ld [hli], a
    ; set EnemyY
    ld a, ENEMY_Y + 4 
    ld [hl], a
    ; todo: also reset sprite tiles

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
    ld a, [hli]
    and a
    jr nz, ProcessEnemy.done ;keep waiting 

    ;aiming is done
    ;call GetNextRandom
    ;and %01010101
    ld a, ENEMY_STATE_DOWN
    ld [hl], a

    jr ProcessEnemy.done

AIStateThrow:
AIStateHit:
    pop hl
    push hl
    jr ProcessEnemy.done

AIStateDown:
    pop hl
    push hl
    ; sleeptime can stay at 0 (for fast scrolling)
    ld bc, 3
    add hl, bc

    ; now points at enemyY
    ; move up
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
    ;ld a, ENEMY_TIME_AIM
    ld [hl], a
.continue:
    jr ProcessEnemy.done