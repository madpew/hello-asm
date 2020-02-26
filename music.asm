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

SECTION "SONG DATA", ROMX
DemoSongData:
db $36
db $00
db $00
db $00
db $00
db $00
db $36
db $00
db $FF
DEMOSONG_SPEED EQU 20

SECTION "MUSIC CODE", ROM0
MusicInit:
    xor a
    ld [wMusicStatus], a
    ld [wMusicSpeedDivider], a


    ld hl, DemoSongData
    ld a, DEMOSONG_SPEED
    call MusicStartSong    

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
.processData:
    ld a, [hl]

    ;check for end
    cp NOTE_SONG_END
    jr nz, .checkLoop

    ; turn off song
    xor a
    ld [wMusicStatus], a
    
    ret

    ;check for loop
.checkLoop:
    cp NOTE_SONG_LOOP
    jr nz, .processNote

    ;loop
    ld a, [wMusicSongLow]
    ld l, a
    ld a, [wMusicSongHigh]
    ld h, a

    ld a, [hl]
    
    ; process and inc hl
.processNote:

    ;check highest bit
    bit 7, a
    jr z, .processFrequencyIndex

    ;it's a command
    ;todo: ignore for now
    jr z, .advanceStep

.processFrequencyIndex:

    ;if the index is 0, the step is empty
    and a
    jr z, .advanceStep

    push hl
    sla a ; *2
    ld hl, FrequencyTable
    ld b, 0
    ld c, a
    add hl, bc

    ;channel 2
    ;ld a, $80
    ;ldh [rNR21], a
    ;ld a, $84
    ;ldh [rNR22], a

    ;ld a, [hli]
    ;ldh [rNR23], a

    ;ld a, [hl]
    ;or a, $80
    ;ldh [rNR24], a

    ;channel 3
    ld a, $80
    ldh [rNR30], a

    ld a, $df
    ldh [rNR31], a

    ld a, $20
    ldh [rNR32], a

    ld a, [hli]
    ldh [rNR33], a

    ld a, [hl]
    or a, $c0
    ldh [rNR34], a


    pop hl
.advanceStep:
    inc hl
    ld a, h
    ld [wMusicCurrentHigh], a
    ld a, l
    ld [wMusicCurrentLow], a

    ret