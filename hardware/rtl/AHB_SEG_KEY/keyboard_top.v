// ----------------------------------------------------------------------------
//  Version and control information:
//  File Revision       : 1.0.0
//  File Date           : 2022-05-02
//  Author              : RG
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

//  Abstract : Meteorolite FPGA 按键模块
//             
//
// ----------------------------------------------------------------------------
module keyboard_top (
	input wire CLK_50M,
	input wire RSTn,
	input wire [3:0] COL,
	output wire [3:0] ROW,
	output wire [4:0] key_disp
);

	wire	[15:0] key;

	keyboard_scan u_keyboard_scan(
        .clk(CLK_50M),
        .RSTn(RSTn),
        .col(COL),
        .row(ROW),
        .key(key)
    );

	wire [15:0] key_deb;

    key_filter u_key_filter(
        .clk(CLK_50M),
        .rstn(RSTn),
        .key_in(key),
        .key_deb(key_deb)
    );


    onehot2binary u_key_disp(
        .clk(CLK_50M),
        .RSTn(RSTn),
        .onehot(key_deb),
        .binary(key_disp)
    );
  
endmodule