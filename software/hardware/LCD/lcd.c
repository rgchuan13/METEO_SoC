#include "lcd.h"
#include "lcdfont.h"
#include "delay.h"

//管理LCD重要参数
//默认为竖屏
_lcd_dev lcddev;


//写寄存器函数
//regval:寄存器值
void LCD_WR_REG(u16 reg)
{   
   //使用16位并行数据总线模式
	LCD_RS_CLR;
	LCD_CS_CLR;
	DATAOUT(reg);
	LCD_WR_CLR;
	LCD_WR_SET;
	LCD_CS_SET; 
}

//写LCD数据
//data:要写入的值
void LCD_WR_data(u16 data)
{	 
  //使用16位并行数据总线模式
	LCD_RS_SET;
	LCD_CS_CLR;
	DATAOUT(data);
	LCD_WR_CLR;
	LCD_WR_SET;
	LCD_CS_SET;
}

//写LCD数据
//data:要写入的值
void LCD_WR_DATA(u16 data)
{
  //使用16位并行数据总线模式
	LCD_RS_SET;
	LCD_CS_CLR;
	DATAOUT(data);
	LCD_WR_CLR;
	LCD_WR_SET;
	LCD_CS_SET;
}

//读LCD数据
//返回值:读到的值
u16 LCD_RD_DATA(void)
{
	u16 data=0,data0=0;
//使用16位并行数据总线模式
	LCD_RS_SET;
	LCD_CS_CLR;
	LCD_RD_CLR;
	data=DATAIN;
	LCD_RD_SET;
	LCD_CS_SET;
	return data;
}




/******************************************************************************
      函数说明：设置起始和结束地址
      入口数据：x1,x2 设置列的起始和结束地址
                y1,y2 设置行的起始和结束地址
      返回值：  无
******************************************************************************/
void LCD_Address_Set(u16 x1,u16 y1,u16 x2,u16 y2)
{
	LCD_WR_REG(0x2a);//列地址设置
	LCD_WR_data(x1>>8);
	LCD_WR_data(x1&0xff);
	LCD_WR_data(x2>>8);
	LCD_WR_data(x2&0xff);
	LCD_WR_REG(0x2b);//行地址设置
	LCD_WR_data(y1>>8);
	LCD_WR_data(y1&0xff);
	LCD_WR_data(y2>>8);
	LCD_WR_data(y2&0xff);
	LCD_WR_REG(0x2c);//储存器写
}
/******************************************************************************
      函数说明：在指定区域填充颜色
      入口数据：xsta,ysta   起始坐标
                xend,yend   终止坐标
								color       要填充的颜色
      返回值：  无
******************************************************************************/
void LCD_Fill(u16 xsta,u16 ysta,u16 xend,u16 yend,u16 color)
{          
	u16 i,j; 
	LCD_Address_Set(xsta,ysta,xend-1,yend-1);//设置显示范围
	for(i=ysta;i<yend;i++)
	{													   	 	
		for(j=xsta;j<xend;j++)
		{
			LCD_WR_DATA(color);
		}
	} 					  	    
}

void Set_Dir(u8 dir)
{
	if((dir>>4)%4)
	{
		lcddev.width=320;
		lcddev.height=240;
	}else
	{
		lcddev.width=240;
		lcddev.height=320;
	}
}

/******************************************************************************
      函数说明：在指定位置画点
      入口数据：x,y 画点坐标
                color 点的颜色
      返回值：  无
******************************************************************************/
void LCD_DrawPoint(u16 x,u16 y,u16 color)
{
	LCD_Address_Set(x,y,x,y);//设置光标位置 
	LCD_WR_DATA(color);
} 


/******************************************************************************
      函数说明：画线
      入口数据：x1,y1   起始坐标
                x2,y2   终止坐标
                color   线的颜色
      返回值：  无
******************************************************************************/
void LCD_DrawLine(u16 x1,u16 y1,u16 x2,u16 y2,u16 color)
{
	u16 t; 
	int xerr=0,yerr=0,delta_x,delta_y,distance;
	int incx,incy,uRow,uCol;
	delta_x=x2-x1; //计算坐标增量 
	delta_y=y2-y1;
	uRow=x1;//画线起点坐标
	uCol=y1;
	if(delta_x>0)incx=1; //设置单步方向 
	else if (delta_x==0)incx=0;//垂直线 
	else {incx=-1;delta_x=-delta_x;}
	if(delta_y>0)incy=1;
	else if (delta_y==0)incy=0;//水平线 
	else {incy=-1;delta_y=-delta_y;}
	if(delta_x>delta_y)distance=delta_x; //选取基本增量坐标轴 
	else distance=delta_y;
	for(t=0;t<distance+1;t++)
	{
		LCD_DrawPoint(uRow,uCol,color);//画点
		xerr+=delta_x;
		yerr+=delta_y;
		if(xerr>distance)
		{
			xerr-=distance;
			uRow+=incx;
		}
		if(yerr>distance)
		{
			yerr-=distance;
			uCol+=incy;
		}
	}
}


