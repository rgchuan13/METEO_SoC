#include "lcd.h"
#include "test.h"


void Test_Color(void)
{
	LCD_Fill(0,20,lcddev.width,lcddev.height-20,BLUE);

}