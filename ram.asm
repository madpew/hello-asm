SECTION "LOCAL OAM", WRAM0 [$C000]
wShadowOam: ds 160
wShadowMap: ds 1024
wShadowMapEnd:

SECTION "ENGINE MEMORY", WRAM0
wInterruptFlags: ds 1

wShadowMapCopyLine: ds 1
wShadowMapUpdate: ds 1

wPaletteBg: ds 1
wPaletteObj0: ds 1
wPaletteObj1: ds 1

wCamScrollX: ds 1
wCamScrollY: ds 1

wCurrentScene: ds 1

wFrames: ds 1
wFrameCounter: ds 1

wInputState: ds 1
wInputChanged: ds 1

; storage of the random number generator
wLFSR: ds 1

; general purpose animation flags for misc animations
wAnimationFlags: ds 1

SECTION "USER MEMORY", WRAM0
wScoreHighBcd: ds 1
wScoreLowBcd: ds 1
wLives: ds 1
wTime: ds 1

;wStage: ds 1
wHitEffectCounter: ds 1
HIT_DURATION EQU 20
wPlayerX: ds 1

wPlayerFlags: ds 1
PLAYER_HIT EQU      %00000001
PLAYER_HASBALL EQU  %00000010
PLAYER_CATCH EQU    %00000100
PLAYER_THROWING equ %00001000

wBallDirection: ds 1

ENEMY_STATE_WAIT equ    %00000001   ;turn off sprites, set timer to random interval, set random x
ENEMY_STATE_UP  equ     %00000010   ; move enemy up
ENEMY_STATE_AIM equ     %00000100   ; wait 
ENEMY_STATE_THROW equ   %00001000   ; shoot or don't and wait
ENEMY_STATE_HIT equ     %00010000   ; hit animation
ENEMY_STATE_DOWN equ    %00100000   ; move down

wEnemy1X : ds 1
wEnemy1Timer: ds 1
wEnemy1State: ds 1

wEnemy2X : ds 1
wEnemy2Timer: ds 1
wEnemy2State: ds 1

wGameState: ds 1
GAME_STATE_OVER EQU %00000001

