`timescale 1ns / 1ps

module alu(
    input wire[31:0] a,b,
	input wire[2:0] op,
	output [31:0] y,
	output overflow,
	output zero
    );

    wire [31:0] s,bout;

    assign bout = op[2] ? ~b : b;
    assign s = a + bout + op[2];     //补码为反码加1，融合加法与减法

    assign  y = (op[1:0] == 2'b00) ? (a & bout) :
                (op[1:0] == 2'b01) ? (a | bout) :
                (op[1:0] == 2'b10) ? (s) : 
                (op[1:0] == 2'b11) ? (s[31]) : 32'b0;

    assign zero = (s == 32'b0);

    assign overflow = (op[2:1] == 2'b01) ? 
                      ((a[31] & b[31] & ~s[31]) | (~a[31] & ~b[31] & s[31])) :
                      (op[2:1] == 2'b11) ?
                      ((a[31] & ~b[31] & ~s[31]) | (~a[31] & b[31] & s[31])) : 1'b0;
                      
endmodule
