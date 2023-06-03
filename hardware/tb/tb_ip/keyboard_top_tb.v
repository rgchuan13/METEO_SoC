`timescale 1ns/1ns

module keyboard_top_tb ();

	reg				HCLK;
	reg 			RSTn;
	reg		[3:0]	COL;
	wire	[3:0]	ROW;
	wire	[4:0]	key_disp;



	keyboard_top u_keyboard_top_tb(
		.RSTn(RSTn),	
		.CLK_50M(HCLK),
		.COL(COL),
		.ROW(ROW),		
		.key_disp(key_disp)		
	);

	parameter  clk_period = 2; 					// clk period
	parameter clk_half_period = clk_period/2;
	initial begin
		HCLK =1;
		RSTn =0;
        #10 RSTn = 1;
		// 设置输入信号初值
		COL = 4'd0;
        #15000 COL = 4'b1000;
        #200000 COL = 4'b0100;
        #200000 COL = 4'b0010;

	end

	// 产生时钟信号
	always #clk_half_period HCLK =~HCLK;

endmodule