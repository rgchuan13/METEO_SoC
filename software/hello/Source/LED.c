#include "LED.h"
#include "meteo.h"

void  LED_on  (void)
{
  CMSDK_GPIO0->DATAOUT |= (0x40UL); // Set data output to 1
  return;
}

void LED_off (void)
{
  CMSDK_GPIO0->DATAOUT &= ~(0x40UL);
  return;
}

int32_t LED_Initialize (void)
{
  CMSDK_GPIO0->DATAOUT &= ~(0x40UL);        // Set data ouput to 0
  CMSDK_GPIO0->OUTENABLESET   |= 0x40UL;     // Enable bit 0 as output
  return(0);
}