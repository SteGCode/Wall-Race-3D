# Wall Race: Project Milestones

A two-player grid game built in Godot with GDScript (statically typed).
Players start on opposite sides of a 9×9 board and race to reach the other side.
On each turn a player either **moves one step** or **places a wall**.

**Goal of this project:** learn. All code is written by me. AI is a mentor, not a code generator (see `AI_RULES.md`).

**Golden rule of the architecture:** game rules live in a plain script with no nodes and no visuals.
Scenes only *display* the state and *send* player input to the rules.

---

## Milestone 1: The board ✅
Draw a 9×9 grid and place two pawns on opposite sides.

- [x] Create the Godot project and a main scene
- [x] Represent the board as data, separate from visuals
- [x] Draw the grid from that data
- [x] Place Player 1 and Player 2 at their starting positions

Things to think about:
- What type represents a position? (Look at `Vector2i`.)
- TileMapLayer, or draw/spawn tiles yourself?
- Could the board logic run with no scene at all?

**Done when:** the board and both pawns appear, and changing the board size in one place updates everything.

---

## Milestone 2: Movement and turns
- [ ] Click an adjacent tile to move there
- [ ] Reject illegal moves (off-board, diagonal, onto the other pawn)
- [ ] Turns alternate between players
- [ ] A player wins on reaching the opposite row
- [ ] Show whose turn it is

Things to think about:
- Where does "whose turn is it" live?
- What exactly makes a move legal? Write the rules in words first.

**Move rules (in words).** A move is legal only if **all** of these are true:
1. The game isn't over.
2. It's this player's turn.
3. The target is exactly one square away, horizontally or vertically (no diagonals).
4. The target is on the board.
5. The other pawn isn't on the target.
6. *(Added in M3)* No wall between the current square and the target.

New game state these rules need: **whose turn it is**, and **whether the game is over (and who won)**.

**Done when:** two people can play a full (wall-less) game on one machine.

---

## Milestone 3: Walls
- [ ] Decide: walls **between tiles** (edges) or **on tiles**? Sketch it on paper first
- [ ] Choose a data structure that answers "can I move from A to B?" quickly
- [ ] Place walls with mouse input (position + orientation)
- [ ] Each player has a limited wall supply (e.g. 10)
- [ ] Reject overlapping/crossing walls
- [ ] Movement respects walls

Notes:
- A wall is **two squares long**.
- Pawns can't pass through walls (rule 6 in the M2 move list).

**Done when:** a player can place walls on their turn and they block movement correctly.

---

## Milestone 4: Path validation
A wall must never completely block a player from reaching their goal.

- [ ] Learn breadth-first search (BFS)
- [ ] Write a BFS that checks whether a player can reach their goal row
- [ ] Test it on small hand-built boards
- [ ] Before accepting a wall: place it temporarily, check both players, undo if illegal

Things to think about:
- Why place-check-undo instead of checking "in your head"?
- What's the worst-case cost of running BFS every wall placement? Does it matter at 9×9?

**Done when:** it's impossible to trap a player.

---

## Milestone 5: Polish
- [ ] Wall preview on hover (valid/invalid colour)
- [ ] Walls-remaining counter for each player
- [ ] Highlight legal moves
- [ ] Win screen and restart button
- [ ] Basic sound or animation (optional)

**Done when:** someone who's never seen the game can play it without explanation.

---

## Milestone 6: Online multiplayer
- [ ] Read the Godot docs page "High-level multiplayer"
- [ ] Host / join screen (ENet)
- [ ] The host is the authority: clients send *requests*, the host validates and broadcasts state
- [ ] Handle a player disconnecting

Things to think about:
- Which machine decides whether a move is legal, and why?
- What's the minimum data you need to send per turn?

**Done when:** two people on different machines can play a full game.

---

## Stretch goals
- [ ] Bot opponent v1: always move along its shortest path
- [ ] Bot opponent v2: places walls to lengthen the opponent's path
- [ ] Bot opponent v3: minimax with a path-length heuristic
- [ ] Jumping over the other pawn when adjacent
- [ ] Setup phase: each player picks their starting column on their own edge row (pawns default to the middle until then)
- [ ] Grid size editable in the Inspector (pass it into `BoardData` via `_init()`)
- [ ] Twists: decaying walls, power-up tiles, 4 players, turn timer
- [ ] Unit tests for the rules script (try the GUT addon)

---

## Log
Keep short notes here on what you learned, decisions you made and why, and bugs that took a while to find.

- **3D, not 2D.** Chose 3D. Only the display side is affected; the rules are the same either way.
- **Tiles are `MeshInstance3D` nodes spawned from code**, not a GridMap. Separate nodes make per-tile effects (highlight, bounce) easy later, and walls between tiles don't fit GridMap's cells.
- **Data vs. visuals split:**
  - `BoardData` (`RefCounted`): grid size and the two players. Game facts only.
  - `PlayerData` (`RefCounted`): a pawn's grid position (`Vector2i`).
  - Board scene: draws tiles and pawns. Visual settings (spacing, cell scale, meshes) are `@export`s here, *not* in `BoardData`.
  - `Grid_World_Translator` (`RefCounted`): converts grid → world. `_init` calculates step and centering once; `grid_to_world()` is called as often as needed. Single place for the formula. World → grid (for clicking) goes here in M2.
- **Axes:** grid uses x/y (`Vector2i`); world uses x/z, and y is up. Grid y maps to world z.
- **Pawns start in the middle of their edge rows** (column = width / 2 with integer division; row 0 and the last row).
- **Gotchas I hit:**
  - Shadowed variables: declaring `var x` inside a function hides the member `x`, which then stays empty. Assign without `var`.
  - Variables initialised at the top of a script run *before* Inspector values are applied. Calculate things that depend on exports in `_ready()`.
  - `@export` does nothing on a `RefCounted` (no Inspector).
  - Renaming an exported variable loses the value set in the Inspector.
  - Fence-post off-by-one: n tiles have n − 1 steps between them; tile x has x gaps before it.
  - `int / int` drops the fraction.
  - `range(n)` stops before n.
  - Runtime-spawned nodes only show in the **Remote** tab, not in the editor viewport.
  - A red dot in the script margin is a breakpoint, not an error.
