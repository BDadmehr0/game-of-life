#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> // for sleep
#include <time.h>
#include <sys/ioctl.h> // برای دریافت ابعاد ترمینال در لینوکس

#define MUTATION_INTERVAL 50

void get_terminal_size(int *rows, int *cols) {
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    *rows = w.ws_row;
    *cols = w.ws_col;
}

void initialize_grid(int **grid, int rows, int cols);
void print_grid(int **grid, int rows, int cols);
void update_grid(int **grid, int rows, int cols);
int count_neighbors(int **grid, int rows, int cols, int x, int y);
void mutate_grid(int **grid, int rows, int cols, int generation);

char random_char() {
    char chars[] = {'@', '#', 'X'};
    int random_index = rand() % 3;
    return chars[random_index];
}

int main() {
    int rows, cols;
    get_terminal_size(&rows, &cols); // دریافت ابعاد ترمینال

    // اختصاص حافظه پویا برای گرید
    int **grid = malloc(rows * sizeof(int *));
    for (int i = 0; i < rows; i++) {
        grid[i] = malloc(cols * sizeof(int));
    }

    initialize_grid(grid, rows, cols);
    int generation = 0;
    
    while (1) {
        system("clear"); // Use "cls" for Windows
        print_grid(grid, rows, cols);
        update_grid(grid, rows, cols);
        mutate_grid(grid, rows, cols, generation);
        generation++;
        usleep(10000); // 200ms delay
    }
    
    // آزادسازی حافظه
    for (int i = 0; i < rows; i++) {
        free(grid[i]);
    }
    free(grid);
    
    return 0;
}

void initialize_grid(int **grid, int rows, int cols) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            grid[i][j] = rand() % 2; // Random 0 or 1
        }
    }
}

void print_grid(int **grid, int rows, int cols) {
    srand(time(0));
    
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            char random_character = random_char();
            printf("%c", grid[i][j] ? random_character : ' ');
        }
        printf("\n");
    }
}

void update_grid(int **grid, int rows, int cols) {
    int **new_grid = malloc(rows * sizeof(int *));
    for (int i = 0; i < rows; i++) {
        new_grid[i] = malloc(cols * sizeof(int));
    }
    
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            int neighbors = count_neighbors(grid, rows, cols, i, j);
            if (grid[i][j] == 1) {
                new_grid[i][j] = (neighbors == 2 || neighbors == 3) ? 1 : 0;
            } else {
                new_grid[i][j] = (neighbors == 3) ? 1 : 0;
            }
        }
    }
    
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            grid[i][j] = new_grid[i][j];
        }
    }
    
    for (int i = 0; i < rows; i++) {
        free(new_grid[i]);
    }
    free(new_grid);
}

int count_neighbors(int **grid, int rows, int cols, int x, int y) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            if (i == 0 && j == 0) continue;
            int nx = (x + i + rows) % rows;
            int ny = (y + j + cols) % cols;
            count += grid[nx][ny];
        }
    }
    return count;
}

void mutate_grid(int **grid, int rows, int cols, int generation) {
    if (generation % MUTATION_INTERVAL == 0) {
        for (int i = 0; i < rows / 5; i++) {
            int x = rand() % rows;
            int y = rand() % cols;
            grid[x][y] = !grid[x][y]; // Flip cell state randomly
        }
    }
}
