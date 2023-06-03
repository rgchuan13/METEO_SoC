module clock_div_par#(
    parameter N = 9'd500, 
    parameter WIDTH = 9
)
(
    input clk,
    input rst,
    output reg clk_out
);


reg [WIDTH:0] counter;

always @(posedge clk or negedge rst) begin
	if (~rst) begin
		counter <= 0;
		clk_out <= 0;
	end
	else if (counter == N-1) begin
		clk_out <= ~clk_out;
		counter <= 0;
	end
	else
		counter <= counter + 1;
end

endmodule
