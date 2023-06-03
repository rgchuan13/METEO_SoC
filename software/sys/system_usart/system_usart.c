#include "system_usart.h"
#include <stdlib.h>
/**
 *
 * @brief   ��ʼ��UART��ָ��UART�����ʷָ���ֵ�Լ��Ƿ����÷��ͺͽ��չ��ܡ�����ָ����������Щ�жϡ�
 *   
 * @param ����ָ��
 * @param �����ʷָ����趨
 * @param tx_en�����Ƿ�ʹ��UART����
 * @param rx_en�����Ƿ�ʹ��UART����
 * @param tx_irq_en�����Ƿ�����UART���仺����ȫ�ж�
 * @param rx_irq_en�����Ƿ�����UART���ջ�����ȫ�ж�
 * @param tx_ovrirq_en�����Ƿ�����UART���仺��������ж�
 * @param rx_ovrirq_en�����Ƿ�����UART���ջ���������ж�
 * @return ��ʼ��ʧ��Ϊ1���ɹ�Ϊ0��
 */

 uint32_t CMSDK_uart_init(CMSDK_UART_TypeDef* CMSDK_UART, uint32_t divider, uint32_t tx_en,
                           uint32_t rx_en, uint32_t tx_irq_en, uint32_t rx_irq_en, uint32_t tx_ovrirq_en, uint32_t rx_ovrirq_en)
 {
       uint32_t new_ctrl=0;

       if (tx_en!=0)        new_ctrl |= CMSDK_UART_CTRL_TXEN_Msk;
       if (rx_en!=0)        new_ctrl |= CMSDK_UART_CTRL_RXEN_Msk;
       if (tx_irq_en!=0)    new_ctrl |= CMSDK_UART_CTRL_TXIRQEN_Msk;
       if (rx_irq_en!=0)    new_ctrl |= CMSDK_UART_CTRL_RXIRQEN_Msk;
       if (tx_ovrirq_en!=0) new_ctrl |= CMSDK_UART_CTRL_TXORIRQEN_Msk;
       if (rx_ovrirq_en!=0) new_ctrl |= CMSDK_UART_CTRL_RXORIRQEN_Msk;

       CMSDK_UART->CTRL = 0;         /* ��������ʱ����UART */
       CMSDK_UART->BAUDDIV = divider;
       CMSDK_UART->CTRL = new_ctrl;  /* ����CTRL�Ĵ���Ϊ��ֵ */

       if((CMSDK_UART->STATE & (CMSDK_UART_STATE_RXOR_Msk | CMSDK_UART_STATE_TXOR_Msk))) 
				 return 1;
       else return 0;
 }

/**
 *
 * @param ����ָ��
 * @return RxBufferFull
 *
 * @brief  ����RX�������Ƿ�����
 */

 uint32_t CMSDK_uart_GetRxBufferFull(CMSDK_UART_TypeDef* CMSDK_UART)
 {
        return ((CMSDK_UART->STATE & CMSDK_UART_STATE_RXBF_Msk)>> CMSDK_UART_STATE_RXBF_Pos);
 }

/**
 *
 * @param *CMSDK_UART UART Pointer
 * @return TxBufferFull
 *
 * @brief  ����TX�������Ƿ�����
 */

 uint32_t CMSDK_uart_GetTxBufferFull(CMSDK_UART_TypeDef* CMSDK_UART)
 {
        return ((CMSDK_UART->STATE & CMSDK_UART_STATE_TXBF_Msk)>> CMSDK_UART_STATE_TXBF_Pos);
 }

/**
 *
 * @param *CMSDK_UART UART Pointer
 * @param txchar Character to be sent
 * @return none
 *
 * @brief  ����һ���ַ���TX���������д��䡣
 */

 void CMSDK_uart_SendChar(CMSDK_UART_TypeDef* CMSDK_UART, char txchar)
 {
       while(CMSDK_UART->STATE & CMSDK_UART_STATE_TXBF_Msk);
       CMSDK_UART->DATA = (uint32_t)txchar;
 }

/**
 *
 * @param *CMSDK_UART UART Pointer
 * @return rxchar
 *
 * @brief  ��RX�����������ѽ��յ����ַ�
 */

 char CMSDK_uart_ReceiveChar(CMSDK_UART_TypeDef* CMSDK_UART)
 {
       while(!(CMSDK_UART->STATE & CMSDK_UART_STATE_RXBF_Msk));
       return (char)(CMSDK_UART->DATA);
 }

