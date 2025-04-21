/*

Written by Montek Singh
Copyright and all rights reserved by Montek Singh
Last Updated:  April 4, 2025

Permission granted to use this only for students, teaching/learning assistants
and instructors of the COMP 541 course at UNC Chapel Hill.
For any other use, contact Montek Singh first.

*/


/*

This is a C template for initial development
of your demo app for COMP541 find projects!

You must compile and run this code in an ANSI
compatible terminal.  You can use the terminal app
in the course VM.  For macOS and Linux users, the
standard terminal/shell on your laptop is also ANSI
compatible.

Open a terminal and compile and run the code as follows:

	gcc code.c
	./a.out

*/



/* Specify the keys here that get_key() will look for,
returning 1 if the first key was found, 2, for the second key, etc.,
and returning 0 if none of these keys was found.
In the actual board-level implementation, you will define
scancodes instead of characters, and you can use specify 
key releases as well.
*/

int key_array[] = {'a', 'd', 'w', 's', 'j', 'k'}; 	// define as many as you need

/* Specify the keys here that get_key2() will look for. */

// int key_array2[] = {'j', 'l', 'i', 'k'}; 	// define as many as you need


/* Let us define our sprites.  These will be text approximations
of the actual sprites used in the board implementation.
Here, each sprite is specified by:
	{ text character, foreground color, background color }

For example, specifying a sprite as
	{'.', white, red},
means it is drawn as a white dot over a red background.

Specify the number of sprites first (Nchars), and then the
attributes of each sprite.
*/

// type definition for emulating sprites (see below)
typedef struct {
	char char_to_display;
	int fg_color;
	int bg_color;
} sprite_attr;

#include <stdio.h>
#include <time.h>
#define Nchars 14

enum colors {black, red, green, yellow, blue, magenta, cyan, white};

sprite_attr sprite_attributes[Nchars] = {
	{'.', white, black},
	{'b', white, white},
	{'1', blue, white},
	{'2', green, white},
	{'3', red, white},
	{'4', yellow, white},
	{'5', magenta, white},
	{'6', cyan, white},
	{'7', blue, white},
	{'8', green, white},
	{'9', red, white},
	{'*', black, white},
	{'s', black, white},
	{'f', red, black},
};
#define ROW 10
#define COL 10
#define TotalROW 30
#define TotalCOL 40


#define ROWS    ROW + 2
#define COLS    COL + 2

#define MINE_COUNT 10


//===============================================================
// Here are the functions available for I/O.  These correspond
// one-to-one to functions available in MIPS assembly in the
// helper files provided.
//
// NOTE:  There is one function specific to the C implementation
// that is not needed in the assembly implementation:
//     void initialize_IO(char* smem_initfile);
//===============================================================

void my_pause(int N);  	// N is hundredths of a second

void putChar_atXY(int charcode, int col, int row);
	// puts a character at screen location (X, Y)

int getChar_atXY(int col, int row);
	// gets the character from screen location (X, Y)

int get_key();
	// if a key has been pressed and it matches one of the
	// characters specified in key_array[], return the
	// index of the key in that array (starting with 1),
	// else return 0 if no valid key was pressed.

int get_key2();
	// similar to get_key(), but looks for key in
	// key_array2[].

int pause_and_getkey(int N);
	// RECOMMENDED!
	// combines pause(N) with get_key() to produce a 
	// *responsive* version of reading keyboard input

void pause_and_getkey_2player(int N, int* key1, int* key2);
	// 2-player version of pause_and_getkey().

int get_accel();
	// returns the accelerometer value:  accelX in bits [31:16], accelY in bits [15:0]
	// to emulate accelerometer, use the four arrow keys

int get_accelX();
	// returns X tilt value (increases back-to-front)

int get_accelY();
	// returns Y tilt value (increases right-to-left)

void put_sound(int period);
	// visually shows approximate sound tone generated
	// you will not hear a sound, but see the tone highlighted on a sound bar

void sound_off();
	// turns sound off

void put_leds(int pattern);
	// put_leds: set the LED lights to a specified pattern
	//   displays on row #31 (below the screen display)

void initialize_IO(char* smem_initfile);
int IsWin(int show[ROWS][COLS], int row, int col);
void spread(int mine[ROWS][COLS], int show[ROWS][COLS], int x, int y);
int mine_count(int mine[ROWS][COLS], int x, int y);
void FindMine(int mine[ROWS][COLS], int show[ROWS][COLS], int result[ROWS][COLS], int row, int col);
void SetMine(int mine[ROWS][COLS], int row, int col);
void DisplayBoard(int show[ROWS][COLS], int row, int col);
void InitBoard(int board[ROWS][COLS], int rows, int cols, int set);
void srand (unsigned int seed);
void play(void);
int rand(void);
void combineBoards(int rows, int cols, int mine[rows][cols], int show[rows][cols], int result[rows][cols]);


int IsWin(int show[ROWS][COLS], int row, int col)
{
    int num = 0;
    for (int i = 1; i <= row; i++)
    {
        for (int j = 1; j <= col; j++)
        {
            if (show[i][j] == 0 || show[i][j] == 13)
                num++;
        }
    }
    return num;
}

