#ifndef __SYS_H
#define __SYS_H	
#include "meteo.h"
#include "system_gpio.h"
#include "system_usart.h"


/*�������������ԭ����CMSDK�����ֲ��34ҳ*/
#define GPIO0_HIGH(n)  CMSDK_gpio_MaskedWrite(GPIO0, 0x0001 << n, 0x0001 << n)
#define GPIO0_LOW(n)   CMSDK_gpio_MaskedWrite(GPIO0, 0, 0x0001 << n)

#endif