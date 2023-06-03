#include "system_gpio.h"

/**
  * @brief  设置选择的数据端口位置高
  * @param  GPIOx: 哪一组gpio
  * @param  GPIO_Pin: 哪一组端口
  *  可以是GPIO_Pin_X自由组合，其中X为（0...15）
  * @retval None
  */
void GPIO_SetBits(CMSDK_GPIO_TypeDef * GPIOx, uint16_t GPIO_Pin)
{
    GPIOx->DATAOUT |= GPIO_Pin;
  
}
/**
  * @brief  设置选择的数据端口位置低
  * @param  GPIOx: 哪一组gpio
  * @param  GPIO_Pin: 哪一组端口
  *  可以是GPIO_Pin_X自由组合，其中X为（0...15）
  * @retval None
  */
void GPIO_ResetBits(CMSDK_GPIO_TypeDef * GPIOx, uint16_t GPIO_Pin)
{
    GPIOx->DATAOUT &= ~ GPIO_Pin;
}

/**
  * @brief  设置端口引脚为输出
  * @param  GPIOx: 哪一组gpio
  * @param  GPIO_Pin: 哪一组端口
  *@param  status: 1：输出 others：输入
  *  可以是GPIO_Pin_X自由组合，其中X为（0...15）
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
  * @brief  返回一个uint32_t，它定义了一个端口上的引脚是否设置为输入或输出。
  *如果返回的uint32_t的第1位设置为1，那么这意味着引脚1是一个输出。
  * @param  GPIOx: 哪一组gpio
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
 * @param gpio组
 * @param gpio端口
 * @return 读到一返回1 读到0返回0
 *
 * @brief GPIO读一位
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