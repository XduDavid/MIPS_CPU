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
    input wire[`RegBus]     inst_i,//当前处于执行阶段的指令

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
    //乘累加、乘累减需添加的接口
    input wire [`DoubleRegBus] hilo_temp_i, //第一个执行周期得到的乘法结果
    input wire [1:0] cnt_i,         //当前处于执行阶段的第几个时钟周期
    output reg [`DoubleRegBus] hilo_temp_o, //第一个执行周期得到的乘法结果
    output reg [1:0] cnt_o,         //下一个时钟周期处于执行阶段的第几个时钟周期
    
    //HI/LO的输出
    output reg whilo_o,
    output reg [31:0] hi_o,lo_o,     //执行阶段的指令要写入HI/LO寄存器的值

    output reg stallreq,

    //除法模块新增的接口
    output reg signed_div_o,        //是否为有符号除法，为1表示是有符号除法
    output reg [31:0] div_opdata1_o,//被除数
    output reg [31:0] div_opdata2_o,//除数
    output reg div_start_o,         //是否开始除法运算
    input wire [63:0] div_result_i, //除法运算结果
    input wire div_ready_i,         //除法运算是否结束
    
    //加载、存储指令所需的输出接口
    output wire[`AluOpBus]  aluop_o,
    output wire[`RegBus]    mem_addr_o,
    output wire[`RegBus]    reg2_o,

    //处于执行阶段的转移指令要保存的返回地址
    input wire [`RegBus] link_address_i,
    //当前执行阶段的指令是否位于延迟槽
    input wire is_in_delayslot_i
);

    //保存逻辑运算的结果
    reg [`RegBus] logicout;
    //保存移位运算的结果
    reg [`RegBus] shiftres;
    //移动操作的结果
    reg [`RegBus] moveres;

    //保存HI/LO寄存器的最新值
    reg [`RegBus] HI,LO;

    //算术运算所需的变量
    reg[`RegBus] arithmeticres; //保存算术运算结果
    wire ov_sum;				//保存溢出情况
    wire reg1_eq_reg2;			//第一个操作数是否等于第二个操作数
    wire reg1_lt_reg2;			//第一个操作数是否小于第二个操作数
    wire[`RegBus] reg2_i_mux;	//保存输入的第二个操作reg2_i的补码
    wire[`RegBus] reg1_i_not;	//保存输入的第一个操作数reg1_i取反后的值
    wire[`RegBus] result_sum;	//保存加法结果
    wire[`RegBus] opdata1_mult;	//乘法操作中的被乘数
    wire[`RegBus] opdata2_mult;	//乘法操作中的乘数
    wire[`DoubleRegBus] hilo_temp;	//临时保存乘法结果，宽度为64位
    reg[`DoubleRegBus] hilo_temp1;
    reg stallreq_for_madd_msub;    //是否由于乘累加、乘累减导致流水线暂停
    reg stallreq_for_div;         //是否由于除法运算导致流水线暂停
    reg[`DoubleRegBus] mulres;		//保存乘法结果，宽度为64位

