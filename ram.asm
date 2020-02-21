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

wLFSR: ds 1

wAnimationFlags: ds 1

SECTION "USER MEMORY", WRAM0
wScoreHighBcd: ds 1
wScoreLowBcd: ds 1
wLives: ds 1
wTime: ds 1

;wStage: ds 1
wHitEffectCounter: ds 1
HIT_DURATION EQU 30
wPlayerX: ds 1

wPlayerFlags: ds 1
PLAYER_HIT EQU      %00000001
PLAYER_HASBALL EQU  %00000010
PLAYER_CATCH EQU    %00000100


