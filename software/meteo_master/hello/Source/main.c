#include "meteo.h"
#include "LED.h"
#include "delay.h"
#include "MSI001.h"
#include "sys.h"
#include "24cxx.h" 
#include "qn8027.h"
#include "Nixie_tube.h"
#include "keyboard.h"
#include "oled.h"
#include "lcd.h"
#include "stdlib.h"

extern u32 value;
extern u32 keyvalue;
void STORE();
void TAKE();
void Search();
void APP_Display(u32 fm);
void Show_Maps();
void StoreFM_Display();
void VOLUME();
void VOLUME_Display();

int FM_STORE[200]={0};
int FM_Store = 0;
extern u32 FM_Value ;
u32 Search_value = 880;
u32 Gate = 0x02ffffff;
u16 stop = 1;
u8 Volume = 5;
int main(void)
{ 
    u32 i=0x0,n=1,a;
    u16 value=0;
	int c=1,s=0;
    SysTick_Config((SystemCoreClock)-1); // 1MHz Ticks    
    //初始化
    MSI001_Init();
   // QN8027_Init();
    CMSDK_uart_init(CMSDK_UART1, 2500, 1,1,0,1,0,1);
    CMSDK_uart_init(CMSDK_UART0, 2500, 1,1,0,1,0,1);
    OLED_Init();
    LCD_Init();
    OLED_Clear();
    Damping_Control(25);
    FM_Select(FM_Value);
    Display_FM(FM_Value);	
    OLED_ShowString(45,0, "METEO",24);
    OLED_SHOW_FM(FM_Value);
    OLED_SHOW_QN(765);
    OLED_SHOW_FM(FM_Value);  
    Show_Maps();
    NVIC_SETENA = 0XF;
     APP_Display(FM_Value);
  while(1)
  {   
        if(GetKEYNUM() == 10)
  {
      FM_Value = Type_NUM();
      Display_FM(FM_Value);
      FM_Select(FM_Value);
      OLED_SHOW_FM(FM_Value);

  //    APP_Display(FM_Value);
   //    keyvalue = 0;
  }
  else if(GetKEYNUM() == 40)
  {
      FM_Value--;
		 // SEG_Clear_all();
      Display_FM(FM_Value);
      FM_Select(FM_Value);
      OLED_SHOW_FM(FM_Value);
 
  }
  else if(GetKEYNUM() == 50)
  {
      FM_Value++;
		//  SEG_Clear_all();
      Display_FM(FM_Value);
      FM_Select(FM_Value);
      OLED_SHOW_FM(FM_Value);
   
  }
  else if(GetKEYNUM() == 60)
  {
      if(stop == 1)
      {
          START_AND_STOP(0);
          stop = 0;
          STOP();
          OLED_ShowString(38,6, "STOP!!",24);
      }
      else if(stop == 0)
      {
          START_AND_STOP(Volume);
          stop = 1;
           Display_FM(FM_Value);
          OLED_Clear();
          OLED_SHOW_FM(FM_Value);
          OLED_SHOW_QN(985);
          OLED_ShowString(45,0, "METEO",24);
      }
  }
      else if(GetKEYNUM() == 70)
     {
         SEG_Clear_all();
         VOLUME();     
         VOLUME_Display();
	     while(1)
        {
            
            if(GetKEYNUM() == 30)
             {
     
             }
	       else if(GetKEYNUM() == 40)
             {
               Volume--;
               START_AND_STOP(Volume);
               VOLUME_Display();
             }
            else if(GetKEYNUM() == 50)
             {
               Volume++;
               START_AND_STOP(Volume);
               VOLUME_Display();
             } 
			else if(GetKEYNUM() == 70)
             {
			   VOLUME();
			   Display_FM(FM_Value);
               FM_Select(FM_Value);
               OLED_SHOW_FM(FM_Value);
			   break;
				}
			 }       
     }
     else if(GetKEYNUM() == 80)
     {
        TAKE();
			  SEG_Clear_all();
        while(1)
       {
         Display_FM(FM_STORE[s]);
        if(GetKEYNUM() == 40)
       {
            s--;
       }
        else if(GetKEYNUM() == 50)
       {
            s++;
       }   
        else if(GetKEYNUM() == 80)
       {
       FM_Select(FM_STORE[s]);
       FM_Value = FM_STORE[s];
      OLED_SHOW_FM(FM_STORE[s]);
      OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);
       break;
       }   
      }
     }     
  
  }
}
void VOLUME()
{
    SEG_Clear_all();
    nixie_display_num(0xa,1);
    nixie_display_num(0xa,2);
    nixie_display_num(0xa,3);
    nixie_display_num(0xa,4);
    Display_FM(FM_Value);
    OLED_ShowString(3,6, "volume adjust",24);
	   delay_ms(500);
    OLED_ShowString(3,6, "              ",24);
    
}
void VOLUME_Display()
{
    SEG_Clear_all();
    nixie_display_num(Volume,1);
    nixie_display_num(0x00,2);
    nixie_display_num(0x00,3);
    nixie_display_num(0x0A,4);
}
void STORE()
{
    SEG_Clear_all();
    nixie_display_num(0xB,1);
    nixie_display_num(0xD,2);
    nixie_display_num(0x0,3);
    nixie_display_num(0x0,4);
    delay_ms(500);
    Display_FM(FM_Value);
    OLED_ShowString(3,6, "store",24);
    delay_ms(500);
    OLED_ShowString(3,6, "              ",24);
    
}
void TAKE()
{
    SEG_Clear_all();
    nixie_display_num(0x1,1);
    nixie_display_num(0xc,2);
    nixie_display_num(0x0,3);
    nixie_display_num(0x0,4);
    delay_ms(500);
    Display_FM(FM_Value);
    OLED_ShowString(3,6, "take",24);
    
}
void Search()
{
    OLED_ShowString(3,6, "              ",24);
    nixie_display_num(0xC,1);
    nixie_display_num(0xA,2);
    nixie_display_num(0xE,3);
    nixie_display_num(0x5,4);
    OLED_ShowString(3,6, "Search...",24);
}
char APP_SendBuffer[5];
void APP_Display(u32 fm)
{
    float send_float;
    send_float = (((float)fm)/10);
    sprintf(APP_SendBuffer,"%.1f",send_float);
    CMSDK_SendString(APP_SendBuffer,5);
}

