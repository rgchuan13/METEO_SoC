// Verilog netlist created by TD v5.0.43066
// Sat Mar 12 16:06:20 2022

`timescale 1ns / 1ps
module dsp1  // dsp1.v(14)
  (
  a,
  b,
  cea,
  ceb,
  cepd,
  clk,
  rstan,
  rstbn,
  rstpdn,
  p
  );

  input [8:0] a;  // dsp1.v(18)
  input [8:0] b;  // dsp1.v(19)
  input cea;  // dsp1.v(20)
  input ceb;  // dsp1.v(21)
  input cepd;  // dsp1.v(22)
  input clk;  // dsp1.v(23)
  input rstan;  // dsp1.v(24)
  input rstbn;  // dsp1.v(25)
  input rstpdn;  // dsp1.v(26)
  output [17:0] p;  // dsp1.v(16)


  EG_PHY_CONFIG #(
    .DONE_PERSISTN("ENABLE"),
    .INIT_PERSISTN("ENABLE"),
    .JTAG_PERSISTN("DISABLE"),
    .PROGRAMN_PERSISTN("DISABLE"))
    config_inst ();
  EG_PHY_MULT18 #(
    .CEAMUX("SIG"),
    .CEBMUX("SIG"),
    .CEPDMUX("SIG"),
    .CLKMUX("SIG"),
    .INPUTREGA("ENABLE"),
    .INPUTREGB("ENABLE"),
    .MODE("MULT9X9C"),
    .OUTPUTREG("ENABLE"),
    .RSTANMUX("SIG"),
    .RSTBNMUX("SIG"),
    .RSTPDNMUX("SIG"),
    .SIGNEDAMUX("0"),
    .SIGNEDBMUX("0"),
    .SRMODE("SYNC"))
    inst_ (
    .a({open_n47,open_n48,open_n49,open_n50,open_n51,open_n52,open_n53,open_n54,open_n55,a}),
    .b({open_n74,open_n75,open_n76,open_n77,open_n78,open_n79,open_n80,open_n81,open_n82,b}),
    .cea(cea),
    .ceb(ceb),
    .cepd(cepd),
    .clk(clk),
    .rstan(rstan),
    .rstbn(rstbn),
    .rstpdn(rstpdn),
    .p({open_n141,open_n142,open_n143,open_n144,open_n145,open_n146,open_n147,open_n148,open_n149,open_n150,open_n151,open_n152,open_n153,open_n154,open_n155,open_n156,open_n157,open_n158,p}));

endmodule 

