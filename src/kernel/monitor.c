// Athena 7736

#include "monitor.h"

#define DISP_MEMORY 0xB8000
#define TXTCLR 0x0F00

#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 25
#define SCREEN_SIZE 2000

unsigned short iCursorPosition = 0;
unsigned short iBlankChar = TXTCLR | 0x20; //blank character

void move_cursor()
{
	// Send Commands to VGA Controller 
	outb(0x3D4,14);
	outb(0x3D5,iCursorPosition >> 8);  // Send the higher byte first
	outb(0x3D4,15);
	outb(0x3D5,iCursorPosition);  // then lower byte
}

void print_char(char cToDisp)
{
	unsigned short * pDispMem = NULL;
	pDispMem = (unsigned short *) DISP_MEMORY;
	
	unsigned short iDispWord = 0;
	iDispWord |= TXTCLR;
	iDispWord |= cToDisp;
	
	pDispMem[iCursorPosition] = iDispWord;
	
	iCursorPosition++;
	if(iCursorPosition >= SCREEN_SIZE)
		scroll_screen();         
	
        move_cursor();

}


short monitor_write(char *pDispString)
{
	short iIndexChar = 0;
	char curChar = '\0';

	while ( (curChar = pDispString[iIndexChar++]) != '\0' )
	{
		print_char(curChar);
	}
	
	return iIndexChar;
}

short scroll_screen()
{
	unsigned short *pDispArea = NULL;
	pDispArea = (unsigned short*) DISP_MEMORY;
	unsigned short iPosIndex = 0;
	for ( ; iPosIndex < (SCREEN_SIZE - SCREEN_WIDTH) ; iPosIndex++ )
 		pDispArea[iPosIndex] = pDispArea[iPosIndex + SCREEN_WIDTH];
	for ( ; iPosIndex < SCREEN_SIZE ; iPosIndex++ )
		pDispArea[iPosIndex] = iBlankChar;
	iCursorPosition -=SCREEN_WIDTH;
}

void monitor_clear()
{
	unsigned short *pDispArea = NULL;
        pDispArea = (unsigned short*) DISP_MEMORY;

	unsigned short iPosIndex = 0;
	for ( ; iPosIndex < SCREEN_SIZE ; iPosIndex++ )
 		pDispArea[iPosIndex] = iBlankChar;
	
	// Reset the Cursor position
	iCursorPosition = 0;
	move_cursor();
}