/**
 *
 * @param *CMSDK_UART UART Pointer
 * @return 0 - No overrun
 * @return 1 - TX overrun
 * @return 2 - RX overrun
 * @return 3 - TX & RX overrun
 *
 * @brief ����RX��TX�������ĵ�ǰ���״̬��
 */


 uint32_t CMSDK_uart_GetOverrunStatus(CMSDK_UART_TypeDef* CMSDK_UART)
 {
        return ((CMSDK_UART->STATE & (CMSDK_UART_STATE_RXOR_Msk | CMSDK_UART_STATE_TXOR_Msk))>>CMSDK_UART_STATE_TXOR_Pos);
 }

/**
 *
 * @param *CMSDK_UART UART Pointer
 * @return 0 - No overrun
 * @return 1 - TX overrun
 * @return 2 - RX overrun
 * @return 3 - TX & RX overrun
 *
 * @brief  ���RX��TX�����������״̬��Ȼ�󷵻ص�ǰ�����״̬��
 */

 uint32_t CMSDK_uart_ClearOverrunStatus(CMSDK_UART_TypeDef* CMSDK_UART)
 {
       CMSDK_UART->STATE = (CMSDK_UART_STATE_RXOR_Msk | CMSDK_UART_STATE_TXOR_Msk);
        return ((CMSDK_UART->STATE & (CMSDK_UART_STATE_RXOR_Msk | CMSDK_UART_STATE_TXOR_Msk))>>CMSDK_UART_STATE_TXOR_Pos);
 }

/**
 *
 * @param *CMSDK_UART UART Pointer
 * @return BaudDiv
 *
 * @brief  ���ص�ǰ��UART�����ʷָ�����ע�Ⲩ���ʷָ�����ʱ��Ƶ�ʺͲ���Ƶ��֮��Ĳ�ֵ��
 */

 uint32_t CMSDK_uart_GetBaudDivider(CMSDK_UART_TypeDef* CMSDK_UART)
 {
       return CMSDK_UART->BAUDDIV;
 }

 /**
 *
 * @param *CMSDK_UART UART Pointer
 * @return TXStatus
 *
 * @brief  ����TX�ж�״̬��
 */

 uint32_t CMSDK_uart_GetTxIRQStatus(CMSDK_UART_TypeDef* CMSDK_UART)
 {
       return ((CMSDK_UART->INTSTATUS & CMSDK_UART_CTRL_TXIRQ_Msk)>>CMSDK_UART_CTRL_TXIRQ_Pos);
 }

/**
 *
 * @param *CMSDK_UART UART Pointer
 * @return RXStatus
 *
 * @brief  ����RX�ж�״̬��
 */

 uint32_t CMSDK_uart_GetRxIRQStatus(CMSDK_UART_TypeDef* CMSDK_UART)
 {
       return ((CMSDK_UART->INTSTATUS & CMSDK_UART_CTRL_RXIRQ_Msk)>>CMSDK_UART_CTRL_RXIRQ_Pos);
 }

 /**
 *
 * @param *CMSDK_UART UART Pointer
 * @return none
 *
 * @brief  ���TX������ȫ�ж�״̬��
 */

 void CMSDK_uart_ClearTxIRQ(CMSDK_UART_TypeDef* CMSDK_UART)
 {
       CMSDK_UART->INTCLEAR = CMSDK_UART_CTRL_TXIRQ_Msk;
 }

/**
 *
 * @param *CMSDK_UART UART Pointer
 * @return none
 *
 * @brief ���RX�ж�״̬��
 */

 void CMSDK_uart_ClearRxIRQ(CMSDK_UART_TypeDef* CMSDK_UART)
 {
       CMSDK_UART->INTCLEAR = CMSDK_UART_CTRL_RXIRQ_Msk;
 }
 //����һ���ַ��Ŵ�
void CMSDK_SendString(char *p,u8 Char_Size)
{
	unsigned char j=0;
	while (p[j]!='\0')
	{		
       CMSDK_uart_SendChar(CMSDK_UART1, p[j]);
       
		j++;
	}
}
//����һ���ַ���
u32 CMSDK_ReceiveString(u8 char_size)
{
      u8 j=0;
      float temp;
      char ReceiveBuf[5];
      while (j<char_size)
      {
           ReceiveBuf[j] = (char)(CMSDK_UART0->DATA);;    
      }
      temp = strtof(ReceiveBuf, NULL);
      return (u32)(temp*10);

}