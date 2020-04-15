# Backend developer assignment (Elixir)
Build a barebones Massively Multiplayer Online game (MMO) very simple in terms of graphics and gameplay mechanics.

The main point is to demonstrate skills and understanding of Elixir, OTP and basics of web development.

### What the game should look like?
It is played on a 2D grid rendered on the browser. Each field can be either a **wall** or an **empty** tile. The “map” can be predefined and does not need to be randomly generated. The only condition is that there must be at least some wall tiles scattered throughout the grid.

The player controls a hero placed on the grid. It can move freely on empty tiles but **not** on the wall tiles. When other players connect to the game, the enemies, they are also placed on the grid.

Heroes can move to tiles occupied by enemies but they are always rendered on top of them so that yours is always visible. Any dead character should be distinguishable from others.

### Game mechanics
- Players are assigned a hero which is spawned on a random walkable tile
- Random names are assigned to heroes but the player can also choose one
- Each hero can attack everyone else within the radius of 1 tile around, in all directions plus the tile they are standing on
- All enemies in range are attacked at the same time
- One hit is enough to kill. If an enemy attacks you, your hero dies
- When your hero is dead it cannot perform any action
- Every 5 seconds all dead heroes are removed and randomly re-spawned if the player is still playing the game

### Implementation rules
- Each hero is represented by a **GenServer** which holds their position on the grid and the status (alive/dead)
- Game interaction does *not* have to be “live”. Graphics can be updated every second with a page refresh
- A web endpoint to play (e.g. `/game`)
- Players can choose their names with query parameters (e.g. `/game?name=Geralt`)
- Movements input can come from keyboard or HTML buttons

### Where is the focus …
- As much vanilla Elixir as possible
- Software architecture, separation of concerns, readable and testable code
- Production-ready code
- OTP facilities (GenServers, Supervisors) and message passing
- Enough unit tests for the business logic
- At least one test for web controllers

### … and where is NOT
- Frontend code
- GUI and interactions
- Libraries (except for the web part)
