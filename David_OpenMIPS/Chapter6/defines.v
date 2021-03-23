//全局宏定义
`define RstEnable 1'b1          //复位信号有效
`define RstDisable 1'b0         //复位信号无效
`define ChipEnable 1'b1         //芯片使能
`define ChipDisable 1'b0        //芯片禁止
`define ZeroWord 32'h00000000   //32位的数值0
`define WriteEnable 1'b1        //使能写
`define WriteDisable 1'b0       //禁止写
`define ReadEnable 1'b1         //使能读
`define ReadDisable 1'b0        //禁止读
`define AluSelBus 2:0           //译码阶段的输出alusel_o的宽度
`define AluOpBus 7:0            //译码阶段的输出aluop_o的宽度
`define InstValid 1'b1          //指令有效
`define InstInvalid 1'b0        //指令无效

//与指令存储器相关的定义
`define InstAddrBus     31:0    //ROM的地址总线宽度
`define InstBus     31:0        //ROM的数据总线宽度
`define InstMemNum 131071       //ROM的实际大小为128KB
`define InstMemNumLog2  17      //ROM实际使用的地址线宽度

//与通用寄存器Regfile有关的宏定义
`define RegAddrBus 4:0          //Regfile模块的地址线宽度
`define RegBus 31:0             //Regfile模块的数据线宽度
`define RegNum 32               //通用寄存器的数量
`define RegNumLog2 5            //寻址通用寄存器所用的地址位数
`define NOPRegAddr  5'b00000

//与具体指令相关的宏定义
`define EXE_AND     6'b100100   //and指令的功能码
`define EXE_OR      6'b100101   //or指令的功能码
`define EXE_XOR     6'b100110   //xor指令的功能码
`define EXE_NOR     6'b100111   //nor指令的功能码
`define EXE_ANDI    6'b001100   //andi指令的指令码
`define EXE_ORI     6'b001101   //ori指令的指令码
`define EXE_XORI    6'b001110   //xori指令的指令码
`define EXE_LUI     6'b001111   //lui指令的指令码
`define EXE_NOP     6'b000000

`define EXE_SLL     6'b000000   //sll指令的功能码
`define EXE_SLLV    6'b000100   //sllv指令的功能码
`define EXE_SRL     6'b000010   //srl指令的功能码
`define EXE_SRLV    6'b000110   //srlv指令的功能码
`define EXE_SRA     6'b000011   //sra指令的功能码
`define EXE_SRAV    6'b000111   //srav指令的功能码
// MOV EXE  
`define EXE_MOVZ    6'b001010
`define EXE_MOVN    6'b001011
`define EXE_MFHI    6'b010000
`define EXE_MTHI    6'b010001
`define EXE_MFLO    6'b010010
`define EXE_MTLO    6'b010011

`define EXE_SYNC    6'b001111   //sync指令的功能码
`define EXE_PREF    6'b110011   //pref指令的指令码
`define EXE_SPECIAL_INST    6'b000000   //SPECIAL类指令的指令码



//AluOp
`define EXE_AND_OP      8'b00100100
`define EXE_OR_OP       8'b00100101
`define EXE_XOR_OP      8'b00100110
`define EXE_NOR_OP      8'b00100111
`define EXE_ANDI_OP     8'b01011001
`define EXE_ORI_OP      8'b01011010
`define EXE_XORI_OP     8'b01011011
`define EXE_LUI_OP      8'b01011100   

`define EXE_SLL_OP      8'b01111100
`define EXE_SLLV_OP     8'b00000100
`define EXE_SRL_OP      8'b00000010
`define EXE_SRLV_OP     8'b00000110
`define EXE_SRA_OP      8'b00000011
`define EXE_SRAV_OP     8'b00000111

`define EXE_NOP_OP      8'b00000000
//MOVE OP
`define EXE_MOVZ_OP     8'b00001010
`define EXE_MOVN_OP     8'b00001011
`define EXE_MFHI_OP     8'b00010000
`define EXE_MTHI_OP     8'b00010001
`define EXE_MFLO_OP     8'b00010010
`define EXE_MTLO_OP     8'b00010011

//AluSel
`define EXE_RES_LOGIC   3'b001
`define EXE_RES_SHIFT   3'b010
`define EXE_RES_MOVE    3'b011
`define EXE_RES_NOP     3'b000