void Show_Maps()
{
    LCD_Clear(WHITE);
    LCD_Fill(0, 0, 320, 240,WHITE);
    LCD_Fill(20,20,297,125,LGRAYBLUE);
    LCD_DrawRectangle(20, 20, 297, 125,BLACK);
    
    LCD_DrawLine(20,44,40,44,BLACK);
    LCD_DrawLine(40,44,40,54,BLACK);
    LCD_DrawLine(40,54,56,54,BLACK);
    LCD_DrawLine(56,54,56,44,BLACK);
    LCD_DrawLine(56,44,107,44,BLACK);
    LCD_DrawLine(107,44,107,20,BLACK);
 //   LCD_DrawLine(111,44,111,20,BLACK);
    
    LCD_DrawLine(20,112,54,112,BLACK);
    LCD_DrawLine(54,112,54,98,BLACK);
    LCD_DrawLine(54,98,41,98,BLACK);
    LCD_DrawLine(41,98,41,73,BLACK);
    LCD_DrawLine(41,73,67,73,BLACK);
    LCD_DrawLine(67,73,67,125,BLACK);
    
    LCD_DrawLine(88,125,88,60,BLACK);
    LCD_DrawLine(88,60,107,60,BLACK);
    LCD_DrawLine(107,60,107,125,BLACK);
    
    LCD_DrawLine(126,20,126,38,BLACK);
    LCD_DrawLine(126,38,158,38,BLACK);
    LCD_DrawLine(158,38,158,20,BLACK);
    
    LCD_DrawLine(126,48,158,48,BLACK);
    LCD_DrawLine(158,48,158,84,BLACK);
    LCD_DrawLine(158,84,126,84,BLACK);
    LCD_DrawLine(126,84,126,48,BLACK);
    
    LCD_DrawLine(126,125,126,98,BLACK);
    LCD_DrawLine(126,98,158,98,BLACK);
    LCD_DrawLine(158,98,158,125,BLACK);
    
     LCD_DrawLine(194,20,194,98,BLACK);
    LCD_DrawLine(194,98,218,98,BLACK);
    LCD_DrawLine(218,98,218,38,BLACK);
     LCD_DrawLine(218,38,239,38,BLACK);
    LCD_DrawLine(239,38,239,43,BLACK);
     LCD_DrawLine(239,43,252,43,BLACK);
    LCD_DrawLine(252,43,252,50,BLACK);
     LCD_DrawLine(252,50,266,50,BLACK);
    LCD_DrawLine(266,50,266,43,BLACK);
    LCD_DrawLine(266,43,266,43,BLACK);
    LCD_DrawLine(266,43,297,43,BLACK);
   //  LCD_DrawLine(126,125,126,98,BLACK);

    LCD_DrawLine(194,125,194,111,BLACK);
    LCD_DrawLine(194,111,218,111,BLACK);
    LCD_DrawLine(218,111,218,125,BLACK);
    
    LCD_DrawLine(239,125,239,111,BLACK);
    LCD_DrawLine(239,111,256,111,BLACK);
    LCD_DrawLine(256,111,256,98,BLACK);
     LCD_DrawLine(256,98,239,98,BLACK);
    LCD_DrawLine(239,98,239,70,BLACK);
    LCD_DrawLine(239,70,265,70,BLACK);
     LCD_DrawLine(265,70,265,115,BLACK);
    LCD_DrawLine(265,115,297,115,BLACK);
    
    LCD_ShowString(20,150,"X:",BLACK,WHITE,24,0);
    LCD_ShowString(20,200,"Y:",BLACK,WHITE,24,0);
  
}

