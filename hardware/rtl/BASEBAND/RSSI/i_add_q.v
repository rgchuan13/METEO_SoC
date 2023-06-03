module i_add_q #(
    parameter INPUT_WIDTH = 37
)(
    input wire signed  [INPUT_WIDTH-1:0]   A,
    input wire signed  [INPUT_WIDTH-1:0]   B,
    input wire                             CLK,
    input wire                             CE,//高有效
    output wire signed [INPUT_WIDTH:0]     S
);

    reg signed [INPUT_WIDTH:0] s_sum = 'd0;

    always @(posedge CLK ) begin
        s_sum = A + B;
    end
    
    assign S = s_sum;

endmodule