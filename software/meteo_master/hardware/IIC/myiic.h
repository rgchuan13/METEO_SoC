#ifndef __MYIIC_H
#define __MYIIC_H
#include "meteo.h"
#include "sys.h"


//IO��������
 
#define SDA_IN()     CMSDK_gpio_SetOutEnable(GPIO0, GPIO_Pin_4,0)
#define SDA_OUT()    CMSDK_gpio_SetOutEnable(GPIO0, GPIO_Pin_4,1)
//IO��������	 
#define IIC_SCL_H    GPIO_SetBits(GPIO0, GPIO_Pin_3) //SCL
#define IIC_SDA_H    GPIO_SetBits(GPIO0, GPIO_Pin_4)//SDA	 

#define IIC_SCL_L    GPIO_ResetBits(GPIO0, GPIO_Pin_3) //SCL
#define IIC_SDA_L    GPIO_ResetBits(GPIO0, GPIO_Pin_4) //SDA

#define READ_SDA     CMSDK_gpio_ReadBit(GPIO0, GPIO_Pin_4) //����SDA ��ȡSDA���ܵ�ƽ

//IIC���в�������
void IIC_Init(void);                //��ʼ��IIC��IO��				 
void IIC_Start(void);				//����IIC��ʼ�ź�
void IIC_Stop(void);	  			//����IICֹͣ�ź�
void IIC_Send_Byte(u8 txd);			//IIC����һ���ֽ�
u8 IIC_Read_Byte(unsigned char ack);//IIC��ȡһ���ֽ�
u8 IIC_Wait_Ack(void); 				//IIC�ȴ�ACK�ź�
void IIC_Ack(void);					//IIC����ACK�ź�
void IIC_NAck(void);				//IIC������ACK�ź�

void IIC_Write_One_Byte(u8 daddr,u8 addr,u8 data);
u8 IIC_Read_One_Byte(u8 daddr,u8 addr);	  
#endif
















