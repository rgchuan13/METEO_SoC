// ----------------------------------------------------------------------------
//  Version and control information:
//  File Revision       : 1.0.0
//  File Date           : 2022-05-13
//  Author              : RG
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

//  Abstract : Meteorolite FPGA 数码管/矩阵键盘控制模块
//
// ----------------------------------------------------------------------------
module AHB_SEG_KEY (
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

	// 数码管接口信号
	output wire     [6:0] 	seg,		// 数码管段选信号
	output wire    [3:0] 	an,			// 数码管位选信号
	output wire				dp,

	// 矩阵键盘接口信号
	input wire [3:0] 		COL,
	output wire [3:0] 		ROW,
	output wire				KEY_IRQ
);

	// 地址周期采样寄存器
	reg 	   rHSEL;
	reg [31:0] rHADDR;
	reg [1:0]  rHTRANS;
	reg		   rHWRITE;
	reg [2:0]  rHSIZE;
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

	// 数据周期数据传送

	reg [31:0] DATA;			// 数码管寄存器
	always @(posedge HCLK or negedge HRESETn) begin
		if (!HRESETn) begin
			DATA <= 32'h00000000;
		end
		else begin
			if(rHSEL & rHWRITE & rHTRANS[1])
			DATA <= HWDATA[31:0];
		end
	end

	wire [4:0] key_disp;
	reg [31:0] KEY_DATA;		// 矩阵键盘寄存器
	reg [31:0] rHRDATA;
	assign HRDATA = rHRDATA;
	always @(posedge HCLK or negedge HRESETn) begin
		if (!HRESETn) begin
			rHRDATA <= 32'h00000000;
		end
		else begin
			if(rHSEL & (~rHWRITE) & rHTRANS[1])
			 rHRDATA[31:0] <= KEY_DATA;
		end
	end

	wire key_flag;			//指示按键是否按下
	assign key_flag = key_disp[4] | key_disp[3] | key_disp[2] | key_disp[1] | key_disp[0];
	reg irq_reg =1'b0;

	always @(posedge HCLK or negedge HRESETn) begin
		if (!HRESETn) begin
			KEY_DATA <= 32'd0;
		end
		else begin
			
				KEY_DATA <= {27'd0,key_disp[4:0]};
		end
	end

	always @(posedge key_flag) begin
		irq_reg <= ~irq_reg;
	end
	assign KEY_IRQ = irq_reg;

	



	// 传输响应
	assign HREADYOUT = 1'b1;		//单周期写和读，零等待状态操作
	// 读数据
	
	Nixie_tube u_Nixie_tube(
		.HCLK(HCLK),
		.HRESETn(HRESETn),
		.DATA(DATA),
		.seg(seg),
		.an(an),
		.dp(dp)
	);



	keyboard_top u_keyboard_top(
		.CLK_50M(HCLK),
		.RSTn(HRESETn),
		.COL(COL),
		.ROW(ROW),
		.key_disp(key_disp)
	);

  
endmodule