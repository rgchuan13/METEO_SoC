#include "delay.h"

 volatile int32_t SysTickCntr=0;
//void delay_Init()
//{
//    SysTick_Config((SystemCoreClock/1000)-1); // 1KHz Ticks
//}
void delay_us(int32_t tnum)
{    
   u16 i=0;  
   while(tnum--)
   {
      i=4;  
      while(i--) ;    
   }
    
    SysTickCntr=0;
    
    while(SysTickCntr==48);
}
void delay_ms(int32_t tnum)
{    
   u16 i=0;  
   while(tnum--)
   {
      i=6853;  
      while(i--) ;    
   }

}
void SysTick_Handler(void)
{
  SysTickCntr++ ;
  return;
}