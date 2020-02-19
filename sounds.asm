SoundOff:
	xor a 
    ldh [rAUDVOL], a
    ldh [rAUDTERM], a
    ldh [rAUDENA], a
    
    ret
    
SoundOn:
	ld a, $ff 
    ldh [rAUDVOL], a
    ldh [rAUDTERM], a
    ldh [rAUDENA], a
    
    ret