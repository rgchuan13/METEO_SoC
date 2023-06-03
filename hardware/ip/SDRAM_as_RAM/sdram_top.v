// ----------------------------------------------------------------------------
//  Version and control information:
//  File Revision       : 1.0.0
//  File Date           : 2022-05-02
//  Author              : RG
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

//  Abstract : Meteorolite mcu SDRAM 顶层模块
//             
//
// ----------------------------------------------------------------------------
module sdram_top (
	input wire	[31:0]	dia,	// 32位数据输入
	input wire	[31:0]  addra,	// 32位地址
	input wire	[3:0]   wea,	// 端口写入读出数据控制
	input wire			cea,	// A端口时钟有效控制信号，默认高有效
	input wire			clk,	// 端口时钟输入
	output wire	[31:0]	doa		// 32位数据输出
);

`define   DATA_WIDTH                        32
`define   ADDR_WIDTH                        21
`define   DM_WIDTH                          4

`define   ROW_WIDTH                        11
`define   BA_WIDTH                        2


	wire 		Sdr_init_done,Sdr_init_ref_vld;



	sdr_as_ram  #( .self_refresh_open(1'b1))
	u2_ram( 
		.Sdr_clk(clk),								// 应用方案SDRAM工作时钟
		.Sdr_clk_sft(clk),						// 同频可能不同相位的SDRAM时钟
		.Rst(1'b0),									// 高有效
		//用户读写接口	  			  
		.Sdr_init_done(Sdr_init_done),				// SDRAM 初始化完成
		.Sdr_init_ref_vld(Sdr_init_ref_vld),		// SDRAM 刷新有效标志
		.Sdr_busy(Sdr_busy),						// SDRAM忙状态
		
		.App_ref_req(1'b0),							// 用户自行请求刷新操作
		
        .App_wr_en(App_wr_en), 						// 写使能，高有效
        .App_wr_addr(App_wr_addr),  				// 写地址
		.App_wr_dm(App_wr_dm),						// 写入数据掩码
		.App_wr_din(App_wr_din),					// 写数据

		.App_rd_en(App_rd_en),						// 读使能
		.App_rd_addr(App_rd_addr),					// 读地址
		.Sdr_rd_en	(Sdr_rd_en),					// 有效读数据输出使能
		.Sdr_rd_dout(Sdr_rd_dout),					// 有效读出数据
	
		.SDRAM_CLK(SDRAM_CLK),						// SDRAM时钟
		.SDR_RAS(SDR_RAS),							// SDRAM行有效
		.SDR_CAS(SDR_CAS),							// SDRAM 片选
		.SDR_WE(SDR_WE),							// SDRAM写使能
		.SDR_BA(SDR_BA),							// SDRAM BANK
		.SDR_ADDR(SDR_ADDR),						// SDRAM的操作地址
		.SDR_DM(SDR_DM),							// SDRAM的数据掩码
		.SDR_DQ(SDR_DQ)								// SDRAM数据总线
	);

	EG_PHY_SDRAM_2M_32 sdram(
		.clk(SDRAM_CLK),
		.ras_n(SDR_RAS),
		.cas_n(SDR_CAS),
		.we_n(SDR_WE),
		.addr(SDR_ADDR[10:0]),
		.ba(SDR_BA),
		.dq(SDR_DQ),
		.cs_n(1'b0),
		.dm0(SDR_DM[0]),
		.dm1(SDR_DM[1]),
		.dm2(SDR_DM[2]),
		.dm3(SDR_DM[3]),
		.cke(1'b1)
		);


endmodule