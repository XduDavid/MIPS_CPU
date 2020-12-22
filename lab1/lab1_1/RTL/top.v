`timescale 1ns / 1ps

module top(
    input clk,
    input rst,
    input [2:0] op,
    output [5:0] ans,
    output [6:0] seg
    );

    wire [31:0] s;

    alu alu_0(
    .op(op),
    .result(s)
    );

    display display_0(
    .clk(clk),
    .reset(rst),
    .s(s),
    .seg(seg),
    .ans(ans)
    );

endmodule
