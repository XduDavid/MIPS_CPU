`include "defines.v"

module id(
    input wire                rst,
    input wire [`InstBus]     inst_i,

    //��ȡ��Regfile��ֵ
    input wire[`RegBus]       reg1_data_i,
    input wire[`RegBus]       reg2_data_i,

    //�����Regfile����Ϣ
    output reg                reg1_read_o,
    output reg                reg2_read_o,
    output reg [`RegAddrBus]  reg1_addr_o,
    output reg [`RegAddrBus]  reg2_addr_o,

    //�͵�ִ�н׶ε���Ϣ
    output reg[`AluSelBus]    alusel_o,
    output reg[`AluOpBus]     aluop_o,
    output reg[`RegBus]       reg1_o,
    output reg[`RegBus]       reg2_o,
    output reg[`RegAddrBus]   wd_o,       //����׶ε�ָ��Ҫд���Ŀ�ļĴ�����ַ
    output reg                wreg_o,     //����׶ε�ָ���Ƿ���Ҫд���Ŀ�ļĴ���

    //����ִ�н׶ε�ָ���������
    input wire                ex_wreg_i,
    input wire [`RegBus]      ex_wdata_i,
    input wire [`RegAddrBus]  ex_wd_i,

    //���ڷô�׶ε�ָ���������
    input wire                mem_wreg_i,
    input wire [`RegBus]      mem_wdata_i,
    input wire [`RegAddrBus]  mem_wd_i
);

    //ȡ��ָ���ָ�����빦����
    wire [5:0] op = inst_i[31:26];
    wire [4:0] op2 = inst_i[10:6];
    wire [5:0] op3 = inst_i[5:0];
    wire [4:0] op4 = inst_i[20:16];

    //����ָ��ִ����Ҫ��������
    reg[`RegBus] imm;

    //ָʾָ���Ƿ���Ч
    reg instvalid;

    //��һ�Σ���ָ���������
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

//ȷ����������Ĳ�����1
//��reg1_o��ֵ�Ĺ����������������
//1.���Regfileģ����˿�1Ҫ��ȡ�ļĴ�������ִ�н׶�Ҫд��Ŀ�ļĴ�����
//��ôֱ�Ӱ�ִ�н׶εĽ��ex_data_i��Ϊreg1_o��ֵ
//2.���Regfileģ����˿�1Ҫ��ȡ�ļĴ������Ƿô�׶�Ҫд��Ŀ�ļĴ�����
//��ôֱ�Ӱѷô�׶εĽ��mem_data_i��Ϊreg1_o��ֵ
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

//ȷ����������Ĳ�����2
//��reg2_o��ֵ�Ĺ�����reg1_oͬ��
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