void StoreFM_Display()
{
   u8 i;
   LCD_Clear(WHITE);
   LCD_Fill(20,10,300,50,YELLOW);
   LCD_ShowString(80,20,"Saved Stations",BLACK,WHITE,24,1);
   LCD_ShowIntNum(10,50,FM_STORE[0],4,BLACK,WHITE,24);
   LCD_ShowIntNum(60,50,FM_STORE[1],4,BLACK,WHITE,24);
   LCD_ShowIntNum(110,50,FM_STORE[2],4,BLACK,WHITE,24);
   LCD_ShowIntNum(160,50,FM_STORE[3],4,BLACK,WHITE,24);
   LCD_ShowIntNum(210,50,FM_STORE[4],4,BLACK,WHITE,24);
   LCD_ShowIntNum(260,50,FM_STORE[5],4,BLACK,WHITE,24);
   LCD_ShowIntNum(10,100,FM_STORE[6],4,BLACK,WHITE,24);
   LCD_ShowIntNum(60,100,FM_STORE[7],4,BLACK,WHITE,24);
   LCD_ShowIntNum(110,100,FM_STORE[8],4,BLACK,WHITE,24);
   LCD_ShowIntNum(160,100,FM_STORE[9],4,BLACK,WHITE,24);
   LCD_ShowIntNum(210,100,FM_STORE[10],4,BLACK,WHITE,24);
   LCD_ShowIntNum(260,100,FM_STORE[11],4,BLACK,WHITE,24);
   LCD_ShowIntNum(10,150,FM_STORE[12],4,BLACK,WHITE,24);
   LCD_ShowIntNum(60,150,FM_STORE[13],4,BLACK,WHITE,24);
   LCD_ShowIntNum(110,150,FM_STORE[14],4,BLACK,WHITE,24);
   LCD_ShowIntNum(160,150,FM_STORE[15],4,BLACK,WHITE,24);
   LCD_ShowIntNum(210,150,FM_STORE[16],4,BLACK,WHITE,24);
   LCD_ShowIntNum(260,150,FM_STORE[17],4,BLACK,WHITE,24);
   LCD_ShowIntNum(10,200,FM_STORE[18],4,BLACK,WHITE,24);
   LCD_ShowIntNum(60,200,FM_STORE[19],4,BLACK,WHITE,24);
   LCD_ShowIntNum(110,200,FM_STORE[20],4,BLACK,WHITE,24);
   LCD_ShowIntNum(160,200,FM_STORE[21],4,BLACK,WHITE,24);
   LCD_ShowIntNum(210,200,FM_STORE[22],4,BLACK,WHITE,24);
   LCD_ShowIntNum(260,200,FM_STORE[23],4,BLACK,WHITE,24);
  
//   LCD_ShowIntNum(100,150,FM_STORE[1],4,BLACK,WHITE,24);
//   LCD_ShowIntNum(140,150,FM_STORE[1],4,BLACK,WHITE,24);
//   LCD_ShowIntNum(60,150,FM_STORE[0],4,BLACK,WHITE,24);
//   LCD_ShowIntNum(100,150,FM_STORE[1],4,BLACK,WHITE,24);
//   LCD_ShowIntNum(140,150,FM_STORE[1],4,BLACK,WHITE,24);
       
}
 u32 lcd_x,lcd_y;
