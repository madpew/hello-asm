SECTION "LOCAL OAM", WRAM0 [$C000]
oamstart: ds 160

SECTION "ENGINE MEMORY", WRAM0 [$C0A0]
intFlags: ds 1

paletteBg: ds 1
paletteObj0: ds 1
paletteObj1: ds 1

camScrollX: ds 1
camScrollY: ds 1

currentScene: ds 1

timeFrames: ds 1
timeFrameCounter: ds 1

SECTION "USER MEMORY", WRAM0

iTemp: ds 1
