/************************************************************\
 **  Copyright (c) 2011-2021 Anlogic, Inc.
 **  All Right Reserved.
\************************************************************/
/************************************************************\
 ** Log	:	This file is generated by Anlogic IP Generator.
 ** File	:	E:/TD/workspace/meteorolite/hardware/ip/sram_128k.v
 ** Date	:	2022 02 28
 ** TD version	:	5.0.43066
 ** Abstract: 4K x 32bit  单口RAM
\************************************************************/

`timescale 1ns / 1ps

module sram_128k ( doa, dia, addra, cea, clka, wea );


	parameter DATA_WIDTH_A = 32; 
	parameter ADDR_WIDTH_A = 12;
	parameter DATA_DEPTH_A = 4096;
	parameter DATA_WIDTH_B = 32;
	parameter ADDR_WIDTH_B = 12;
	parameter DATA_DEPTH_B = 4096;
	parameter REGMODE_A    = "NOREG";
	parameter WRITEMODE_A  = "NORMAL";

	output [DATA_WIDTH_A-1:0] doa;						// 32位数据输出

	input  [DATA_WIDTH_A-1:0] dia;						// 32位数据输入
	input  [ADDR_WIDTH_A-1:0] addra;					// 12位地址线
	input  [3:0] wea;													// A端口写入/读出操作控制
	input  cea;																// A端口时钟有效控制信号，默认高有效
	input  clka;															// A端口时钟输入，默认上升沿有效



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
				.addrb({12{1'b0}}),
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