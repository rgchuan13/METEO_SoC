#ifndef __NIXIE_H
#define __NIXIE_H


#include "sys.h"

void nixie_display_num(u32 data,int pos);
void nixie_display_dos(int dos);
void SEG_Clear_all();
void Display_FM(u32 FM_Value);
void Standby();
void STOP();
#endif
