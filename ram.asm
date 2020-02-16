SECTION "LOCAL OAM", WRAM0 [$C000]
wOamStart: ds 160

SECTION "ENGINE MEMORY", WRAM0 [$C0A0]
wInterruptFlags: ds 1

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

SECTION "USER MEMORY", WRAM0

wTemp: ds 1
