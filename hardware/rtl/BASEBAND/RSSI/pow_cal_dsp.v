module pow_cal_dsp #(
    parameter INPUT_WIDTH = 12,
    parameter OUTPUT_WIDTH = 37
)(          
    input wire                              CLK,
    input wire                              SEL,
    input wire signed   [INPUT_WIDTH-1:0]   A,
    input wire signed   [INPUT_WIDTH-1:0]   B,
    input wire signed   [INPUT_WIDTH-1:0]   C,
    output wire signed  [OUTPUT_WIDTH-1:0]     P
);

    reg signed [OUTPUT_WIDTH-1:0]  s_result = 'd0;
    reg signed [OUTPUT_WIDTH-1:0]  s_result_t = 'd0;

    reg signed [23:0]  s_mult = 'd0;   

    always @(posedge CLK ) begin
        s_mult = A * B;
        if(SEL) begin
            s_result = s_result_t + s_mult;
            s_result_t = s_result;
        end
        if(~SEL) begin
            s_result_t <= 'd0;
            s_result = s_mult + C;
        end
    end

    assign P = s_result;

endmodule