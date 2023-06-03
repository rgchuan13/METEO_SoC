// ----------------------------------------------------------------------------
//  Version and control information:
//  File Revision       : 2.1.0
//  File Date           : 2022-08-10
//                       
//  Author              : RG
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

//  Abstract : Meteorolite FPGA 基带信号处理模块
//             
//
// ----------------------------------------------------------------------------
module baseband_top (
    input  wire			    oscclk,
    input  wire			    rstn,
    output wire			    pwm_out,//synthesis keep
    output wire 			clk_1k,		// 用于产生定位时所需的1kHZ时钟信号
    output wire             clk_msi,
    output wire             clk_qn,
    // AHB BASEBAND CONTROL 接口信号
    input wire 			    pwm_enable,		// PWM使能
    input wire  [30:0]      audio_thr,      // audio阈值
    output wire [31:0]	    rssi			// FM RSSI 信号特征值

);
    

    
    parameter ADC_IQ_WIDTH = 12;
    parameter DEMOD_WIDTH = 12;
    parameter AUDIO_WIDTH = 21;
    parameter PWM_DATA_IN_WIDTH = 10;

    // ------------------------------------------------------------------------
    
    wire    clk_100mhz;
    wire    clk_24mhz;
    wire    clk_16mhz;
    wire    clk_10mhz;
    wire    clk_1khz;
    wire    clk_100hz;//synthesis keep

    wire signed [ADC_IQ_WIDTH-1:0]   i_data;//synthesis keep
    wire signed [ADC_IQ_WIDTH-1:0]   q_data;//synthesis keep
    wire                             adc_iq_valued;//synthesis keep

    wire signed [DEMOD_WIDTH-1:0]   fm_demod;//synthesis keep
    wire signed [AUDIO_WIDTH-1:0]   audio_wave;//synthesis keep
    wire        [31:0]              audio_power;

    wire [25:0] pow_sum;//synthesis keep

    pll_baseband u_pll_baseband(
		.refclk(oscclk),						// 50MHz 晶振时钟输入
		.reset(~rstn),							// 
		.extlock(),								// pll_top 锁定输出
		.clk0_out(clk_100mhz),                            // 100mhz
        .clk1_out(clk_24mhz),                            // 24mhz
        .clk2_out(clk_16mhz),                            // 16mhz
		.clk3_out(clk_10mhz)                             // 10mhz
	);

    assign clk_msi = clk_24mhz;
    assign clk_qn = clk_24mhz;

    adc_acq #(
        .ADC_IQ_WIDTH(ADC_IQ_WIDTH),
        .FILTER_WIDTH(21)
    ) u_adc_acq(
        .clk_adc(clk_16mhz),        // adc时钟16mhz
        .rstn(rstn),
        .iq_valued(adc_iq_valued),
        .o_i_data(i_data),
        .o_q_data(q_data)
    );

    Pow_cal #(
        .ADC_IQ_WIDTH(ADC_IQ_WIDTH)
    )u_Pow_cal(
        .i_clk(adc_iq_valued),
        .i_syn_10ms(clk_100hz),
        .i_di(i_data),
        .i_dq(q_data),
        .o_syn_flag(),
        .o_pow_sum(pow_sum)
    );

    demodula #(
        .INPUT_WIDTH(ADC_IQ_WIDTH),
        .OUTPUT_WIDTH(DEMOD_WIDTH)
   ) u_demodula(
    	.RST(~rstn),
    	.clk_out(adc_iq_valued),
    	.I_OUT(i_data),
    	.Q_OUT(q_data),
    	.modulo(),
    	.FM_Demodule_OUT(fm_demod)
	);

    audio #(
        .DEMOD_WIDTH(DEMOD_WIDTH),
        .AUDIO_WIDTH(AUDIO_WIDTH)
    ) u_audio(
        .clk_in(adc_iq_valued),
        .rstn(rstn),
        .data_in(fm_demod),
        .audio_thr(audio_thr),
        .power(audio_power),
        .audio_wave(audio_wave)
    );

    pwm #(
        .DATA_IN_WIDTH(10)
    ) u_pwm(
    	.clk_in(clk_100mhz),
    	.rstn(rstn),
    	.pwm_en(pwm_enable),
    	.data_in(audio_wave[PWM_DATA_IN_WIDTH+7:8]),
    	.PWM_OUT(pwm_out)
	);


    // 用于产生定位的1khz时钟信号
    clock_div_par#(
        .N(9'd500), 
        .WIDTH(9)
    ) u_clock_1k(
        .clk(adc_iq_valued),
        .rst(rstn),
        .clk_out(clk_1khz)
    );

    assign clk_1k = clk_1khz;

    // 用于产生Pow_cal 模块的100HZ时钟信号
    clock_div_par#(
        .N(9'd10), 
        .WIDTH(4)
    ) u_clock_100(
        .clk(clk_1khz),
        .rst(rstn),
        .clk_out(clk_100hz)
    );

    // unused
    assign rssi = {6'b0,pow_sum[25:0]};
    //assign rssi = audio_power;

endmodule