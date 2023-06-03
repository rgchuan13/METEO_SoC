#include "24cxx.h" 
#include "delay.h" 

//1初始化IIC

void AT24CXX_Init(void)
{					     
    CMSDK_gpio_SetOutEnable(GPIO0, GPIO_Pin_7,1);//设置为输出
    CMSDK_gpio_SetOutEnable(GPIO0, GPIO_Pin_8,1);
    AT_IIC_SCL_H;
    AT_IIC_SDA_H;  
}
//产1生IIC起始信号
void AT_IIC_Start(void)
{
	AT_SDA_OUT();     //sda线输出 
    delay_us(2);
	AT_IIC_SDA_H;	  	  
	AT_IIC_SCL_H;
	delay_us(4);
 	AT_IIC_SDA_L;
	delay_us(4);
	AT_IIC_SCL_L;
}	  
//产生IIC停止信号
void AT_IIC_Stop(void)
{
	AT_SDA_OUT();//sda线输出
    delay_us(2);
	AT_IIC_SCL_L;
	AT_IIC_SDA_L;
 	delay_us(4);
	AT_IIC_SCL_H; 
	AT_IIC_SDA_H;//发送I2C总线结束信号
	delay_us(4);							   	
}
//等待应答信号到来
//返回值：1，接收应答失败
//        0，接收应答成功
u8 AT_IIC_Wait_Ack(void)
{
	u8 ucErrTime=0;
  //  AT_SDA_IN();      //SDA设置为输入  
    delay_us(3);	    
	AT_IIC_SDA_H;delay_us(1);	   
	AT_IIC_SCL_H;delay_us(1);	
    //SDA_IN();      //SDA设置为输入 
   AT_SDA_IN();      //SDA设置为输入    
	while(AT_READ_SDA)
	{
		ucErrTime++;
		if(ucErrTime>250)
		{
			AT_IIC_Stop();
			return 1;
		}
	}
	AT_IIC_SCL_L;//时钟输出0 	   
	return 0;  
//    AT_IIC_SCL_H;
//    AT_IIC_SCL_L;
} 
//产生ACK应答
void AT_IIC_Ack(void)
{
	AT_IIC_SCL_L;
	AT_SDA_OUT();
    delay_us(5);
	AT_IIC_SDA_L;
	delay_us(2);
	AT_IIC_SCL_H;
	delay_us(2);
	AT_IIC_SCL_L;
}
//不产生ACK应答		    
void AT_IIC_NAck(void)
{
	AT_IIC_SCL_L;
	AT_SDA_OUT();
	AT_IIC_SDA_H;
	delay_us(2);
	AT_IIC_SCL_H;
	delay_us(2);
	AT_IIC_SCL_L;
}					 				     
//IIC发送一个字节
//返回从机有无应答
//1，有应答
//0，无应答			  
void AT_IIC_Send_Byte(u8 txd)
{                        
    u8 t;   
	AT_SDA_OUT(); 	    
    AT_IIC_SCL_L;//拉低时钟开始数据传输
    for(t=0;t<8;t++)
    {     
        if(((txd&0x80)>>7)!=0)
        {   
            AT_IIC_SDA_H;
        }
        else 
        { 
            AT_IIC_SDA_L;
            
           }
//        IIC_SDA=(txd&0x80)>>7;
        txd<<=1; 	  
		delay_us(2);   
		AT_IIC_SCL_H;
		delay_us(2); 
		AT_IIC_SCL_L;	
		delay_ms(1);
    }	 
} 	    
//读1个字节，ack=1时，发送ACK，ack=0，发送nACK   
u8 AT_IIC_Read_Byte(unsigned char ack)
{
	unsigned char i,receive=0;
	AT_SDA_IN();//SDA设置为输入
    delay_us(5);
    for(i=0;i<8;i++ )
	{
        AT_IIC_SCL_L; 
        delay_us(2);
		AT_IIC_SCL_H;
        receive<<=1;
        if(AT_READ_SDA)receive++;   
		delay_ms(1); 
    }					 
    if (!ack)
        AT_IIC_NAck();//发送nACK
    else
        AT_IIC_Ack(); //发送ACK   
    return receive;
}


