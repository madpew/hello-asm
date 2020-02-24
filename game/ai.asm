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

    ld bc, 4 ;size of enemy struct
    add hl, bc

    call ProcessEnemy   ; second

    ret

ProcessEnemy:
    
    push hl

    ; enemy AI is based on a very basic statemachine and a timer
    ; when the timer hits 0, the statemachine acts accordingly, sets the new state and timer
    dec [hl]
    jr nz, .sleep

    inc hl
    ld a, [hld] ;load state, hl now points to timer again
    ld c, a    
    sla c		; shift c left (*2) because our table contains 16bit addresses

    ld b, 0
	
	lookup_jump StateFuncTable	; do the table jump using the given Table (label) and offset stored in BC
.sleep:
    pop hl
    ret

; AI State Machine
; Functions get called with hl pointing to the timer when the timer reached zero (the state is completed or changed)
; Functions need to set the timer and state

ENEMY_TIME_AIM  equ 60

ENEMY_STATE_WAIT equ    1   ;turn off sprites, set timer to random interval, set random x
ENEMY_STATE_UP  equ     2   ; move enemy up
ENEMY_STATE_AIM equ     3   ; wait 
ENEMY_STATE_THROW equ   4   ; shoot or don't and wait
ENEMY_STATE_HIT equ     5   ; hit animation
ENEMY_STATE_DOWN equ    6   ; move down

AIStateWait:
jr ProcessEnemy.sleep

ret
    ; set sleep time
    xor a
    ld [hli], a

    ; advance state
    sla [hl]

    ; update EnemyX
    inc hl
    call GetNextRandom
    sla a ; *8 to align with tiles
    sla a
    sla a
    and a, 7 ; always set low 8 bits
    ld [hli], a
    ; set EnemyY
    ld a, ENEMY_Y
    add a, 8
    ld [hl], a
ret 

AIStateUp:
ret 

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
    sla [hl]
    dec hl
    ld a, ENEMY_TIME_AIM
    ld [hl], a
.continue:
    ret

AIStateAim:
AIStateThrow:
AIStateHit:
ret

AIStateDown:
ret
    ; once down is finished, set wait time to random + state to wait
    ; set sleep time
    call GetNextRandom
    ld [hli], a

    ; advance state
    ld a, ENEMY_STATE_WAIT
    ld [hl], a
    ret