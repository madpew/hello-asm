SoundOff:
	xor a 
    ldh [rAUDVOL], a
    ldh [rAUDTERM], a
    ldh [rAUDENA], a
    
    ret
    
SoundOn:
    ld a, $8f
    ldh [rAUDENA], a

    ld a, $ff
    ldh [rAUDTERM], a

    ld a, $77
    ldh [rAUDVOL], a

    ret

SfxCatch: ; perfect
    ld a, $14
    ldh [rNR10], a
    ld a, $90
	ldh [rNR11], a 
    ld a, $f1
	ldh [rNR12], a
    ld a, $0f
	ldh [rNR13], a
    ld a, $c3
	ldh [rNR14], a
    ret

SfxHit: ;ok-ish, can use NR4 as well
    ld a, $37
    ldh [rNR10], a
    ld a, $00
	ldh [rNR11], a 
    ld a, $f3
	ldh [rNR12], a
    ld a, $b0
	ldh [rNR13], a
    ld a, $86
	ldh [rNR14], a
    ret

SfxMiss: ;needs shorter nr1
    ld a, $3b
    ldh [rNR10], a
    ld a, $80
	ldh [rNR11], a 
    ld a, $f1
	ldh [rNR12], a
    ld a, $a0
	ldh [rNR13], a
    ld a, $c6
	ldh [rNR14], a

    ld a, $1b
    ldh [rNR41], a
    ld a, $f1
	ldh [rNR42], a 
    ld a, $5c
	ldh [rNR43], a
    ld a, $80
	ldh [rNR44], a
    ret
    
SfxDmg:
    ld a, $3c
    ldh [rNR10], a
    ld a, $80
	ldh [rNR11], a 
    ld a, $f3
	ldh [rNR12], a
    ld a, $9f
	ldh [rNR13], a
    ld a, $86
	ldh [rNR14], a

    ld a, $1f
    ldh [rNR41], a
    ld a, $f2
	ldh [rNR42], a 
    ld a, $60
	ldh [rNR43], a
    ld a, $80
	ldh [rNR44], a

    ret 

SfxThrow: ;perfect
    ld a, $3e
    ldh [rNR10], a
    ld a, $80
	ldh [rNR11], a 
    ld a, $a2
	ldh [rNR12], a
    ld a, $1f
	ldh [rNR13], a
    ld a, $87
	ldh [rNR14], a

    ld a, $1f
    ldh [rNR41], a
    ld a, $09
	ldh [rNR42], a 
    ld a, $50
	ldh [rNR43], a
    ld a, $c0
	ldh [rNR44], a
    ret 


SfxMew:
    ld a, $3f
    ldh [rNR10], a
    ld a, $c0
	ldh [rNR11], a 
    ld a, $87
	ldh [rNR12], a
    ld a, $90
	ldh [rNR13], a
    ld a, $c7
	ldh [rNR14], a
    ret 