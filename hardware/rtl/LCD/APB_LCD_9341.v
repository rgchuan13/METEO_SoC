// ----------------------------------------------------------------------------
//  Version and control information:
//  File Revision       : 1.0.0
//  File Date           : 2022-05-13
//  Author              : RG
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

//  Abstract : Meteorolite FPGA APB LCD9341 接口模块
//  
// ----------------------------------------------------------------------------
// ---------------------------------------------
// Programmer's model
// 0x00 RW LCD_CS_reg
// 0x04 RW LCD_RS_reg
// 0x08 RW LCD_WR_reg
// 0x0C RW LCD_RD_reg
// 0x10 RW LCD_RST_reg
// 0x14 RW LCD_BL_CTR_reg
// 0x18 RW LCD_DATA_reg
module APB_LCD_9341 (
    input  wire             PCLK,    // PCLK for timer operation
    input  wire             PCLKG,   // Gated clock
    input  wire             PRESETn, // Reset

    input  wire             PSEL,
    input  wire     [11:0]  PADDR,
    input  wire             PENABLE,
    input  wire             PWRITE,
    input  wire     [31:0]  PWDATA,

    output wire     [31:0]  PRDATA,
    output wire             PREADY,
    output wire             PSLVERR,

    output  wire                        LCD_CS,
    output  wire                        LCD_RS,
    output  wire                        LCD_WR,
    output  wire                        LCD_RD,
    output  wire                        LCD_RST,
    output  wire    [15:0]              LCD_DATA,
    output  wire                        LCD_BL_CTR
);

    assign PSLVERR = 1'b0;
    assign PREADY = 1'b1;


    // 地址周期采样寄存器
	reg 	   rPSEL;
	reg [11:0] rPADDR;
	reg		   rPWRITE;
    reg [31:0] rPWDATA;
	//地址周期采样
	always @(posedge PCLK or negedge PRESETn) begin
		if(!PRESETn)
			begin
				rPSEL	<= 1'b0;
				rPADDR	<= 32'h0;
				rPWRITE	<= 1'b0;
                rPWDATA <= 32'b0;
			end
		else
		begin
					rPSEL	<= PSEL;
					rPADDR	<= PADDR;
					rPWRITE	<= PWRITE;
                    rPWDATA <= PWDATA;
		end
	end


    wire read_en;
    assign read_en=rPSEL&(~rPWRITE);

    wire write_en;
    assign write_en=rPSEL&(rPWRITE);


    wire        LCD_CS_en;
    wire        LCD_RS_en;
    wire        LCD_WR_en;
    wire        LCD_RD_en;
    wire        LCD_RST_en;
    wire        LCD_BL_CTR_en;
    wire        LCD_DATA_en;

    assign LCD_CS_en        = (rPADDR[11:2] == 10'h0) & write_en;
    assign LCD_RS_en        = (rPADDR[11:2] == 10'h1) & write_en;
    assign LCD_WR_en        = (rPADDR[11:2] == 10'h2) & write_en;
    assign LCD_RD_en        = (rPADDR[11:2] == 10'h3) & write_en;
    assign LCD_RST_en       = (rPADDR[11:2] == 10'h4) & write_en;
    assign LCD_BL_CTR_en    = (rPADDR[11:2] == 10'h5) & write_en;
    assign LCD_DATA_en      = (rPADDR[11:2] == 10'h6) & write_en;

    reg              LCD_CS_reg;
    reg              LCD_RS_reg;
    reg              LCD_WR_reg;
    reg              LCD_RD_reg;
    reg              LCD_RST_reg;
    reg              LCD_BL_CTR_reg;
    reg   [31:0]     LCD_DATA_reg;
    

    always@(posedge PCLK or negedge PRESETn) begin
        if(~PRESETn) begin
            LCD_CS_reg <= 1'b0;
            LCD_RS_reg <= 1'b0;
            LCD_WR_reg <= 1'b0;
            LCD_RD_reg <= 1'b0;
            LCD_RST_reg <= 1'b0;
            LCD_BL_CTR_reg <= 32'b0;
        end 
        else begin
            if (LCD_CS_en) begin
                LCD_CS_reg <= rPWDATA[0];
            end
            if (LCD_RS_en) begin
                LCD_RS_reg <= rPWDATA[0];
            end
            if (LCD_WR_en) begin
                LCD_WR_reg <= rPWDATA[0];
            end
            if (LCD_RD_en) begin
                LCD_RD_reg <= rPWDATA[0];
            end
            if (LCD_RST_en) begin
                LCD_RST_reg <= rPWDATA[0];
            end
            if (LCD_BL_CTR_en) begin
                LCD_BL_CTR_reg <= rPWDATA[0];
            end
            //-----------------------------------------------
            //              DATA
            //-----------------------------------------------
            if (LCD_DATA_en) begin
                LCD_DATA_reg <= rPWDATA;
            end

        end
    end

//-------------------------------------------------------------------       
//                  HRDATA DECODER
//-------------------------------------------------------------------

assign PRDATA =  (      rPADDR[11:2] == 10'h0   ) ?  LCD_CS_reg           :   (         
                    (   rPADDR[11:2] == 10'h1   ) ?  LCD_RS_reg        :   (
                    (   rPADDR[11:2] == 10'h2   ) ?  LCD_WR_reg        :   (
                    (   rPADDR[11:2] == 10'h3   ) ?  LCD_RD_reg         :   (
                    (   rPADDR[11:2] == 10'h4   ) ?  LCD_RST_reg        :   (
                    (   rPADDR[11:2] == 10'h5   ) ?  LCD_BL_CTR_reg     :   (
                    (   rPADDR[11:2] == 10'h6   ) ?  LCD_DATA_reg       :   32'b0))))));

assign LCD_CS       = LCD_CS_reg;
assign LCD_RS       = LCD_RS_reg;
assign LCD_WR       = LCD_WR_reg;
assign LCD_RD       = LCD_RD_reg;
assign LCD_RST      = LCD_RST_reg;
assign LCD_BL_CTR   = LCD_BL_CTR_reg;
assign LCD_DATA     = LCD_DATA_reg[15:0];


endmodule //APB_LCD_9341