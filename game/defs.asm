
ENEMY_TIME_AIM  equ 40
ENEMY_TIME_THROW equ 30

ENEMY_STATE_WAIT equ    0   ;turn off sprites, set timer to random interval, set random x
ENEMY_STATE_UP  equ     1   ; move enemy up
ENEMY_STATE_AIM equ     2   ; wait 
ENEMY_STATE_THROW equ   3   ; shoot or don't and wait
ENEMY_STATE_HIT equ     4   ; hit animation
ENEMY_STATE_DOWN equ    5   ; move down

BALL_SPEED EQU 2

PLAYER_Y EQU 120+16
ENEMY_Y EQU 16+40

PLAYER_HIT EQU      %00000001
PLAYER_HASBALL EQU  %00000010
PLAYER_CATCH EQU    %00000100
PLAYER_THROWING EQU %00001000


SCORE_BIG EQU 3
SCORE_SMALL EQU 2