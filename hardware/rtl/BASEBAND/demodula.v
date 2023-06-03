module demodula #(
    parameter INPUT_WIDTH = 12,
    parameter OUTPUT_WIDTH = 12
) (
    input                               RST,
    input wire                          clk_out,
    input wire  [INPUT_WIDTH - 1 : 0]   I_OUT,
    input wire  [INPUT_WIDTH - 1 : 0]   Q_OUT,

    output wire [INPUT_WIDTH-1: 0]      modulo,
    output wire [OUTPUT_WIDTH-1:0]      FM_Demodule_OUT
);

    wire [OUTPUT_WIDTH-1:0] PM_Demodule_OUT;


    Cordic # (
        .XY_BITS(INPUT_WIDTH),               
        .PH_BITS(OUTPUT_WIDTH),      //1~32
        .ITERATIONS(16),             //1~32
        .CORDIC_STYLE("VECTOR")      //ROTATE  //VECTOR
    ) Demodulate_Gen_u (
        .clk_in(clk_out),
        .RST(RST),
        .x_i(I_OUT), 
        .y_i(Q_OUT),
        .phase_in(0),          
	    .valid_in(~RST),   

        .x_o(modulo),
        .y_o(),
        .phase_out(PM_Demodule_OUT)
    );

    reg [OUTPUT_WIDTH-1:0] PM_Demodule_OUT_r = 0; //synthesis keep
    always @(posedge clk_out) begin
        PM_Demodule_OUT_r <= PM_Demodule_OUT;
    end

    assign FM_Demodule_OUT = $signed(PM_Demodule_OUT) - $signed(PM_Demodule_OUT_r);

endmodule