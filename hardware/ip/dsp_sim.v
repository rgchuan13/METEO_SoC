// Verilog netlist created by TD v5.0.43066
// Thu Mar 31 19:10:55 2022

`timescale 1ns / 1ps
module dsp  // dsp.v(14)
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

  input [7:0] a;  // dsp.v(18)
  input [7:0] b;  // dsp.v(19)
  input cea;  // dsp.v(20)
  input ceb;  // dsp.v(21)
  input cepd;  // dsp.v(22)
  input clk;  // dsp.v(23)
  input rstan;  // dsp.v(24)
  input rstbn;  // dsp.v(25)
  input rstpdn;  // dsp.v(26)
  output [15:0] p;  // dsp.v(16)


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
    .SRMODE("ASYNC"))
    inst_ (
    .a({open_n47,open_n48,open_n49,open_n50,open_n51,open_n52,open_n53,open_n54,open_n55,1'b0,a}),
    .b({open_n74,open_n75,open_n76,open_n77,open_n78,open_n79,open_n80,open_n81,open_n82,1'b0,b}),
    .cea(cea),
    .ceb(ceb),
    .cepd(cepd),
    .clk(clk),
    .rstan(rstan),
    .rstbn(rstbn),
    .rstpdn(rstpdn),
    .p({open_n141,open_n142,open_n143,open_n144,open_n145,open_n146,open_n147,open_n148,open_n149,open_n150,open_n151,open_n152,open_n153,open_n154,open_n155,open_n156,open_n157,open_n158,open_n159,open_n160,p}));

endmodule 

