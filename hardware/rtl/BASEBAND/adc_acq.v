// ----------------------------------------------------------------------------
//  Version and control information:
//  File Revision       : 2.1.0
//  File Date           : 2022-08-12
//  Author              : RG
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

//  Abstract : Meteorolite FPGA 基带信号处理模块 信号采集部分
//             采集MSI001产生的IQ信号并同步输出IQ信号
//
// ----------------------------------------------------------------------------
module adc_acq #(
    parameter   ADC_IQ_WIDTH = 12,
	parameter	FILTER_WIDTH = 21
) (
    input wire                              clk_adc,        // adc时钟16mhz
    input wire                              rstn,

    output wire                             iq_valued,
    output wire signed [ADC_IQ_WIDTH-1:0]   o_i_data,
    output wire signed [ADC_IQ_WIDTH-1:0]   o_q_data

);
    

    wire			eoc;
	wire			clk_1M;
	wire			clk_500k;
	wire	[11:0]	adc_data;
	reg				IQ_CLK;
	reg 	[11:0]	I_data;
	reg 	[11:0]	Q_data;
	reg 	[11:0]  I_t;
 	reg 	[11:0]  Q_t;
	reg		[11:0]	data_t;
	reg		[2:0]	s;			//synthesis keep
	reg				error;
	reg		 	 	ch;


    always @(posedge clk_adc or negedge rstn) begin
    	if (~rstn) begin
        	ch<=1'b0;
    	end else begin
        	if (eoc) begin
            	ch<=ch+1'b1;
        	end
    	end
	end

	always @(*) begin
    	case (ch)
    	1'b0:s<=3'd6;
    	1'b1:s<=3'd4;
    	endcase
	end


	// MSI_I    :   ADC_CH_6
    // MSI_Q    :   ADC_CH_4

	ADC_2CH u_ADC_2CH(
        .clk(clk_adc),				    // ADC工作时钟
        .pd(1'b0),				        // ADC低功耗掉电模式
        .s(s),							// ADC通道选择信号输入
        .soc(1'b1),						// ADC采样使能信号输入，高有效
        .eoc(eoc),						// ADC转换完成输出，高有效
        .dout(adc_data)					// 对应通道的ADC转换结果
    );


    always @(posedge clk_adc or negedge rstn) begin
		if(~rstn) begin
			I_data <= 11'd0;
			Q_data <= 11'd0;
			data_t <= 11'd0;
			IQ_CLK <= 1'b0;
			error  <= 1'b0;
			end
		else if(eoc)
			begin
				case (ch)
				1'd0:begin 
						I_data <= adc_data;			
                        IQ_CLK <= 1'b0;
				end
				1'd1:begin
						Q_t <= adc_data;
                        I_t <= I_data;
						IQ_CLK <= 1'b1;
				end
					default: IQ_CLK <= 1'b0;
				endcase
			end
		else 
			IQ_CLK <= 1'b0;
	end


	wire signed [11:0] i_signed;
    wire signed [11:0] q_signed;
	wire signed [FILTER_WIDTH-1:0]	i_filtered;
	wire signed [FILTER_WIDTH-1:0]	q_filtered;

    
    assign i_signed = {~I_t[11],I_t[10:0]};
	assign q_signed = {~Q_t[11],Q_t[10:0]};

	fir_50_3 Fiter_LPF_I(
    	.clk(IQ_CLK),
    	.clk_enable(1'd1),
    	.reset(~rstn),
    	.filter_in(i_signed),
    	.filter_out(i_filtered)
	);
	fir_50_3 Fiter_LPF_Q(
    	.clk(IQ_CLK),
    	.clk_enable(1'd1),
    	.reset(~rstn),
    	.filter_in(q_signed),
    	.filter_out(q_filtered)
	);

	assign o_i_data = i_filtered[ADC_IQ_WIDTH+7:8];
	assign o_q_data = q_filtered[ADC_IQ_WIDTH+7:8];
	assign iq_valued = IQ_CLK;


endmodule