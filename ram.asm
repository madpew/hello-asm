SECTION "LOCAL OAM", WRAM0 [$C000]
wShadowOam:

wSpritePlayer:
wSpritePlayerLeft: ds 4
wSpritePlayerRight: ds 4
wSpritePlayerPawLeft: ds 4
wSpritePlayerPawRight: ds 4
wSpritePlayerBall: ds 4

wBallSprites: ds 8*4

wEnemySprites:
wEnemy1Sprites:
wEnemy1WallSprites: ds 8
wEnemy1FaceSprites: ds 8
wEnemy1PawSprite: ds 4

wEnemy2Sprites:
wEnemy2WallSprites: ds 8
wEnemy2FaceSprites: ds 8
wEnemy2PawSprite: ds 4

wEnemy3Sprites:
wEnemy3WallSprites: ds 8
wEnemy3FaceSprites: ds 8
wEnemy3PawSprite: ds 4

FreeSprites_12:
sprite11: ds 4
sprite12: ds 4
sprite13: ds 4
sprite14: ds 4
sprite15: ds 4
sprite16: ds 4
sprite17: ds 4
sprite18: ds 4
sprite19: ds 4
sprite20: ds 4
sprite21: ds 4
sprite22: ds 4

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
HIT_DURATION EQU 7

wPlayerX: ds 1
wPlayerFlags: ds 1

wBallDirection: ds 1

wEnemyData:

wEnemy1Timer: ds 1
wEnemy1State: ds 1
wEnemy1X : ds 1
wEnemy1Y : ds 1

wEnemy2Timer: ds 1
wEnemy2State: ds 1
wEnemy2X : ds 1
wEnemy2Y : ds 1

wEnemy3Timer: ds 1
wEnemy3State: ds 1
wEnemy3X : ds 1
wEnemy3Y : ds 1