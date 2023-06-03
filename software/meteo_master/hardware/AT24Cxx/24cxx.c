#include "24cxx.h" 
#include "delay.h" 

//1��ʼ��IIC

void AT24CXX_Init(void)
{					     
    CMSDK_gpio_SetOutEnable(GPIO0, GPIO_Pin_7,1);//����Ϊ���
    CMSDK_gpio_SetOutEnable(GPIO0, GPIO_Pin_8,1);
    AT_IIC_SCL_H;
    AT_IIC_SDA_H;  
}
//��1��IIC��ʼ�ź�
void AT_IIC_Start(void)
{
	AT_SDA_OUT();     //sda����� 
    delay_us(2);
	AT_IIC_SDA_H;	  	  
	AT_IIC_SCL_H;
	delay_us(4);
 	AT_IIC_SDA_L;
	delay_us(4);
	AT_IIC_SCL_L;
}	  
//����IICֹͣ�ź�
void AT_IIC_Stop(void)
{
	AT_SDA_OUT();//sda�����
    delay_us(2);
	AT_IIC_SCL_L;
	AT_IIC_SDA_L;
 	delay_us(4);
	AT_IIC_SCL_H; 
	AT_IIC_SDA_H;//����I2C���߽����ź�
	delay_us(4);							   	
}
//�ȴ�Ӧ���źŵ���
//����ֵ��1������Ӧ��ʧ��
//        0������Ӧ��ɹ�
u8 AT_IIC_Wait_Ack(void)
{
	u8 ucErrTime=0;
  //  AT_SDA_IN();      //SDA����Ϊ����  
    delay_us(3);	    
	AT_IIC_SDA_H;delay_us(1);	   
	AT_IIC_SCL_H;delay_us(1);	
    //SDA_IN();      //SDA����Ϊ���� 
   AT_SDA_IN();      //SDA����Ϊ����    
	while(AT_READ_SDA)
	{
		ucErrTime++;
		if(ucErrTime>250)
		{
			AT_IIC_Stop();
			return 1;
		}
	}
	AT_IIC_SCL_L;//ʱ�����0 	   
	return 0;  
//    AT_IIC_SCL_H;
//    AT_IIC_SCL_L;
} 
//����ACKӦ��
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
//������ACKӦ��		    
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
//IIC����һ���ֽ�
//���شӻ�����Ӧ��
//1����Ӧ��
//0����Ӧ��			  
void AT_IIC_Send_Byte(u8 txd)
{                        
    u8 t;   
	AT_SDA_OUT(); 	    
    AT_IIC_SCL_L;//����ʱ�ӿ�ʼ���ݴ���
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
//��1���ֽڣ�ack=1ʱ������ACK��ack=0������nACK   
u8 AT_IIC_Read_Byte(unsigned char ack)
{
	unsigned char i,receive=0;
	AT_SDA_IN();//SDA����Ϊ����
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
        AT_IIC_NAck();//����nACK
    else
        AT_IIC_Ack(); //����ACK   
    return receive;
}


//��AT24CXXָ����ַ����һ������
//ReadAddr:��ʼ�����ĵ�ַ  
//����ֵ  :����������
u8 AT24CXX_ReadOneByte(u16 ReadAddr)
{				  
	u8 temp=0;		  	    																 
    AT_IIC_Start();  
	if(EE_TYPE>AT24C16)
	{
		AT_IIC_Send_Byte(0XA0);	   //����д����
		AT_IIC_Wait_Ack();
		AT_IIC_Send_Byte(ReadAddr>>8);//���͸ߵ�ַ
		AT_IIC_Wait_Ack();		 
	}else AT_IIC_Send_Byte(0XA0+((ReadAddr/256)<<1));   //����������ַ0XA0,д���� 	 

	AT_IIC_Wait_Ack(); 
    AT_IIC_Send_Byte(ReadAddr%256);   //���͵͵�ַ
	AT_IIC_Wait_Ack();	    
	AT_IIC_Start();  	 	   
	AT_IIC_Send_Byte(0XA1);           //�������ģʽ			   
	AT_IIC_Wait_Ack();	 
    temp=AT_IIC_Read_Byte(0);		   
    AT_IIC_Stop();//����һ��ֹͣ����	    
	return temp;
}
//��AT24CXXָ����ַд��һ������
//WriteAddr  :д�����ݵ�Ŀ�ĵ�ַ    
//DataToWrite:Ҫд�������
void AT24CXX_WriteOneByte(u16 WriteAddr,u8 DataToWrite)
{				   	  	    																 
    AT_IIC_Start();  
	if(EE_TYPE>AT24C16)
	{
		AT_IIC_Send_Byte(0XA0);	    //����д����
		AT_IIC_Wait_Ack();
		AT_IIC_Send_Byte(WriteAddr>>8);//���͸ߵ�ַ
 	}else
	{
		AT_IIC_Send_Byte(0XA0+((WriteAddr/256)<<1));   //����������ַ0XA0,д���� 
	}	 
	AT_IIC_Wait_Ack();	   
    AT_IIC_Send_Byte(WriteAddr%256);   //���͵͵�ַ
	AT_IIC_Wait_Ack(); 	 										  		   
	AT_IIC_Send_Byte(DataToWrite);     //�����ֽ�							   
	AT_IIC_Wait_Ack();  		    	   
    AT_IIC_Stop();//����һ��ֹͣ���� 
	delay_ms(10);	 
}
//��AT24CXX�����ָ����ַ��ʼд�볤��ΪLen������
//�ú�������д��16bit����32bit������.
//WriteAddr  :��ʼд��ĵ�ַ  
//DataToWrite:���������׵�ַ
//Len        :Ҫд�����ݵĳ���2,4
void AT24CXX_WriteLenByte(u16 WriteAddr,u32 DataToWrite,u8 Len)
{  	
	u8 t;
	for(t=0;t<Len;t++)
	{
		AT24CXX_WriteOneByte(WriteAddr+t,(DataToWrite>>(8*t))&0xff);
	}												    
}

//��AT24CXX�����ָ����ַ��ʼ��������ΪLen������
//�ú������ڶ���16bit����32bit������.
//ReadAddr   :��ʼ�����ĵ�ַ 
//����ֵ     :����
//Len        :Ҫ�������ݵĳ���2,4
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
//���AT24CXX�Ƿ�����
//��������24XX�����һ����ַ(255)���洢��־��.
//���������24Cϵ��,�����ַҪ�޸�
//����1:���ʧ��
//����0:���ɹ�
u8 AT24CXX_Check(void)
{
	u8 temp;
	temp=AT24CXX_ReadOneByte(255);//����ÿ�ο�����дAT24CXX			   
	if(temp==0X55)return 0;		   
	else//�ų���һ�γ�ʼ�������
	{
		AT24CXX_WriteOneByte(255,0X55);
	    temp=AT24CXX_ReadOneByte(255);	  
		if(temp==0X55)return 0;
	}
	return 1;											  
}

//��AT24CXX�����ָ����ַ��ʼ����ָ������������
//ReadAddr :��ʼ�����ĵ�ַ ��24c02Ϊ0~255
//pBuffer  :���������׵�ַ
//NumToRead:Ҫ�������ݵĸ���
void AT24CXX_Read(u16 ReadAddr,u8 *pBuffer,u16 NumToRead)
{
	while(NumToRead)
	{
		*pBuffer++=AT24CXX_ReadOneByte(ReadAddr++);	
		NumToRead--;
	}
}  
//��AT24CXX�����ָ����ַ��ʼд��ָ������������
//WriteAddr :��ʼд��ĵ�ַ ��24c02Ϊ0~255
//pBuffer   :���������׵�ַ
//NumToWrite:Ҫд�����ݵĸ���
void AT24CXX_Write(u16 WriteAddr,u8 *pBuffer,u16 NumToWrite)
{
	while(NumToWrite--)
	{
		AT24CXX_WriteOneByte(WriteAddr,*pBuffer);
		WriteAddr++;
		pBuffer++;
	}
}
 











