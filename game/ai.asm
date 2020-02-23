;   ld [wEnemy1X], a
;   ld [wEnemy1Timer], a
;   ld [wEnemy1State], a
;   ld [wEnemy2X], a
;   ld [wEnemy2Timer], a
;   ld [wEnemy2State], a

ENEMY_STATE_WAIT equ    %00000001   ;turn off sprites, set timer to random interval, set random x
ENEMY_STATE_UP  equ     %00000010   ; move enemy up
ENEMY_STATE_AIM equ     %00000100   ; wait 
ENEMY_STATE_THROW equ   %00001000   ; shoot or don't and wait
ENEMY_STATE_HIT equ     %00010000   ; hit animation
ENEMY_STATE_DOWN equ    %00100000   ; move down