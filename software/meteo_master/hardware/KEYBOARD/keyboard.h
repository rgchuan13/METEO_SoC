#ifndef __KEYBOARD_H
#define __KEYBOARD_H

#include "sys.h"


uint32_t Get_Key_Value(SEGKEY_TypeDef* KEY);
u32 GetKEYNUM();
u32 KeyValue_Tranformation(u32 keyvalue);
u32 Type_NUM();
void START_AND_STOP(u8 state);



#endif