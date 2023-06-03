#include "msi001.h"
#include "delay.h"

void MSI001_Init(void)
{	
   CMSDK_GPIO_TypeDef GPIO_TypeDefStructure;
  CMSDK_GPIO0->DATAOUT &= ~(0x01UL);        // Set data ouput to 0
  CMSDK_GPIO0->OUTENABLESET   |= 0x1UL;     // Enable bit 0 as output
  CMSDK_GPIO0->DATAOUT &= ~(0x02UL);        // Set data ouput to 0
  CMSDK_GPIO0->OUTENABLESET   |= 0x2UL;     // Enable bit 0 as output
  CMSDK_GPIO0->DATAOUT &= ~(0x04UL);        // Set data ouput to 0
  CMSDK_GPIO0->OUTENABLESET   |= 0x4UL;     // Enable bit 0 as output
    
    
    MSI001_Write(0x28bb8,RF_Synthesizer_ConfigurationReg5);
    MSI001_Write(0x20001,DC_Offset_Calibration_setupReg06);
    MSI001_Write(0x04342,IC_modeReg0);
    MSI001_Write(0x00FA0,LO_Trim_ControlReg3);

}  
void MSI001_Write(u32 tx_data,u8 addr)
{
	u8 i;
    MSI001_CS_L;//片选开启
	MSI001_CLK_L; //空闲电平(默认初始化情况)
	for(i=0;i<20;i++)
	{
		//发送前二十位数据
		MSI001_CLK_L;//时钟拉低,准备发送
		if(tx_data&0x80000)MSI001_DATA_H; //发送数据
		else  MSI001_DATA_L;
       delay_us(1);
		MSI001_CLK_H; //主机一位数据发送完毕
       delay_us(1);
		tx_data<<=1; //继续发送下一位	     
	}
    for(i=0;i<4;i++)
    {
        //发送后四位地址
        MSI001_CLK_L;//时钟拉低,准备发送
        if(addr&(0x8))MSI001_DATA_H; //发送数据
		else MSI001_DATA_L;
       delay_us(1);
        MSI001_CLK_H; //主机一位数据发送完毕
       delay_us(1);
		addr<<=1; //继续发送下一位	     
    }
	MSI001_CLK_L; //恢复空闲电平
    MSI001_CS_H;//片选关闭
}
void FM_Select(u32 fm)
{
    float INT_1,FARC,fm1;
    int INT_2;
    u32 value;
    fm1 = (float)fm/10;
    INT_1 = (fm1*32)/(4*24);
    INT_2 = (int)INT_1;//向下取整
    FARC = (INT_1 - INT_2)*3000;
    value = ((u32)INT_2<<=12)+(u32)FARC;
    MSI001_Write(value,Synthesizer_programmingReg2);
}
void Damping_Control(u16 Damp)
{
    u32 data;    
    data = Damp+0xc00;
    MSI001_Write(data,Receiver_gain_controlReg1);
}
    








