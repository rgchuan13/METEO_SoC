/************************************************************\
 **  Copyright (c) 2011-2021 Anlogic, Inc.
 **  All Right Reserved.
\************************************************************/
/************************************************************\
 ** Log	:	This file is generated by Anlogic IP Generator.
 ** File	:	E:/TD/workspace/meteorolite/hardware/rtl/TEST_RF/ADC_2CH.v
 ** Date	:	2022 04 21
 ** TD version	:	5.0.43066
\************************************************************/

`timescale 1ns / 1ps

module ADC_2CH ( eoc, dout, clk, pd, s, soc );
	output 		 eoc;
	output  		[11:0] dout;

	input  		clk;
	input  		pd;
	input  		[2:0] s;
	input  		soc;

	EG_PHY_ADC #(
		.CH6("ENABLE"),
		.CH4("ENABLE"))
		adc (
		.clk(clk),
		.pd(pd),
		.s(s),
		.soc(soc),
		.eoc(eoc),
		.dout(dout));

endmodule