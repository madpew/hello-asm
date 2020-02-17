SECTION "UTILS", ROM0

TurnScreenOff:
	; wait for vblank
	ld a, [rSTAT]   
	and STATF_BUSY  
	jr nz, TurnScreenOff

	; turn it off
	ld a, [rLCDC]
	res 7, a
	ld [rLCDC], a
	
	ret


TurnScreenOn:
	; wait for vblank
	ld a, [rSTAT]   
	and STATF_BUSY  
	jr nz, TurnScreenOn

	; turn it on
	ld a, [rLCDC]
	set 7, a
	ld [rLCDC], a
	
	ret

; HL - memory position of the start of the copying source
; DE - memory position of the start of the copying destination
; BC - the number of bytes to be copied
MemCopy:
    inc b
    inc c
    jr .skip
.loop:
    ld a, [hl+]
    ld [de], a
    inc de
.skip:
    dec c
    jr  nz, .loop
    dec b
    jr nz, .loop
    ret

; A  - clear value
; HL - start
; BC - len
MemSet:
    inc b
    inc c
    jr .skip

.loop:
    ld [hli], a 
.skip:
    dec c
    jr nz, .loop
    dec b
    jr nz, .loop

    ret

ClearAllSprites:
	ld hl, wShadowOam
	ld b, 160
	xor a
.loop:
	ldi [hl], a
	dec b
	jr nz, .loop	
	
	ret

KEY_START   EQU %10000000
KEY_SELECT  EQU %01000000
KEY_B       EQU %00100000
KEY_A       EQU %00010000
KEY_DOWN    EQU %00001000
KEY_UP      EQU %00000100
KEY_LEFT    EQU %00000010
KEY_RIGHT   EQU %00000001

; Reads current keypad status, stores into A register, where each bit corresponds to one key being pressed or not
; Keys are in the following order: Start - Select - B - A - Down - Up - Left - Right
UpdateInputState:
    push af
    push bc
    
    ; Read D-pad
	ld a, $20
    ld [_HW], a 

    ld a, [_HW]
    ld a, [_HW]
    cpl
    and $0f
    ld b, a 
    
    ; Read buttons (Start, Select, B, A)
    ld a, $10
    ld [_HW], a 

    ld a, [_HW]
    ld a, [_HW]
    ld a, [_HW]
    ld a, [_HW]
    ld a, [_HW]
    ld a, [_HW]

    cpl
    and $0f
    
    ; Combine D-pad with buttons, store in B
    swap a 
    or b 
    ld b, a 
    
    ld a, $30
    ld [_HW], a
    
    ;b contains current inputstate
    ld a, [wInputState]
    xor a, b
    ld [wInputChanged], a
    ld a, b
    ld [wInputState], a

    pop bc 
    pop af

    ret

;check if a key changed and is now active
; B - key
CheckKeyPressed:
    ld a, [wInputState]
    and b
    ld b, a
    ld a, [wInputChanged]
    and b
    ret

; B - key
CheckKeyHeld:
    ld a, [wInputState]
    and b
    ret

; setMetatile sets 16x16 pixels in the background by using a 4 byte-lookuptable
; hl = destination address
; de = metatile-Index
MetaTileTable:
SetMetatile:

	push af
	push bc
	push hl

	ld b, h
	ld c, l
	
	; convert the metatileIndex to an address
	ld hl, MetaTileTable
	sla e
	sla e
	add hl, de
	
	ld d, h
	ld e, l

	;start writing
	
	ld h, b
	ld l, c

	; first tile
	ld a, [de]
	ld [hli], a
	inc de
	
	; second tile
	ld a, [de]
	ld [hli], a
	inc de
	
	;next line, but 1 to the left
	ld bc, 31
	add hl, bc
	
	;third tile
	ld a, [de]
	ld [hli], a
	
	;forth tile
	inc de
	ld a, [de]
	ld [hl], a
	
	; set hl-cursor to the upper line to enable easier continuous calling of SetMetatile
	pop hl
	ld bc, 2
	add hl, bc

	pop bc
	pop af

	ret


; MapPositionToAddress get the screen address on the bg map (32x32) for x,y coordinates
; HL - start address or 0
; DE - y, x pos ! IMPORTANT
MapPositionToAddress:

	push af
	push bc

	ld bc, 32

	inc d
	jr .continue

.addLine
	add hl, bc
.continue
	dec d
	jr nz, .addLine

	add hl, de ;d is now 0, so e is the X position

	pop bc
	pop af

	ret


; DE - source address
; HL - destination
; BC - cols, rows (c=18, b=20 for a whole screen)
BLOCK_SIZE_SCREEN EQU $1412

MemCopyBlock:

    push af

    push bc

.foreachRow:
    ld a, c ;save c to a
    pop bc  ;restore bc from stack
    push bc
    ld c, a ;restore c from a

.foreachColumn:
        ld a, [de]
        ld [hli], a
        inc de
        dec b
        jr nz, .foreachColumn
    
    ;padding
    ld a, c ;save c to a
    pop bc  ;restore bc from stack
    push bc
    ld c, a ;restore c from a

    ld a, 32
    sub a, b
    push de
    ld d, 0
    ld e, a
    add hl, de
    pop de
    dec c
    jr nz, .foreachRow

    pop bc
    pop af

    ret