`timescale 1ns / 1ps

module flopr #(parameter WIDTH = 8)(
    input wire clk,rst,
	input wire[WIDTH-1:0] d,
	output reg[WIDTH-1:0] q
    );

    always @(negedge clk or posedge rst) begin
        if(rst)begin
            q <= 0;
        end
        else begin
            q <= d;
        end 
    end

endmodule