/******************************************************************************
      函数说明：画矩形
      入口数据：x1,y1   起始坐标
                x2,y2   终止坐标
                color   矩形的颜色
      返回值：  无
******************************************************************************/
void LCD_DrawRectangle(u16 x1, u16 y1, u16 x2, u16 y2,u16 color)
{
	LCD_DrawLine(x1,y1,x2,y1,color);
	LCD_DrawLine(x1,y1,x1,y2,color);
	LCD_DrawLine(x1,y2,x2,y2,color);
	LCD_DrawLine(x2,y1,x2,y2,color);
}

/******************************************************************************
      函数说明：画圆
      入口数据：x0,y0   圆心坐标
                r       半径
                color   圆的颜色
      返回值：  无
******************************************************************************/
void Draw_Circle(u16 x0,u16 y0,u8 r,u16 color)
{
	int a,b;
	a=0;b=r;	  
	while(a<=b)
	{
		LCD_DrawPoint(x0-b,y0-a,color);             //3           
		LCD_DrawPoint(x0+b,y0-a,color);             //0           
		LCD_DrawPoint(x0-a,y0+b,color);             //1                
		LCD_DrawPoint(x0-a,y0-b,color);             //2             
		LCD_DrawPoint(x0+b,y0+a,color);             //4               
		LCD_DrawPoint(x0+a,y0-b,color);             //5
		LCD_DrawPoint(x0+a,y0+b,color);             //6 
		LCD_DrawPoint(x0-b,y0+a,color);             //7
		a++;
		if((a*a+b*b)>(r*r))//判断要画的点是否过远
		{
			b--;
		}
	}
}

/******************************************************************************
      函数说明：显示图片
      入口数据：x,y起点坐标
                length 图片长度
                width  图片宽度
                pic[]  图片数组    
      返回值：  无
******************************************************************************/
void LCD_ShowPicture(u16 x,u16 y,u16 length,u16 width,const u8 pic[])
{
	u8 picH,picL;
	u16 i,j;
	u32 k=0;
	LCD_Address_Set(x,y,x+length-1,y+width-1);
	for(i=0;i<length;i++)
	{
		for(j=0;j<width;j++)
		{
			picH=pic[k*2];
			picL=pic[k*2+1];
			LCD_WR_DATA(picH<<8|picL);
			k++;
		}
	}			
}


void LCDOpenWindows(u16 x, u16 y, u16 len, u16 wid)
{
        LCD_WR_REG(0X2A); 
        LCD_WR_DATA(x>>8);        //start 
        LCD_WR_DATA(x-((x>>8)<<8));
        LCD_WR_DATA((x+len-1)>>8);        //end
        LCD_WR_DATA((x+len-1)-(((x+len-1)>>8)<<8));
        
        LCD_WR_REG(0X2B); 
        LCD_WR_DATA(y>>8);   //start
        LCD_WR_DATA(y-((y>>8)<<8));
        LCD_WR_DATA((y+wid-1)>>8);   //end
        LCD_WR_DATA((y+wid-1)-(((y+wid-1)>>8)<<8));        
        LCD_WR_REG(0x2C); 
}


/****************************************************************************
* 名    称：void ili9341_DrawPicture(u16 StartX,u16 StartY,u16 EndX,u16 EndY,const unsigned char *pic)
* 功    能：在指定座标范围显示一副图片
* 入口参数：StartX     行起始座标
*           StartY     列起始座标
*           EndX      行结束座标
*           EndY       列结束座标
            pic             图片头指针
* 出口参数：无
* 说    明：图片取模格式为水平扫描，16位颜色模式
* 调用方法：ili9320_DrawPicture(0,0,100,100,(u16*)demo);
****************************************************************************/
void LCD_ili9341_DrawPicture(u16 StartX,u16 StartY,u16 Xend,u16 Yend,const unsigned char *pic)
{
    static   u16 i=0,j=0;


u16 *bitmap = (u16 *)pic;
    
    LCDOpenWindows(StartX,StartY,Xend,Yend);
    
//    for(i=StartY;i<Yend;i++)
//    {

//            for(j=StartX;j<Xend;j++)
//{
//      LCD_WriteRAM(*bitmap++); 
//}        
//    }
//    
}

