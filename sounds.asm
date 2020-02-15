SoundOff:
	xor a 
    ld [rAUDVOL], a
    ld [rAUDTERM], a
    ld [rAUDENA], a
    
    ret
    
SoundOn:
	ld a, $ff 
    ld [rAUDVOL], a
    ld [rAUDTERM], a
    ld [rAUDENA], a
    
    ret