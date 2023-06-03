module onehot2binary(clk,RSTn,onehot,binary);
  
    input clk;
    input RSTn;
    input [15:0] onehot;
    output reg [4:0] binary;


    always@(posedge clk or negedge RSTn) //如果没有按键按下 onehot不动,则输出数据保持
    if(~RSTn)
        binary <= 5'b10000;
    else
        case(onehot) 
            16'h0000 : binary <= 5'b00000;
            16'h0001 : binary <= 5'b00001;
            16'h0002 : binary <= 5'b00010;
            16'h0004 : binary <= 5'b00011;
            16'h0008 : binary <= 5'b00100;
            16'h0010 : binary <= 5'b00101;
            16'h0020 : binary <= 5'b00110;
            16'h0040 : binary <= 5'b00111;
            16'h0080 : binary <= 5'b01000;
            16'h0100 : binary <= 5'b01001;
            16'h0200 : binary <= 5'b01010;
            16'h0400 : binary <= 5'b01011;
            16'h0800 : binary <= 5'b01100;
            16'h1000 : binary <= 5'b01101;
            16'h2000 : binary <= 5'b01110;
            16'h4000 : binary <= 5'b01111;
            16'h8000 : binary <= 5'b10000;
        endcase
endmodule