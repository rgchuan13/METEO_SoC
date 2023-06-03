#ifndef __QN8027_H
#define __QN8027_H
#include "myiic.h" 


void QN8027_Init(void);
u8 QN8027_ReadOneByte(u16 ReadAddr);
void QN8027_WriteOneByte(u16 WriteAddr,u8 DataToWrite);

#endif