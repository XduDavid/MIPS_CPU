`timescale 1ns / 1ps

module sl2(
    input wire [31:0] a,
    output wire [31:0] b
    );

    assign b = {a[29:0],2'b0};

endmodule
