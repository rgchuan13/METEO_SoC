// ----------------------------------------------------------------------------
//  Version and control information:
//  File Revision       : 1.0.0
//  File Date           : 2022-03-01
//  Author              : RG
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

//  Abstract : Meteorolite FPGA 板卡顶层文件
//
// ----------------------------------------------------------------------------
module meteorolite_top (
	
	//系统工作指示信号
	output wire FLAG_NPOR,
	output wire FLAG_RESET_N,
	output wire MSI_CLK_24MHZ,
	output wire	QN_CLK_24MHZ,
	output wire FLAG_FM,
	// 外部时钟输入
	input wire OSCCLK,

	// Debug and Trace 
	input  wire			 		CS_GNDDETECT,   // Ground detect
	input  wire         		CS_nTRST,       // JTAG nTRST
  	input  wire         		CS_TDI,         // JTAG TDI
  	input  wire         		CS_TCK,         // SWD Clk / JTAG TCK
  	inout  wire         		CS_TMS,         // SWD I/O / JTAG TMS
  	output wire         		CS_TDO,         // SWV     / JTAG TDO
	input  wire			 		CS_nSRST,       // Not required for Cortex-M
	output wire         		CS_TRACECLK,    // Trace clock
  	output wire         		CS_TRACECTL,    // Trace control
  	output wire		[15:0]  	CS_TRACEDATA,   // Trace data

	// UART
	input wire					UART0_RXD,			// UART receive data
	output wire					UART0_TXD,			// UART transmit data
	input wire					UART1_RXD,			// UART receive data
	output wire					UART1_TXD,			// UART transmit data
	// I/O
	inout wire		[15:0]		EXP,				// I/O expansion port

	// 矩阵键盘和数码管
	output wire	 [3:0]			KEY_ROW,
	input wire	 [3:0]			KEY_COL,
	output wire [3:0] 			DigitronCS_OUT,
	output wire [6:0] 			Digitron_OUT,
	output wire	      			DP,

	// 拨动开关
	input wire [7:0] SW,

	// LCD 9341
	output  wire                        LCD_CS,
    output  wire                        LCD_RS,
    output  wire                        LCD_WR,
    output  wire                        LCD_RD,
    output  wire                        LCD_RST,
    output  wire    [15:0]              LCD_DATA,
    output  wire                        LCD_BL_CTR,

	// 基带信号处理模块
	input wire MSI_I,
  	input wire MSI_Q,
	input wire AD_MICIN,
	output wire ANALOG,
	output wire CLK_1KHZ

);
	wire					cb_npor;
	wire		[3:0] 		key_row;
	wire		[3:0] 		key_col;

	assign      	key_row	= 4'b0;

	assign			cb_npor		=	SW[0];	// key 0
	assign			cb_nrst		= 	SW[1];	// key 1

	wire 			clk_16mhz;
	wire   			clk_48mhz;
	wire			clk_24mhz;

	// ------------------------------------------------------------------------
	// 基带模块与MCU交互接口信号
	// ------------------------------------------------------------------------
	wire 			PWM_ENABLE;
	wire	[30:0]	AUDIO_THR;
	wire	[31:0]	RSSI;



  
  	meteorolite u_meteorolite (

	  	//系统工作指示信号
		.FLAG_NPOR(FLAG_NPOR),
		.FLAG_RESET_N(FLAG_RESET_N),

	    // 时钟
	    .OSCCLK(OSCCLK),           	// Oscillator -50Mhz, 外部晶振输入50MHZ
		.out_clk_16mhz(clk_16mhz),
		.out_clk_48mhz(clk_48mhz),
		.out_clk_24mhz(clk_24mhz),

	    // 复位
      	.CB_nRST(cb_nrst),			 					// mcu系统复位输入
	    .CB_nPOR(cb_npor),								// EG4S20芯片全局复位输入(低有效)

      	// Debug and Trace 
	    .CS_GNDDETECT(CS_GNDDETECT),   // Ground detect
	    .CS_nTRST(CS_nTRST),       // JTAG nTRST
      	.CS_TDI(CS_TDI),         // JTAG TDI
      	.CS_TCK(CS_TCK),         // SWD Clk / JTAG TCK
      	.CS_TMS(CS_TMS),         // SWD I/O / JTAG TMS
      	.CS_TDO(CS_TDO),         // SWV     / JTAG TDO
	    .CS_nSRST(CS_nSRST),       // Not required for Cortex-M
	    .CS_TRACECLK(CS_TRACECLK),    // Trace clock
      	.CS_TRACECTL(CS_TRACECTL),    // Trace control
      	.CS_TRACEDATA(CS_TRACEDATA),   // Trace data

	    // UART
	    .UART0_RXD(UART0_RXD),			// UART receive data
	    .UART0_TXD(UART0_TXD),			// UART transmit data
		.UART1_RXD(UART1_RXD),			// UART receive data
		.UART1_TXD(UART1_TXD),			// UART transmit data
	
	    // I/O
	    .EXP(EXP),				// I/O expansion port
								// 0 - 15 gpio #0

		// 矩阵键盘 和数码管
		.KEY_ROW(KEY_ROW),
		.KEY_COL(KEY_COL),
		.DigitronCS_OUT(DigitronCS_OUT),
		.Digitron_OUT(Digitron_OUT),
		.DP(DP),

		// LCD9341
		.LCD_CS(LCD_CS),
		.LCD_RS(LCD_RS),
		.LCD_WR(LCD_WR),
		.LCD_RD(LCD_RD),
		.LCD_RST(LCD_RST),
		.LCD_DATA(LCD_DATA),
		.LCD_BL_CTR(LCD_BL_CTR),

		// 基带控制模块
		.PWM_ENABLE(PWM_ENABLE),
		.AUDIO_THR(AUDIO_THR),
		.RSSI(RSSI)
  );

	

	baseband_top u_baseband(
		.oscclk(OSCCLK),
		.rstn(SW[0]),
		.pwm_out(ANALOG),
		.clk_1k(CLK_1KHZ),
		.clk_msi(MSI_CLK_24MHZ),
		.clk_qn(QN_CLK_24MHZ),

		// 基带控制模块接口
		.rssi(RSSI),
		.pwm_enable(PWM_ENABLE),
		.audio_thr(AUDIO_THR)
	);
  

endmodule