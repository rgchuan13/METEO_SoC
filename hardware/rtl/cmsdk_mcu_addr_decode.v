// ----------------------------------------------------------------------------
//  Version and control information:
//  File Revision       : 1.0.0
//  File Date           : 2022-03-02
//  Author              : RG
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

//  Abstract : 本模块将来自cortex-m0 CPU 模块的地址信号 HADDR 译码并产生 HSEL
//              信号给外围设备
//
// ----------------------------------------------------------------------------

module cmsdk_mcu_addr_decode (
	
	// 系统地址
	input wire [31:0]		haddr,
	input wire				remap_ctrl,

	// 存储选择
	output wire				boot_hsel,
	output wire				rom_hsel,
	output wire				sram_hsel,

	// 外设选择
	output wire				apbsys_hsel,
	output wire				gpioA_hsel,
	output wire				segkey_hsel,
	output wire 			baseband_hsel,
	output wire				sysctrl_hsel,
	output wire				sysrom_hsel,

	// 默认从设备(Default slave)
	output wire				defslv_hsel

	);

	// AHB 地址译码
	// 0x0000_0000 - 0x0000_7FFF	:	ERAM code
	// 0x0100_0000 - 0x0100_0FFF	:	boot
	// 0x2000_0000 - 0x2000_4000	:	ERAM data
	// 0x4000_0000 - 0x4000_FFFF	:	CMSDK subsystem APB peripherals
	// 0x4001_0000 - 0x4001_0FFF	: CMSDK ahb gpio0
	// 0x4001_1000 - 0x4001_1FFF	: segkey
	// 0x4001_2000 - 0x4001_2FFF	: baseband
	// 0x4001_F000 - 0x4001_FFFF	: CMSDK system controller
	//


	

	// ------------------------------------------------------------------------
	// 判断程序从 boot 还是 rom 启动
	// ------------------------------------------------------------------------
	
	// 如果address = 0x0100_xxxx 或者当 remap_ctrl = 1 且address = 0x0000_xxxx
	//assign boot_hsel = (haddr[31:16] == 16'h0100) & (remap_ctrl == 1'b1) | (haddr[31:16] == 16'h0100);
	assign boot_hsel = 1'b0;
	assign rom_hsel = (haddr[31:23] == 9'b0000_0000_0) & (boot_hsel == 1'b0);

	assign sram_hsel = (haddr[31:29] == 3'b001);				//  0x2000_0000 - 0x2000_4000

	// ------------------------------------------------------------------------
	// Peripheral Selection decode logic
	// ------------------------------------------------------------------------
	assign apbsys_hsel = (haddr[31:16]==16'h4000);      // 0x40000000
	assign gpioA_hsel  = (haddr[31:12] == 20'h40010);
	assign segkey_hsel = (haddr[31:12] == 20'h40011);
	assign baseband_hsel =  (haddr[31:12] == 20'h40012);

	assign sysctrl_hsel = (haddr[31:12]==20'h4001F);		// 0x4001_F000
	assign sysrom_hsel = (haddr[31:12] == 20'hF0000);		// 0xF000_0000


	// ------------------------------------------------------------------------
	// Default slave decode logic
	// ------------------------------------------------------------------------


	assign defslv_hsel = ~ (rom_hsel	| boot_hsel | sram_hsel | apbsys_hsel | gpioA_hsel | segkey_hsel |baseband_hsel | sysctrl_hsel | sysrom_hsel);





  
endmodule