// Verilog netlist created by TD v5.0.43066
// Wed Apr  6 18:01:10 2022

`timescale 1ns / 1ps
module mult  // mult.v(14)
  (
  a,
  b,
  p
  );

  input [7:0] a;  // mult.v(18)
  input [7:0] b;  // mult.v(19)
  output [15:0] p;  // mult.v(16)


  EG_PHY_CONFIG #(
    .DONE_PERSISTN("ENABLE"),
    .INIT_PERSISTN("ENABLE"),
    .JTAG_PERSISTN("DISABLE"),
    .PROGRAMN_PERSISTN("DISABLE"))
    config_inst ();
  EG_PHY_MULT18 #(
    .INPUTREGA("DISABLE"),
    .INPUTREGB("DISABLE"),
    .MODE("MULT9X9C"),
    .OUTPUTREG("DISABLE"),
    .SIGNEDAMUX("0"),
    .SIGNEDBMUX("0"))
    inst_ (
    .a({open_n47,open_n48,open_n49,open_n50,open_n51,open_n52,open_n53,open_n54,open_n55,1'b0,a}),
    .b({open_n74,open_n75,open_n76,open_n77,open_n78,open_n79,open_n80,open_n81,open_n82,1'b0,b}),
    .p({open_n148,open_n149,open_n150,open_n151,open_n152,open_n153,open_n154,open_n155,open_n156,open_n157,open_n158,open_n159,open_n160,open_n161,open_n162,open_n163,open_n164,open_n165,open_n166,open_n167,p}));

endmodule 

