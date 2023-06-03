#ifndef __MYIIC_H
#define __MYIIC_H
#include "meteo.h"
#include "sys.h"


//IO方向设置
 
#define SDA_IN()     CMSDK_gpio_SetOutEnable(GPIO0, GPIO_Pin_4,0)
#define SDA_OUT()    CMSDK_gpio_SetOutEnable(GPIO0, GPIO_Pin_4,1)
//IO操作函数	 
#define IIC_SCL_H    GPIO_SetBits(GPIO0, GPIO_Pin_3) //SCL
#define IIC_SDA_H    GPIO_SetBits(GPIO0, GPIO_Pin_4)//SDA	 

#define IIC_SCL_L    GPIO_ResetBits(GPIO0, GPIO_Pin_3) //SCL
#define IIC_SDA_L    GPIO_ResetBits(GPIO0, GPIO_Pin_4) //SDA

#define READ_SDA     CMSDK_gpio_ReadBit(GPIO0, GPIO_Pin_4) //输入SDA 读取SDA接受电平

//IIC所有操作函数
void IIC_Init(void);                //初始化IIC的IO口				 
void IIC_Start(void);				//发送IIC开始信号
void IIC_Stop(void);	  			//发送IIC停止信号
void IIC_Send_Byte(u8 txd);			//IIC发送一个字节
u8 IIC_Read_Byte(unsigned char ack);//IIC读取一个字节
u8 IIC_Wait_Ack(void); 				//IIC等待ACK信号
void IIC_Ack(void);					//IIC发送ACK信号
void IIC_NAck(void);				//IIC不发送ACK信号

void IIC_Write_One_Byte(u8 daddr,u8 addr,u8 data);
u8 IIC_Read_One_Byte(u8 daddr,u8 addr);	  
#endif
















