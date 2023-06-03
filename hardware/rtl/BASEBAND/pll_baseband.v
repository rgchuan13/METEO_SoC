/************************************************************\
 **  Copyright (c) 2011-2021 Anlogic, Inc.
 **  All Right Reserved.
\************************************************************/
/************************************************************\
 ** Log	:	This file is generated by Anlogic IP Generator.
 ** File	:	D:/workspace/soc/ADVANCED/meteorolite_advanced/hardware/rtl/BASEBAND/pll_baseband.v
 ** Date	:	2022 08 11
 ** TD version	:	5.0.43066
\************************************************************/

///////////////////////////////////////////////////////////////////////////////
//	Input frequency:             50.000Mhz
//	Clock multiplication factor: 2
//	Clock division factor:       1
//	Clock information:
//		Clock name	| Frequency 	| Phase shift
//		C0        	| 100.000000MHZ	| 0  DEG     
//		C1        	| 24.000000 MHZ	| 0  DEG     
//		C2        	| 16.000000 MHZ	| 0  DEG     
//		C3        	| 10.000000 MHZ	| 0  DEG     
///////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 100 fs

module pll_baseband(refclk,
		reset,
		extlock,
		clk0_out,
		clk1_out,
		clk2_out,
		clk3_out);

	input refclk;
	input reset;
	output extlock;
	output clk0_out;
	output clk1_out;
	output clk2_out;
	output clk3_out;

	wire clk0_buf;

	EG_LOGIC_BUFG bufg_feedback( .i(clk0_buf), .o(clk0_out) );

	EG_PHY_PLL #(.DPHASE_SOURCE("DISABLE"),
		.DYNCFG("DISABLE"),
		.FIN("50.000"),
		.FEEDBK_MODE("NORMAL"),
		.FEEDBK_PATH("CLKC0_EXT"),
		.STDBY_ENABLE("DISABLE"),
		.PLLRST_ENA("ENABLE"),
		.SYNC_ENABLE("DISABLE"),
		.DERIVE_PLL_CLOCKS("DISABLE"),
		.GEN_BASIC_CLOCK("DISABLE"),
		.GMC_GAIN(4),
		.ICP_CURRENT(13),
		.KVCO(4),
		.LPF_CAPACITOR(1),
		.LPF_RESISTOR(4),
		.REFCLK_DIV(1),
		.FBCLK_DIV(2),
		.CLKC0_ENABLE("ENABLE"),
		.CLKC0_DIV(12),
		.CLKC0_CPHASE(11),
		.CLKC0_FPHASE(0),
		.CLKC1_ENABLE("ENABLE"),
		.CLKC1_DIV(50),
		.CLKC1_CPHASE(49),
		.CLKC1_FPHASE(0),
		.CLKC2_ENABLE("ENABLE"),
		.CLKC2_DIV(75),
		.CLKC2_CPHASE(74),
		.CLKC2_FPHASE(0),
		.CLKC3_ENABLE("ENABLE"),
		.CLKC3_DIV(120),
		.CLKC3_CPHASE(119),
		.CLKC3_FPHASE(0)	)
	pll_inst (.refclk(refclk),
		.reset(reset),
		.stdby(1'b0),
		.extlock(extlock),
		.load_reg(1'b0),
		.psclk(1'b0),
		.psdown(1'b0),
		.psstep(1'b0),
		.psclksel(3'b000),
		.psdone(open),
		.dclk(1'b0),
		.dcs(1'b0),
		.dwe(1'b0),
		.di(8'b00000000),
		.daddr(6'b000000),
		.do({open, open, open, open, open, open, open, open}),
		.fbclk(clk0_out),
		.clkc({open, clk3_out, clk2_out, clk1_out, clk0_buf}));

endmodule
