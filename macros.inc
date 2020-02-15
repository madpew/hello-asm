; LDA load value into A, load A into location
seta: MACRO
ld a, \2
ld \1, a
ENDM

loadScene: MACRO
xor a
ld [timeTickCounter], a
ld [timeFrameCounter], a
ld a, \1
ld [currentScene], a
jp gameOnLoadScene
ENDM

setSprite: MACRO ; \1 \2\3\4\5
	ld a, \2
	ld [oamstart + \1*4], a
	
	ld a, \3
	ld [oamstart + 1 + \1*4], a
	
	ld a, \4
	ld [oamstart + 2 + \1*4], a
	
	ld a, \5
	ld [oamstart + 3 + \1*4], a
ENDM

clearSprite: MACRO ; \1
	xor a
	ld [oamstart + \1*4], a
	ld [oamstart + 1 + \1*4], a ; should be able to remove this
ENDM

case: MACRO ;\1 compare value, gets compared with A, \2 label to get called
	cp \1
	call z, \2
ENDM