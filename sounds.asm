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

SoundTest:
SfxThrow:
SfxHit:
SfxMiss:
SfxDmg:
SfxMew:
    
    ld a, $51
    ldh [rNR10], a

    ld a, $81
	ldh [rNR11], a 

    ld a, $F3
	ldh [rNR12], a

    ld a, $A4
	ldh [rNR13], a

    ld a, $C0
	ldh [rNR14], a

    ret 