/******************************************************************************
      函数说明：显示单个字符
      入口数据：x,y显示坐标
                num 要显示的字符
                fc 字的颜色
                bc 字的背景色
                sizey 字号
                mode:  0非叠加模式  1叠加模式
      返回值：  无
******************************************************************************/
void LCD_ShowChar(u16 x,u16 y,u8 num,u16 fc,u16 bc,u8 sizey,u8 mode)
{
	u8 temp,sizex,t,m=0;
	u16 i,TypefaceNum;//一个字符所占字节大小
	u16 x0=x;
	sizex=sizey/2;
	TypefaceNum=(sizex/8+((sizex%8)?1:0))*sizey;
	num=num-' ';    //得到偏移后的值
	LCD_Address_Set(x,y,x+sizex-1,y+sizey-1);  //设置光标位置 
	for(i=0;i<TypefaceNum;i++)
	{ 
		if(sizey==12)temp=ascii_1206[num][i];		       //调用6x12字体
		else if(sizey==16)temp=ascii_1608[num][i];		 //调用8x16字体
		else if(sizey==24)temp=ascii_2412[num][i];		 //调用12x24字体
		else if(sizey==32)temp=ascii_3216[num][i];		 //调用16x32字体
		else return;
		for(t=0;t<8;t++)
		{
			if(!mode)//非叠加模式
			{
				if(temp&(0x01<<t))LCD_WR_DATA(fc);
				else LCD_WR_DATA(bc);
				m++;
				if(m%sizex==0)
				{
					m=0;
					break;
				}
			}
			else//叠加模式
			{
				if(temp&(0x01<<t))LCD_DrawPoint(x,y,fc);//画一个点
				x++;
				if((x-x0)==sizex)
				{
					x=x0;
					y++;
					break;
				}
			}
		}
	}   	 	  
}


/******************************************************************************
      函数说明：显示字符串
      入口数据：x,y显示坐标
                *p 要显示的字符串
                fc 字的颜色
                bc 字的背景色
                sizey 字号
                mode:  0非叠加模式  1叠加模式
      返回值：  无
******************************************************************************/
void LCD_ShowString(u16 x,u16 y,const u8 *p,u16 fc,u16 bc,u8 sizey,u8 mode)
{         
	while(*p!='\0')
	{       
		LCD_ShowChar(x,y,*p,fc,bc,sizey,mode);
		x+=sizey/2;
		p++;
	}  
}


/******************************************************************************
      函数说明：显示数字
      入口数据：m底数，n指数
      返回值：  无
******************************************************************************/
u32 mypow(u8 m,u8 n)
{
	u32 result=1;	 
	while(n--)result*=m;
	return result;
}



/******************************************************************************
      函数说明：显示整数变量
      入口数据：x,y显示坐标
                num 要显示整数变量
                len 要显示的位数
                fc 字的颜色
                bc 字的背景色
                sizey 字号
      返回值：  无
******************************************************************************/
void LCD_ShowIntNum(u16 x,u16 y,u16 num,u8 len,u16 fc,u16 bc,u8 sizey)
{         	
	u8 t,temp;
	u8 enshow=0;
	u8 sizex=sizey/2;
	for(t=0;t<len;t++)
	{
		temp=(num/mypow(10,len-t-1))%10;
		if(enshow==0&&t<(len-1))
		{
			if(temp==0)
			{
				LCD_ShowChar(x+t*sizex,y,' ',fc,bc,sizey,0);
				continue;
			}else enshow=1; 
		 	 
		}
	 	LCD_ShowChar(x+t*sizex,y,temp+48,fc,bc,sizey,0);
	}
} 


/******************************************************************************
      函数说明：显示两位小数变量
      入口数据：x,y显示坐标
                num 要显示小数变量
                len 要显示的位数
                fc 字的颜色
                bc 字的背景色
                sizey 字号
      返回值：  无
******************************************************************************/
void LCD_ShowFloatNum1(u16 x,u16 y,float num,u8 len,u16 fc,u16 bc,u8 sizey)
{         	
	u8 t,temp,sizex;
	u16 num1;
	sizex=sizey/2;
	num1=num*10;
	for(t=0;t<len;t++)
	{
		temp=(num1/mypow(10,len-t-1))%10;
		if(t==(len-1))
		{
			LCD_ShowChar(x+(len-1)*sizex,y,'.',fc,bc,sizey,0);
			t++;
			len+=1;
		}
	 	LCD_ShowChar(x+t*sizex,y,temp+48,fc,bc,sizey,0);
	}
}










