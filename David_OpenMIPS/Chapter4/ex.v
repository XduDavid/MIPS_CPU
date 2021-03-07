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
    output reg[`RegBus] wdata_o         //执行阶段最终要写入目的寄存器的值
);

    //保存逻辑运算的结果
    reg [`RegBus] logicout;

    //根据aluop指示的运算子类型进行运算，此处只有逻辑或运算
    always @(*) begin
        if(rst == `RstEnable) begin
          logicout = `ZeroWord;
        end
        else begin
            case(aluop_i)
                `EXE_OR_OP:  logicout = reg1_i | reg2_i;
                default:    logicout = `ZeroWord;
            endcase
        end  
    end

    //根据alusel指示的运算类型，选择一个运算结果作为最终结果
    //此时只有逻辑运算结果
    always @(*) begin
        wd_o = wd_i;
        wreg_o = wreg_i;
        case(alusel_i)
            `EXE_RES_LOGIC:     wdata_o = logicout;
            default:            wdata_o = `ZeroWord;
        endcase
    end

endmodule