//在AT24CXX指定地址读出一个数据
//ReadAddr:开始读数的地址  
//返回值  :读到的数据
u8 AT24CXX_ReadOneByte(u16 ReadAddr)
{				  
	u8 temp=0;		  	    																 
    AT_IIC_Start();  
	if(EE_TYPE>AT24C16)
	{
		AT_IIC_Send_Byte(0XA0);	   //发送写命令
		AT_IIC_Wait_Ack();
		AT_IIC_Send_Byte(ReadAddr>>8);//发送高地址
		AT_IIC_Wait_Ack();		 
	}else AT_IIC_Send_Byte(0XA0+((ReadAddr/256)<<1));   //发送器件地址0XA0,写数据 	 

	AT_IIC_Wait_Ack(); 
    AT_IIC_Send_Byte(ReadAddr%256);   //发送低地址
	AT_IIC_Wait_Ack();	    
	AT_IIC_Start();  	 	   
	AT_IIC_Send_Byte(0XA1);           //进入接收模式			   
	AT_IIC_Wait_Ack();	 
    temp=AT_IIC_Read_Byte(0);		   
    AT_IIC_Stop();//产生一个停止条件	    
	return temp;
}
//在AT24CXX指定地址写入一个数据
//WriteAddr  :写入数据的目的地址    
//DataToWrite:要写入的数据
void AT24CXX_WriteOneByte(u16 WriteAddr,u8 DataToWrite)
{				   	  	    																 
    AT_IIC_Start();  
	if(EE_TYPE>AT24C16)
	{
		AT_IIC_Send_Byte(0XA0);	    //发送写命令
		AT_IIC_Wait_Ack();
		AT_IIC_Send_Byte(WriteAddr>>8);//发送高地址
 	}else
	{
		AT_IIC_Send_Byte(0XA0+((WriteAddr/256)<<1));   //发送器件地址0XA0,写数据 
	}	 
	AT_IIC_Wait_Ack();	   
    AT_IIC_Send_Byte(WriteAddr%256);   //发送低地址
	AT_IIC_Wait_Ack(); 	 										  		   
	AT_IIC_Send_Byte(DataToWrite);     //发送字节							   
	AT_IIC_Wait_Ack();  		    	   
    AT_IIC_Stop();//产生一个停止条件 
	delay_ms(10);	 
}
//在AT24CXX里面的指定地址开始写入长度为Len的数据
//该函数用于写入16bit或者32bit的数据.
//WriteAddr  :开始写入的地址  
//DataToWrite:数据数组首地址
//Len        :要写入数据的长度2,4
void AT24CXX_WriteLenByte(u16 WriteAddr,u32 DataToWrite,u8 Len)
{  	
	u8 t;
	for(t=0;t<Len;t++)
	{
		AT24CXX_WriteOneByte(WriteAddr+t,(DataToWrite>>(8*t))&0xff);
	}												    
}

//在AT24CXX里面的指定地址开始读出长度为Len的数据
//该函数用于读出16bit或者32bit的数据.
//ReadAddr   :开始读出的地址 
//返回值     :数据
//Len        :要读出数据的长度2,4
u32 AT24CXX_ReadLenByte(u16 ReadAddr,u8 Len)
{  	
	u8 t;
	u32 temp=0;
	for(t=0;t<Len;t++)
	{
		temp<<=8;
		temp+=AT24CXX_ReadOneByte(ReadAddr+Len-t-1); 	 				   
	}
	return temp;												    
}
//检查AT24CXX是否正常
//这里用了24XX的最后一个地址(255)来存储标志字.
//如果用其他24C系列,这个地址要修改
//返回1:检测失败
//返回0:检测成功
u8 AT24CXX_Check(void)
{
	u8 temp;
	temp=AT24CXX_ReadOneByte(255);//避免每次开机都写AT24CXX			   
	if(temp==0X55)return 0;		   
	else//排除第一次初始化的情况
	{
		AT24CXX_WriteOneByte(255,0X55);
	    temp=AT24CXX_ReadOneByte(255);	  
		if(temp==0X55)return 0;
	}
	return 1;											  
}

//在AT24CXX里面的指定地址开始读出指定个数的数据
//ReadAddr :开始读出的地址 对24c02为0~255
//pBuffer  :数据数组首地址
//NumToRead:要读出数据的个数
void AT24CXX_Read(u16 ReadAddr,u8 *pBuffer,u16 NumToRead)
{
	while(NumToRead)
	{
		*pBuffer++=AT24CXX_ReadOneByte(ReadAddr++);	
		NumToRead--;
	}
}  
//在AT24CXX里面的指定地址开始写入指定个数的数据
//WriteAddr :开始写入的地址 对24c02为0~255
//pBuffer   :数据数组首地址
//NumToWrite:要写入数据的个数
void AT24CXX_Write(u16 WriteAddr,u8 *pBuffer,u16 NumToWrite)
{
	while(NumToWrite--)
	{
		AT24CXX_WriteOneByte(WriteAddr,*pBuffer);
		WriteAddr++;
		pBuffer++;
	}
}
 











