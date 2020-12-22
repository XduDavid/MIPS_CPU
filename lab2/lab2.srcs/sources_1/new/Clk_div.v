`timescale 1ns / 1ps

module Clk_div(
    input clk,
    input reset_n,
    output reg clk_div
    );
    //define the time counter
    reg [27:0]      cnt0;
    parameter       SET_TIME = 27'd52428800;
    always@(posedge clk) begin
        if(~reset_n)begin
            cnt0 <= 27'd0;
        end
        else begin
            if (cnt0 == SET_TIME) begin
                cnt0 <= 27'd0;                   //count done,clearing the time counter
                clk_div <= 1'd1;
            end
            else begin
                cnt0 <= cnt0 + 1'd1;            //cnt0 counter = cnt0 counter + 1
                clk_div <= 1'd0;
            end
        end
    end
endmodule
