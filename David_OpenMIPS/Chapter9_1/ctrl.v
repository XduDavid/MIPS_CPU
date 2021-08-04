`include "defines.v"
module ctrl(
    input wire rst,             //复位信号
    input wire stallreq_from_id,//处于译码阶段的指令是否请求流水线暂停
    input wire stallreq_from_ex,//处于执行阶段的指令是否请求流水线暂停
    output reg [5:0] stall      //暂停流水线控制信号
);

    always @(*) begin
        if(rst == `RstEnable) begin
            stall = 6'b0;
        end
        else if(stallreq_from_ex == `Stop) begin
            stall = 6'b001111;
        end
        else if(stallreq_from_id == `Stop) begin
            stall = 6'b000111;
        end
        else begin
            stall = 6'b000000;
        end
    end

endmodule