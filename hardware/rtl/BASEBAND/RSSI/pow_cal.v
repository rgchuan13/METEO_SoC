`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/17 13:22:24
// Design Name: 
// Module Name: Pow_cal
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Pow_cal#(
    parameter ADC_IQ_WIDTH = 12
)(
    input                           i_clk      ,
    input                           i_syn_10ms ,
    input  [ADC_IQ_WIDTH-1:0]       i_di       ,
    input  [ADC_IQ_WIDTH-1:0]       i_dq       ,
    output reg                      o_syn_flag ,
    output wire [25:0]               o_pow_sum//synthesis keep
);

    parameter ACC_WIDTH = 37;

reg                             s_dsp_sel     ;//synthesis keep
reg  [ADC_IQ_WIDTH-1:0]         s_di_r0       ;//synthesis keep
reg  [ADC_IQ_WIDTH-1:0]         s_dq_r0       ;//synthesis keep
reg  [11:0]                     s_syn_10ms = 0;//synthesis keep
wire [ACC_WIDTH-1:0]            s_pouti       ;//synthesis keep
wire [ACC_WIDTH-1:0]            s_poutq       ;//synthesis keep
reg  [ACC_WIDTH-1:0]            sum_i,sum_q   ;//synthesis keep
reg                             s_ce    = 0   ;//synthesis keep
wire [ACC_WIDTH:0]              s_adder_p     ; //synthesis keep
reg  [ACC_WIDTH:0]              s_pow_sum     ;//synthesis keep
wire [47:0]                     s_pout        ;//synthesis keep
reg  [25:0]                      pow_result    ;

always @(posedge i_clk)
begin
    s_di_r0 <= i_di;
    s_dq_r0 <= i_dq;
end

always @(posedge i_clk)
begin
    if(i_syn_10ms)
        s_dsp_sel <= 1'b0; //the first num per 10ms
    else
        s_dsp_sel <= 1'b1; //acc
end

genvar i;
generate
begin
    for(i = 0;i < 12;i = i + 1)
    begin
        always @(posedge i_clk)
        begin
            if(i == 0)
            begin
                s_syn_10ms[0] <= i_syn_10ms;
            end
            else
            begin
                s_syn_10ms[i] <= s_syn_10ms[i-1];
            end
        end
    end
end
endgenerate

//**dsp mode : 0 -> A*B+C
//**         : 1 -> A*B+P
//sum(i^2)_10ms
 pow_cal_dsp #(
    .INPUT_WIDTH(ADC_IQ_WIDTH),
    .OUTPUT_WIDTH(ACC_WIDTH)
 )ins_pow_cal_i(
    .CLK (i_clk                          ), //: IN STD_LOGIC;
    .SEL (s_dsp_sel                      ), //: IN STD_LOGIC_VECTOR(0 DOWNTO 0);endmodule
    .A   (s_di_r0                        ), //: IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    .B   (s_di_r0                        ), //: IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    .C   ('d0                            ), //: IN STD_LOGIC_VECTOR(47 DOWNTO 0);
    .P   (s_pouti                        )  //: OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
  );

//sum(q^2)_10ms
 pow_cal_dsp  #(
    .INPUT_WIDTH(ADC_IQ_WIDTH),
    .OUTPUT_WIDTH(ACC_WIDTH)
 )ins_pow_cal_q(
    .CLK (i_clk                          ), //: IN STD_LOGIC;
    .SEL (s_dsp_sel                      ), //: IN STD_LOGIC_VECTOR(0 DOWNTO 0);endmodule
    .A   (s_dq_r0                        ), //: IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    .B   (s_dq_r0                        ), //: IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    .C   ('d0                            ), //: IN STD_LOGIC_VECTOR(47 DOWNTO 0);
    .P   (s_poutq                        )  //: OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
  );
//sum(i^2)_10ms + sum(q^2)_10ms 
i_add_q #(
    .INPUT_WIDTH(ACC_WIDTH)
)ins_i_add_q(
     .A   (sum_i          ), //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
     .B   (sum_q          ), //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
     .CLK (i_clk          ), //: IN STD_LOGIC;
     .CE  (s_ce           ), //: IN STD_LOGIC; 
     .S   (s_adder_p      ) //: OUT STD_LOGIC_VECTOR(32 DOWNTO 0)
   ); 

 always @(posedge i_clk)
 begin
     o_syn_flag <= 1'b0      ;
     
     if(s_syn_10ms[3]) //the last number of acc mode(A*B+P)
     begin
         sum_i <= s_pouti;
         sum_q <= s_poutq;
         s_ce  <= 1'b1           ; //adder on 
     end
     
     if(s_syn_10ms[6])
     begin
         s_ce       <= 1'b0      ; //adder off,low pow mode
         s_pow_sum  <= s_adder_p ;
         //o_syn_flag <= 1'b1      ; //last 1 clk
     end
     
     if(s_syn_10ms[11])
     begin
         pow_result  <= s_pout[47:22];
         o_syn_flag <= 1'b1        ; //last 1 clk
     end
 end  
 
    assign o_pow_sum = pow_result;

 //x/5000 = x*420/2^23
 pow_cal_dsp #(
    .INPUT_WIDTH(ACC_WIDTH+1),
    .OUTPUT_WIDTH(48)
 )ins_pow_cal(
    .CLK (i_clk                          ), //: IN STD_LOGIC;
    .SEL (1'b0                           ), //: IN STD_LOGIC_VECTOR(0 DOWNTO 0);endmodule
    .A   (s_pow_sum              ), //: IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    .B   (38'd420                        ), //: IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    .C   ('d0                            ), //: IN STD_LOGIC_VECTOR(47 DOWNTO 0);
    .P   (s_pout                         )  //: OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
  );

    // wire [15:0] pow_avg;//synthesis keep
    // wire [15:0] pow_temp;//synthesis keep
    // assign pow_temp = s_pout[ACC_WIDTH:22];

// moving_avg #(
//     .DATA_WIDTH(16),
//     .WINDOW_SHIFT(4),
//     .SIGNED(0)
// )u_moving_avg(
//     .clock(i_clk),
//     .enable(1'b1),
//     .reset(rstn),
//     .data_in(pow_temp),
//     .input_strobe(1'b1),
//     .data_out(pow_avg),
//     .output_strobe()
// );
    

  
 endmodule