#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> // for sleep

#define ROWS 20
#define COLS 40
#define MUTATION_INTERVAL 50

void initialize_grid(int grid[ROWS][COLS]);
void print_grid(int grid[ROWS][COLS]);
void update_grid(int grid[ROWS][COLS]);
int count_neighbors(int grid[ROWS][COLS], int x, int y);
void mutate_grid(int grid[ROWS][COLS], int generation);

int main() {
    int grid[ROWS][COLS];
    initialize_grid(grid);
    int generation = 0;
    
    while (1) {
        system("clear"); // Use "cls" for Windows
        print_grid(grid);
        update_grid(grid);
        mutate_grid(grid, generation);
        generation++;
        usleep(200000); // 200ms delay
    }
    
    return 0;
}

void initialize_grid(int grid[ROWS][COLS]) {
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            grid[i][j] = rand() % 2; // Random 0 or 1
        }
    }
}

void print_grid(int grid[ROWS][COLS]) {
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            printf("%c", grid[i][j] ? '#' : ' ');
        }
        printf("\n");
    }
}

void update_grid(int grid[ROWS][COLS]) {
    int new_grid[ROWS][COLS] = {0};
    
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            int neighbors = count_neighbors(grid, i, j);
            if (grid[i][j] == 1) {
                new_grid[i][j] = (neighbors == 2 || neighbors == 3) ? 1 : 0;
            } else {
                new_grid[i][j] = (neighbors == 3) ? 1 : 0;
            }
        }
    }
    
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            grid[i][j] = new_grid[i][j];
        }
    }
}

int count_neighbors(int grid[ROWS][COLS], int x, int y) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            if (i == 0 && j == 0) continue;
            int nx = (x + i + ROWS) % ROWS;
            int ny = (y + j + COLS) % COLS;
            count += grid[nx][ny];
        }
    }
    return count;
}

void mutate_grid(int grid[ROWS][COLS], int generation) {
    if (generation % MUTATION_INTERVAL == 0) {
        for (int i = 0; i < ROWS / 5; i++) {
            int x = rand() % ROWS;
            int y = rand() % COLS;
            grid[x][y] = !grid[x][y]; // Flip cell state randomly
        }
    }
}

