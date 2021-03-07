`include "defines.v"

module id(
    input wire                rst,
    input wire [`InstBus]     inst_i,

    //读取的Regfile的值
    input wire[`RegBus]       reg1_data_i,
    input wire[`RegBus]       reg2_data_i,

    //输出到Regfile的信息
    output reg                reg1_read_o,
    output reg                reg2_read_o,
    output reg [`RegAddrBus]  reg1_addr_o,
    output reg [`RegAddrBus]  reg2_addr_o,

    //送到执行阶段的信息
    output reg[`AluSelBus]    alusel_o,
    output reg[`AluOpBus]     aluop_o,
    output reg[`RegBus]       reg1_o,
    output reg[`RegBus]       reg2_o,
    output reg[`RegAddrBus]   wd_o,       //译码阶段的指令要写入的目的寄存器地址
    output reg                wreg_o      //译码阶段的指令是否有要写入的目的寄存器
);

    //取得指令的指令码与功能码
    wire [5:0] op = inst_i[31:26];
    wire [4:0] op2 = inst_i[10:6];
    wire [5:0] op3 = inst_i[5:0];
    wire [4:0] op4 = inst_i[20:16];

    //保存指令执行需要的立即数
    reg[`RegBus] imm;

    //指示指令是否有效
    reg instvalid;

    //第一段：对指令进行译码
    always @(*) begin
        if(rst == `RstEnable) begin
          aluop_o = `EXE_NOP_OP;
          alusel_o = `EXE_RES_NOP;
          wd_o = `NOPRegAddr;
          wreg_o = `WriteDisable;
          instvalid = `InstInvalid;
          reg1_read_o = `ReadDisable;
          reg2_read_o = `ReadDisable;
          reg1_addr_o = `NOPRegAddr;
          reg2_addr_o = `NOPRegAddr;
          imm = `ZeroWord;
        end
        else begin
          case(op)
            `EXE_ORI:begin
              aluop_o = `EXE_OR_OP;
              alusel_o = `EXE_RES_LOGIC;
              wd_o = inst_i[20:16];
              wreg_o = `WriteEnable;
              instvalid = `InstValid;
              reg1_read_o = `ReadEnable;
              reg2_read_o = `ReadDisable;
              reg1_addr_o = inst_i[25:21];
              reg2_addr_o = inst_i[20:16];
              imm = {16'h0,inst_i[15:0]};
            end
            default:begin
                aluop_o = `EXE_NOP_OP;
                alusel_o = `EXE_RES_NOP;
                wd_o = inst_i[15:11];
                wreg_o = `WriteDisable;
                instvalid = `InstInvalid;
                reg1_read_o = `ReadDisable;
                reg2_read_o = `ReadDisable;
                reg1_addr_o = inst_i[25:21];
                reg2_addr_o = inst_i[20:16];
                imm = `ZeroWord;
            end
          endcase
        end
    end

//确定进行运算的操作数1
always @(*) begin
    if(rst == `RstEnable) begin
      reg1_o = `ZeroWord;
    end
    else if(reg1_read_o == 1'b1) begin
      reg1_o = reg1_data_i;
    end
    else if(reg1_read_o == 1'b0) begin
      reg1_o = imm;
    end
    else begin
      reg1_o = `ZeroWord;
    end
end

//确定进行运算的操作数2
always @(*) begin
    if(rst == `RstEnable) begin
      reg2_o = `ZeroWord;
    end
    else if(reg2_read_o == 1'b1) begin
      reg2_o = reg2_data_i;
    end
    else if(reg2_read_o == 1'b0) begin
      reg2_o = imm;
    end
    else begin
      reg2_o = `ZeroWord;
    end
end

endmodule
