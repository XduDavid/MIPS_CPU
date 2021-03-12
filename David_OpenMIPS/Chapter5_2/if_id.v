`include "defines.v"

module if_id(
    input wire              rst,
    input wire              clk,

    //来自取值阶段的信号，InstBus表示指令宽度为32
    input wire [`InstBus]   if_inst,

    //对应的译码阶段的信号
    output reg [`InstBus]   id_inst
);

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
          id_inst <= `ZeroWord;
        end
        else begin
          id_inst <= if_inst;
        end
    end

endmodule
