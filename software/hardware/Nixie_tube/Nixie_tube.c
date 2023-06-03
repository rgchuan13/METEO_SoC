#include "Nixie_tube.h"
#include "delay.h"

u32 value=0X0;
void nixie_display_num(u32 data,int pos)
{
    u32 i=0x1;
   if(pos==1)
   {
       value = (value&0XFFFF0)|data;     
       SEGKEY -> SEG_DATA = value;
   }
   else if(pos==2)
   {
        value = (value&0XFFE1F)|data<<5;
       SEGKEY -> SEG_DATA = value;
   }
   else if(pos==3)
   {
      value =  (value&0XFC3FF)|data<<10;
       SEGKEY -> SEG_DATA = value;
   }
   else if(pos==4)
   {
       value = (value&0X87FFF)|data<<15;
       SEGKEY -> SEG_DATA = value;
   }
}
void nixie_display_dos(int dos)
{
   if(dos==1)
   {
       value |=(0x1<<4);
       SEGKEY -> SEG_DATA = value;
   }
   else if(dos==2)
   {
      value |=(0x1<<9);
       SEGKEY -> SEG_DATA = value;
   }
   else if(dos==3)
   {
      value |=(0x1<<19);
       SEGKEY -> SEG_DATA = value;
   }
}
void SEG_Clear_all()
{
    value=0;
    SEGKEY -> SEG_DATA = value;
}
void Display_FM(u32 FM_Value)
{
    if(FM_Value<=999)
    {
        delay_ms(10);
        nixie_display_num(FM_Value%10,1);
        nixie_display_num((FM_Value/10)%10,2);
        nixie_display_num(FM_Value/100,3);
        nixie_display_num(0xF,4);
        nixie_display_dos(2);
    }
    else if(FM_Value>999)
    {
        nixie_display_num(FM_Value%10,1);
        nixie_display_num((FM_Value/10)%10,2);
        nixie_display_num((FM_Value/100)%10,3);
        nixie_display_num(FM_Value/1000,4);
        nixie_display_dos(2);
    }
}
void Standby()
{
    nixie_display_num(0xC,1);
    nixie_display_num(0xC,2);
    nixie_display_num(0xF,3);
    nixie_display_num(0xF,4);
//    delay_ms(200);
//    nixie_display_num(0x0,1);
//    nixie_display_num(0x0,2);
//    nixie_display_num(0x0,3);
//    nixie_display_num(0x0,4);
//    delay_ms(200);
}
void STOP()
{
    SEG_Clear_all();
    nixie_display_num(0xE,1);
    nixie_display_num(0xA,2);
    nixie_display_num(0x0,3);
    nixie_display_num(0x0,4);
}
