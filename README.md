# Heroes Board Game
It is a very simple web game consisting on a 2D grid board with heroes and basic gameplay mechanics.

Players can move heroes across the board except on walls. The goal is to kill other players casting _invisible_ attacks.

### Game mechanics
- When player joins a hero is spawned on a random walkable tile
- **Arrow keys** control movements and **space bar** attacks
- Each attack spreads within a radius of 1 tile around the hero
- All enemies in range are attacked at the same time
- One hit is enough to kill

### Where is the focus …
- As much vanilla Elixir as possible
- Software architecture, separation of concerns, readable and testable code
- Production-ready code
- OTP facilities (GenServers, Supervisors) and message passing
- Enough tests for the business logic

### … and where is NOT
- Frontend code
- GUI and interactions
- Libraries (except for the web part)
