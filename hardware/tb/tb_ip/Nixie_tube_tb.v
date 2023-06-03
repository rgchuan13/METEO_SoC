`timescale 1ns/1ns

module Nixie_tube_tb ();

	reg				HCLK;
	reg 			RSTn;
	reg		[31:0]	DATA;
	wire	[6:0]	seg;
	wire	[3:0]	an;
    wire            dp;


	Nixie_tube u_Nixie_tube_tb(
		.HRESETn(RSTn),	
		.HCLK(HCLK),
		.DATA(DATA),
		.seg(seg),	
		.an(an),	
		.dp(dp)		
	);

	parameter  clk_period = 2; 					// clk period
	parameter clk_half_period = clk_period/2;
	initial begin
		HCLK =1;
		RSTn =0;
        #10 RSTn = 1;
		// 设置输入信号初值
		DATA = 32'd0;
        #10 DATA = 32'b0000_0000_0000_00100_00011_10010_00001;
	end

	// 产生时钟信号
	always #clk_half_period HCLK =~HCLK;

endmodule