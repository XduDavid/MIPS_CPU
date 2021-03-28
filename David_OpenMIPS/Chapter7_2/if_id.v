`include "defines.v"

module if_id(
    input wire              rst,
    input wire              clk,
    input wire [5:0]        stall,

    //来自取值阶段的信号，InstBus表示指令宽度为32
    input wire [`InstBus]   if_inst,

    //对应的译码阶段的信号
    output reg [`InstBus]   id_inst
);

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
          id_inst <= `ZeroWord;
        end
        else if(stall[1] == `Stop && stall[2] == `NoStop) begin
          id_inst <= `ZeroWord;
        end
        else if(stall[1] == `NoStop) begin
          id_inst <= if_inst;
        end
    end

endmodule
