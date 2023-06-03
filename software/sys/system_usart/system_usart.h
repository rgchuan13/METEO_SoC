/* 定义防止递归包含 -------------------------------------*/
#ifndef __METEO_USART_H
#define __METEO_USART_H


/* Includes ------------------------------------------------------------------*/
#include "meteo.h"


/** @defgroup USART库函数定义*/
uint32_t CMSDK_uart_init(CMSDK_UART_TypeDef* CMSDK_UART, uint32_t divider, uint32_t tx_en, uint32_t rx_en, uint32_t tx_irq_en, uint32_t rx_irq_en, uint32_t tx_ovrirq_en, uint32_t rx_ovrirq_en);
uint32_t CMSDK_uart_GetRxBufferFull(CMSDK_UART_TypeDef* CMSDK_UART);
uint32_t CMSDK_uart_GetTxBufferFull(CMSDK_UART_TypeDef* CMSDK_UART);
void CMSDK_uart_SendChar(CMSDK_UART_TypeDef* CMSDK_UART, char txchar);
char CMSDK_uart_ReceiveChar(CMSDK_UART_TypeDef* CMSDK_UART);
uint32_t CMSDK_uart_GetOverrunStatus(CMSDK_UART_TypeDef* CMSDK_UART);
uint32_t CMSDK_uart_ClearOverrunStatus(CMSDK_UART_TypeDef* CMSDK_UART);
uint32_t CMSDK_uart_GetBaudDivider(CMSDK_UART_TypeDef* CMSDK_UART);
uint32_t CMSDK_uart_GetTxIRQStatus(CMSDK_UART_TypeDef* CMSDK_UART);
uint32_t CMSDK_uart_GetRxIRQStatus(CMSDK_UART_TypeDef* CMSDK_UART);
void CMSDK_uart_ClearTxIRQ(CMSDK_UART_TypeDef* CMSDK_UART);
void CMSDK_uart_ClearRxIRQ(CMSDK_UART_TypeDef* CMSDK_UART);
void CMSDK_SendString(char *p,u8 Char_Size);
u32 CMSDK_ReceiveString(u8 char_size);
#endif