#ifndef __LCD_H
#define __LCD_H		
#include "meteo.h"
#include "sys.h"	 
#include "stdlib.h" 


#define DFT_SCAN_DIR  U2D_R2L  //默认的扫描方向
#define LCD_USE8BIT_MODEL   0  //8位16位切换，1：8位
                               //             0:16位

//扫描方向定义
#define L2R_U2D  0x00 //从左到右,从上到下（正向,0度）
#define L2R_D2U  0x80 //从左到右,从下到上
#define R2L_U2D  0x40 //从右到左,从上到下
#define R2L_D2U  0xc0 //从右到左,从下到上（旋转180度）

#define U2D_L2R  0x20 //从上到下,从左到右
#define U2D_R2L  0x60 //从上到下,从右到左（旋转90度）
#define D2U_L2R  0xa0 //从下到上,从左到右（旋转270度）
#define D2U_R2L  0xe0 //从下到上,从右到左

//LCD重要参数集
typedef struct  
{										    
	u16 width;			//LCD 宽度
	u16 height;			//LCD 高度
	u16 id;				  //LCD ID
}_lcd_dev; 	  

//LCD参数
extern _lcd_dev lcddev;	//管理LCD重要参数

//////////////////////////////////////////////////////////////////////////////////	 
//-----------------LCD端口定义---------------- 
#define	LCD_LED  LCD ->LCD_BL_CTR//LCD背光

#define	LCD_CS_SET 	LCD ->LCD_CS  =0x1  //片选端口  
#define	LCD_RS_SET	LCD ->LCD_RS  =0x1  //数据/命令 
#define	LCD_WR_SET	LCD ->LCD_WR  =0x1  //写数据		
#define	LCD_RD_SET	LCD ->LCD_RD  =0x1  //读数据		
#define	LCD_RST_SET	LCD ->LCD_RST =0x1  //复位			
								    
#define	LCD_CS_CLR  LCD ->LCD_CS  =0x00000000     //片选端口  
#define	LCD_RS_CLR	LCD ->LCD_RS  =0x00000000     //数据/命令 
#define	LCD_WR_CLR	LCD ->LCD_WR  =0x00000000     //写数据		
#define	LCD_RD_CLR	LCD ->LCD_RD  =0x00000000     //读数据		
#define	LCD_RST_CLR	LCD ->LCD_RST =0x00000000     //复位			


#define DATAOUT(x)  LCD ->LCD_DATA=x;       //数据输出
#define DATAIN      LCD ->LCD_DATA;         //数据输入

//画笔颜色
#define WHITE         	 0xFFFF
#define BLACK         	 0x0000	  
#define BLUE         	 0x001F  
#define BRED             0XF81F
#define GRED 			 0XFFE0
#define GBLUE			 0X07FF
#define RED           	 0xF800
#define MAGENTA       	 0xF81F
#define GREEN         	 0x07E0
#define CYAN          	 0x7FFF
#define YELLOW        	 0xFFE0
#define BROWN 			 0XBC40 //棕色
#define BRRED 			 0XFC07 //棕红色
#define GRAY  			 0X8430 //灰色
//GUI颜色

#define DARKBLUE      	 0X01CF	//深蓝色
#define LIGHTBLUE      	 0X7D7C	//浅蓝色  
#define GRAYBLUE       	 0X5458 //灰蓝色
//以上三色为PANEL的颜色 
 
#define LIGHTGREEN     	 0X841F //浅绿色
//#define LIGHTGRAY        0XEF5B //浅灰色(PANNEL)
#define LGRAY 			 0XC618 //浅灰色(PANNEL),窗体背景色

#define LGRAYBLUE        0XA651 //浅灰蓝色(中间层颜色)
#define LBBLUE           0X2B12 //浅棕蓝色(选择条目的反色)
	    				

void LCD_Clear(u16 color);
void LCD_Init(void);													   	//初始化
void LCD_WR_data(u16 data);//写数据
void LCD_WR_DATA(u16 data);//写数据
u16 LCD_RD_DATA(void);//读点		
void LCD_Address_Set(u16 x1,u16 y1,u16 x2,u16 y2);//设置坐标函数
void LCD_Fill(u16 xsta,u16 ysta,u16 xend,u16 yend,u16 color);//指定区域填充颜色
void LCD_DrawPoint(u16 x,u16 y,u16 color);//在指定位置画一个点

void Draw_Circle(u16 x0,u16 y0,u8 r,u16 color);
void LCD_DrawRectangle(u16 x1, u16 y1, u16 x2, u16 y2,u16 color);
void LCD_DrawLine(u16 x1,u16 y1,u16 x2,u16 y2,u16 color);
void LCD_ShowPicture(u16 x,u16 y,u16 length,u16 width,const u8 pic[]);
void LCDOpenWindows(u16 x, u16 y, u16 len, u16 wid);
void LCD_ili9341_DrawPicture(u16 StartX,u16 StartY,u16 Xend,u16 Yend,const unsigned char *pic);

void LCD_ShowChar(u16 x,u16 y,u8 num,u16 fc,u16 bc,u8 sizey,u8 mode);
void LCD_ShowString(u16 x,u16 y,const u8 *p,u16 fc,u16 bc,u8 sizey,u8 mode);
void LCD_ShowIntNum(u16 x,u16 y,u16 num,u8 len,u16 fc,u16 bc,u8 sizey);
void LCD_ShowFloatNum1(u16 x,u16 y,float num,u8 len,u16 fc,u16 bc,u8 sizey);
u32 mypow(u8 m,u8 n);
#endif  
	 
	 



