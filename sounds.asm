soundOff:
	xor a 
    ld [rAUDVOL], a
    ld [rAUDTERM], a
    ld [rAUDENA], a
    
    ret
    
soundOn:
	ld a, $ff 
    ld [rAUDVOL], a
    ld [rAUDTERM], a
    ld [rAUDENA], a
    
    ret