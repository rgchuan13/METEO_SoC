#include "meteo.h"
#include "delay.h"
#include "keyboard.h"
#include "Nixie_tube.h"

u32 FM_Value=955;

uint32_t Get_Key_Value(SEGKEY_TypeDef* KEY)
{
  u16 zero;
  u16 keyvalue = 0;
    
 while(keyvalue == 0)
    {
    keyvalue = KEY -> KEY_DATA;
 //   nixie_display_num(0Xd,4);
    }
   while(zero!=0)    //等待寄存器归零
   {
     zero = KEY -> KEY_DATA;
   }
  delay_ms(20);
    
      
  return keyvalue;
}
u32 KeyValue_Tranformation(u32 keyvalue)
{
    if(keyvalue==0x2)
    {
        return 9;
    }
    else if(keyvalue==0x3)
    {
        return 8;
    }
    else if(keyvalue==0x4)
    {
        return 7;
    }
    else if(keyvalue==0x6)
    {
        return 6;
    }
    else if(keyvalue==0x7)
    {
        return 5;
    }
    else if(keyvalue==0x8)
    {
        return 4;
    }
    else if(keyvalue==0xA)
    {
        return 3;
    }
    else if(keyvalue==0xB)
    {
        return 2;
    }
    else if(keyvalue==0xC)
    {
        return 1;
    }
    else if(keyvalue==0xF)
    {
        return 0;
    }
    else if(keyvalue==0xD)
    {
        return 10;//直接取台
    }   
    else if(keyvalue==0x10)
    {
        return 40;
    }
    else if(keyvalue==0xE)
    {
        return 50;
    }
    else if(keyvalue==0x9)
    {
        return 60;
    }
     else if(keyvalue==0x5)
    {
        return 70;
    }
     else if(keyvalue==0x1)
    {
        return 80;
    }
    
}
u32 GetKEYNUM()
{
    return KeyValue_Tranformation(Get_Key_Value(SEGKEY));
}
u32 Type_NUM()
{
    u32 num=0,n=1,temp=20,a1=30;
    SEG_Clear_all();
    Standby();//此处显示选台待机模式；
  //  delay_ms(200);
    // 第一次键入
    temp = GetKEYNUM();
    SEG_Clear_all();
    if(temp<=9)
      {
            num+=temp;
            nixie_display_num(temp,n);
            n++;
            temp=20;
        }
        else if(temp == 10)
        {
            return FM_Value;
        }
    
  
      //第二次键入
    temp = GetKEYNUM();
    if(temp<=9)
    {
        nixie_display_num(num,n);
        num = num*10+temp;
        nixie_display_num(temp,n-1);
        n++;   
        temp=20;      
    }
    else if(temp == 10)
    {
        return FM_Value;
    }
    

       //第三次键入 
    temp = GetKEYNUM();
    if(temp<=9)
    {
        nixie_display_num(num/10,n);
        nixie_display_num(num%10,n-1);
        num = num*10+temp;
        nixie_display_num(temp,n-2);
        n++; 
        temp=20;        
    }
    else if(temp == 10)
    {
        return FM_Value;
    }
           
        //第四次键入
    temp = GetKEYNUM();
    if(temp<=9)
    {
        nixie_display_num(num/100,n);
        nixie_display_num(num/10%10,n-1);
        nixie_display_num(num%10,n-2);
        num = num*10+temp;
        nixie_display_num(temp,n-3);
        n++;    
            temp=20;
          
    }
    else if(temp == 10)
    {
        return num;
    }
    
      //第五次键入
    temp = GetKEYNUM();
    if(temp<=9)
    {
        num=0;
        temp=20;
        return FM_Value;
        
    }
    else if(temp == 10)
    {
        return num;
    }
    

}
void START_AND_STOP(u8 state)
{
    if(state == 1)
    {
    BASEBAND->PWM_CONTROL=0x0003;
    }
    else if(state == 0)
    {
    BASEBAND->PWM_CONTROL=0x00000;
    }
		else if(state == 2)
    {
    BASEBAND->PWM_CONTROL=0x0005;
    }
		else if(state == 3)
    {
    BASEBAND->PWM_CONTROL=0x0009;
    }
		else if(state == 4)
    {
    BASEBAND->PWM_CONTROL=0x0011;
    }
		else if(state == 5)
    {
    BASEBAND->PWM_CONTROL=0x0021;
    }
		
}