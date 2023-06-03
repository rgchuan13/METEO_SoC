#include "system_gpio.h"

/**
  * @brief  ����ѡ������ݶ˿�λ�ø�
  * @param  GPIOx: ��һ��gpio
  * @param  GPIO_Pin: ��һ��˿�
  *  ������GPIO_Pin_X������ϣ�����XΪ��0...15��
  * @retval None
  */
void GPIO_SetBits(CMSDK_GPIO_TypeDef * GPIOx, uint16_t GPIO_Pin)
{
    GPIOx->DATAOUT |= GPIO_Pin;
  
}
/**
  * @brief  ����ѡ������ݶ˿�λ�õ�
  * @param  GPIOx: ��һ��gpio
  * @param  GPIO_Pin: ��һ��˿�
  *  ������GPIO_Pin_X������ϣ�����XΪ��0...15��
  * @retval None
  */
void GPIO_ResetBits(CMSDK_GPIO_TypeDef * GPIOx, uint16_t GPIO_Pin)
{
    GPIOx->DATAOUT &= ~ GPIO_Pin;
}

/**
  * @brief  ���ö˿�����Ϊ���
  * @param  GPIOx: ��һ��gpio
  * @param  GPIO_Pin: ��һ��˿�
  *@param  status: 1����� others������
  *  ������GPIO_Pin_X������ϣ�����XΪ��0...15��
  * @retval None
  */
void CMSDK_gpio_SetOutEnable(CMSDK_GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin,uint16_t status)
 {
     if(status==1)
     {
       GPIOx->OUTENABLESET |= GPIO_Pin;
     }
     else
     {
       GPIOx->OUTENABLESET &= ~GPIO_Pin; 
     } 
 }

 
 /**
  * @brief  ����һ��uint32_t����������һ���˿��ϵ������Ƿ�����Ϊ����������
  *������ص�uint32_t�ĵ�1λ����Ϊ1����ô����ζ������1��һ�������
  * @param  GPIOx: ��һ��gpio
  * @retval None
  */
 uint32_t CMSDK_gpio_GetOutEnable(CMSDK_GPIO_TypeDef* GPIOx)
 {
       return GPIOx->OUTENABLESET;
 }
 
 /**
 *
 * @param mask The output port mask
 * @param value The value to output to the specified port
 * @return none
 *
 * @brief Outputs the specified value on the desired port using the user defined mask to perform Masked access.
 */

 void CMSDK_gpio_MaskedWrite(CMSDK_GPIO_TypeDef* GPIOx, uint32_t value, uint32_t mask)
 {
       GPIOx->LB_MASKED[0x00FF & mask] = value;
       GPIOx->UB_MASKED[((0xFF00 & mask) >> 8)] = value;
 }
 
 /**
 *
 * @param gpio��
 * @param gpio�˿�
 * @return ����һ����1 ����0����0
 *
 * @brief GPIO��һλ
 */
uint8_t CMSDK_gpio_ReadBit(CMSDK_GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin)
{
    u8 c;
      if((GPIOx->DATA & GPIO_Pin) != 0)
      {
         c = 1;
        return c;
      }
      else
      {
          c = 0;
        return c;
      }
}