`timescale 1ns / 1ps

module top(
    input [3:0] ins,
    input clk,
    input reset_n,
    output [6:0] seg,
    output [5:0] ans
    );

    wire [31:0] s;

    blk_mem_gen_0 rom_u0(
    .clka(clk),    // input wire clka
    .addra({28'b0,~ins[3:0]}),  // input wire [7 : 0] addra
    .douta(s)  // output wire [31 : 0] douta
    );

    display display_u0(
    .clk(clk),
    .reset(reset_n),
    .s(s),
    .seg(seg),
    .ans(ans)
    );

endmodule
