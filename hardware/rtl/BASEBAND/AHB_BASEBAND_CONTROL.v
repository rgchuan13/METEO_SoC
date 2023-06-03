// ----------------------------------------------------------------------------
//  Version and control information:
//  File Revision       : 1.1.0
//  File Date           : 2022-04-16
//                        2022-05-13（为模块添加APB控制接口）
//  Author              : RG
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

//  Abstract : Meteorolite FPGA 基带信号处理模块控制信号（添加AHB接口）
//             
//
// ----------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// Programmer's model
// 0x00 R	RSSI_STATE[31:0]		RSSI状态信号
//
// 0x04 w	PWM_CONTROL[31:0]		PWM 控制信号
//				[0] PWM使能信号
//
//				
module AHB_BASEBAND_CONTROL (
  // AHB LITE接口
	input wire 			HSEL,
	input wire 			HCLK,
	input wire 			HRESETn,
	input wire 			HREADY,
	input wire [31:0] 	HADDR,
	input wire [1:0]  	HTRANS,
	input wire          HWRITE,
	input wire [2:0] 	HSIZE,
	input wire [31:0] 	HWDATA,
	output wire        	HREADYOUT,
	output wire [31:0] 	HRDATA,


	// BASEBAND 控制/状态 接口
	input wire	[31:0]	RSSI,	// FM特征信号——RSSI值
	output wire			PWM_ENABLE,
	output wire	[30:0]	AUDIO_THR		
);

	// 地址周期采样寄存器
	reg 	   rHSEL;
	reg [31:0] rHADDR;
	reg [1:0]  rHTRANS;
	reg		   rHWRITE;
	reg [2:0]  rHSIZE;

	wire		clk_iq;  // iq采样率时钟

	
	// 传输响应
	assign HREADYOUT = 1'b1;		//单周期写和读，零等待状态操作


	//地址周期采样
	always @(posedge HCLK or negedge HRESETn) begin
		if(!HRESETn)
			begin
				rHSEL	<= 1'b0;
				rHADDR	<= 32'h0;
				rHTRANS	<= 2'b00;
				rHWRITE	<= 1'b0;
				rHSIZE	<= 3'b000;
			end
		else
		begin
			if(HREADY)
				begin
					rHSEL	<= HSEL;
					rHADDR	<= HADDR;
					rHTRANS	<= HTRANS;
					rHWRITE	<= HWRITE;
					rHSIZE	<= HSIZE;
				end
		end
	end
  // ------------------------------------------------------------------------
	// 基带信号处理模块 寄存器
	// ------------------------------------------------------------------------
	reg [31:0] RSSI_STATE;	// R	0x00
	reg	[31:0] PWM_CONTROL; // W 	0x04

	wire write_enable = rHSEL & rHWRITE & rHTRANS[1];

	// 写操作
	always @(posedge HCLK or negedge HRESETn) begin
		if (!HRESETn) begin
			PWM_CONTROL <= 32'h00000001;
		end
		else begin
			if(write_enable & rHADDR[11:2] == 10'h001)
			PWM_CONTROL <= HWDATA[31:0];
		end
	end

	/*
	always @(posedge HCLK or negedge HRESETn) begin
		if (!HRESETn) begin
			SQ_THR <= 32'h00000000;
		end
		else begin
			if(write_enable & rHADDR[11:2] == 10'h002)
			SQ_THR <= HWDATA[31:0];
		end
	end*/

	// 读操作
	reg [31:0] rHRDATA;
	assign HRDATA = rHRDATA;
	always @(posedge HCLK or negedge HRESETn) begin
		if (!HRESETn) begin
			rHRDATA <= 32'h00000000;
		end
		else begin
			if(rHSEL & (~rHWRITE) & rHTRANS[1])
			 rHRDATA[31:0] <= RSSI_STATE;
		end
	end

	clock_divider #(
		.M(96)
	)
    u_baseband_control_clk_divider(
		.reset(HRESETn),// reset
    	.clk(HCLK),    	// input clock
    	.en_i(1'b1),   	// input enable enable
    	.en_o(clk_iq)	// output clock enable
	);  

	// BASEBAND 输入信号
	always @(posedge clk_iq or negedge HRESETn) begin
		if (~HRESETn) begin
			RSSI_STATE <= 32'd0;
		end
		else begin
			RSSI_STATE <= RSSI;
		end
	end

	// BASEBAND 输出信号
	assign PWM_ENABLE = PWM_CONTROL[0];
	assign AUDIO_THR = PWM_CONTROL[31:1];
	
endmodule