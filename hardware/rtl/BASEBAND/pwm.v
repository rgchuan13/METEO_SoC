// ----------------------------------------------------------------------------
//  Version and control information:
//  File Revision       : 1.0.0
//  File Date           : 2022-03-19
//  Author              : RG
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

//  Abstract : Meteorolite FPGA PWM 输出模块
//
// ----------------------------------------------------------------------------
module pwm#(
    parameter DATA_IN_WIDTH = 10
)(
    input wire clk_in,
    input wire rstn,
    input wire pwm_en,
    input wire signed [DATA_IN_WIDTH-1:0] data_in,
    output wire PWM_OUT
);


reg [DATA_IN_WIDTH-1:0] cnt;
always @(posedge clk_in or negedge rstn) begin
  if(~rstn)
    cnt<= 0;
  else
   cnt <= cnt + 1'b1;  // free-running counter
end

reg [DATA_IN_WIDTH-1:0] duty_r;
always @(posedge clk_in or negedge rstn) begin
	if (~rstn) begin
		duty_r <= 'd0;
	end
	else begin
		duty_r <= $signed(data_in) + 10'd512;
	end
end


assign DAC_PWM = (cnt <= duty_r) ? 1'b1 : 1'b0;
assign PWM_OUT = (pwm_en) ? DAC_PWM : 1'b0;

endmodule