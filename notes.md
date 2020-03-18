Ideas for optimizations:

CAUTION: Do not optimize if not required to keep the code clean (easier to read and understand + reuse)

# Topics for future research

- look into meta-tiles, meta-maps and meta sprites
- look into 4bit packing for maps (like I used in the GBDK version of PSS)

# topics for article

### Unexpected Rendering Problem:
Sprite Priority doesn't work how I anticipated. Thus some parts of the code should probably be done differently.
(Especially the whole "wall tile below cats" thing).
Sprites are sorted by: Y Coordinate > X Coordinate > OAM-Index
Priority is just "over write BG" or "only overwrite white background" instead of OAM-Priority.

### Palette on the real DMG and Auto-Color on GBA/GBC

### remembering cp flags
CP A, X
c: A < X
nc: A > X

LESS EQUS "c"
GREATER EQUS "nc"

c like "smaller"