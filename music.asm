SECTION "MUSIC MEMORY", WRAM0
wMusicStatus: ds 1
wMusicSpeedDivider: ds 1

;current song settings
wMusicSongSpeed: ds 1
wMusicSongLow : ds 1
wMusicSongHigh: ds 1

;music engine data
wMusicCurrentLow: ds 1
wMusicCurrentHigh: ds 1

NOTE_SONG_LOOP EQU $FF
NOTE_SONG_END EQU $FE
NOTE_SONG_EMPTY_ROW EQU $FD

SECTION "FREQUENCYTABLE", ROMX
FrequencyTable:
dw 0
C3:
dw 44
dw 156
dw 262
dw 363
dw 457
dw 547
dw 631
dw 710
dw 786
dw 854
dw 923
dw 986
dw 1046
dw 1102
dw 1155
dw 1205
dw 1253
dw 1297
dw 1339
dw 1379
dw 1417
dw 1452
dw 1486
dw 1517
dw 1546
dw 1575
dw 1602
dw 1627
dw 1650
dw 1673
dw 1694
dw 1714
dw 1732
dw 1750
dw 1767
dw 1783
dw 1798
dw 1812
dw 1825
dw 1837
dw 1849
dw 1860
dw 1871
dw 1881
dw 1890
dw 1899
dw 1907
dw 1915
dw 1923
dw 1930
dw 1936
dw 1943
dw 1949
dw 1954
dw 1959
dw 1964
dw 1969
dw 1974
dw 1978
dw 1982
dw 1985
dw 1988
dw 1992
dw 1995
dw 1998
dw 2001
dw 2004
dw 2006
dw 2009
dw 2011
dw 2013
B8: dw 2015
; 72 notes
; C3 = 1, B8 = 72

;SECTION "SONG DATA", ROMX
;DemoSongData:
;db $36
;db $00
;db $00
;db $00
;db $00
;db $00
;db $36
;db $00
;db $FF
;DEMOSONG_SPEED EQU 20

SECTION "MUSIC CODE", ROM0
MusicInit:
    xor a
    ld [wMusicStatus], a
    ld [wMusicSpeedDivider], a

    ldh [rAUDVOL], a
    ldh [rAUDTERM], a
    ldh [rAUDENA], a

    ldh [$FF30], a
    ldh [$FF31], a
    ldh [$FF32], a
    ldh [$FF33], a
    ldh [$FF34], a
    ldh [$FF35], a
    ldh [$FF36], a
    ldh [$FF37], a
    xor $ff
    ldh [$FF38], a
    ldh [$FF39], a
    ldh [$FF3A], a
    ldh [$FF3B], a
    ldh [$FF3C], a
    ldh [$FF3D], a
    ldh [$FF3E], a
    ldh [$FF3F], a

    ld a, $8f
    ldh [rAUDENA], a

    ld a, $ff
    ldh [rAUDTERM], a

    ld a, $77
    ldh [rAUDVOL], a

    ;ld hl, DemoSongData
    ;ld a, DEMOSONG_SPEED
    ;call MusicStartSong    
    
    ret 

; param hl startaddress of the song
; param a speed
MusicStartSong:
    ld [wMusicSongSpeed], a
    ld a, h
    ld [wMusicSongHigh], a
    ld [wMusicCurrentHigh], a
    ld a, l
    ld [wMusicSongLow], a
    ld [wMusicCurrentLow], a

    ld a, 1
    ld [wMusicStatus], a

    xor a
    ld [wMusicSpeedDivider], a

    ret

MusicUpdate:

    ld a, [wMusicStatus]
    and a
    ret z

    ld a, [wMusicSongSpeed]
    ld b, a
    ld a, [wMusicSpeedDivider]
    inc a
    ld [wMusicSpeedDivider], a
    cp a, b
    ret nz

    xor a
    ld [wMusicSpeedDivider] ,a 

    ; we got an update, it was a tick AND we passed the divider, make some noise
    ld a, [wMusicCurrentLow]
    ld l, a
    ld a, [wMusicCurrentHigh]
    ld h, a
    ld d, 3
.processData:
    ld a, [hl]

    ;check for end
    cp NOTE_SONG_END
    jr nz, .noEnd

    ; turn off song
    xor a
    ld [wMusicStatus], a
    
    ret
.noEnd:

    cp NOTE_SONG_EMPTY_ROW
    jr nz, .notEmpty

    inc hl
    
    ld a, h
    ld [wMusicCurrentHigh], a
    ld a, l
    ld [wMusicCurrentLow], a

    ret 
.notEmpty:

    ;check for loop
.checkLoop:
    cp NOTE_SONG_LOOP
    jr nz, .noLoop

    ;loop
    ld a, [wMusicSongLow]
    ld l, a
    ld a, [wMusicSongHigh]
    ld h, a

    ld a, [hl]
    
    ; process and inc hl
.noLoop:

    ;check highest bit
    bit 7, a
    jr z, .processFrequencyIndex

    call PlaySample
    jr .advanceStep

.processFrequencyIndex:

    ;if the index is 0, the step is empty
    and a
    jr z, .advanceStep

    ;if d = 2, 1 use according channel    
    ld b, a
    
    ld a, d
    cp 2
    jr nz, .otherChannel

    ld a, b
    call PlayNoteCh2
    jr .advanceStep

.otherChannel:
    ld a, b
    call PlayNoteCh3

.advanceStep:
    inc hl
    
    dec d
    jr nz, .processData

    ld a, h
    ld [wMusicCurrentHigh], a
    ld a, l
    ld [wMusicCurrentLow], a

    ret

PlayNoteCh2:
    push hl
    sla a
    ld hl, FrequencyTable
    ld b, 0
    ld c, a
    add hl, bc

    ld a, $80
    ldh [rNR21], a
    ld a, $84
    ldh [rNR22], a
    ld a, [hli]
    ldh [rNR23], a
    ld a, [hl]
    or a, $80
    ldh [rNR24], a
    pop hl
    ret

PlayNoteCh3:
    push hl
    sla a
    ld hl, FrequencyTable
    ld b, 0
    ld c, a
    add hl, bc

    ;channel 3
    ld a, $80
    ldh [rNR30], a
    ld a, $cf
    ldh [rNR31], a
    ld a, $20
    ldh [rNR32], a
    ld a, [hli]
    ldh [rNR33], a
    ld a, [hl]
    or a, $c0
    ldh [rNR34], a

    pop hl
    ret

PlaySample:
    and $0f

    cp a, 1
    jr nz, .noBD
	ld a, $4a
    ldh [rNR10], a
    ld a, $bf
    ldh [rNR11], a
    ld a, $f1
    ldh [rNR12], a
    ld a, $ff
    ldh [rNR13], a
    ld a, $83
    ldh [rNR14], a
.noBD:

    cp a, 2
    jr nz, .noSnare
    xor a
    ldh [rNR41], a
    ld a, $73
    ldh [rNR42], a
    ld a, $51
    ldh [rNR43], a
    ld a, $80
    ldh [rNR44], a
.noSnare:

    cp a, 3
    jr nz, .noHH
    ld a, $1f
    ldh [rNR41], a
    ld a, $71
    ldh [rNR42], a
    ld a, $10
    ldh [rNR43], a
    ld a, $c0
    ldh [rNR44], a
.noHH:

    cp a, 4
    jr nz, .noOHH
    xor a
    ldh [rNR41], a
    ld a, $f1
    ldh [rNR42], a
    ld a, $10
    ldh [rNR43], a
    ld a, $80
    ldh [rNR44], a
.noOHH:
    ret