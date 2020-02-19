SECTION	"GAME", ROM0

; currentScene enum
SCENE_INTRO EQU 0
SCENE_GAME EQU 1
SCENE_WIN EQU 2
SCENE_LOST EQU 3
SCENE_HELP EQU 4

include "game/intro.asm"
include "game/fight.asm"
include "game/winner.asm"
include "game/loser.asm"
include "game/help.asm"

GameInit:
	; do whatever setup is required, then load first scene
	xor a
	call GameLoadScene
	jp GameLoop

GameLoadScene: ;A is the scenenumber to load

	ld b, a

	; update current scene
	ld [wCurrentScene], a
	; reset counter
	xor a
	ld [wFrameCounter], a

	ld a, b

	cp SCENE_INTRO
	jp z, LoadIntro
	
	cp SCENE_GAME
	jp z, LoadFight
	
	cp SCENE_WIN
	jp z, LoadWinner
	
	cp SCENE_LOST
	jp z, LoadLoser

	cp SCENE_HELP
	jp z, LoadHelp

	stop ;should never reach this
		
GameTick:
	
	;do global stuff here (update music maybe?)

	;branch out according to scene
	ld a, [wCurrentScene]
	cp SCENE_INTRO
	jp z, TickIntro
	
	cp SCENE_GAME
	jp z, TickFight
	
	cp SCENE_WIN
	jp z, TickWinner
	
	cp SCENE_LOST
	jp z, TickLoser	

	cp SCENE_HELP
	jp z, TickHelp

	stop ;should never reach this