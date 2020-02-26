set_sprite: MACRO ; \1 \2\3\4\5
	ld a, \2
	ld [wShadowOam + \1*4], a
	
	ld a, \3
	ld [wShadowOam + 1 + \1*4], a
	
	ld a, \4
	ld [wShadowOam + 2 + \1*4], a
	
	ld a, \5
	ld [wShadowOam + 3 + \1*4], a
ENDM

set_sprite_addr: MACRO ; \1 \2\3\4\5
	ld a, \2
	ld [\1], a
	
	ld a, \3
	ld [\1 + 1], a
	
	ld a, \4
	ld [\1 + 2], a
	
	ld a, \5
	ld [\1 + 3], a
ENDM

clear_sprite: MACRO ; \1
	xor a
	ld [wShadowOam + \1*4], a
ENDM

ld16: MACRO ; r, hi, lo
    ld \1, ((\2) & $ff) << 8 + ((\3) & $ff)
ENDM

; @param \1 The keycode defined in the KEY enum.
; @result Z flag
is_key_pressed : MACRO
    ld a, [wInputState]
    and \1
    ld b, a
    ld a, [wInputChanged]
    and b
    ENDM

; @param \1 The keycode defined in the KEY enum.
; @result Z flag
is_key_held : MACRO
	ld a, [wInputState]
    and \1
    ENDM

; Calls the Load-Function of the Scene set in the jump table
; @param \1 The scene number to load. (use SCENE enum)
switch_scene : MACRO
	ld a, \1
    call GameLoadScene
    ENDM

; Copies data to the shadow-map and queues the update
; @param \1 Label of the data to copy
; @param \2 2-byte size (w/h) of the area to copy
load_shadow_map : MACRO
	ld de, \1
	ld hl, wShadowMap
	ld bc, \2
	call MemCopyBlock
	call QueueShadowUpdate
    ENDM


; Copies data to the map vram
; @param \1 Label of the data to copy
; @param \2 2-byte size (w/h) of the area to copy
load_map : MACRO
	ld de, \1
	ld hl, _SCRN0
	ld bc, \2
	call MemCopyBlock
    ENDM

; Copies data to the window vram
; @param \1 Label of the data to copy
; @param \2 2-byte size (w/h) of the area to copy
load_win : MACRO
	ld de, \1
	ld hl, _SCRN1
	ld bc, \2
	call MemCopyBlock
    ENDM

; @param \1 The label of the jumptable
; @param bc The offset into the jumptable (Index*2 because of 16bit width)
lookup_jump : MACRO ; Requires offset (index *2) in BC \1 table-address

	; load hl with the jump table address and add the offset
	ld hl, \1
	add hl, bc

	; read the address from the jump table (HL) and store it into bc
	ld a, [hli]
	ld b, [hl]

	; copy the address to hl
	ld h, b
	ld l, a

	; jump
	jp hl
	ENDM