void UARTRX0_Handler()
{
	u8 itr;			// 读取树莓派发送的指令
	int cir,i;
	u32 rssi;		// 读取RSSI值
	u8 data[4];
	u8 data8_1,data8_2,data8_3,data8_4;
	float locationx,locationy;		// 定义x坐标值
 
  CMSDK_uart_ClearRxIRQ(CMSDK_UART0); //clear RX IRQ
	NVIC_CLRENA = 0XF;
  itr = CMSDK_UART0->DATA;
	if(itr == 0x01){
		Display_FM(1024);
		// 发送RSSI值
		for(cir=0;cir <10;cir++){
			rssi = BASEBAND ->RSSI_STATE;
			data[0] = (u8)((rssi>>24));
			data[1] = (u8)((rssi>>16));
			data[2] = (u8)((rssi>>8));
			data[3] = (u8)(rssi);
			for(i=0;i<4;i++)
			{
			CMSDK_uart_SendChar(CMSDK_UART0,data[i]);
			}
		} 
	}
	else if(itr == 0x00){
			CMSDK_uart_ClearRxIRQ(CMSDK_UART0); //clear RX IRQ
			Display_FM(2048);
		    Show_Maps();
		//	      locationx = CMSDK_UART0->DATA;
         //   locationy = CMSDK_UART0->DATA;
            locationx = 1200+rand()%100+(float)(rand()%10)/10;
            locationy = 200+rand()%50+(float)(rand()%10)/10;
            LCD_ShowFloatNum1(100,150,locationx,5,BLACK,WHITE,24);
            LCD_ShowFloatNum1(100,200,locationy,4,BLACK,WHITE,24);
            Draw_Circle(lcd_x,lcd_y,2,LGRAYBLUE);
            lcd_x = (int)(locationx/5)+20;
            lcd_y = (int)(locationy/5)+20;
            Draw_Circle(lcd_x,lcd_y,2,RED);
        
            

	}
	else{
    Display_FM(255);
  }
	delay_ms(200);
	Display_FM(FM_Value);
  delay_ms(10);
  NVIC_SETENA = 0XF;
}

