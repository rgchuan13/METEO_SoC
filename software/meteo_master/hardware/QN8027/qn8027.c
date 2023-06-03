#include "qn8027.h"
#include "myiic.h"
#include "delay.h"

//��ʼ��IIC�ӿ�
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

//��QN8027ָ����ַ����һ������
//ReadAddr:��ʼ�����ĵ�ַ  
//����ֵ  :����������
u8 QN8027_ReadOneByte(u16 ReadAddr)
{				  
	u8 temp=0;		  	    																 
    IIC_Start();  
	IIC_Send_Byte(0X58+((ReadAddr/256)<<1));   //����������ַ0X58,д���� 	 

	IIC_Wait_Ack(); 
    IIC_Send_Byte(ReadAddr%256);   //���͵͵�ַ
	IIC_Wait_Ack();	    
	IIC_Start();  	 	   
	IIC_Send_Byte(0X59);           //�������ģʽ			   
	IIC_Wait_Ack();	 
    temp=IIC_Read_Byte(0);		   
    IIC_Stop();//����һ��ֹͣ����	    
	return temp;
}
//��QN8027ָ����ַд��һ������
//WriteAddr  :д�����ݵ�Ŀ�ĵ�ַ    
//DataToWrite:Ҫд�������
void QN8027_WriteOneByte(u16 WriteAddr,u8 DataToWrite)
{				   	  	    																 
    IIC_Start();  
	
    IIC_Send_Byte(0X58+((WriteAddr/256)<<1));   //����������ַ0X58,д���� 
	
  //   delay_us(2); 
    
    IIC_Wait_Ack();  
    delay_us(2);
    IIC_Send_Byte(WriteAddr%256);   //���͵͵�ַ
    IIC_Wait_Ack(); 	      
	IIC_Send_Byte(DataToWrite);     //�����ֽ�							   
    IIC_Wait_Ack();      
    IIC_Stop();//����һ��ֹͣ���� 
	delay_ms(10);	 
}


