# Todo

## Core-Game (3 days)

- implement enemy AI
- implement Enemy X position randomizer. Align to grid, and check for overlap with other enemies
- random shoot or not
- add hit-tiles (x-eyes) and tile-reset on respawn
- change player sprite to be a lighter shade

## Optional Features (Wishlist)
### Phase 1 (likely)

- add static props to map (plenty of memory left for additional tiles)
- give balls X direction as well so they don't just go straight
- make catching easier

### Phase 2 (unlikely)
- add music (custom music format or go with a proven solution)
- add 2 cloud sprites scrolling along in the background or mouse running across the field
- make better sounds (layer the channels to get richer effects)
- add a proper screen transition instead of using the shadow-map refresh as an transition

## Finish: (1-2 days)

- put the game on a cartridge and test
- fix bugs found on the real hardware
- finalize and print cartridge label and gamebox
- Make photos and finish the article

# KNOWN BUGS
- fix enemy collision when state is WAIT
- fix hit effect cycling BG palette instead of obj0/1