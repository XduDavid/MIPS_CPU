`timescale 1ns / 1ps

module PC(
    input clk,
    input reset_n,
    output reg [31:0] addr
    );

    wire [31:0] addr_next;
    adder add_u0(
            .a(addr),
            .b(32'd4),
            .out(addr_next)
            );

    always @(posedge clk or negedge reset_n) begin
        if(~reset_n)begin
            addr <= 32'd0;
        end
        else begin
            addr <= addr_next;
        end
    end

endmodule
