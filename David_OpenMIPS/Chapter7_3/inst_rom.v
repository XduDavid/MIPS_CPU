`include "defines.v"

module inst_rom(
    input wire                  ce,
    input wire[`InstAddrBus]    addr,
    output reg[`InstBus]        inst
);

    //定义一个数组，大小是InstMemNum，元素宽度是InstBus
    reg [`InstBus] inst_mem[0:`InstMemNum-1];

    //使用文件inst_rom.data初始化寄存器
    initial $readmemh ("C:/Users/David/Desktop/Chapter7_3/rtl/inst_rom.data",inst_mem);

    //当复位信号无效时，依据输入的地址，给出指令存储器ROM中对应的元素
    always @(*) begin
        if(ce == `ChipDisable) begin
            inst <= `ZeroWord;
        end
        else begin
            //指令寄存器的每个地址是32bit的字，所以要将OpenMips给出的指令地址除以4再使用
            inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
        end
    end

endmodule