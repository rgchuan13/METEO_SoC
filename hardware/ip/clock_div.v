module clock_div(
    input clk,
    input rst,
    output reg clk_out
);

parameter N = 9'd500 , WIDTH = 9;
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
