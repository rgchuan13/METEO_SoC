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
    MSI001_CS_L;//Ƭѡ����
	MSI001_CLK_L; //���е�ƽ(Ĭ�ϳ�ʼ�����)
	for(i=0;i<20;i++)
	{
		//����ǰ��ʮλ����
		MSI001_CLK_L;//ʱ������,׼������
		if(tx_data&0x80000)MSI001_DATA_H; //��������
		else  MSI001_DATA_L;
       delay_us(1);
		MSI001_CLK_H; //����һλ���ݷ������
       delay_us(1);
		tx_data<<=1; //����������һλ	     
	}
    for(i=0;i<4;i++)
    {
        //���ͺ���λ��ַ
        MSI001_CLK_L;//ʱ������,׼������
        if(addr&(0x8))MSI001_DATA_H; //��������
		else MSI001_DATA_L;
       delay_us(1);
        MSI001_CLK_H; //����һλ���ݷ������
       delay_us(1);
		addr<<=1; //����������һλ	     
    }
	MSI001_CLK_L; //�ָ����е�ƽ
    MSI001_CS_H;//Ƭѡ�ر�
}
void FM_Select(u32 fm)
{
    float INT_1,FARC,fm1;
    int INT_2;
    u32 value;
    fm1 = (float)fm/10;
    INT_1 = (fm1*32)/(4*24);
    INT_2 = (int)INT_1;//����ȡ��
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
    








