// ----------------------------------------------------------------------------
//  Version and control information:
//  File Revision       : 1.0.0
//  File Date           : 2022-03-01
//  Author              : RG
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

//  Abstract : Meteorolite 基于armcortex-m0 designstart eval 的软件无线电 FPGA 顶层设计
//
// ----------------------------------------------------------------------------

module meteorolite (

	// 系统工作指示信号
	output wire 				FLAG_NPOR,
	output wire 				FLAG_RESET_N,
	
	// 时钟
	input wire          		OSCCLK,           			// Oscillator -50Mhz, 外部晶振输入50MHZ
	output wire					out_clk_16mhz,				// 锁相环输出16MHZ时钟用于基带信号处理
	output wire					out_clk_48mhz, 				// 锁相环输出48MHZ时钟用于基带信号处理
	output wire					out_clk_24mhz,

	// 复位
  	input wire					CB_nRST,			 		// mcu系统复位输入
	input wire					CB_nPOR,					// EG4S20芯片全局复位输入(低有效)



	// Debug and Trace 
	input  wire			 		CS_GNDDETECT,   			// Ground detect
	input  wire         		CS_nTRST,       			// JTAG nTRST
  	input  wire         		CS_TDI,         			// JTAG TDI
 	input  wire         		CS_TCK,         			// SWD Clk / JTAG TCK
  	inout  wire         		CS_TMS,         			// SWD I/O / JTAG TMS
  	output wire         		CS_TDO,         			// SWV     / JTAG TDO
	input  wire			 		CS_nSRST,       			// Not required for Cortex-M
	output wire         		CS_TRACECLK,    			// Trace clock
  	output wire         		CS_TRACECTL,    			// Trace control
  	output wire		[15:0]  	CS_TRACEDATA,   			// Trace data

	// UART
	input wire					UART0_RXD,					// UART receive data
	output wire					UART0_TXD,					// UART transmit data
	input wire					UART1_RXD,					// UART receive data
	output wire					UART1_TXD,					// UART transmit data



	// I/O		
	inout wire		[15:0]		EXP,						// I/O expansion port
															// 0 - 15 gpio #0

	// 矩阵键盘和数码管
	output wire	 [3:0]			KEY_ROW,
	input wire	 [3:0]			KEY_COL,
	output wire [3:0] 			DigitronCS_OUT,
	output wire [6:0] 			Digitron_OUT,
	output wire	      			DP,

	// LCD 9341
	output  wire                        LCD_CS,
    output  wire                        LCD_RS,
    output  wire                        LCD_WR,
    output  wire                        LCD_RD,
    output  wire                        LCD_RST,
    output  wire    [15:0]              LCD_DATA,
    output  wire                        LCD_BL_CTR,

	// 基带信号处理模块接口信号
	output wire 				PWM_ENABLE,
	output wire		[30:0]		AUDIO_THR,
	input wire		[31:0]		RSSI
	

);	// end of top level pin list

	// ----------------------------------------------------------------------------
	// internal wires
	// ----------------------------------------------------------------------------

	// 时钟源信号

	//pll_top锁相环时钟输出
	wire 						pll_0_clk_50mhz;			// pll_top锁相环输出50mhz ()
	wire						pll_0_clk_16mhz;			// pll_top锁相环输出12mhz (用于基带信号处理模块)
	wire						pll_0_clk_24mhz;			// pll_top锁相环输出24mhz (用于APB时钟)
	wire						pll_0_clk_48mhz;			// pll_top锁相环输出48mhz (用于AHB时钟)	


	// 系统内部时钟信号
	wire						fclk;						// 内核时钟，主频
	wire						hclk_cpu;					// Cortex-m0 运行时钟	
	wire						hclk_dcpu;					// cortex m0 debug 时钟
	wire						hclk;						// AHB 总线时钟(没有经过门控)
	wire						hclk_gated;					// AHB 总线门控时钟
	wire						pclk;						// APB 总线时钟(没有经过门控)
	wire						pclk_gated;					// APB 总线上门控时钟
	wire						sclk;						// 系统定时器时钟
	wire		[1:0] 			pll_locked;					// 独立的pll锁定输出信号，高有效
	wire						pll_all_locked;				// 所有锁相环均已锁定，高有效


	//复位信号
	wire						cb_npor_sync;
	wire						cb_nrst_sync;
	wire						cs_nsrst_sync;
	reg							reg_sys_rst;				// EG4S20芯片全局复位寄存器
	reg							reg_cpu0_rst;				// mcu系统复位
	reg							fpga_npor;
	reg							fpga_reset_n;
	reg			[7:0] 			board_rst_counter;			// 复位计数器
	wire						board_rst_counter_done;		// 复位计数器完成标志
	wire						cpu0_hresetn;
	wire						poresetn;
	wire						hresetn;
	wire						presetn;

	wire						sys_reset_req;
	wire						wdog_reset_req;
	wire						remap_ctrl;


	// Cortex m0 处理器信号
	// These are signals which either are on Cortex M0+, (which has not been migrated to the core_partition)
  	// and not on Cortex-M0 or M0 DesignStart
  	// Or they are output from cmsdk_mcu_system to the processor core

	wire            			LOCKUPRESET;                // Control signal to enable automatic reset at lockup
	wire           				LOCKUP;                     // Lock up status
	wire						PMUENABLE;					// Power Management Unit enable (set to 1 to enable WIC mode deel sleep)
	wire            			WICENREQ;                   // WIC enable request (from PMU to WIC)
	wire            			RSTBYPASS;                  // Reset bypass (for testing)
	wire						DFTSE;                      // Design For Test Enable
	wire            			CDBGPWRUPREQ;               // Power up request
	wire            			CDBGPWRUPACK;               // Power up acknowledge
	wire            			SLEEPHOLDREQn;              // Sleep extension handshaking : hold request
	wire            			GATEHCLK;                   // Gated HCLK

	wire            			DBGRESTART;                 // multi-core synchronous restart from halt
	wire            			EDBGRQ;                     // multi-core synchronous halt request

	// User expansion I/O interface
	wire            			dbg_swo_tdo_nen;            // SWV / JTAG TDO 3-state disable

	// APB expansion port signals
	wire	     [33:0]   		WICSENSE;       			// Not used



	// event signals
	wire              			TXEV;           			// Not used
  	wire              			RXEV;           			// Used by Cortex-M0 PMTB only


	// Processor status
	wire              			CODENSEQ;       			// Not used
	wire	     [2:0]   		CODEHINTDE;     			// Not used
	wire              			SPECHTRANS;     			// Not used
	wire              			HALTED;         			// Not used






	// System bus
	wire	     [31:0]   		sys_haddr;
  	wire	     [1:0]    		sys_htrans;
  	wire	     [2:0]    		sys_hsize;
 	wire	     [2:0]    		sys_hburst;
  	wire	     [3:0]    		sys_hprot;
  	wire	              		sys_hmaster;
  	wire	              		sys_hmastlock;
  	wire	              		sys_hwrite;
  	wire	     [31:0]   		sys_hwdata;
  	wire	     [31:0]   		sys_hrdata;
  	wire	              		sys_hready;
  	wire	              		sys_hreadyout;
  	wire	              		sys_hresp;


	wire	     [31:0]   		intisr_cm0;    				// Combined interrupts output to core
  	wire              			intnmi_cm0;    				// NMI interrupt output to core


	// SysTick timer signal
	wire              			STCLKEN;
  	wire	     [25:0]   		STCALIB;

	wire          				dbg_swio_tms_o;             // SWD I/O 3-state output
    wire          				dbg_swio_tms_en;            // SWD I/O 3-state enable
    wire          				dbg_swo_tdo_o;              // SWV / JTAG TDO
    wire          				dbg_swo_tdo_en;             // SWV / JTAG TDO tristata enable

	// Debug connection
    assign 		CS_TMS				 = 		dbg_swio_tms_en ? dbg_swio_tms_o : 1'bz;
    assign 		CS_TDO				 = 		dbg_swo_tdo_en  ? dbg_swo_tdo_o  : 1'bz;

	// No DMA controller ,direct connection from cpu to system bus
	assign   	sys_hready		     = 		sys_hreadyout;
	assign   	sys_hmaster_i	     = 		2'b00;



	// ------------------------------------------------------------------------
	// 外设信号
	// ------------------------------------------------------------------------
	
	// Boot rom
	wire 						boot_hsel;
	wire 						boot_hresp;
	wire 						boot_hreadyout;
	wire 		[31:0] 			boot_hrdata;
	wire 		[9:0] 			boot_addr;
	wire		[3:0] 			boot_wen;	
	wire						boot_cs;
	wire		[31:0] 			boot_wdata;
	wire		[31:0]			boot_rdata;

	// SRAM 256k for code
	wire 						sram256_hsel;
	wire 						sram256_hresp;
	wire 						sram256_hreadyout;
	wire 		[31:0] 			sram256_hrdata;
	wire 		[12:0] 			sram256_addr;
	wire		[3:0] 			sram256_wen;	
	wire						sram256_cs;
	wire		[31:0] 			sram256_wdata;
	wire		[31:0]			sram256_rdata;

	// SRAM 128k for code
	wire 						sram128_hsel;
	wire 						sram128_hresp;
	wire 						sram128_hreadyout;
	wire 		[31:0] 			sram128_hrdata;
	wire 		[11:0] 			sram128_addr;
	wire		[3:0] 			sram128_wen;	
	wire						sram128_cs;
	wire		[31:0] 			sram128_wdata;
	wire		[31:0]			sram128_rdata;

	// Ahb gpioA
	wire     	         		gpioA_hsel;
  	wire     	         		gpioA_hreadyout;
  	wire     	[31:0]   		gpioA_hrdata;
  	wire     	         		gpioA_hresp;

	// apb subsystem
	wire						apbsys_hsel;
	wire						apbsys_hreadyout;
	wire		[31:0] 			apbsys_hrdata;
	wire						apbsys_hresp;

	// APB expansion port signals
  	wire     	[11:0]   		exp_paddr;
  	wire     	[31:0]   		exp_pwdata;
  	wire              			exp_pwrite;
  	wire              			exp_penable;

	// AHB default slave signals
	wire						defslv_hsel;
	wire						defslv_hreadyout;
	wire		[31:0]			defslv_hrdata;
	wire						defslv_hresp;

	// System rom table
	wire              			sysrom_hsel;      			// AHB to System ROM Table - select
  	wire              			sysrom_hreadyout; 			// AHB from System ROM Table - ready
  	wire		[31:0]   		sysrom_hrdata;    			// AHB from System ROM Table - read data
  	wire              			sysrom_hresp;     			// AHB from System ROM Table - response



	// System control bus 
	wire              			sysctrl_hsel; 
  	wire              			sysctrl_hreadyout;
  	wire	    [31:0]   		sysctrl_hrdata;
  	wire              			sysctrl_hresp;

	// 数码管和矩阵键盘
	wire              			segkey_hsel; 
  	wire              			segkey_hreadyout;
  	wire	    [31:0]   		segkey_hrdata;
  	wire              			segkey_hresp;

	// 基带信号控制模块
	wire              			baseband_hsel; 
  	wire              			baseband_hreadyout;
  	wire	    [31:0]   		baseband_hrdata;
  	wire              			baseband_hresp;

	// LCD9341 接口模块
	wire						lcd_psel;
	wire		[31:0]			lcd_prdata;
	wire 						lcd_pready;
  	wire 						lcd_pslverr;
	  

	// I/O port outputs
	wire		[15:0]			io_exp_port_i;				// I/O port intputs
	wire		[15:0]			io_exp_port_o;				// I/O port outputs
	wire		[15:0] 			io_exp_port_oen;			// I/O port output enables
	wire		[15:0] 			io_exp_port_mcu_altfunc;

	wire		[15:0] 			gpioA_i;
	wire		[15:0] 			gpioA_o;
	wire		[15:0] 			gpioA_oen;
	wire		[15:0] 			gpioA_altfunc;



	// Interrupt request
	wire	  	[15:0]  		gpioA_intr;
  	wire              			gpio0_combintr;
	wire		[31:0]			apbsubsys_interrupt;
	wire						watchdog_interrupt;
	wire						segkey_intr;
	
	// 对CB_nPOR进行取反，用于锁相环复位信号
	wire					 	CB_pPOR;
	assign					 	CB_pPOR = ~CB_nPOR;




	// ----------------------------------------------------------------------------
	// PLL 锁相环
	// ----------------------------------------------------------------------------

	// EG4S20 内部硬核PLL
	pll_top u_pll_top(
		.refclk(OSCCLK),										// 50MHz 晶振时钟输入
		.reset(CB_pPOR),										// 
		.extlock(pll_locked[0]),								// pll_top 锁定输出
		.clk0_out(pll_0_clk_50mhz),								// 50mhz时钟输出
		.clk1_out(pll_0_clk_48mhz),								// 48mhz时钟输出
		.clk2_out(pll_0_clk_24mhz),								// 24mhz时钟输出
		.clk3_out(pll_0_clk_16mhz)								// 16mhz时钟输出
	);

	assign	pll_locked[1] 	 = 1'b1;
	assign 	fclk			 = pll_0_clk_48mhz;
	assign	pclk			 = pll_0_clk_24mhz;	
	assign 	out_clk_16mhz	 = pll_0_clk_16mhz;
	assign 	out_clk_48mhz	 = pll_0_clk_48mhz;
	assign	out_clk_24mhz	 = pll_0_clk_24mhz;

	assign	pll_all_locked	 = (pll_locked[1:0] == 2'b11);


	// ------------------------------------------------------------------------
	// Clock
	// ------------------------------------------------------------------------ 

	// 门控时钟
	assign hclk				 = fclk;							// 将fclk 时钟和hclk时钟设为相等
	assign hclk_cpu			 = fclk;							// 将fclk时钟用于cpu主频时钟
	assign hclk_gated		 = hclk;							// 由于没有经过门控，因此 hclk_gated 和 hclk 直接连接
	assign pclk_gated		 = pclk;							// 由于没有经过门控，因此 pclk_gated 和 pclk 直接连接


	// ------------------------------------------------------------------------
	// Reset
	// ------------------------------------------------------------------------
	// 1.0.0 版本设计：
	// CB_nPOR EG4S20芯片全局复位
	// 外部端口复位mcu系统
	// 

	// 同步复位 CB_nPOR
	fpga_rst_sync u_fpga_rst_sync_1(
		.clk(fclk),
		.rst_n_in(CB_nPOR),
		.rst_request(1'b0),
		.rst_n_out(cb_npor_sync)
	);

	// 同步复位 
	fpga_rst_sync u_fpga_rst_sync_2(
		.clk(fclk),
		.rst_n_in(CB_nRST),
		.rst_request(1'b0),
		.rst_n_out(cb_nrst_sync)
	);

	// 同步复位 
	fpga_rst_sync u_fpga_rst_sync_3(
		.clk(fclk),
		.rst_n_in(CS_nSRST),
		.rst_request(1'b0),
		.rst_n_out(cs_nsrst_sync)
	);

	// 复位计数器
	// 如果按下上电复位按钮(复位mcu、以及芯片上的其他外围设备)或 PLL 未锁定(刚上电)，则判定复位
	always @(posedge fclk or negedge cb_npor_sync) begin
		if (~cb_npor_sync)
			board_rst_counter <= 8'h00;
		else
			begin
				if (pll_all_locked == 1'b0)
					board_rst_counter <= 8'h00;
				else if(board_rst_counter != 8'hff)
					board_rst_counter <= board_rst_counter + 8'h01;
			end
	end

	assign board_rst_counter_done = (board_rst_counter==8'hff);

	// fpga_npor 复位寄存器
	always @(posedge fclk or negedge CB_nPOR) begin
		if (~CB_nPOR) 
			fpga_npor <= 1'b0;
		else begin
			if (~board_rst_counter_done)
				fpga_npor <= 1'b0; 								// 复位255个时钟周期
			else
				fpga_npor <= 1'b1;								// 复位释放
		end
	end

	// fpga_reset_n复位寄存器
	always @(posedge fclk or negedge cb_nrst_sync) begin
		if(~cb_nrst_sync)
			fpga_reset_n <= 1'b0;
		else begin
			if(~board_rst_counter_done)
				fpga_reset_n <= 1'b0;							// 复位255个时钟周期
			else
				fpga_reset_n <= 1'b1;							// 复位释放
			
		end
	end

	// EG4S20芯片全局复位reg_sys_rst，用于复位芯片上的硬核IP和mcu系统外的一些外设
	always @(posedge fclk or negedge fpga_npor) begin
		if (~fpga_npor)
			reg_sys_rst <= 1'b0;
		else
			if (sys_reset_req | wdog_reset_req | (LOCKUP & LOCKUPRESET))
				reg_sys_rst <= 1'b0;
			else
				reg_sys_rst <= 1'b1;
			
	end

	// mcu系统复位
	always @(posedge fclk or negedge fpga_reset_n) begin
    	if (~fpga_reset_n)
     		 reg_cpu0_rst <= 1'b0;
    	else
      		if ( sys_reset_req | wdog_reset_req | (LOCKUP & LOCKUPRESET))
        		reg_cpu0_rst <= 1'b0;
     		 else
        		reg_cpu0_rst <= 1'b1;
    end

	assign hresetn     	 = 	reg_sys_rst;  						// 复位mcu系统外的部分 ahb线
	assign presetn     	 = 	reg_sys_rst;  						//synthesis keep
																// 复位mcu系统外的部分 apb线
	assign cpu0_hresetn	 = 	reg_cpu0_rst; 						// For CPU only - release after CB_nRST
	assign poresetn   	 = 	fpga_reset_n; 						// For CPU only - release after CB_nRST
	//assign FLAG_NPOR	 = 	reg_sys_rst;
	assign FLAG_NPOR	 = 	presetn;
	assign FLAG_RESET_N	 = 	reg_cpu0_rst;


	




	//---------------------------------------------------
  	// Loop back of debug power up request to acknowledge
  	//---------------------------------------------------
	reg    reg_cdbgpwrup_req;
	always @(posedge fclk or negedge fpga_reset_n) begin
    	if (~fpga_reset_n)
      		reg_cdbgpwrup_req <= 1'b0;
    	else
      		reg_cdbgpwrup_req <= CDBGPWRUPREQ;
    end

  	assign CDBGPWRUPACK   = reg_cdbgpwrup_req;



	// ------------------------------------------------------------------------
	// 处理器和电源管理
	// ------------------------------------------------------------------------
	CORTEXM0INTEGRATION u_cortex_m0_integration (
		// System inputs
		.FCLK			(fclk),									// FCLK
		.SCLK			(fclk),
		.HCLK			(hclk),
		.DCLK			(fclk),
		.PORESETn       (poresetn),
    	.HRESETn        (cpu0_hresetn),
    	.DBGRESETn      (poresetn),
    	.RSTBYPASS      (RSTBYPASS),
    	.SE             (DFTSE),

		// Power management inputs
		.SLEEPHOLDREQn	(SLEEPHOLDREQn),
		.WICENREQ       (WICENREQ),
		.CDBGPWRUPACK   (CDBGPWRUPACK),

		// Power management outputs
		.SLEEPHOLDACKn  (SLEEPHOLDACKn),
		.WICENACK       (/*Unused*/),
		.CDBGPWRUPREQ   (CDBGPWRUPREQ),

		.WAKEUP         (/*Unused*/),
		.WICSENSE       (WICSENSE),
		.GATEHCLK       (GATEHCLK),
		.SYSRESETREQ    (sys_reset_req),

		// System bus
		.HADDR          (sys_haddr),
    	.HTRANS         (sys_htrans),
    	.HSIZE          (sys_hsize),
    	.HBURST         (sys_hburst),
    	.HPROT          (sys_hprot),
    	.HMASTER        (sys_hmaster),
    	.HMASTLOCK      (sys_hmastlock),
    	.HWRITE         (sys_hwrite),
    	.HWDATA         (sys_hwdata),
    	.HRDATA         (sys_hrdata),
    	.HREADY         (sys_hready),
    	.HRESP          (sys_hresp),

		.CODEHINTDE     (CODEHINTDE),
    	.SPECHTRANS     (SPECHTRANS),
    	.CODENSEQ       (CODENSEQ),

		// Interrupts
		.IRQ            (intisr_cm0[31:0]),
    	.NMI            (intnmi_cm0),
    	.IRQLATENCY     (8'h00),
    	.ECOREVNUM      (28'h0),

		// Systick
		.STCLKEN        (STCLKEN),
    	.STCALIB        (STCALIB),

		// Debug - JTAG or Serial wire
		// Inputs
		.nTRST          (CS_nTRST),
    	.SWDITMS        (CS_TMS),
    	.SWCLKTCK       (CS_TCK),
    	.TDI            (CS_TDI),
    	// Outputs
    	.TDO            (dbg_swo_tdo_o),
    	.nTDOEN         (dbg_swo_tdo_nen),
    	.SWDO           (dbg_swio_tms_o),
    	.SWDOEN         (dbg_swio_tms_en),

    	.DBGRESTART     (DBGRESTART),
    	.DBGRESTARTED   (/* Unused*/),

		// Event communication
		.TXEV           (TXEV),
    	.RXEV           (RXEV),
    	.EDBGRQ         (EDBGRQ),

		// Status output
		.HALTED         (HALTED),
    	.LOCKUP         (LOCKUP),
    	.SLEEPING       (/* Unused*/),
    	.SLEEPDEEP      (/* Unused*/)
	);

	// ------------------------------------------------------------------------
	// AHB addres decode
	// ------------------------------------------------------------------------
	cmsdk_mcu_addr_decode u_cmsdk_mcu_addr_decode(

		// 系统地址
		.haddr		 	(sys_haddr),
		.remap_ctrl	 	(remap_ctrl),

		// 存储选择	
		.boot_hsel	 	(boot_hsel),
		.rom_hsel	 	(sram256_hsel),
		.sram_hsel	 	(sram128_hsel),
		.apbsys_hsel 	(apbsys_hsel),
		.gpioA_hsel	 	(gpioA_hsel),
		.segkey_hsel	(segkey_hsel),
		.baseband_hsel	(baseband_hsel),
		.sysctrl_hsel	(sysctrl_hsel),
		.sysrom_hsel 	(sysrom_hsel),
		.defslv_hsel 	(defslv_hsel)
	);

	// ------------------------------------------------------------------------
	// AHB slave multiplexer
	// ------------------------------------------------------------------------
	cmsdk_ahb_slave_mux #(
		.PORT0_ENABLE  (1),				// boot
    	.PORT1_ENABLE  (1),				// SRAM code
    	.PORT2_ENABLE  (1),				// SRAM data
    	.PORT3_ENABLE  (1),				// default slave
    	.PORT4_ENABLE  (1),				// apb subsystem
    	.PORT5_ENABLE  (1),				// gpio 0
    	.PORT6_ENABLE  (1),				// sysctrl
    	.PORT7_ENABLE  (1),				// sysrom
    	.PORT8_ENABLE  (1),
    	.PORT9_ENABLE  (1),
    	.DW            (32)
		) 
	u_cmsdk_ahb_slave_mux (
		.HCLK		(hclk),
		.HRESETn	(cpu0_hresetn),
		.HREADY		(sys_hready),
		.HREADYOUT	(sys_hreadyout),
		.HRESP		(sys_hresp),
		.HRDATA		(sys_hrdata),
		
		.HSEL0		(boot_hsel),
		.HREADYOUT0	(boot_hreadyout),
		.HRESP0		(boot_hresp),
		.HRDATA0	(boot_hrdata),
		.HSEL1		(sram256_hsel),
		.HREADYOUT1	(sram256_hreadyout),
		.HRESP1		(sram256_hresp),
		.HRDATA1	(sram256_hrdata),
		.HSEL2		(sram128_hsel),
		.HREADYOUT2	(sram128_hreadyout),
		.HRESP2		(sram128_hresp),
		.HRDATA2	(sram128_hrdata),
		.HSEL3		(defslv_hsel),
		.HREADYOUT3	(defslv_hreadyout),
		.HRESP3		(defslv_hresp),
		.HRDATA3	(defslv_hrdata),
		.HSEL4		(apbsys_hsel),
		.HREADYOUT4	(apbsys_hreadyout),
		.HRESP4		(apbsys_hresp),
		.HRDATA4	(apbsys_hrdata),
		.HSEL5		(gpioA_hsel),
		.HREADYOUT5	(gpioA_hreadyout),
		.HRESP5		(gpioA_hresp),
		.HRDATA5	(gpioA_hrdata),
		.HSEL6		(sysctrl_hsel),
		.HREADYOUT6	(sysctrl_hreadyout),
		.HRESP6		(sysctrl_hresp),
		.HRDATA6	(sysctrl_hrdata),
		.HSEL7		(sysrom_hsel),
		.HREADYOUT7	(sysrom_hreadyout),
		.HRESP7		(sysrom_hresp),
		.HRDATA7	(sysrom_hrdata),
		.HSEL8      (segkey_hsel),     
    	.HREADYOUT8 (segkey_hreadyout),
    	.HRESP8     (segkey_hresp),
    	.HRDATA8    (segkey_hrdata),
		.HSEL9      (baseband_hsel),     
    	.HREADYOUT9 (baseband_hreadyout),
    	.HRESP9     (baseband_hresp),
    	.HRDATA9    (baseband_hrdata)


	);

	// ------------------------------------------------------------------------
	// Default slave 
	// ------------------------------------------------------------------------
	cmsdk_ahb_default_slave u_ahb_default_slave_1(
		.HCLK	 	 (hclk),
		.HRESETn	 (cpu0_hresetn),
		.HSEL		 (defslv_hsel),
		.HTRANS		 (sys_htrans),
		.HREADY		 (sys_hready),
		.HREADYOUT	 (defslv_hreadyout),
		.HRESP		 (defslv_hresp)
	);

	assign defslv_hrdata = 32'h0000_0000;

	// ------------------------------------------------------------------------
	// 矩阵键盘和数码管 
	// ------------------------------------------------------------------------
	 AHB_SEG_KEY u_AHB_SEG_KEY(
		.HSEL(segkey_hsel),
		.HCLK(hclk),
		.HRESETn(cpu0_hresetn),
		.HREADY(sys_hready),
		.HADDR(sys_haddr),
		.HTRANS(sys_htrans),
		.HWRITE(sys_hwrite),
		.HSIZE(sys_hsize),
		.HWDATA(sys_hwdata),
		.HREADYOUT(segkey_hreadyout),
		.HRDATA(segkey_hrdata),
		
		.seg(Digitron_OUT),
		.an(DigitronCS_OUT),
		.dp(DP),
		.COL(KEY_COL),
		.ROW(KEY_ROW),
		.KEY_IRQ(segkey_intr)
);
	// -----------------------------------------------------------------------
	// 基带信号处理控制模块
	// -----------------------------------------------------------------------
	AHB_BASEBAND_CONTROL u_AHB_BASEBAND_CONTROL(
		.HSEL(baseband_hsel),
		.HCLK(hclk),
		.HRESETn(cpu0_hresetn),
		.HREADY(sys_hready),
		.HADDR(sys_haddr),
		.HTRANS(sys_htrans),
		.HWRITE(sys_hwrite),
		.HSIZE(sys_hsize),
		.HWDATA(sys_hwdata),
		.HREADYOUT(baseband_hreadyout),
		.HRDATA(baseband_hrdata),

		// 输入接口
		.RSSI(RSSI),
		// 输出接口
		.PWM_ENABLE(PWM_ENABLE),
		.AUDIO_THR(AUDIO_THR)
	);


	// ------------------------------------------------------------------------
	// System rom table
	// ------------------------------------------------------------------------
	cmsdk_ahb_cs_rom_table #(
		//.JEPID                             (),
     	//.JEPCONTINUATION                   (),
     	//.PARTNUMBER                        (),
     	//.REVISION                          (),
     	.BASE              (32'hF0000000),
    	 // Entry 0 = Cortex-M0+ Processor
     	.ENTRY0BASEADDR    (32'hE00FF000),
     	.ENTRY0PRESENT     (1'b1),
     	// Entry 1 = CoreSight MTB-M0+
     	.ENTRY1BASEADDR    (32'hF0200000),
     	.ENTRY1PRESENT     (0))
    u_system_rom_table (
		//Outputs
     	.HRDATA            (sysrom_hrdata[31:0]),
     	.HREADYOUT         (sysrom_hreadyout),
     	.HRESP             (sysrom_hresp),
     	//Inputs
     	.HCLK              (hclk),
     	.HSEL              (sysrom_hsel),
     	.HADDR             (sys_haddr[31:0]),
     	.HBURST            (sys_hburst[2:0]),
     	.HMASTLOCK         (sys_hmastlock),
     	.HPROT             (sys_hprot[3:0]),
     	.HSIZE             (sys_hsize[2:0]),
     	.HTRANS            (sys_htrans[1:0]),
     	.HWDATA            (sys_hwdata[31:0]),
     	.HWRITE            (sys_hwrite),
     	.HREADY            (sys_hready),
     	.ECOREVNUM         (4'h0)
	);


	// ------------------------------------------------------------------------
	// Sysctrl
	// ------------------------------------------------------------------------
	cmsdk_mcu_sysctrl #(.BE (0))
	u_cmsdk_mcu_sysctrl(
		 // AHB Inputs
    	.HCLK         	(hclk),
    	.HRESETn      	(cpu0_hresetn),
    	.FCLK         	(fclk),
    	.PORESETn     	(poresetn),
    	.HSEL         	(sysctrl_hsel),
    	.HREADY       	(sys_hready),
    	.HTRANS       	(sys_htrans),
    	.HSIZE        	(sys_hsize),
    	.HWRITE       	(sys_hwrite),
    	.HADDR        	(sys_haddr[11:0]),
    	.HWDATA       	(sys_hwdata),
   		// AHB Outputs	
    	.HREADYOUT    	(sysctrl_hreadyout),
    	.HRESP        	(sysctrl_hresp),
    	.HRDATA       	(sysctrl_hrdata),
   		// Reset information
    	.SYSRESETREQ  	(sys_reset_req),
    	.WDOGRESETREQ 	(wdog_reset_req),
    	.LOCKUP       	(LOCKUP),
    	// Engineering-change-order revision bits
    	.ECOREVNUM	    (4'h0),
   		// System control signals
    	.REMAP        	(remap_ctrl),
    	.PMUENABLE    	(PMUENABLE),
    	.LOCKUPRESET  	(LOCKUPRESET)
	);

	// ------------------------------------------------------------------------
	// SysTick signals
	// ------------------------------------------------------------------------
	cmsdk_mcu_stclkctrl #(
		.DIV_RATIO		(18'd01000)
	)
   		u_cmsdk_mcu_stclkctrl (
    	.FCLK      		(fclk),
    	.SYSRESETn 		(cpu0_hresetn),

    	.STCLKEN   		(STCLKEN),
    	.STCALIB   		(STCALIB)
    );		



	// ------------------------------------------------------------------------
	// Boot ROM - for booting up the system
	// ------------------------------------------------------------------------


	cmsdk_ahb_to_sram #(
		.AW(12)										// Address width
	)
		u_cmsdk_ahb_to_sram_0(
			.HCLK	 		(hclk),					// system bus clock
			.HRESETn 		(cpu0_hresetn),			// system bus reset
			.HSEL	 		(boot_hsel),			// AHB peripheral select
			.HREADY	 		(sys_hready),    		// AHB ready input
			.HTRANS	 		(sys_htrans),    		// AHB transfer type
			.HSIZE	 		(sys_hsize),     		// AHB hsize
			.HWRITE	 		(sys_hwrite),    		// AHB hwrite
			.HADDR	 		(sys_haddr[11:0]),     	// AHB address bus
			.HWDATA	 		(sys_hwdata),    		// AHB write data bus
       		.HREADYOUT		(boot_hreadyout), 		// AHB ready output to S->M mux
       		.HRESP			(boot_hresp),     		// AHB response
			.HRDATA			(boot_hrdata),    		// AHB read data bus
			
			.SRAMRDATA		(boot_rdata), 			// SRAM Read Data
			.SRAMADDR	 	(boot_addr),  			// SRAM address
			.SRAMWEN		(boot_wen),   			// SRAM write enable (active high)
			.SRAMWDATA		(boot_wdata), 			// SRAM write data
        	.SRAMCS			(boot_cs)   			// SRAM Chip Select  (active high)
	);

	boot_32k u_boot32k(
			.doa			(boot_rdata),
			.dia			(boot_wdata),
			.addra			(boot_addr),
			.cea			(boot_cs),
			.clka			(hclk),
			.wea			(boot_wen)
	);

	// ------------------------------------------------------------------------
	// SRAM for code
	// ------------------------------------------------------------------------
	cmsdk_ahb_to_sram #(
		.AW(15)										// Address width
	)
		u_cmsdk_ahb_to_sram_1(
			.HCLK			(hclk),					// system bus clock
			.HRESETn		(cpu0_hresetn),			// system bus reset
			.HSEL			(sram256_hsel),			// AHB peripheral select
			.HREADY			(sys_hready),    		// AHB ready input
			.HTRANS			(sys_htrans),    		// AHB transfer type
			.HSIZE			(sys_hsize),     		// AHB hsize
			.HWRITE			(sys_hwrite),    		// AHB hwrite
			.HADDR			(sys_haddr[14:0]),     	// AHB address bus
			.HWDATA			(sys_hwdata),    		// AHB write data bus
      		.HREADYOUT		(sram256_hreadyout), 	// AHB ready output to S->M mux
      		.HRESP			(sram256_hresp),     	// AHB response
			.HRDATA			(sram256_hrdata),    	// AHB read data bus
			
			.SRAMRDATA		(sram256_rdata), 		// SRAM Read Data
			.SRAMADDR		(sram256_addr),  		// SRAM address
			.SRAMWEN		(sram256_wen),   		// SRAM write enable (active high)
			.SRAMWDATA		(sram256_wdata), 		// SRAM write data
      		.SRAMCS			(sram256_cs)   			// SRAM Chip Select  (active high)
	);

	sram_256k u_sram_256k(
			.doa			(sram256_rdata),
			.dia			(sram256_wdata),
			.addra			(sram256_addr),
			.cea			(sram256_cs),
			.clka			(hclk),
			.wea			(sram256_wen)
	);

	// ------------------------------------------------------------------------
	// SRAM for data
	// ------------------------------------------------------------------------
	cmsdk_ahb_to_sram #(
		.AW(14)										// Address width
		)
		u_cmsdk_ahb_to_sram_2(
			.HCLK		 (hclk),					// system bus clock
			.HRESETn	 (cpu0_hresetn),			// system bus reset
			.HSEL		 (sram128_hsel),			// AHB peripheral select
			.HREADY		 (sys_hready),    			// AHB ready input
			.HTRANS		 (sys_htrans),    			// AHB transfer type
			.HSIZE		 (sys_hsize),     			// AHB hsize
			.HWRITE		 (sys_hwrite),    			// AHB hwrite
			.HADDR		 (sys_haddr[13:0]),     	// AHB address bus
			.HWDATA		 (sys_hwdata),    			// AHB write data bus
      		.HREADYOUT	 (sram128_hreadyout), 		// AHB ready output to S->M mux
      		.HRESP		 (sram128_hresp),     		// AHB response
			.HRDATA		 (sram128_hrdata),    		// AHB read data bus
			
			.SRAMRDATA	 (sram128_rdata), 			// SRAM Read Data
			.SRAMADDR	 (sram128_addr),  			// SRAM address
			.SRAMWEN	 (sram128_wen),   			// SRAM write enable (active high)
			.SRAMWDATA	 (sram128_wdata), 			// SRAM write data
      		.SRAMCS		 (sram128_cs)   			// SRAM Chip Select  (active high)
		);

	sram_128k u_sram_128k(
		.doa		 (sram128_rdata),
		.dia		 (sram128_wdata),
		.addra		 (sram128_addr),
		.cea		 (sram128_cs),
		.clka		 (hclk),
		.wea		 (sram128_wen)
	);


	// --------------------------------------------------------------------
	// APB subsystem for timers uarts
	// --------------------------------------------------------------------
	cmsdk_apb_subsystem #(
		.APB_EXT_PORT12_ENABLE(1),				// LCD9341
		.APB_EXT_PORT13_ENABLE(0),				// 
		.APB_EXT_PORT14_ENABLE(0),
		.APB_EXT_PORT15_ENABLE(0),
		.INCLUDE_IRQ_SYNCHRONIZER(1),
		.INCLUDE_APB_TEST_SLAVE(1),
		.INCLUDE_APB_TIMER0(1),
		.INCLUDE_APB_TIMER1(1), 
		.INCLUDE_APB_DUALTIMER0(1), 
		.INCLUDE_APB_UART0(1),
		.INCLUDE_APB_UART1(1),  
		.INCLUDE_APB_UART2(0),
		.INCLUDE_APB_WATCHDOG(1),
		.BE(0)
	)
		u_apb_subsystem(
			.HCLK		 	(hclk),
			.HRESETn	 	(cpu0_hresetn),
			.HSEL		 	(apbsys_hsel),
			.HADDR		 	(sys_haddr[15:0]),
			.HTRANS		 	(sys_htrans[1:0]),
			.HWRITE		 	(sys_hwrite),
			.HSIZE		 	(sys_hsize),
			.HPROT		 	(sys_hprot),
			.HREADY		 	(sys_hready),
			.HWDATA		 	(sys_hwdata),
			.HREADYOUT	 	(apbsys_hreadyout),
			.HRDATA		 	(apbsys_hrdata),
			.HRESP		 	(apbsys_hresp),

			.PCLK		 	(pclk),    
			.PCLKG		 	(pclk_gated),   
			.PCLKEN		 	(1'b1),  
			.PRESETn	 	(cpu0_hresetn), 

			.PADDR		 	(exp_paddr[11:0]),
			.PWRITE		 	(exp_pwrite),
			.PWDATA		 	(exp_pwdata),
			.PENABLE	 	(exp_penable),

			.ext12_psel  	(lcd_psel),
    		.ext13_psel  	(),
    		.ext14_psel  	(),
    		.ext15_psel  	(),

			// Input from APB device on APB expansion ports
			.ext12_prdata  (lcd_prdata),
    		.ext12_pready  (lcd_pready),
    		.ext12_pslverr (lcd_pslverr),

    		.ext13_prdata  (32'h00000000),
    		.ext13_pready  (1'b1),
    		.ext13_pslverr (1'b0),

    		.ext14_prdata  (32'h00000000),
    		.ext14_pready  (1'b1),
    		.ext14_pslverr (1'b0),

    		.ext15_prdata  (32'h00000000),
    		.ext15_pready  (1'b1),
    		.ext15_pslverr (1'b0),

			.APBACTIVE     (/*Unused*/),  // Status Output for clock gating

			// Peripherals
			// UART
			.uart0_rxd     (UART0_RXD),
    		.uart0_txd     (UART0_TXD),
    		.uart0_txen    (/*Unused*/),

			.uart1_rxd     (UART1_RXD),
    		.uart1_txd     (UART1_TXD),
    		.uart1_txen    (/*Unused*/),

			.uart2_rxd     (/*Unused*/),
    		.uart2_txd     (/*Unused*/),
    		.uart2_txen    (/*Unused*/),

			// Timer
			.timer0_extin	(/*Unused*/),
			.timer1_extin	(/*Unused*/),

			// Interrupt outputs
    		.apbsubsys_interrupt (apbsubsys_interrupt),
    		.watchdog_interrupt  (watchdog_interrupt),
   			// reset output
    		.watchdog_reset      (wdog_reset_req)

		);

	// APB LCD9341
	APB_LCD_9341 u_APB_LCD_9341(
    	.PCLK(pclk),
    	.PCLKG(pclk),
    	.PRESETn(cpu0_hresetn),
    	.PSEL(lcd_psel),
    	.PADDR(exp_paddr),
    	.PENABLE(exp_penable),
    	.PWRITE(exp_pwrite),
    	.PWDATA(exp_pwdata),
    	.PRDATA(lcd_prdata),
    	.PREADY(lcd_pready),
    	.PSLVERR(lcd_pslverr),
    	.LCD_CS(LCD_CS),
    	.LCD_RS(LCD_RS),
    	.LCD_WR(LCD_WR),
    	.LCD_RD(LCD_RD),
    	.LCD_RST(LCD_RST),
    	.LCD_DATA(LCD_DATA),
    	.LCD_BL_CTR(LCD_BL_CTR)
);



	// --------------------------------------------------------------------
	// 3-state buffers
	// --------------------------------------------------------------------
	genvar i1;

	// I/O expansion port
	generate
		for (i1=0;i1<16;i1=i1+1)
			begin: gen_port_3state
				assign EXP[i1] = (io_exp_port_oen[i1]) ? io_exp_port_o[i1] : 1'bz;
			end
	endgenerate

		assign io_exp_port_i = EXP; 


	// --------------------------------------------------------------------
	// GPIO driven frome the AHB
	// --------------------------------------------------------------------
	cmsdk_ahb_gpio #(
    	.ALTERNATE_FUNC_MASK     (16'hFFFF), // Permit pin muxing for Port #0
    	.ALTERNATE_FUNC_DEFAULT  (16'h0000), // All pins default to GPIO
    	.BE                      (0)
    )
		u_ahb_gpio_0(
			// AHB Inputs
    		.HCLK         (hclk),
    		.HRESETn      (cpu0_hresetn),
    		.FCLK         (fclk),
    		.HSEL         (gpioA_hsel),
    		.HREADY       (sys_hready),
    		.HTRANS       (sys_htrans),
    		.HSIZE        (sys_hsize),
    		.HWRITE       (sys_hwrite),
    		.HADDR        (sys_haddr[11:0]),
    		.HWDATA       (sys_hwdata),
   			// AHB Outputs
    		.HREADYOUT    (gpioA_hreadyout),
    		.HRESP        (gpioA_hresp),
    		.HRDATA       (gpioA_hrdata),

    		.ECOREVNUM    (4'h0),// Engineering-change-order revision bits

    		.PORTIN       (gpioA_i),   // GPIO Interface inputs
    		.PORTOUT      (gpioA_o),  // GPIO Interface outputs
    		.PORTEN       (gpioA_oen),
    		.PORTFUNC     (gpioA_altfunc), // Alternate function control

    		.GPIOINT      (gpioA_intr[15:0]),  // Interrupt outputs
    		.COMBINT      (gpio0_combintr)
		);



	// -----------------------------------------------------------------------------------------------------------------
	// *****************************************************************************************************************
	// Interrupt assignment
	//
	// *****************************************************************************************************************
	// -----------------------------------------------------------------------------------------------------------------

	assign intnmi_cm0        = watchdog_interrupt;
  	assign intisr_cm0[ 1: 0] = apbsubsys_interrupt[1:0];
	assign intisr_cm0[3:2] = apbsubsys_interrupt[3:2];


	assign intisr_cm0[31:4] = 28'b0;


	assign gpioA_i =	io_exp_port_i[15:0];
	assign 	io_exp_port_o[15:0] =gpioA_o;
	assign io_exp_port_oen[15:0] = gpioA_oen;
	assign gpioA_altfunc = io_exp_port_mcu_altfunc[15:0];





	// Unusedf debug feature
	assign RSTBYPASS      	= 1'b0;    			// Reset bypass (for testing)
	assign DFTSE          	= 1'b0;     		// Design For Test Enable
	assign WICENREQ       	= 1'b0; 			// Not used
	assign SLEEPHOLDREQn  	= 1'b1; 			// Not used
	assign DBGRESTART		= 1'b0;				// Unused debug feature
	assign EDBGRQ	        = 1'b0;

	//
	assign dbg_swo_tdo_en  = ~dbg_swo_tdo_nen;
	assign RXEV = 1'b0;


	


	// Lint checks, tie off all the unused signals
	wire     unused;
	assign   unused = SPECHTRANS | CODENSEQ | (|CODEHINTDE) | TXEV | (|WICSENSE) | HALTED | sys_hmaster; 

endmodule