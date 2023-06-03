#ifndef __24CXX_H
#define __24CXX_H
#include "sys.h"   
#define AT24C01		127
#define AT24C02		255
#define AT24C04		511
#define AT24C08		1023
#define AT24C16		2047
#define AT24C32		4095
#define AT24C64	    8191
#define AT24C128	16383
#define AT24C256	32767  
#define EE_TYPE AT24C02

//IO��������
#define AT_SDA_IN()     CMSDK_gpio_SetOutEnable(GPIO0, GPIO_Pin_7,0)
#define AT_SDA_OUT()    CMSDK_gpio_SetOutEnable(GPIO0, GPIO_Pin_7,1)

//IO��������	 
#define AT_IIC_SCL_H    GPIO_SetBits(GPIO0, GPIO_Pin_8) //SCL
#define AT_IIC_SDA_H    GPIO_SetBits(GPIO0, GPIO_Pin_7)//SDA	 

#define AT_IIC_SCL_L    GPIO_ResetBits(GPIO0, GPIO_Pin_8) //SCL
#define AT_IIC_SDA_L    GPIO_ResetBits(GPIO0, GPIO_Pin_7) //SDA

#define AT_READ_SDA     CMSDK_gpio_ReadBit(GPIO0, GPIO_Pin_7) //����SDA ��ȡSDA���ܵ�ƽ


u8 AT24CXX_ReadOneByte(u16 ReadAddr);							//ָ����ַ��ȡһ���ֽ�
void AT24CXX_WriteOneByte(u16 WriteAddr,u8 DataToWrite);		//ָ����ַд��һ���ֽ�
void AT24CXX_WriteLenByte(u16 WriteAddr,u32 DataToWrite,u8 Len);//ָ����ַ��ʼд��ָ�����ȵ�����
u32 AT24CXX_ReadLenByte(u16 ReadAddr,u8 Len);					//ָ����ַ��ʼ��ȡָ����������
void AT24CXX_Write(u16 WriteAddr,u8 *pBuffer,u16 NumToWrite);	//��ָ����ַ��ʼд��ָ�����ȵ�����
void AT24CXX_Read(u16 ReadAddr,u8 *pBuffer,u16 NumToRead);   	//��ָ����ַ��ʼ����ָ�����ȵ�����

//IIC���в�������
void AT24CXX_Init(void);              //��ʼ��IIC��IO��				 
void AT_IIC_Start(void);				//����IIC��ʼ�ź�
void AT_IIC_Stop(void);	  			//����IICֹͣ�ź�
void AT_IIC_Send_Byte(u8 txd);			//IIC����һ���ֽ�
u8 AT_IIC_Read_Byte(unsigned char ack);//IIC��ȡһ���ֽ�
u8 AT_IIC_Wait_Ack(void); 				//IIC�ȴ�ACK�ź�
void AT_IIC_Ack(void);					//IIC����ACK�ź�
void AT_IIC_NAck(void);				//IIC������ACK�ź�
u8 AT24CXX_Check(void);


#endif
















