include "hardware.inc"
include "macros.inc"

;--------------------------------------------------------------------------------------------

include "ram.asm"
include "interrupts.asm"

DEBUG EQU 0

;--------------------------------------------------------------------------------------------
SECTION	"BOOT", ROM0[$0100]
    nop
    jp	BootSequence
    
	;ROM_HEADER	ROM_NOMBC, ROM_SIZE_32KBYTE, RAM_SIZE_0KBYTE
	
	; nintendo logo
	db $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
	db $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
	db $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

	db "HELLOASM",0,0,0,0,0,0,0	; 15 bytes
	db 0                        ; $143
	db 0, 0                     ; $144 - Licensee code (not important)
	db 0                        ; $146 - SGB Support indicator
	db 0		                ; $147 - Cart type
	db 0				        ; $148 - ROM Size
	db 0				        ; $149 - RAM Size
	db 1                        ; $14a - Destination code
	db $33                      ; $14b - Old licensee code
	db 0                        ; $14c - Mask ROM version
	db 0                        ; $14d - Complement check (important)
	dw 0                        ; $14e - Checksum (not important)

SECTION	"BOOTSEQ", ROM0
BootSequence:

	di					; disable interrupts
	
	ld	sp, $ffff		; setup stack to highest mem location we can use + 1
	
	;turn off sound to save battery
	call SoundOff
	
	; shut down screen
    call TurnScreenOff
	xor a
    ldh [rLCDC], a
	
	; palette setup
	ld a, %11100100
	ld [wPaletteBg], a
	ld [wPaletteObj0], a
	ld [wPaletteObj1], a
	
	ld [wLFSR], a

	;setup scroll
	xor a
	ldh [rSCX], a
	ldh [rSCY], a
	ld [wCamScrollX], a
	ld [wCamScrollY], a
	
	ld [wCurrentScene], a	; start with scene 0
	ld [wInterruptFlags], a		; reset interrupt flags
	ld [wInputState], a ; reset input state

	ld [wShadowMapUpdate], a
	ld [wShadowMapCopyLine], a

	;init sprites
	call ClearAllSprites
	
	; setup timer
	;seta [rTMA], 190 ;~60 fps
	;seta [rTAC], TACF_START | TACF_4KHZ
	
	ld a, STATF_LYC ; | STATF_MODE00
	ldh [rSTAT], a

	xor a
	ldh [rLYC], a
	
	ld a, IEF_VBLANK | IEF_LCDC
	ldh [rIE], a
	
	; turn on screen
	ld a, LCDCF_OFF | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_WIN9C00 | LCDCF_BGON | LCDCF_OBJ8 | LCDCF_OBJON
	ldh [rLCDC], a
	
	;setup
	call InitializeDMA
	
	ei ; enable interrupts 

	jp GameInit

include "data/data.inc"

SECTION "MAINLOOP", ROM0  
GameLoop:

	; wait for next interrupt to occur
	halt
	nop
	
	ld a, [wInterruptFlags]
	bit IEF_VBLANK, a ; check if we had an vblank
	jr z, GameLoop
	
IF DEBUG
	;debug start of gamecode (turns palette black)
	ldh a, [rBGP]
	xor $ff
	ldh [rBGP], a
ENDC
	
	ld a, [wFrames]
	inc a
	ld [wFrames], a
	
	ld a, [wFrameCounter]
	inc a
	ld [wFrameCounter], a
   
	call UpdateInputState

	call GameTick

IF DEBUG
	;debug length of gamecode (turn palette back to normal)
	ldh a, [rBGP]
	xor $ff
	ldh [rBGP], a
ENDC

	ld a, [wInterruptFlags]
	res IEF_VBLANK, a	; reset vblank flag
	ld [wInterruptFlags], a

	jp GameLoop

include "utils.asm"
include "sounds.asm"
include "game.asm"