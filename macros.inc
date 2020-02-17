set_sprite: MACRO ; \1 \2\3\4\5
	ld a, \2
	ld [oamstart + \1*4], a
	
	ld a, \3
	ld [oamstart + 1 + \1*4], a
	
	ld a, \4
	ld [oamstart + 2 + \1*4], a
	
	ld a, \5
	ld [oamstart + 3 + \1*4], a
ENDM

clear_sprite: MACRO ; \1
	xor a
	ld [oamstart + \1*4], a
ENDM

lb: MACRO ; r, hi, lo
    ld \1, ((\2) & $ff) << 8 + ((\3) & $ff)
ENDM