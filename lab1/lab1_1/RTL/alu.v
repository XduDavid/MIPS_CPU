`timescale 1ns / 1ps

module alu(
    input wire [2:0] op,
    output [31:0] result
    );

    wire [2:0] op_n;
    assign op_n = ~op;
    wire [31:0] num1,num2;
    assign num1 = 32'd30;
    assign num2 = 32'd15;
    assign result = (op_n == 3'd0) ? num1 + num2 :
                    (op_n == 3'd1) ? num1 - num2 :
                    (op_n == 3'd2) ? num1 & num2 :
                    (op_n == 3'd3) ? num1 | num2 :
                    (op_n == 3'd4) ? ~num1 :
                    32'h0;                    
endmodule