void UARTRX1_Handler()
{
    u8 ch,i;
    u32 rssi;
	CMSDK_uart_ClearRxIRQ(CMSDK_UART1); //clear RX IRQ
    NVIC_CLRENA = 0XF;
    ch =  CMSDK_UART1->DATA;
    if(ch == 0x35)
    {
      FM_Value++;
      Display_FM(FM_Value);
      FM_Select(FM_Value);
      OLED_SHOW_FM(FM_Value);
        APP_Display(FM_Value);
        delay_ms(10);
        APP_Display(FM_Value);
        delay_ms(10);
        APP_Display(FM_Value);
    }
    else if(ch == 0x34)
    {
         FM_Value--;
      Display_FM(FM_Value);
      FM_Select(FM_Value);
      OLED_SHOW_FM(FM_Value);
         APP_Display(FM_Value);
        delay_ms(10);
        APP_Display(FM_Value);
        delay_ms(10);
        APP_Display(FM_Value);

    }
    else if(ch == 0x36)
    {
         if(stop == 1)
      {
          START_AND_STOP(0);
          stop = 0;
          STOP();
          OLED_ShowString(38,6, "STOP!!",24);
            APP_Display(FM_Value);
          delay_ms(10);
        APP_Display(FM_Value);
        delay_ms(10);
        APP_Display(FM_Value);
      }
      else if(stop == 0)
      {
          START_AND_STOP(Volume);
          stop = 1;
           Display_FM(FM_Value);
          OLED_Clear();
          OLED_SHOW_FM(FM_Value);
          OLED_SHOW_QN(985);
          OLED_ShowString(45,0, "METEO",24);
            APP_Display(FM_Value);
          delay_ms(10);
        APP_Display(FM_Value);
        delay_ms(10);
        APP_Display(FM_Value);
      }
    }
     else if(ch == 0x37)
    {
        TAKE(); 
        FM_Select(FM_Value);
        Display_FM(FM_Value);	
        OLED_SHOW_FM(FM_Value);
         APP_Display(FM_Value);
        delay_ms(10);
        APP_Display(FM_Value);
        delay_ms(10);
        APP_Display(FM_Value);
        
    }
     else if(ch == 0x01)
    {
        TAKE(); 
        FM_Value = 881;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
        OLED_SHOW_FM(FM_Value);    
        OLED_ShowString(3,6, "              ",24);          
        
    }
     else if(ch == 0x02)
    {
        TAKE(); 
        FM_Value = 887;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);   
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x03)
    {
        TAKE(); 
        FM_Value = 898;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);  
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x04)
    {
        TAKE(); 
        FM_Value = 906;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);  
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x05)
    {
        TAKE(); 
        FM_Value = 910;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);  
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x06)
    {
        TAKE(); 
        FM_Value = 917;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);  
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x07)
    {
        TAKE(); 
        FM_Value = 925;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);  
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x08)
    {
        TAKE(); 
        FM_Value = 932;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);   
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x09)
    {
        TAKE(); 
        FM_Value = 938;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);     
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0xA)
    {
        TAKE(); 
        FM_Value = 944;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);      
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0xB)
    {
        TAKE(); 
        FM_Value = 955;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);  
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0xC)
    {
        TAKE(); 
        FM_Value = 963;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);    
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0xD)
    {
        TAKE(); 
        FM_Value = 968;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);     
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0xE)
    {
        TAKE(); 
        FM_Value = 974;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);   
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0xF)
    {
        TAKE(); 
        FM_Value = 976;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);       
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x10)
    {
        TAKE(); 
        FM_Value = 980;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);       
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x11)
    {
        TAKE(); 
        FM_Value = 1000;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);      
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x12)
    {
        TAKE(); 
        FM_Value = 1003;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);     
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x13)
    {
        TAKE(); 
        FM_Value = 1015;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);      
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x14)
    {
        TAKE(); 
        FM_Value = 1021;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);    
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x15)
    {
        TAKE(); 
        FM_Value = 1029;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);   
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x16)
    {
        TAKE(); 
        FM_Value = 1035;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);    
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x17)
    {
        TAKE(); 
        FM_Value = 1045;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);    
  OLED_SHOW_FM(FM_Value);        
        
    }
      else if(ch == 0x18)
    {
        TAKE(); 
        FM_Value = 1059;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);    
  OLED_SHOW_FM(FM_Value);        
        
    }
      else if(ch == 0x19)
    {
        TAKE(); 
        FM_Value = 1067;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);    
  OLED_SHOW_FM(FM_Value);        
        
    }
      else if(ch == 0x1A)
    {
        TAKE(); 
        FM_Value = 1079;
        FM_Select(FM_Value);
        Display_FM(FM_Value);
        OLED_ShowString(3,6, "take success",24);
        delay_ms(500);
       OLED_ShowString(3,6, "              ",24);    
  OLED_SHOW_FM(FM_Value);        
        
    }
     else if(ch == 0x38)
    {
         SEG_Clear_all();
        for(i = 0;i<200;i++)
        {
           FM_STORE[i] = 0; 
        }
      while(1)
      {
          Search();
          Search_value++;
           if(Search_value > 1080)
          {
            Search_value = 880;
            FM_Store = 0;
       
            SEG_Clear_all();
            FM_Select(FM_Value);
            Display_FM(FM_Value);
            OLED_SHOW_FM(FM_Value);  
            APP_Display(FM_Value);
            OLED_ShowString(3,6, "Search success",24);
            StoreFM_Display();
            delay_ms(500);
            OLED_ShowString(3,6, "              ",24);  
            
            break;
          }
          FM_Select(Search_value);
        //  delay_ms(10);
          for(i=0;i<5;i++)
          {
             rssi += BASEBAND -> RSSI_STATE; 
              delay_ms(1);
          }
          rssi = rssi/5;
         
        if(rssi>Gate)
        {   
            FM_STORE[FM_Store] = Search_value;
            FM_Store++;
//            FM_Select(FM_Value);
//            Display_FM(FM_Value);
//            OLED_SHOW_FM(FM_Value);  
//            APP_Display(FM_Value);
//            OLED_ShowString(3,6, "Search success",24);
//            delay_ms(500);
//            OLED_ShowString(3,6, "              ",24);    
//            break;
        }
      }          
        
    }
         else if(ch == 0x39)
    {
          APP_Display(FM_Value);
        delay_ms(10);
        APP_Display(FM_Value);
        delay_ms(10);
        APP_Display(FM_Value);
        
    }
  //  CMSDK_uart_SendChar(CMSDK_UART1,ch); 
    delay_ms(10);
    NVIC_SETENA = 0XF;
}
