// ----------------------------------------------------------------------------
//  Version and control information:
//  File Revision       : 1.0.0
//  File Date           : 2022-05-13
//  Author              : RG
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

//  Abstract : Meteorolite FPGA 硬木课堂板载4位7段数码管控制模块
//
// ----------------------------------------------------------------------------

module Nixie_tube (
  	input wire 				HCLK,
  	input wire 				HRESETn,
  	input wire [31:0] 		DATA,

	output reg     [6:0] 	seg,		// 数码管段选信号
	output wire    [3:0] 	an,			// 数码管位选信号
	output wire				dp

);

	reg [15:0] counter;
	reg [3:0]  ring = 4'b1110;

	wire [3:0] code;
	wire [6:0] seg_out;
	reg		   scan_clk;
	assign 	an = ring;

// 扫描时钟生成模块
	always @(posedge HCLK or negedge HRESETn) begin
		if(!HRESETn) begin
			counter <= 16'h0000;
			scan_clk <= 1'b0;
		end
		else begin
			if(counter == 16'h7000)
				begin 
					scan_clk <= ~scan_clk;
					counter <= 16'h0000;
				end
			else
				counter <= counter + 1'b1;
		end
	end

	// 数码管选信号生成模块
	always @(posedge scan_clk or negedge HRESETn) begin
		if(!HRESETn)
			ring <= 4'b1110;
		else
			ring <= {ring[2:0],ring[3]};
	end

	// 数据与每位数码管的对应关系
	assign code =
		(ring == 4'b1110) ? DATA[3:0]    :
		(ring == 4'b1101) ? DATA[8:5]    :
		(ring == 4'b1011) ? DATA[13:10]  :
		(ring == 4'b0111) ? DATA[18 :15] :
		4'b0000;

	assign dp = 
		(ring == 4'b1110) ? DATA[4]    :
		(ring == 4'b1101) ? DATA[9]    :
		(ring == 4'b1011) ? DATA[14]   :
		(ring == 4'b0111) ? DATA[19]   :
		1'b0;
	
	// 十六进制数0 -F 与7段码
	always @(*)
	case (code)
		4'b0000	: seg = 7'b011_1111;
		4'b0001	: seg = 7'b000_0110;
		4'b0010	: seg = 7'b101_1011;
		4'b0011	: seg = 7'b100_1111;
		4'b0100	: seg = 7'b110_0110;
		4'b0101	: seg = 7'b110_1101;
		4'b0110	: seg = 7'b111_1101;
		4'b0111	: seg = 7'b000_0111;
		4'b1000	: seg = 7'b111_1111;
		4'b1001	: seg = 7'b110_1111;
		4'b1010	: seg = 7'b111_0111;
		4'b1011	: seg = 7'b111_1100;
		4'b1100	: seg = 7'b011_1001;
		4'b1101	: seg = 7'b101_1110;
		4'b1110	: seg = 7'b111_1001;
		4'b1111	: seg = 7'b111_0001;
		default: seg = 7'b011_1111;
	endcase

  
endmodule