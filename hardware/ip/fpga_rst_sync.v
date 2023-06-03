//-----------------------------------------------------------------------------
// Date: 2022-02-15
// Abstract : Simple reset synchronizer
//-----------------------------------------------------------------------------

// Reset synchroniser
module fpga_rst_sync  (
  input  wire  clk,
  input  wire  rst_n_in,                    //低电平有效
  input  wire  rst_request,
  output wire  rst_n_out
  );

  reg   [1:0]  reg_rst_sync;

  always @(posedge clk or negedge rst_n_in)
  begin
  if (~rst_n_in)
    reg_rst_sync <= 2'b00;
  else
    if (rst_request)
      reg_rst_sync <= 2'b00;
    else
      reg_rst_sync <= {reg_rst_sync[0], 1'b1};
  end

  assign     rst_n_out = reg_rst_sync[1];

endmodule
