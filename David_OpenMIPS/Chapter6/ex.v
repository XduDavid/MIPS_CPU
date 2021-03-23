`include "defines.v"

module ex(
    input wire              rst,

    //译码阶段送到执行阶段的信息
    input wire[`AluSelBus]  alusel_i,
    input wire[`AluOpBus]   aluop_i,
    input wire[`RegBus]     reg1_i,
    input wire[`RegBus]     reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire              wreg_i,

    //执行的结果
    output reg[`RegAddrBus] wd_o,       //执行阶段的结果最终要写入的目的寄存器的地址
    output reg wreg_o,
    output reg[`RegBus] wdata_o,         //执行阶段最终要写入目的寄存器的值

    //增加HI/LO特殊寄存器后添加的信号
    input wire [31:0] hi_i,lo_i,    //HILO模块给出的HI/LO寄存器的值
    //访存阶段的数据前推
    input wire mem_whilo_i,         //处于访存阶段的指令是否要写HI/LO寄存器
    input wire [31:0] mem_hi_i,mem_lo_i, //处于访存阶段的指令要写入HI/LO寄存器的值
    //回写阶段的数据前推
    input wire wb_whilo_i,          //处于回写阶段的指令是否要写入HI/LO寄存器
    input wire [31:0] wb_hi_i,wb_lo_i, //处于回写阶段的指令要写入HI/LO寄存器的值
    //HI/LO的输出
    output reg whilo_o,
    output reg [31:0] hi_o,lo_o     //执行阶段的指令要写入HI/LO寄存器的值
);

    //保存逻辑运算的结果
    reg [`RegBus] logicout;
    //保存移位运算的结果
    reg [`RegBus] shiftres;
    //移动操作的结果
    reg [`RegBus] moveres;

    //保存HI/LO寄存器的最新值
    reg [`RegBus] HI,LO;

/****************************************************
** 得到最新的HI/LO寄存器的值，此处需解决数据相关问题   *****
****************************************************/
  always @(*) begin
    if(rst == `RstEnable) begin
      {HI,LO} <= {`ZeroWord,`ZeroWord};
    end
    else if(mem_whilo_i == `WriteEnable) begin
      {HI,LO} <= {mem_hi_i,mem_lo_i};
    end
    else if(wb_whilo_i == `WriteEnable) begin
      {HI,LO} <= {wb_hi_i,wb_lo_i};
    end
    else begin
      {HI,LO} <= {hi_i,lo_i};
    end
  end

/****************************************************
** MFHI、MFLO、MOVN、MOVZ指令(需回写通用寄存器的命令)  ***
****************************************************/
    always @(*) begin
      if(rst == `RstEnable) begin
          moveres = `ZeroWord;
      end
      else begin
          case(aluop_i)
              `EXE_MFHI_OP:   moveres = HI;
              `EXE_MFLO_OP:   moveres = LO;
              `EXE_MOVN_OP:   moveres = reg1_i;
              `EXE_MOVZ_OP:   moveres = reg1_i;
              default:        moveres = `ZeroWord;
          endcase
      end
    end


    //进行逻辑运算
    always @(*) begin
        if(rst == `RstEnable) begin
          logicout = `ZeroWord;
        end
        else begin
            case(aluop_i)
                `EXE_OR_OP:     logicout = reg1_i | reg2_i;
                `EXE_AND_OP:    logicout = reg1_i & reg2_i;
                `EXE_NOR_OP:    logicout = ~(reg1_i | reg2_i);
                `EXE_XOR_OP:    logicout = reg1_i ^ reg2_i;
                default:    logicout = `ZeroWord;
            endcase
        end  
    end

    //进行移位运算
    always @(*) begin
        if(rst == `RstEnable) begin
          shiftres = `ZeroWord;
        end
        else begin
          case(aluop_i)
            `EXE_SLL_OP:    shiftres = reg2_i << reg1_i[4:0];
            `EXE_SRL_OP:    shiftres = reg2_i >> reg1_i[4:0];
            `EXE_SRA_OP:begin
              shiftres = ({32{reg2_i[31]}}<<(6'd32-{1'b0,reg1_i[4:0]})) | (reg2_i >> reg1_i[4:0]);
            end
            default:        shiftres = `ZeroWord;
          endcase
        end
    end

    //如果是MTHI、MTLO指令，则需给出whilo_o,hi_o,lo_o的值
    always @(*) begin
      if(rst == `RstEnable) begin
        whilo_o = `WriteDisable;
        hi_o = `ZeroWord;
        lo_o = `ZeroWord;
      end
      else if(aluop_i == `EXE_MTHI_OP) begin
        whilo_o = `WriteEnable;
        hi_o = reg1_i;
        lo_o = LO;        //写HI寄存器，所以LO保持不变
      end
      else if(aluop_i == `EXE_MTLO_OP) begin
        whilo_o = `WriteEnable;
        hi_o = HI;        //写LO寄存器，所以HI保持不变
        lo_o = reg1_i;        
      end
      else begin
        whilo_o = `WriteDisable;
        hi_o = `ZeroWord;
        lo_o = `ZeroWord;
      end
    end

    //根据alusel指示的运算类型，选择一个运算结果作为最终结果
    //此时只有逻辑运算结果
    always @(*) begin
        wd_o = wd_i;
        wreg_o = wreg_i;
        case(alusel_i)
            `EXE_RES_LOGIC:     wdata_o = logicout;
            `EXE_RES_SHIFT:     wdata_o = shiftres;
            `EXE_RES_MOVE:      wdata_o = moveres;
            default:            wdata_o = `ZeroWord;
        endcase
    end

endmodule