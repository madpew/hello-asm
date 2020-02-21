SECTION	"GAME", ROM0

; currentScene enum
SCENE_LOGO EQU 0
SCENE_INTRO EQU 1
SCENE_GAME EQU 2
SCENE_WIN EQU 3
SCENE_LOST EQU 4
SCENE_HELP EQU 5

include "game/logo.asm"
include "game/intro.asm"
include "game/fight.asm"
include "game/winner.asm"
include "game/loser.asm"
include "game/help.asm"

FuncTableLoad:
dw	LoadLogo
dw	LoadIntro
dw	LoadFight
dw	LoadWinner
dw	LoadLoser
dw	LoadHelp

FuncTableTick:
dw 	TickLogo
dw	TickIntro
dw	TickFight
dw	TickWinner
dw	TickLoser
dw	TickHelp

GameInit:
	; do whatever setup is required, then load first scene
	call SoundOn

	xor a
	call GameLoadScene
	jp GameLoop

; @param a Contains the scene number to load. (SCENE enum)
GameLoadScene: 

	ld [wCurrentScene], a		; safe current scene number
	ld c, a						; copy over to c, as "lookupJump" requires the offset in BC
	sla c						; shift c left (*2) because our table contains 16bit addresses
	
	xor a
	ld [wFrameCounter], a		; reset frame counter to 0
	ld b, a						; set b (upper part of jump offset) to 0 as well

	lookup_jump FuncTableLoad	; do the table jump using the given Table (label) and offset stored in BC
		
GameTick:
	
	;do global stuff here (update music maybe?)
	
	;branch out according to scene
	ld a, [wCurrentScene]
	sla a
	ld b, 0
	ld c, a
	
	lookup_jump FuncTableTick
