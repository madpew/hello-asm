# TODO LIST

## Future Ideas:
- add a proper screen transition instead of using the shadow-map refresh as an transition
- add difficulty selection and balance times/enemycount/throw probability accordingly
- add obstacles and powerups
- add x-movement to balls (curve balls)
- add more animations to win/loose/menu screen
- rewrite and fix the ai state machine. waiting in between states messes up code relying on current state (e.g.: score relies on state being "down" to see if a enemy got hit while in the moving or throwing phase and is thus kinda random atm.)