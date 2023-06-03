#ifndef __LCD_H
#define __LCD_H		
#include "meteo.h"
#include "sys.h"	 
#include "stdlib.h" 


#define DFT_SCAN_DIR  U2D_R2L  //Ĭ�ϵ�ɨ�跽��
#define LCD_USE8BIT_MODEL   0  //8λ16λ�л���1��8λ
                               //             0:16λ

//ɨ�跽����
#define L2R_U2D  0x00 //������,���ϵ��£�����,0�ȣ�
#define L2R_D2U  0x80 //������,���µ���
#define R2L_U2D  0x40 //���ҵ���,���ϵ���
#define R2L_D2U  0xc0 //���ҵ���,���µ��ϣ���ת180�ȣ�

#define U2D_L2R  0x20 //���ϵ���,������
#define U2D_R2L  0x60 //���ϵ���,���ҵ�����ת90�ȣ�
#define D2U_L2R  0xa0 //���µ���,�����ң���ת270�ȣ�
#define D2U_R2L  0xe0 //���µ���,���ҵ���

//LCD��Ҫ������
typedef struct  
{										    
	u16 width;			//LCD ���
	u16 height;			//LCD �߶�
	u16 id;				  //LCD ID
}_lcd_dev; 	  

//LCD����
extern _lcd_dev lcddev;	//����LCD��Ҫ����

//////////////////////////////////////////////////////////////////////////////////	 
//-----------------LCD�˿ڶ���---------------- 
#define	LCD_LED  LCD ->LCD_BL_CTR//LCD����

#define	LCD_CS_SET 	LCD ->LCD_CS  =0x1  //Ƭѡ�˿�  
#define	LCD_RS_SET	LCD ->LCD_RS  =0x1  //����/���� 
#define	LCD_WR_SET	LCD ->LCD_WR  =0x1  //д����		
#define	LCD_RD_SET	LCD ->LCD_RD  =0x1  //������		
#define	LCD_RST_SET	LCD ->LCD_RST =0x1  //��λ			
								    
#define	LCD_CS_CLR  LCD ->LCD_CS  =0x00000000     //Ƭѡ�˿�  
#define	LCD_RS_CLR	LCD ->LCD_RS  =0x00000000     //����/���� 
#define	LCD_WR_CLR	LCD ->LCD_WR  =0x00000000     //д����		
#define	LCD_RD_CLR	LCD ->LCD_RD  =0x00000000     //������		
#define	LCD_RST_CLR	LCD ->LCD_RST =0x00000000     //��λ			


#define DATAOUT(x)  LCD ->LCD_DATA=x;       //�������
#define DATAIN      LCD ->LCD_DATA;         //��������

//������ɫ
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
#define BROWN 			 0XBC40 //��ɫ
#define BRRED 			 0XFC07 //�غ�ɫ
#define GRAY  			 0X8430 //��ɫ
//GUI��ɫ

#define DARKBLUE      	 0X01CF	//����ɫ
#define LIGHTBLUE      	 0X7D7C	//ǳ��ɫ  
#define GRAYBLUE       	 0X5458 //����ɫ
//������ɫΪPANEL����ɫ 
 
#define LIGHTGREEN     	 0X841F //ǳ��ɫ
//#define LIGHTGRAY        0XEF5B //ǳ��ɫ(PANNEL)
#define LGRAY 			 0XC618 //ǳ��ɫ(PANNEL),���屳��ɫ

#define LGRAYBLUE        0XA651 //ǳ����ɫ(�м����ɫ)
#define LBBLUE           0X2B12 //ǳ����ɫ(ѡ����Ŀ�ķ�ɫ)
	    				

void LCD_Clear(u16 color);
void LCD_Init(void);													   	//��ʼ��
void LCD_WR_data(u16 data);//д����
void LCD_WR_DATA(u16 data);//д����
u16 LCD_RD_DATA(void);//����		
void LCD_Address_Set(u16 x1,u16 y1,u16 x2,u16 y2);//�������꺯��
void LCD_Fill(u16 xsta,u16 ysta,u16 xend,u16 yend,u16 color);//ָ�����������ɫ
void LCD_DrawPoint(u16 x,u16 y,u16 color);//��ָ��λ�û�һ����

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
	 
	 



