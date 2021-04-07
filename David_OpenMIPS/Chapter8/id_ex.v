`include "defines.v"

module id_ex(
    input wire              clk,
    input wire              rst,

    //从译码阶段传递过来的信息
    input wire[`AluSelBus]  id_alusel,
    input wire[`AluOpBus]   id_aluop,
    input wire[`RegBus]     id_reg1,
    input wire[`RegBus]     id_reg2,
    input wire[`RegAddrBus] id_wd,  //执行阶段的指令要写入的目的寄存器的地址
    input wire              id_wreg,//执行阶段的指令是否有要写入的目的寄存器

    //传递到执行阶段的信息
    output reg[`AluSelBus]  ex_alusel,
    output reg[`AluOpBus]   ex_aluop,
    output reg[`RegBus]     ex_reg1,
    output reg[`RegBus]     ex_reg2,
    output reg[`RegAddrBus] ex_wd,
    output reg              ex_wreg,

    input wire [5:0]        stall,

    input wire id_is_in_delayslot,  //当前处于译码阶段的指令是否处于延迟槽
    input wire [`RegBus] id_link_address,//处于译码阶段的转移指令要保存的返回地址
    //下一条进入译码阶段的指令是否位于延迟槽
    input wire next_inst_in_delayslot_i,
    //当前处于执行阶段的指令是否位于延迟槽
    output reg ex_is_in_delayslot,
    //处于执行阶段的转移指令要保存的返回地址
    output reg [`RegBus] ex_link_address,
    //当前处于译码阶段的指令是否位于延迟槽
    output reg is_in_delayslot_o
);

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
          ex_alusel <= `EXE_RES_NOP;
          ex_aluop <= `EXE_NOP_OP;
          ex_reg1 <= `ZeroWord;
          ex_reg2 <= `ZeroWord;
          ex_wd <= `NOPRegAddr;
          ex_wreg <= `WriteDisable;
          ex_link_address <= `ZeroWord;
          ex_is_in_delayslot <= `NotInDelaySlot;
          is_in_delayslot_o <= `NotInDelaySlot;
        end
        else begin
          if(stall[2] == `Stop && stall[3] == `NoStop) begin
            ex_alusel <= `EXE_RES_NOP;
            ex_aluop <= `EXE_NOP_OP;
            ex_reg1 <= `ZeroWord;
            ex_reg2 <= `ZeroWord;
            ex_wd <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
            ex_link_address <= `ZeroWord;
            ex_is_in_delayslot <= `NotInDelaySlot;
            is_in_delayslot_o <= `NotInDelaySlot;
          end
          else if(stall[2] == `NoStop) begin
            ex_alusel <= id_alusel;
            ex_aluop <= id_aluop;
            ex_reg1 <= id_reg1;
            ex_reg2 <= id_reg2;
            ex_wd <= id_wd;
            ex_wreg <= id_wreg;
            ex_link_address <= id_link_address;
            ex_is_in_delayslot <= id_is_in_delayslot;
            is_in_delayslot_o <= next_inst_in_delayslot_i;
          end
        end
    end

endmodule