//计算算术运算相关变量的值
    //如果为减法或有符号比较运算，则reg2应取补码形式，否则取原码
    assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) ||
                         (aluop_i == `EXE_SLT_OP)) ? (~reg2_i) + 1'b1 : reg2_i;
    //如果是加法运算，则reg2_i_mux=reg2_i，所以result_sum就是加法的结果
    //如果是减法运算，则reg2_i_mux是reg2_i的补码，所以result_sum就是减法的结果
    //如果是有符号比较运算，result_sum就是减法的结果，可由该结果进一步进行大小的判断
    assign result_sum = reg1_i + reg2_i_mux;
    //加减法指令执行时，需判断结果是否溢出，两正数相加为负数，两负数相加为正数时均存在溢出
    assign ov_sum = ((reg1_i[31] && reg2_i_mux[31] && (~result_sum[31]))) ||
                    (((~reg1_i[31] && ~reg2_i_mux[31]) && result_sum[31]));
    //比较操作数1是否小于操作数2需分有符号比较和无符号比较两种方式
    assign reg1_lt_reg2 = (aluop_i == `EXE_SLT_OP) ? ((reg1_i[31] && ~reg2_i[31]) ||
                          (~reg1_i[31] && ~reg2_i[31] && result_sum[31]) || 
                          (reg1_i[31] && reg2_i[31] && result_sum[31])): (reg1_i < reg2_i);
    //对reg_1逐位取反，赋给reg1_i_not
    assign reg1_i_not = ~reg1_i;
    //乘数1：若为有符号乘法且该乘数为负数，则取其补码，否则不变
    assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP) || 
                            (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP))
                          && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1'b1) : reg1_i;
    //乘数2：若为有符号乘法且该乘数为负数，则取其补码，否则不变
    assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP) ||
                            (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP))
                          && (reg2_i[31] == 1'b1)) ? (~reg2_i + 1'b1) : reg2_i;
    //得到临时的乘法结果，保存到hilo_temp中
    assign hilo_temp = opdata1_mult * opdata2_mult;
    //aluop_o会传递到访存阶段，届时将利用其确定加载、存储类型
    assign aluop_o = aluop_i;
    //mem_addr_o会传递到访存阶段，是加载、存储指令对应的存储器地址
    assign mem_addr_o = reg1_i + {{16{inst_i[15]}},inst_i[15:0]};
    //reg2_i是存储指令要存储的数据，或lwl、lwr指令要加载到目的寄存器的原始值
    //将该值通过reg2_o接口传递到访存阶段
    assign reg2_o = reg2_i;


    //对临时乘法结果进行修正，将最终结果放入mulres中
    always @(*) begin
        if(rst == `RstEnable) begin
            mulres = {`ZeroWord,`ZeroWord};
        end
        else if((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP) ||
                (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) begin
            if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin
                mulres = ~hilo_temp + 1'b1;
            end
            else begin
                mulres = hilo_temp;
            end
        end
        else begin
            mulres = hilo_temp;
        end
    end
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
**                乘累加、乘累减运算                  **
****************************************************/
    always @(*) begin
      if(rst == `RstEnable) begin
          hilo_temp_o = {`ZeroWord,`ZeroWord};
          cnt_o = 2'b00;
          stallreq_for_madd_msub = `NoStop;
      end
      else begin
          case(aluop_i)
              `EXE_MADD_OP,`EXE_MADDU_OP:begin  //madd、maddu指令
                if(cnt_i == 2'b00) begin        //执行阶段第一个周期
                    hilo_temp_o = mulres;
                    cnt_o = 2'b01;
                    hilo_temp1 = {`ZeroWord,`ZeroWord};
                    stallreq_for_madd_msub = `Stop;
                end
                else if(cnt_i == 2'b01) begin   //执行阶段第二个周期
                    hilo_temp_o = {`ZeroWord,`ZeroWord};
                    cnt_o = 2'b10;
                    hilo_temp1 = hilo_temp_i + {HI,LO};
                    stallreq_for_madd_msub = `NoStop;
                end
              end
              `EXE_MSUB_OP,`EXE_MSUBU_OP:begin  //msub、msubu指令
                if(cnt_i == 2'b00) begin
                  hilo_temp_o = ~mulres + 1'b1; //直接取补码存储
                  cnt_o = 2'b01;
                  hilo_temp1 = {`ZeroWord,`ZeroWord};
                  stallreq_for_madd_msub = `Stop;
                end
                else if(cnt_i == 2'b01) begin
                  hilo_temp_o = {`ZeroWord,`ZeroWord};
                  cnt_o = 2'b10;
                  hilo_temp1 = hilo_temp_i + {HI,LO};
                  stallreq_for_madd_msub = `NoStop;
                end
              end
              default:begin
                  hilo_temp_o = {`ZeroWord,`ZeroWord};
                  cnt_o = 2'b00;
                  stallreq_for_madd_msub = `NoStop;
              end
          endcase
      end
    end

/****************************************************
**                    除法运算                      **
****************************************************/
    always @(*) begin
        if(rst == `RstEnable) begin
            stallreq_for_div = `NoStop;
            div_opdata1_o = `ZeroWord;
            div_opdata2_o = `ZeroWord;
            div_start_o = `DivStop;
            signed_div_o = 1'b0;
        end
        else begin
            case(aluop_i)
                `EXE_DIV_OP:begin
                    stallreq_for_div = div_ready_i ? `NoStop : `Stop;
                    div_opdata1_o = reg1_i;
                    div_opdata2_o = reg2_i;
                    div_start_o = div_ready_i ? `DivStop : `DivStart;
                    signed_div_o = 1'b1;
                end
                `EXE_DIVU_OP:begin
                    stallreq_for_div = div_ready_i ? `NoStop : `Stop;
                    div_opdata1_o = reg1_i;
                    div_opdata2_o = reg2_i;
                    div_start_o = div_ready_i ? `DivStop : `DivStart;
                    signed_div_o = 1'b0;
                end
            endcase
        end
    end

/****************************************************
**                     暂停流水线                    **
****************************************************/
    //目前只有乘累加、乘累减指令会导致流水线暂停
    //所以stallreq就直接等于stallreq_for_madd_msub的值
    always @(*) begin
      stallreq = stallreq_for_madd_msub || stallreq_for_div;
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

    //进行算术运算
    always @(*) begin
        if(rst == `RstEnable) begin
            arithmeticres = `ZeroWord;
        end
        else begin
            case(aluop_i)
                `EXE_SLT_OP,`EXE_SLTU_OP:begin        //比较运算
                    arithmeticres = reg1_lt_reg2;
                end
                `EXE_ADD_OP,`EXE_ADDU_OP,`EXE_ADDI_OP,`EXE_ADDIU_OP:begin //加法运算
                    arithmeticres = result_sum;
                end
                `EXE_SUB_OP,`EXE_SUBU_OP:begin        //减法运算
                    arithmeticres = result_sum;
                end
                `EXE_CLZ_OP:begin
                    arithmeticres = reg1_i[31] ? 0 : reg1_i[30] ? 1 : reg1_i[29] ? 2 :
													 reg1_i[28] ? 3 : reg1_i[27] ? 4 : reg1_i[26] ? 5 :
													 reg1_i[25] ? 6 : reg1_i[24] ? 7 : reg1_i[23] ? 8 : 
													 reg1_i[22] ? 9 : reg1_i[21] ? 10 : reg1_i[20] ? 11 :
													 reg1_i[19] ? 12 : reg1_i[18] ? 13 : reg1_i[17] ? 14 : 
													 reg1_i[16] ? 15 : reg1_i[15] ? 16 : reg1_i[14] ? 17 : 
													 reg1_i[13] ? 18 : reg1_i[12] ? 19 : reg1_i[11] ? 20 :
													 reg1_i[10] ? 21 : reg1_i[9] ? 22 : reg1_i[8] ? 23 : 
													 reg1_i[7] ? 24 : reg1_i[6] ? 25 : reg1_i[5] ? 26 : 
													 reg1_i[4] ? 27 : reg1_i[3] ? 28 : reg1_i[2] ? 29 : 
													 reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32 ;
                end
                `EXE_CLO_OP:begin
                    arithmeticres = reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 : reg1_i_not[29] ? 2 :
													 reg1_i_not[28] ? 3 : reg1_i_not[27] ? 4 : reg1_i_not[26] ? 5 :
													 reg1_i_not[25] ? 6 : reg1_i_not[24] ? 7 : reg1_i_not[23] ? 8 : 
													 reg1_i_not[22] ? 9 : reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 :
													 reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 : reg1_i_not[17] ? 14 : 
													 reg1_i_not[16] ? 15 : reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 : 
													 reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 : reg1_i_not[11] ? 20 :
													 reg1_i_not[10] ? 21 : reg1_i_not[9] ? 22 : reg1_i_not[8] ? 23 : 
													 reg1_i_not[7] ? 24 : reg1_i_not[6] ? 25 : reg1_i_not[5] ? 26 : 
													 reg1_i_not[4] ? 27 : reg1_i_not[3] ? 28 : reg1_i_not[2] ? 29 : 
													 reg1_i_not[1] ? 30 : reg1_i_not[0] ? 31 : 32 ;
                end
                default:begin
                    arithmeticres = `ZeroWord;
                end
            endcase
        end
    end

    //如果是MTHI、MTLO指令，则需给出whilo_o,hi_o,lo_o的值
    //乘累加和乘累减指令需修改HI、LO寄存器的写信息
    always @(*) begin
      if(rst == `RstEnable) begin
        whilo_o = `WriteDisable;
        hi_o = `ZeroWord;
        lo_o = `ZeroWord;
      end
      else if((aluop_i == `EXE_MSUB_OP)||(aluop_i == `EXE_MSUBU_OP)
            ||(aluop_i == `EXE_MADD_OP)||(aluop_i == `EXE_MADDU_OP)) begin
        whilo_o = `WriteEnable;
        hi_o = hilo_temp1[63:32];
        lo_o = hilo_temp1[31:0];        
      end
      else if((aluop_i == `EXE_MULT_OP)||(aluop_i == `EXE_MULTU_OP)) begin
        whilo_o = `WriteEnable;
        hi_o = mulres[63:32];
        lo_o = mulres[31:0];
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
      else if((aluop_i == `EXE_DIV_OP) || (aluop_i == `EXE_DIVU_OP)) begin
        whilo_o = `WriteEnable;
        hi_o = div_result_i[63:32];
        lo_o = div_result_i[31:0];
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
          if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || 
            (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1))begin
              wreg_o = `WriteDisable;
          end
          else begin
              wreg_o = wreg_i;
          end
        case(alusel_i)
            `EXE_RES_LOGIC:     wdata_o = logicout;
            `EXE_RES_SHIFT:     wdata_o = shiftres;
            `EXE_RES_MOVE:      wdata_o = moveres;
            `EXE_RES_ARITHMETIC:wdata_o = arithmeticres;
            `EXE_RES_MUL:       wdata_o = mulres[31:0];
            `EXE_RES_JUMP_BRANCH:begin
                wdata_o <= link_address_i;
            end
            default:            wdata_o = `ZeroWord;
        endcase
    end

endmodule