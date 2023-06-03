// ----------------------------------------------------------------------------
//  Version and control information:
//  File Revision       : 1.0.0
//  File Date           : 2022-04-18
//  Author              : RG
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

//  Abstract : Meteorolite FPGA 基带信号处理模块 信号处理模块 testbench
//
// ----------------------------------------------------------------------------

`timescale 1ns/1ns
module tb_TVR ();

  	
	reg clk_aq;			// IQ采样时钟 500KHZ
	reg clk_pll;
	reg RSTn;
	reg [11:0]	I_t;	// I 信号
	reg [11:0]	Q_t;	// Q信号






	wire	[31:0] demod_out;//synthesis keep
  	wire    [11:0] modulo;//synthesis keep
  	wire    [23:0] AVG_data; //synthesis keep




	wire signed [20:0] Audio_wave_Q;
    wire signed [20:0] Audio_wave_I;
    wire signed [11:0] I_Lout;
    wire signed [11:0] Q_Lout;
	wire signed [11:0] I_out;
	wire signed [11:0] Q_out;

    assign I_Lout = {~I_t[11],I_t[10:0]};
	assign Q_Lout = {~Q_t[11],Q_t[10:0]};

	fir_50_3 Fiter_LPF_I(
    .clk(clk_aq),
    .clk_enable(1'd1),
    .reset(0),
    .filter_in(I_Lout),
    .filter_out(Audio_wave_I)
);
	fir_50_3 Fiter_LPF_Q(
    .clk(clk_aq),
    .clk_enable(1'd1),
    .reset(0),
    .filter_in(Q_Lout),
    .filter_out(Audio_wave_Q)
);
    assign I_out = Audio_wave_I[19:8];
    assign Q_out = Audio_wave_Q[19:8];


	TVR_Demod #(
    .OUTPUT_WIDTH(12)
   ) u_TVR_Demod(
    	.RST(0),
    	.clk_out(clk_aq),
    	.I_OUT(I_out),
    	.Q_OUT(Q_out),
    	.modulo(modulo),
    	.FM_Demodule_OUT(demod_out)
	);

	wire [31:0] THR_GATE;
	wire		FM_EXIST;
	assign THR_GATE = 32'd0;
	/*
	RSSI u_RSSI(
        .CLK(clk_aq),
        .RSTn(RSTn),
        .modulo(modulo),
        .AVG_data(AVG_data),
		.THR_GATE(THR_GATE),
        .exist_flag(FM_EXIST)
    );*/

    wire signed [20:0] Audio_wave_1;//synthesis keep

    TVR_Audio_Handle u_audio_handle
    (
        .clk_in(clk_aq),
        .RST(0),
        .data_in(demod_out),
        .Audio_wave_L(Audio_wave_1)
    );
	

  TVR_pwm_test DAC_PWM_CH2(
    .clk_in(clk_pll),
    .RST(RSTn),
    .pwm_en(1'b1),
    .data_in(Audio_wave_1[18:9]),
    .PWM_OUT(pwm_out)
);

	parameter iq_clk_period = 2000;		// 设置IQ时钟周期2000ns
	parameter iq_clk_half_period = iq_clk_period/2;
	parameter data_num = 30000;						// 仿真数据长度
	parameter time_sim = data_num * iq_clk_period/2;	// 仿真时间

	// PWM 模块时钟
	parameter pll_200mhz_period = 4;	//设置500MHZ时钟
	parameter pwm_clk_half_period = pll_200mhz_period/2;

	initial begin
		clk_aq =1;
		clk_pll =1;
		RSTn = 0;
		#200 RSTn =1;
		// 设置仿真时间
		#time_sim $finish;
		// 设置输入信号初值
		I_t = 12'd0;
		Q_t = 12'd0;

	end

	// 产生时钟信号
	always #iq_clk_half_period clk_aq =~clk_aq;
	always #pwm_clk_half_period clk_pll =~clk_pll;

	//从外部TXT文件读取数据作为测试激励
	integer Pattern;
	reg [11:0] stimulusI[1:data_num];
	reg [11:0] stimulusQ[1:data_num];
	initial begin
		$readmemb("Im.txt",stimulusI);
		$readmemb("Qm.txt",stimulusQ);
		Pattern=0;
		repeat(data_num)
			begin
				Pattern = Pattern +1;
				I_t = {stimulusI[Pattern]};
				Q_t = {stimulusQ[Pattern]};
				#iq_clk_period;
			end
	end



endmodule