module dff (
  input wire [15:0] DATA_IN,
  input wire CLK,
  input wire RSTn,
  output wire [15:0] DATA_OUT 
);
  

reg [15:0] data_out;

always @(posedge CLK) begin
  if (!RSTn) begin
    data_out <= 16'd0;
  end
  else 
    data_out <= DATA_IN;
  
end

assign DATA_OUT =data_out;



endmodule