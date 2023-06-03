#ifndef __MSI001_H
#define __MSI001_H

#include "stdio.h"
#include "meteo.h"

#define PORT_MSI001_CS  0x01UL //片选线	
#define PORT_MSI001_CLK  0x02UL //时钟线	
#define PORT_MSI001_DATA  0x04UL //数据线	
#define MSI001_CS_H  CMSDK_GPIO0->DATAOUT |= (PORT_MSI001_CS) //片选信号	拉高
#define MSI001_CLK_H CMSDK_GPIO0->DATAOUT |= (PORT_MSI001_CLK) //时钟信号
#define MSI001_DATA_H CMSDK_GPIO0->DATAOUT |= (PORT_MSI001_DATA) //数据信号
#define MSI001_CS_L  CMSDK_GPIO0->DATAOUT  &= ~(PORT_MSI001_CS) //片选信号	拉低
#define MSI001_CLK_L CMSDK_GPIO0->DATAOUT  &= ~(PORT_MSI001_CLK)//时钟信号
#define MSI001_DATA_L CMSDK_GPIO0->DATAOUT  &= ~(PORT_MSI001_DATA) //数据信号
#define IC_modeReg0 0x00
#define Receiver_gain_controlReg1 0x01
#define Synthesizer_programmingReg2 0x02
#define LO_Trim_ControlReg3 0x03
#define Auxiliary_features_controlReg4 0x04
#define RF_Synthesizer_ConfigurationReg5 0x05
#define DC_Offset_Calibration_setupReg06 0x06


void MSI001_Init(void);
void MSI001_Write(uint32_t tx_data,uint8_t addr);
void Damping_Control(uint16_t Damp);//设置“基带增益降低”
void FM_Select(u32 fm);
#endif