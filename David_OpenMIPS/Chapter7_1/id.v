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
    output reg                wreg_o,     //译码阶段的指令是否有要写入的目的寄存器

    //处于执行阶段的指令的运算结果
    input wire                ex_wreg_i,
    input wire [`RegBus]      ex_wdata_i,
    input wire [`RegAddrBus]  ex_wd_i,

    //处于访存阶段的指令的运算结果
    input wire                mem_wreg_i,
    input wire [`RegBus]      mem_wdata_i,
    input wire [`RegAddrBus]  mem_wd_i
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
          if(inst_i[31:21] == 11'b00000000000) begin
            if(op3 == `EXE_SLL) begin
              wreg_o = `WriteEnable;
              aluop_o = `EXE_SLL_OP;
              alusel_o = `EXE_RES_SHIFT;
              reg1_read_o = `ReadDisable;
              reg2_read_o = `ReadEnable;
              imm[4:0] = inst_i[10:6];              
              wd_o = inst_i[15:11];
              instvalid = `InstValid;
              reg1_addr_o = inst_i[25:21];
              reg2_addr_o = inst_i[20:16]; 
            end
            else if(op3 == `EXE_SRL) begin
              wreg_o = `WriteEnable;
              aluop_o = `EXE_SRL_OP;
              alusel_o = `EXE_RES_SHIFT;
              reg1_read_o = `ReadDisable;
              reg2_read_o = `ReadEnable;
              imm[4:0] = inst_i[10:6];              
              wd_o = inst_i[15:11];
              instvalid = `InstValid;
              reg1_addr_o = inst_i[25:21];
              reg2_addr_o = inst_i[20:16];
            end
            else if(op3 == `EXE_SRA) begin
              wreg_o = `WriteEnable;
              aluop_o = `EXE_SRA_OP;
              alusel_o = `EXE_RES_SHIFT;
              reg1_read_o = `ReadDisable;
              reg2_read_o = `ReadEnable;
              imm[4:0] = inst_i[10:6];              
              wd_o = inst_i[15:11];
              instvalid = `InstValid;
              reg1_addr_o = inst_i[25:21];
              reg2_addr_o = inst_i[20:16];
            end
            else if(op3 == `EXE_MFHI) begin
                wreg_o = `WriteEnable;
                aluop_o = `EXE_MFHI_OP;
                alusel_o = `EXE_RES_MOVE;
                reg1_read_o = `ReadDisable;
                reg2_read_o = `ReadDisable;
                instvalid = `InstValid;                          
                imm = `ZeroWord;              
                wd_o = inst_i[15:11];
                reg1_addr_o = inst_i[25:21];
                reg2_addr_o = inst_i[20:16];
            end
            else if(op3 == `EXE_MFLO) begin
                wreg_o = `WriteEnable;
                aluop_o = `EXE_MFLO_OP;
                alusel_o = `EXE_RES_MOVE;
                reg1_read_o = `ReadDisable;
                reg2_read_o = `ReadDisable;
                instvalid = `InstValid;                          
                imm = `ZeroWord;              
                wd_o = inst_i[15:11];
                reg1_addr_o = inst_i[25:21];
                reg2_addr_o = inst_i[20:16];
            end
          end
          else begin
            case(op)
                `EXE_SPECIAL_INST:begin
                  case(op2)
                    5'b00000:begin
                      case(op3)
                        `EXE_OR:begin
                          wreg_o = `WriteEnable;
                          aluop_o = `EXE_OR_OP;
                          alusel_o = `EXE_RES_LOGIC;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_AND:begin
                          wreg_o = `WriteEnable;
                          aluop_o = `EXE_AND_OP;
                          alusel_o = `EXE_RES_LOGIC;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_XOR:begin
                          wreg_o = `WriteEnable;
                          aluop_o = `EXE_XOR_OP;
                          alusel_o = `EXE_RES_LOGIC;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_NOR:begin
                          wreg_o = `WriteEnable;
                          aluop_o = `EXE_NOR_OP;
                          alusel_o = `EXE_RES_LOGIC;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_SLLV:begin
                          wreg_o = `WriteEnable;
                          aluop_o = `EXE_SLL_OP;
                          alusel_o = `EXE_RES_SHIFT;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_SRLV:begin
                          wreg_o = `WriteEnable;
                          aluop_o = `EXE_SRL_OP;
                          alusel_o = `EXE_RES_SHIFT;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_SRAV:begin
                          wreg_o = `WriteEnable;
                          aluop_o = `EXE_SRA_OP;
                          alusel_o = `EXE_RES_SHIFT;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_SYNC:begin
                          wreg_o = `WriteDisable;
                          aluop_o = `EXE_NOP_OP;
                          alusel_o = `EXE_RES_NOP;
                          reg1_read_o = `ReadDisable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_MTHI: begin
                          wreg_o = `WriteDisable;
                          aluop_o = `EXE_MTHI_OP;
                          alusel_o = `EXE_RES_MOVE;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadDisable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_MTLO: begin
                          wreg_o = `WriteDisable;
                          aluop_o = `EXE_MTLO_OP;
                          alusel_o = `EXE_RES_MOVE;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadDisable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_MOVZ: begin
                          wreg_o = (reg2_o == `ZeroWord) ? `WriteEnable : `WriteDisable;
                          aluop_o = `EXE_MOVZ_OP;
                          alusel_o = `EXE_RES_MOVE;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_MOVN:begin
                          wreg_o = (reg2_o != `ZeroWord) ? `WriteEnable : `WriteDisable;
                          aluop_o = `EXE_MOVN_OP;
                          alusel_o = `EXE_RES_MOVE;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_MULT:begin
                          wreg_o = `WriteDisable;
                          aluop_o = `EXE_MULT_OP;
                          alusel_o = `EXE_RES_NOP;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_MULTU:begin
                          wreg_o = `WriteDisable;
                          aluop_o = `EXE_MULTU_OP;
                          alusel_o = `EXE_RES_NOP;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_ADD:begin
                          wreg_o = `WriteEnable;
                          aluop_o = `EXE_ADD_OP;
                          alusel_o = `EXE_RES_ARITHMETIC;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_ADDU:begin
                          wreg_o = `WriteEnable;
                          aluop_o = `EXE_ADDU_OP;
                          alusel_o = `EXE_RES_ARITHMETIC;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_SUB:begin
                          wreg_o = `WriteEnable;
                          aluop_o = `EXE_SUB_OP;
                          alusel_o = `EXE_RES_ARITHMETIC;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_SUBU:begin
                          wreg_o = `WriteEnable;
                          aluop_o = `EXE_SUBU_OP;
                          alusel_o = `EXE_RES_ARITHMETIC;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_SLT:begin
                          wreg_o = `WriteEnable;
                          aluop_o = `EXE_SLT_OP;
                          alusel_o = `EXE_RES_ARITHMETIC;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        `EXE_SLTU:begin
                          wreg_o = `WriteEnable;
                          aluop_o = `EXE_SLTU_OP;
                          alusel_o = `EXE_RES_ARITHMETIC;
                          reg1_read_o = `ReadEnable;
                          reg2_read_o = `ReadEnable;
                          instvalid = `InstValid;                          
                          imm = `ZeroWord;              
                          wd_o = inst_i[15:11];
                          reg1_addr_o = inst_i[25:21];
                          reg2_addr_o = inst_i[20:16];
                        end
                        default:begin
                          aluop_o = `EXE_NOP_OP;
                          alusel_o = `EXE_RES_NOP;
                          wd_o = `NOPRegAddr;
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
                    default:begin
                      aluop_o = `EXE_NOP_OP;
                      alusel_o = `EXE_RES_NOP;
                      wd_o = `NOPRegAddr;
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
                `EXE_SPECIAL2_INST:begin
                  case(op3)
                    `EXE_CLZ:begin
                      wreg_o = `WriteEnable;
                      aluop_o = `EXE_CLZ_OP;
                      alusel_o = `EXE_RES_ARITHMETIC;
                      reg1_read_o = `ReadEnable;
                      reg2_read_o = `ReadDisable;
                      imm = `ZeroWord;              
                      wd_o = inst_i[20:16];
                      instvalid = `InstValid;
                      reg1_addr_o = inst_i[25:21];
                      reg2_addr_o = inst_i[20:16];
                    end
                    `EXE_CLO:begin
                      wreg_o = `WriteEnable;
                      aluop_o = `EXE_CLO_OP;
                      alusel_o = `EXE_RES_ARITHMETIC;
                      reg1_read_o = `ReadEnable;
                      reg2_read_o = `ReadDisable;
                      imm = `ZeroWord;              
                      wd_o = inst_i[20:16];
                      instvalid = `InstValid;
                      reg1_addr_o = inst_i[25:21];
                      reg2_addr_o = inst_i[20:16];
                    end
                    `EXE_MUL:begin
                      wreg_o = `WriteEnable;
                      aluop_o = `EXE_MUL_OP;
                      alusel_o = `EXE_RES_MUL;
                      reg1_read_o = `ReadEnable;
                      reg2_read_o = `ReadEnable;
                      imm = `ZeroWord;              
                      wd_o = inst_i[15:11];
                      instvalid = `InstValid;
                      reg1_addr_o = inst_i[25:21];
                      reg2_addr_o = inst_i[20:16];
                    end
                    default:begin
                      aluop_o = `EXE_NOP_OP;
                      alusel_o = `EXE_RES_NOP;
                      wd_o = `NOPRegAddr;
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
                `EXE_ORI:begin
                  wreg_o = `WriteEnable;
                  aluop_o = `EXE_OR_OP;
                  alusel_o = `EXE_RES_LOGIC;
                  reg1_read_o = `ReadEnable;
                  reg2_read_o = `ReadDisable;
                  imm = {16'h0,inst_i[15:0]};              
                  wd_o = inst_i[20:16];
                  instvalid = `InstValid;
                  reg1_addr_o = inst_i[25:21];
                  reg2_addr_o = inst_i[20:16];
                end
                `EXE_ANDI:begin
                  wreg_o = `WriteEnable;
                  aluop_o = `EXE_AND_OP;
                  alusel_o = `EXE_RES_LOGIC;
                  reg1_read_o = `ReadEnable;
                  reg2_read_o = `ReadDisable;
                  imm = {16'h0,inst_i[15:0]};              
                  wd_o = inst_i[20:16];
                  instvalid = `InstValid;
                  reg1_addr_o = inst_i[25:21];
                  reg2_addr_o = inst_i[20:16];
                end
                `EXE_XORI:begin
                  wreg_o = `WriteEnable;
                  aluop_o = `EXE_XOR_OP;
                  alusel_o = `EXE_RES_LOGIC;
                  reg1_read_o = `ReadEnable;
                  reg2_read_o = `ReadDisable;
                  imm = {16'h0,inst_i[15:0]};              
                  wd_o = inst_i[20:16];
                  instvalid = `InstValid;
                  reg1_addr_o = inst_i[25:21];
                  reg2_addr_o = inst_i[20:16];
                end
                `EXE_LUI:begin
                  wreg_o = `WriteEnable;
                  aluop_o = `EXE_OR_OP;
                  alusel_o = `EXE_RES_LOGIC;
                  reg1_read_o = `ReadEnable;
                  reg2_read_o = `ReadDisable;
                  imm = {inst_i[15:0],16'h0};              
                  wd_o = inst_i[20:16];
                  instvalid = `InstValid;
                  reg1_addr_o = inst_i[25:21];
                  reg2_addr_o = inst_i[20:16];
                end
                `EXE_PREF:begin
                  wreg_o = `WriteDisable;
                  aluop_o = `EXE_NOP_OP;
                  alusel_o = `EXE_RES_NOP;
                  reg1_read_o = `ReadDisable;
                  reg2_read_o = `ReadDisable;
                  imm = `ZeroWord;              
                  wd_o = `NOPRegAddr;
                  instvalid = `InstValid;
                  reg1_addr_o = inst_i[25:21];
                  reg2_addr_o = inst_i[20:16];
                end
                `EXE_ADDI:begin
                  wreg_o = `WriteEnable;
                  aluop_o = `EXE_ADDI_OP;
                  alusel_o = `EXE_RES_ARITHMETIC;
                  reg1_read_o = `ReadEnable;
                  reg2_read_o = `ReadDisable;
                  imm = {{16{inst_i[15]}},inst_i[15:0]};              
                  wd_o = inst_i[20:16];
                  instvalid = `InstValid;
                  reg1_addr_o = inst_i[25:21];
                  reg2_addr_o = inst_i[20:16];
                end
                `EXE_ADDIU:begin
                  wreg_o = `WriteEnable;
                  aluop_o = `EXE_ADDIU_OP;
                  alusel_o = `EXE_RES_ARITHMETIC;
                  reg1_read_o = `ReadEnable;
                  reg2_read_o = `ReadDisable;
                  imm = {{16{inst_i[15]}},inst_i[15:0]};              
                  wd_o = inst_i[20:16];
                  instvalid = `InstValid;
                  reg1_addr_o = inst_i[25:21];
                  reg2_addr_o = inst_i[20:16];
                end
                `EXE_SLTI:begin
                  wreg_o = `WriteEnable;
                  aluop_o = `EXE_SLT_OP;
                  alusel_o = `EXE_RES_ARITHMETIC;
                  reg1_read_o = `ReadEnable;
                  reg2_read_o = `ReadDisable;
                  imm = {{16{inst_i[15]}},inst_i[15:0]};              
                  wd_o = inst_i[20:16];
                  instvalid = `InstValid;
                  reg1_addr_o = inst_i[25:21];
                  reg2_addr_o = inst_i[20:16];
                end
                `EXE_SLTIU:begin
                  wreg_o = `WriteEnable;
                  aluop_o = `EXE_SLTU_OP;
                  alusel_o = `EXE_RES_ARITHMETIC;
                  reg1_read_o = `ReadEnable;
                  reg2_read_o = `ReadDisable;
                  imm = {{16{inst_i[15]}},inst_i[15:0]};              
                  wd_o = inst_i[20:16];
                  instvalid = `InstValid;
                  reg1_addr_o = inst_i[25:21];
                  reg2_addr_o = inst_i[20:16];
                end
                default:begin
                  aluop_o = `EXE_NOP_OP;
                  alusel_o = `EXE_RES_NOP;
                  wd_o = `NOPRegAddr;
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
    end

//确定进行运算的操作数1
//给reg1_o赋值的过程增加了两种情况
//1.如果Regfile模块读端口1要读取的寄存器就是执行阶段要写的目的寄存器，
//那么直接把执行阶段的结果ex_data_i作为reg1_o的值
//2.如果Regfile模块读端口1要读取的寄存器就是访存阶段要写的目的寄存器，
//那么直接把访存阶段的结果mem_data_i作为reg1_o的值
always @(*) begin
    if(rst == `RstEnable) begin
      reg1_o = `ZeroWord;
    end
    else if((reg1_read_o == `ReadEnable) && (ex_wreg_i == `WriteEnable) && (ex_wd_i == reg1_addr_o))begin
      reg1_o = ex_wdata_i;
    end
    else if((reg1_read_o == `ReadEnable) && (mem_wreg_i == `WriteEnable) && (mem_wd_i == reg1_addr_o)) begin
      reg1_o = mem_wdata_i;
    end
    else if(reg1_read_o == `ReadEnable) begin
      reg1_o = reg1_data_i;
    end
    else if(reg1_read_o == `ReadDisable) begin
      reg1_o = imm;
    end
    else begin
      reg1_o = `ZeroWord;
    end
end

//确定进行运算的操作数2
//给reg2_o赋值的过程与reg1_o同理
always @(*) begin
    if(rst == `RstEnable) begin
      reg2_o = `ZeroWord;
    end
    else if((reg2_read_o == `ReadEnable) && (ex_wreg_i == `WriteEnable) && (ex_wd_i == reg2_addr_o))begin
      reg2_o = ex_wdata_i;
    end
    else if((reg2_read_o == `ReadEnable) && (mem_wreg_i == `WriteEnable) && (mem_wd_i == reg2_addr_o)) begin
      reg2_o = mem_wdata_i;
    end
    else if(reg2_read_o == `ReadEnable) begin
      reg2_o = reg2_data_i;
    end
    else if(reg2_read_o == `ReadDisable) begin
      reg2_o = imm;
    end
    else begin
      reg2_o = `ZeroWord;
    end
end

endmodule
