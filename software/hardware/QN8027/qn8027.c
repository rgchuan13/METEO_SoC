#include "qn8027.h"
#include "myiic.h"
#include "delay.h"

//初始化IIC接口
void QN8027_Init(void)
{
	IIC_Init();
    
    QN8027_WriteOneByte(0x00,0x30);
    QN8027_WriteOneByte(0x00,0x30);
    QN8027_WriteOneByte(0x01,0x0A);    
    QN8027_WriteOneByte(0x02,0xB9);
    QN8027_WriteOneByte(0x03,0x80);
    QN8027_WriteOneByte(0x04,0xB2); 
    QN8027_WriteOneByte(0x10,0x32); 
    QN8027_WriteOneByte(0x11,0x81); 
}

//在QN8027指定地址读出一个数据
//ReadAddr:开始读数的地址  
//返回值  :读到的数据
u8 QN8027_ReadOneByte(u16 ReadAddr)
{				  
	u8 temp=0;		  	    																 
    IIC_Start();  
	IIC_Send_Byte(0X58+((ReadAddr/256)<<1));   //发送器件地址0X58,写数据 	 

	IIC_Wait_Ack(); 
    IIC_Send_Byte(ReadAddr%256);   //发送低地址
	IIC_Wait_Ack();	    
	IIC_Start();  	 	   
	IIC_Send_Byte(0X59);           //进入接收模式			   
	IIC_Wait_Ack();	 
    temp=IIC_Read_Byte(0);		   
    IIC_Stop();//产生一个停止条件	    
	return temp;
}
//在QN8027指定地址写入一个数据
//WriteAddr  :写入数据的目的地址    
//DataToWrite:要写入的数据
void QN8027_WriteOneByte(u16 WriteAddr,u8 DataToWrite)
{				   	  	    																 
    IIC_Start();  
	
    IIC_Send_Byte(0X58+((WriteAddr/256)<<1));   //发送器件地址0X58,写数据 
	
  //   delay_us(2); 
    
    IIC_Wait_Ack();  
    delay_us(2);
    IIC_Send_Byte(WriteAddr%256);   //发送低地址
    IIC_Wait_Ack(); 	      
	IIC_Send_Byte(DataToWrite);     //发送字节							   
    IIC_Wait_Ack();      
    IIC_Stop();//产生一个停止条件 
	delay_ms(10);	 
}


