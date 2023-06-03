/************************************************************\
 **  Copyright (c) 2011-2021 Anlogic, Inc.
 **  All Right Reserved.
\************************************************************/
/************************************************************\
 ** Log	:	This file is generated by Anlogic IP Generator.
 ** File	:	E:/TD/workspace/meteorolite/hardware/ip/sram_256k.v
 ** Date	:	2022 03 01
 ** TD version	:	5.0.43066
 ** Abstract: 8K x 32bit  单口RAM
\************************************************************/

`timescale 1ns / 1ps

module sram_256k ( doa, dia, addra, cea, clka, wea );


	parameter DATA_WIDTH_A = 32; 
	parameter ADDR_WIDTH_A = 13;
	parameter DATA_DEPTH_A = 8192;
	parameter DATA_WIDTH_B = 32;
	parameter ADDR_WIDTH_B = 13;
	parameter DATA_DEPTH_B = 8192;
	parameter REGMODE_A    = "NOREG";
	parameter WRITEMODE_A  = "NORMAL";

	output [DATA_WIDTH_A-1:0] doa;									// 32位数据输出

	input  [DATA_WIDTH_A-1:0] dia;									// 32位数据输入
	input  [ADDR_WIDTH_A-1:0] addra;								// 32位地址
	input  [3:0] wea;																// A端口写入/读出数据控制
	input  cea;																			// A端口时钟有效控制信号，默认高有效
	input  clka;																		// A端口时钟输入，默认上升沿有效



	EG_LOGIC_BRAM #( .DATA_WIDTH_A(DATA_WIDTH_A),
				.ADDR_WIDTH_A(ADDR_WIDTH_A),
				.DATA_DEPTH_A(DATA_DEPTH_A),
				.DATA_WIDTH_B(DATA_WIDTH_B),
				.ADDR_WIDTH_B(ADDR_WIDTH_B),
				.DATA_DEPTH_B(DATA_DEPTH_B),
				.BYTE_ENABLE(8),
				.BYTE_A(4),
				.BYTE_B(4),
				.MODE("SP"),
				.REGMODE_A(REGMODE_A),
				.WRITEMODE_A(WRITEMODE_A),
				.RESETMODE("SYNC"),
				.IMPLEMENT("32K"),
				.DEBUGGABLE("NO"),
				.PACKABLE("NO"),
				.INIT_FILE("NONE"),
				.FILL_ALL("NONE"))
			inst(
				.dia(dia),
				.dib({32{1'b0}}),
				.addra(addra),
				.addrb({13{1'b0}}),
				.cea(cea),
				.ceb(1'b0),
				.ocea(1'b0),
				.oceb(1'b0),
				.clka(clka),
				.clkb(1'b0),
				.wea(1'b0),
				.bea(wea),
				.web(1'b0),
				.rsta(1'b0),
				.rstb(1'b0),
				.doa(doa),
				.dob());


endmodule