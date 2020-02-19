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

is_key_pressed : MACRO	; \1 = KEYCODE
    ld a, [wInputState]
    and \1
    ld b, a
    ld a, [wInputChanged]
    and b
    ENDM

is_key_held : MACRO		; \1 = KEYCODE
	ld a, [wInputState]
    and \1
    ENDM

switch_scene : MACRO	; \1 = SCENE_ constant
	ld a, \1
    call GameLoadScene
    ENDM

load_shadow_map : MACRO	; \1 = data, \2 = size
	ld de, \1
	ld hl, wShadowMap
	ld bc, \2
	call MemCopyBlock
	call QueueShadowUpdate
    ENDM