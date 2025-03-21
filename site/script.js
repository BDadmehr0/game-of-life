const ROWS = 20;
const COLS = 40;
const MUTATION_INTERVAL = 50;
let grid = Array.from({ length: ROWS }, () => Array(COLS).fill(0));
let generation = 0;

function initializeGrid() {
  for (let i = 0; i < ROWS; i++) {
    for (let j = 0; j < COLS; j++) {
      grid[i][j] = Math.random() < 0.5 ? 1 : 0;
    }
  }
}

function printGrid() {
  const output = grid.map((row) =>
    row.map((cell) => (cell ? "#" : " ")).join(""),
  );
  document.getElementById("grid").innerText = output.join("\n");
}

function countNeighbors(x, y) {
  let count = 0;
  for (let i = -1; i <= 1; i++) {
    for (let j = -1; j <= 1; j++) {
      if (i === 0 && j === 0) continue;
      let nx = (x + i + ROWS) % ROWS;
      let ny = (y + j + COLS) % COLS;
      count += grid[nx][ny];
    }
  }
  return count;
}

function updateGrid() {
  let newGrid = grid.map((arr) => [...arr]);
  for (let i = 0; i < ROWS; i++) {
    for (let j = 0; j < COLS; j++) {
      let neighbors = countNeighbors(i, j);
      if (grid[i][j] === 1) {
        newGrid[i][j] = neighbors === 2 || neighbors === 3 ? 1 : 0;
      } else {
        newGrid[i][j] = neighbors === 3 ? 1 : 0;
      }
    }
  }
  grid = newGrid;
}

function mutateGrid() {
  if (generation % MUTATION_INTERVAL === 0) {
    for (let i = 0; i < ROWS / 5; i++) {
      let x = Math.floor(Math.random() * ROWS);
      let y = Math.floor(Math.random() * COLS);
      grid[x][y] = grid[x][y] ? 0 : 1;
    }
  }
}

function loop() {
  printGrid();
  updateGrid();
  mutateGrid();
  generation++;
  setTimeout(loop, 200);
}

document.addEventListener("DOMContentLoaded", () => {
  initializeGrid();
  loop();
});
