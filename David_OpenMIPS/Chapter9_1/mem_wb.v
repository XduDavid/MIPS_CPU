`include "defines.v"

module mem_wb(
    input wire                  clk,
    input wire                  rst,

    //访存阶段的结果
    input wire[`RegAddrBus]     mem_wd,
    input wire                  mem_wreg,
    input wire[`RegBus]         mem_wdata,
    //与HI/LO寄存器相关的输入接口
    input wire                  mem_whilo,
    input wire[`RegBus]         mem_hi,
    input wire[`RegBus]         mem_lo,

    //送到回写阶段的信息
    output reg[`RegAddrBus]     wb_wd,
    output reg                  wb_wreg,
    output reg[`RegBus]         wb_wdata,
    //与HI/LO寄存器相关的输出接口
    output reg                  wb_whilo,
    output reg[`RegBus]         wb_hi,
    output reg[`RegBus]         wb_lo,

    input wire [5:0]            stall
);

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
          wb_wd <= `NOPRegAddr;
          wb_wreg <= `WriteDisable;
          wb_wdata <= `ZeroWord;
          wb_whilo <= `WriteDisable;
          wb_hi <= `ZeroWord;
          wb_lo <= `ZeroWord;
        end
        else begin
          if(stall[4] == `Stop && stall[5] == `NoStop) begin
            wb_wd <= `NOPRegAddr;
            wb_wreg <= `WriteDisable;
            wb_wdata <= `ZeroWord;
            wb_whilo <= `WriteDisable;
            wb_hi <= `ZeroWord;
            wb_lo <= `ZeroWord;
          end
          else if(stall[4] == `NoStop) begin
            wb_wd <= mem_wd;
            wb_wreg <= mem_wreg;
            wb_wdata <= mem_wdata;
            wb_whilo <= mem_whilo;
            wb_hi <= mem_hi;
            wb_lo <= mem_lo;
          end
        end
    end

endmodule