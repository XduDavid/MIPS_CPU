`include "defines.v"

module id_ex(
    input wire              clk,
    input wire              rst,

    //������׶δ��ݹ�������Ϣ
    input wire[`AluSelBus]  id_alusel,
    input wire[`AluOpBus]   id_aluop,
    input wire[`RegBus]     id_reg1,
    input wire[`RegBus]     id_reg2,
    input wire[`RegAddrBus] id_wd,  //ִ�н׶ε�ָ��Ҫд���Ŀ�ļĴ����ĵ�ַ
    input wire              id_wreg,//ִ�н׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���

    //���ݵ�ִ�н׶ε���Ϣ
    output reg[`AluSelBus]  ex_alusel,
    output reg[`AluOpBus]   ex_aluop,
    output reg[`RegBus]     ex_reg1,
    output reg[`RegBus]     ex_reg2,
    output reg[`RegAddrBus] ex_wd,
    output reg              ex_wreg,

    input wire [5:0]        stall,

    input wire id_is_in_delayslot,  //��ǰ��������׶ε�ָ���Ƿ����ӳٲ�
    input wire [`RegBus] id_link_address,//��������׶ε�ת��ָ��Ҫ����ķ��ص�ַ
    //��һ����������׶ε�ָ���Ƿ�λ���ӳٲ�
    input wire next_inst_in_delayslot_i,
    //��ǰ����ִ�н׶ε�ָ���Ƿ�λ���ӳٲ�
    output reg ex_is_in_delayslot,
    //����ִ�н׶ε�ת��ָ��Ҫ����ķ��ص�ַ
    output reg [`RegBus] ex_link_address,
    //��ǰ��������׶ε�ָ���Ƿ�λ���ӳٲ�
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