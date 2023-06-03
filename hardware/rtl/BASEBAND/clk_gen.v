// ----------------------------------------------------------------------------
//  Version and control information:
//  File Revision       : 2.1.0
//  File Date           : 2022-08-111
//                       
//  Author              : RG
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

//  Abstract : Meteorolite FPGA 基带信号处理模块
//             用于产生24MHZ时钟给msi001和qn8027
//
// ----------------------------------------------------------------------------



module clk_gen (
    input   wire    clk_48mhz,
    input   wire    rstn,
    output  wire    msi_clk_24mhz,
    output  wire    qn_clk_24mhz
);

    reg				clk24_reg;
	reg				clk24_count;

    // 用于产生24MHZ的时钟信号
	always @(posedge clk_48mhz or negedge rstn) begin
		if(~rstn) begin
			clk24_reg <= 1'b0;
			clk24_count <= 1'b0;
		end
		else begin
			clk24_reg <= (clk24_count == 1'b1) ? 1'b1 : 1'b0;
			clk24_count <= (clk24_count== 1'b1) ? 1'b0 : clk24_count + 1'b1;
		end
	end
	assign msi_clk_24mhz = clk24_reg;
	assign qn_clk_24mhz = clk24_reg;
    
endmodule