//初始化lcd
void LCD_Init(void)
{
	LCD ->LCD_DATA = 0xFF;
	LCD_RST_CLR;
	delay_ms(200); 					// delay 50 ms 
	LCD_RST_SET;
	
	delay_ms(50); 					// delay 50 ms 
	Set_Dir(DFT_SCAN_DIR);
	LCD_WR_REG(0XD3);
  //使用16位并行数据总线模式
	lcddev.id=LCD_RD_DATA();	//dummy read 	
	lcddev.id=LCD_RD_DATA();	//读到0X00
	lcddev.id=LCD_RD_DATA();   	//读取93								   
	lcddev.id<<=8;
	lcddev.id|=LCD_RD_DATA();  	//读取41	

	LCD_WR_REG(0xCF);  
	LCD_WR_data(0x00); 
	LCD_WR_data(0xC1); 
	LCD_WR_data(0X30); 
	LCD_WR_REG(0xED);  
	LCD_WR_data(0x64); 
	LCD_WR_data(0x03); 
	LCD_WR_data(0X12); 
	LCD_WR_data(0X81); 
	LCD_WR_REG(0xE8);  
	LCD_WR_data(0x85); 
	LCD_WR_data(0x10); 
	LCD_WR_data(0x7A); 
	LCD_WR_REG(0xCB);  
	LCD_WR_data(0x39); 
	LCD_WR_data(0x2C); 
	LCD_WR_data(0x00); 
	LCD_WR_data(0x34); 
	LCD_WR_data(0x02); 
	LCD_WR_REG(0xF7);  
	LCD_WR_data(0x20); 
	LCD_WR_REG(0xEA);  
	LCD_WR_data(0x00); 
	LCD_WR_data(0x00); 
	LCD_WR_REG(0xC0);    //Power control 
	LCD_WR_data(0x1B);   //VRH[5:0] 
	LCD_WR_REG(0xC1);    //Power control 
	LCD_WR_data(0x01);   //SAP[2:0];BT[3:0] 
	LCD_WR_REG(0xC5);    //VCM control 
	LCD_WR_data(0x30); 	 //3F
	LCD_WR_data(0x30); 	 //3C
	LCD_WR_REG(0xC7);    //VCM control2 
	LCD_WR_data(0XB7); 
	LCD_WR_REG(0x36);    // Memory Access Control 
	LCD_WR_data(0x08|DFT_SCAN_DIR); 
	LCD_WR_REG(0x3A);   
	LCD_WR_data(0x55); 
	LCD_WR_REG(0xB1);   
	LCD_WR_data(0x00);   
	LCD_WR_data(0x1A); 
	LCD_WR_REG(0xB6);    // Display Function Control 
	LCD_WR_data(0x0A); 
	LCD_WR_data(0xA2); 
	LCD_WR_REG(0xF2);    // 3Gamma Function Disable 
	LCD_WR_data(0x00); 
	LCD_WR_REG(0x26);    //Gamma curve selected 
	LCD_WR_data(0x01); 
	LCD_WR_REG(0xE0);    //Set Gamma 
	LCD_WR_data(0x0F); 
	LCD_WR_data(0x2A); 
	LCD_WR_data(0x28); 
	LCD_WR_data(0x08); 
	LCD_WR_data(0x0E); 
	LCD_WR_data(0x08); 
	LCD_WR_data(0x54); 
	LCD_WR_data(0XA9); 
	LCD_WR_data(0x43); 
	LCD_WR_data(0x0A); 
	LCD_WR_data(0x0F); 
	LCD_WR_data(0x00); 
	LCD_WR_data(0x00); 
	LCD_WR_data(0x00); 
	LCD_WR_data(0x00); 		 
	LCD_WR_REG(0XE1);    //Set Gamma 
	LCD_WR_data(0x00); 
	LCD_WR_data(0x15); 
	LCD_WR_data(0x17); 
	LCD_WR_data(0x07); 
	LCD_WR_data(0x11); 
	LCD_WR_data(0x06); 
	LCD_WR_data(0x2B); 
	LCD_WR_data(0x56); 
	LCD_WR_data(0x3C); 
	LCD_WR_data(0x05); 
	LCD_WR_data(0x10); 
	LCD_WR_data(0x0F); 
	LCD_WR_data(0x3F); 
	LCD_WR_data(0x3F); 
	LCD_WR_data(0x0F); 
	LCD_WR_REG(0x2B); 
	LCD_WR_data(0x00);
	LCD_WR_data(0x00);
	LCD_WR_data(0x01);
	LCD_WR_data(0x3f);
	LCD_WR_REG(0x2A); 
	LCD_WR_data(0x00);
	LCD_WR_data(0x00);
	LCD_WR_data(0x00);
	LCD_WR_data(0xef);	 
	LCD_WR_REG(0x11); //Exit Sleep
	delay_ms(120);
	LCD_WR_REG(0x29); //display on	
	LCD_LED=0x01;
}


void LCD_Clear(u16 color)
{          
	u16 i,j; 
	LCD_Address_Set(0,0,lcddev.width-1,lcddev.height-1);//设置显示范围
	for(i=0;i<lcddev.width;i++)
	{													   	 	
		for(j=0;j<lcddev.height;j++)
		{
			LCD_WR_DATA(color);
		}
	} 					  	    
}