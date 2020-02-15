include "hardware.inc"
include "macros.inc"
;--------------------------------

include "ram.asm"
include "interrupts.asm"

SECTION	"BOOT", ROM0[$0100]
    nop
    jp	bootsequence
    
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
bootsequence:

	di					; disable interrupts
	
	ld	sp, $ffff		; setup stack to highest mem location we can use + 1
	
	;turn off sound to save battery
	call soundOff
	
	; shut down screen
    call turnScreenOffSafe
	xor a
    ld [rLCDC], a
	
	; palette setup
	ld a, [rBGP]
	ld [paletteBg], a
	
	ld a, [rOBP0]
	ld [paletteObj0], a
	
	ld a, [rOBP1]
	ld [paletteObj1], a
	
	;setup scroll
	xor a
	ld [rSCX], a
	ld [rSCY], a
	ld [camScrollX], a
	ld [camScrollY], a
	
	ld [currentScene], a	; start with scene 0
	ld [intFlags], a		; reset interrupt flags
	
	;init sprites
	call clearAllSprites
	
	; setup timer
	;seta [rTMA], 190 ;~60 fps
	;seta [rTAC], TACF_START | TACF_4KHZ
	
	ld a, %00001000
	ld [rSTAT], a
	
	ld a, IEF_VBLANK | IEF_LCDC
	ld [rIE], a
	
	; turn on screen
	ld a, LCDCF_OFF | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ8 | LCDCF_OBJON 
	ld [rLCDC], a
	
	;setup
	call initDMA
	
	ei ; enable interrupts 

	jp gameInit

SECTION "MAINLOOP", ROM0  
gameloop:

	; make sure the display is on
	ld a, [rLCDC]
	set 7, a
	ld [rLCDC], a
	
	; wait for next interrupt to occur
	halt
	nop
	
	; jump to handler depending on intFlags
	ld a, [intFlags]
	
	bit IEF_VBLANK, a ;vblank
	jp nz, onVBlank
	
	; some other interrupt happened, just wait for the next
	jp gameloop

onVBlank:
	; reset vblank flag
	res IEF_VBLANK, a
	ld [intFlags], a
	
	ld a, [timeFrames]
	inc a
	ld [timeFrames], a
	
	ld a, [timeFrameCounter]
	inc a
	ld [timeFrameCounter], a
   
	jp gameOnVBlank
	
include "utils.asm"
include "data/data.inc"
include "sounds.asm"
include "game.asm"