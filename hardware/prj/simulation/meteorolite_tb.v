// Verilog testbench created by TD v5.0.43066
// 2022-03-06 16:20:36

`timescale 1ns / 1ps

module meteorolite_tb();

reg CB_nPOR;
reg CB_nRST;
reg CS_GNDDETECT;
reg CS_TCK;
reg CS_TDI;
reg CS_nSRST;
reg CS_nTRST;
reg OSCCLK;
reg SPI_MISO;
reg UART_RXD;
wire CS_TDO;
wire CS_TRACECLK;
wire CS_TRACECTL;
wire [15:0] CS_TRACEDATA;
wire FLAG_NPOR;
wire FLAG_RESET_N;
wire SPI_MOSI;
wire SPI_SCK;
wire SPI_nSS;
wire UART_TXD;
wire CS_TMS;
wire [15:0] EXP;

//Clock process
parameter PERIOD = 10;
assign OSCCLK =1'b0;
always #(PERIOD/2) OSCCLK = ~OSCCLK;

//glbl Instantiate
glbl glbl();

//Unit Instantiate
meteorolite uut(
	.CB_nPOR(CB_nPOR),
	.CB_nRST(CB_nRST),
	.CS_GNDDETECT(CS_GNDDETECT),
	.CS_TCK(CS_TCK),
	.CS_TDI(CS_TDI),
	.CS_nSRST(CS_nSRST),
	.CS_nTRST(CS_nTRST),
	.OSCCLK(OSCCLK),
	.SPI_MISO(SPI_MISO),
	.UART_RXD(UART_RXD),
	.CS_TDO(CS_TDO),
	.CS_TRACECLK(CS_TRACECLK),
	.CS_TRACECTL(CS_TRACECTL),
	.CS_TRACEDATA(CS_TRACEDATA),
	.FLAG_NPOR(FLAG_NPOR),
	.FLAG_RESET_N(FLAG_RESET_N),
	.SPI_MOSI(SPI_MOSI),
	.SPI_SCK(SPI_SCK),
	.SPI_nSS(SPI_nSS),
	.UART_TXD(UART_TXD),
	.CS_TMS(CS_TMS),
	.EXP(EXP));

//Stimulus process
initial begin
//To be inserted

	assign CB_nPOR =1;
	assign CB_nRST =1;

end

endmodule