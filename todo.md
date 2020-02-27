# Todo
write music for:
  - game over
  - game
  - help
  - menu entry
  - menu ongoing
# KNOWN BUGS

## Optional Features (Wishlist)
### Phase 1 (likely)
- add a proper screen transition instead of using the shadow-map refresh as an transition
  idea: on intro scene load set palettes but bg palette to 0. each loop / animationstep compare if equal else...
    00000000
    00000011 &
     << mask
    00001100 &
    11100100
    do it in gametick and once palettes match to the scene switch


## Finish: (1-2 days)

- put the game on a cartridge and test
- fix bugs found on the real hardware
- upload to homebrewhub, itch.io

- finalize and print cartridge label and gamebox
- Make photos and finish the article

## Future Ideas:
- add difficulty selection and balance times/enemycount/throw probability accordingly
- add obstacles and powerups
- add x-movement to balls (curve balls)
- add animations to win/loose/menu screen
- rewrite and fix the ai state machine. waiting in between states messes up code relying on current state (e.g.: score relies on state being "down" to see if a enemy got hit while in the moving or throwing phase and is thus kinda random atm.)