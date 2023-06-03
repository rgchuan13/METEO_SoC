module avg_cal #(
    parameter INPUT_WIDTH = 12,
    parameter OUTPUT_WIDTH = 37
)(          
    input wire                              CLK,
    input wire                              RSTn,
    input wire signed   [INPUT_WIDTH-1:0]   A,
    input wire signed   [INPUT_WIDTH-1:0]   B,
    input wire signed   [INPUT_WIDTH-1:0]   C,
    output wire signed  [OUTPUT_WIDTH-1:0]  P
);

    reg signed [OUTPUT_WIDTH-1:0]  s_result = 'd0;
    reg signed [OUTPUT_WIDTH-1:0]  s_result_t = 'd0;

    reg signed [23:0]  s_mult = 'd0;   

    always @(posedge CLK ) begin
        always @(posedge CLK or negedge RSTn) begin
            if (~RSTn) begin
                s_result = 'd0;
                s_result_t = 'd0;
            end
            else begin
                
            end
        end
    end

    assign P = s_result;

endmodule