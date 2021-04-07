`include "defines.v"
module hilo_reg(
    input wire rst,clk,we,
    input wire [`RegBus] hi_i,lo_i,
    output reg [`RegBus] hi_o,lo_o
);

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
        end
        else begin
            if(we == `WriteEnable) begin
                hi_o <= hi_i;
                lo_o <= lo_i;
            end
        end
    end

endmodule