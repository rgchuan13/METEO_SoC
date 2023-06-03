`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: HaveFunFPGA
// 
// Create Date:    23:56:56 05/26/2018 
// Design Name: 
// Module Name:    filter_mid 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: �Ƚ��������������ݣ��õ��м�ֵ����ֵ�����
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module filter_mid(
    input             clk ,
	input     [23:0]  din ,
	output reg[23:0]  dout
    );
    
	reg       [23:0]  din_buf[2:0];
	wire      [2 :0]  comp;
	//��λ�ȽϽ���洢
	assign            comp[2] = (din_buf[0] >= din_buf[2]) ? 1'b1 : 1'b0;
	assign            comp[1] = (din_buf[2] >= din_buf[1]) ? 1'b1 : 1'b0;
	assign            comp[0] = (din_buf[1] >= din_buf[0]) ? 1'b1 : 1'b0;
	   
	always@(posedge clk)
	begin
	   din_buf[0] <= din;
	   din_buf[1] <= din_buf[0];
	   din_buf[2] <= din_buf[1];
	end
	
	always@(posedge clk)
	begin
	   case(comp)
	   3'b011 :dout <= din_buf[1];//2>1>0
	   3'b101 :dout <= din_buf[0];//1>0>2
	   3'b110 :dout <= din_buf[2];//0>2>1
	   3'b100 :dout <= din_buf[1];//0>1>2 
	   3'b010 :dout <= din_buf[0];//2>0>1
	   3'b001 :dout <= din_buf[2];//1>2>0
	   default:dout <= din_buf[1];
	   endcase
	end
endmodule
