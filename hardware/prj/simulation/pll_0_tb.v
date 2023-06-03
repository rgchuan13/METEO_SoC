// Verilog testbench created by TD v5.0.43066
// 2022-03-06 19:51:20

`timescale 1ns / 1ps

module pll_0_tb();

reg refclk;
reg reset;
wire clk0_out;
wire clk1_out;
wire clk2_out;
wire clk3_out;
wire extlock;

//Clock process
parameter PERIOD = 10;
always #(PERIOD/2) refclk = ~refclk;

//glbl Instantiate
glbl glbl();

//Unit Instantiate
pll_0 uut(
	.refclk(refclk),
	.reset(reset),
	.clk0_out(clk0_out),
	.clk1_out(clk1_out),
	.clk2_out(clk2_out),
	.clk3_out(clk3_out),
	.extlock(extlock));

//Stimulus process
initial begin
//To be inserted
end

endmodule