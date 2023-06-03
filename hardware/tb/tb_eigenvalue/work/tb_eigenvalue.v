`timescale 1ns/1ns

`default_nettype none

module tb_eigenvalue;
reg clk;
reg rst_n;
reg [11:0] modulo;
wire [31:0] RSSI;

 
eigenvalue u_eigenvalue(
    .modulo(modulo),
    .RSTn (rst_n),
    .CLK (clk),
    .RSSI(RSSI)
);

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;



initial begin
    #1 rst_n<=1'bx;clk<=1'bx;
    #(CLK_PERIOD*3) rst_n<=0;
    #(CLK_PERIOD*3) rst_n<=1;clk<=1;
    #(CLK_PERIOD*3) modulo <= 12'd10;

end

endmodule
`default_nettype wire