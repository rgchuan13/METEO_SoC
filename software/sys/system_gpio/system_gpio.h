


/* �����ֹ�ݹ���� -------------------------------------*/
#ifndef __METEO_GPIO_H
#define __METEO_GPIO_H


/* Includes ------------------------------------------------------------------*/
#include "meteo.h"
/*���ݶ���*/
#define GPIO0                      CMSDK_GPIO0
#define GPIO1                      CMSDK_GPIO0


/* GPIO�˿ڶ��� ------------------------------------------------------------------*/
#define GPIO_Pin_0                 ((uint16_t)0x0001)  /*!< Pin 0 selected */
#define GPIO_Pin_1                 ((uint16_t)0x0002)  /*!< Pin 1 selected */
#define GPIO_Pin_2                 ((uint16_t)0x0004)  /*!< Pin 2 selected */
#define GPIO_Pin_3                 ((uint16_t)0x0008)  /*!< Pin 3 selected */
#define GPIO_Pin_4                 ((uint16_t)0x0010)  /*!< Pin 4 selected */
#define GPIO_Pin_5                 ((uint16_t)0x0020)  /*!< Pin 5 selected */
#define GPIO_Pin_6                 ((uint16_t)0x0040)  /*!< Pin 6 selected */
#define GPIO_Pin_7                 ((uint16_t)0x0080)  /*!< Pin 7 selected */
#define GPIO_Pin_8                 ((uint16_t)0x0100)  /*!< Pin 8 selected */
#define GPIO_Pin_9                 ((uint16_t)0x0200)  /*!< Pin 9 selected */
#define GPIO_Pin_10                ((uint16_t)0x0400)  /*!< Pin 10 selected */
#define GPIO_Pin_11                ((uint16_t)0x0800)  /*!< Pin 11 selected */
#define GPIO_Pin_12                ((uint16_t)0x1000)  /*!< Pin 12 selected */
#define GPIO_Pin_13                ((uint16_t)0x2000)  /*!< Pin 13 selected */
#define GPIO_Pin_14                ((uint16_t)0x4000)  /*!< Pin 14 selected */
#define GPIO_Pin_15                ((uint16_t)0x8000)  /*!< Pin 15 selected */
#define GPIO_Pin_All               ((uint16_t)0xFFFF)  /*!< All pins selected */

#define IS_GPIO_PIN(PIN) ((((PIN) & (uint16_t)0x00) == 0x00) && ((PIN) != (uint16_t)0x00))


#define IS_GPIO_ALL_PERIPH(PERIPH) (((PERIPH) == GPIO0) || \
                                    ((PERIPH) == GPIO1))
                                   

/** @defgroup GPIO�⺯������*/
void GPIO_SetBits(CMSDK_GPIO_TypeDef * GPIOx, uint16_t GPIO_Pin);
void GPIO_ResetBits(CMSDK_GPIO_TypeDef * GPIOx, uint16_t GPIO_Pin);
void CMSDK_gpio_SetOutEnable(CMSDK_GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin,uint16_t status);
void CMSDK_gpio_ClrOutEnable(CMSDK_GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin);
uint32_t CMSDK_gpio_GetOutEnable(CMSDK_GPIO_TypeDef* GPIOx);
uint8_t CMSDK_gpio_ReadBit(CMSDK_GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
void CMSDK_gpio_MaskedWrite(CMSDK_GPIO_TypeDef* GPIOx, uint32_t value, uint32_t mask);

#endif