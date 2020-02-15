soundOff:
	xor a 
    ld [rAUDVOL], a		; Turn off the audio volume 
    ld [rAUDTERM], a	; Output no channels to no left/right speakers (when using headphones)
    ld [rAUDENA], a		; Turn audio off 
    ret
    
soundOn:
	ld a, $ff 
    ld [rAUDVOL], a
    ld [rAUDTERM], a
    ld [rAUDENA], a
    ret