module audio #(
    parameter DEMOD_WIDTH =12,
    parameter AUDIO_WIDTH = 21
) (
    input   wire                            clk_in,
    input   wire                            rstn,
    input   wire signed  [DEMOD_WIDTH-1:0]  data_in,
    input   wire        [30:0]              audio_thr,                
    output  wire        [31:0]              power,
    output  wire signed [AUDIO_WIDTH-1:0]   audio_wave
);

   
   reg [31:0]   x_power;//synthesis keep
   reg [31:0]   x_power1;//synthesis keep
   reg [5:0]    cnt;
   wire [23:0]  x_out;//synthesis keep
   wire [20:0]  data_strenth;//synthesis keep

   always @(posedge clk_in or negedge rstn) begin
        if(~rstn) begin
            x_power <= 'd0;
            x_power1 <= 'd0;
            cnt <= 'd0;
        end
        else begin
            cnt <= cnt + 1'b1;
            if(cnt == 'd0) begin
                x_power1 <= {{8{x_out[23]}},x_out};
                x_power <= x_power1;
            end
            else 
            //累加64次求信号的功率
            x_power1 <= x_power1 + {{8{x_out[23]}},x_out};
        end
   end

    

    assign audio_wave = (audio_thr[4]) ? (data_strenth )         : (
                            (audio_thr[3]) ? (data_strenth >>1)     : (
                            (audio_thr[2]) ? (data_strenth >>2)     : (
                            (audio_thr[1]) ? (data_strenth >>3)     : (
                            (audio_thr[0]) ? (data_strenth >>8)     :  (data_strenth)   
                            ))));


    assign power = x_power;

    assign data_strenth = {data_in,9'b0};


    pow_cal_dsp #(
    .INPUT_WIDTH(DEMOD_WIDTH),
    .OUTPUT_WIDTH(24)
    ) ins_audio_pow_cal(
    .CLK (clk_in                          ),
    .SEL (1'b0                           ),
    .A   (data_in                      ),
    .B   (data_in                        ),
    .C   ('d0                            ),
    .P   (x_out                         ) 
  );


endmodule