// ----------------------------------------------------------------------------
//  Version and control information:
//  File Revision       : 1.0.0
//  File Date           : 2022-03-30
//  Author              : ZJ
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

//  Abstract : Meteorolite FPGA 基带信号处理模块 FIR滤波器
//
// ----------------------------------------------------------------------------

`define SAFE_DESIGN

module fir
(
   input                rstn,
   input                clk, // Fs=20K
   input                en,
   input        [7:0]  	xin, //
   output               valid,
   output        [15:0] yout
);

   reg [3:0]            en_r ;
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         en_r[3:0]      <= 'b0 ;
      end
      else begin
         en_r[3:0]      <= {en_r[2:0], en} ;
      end
   end

   //(1) parallel fir means multipler working in parallel, so 16 regs needed
   reg        [7:0]    xin_reg[15:0];
   reg [3:0]            i, j ;

   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         for (i=0; i<15; i=i+1) begin
            xin_reg[i]  <= 8'b0;
         end
      end
      else if (en) begin
         for (j=0; j<15; j=j+1) begin
            xin_reg[j+1] <= xin_reg[j] ; // data shift every clock cycle
         end
         xin_reg[0] <= xin ;
      end
   end

   //Only 8 multipliers needed because of the symmetyr of FIR filter coefficient
   //(2)expanding bit-width of        data and adding them with the same coefficient
   reg        [8:0]    add_reg[7:0];
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         for (i=0; i<8; i=i+1) begin
            add_reg[i] <= 9'd0 ;
         end
      end
      else if (en_r[0]) begin
         for (i=0; i<8; i=i+1) begin
            add_reg[i] <= xin_reg[i] + xin_reg[15-i] ;
         end
      end
   end


   //(3) 8 multipliers
   wire        [7:0]   coe[7:0] ;
   assign coe[0]        = 12'd20 ;
   assign coe[1]        = 12'd34 ;
   assign coe[2]        = 12'd58 ;
   assign coe[3]        = 12'd85 ;
   assign coe[4]        = 12'd115 ;
   assign coe[5]        = 12'd141 ;
   assign coe[6]        = 12'd162 ;
   assign coe[7]        = 12'd173 ;
   wire        [16:0]   mout[7:0]; //coe bit-width 8bit;        data bit-width 9bit; 17bit total

`ifdef SAFE_DESIGN
   wire [7:0]          valid_mult ;
   genvar              k ;
	   mult_man #(9, 8)
           u_mult_paral
           (.clk        (clk),
            .rstn       (rstn),
            .data_rdy   (en_r[1]),
            .mult1      (add_reg[0]),
            .mult2      (coe[0]),
            .res_rdy    (valid_mult[0]),   //all data valid are the same
            .res        (mout[0])
            );
   generate
      for (k=1; k<8; k=k+1) begin
         mult_man #(9, 8)
         u_mult_paral
           (.clk        (clk),
            .rstn       (rstn),
            .data_rdy   (en_r[1]),
            .mult1      (add_reg[k]),
            .mult2      (coe[k]),
            .res_rdy    (valid_mult[k]),   //all data valid are the same
            .res        (mout[k])
            );
       end
   endgenerate
   wire valid_mult7     = valid_mult[7] ;
 

`endif

   //(4) accumulation(integrator), 8 25-bit data ------------> 1 29-bit data
   reg [3:0]            valid_mult_r ;
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         valid_mult_r[3:0]      <= 'b0 ;
      end
      else begin
         valid_mult_r[3:0]      <= {valid_mult_r[2:0], valid_mult7} ;
      end
   end

`ifdef SAFE_DESIGN

  //(4) accumulation(integrator), 8 25-bit data ------------> 1 28-bit data
   reg        [28:0]    sum1 ;
   reg        [28:0]    sum2 ;
   reg        [28:0]    yout_t ;

   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         sum1   <= 29'd0 ;
         sum2   <= 29'd0 ;
         yout_t <= 29'd0 ;
      end
      else if(valid_mult7) begin
         sum1   <= mout[0] + mout[1] + mout[2] + mout[3] ;
         sum2   <= mout[4] + mout[5] + mout[6] + mout[7] ;
         yout_t <= sum1 + sum2 ;
      end
   end

`else // !`ifdef SAFE_DESIGN
   reg signed [28:0]    sum ;
   reg signed [28:0]    yout_t ;
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         sum    <= 29'd0 ;
         yout_t <= 29'd0 ;
      end
      else if (valid_mult7) begin
         sum    <= mout[0] + mout[1] + mout[2] + mout[3] + mout[4] + mout[5] + mout[6] + mout[7];
         yout_t <= sum ;
      end
   end


`endif

   assign yout  = yout_t[20:5] ;
   assign valid = clk;


endmodule // fir_guide
