`timescale 1ns / 1ps

module top(
    input clk,
    input reset_n,
    output [9:0] control_sig,
    output [6:0] seg,
    output [5:0] ans
    );

    wire clk_div;
    wire [31:0] addr;
    wire [31:0] inst;

    Clk_div Clk_div_u0(
    .clk(clk),
    .reset_n(reset_n),
    .clk_div(clk_div)
    );

    PC PC_u0(
    .clk(clk_div),
    .reset_n(reset_n),
    .addr(addr)
    );

    blk_mem_gen_0 rom(
    .clka(clk_div),    // input wire clka
    .addra(addr),  // input wire [31 : 0] addra
    .douta(inst)  // output wire [31 : 0] douta
    );

    display display_u0(
    .clk(clk),
    .reset(reset_n),
    .s(inst),
    .seg(seg),
    .ans(ans)
    );

    Controller Controller_u0(
    .inst(inst),
    .jump(control_sig[0]),
    .branch(control_sig[1]),
    .alusrc(control_sig[2]),
    .memwrite(control_sig[3]),
    .memtoreg(control_sig[4]),
    .regwrite(control_sig[5]),
    .regdst(control_sig[6]),
    .Alucontrol(control_sig[9:7])
    );

endmodule
