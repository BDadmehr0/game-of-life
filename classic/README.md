# Terminal Game of Life with Mutations

A dynamic, terminal-based implementation of Conway's Game of Life with periodic mutations, written in C. Watch cellular automata evolve in real-time, with random mutations adding chaos to the classic simulation.

![Demo GIF](demo.gif) *(Replace with actual demo GIF if available)*

## Features

- **Adaptive Grid**: Automatically adjusts to your terminal size for full-screen display.
- **Chaotic Mutations**: Random cell states flip every 50 generations (`MUTATION_INTERVAL`).
- **Retro Aesthetic**: Living cells display as random characters (`@`, `#`, `X`) for a "digital rain" effect.
- **Wrap-Around World**: Cells at edges connect to opposite sides (toroidal topology).
- **Optimized Refresh**: Smooth animation with 10ms frame updates.

## Requirements

- Unix-like OS (Linux/macOS) - Uses Unix terminal control features
- C compiler (GCC/clang)

## Build & Run

1. **Compile**:
   ```bash
   gcc game_of_life.c -o game_of_life -Wall
   ```

2. **Run**:
   ```bash
   ./game_of_life
   ```

3. **Exit**: `Ctrl + C`

## Customization

Modify the code to tweak behavior:
```c
#define MUTATION_INTERVAL 50  // Change mutation frequency
char chars[] = {'@', '#', 'X'};  // Modify displayed characters
usleep(10000);  // Adjust frame rate (currently 10ms)
```

## How It Works

1. **Grid Initialization**:
   - Creates 2D array matching terminal dimensions
   - Randomly populates cells (40% alive initially)

2. **Simulation Rules** (per frame):
   - **Survival**: Live cells with 2-3 neighbors survive
   - **Death**: Over/under-population kills cells
   - **Birth**: Dead cells with 3 neighbors become alive

3. **Mutation Phase**:
   - Every 50 generations: 
   - Randomly flips 20% of cells (`rows/5` cells)

## Compatibility Notes

- **Windows**: Requires modifications:
  - Replace `system("clear")` with `system("cls")`
  - Implement Windows terminal size detection
- **Terminal**: Requires ANSI-compatible terminal

## License

MIT License - Free for modification and redistribution. Attribution appreciated.

---

**Inspired by**: John Conway's Game of Life (1970)
