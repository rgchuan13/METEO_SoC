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

//IO方向设置
#define AT_SDA_IN()     CMSDK_gpio_SetOutEnable(GPIO0, GPIO_Pin_7,0)
#define AT_SDA_OUT()    CMSDK_gpio_SetOutEnable(GPIO0, GPIO_Pin_7,1)

//IO操作函数	 
#define AT_IIC_SCL_H    GPIO_SetBits(GPIO0, GPIO_Pin_8) //SCL
#define AT_IIC_SDA_H    GPIO_SetBits(GPIO0, GPIO_Pin_7)//SDA	 

#define AT_IIC_SCL_L    GPIO_ResetBits(GPIO0, GPIO_Pin_8) //SCL
#define AT_IIC_SDA_L    GPIO_ResetBits(GPIO0, GPIO_Pin_7) //SDA

#define AT_READ_SDA     CMSDK_gpio_ReadBit(GPIO0, GPIO_Pin_7) //输入SDA 读取SDA接受电平


u8 AT24CXX_ReadOneByte(u16 ReadAddr);							//指定地址读取一个字节
void AT24CXX_WriteOneByte(u16 WriteAddr,u8 DataToWrite);		//指定地址写入一个字节
void AT24CXX_WriteLenByte(u16 WriteAddr,u32 DataToWrite,u8 Len);//指定地址开始写入指定长度的数据
u32 AT24CXX_ReadLenByte(u16 ReadAddr,u8 Len);					//指定地址开始读取指定长度数据
void AT24CXX_Write(u16 WriteAddr,u8 *pBuffer,u16 NumToWrite);	//从指定地址开始写入指定长度的数据
void AT24CXX_Read(u16 ReadAddr,u8 *pBuffer,u16 NumToRead);   	//从指定地址开始读出指定长度的数据

//IIC所有操作函数
void AT24CXX_Init(void);              //初始化IIC的IO口				 
void AT_IIC_Start(void);				//发送IIC开始信号
void AT_IIC_Stop(void);	  			//发送IIC停止信号
void AT_IIC_Send_Byte(u8 txd);			//IIC发送一个字节
u8 AT_IIC_Read_Byte(unsigned char ack);//IIC读取一个字节
u8 AT_IIC_Wait_Ack(void); 				//IIC等待ACK信号
void AT_IIC_Ack(void);					//IIC发送ACK信号
void AT_IIC_NAck(void);				//IIC不发送ACK信号
u8 AT24CXX_Check(void);


#endif
