void spread(int mine[ROWS][COLS], int show[ROWS][COLS], int x, int y)
{
    int count = mine_count(mine, x, y);

    if (count == 0)
    {
        show[x][y] = 1;
        int i = 0, j = 0;

        for (i = -1; i <= 1; i++)
        {
            for (j = -1; j <= 1; j++)
            {
                if ((x + i) > 0 && (y + i) > 0 && (x + i < ROWS) && (y + j < COLS) && show[x + i][y + j] == 0|| show[i + x][j + y] == 13)
                {        
                    spread(mine, show, x + i, y + j);
                }
            }
        }
    }
    else
    {
        show[x][y] = count+1;
    }
}

int mine_count(int mine[ROWS][COLS], int x, int y)
{

    return (mine[x - 1][y] +
        mine[x - 1][y - 1] +
        mine[x][y - 1] +
        mine[x + 1][y - 1] +
        mine[x + 1][y] +
        mine[x + 1][y + 1] +
        mine[x][y + 1] +
        mine[x - 1][y + 1])/11;
}

void FindMine(int mine[ROWS][COLS], int show[ROWS][COLS], int result[ROWS][COLS], int row, int col)
{
    int x = 1, y = 1;
    int key1 = 0;
    int past;
    int y_offset = (TotalROW - row) / 2;
    int x_offset = (TotalCOL - col) / 2;
    while (1)
    {
    loop:

    	putChar_atXY(12, y-1+x_offset, x-1+y_offset);
	key1 = pause_and_getkey(10);
	switch (key1) {
		case 1: y--; 	DisplayBoard(show, ROW, COL);
		if(y<1) y=1; break;
		case 2: y++; 	DisplayBoard(show, ROW, COL);
		if(y>col) y=col; break;
		case 3: x--; 	DisplayBoard(show, ROW, COL);
		if(x<1) x=1; break;
		case 4: x++; 	DisplayBoard(show, ROW, COL);
		if(x>row) x=row; break;
		case 5: break;
		case 6: break;
	}
        if (x > 0 && x <= row && y > 0 && y <= col && key1 == 5)
        {
            if (mine[x][y] == 11)
            {	
            	combineBoards(ROWS, COLS, mine, show, result);
                DisplayBoard(result, ROW, COL);
                break;
            }
            else
            {
                spread(mine, show, x, y);
                DisplayBoard(show, ROW, COL);
            }
        }
        else if(x > 0 && x <= row && y > 0 && y <= col && key1 == 6)
        {
            if (show[x][y] == 0) 
            {
        	show[x][y] = 13; 
            } 
            else if (show[x][y] == 13) 
            {
        	show[x][y] = 0; 
    	    }
    	DisplayBoard(show, ROW, COL);
        }
        else
        {
            goto loop;
        }
        int ret = IsWin(show, row, col);
        if (ret == MINE_COUNT)
        {
            break;
        }
    }
}

void SetMine(int mine[ROWS][COLS], int row, int col)
{
    int count = MINE_COUNT;
    while (count)
    {
        int x = rand() % row+1;
        int y = rand() % col+1;
        if (mine[x][y] == 0)
        {
            mine[x][y] = 11;
            count--;
        }
    }
}

void DisplayBoard(int show[ROWS][COLS], int row, int col)
{
    int i = 0, j = 0;
    int y_offset = (TotalROW - row) / 2;
    int x_offset = (TotalCOL - col) / 2;

    for (i = 1; i <= row; i++)
    {
        for (j = 1; j <= col; j++)
        {
            putChar_atXY(show[i][j], x_offset + j-1, y_offset + i-1);
        }
    }
    /*for (i = 1; i <= row; i++)
    {
        for (j = 1; j <= col; j++)
        {
		putChar_atXY(show[i][j], j-1, i-1);
        }
    }*/
}

void InitBoard(int board[ROWS][COLS], int rows, int cols, int set)
{
    int i = 0, j = 0;
    for (i = 0; i < rows; i++)
    {
        for (j = 0; j < cols; j++)
        {
            board[i][j] = set;
        }
    }
}

void combineBoards(int rows, int cols, int mine[rows][cols], int show[rows][cols], int result[rows][cols]) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (mine[i][j] == 11) {
                result[i][j] = 11;
            } else {
                result[i][j] = show[i][j];
            }
        }
    }
}


//===============================================================
// This is the code for your demo app!
//===============================================================


int main() {
	initialize_IO("smem.mem");
	srand((unsigned int)time(NULL));
    int mine[ROWS][COLS] = { 0 };
    int show[ROWS][COLS] = { 0 };
    int result[ROWS][COLS] = { 0 };

    InitBoard(mine, ROWS, COLS, 0);
    InitBoard(show, ROWS, COLS, 0);
    DisplayBoard(show, ROW, COL);
    SetMine(mine, ROW, COL);
    FindMine(mine, show, result, ROW, COL);

}


// The file below has the implementation of all of the helper functions
#include "procs.c"

