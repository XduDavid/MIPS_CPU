`include "defines.v"

module openmips(
    input wire                  clk,
    input wire                  rst,
    
    input wire[`InstBus]        rom_data_i,
    output wire[`InstAddrBus]   rom_addr_o,
    output wire                 rom_ce_o
);

    //连接IF/ID模块与译码阶段ID模块的变量
    wire[`InstBus]  id_inst_i;
    //连接译码阶段ID模块与通用寄存器Regfile模块的变量
    wire reg1_read;
    wire reg2_read;
    wire [`RegBus] reg1_data;
    wire [`RegBus] reg2_data;
    wire [`RegAddrBus] reg1_addr;
    wire [`RegAddrBus] reg2_addr;
    //连接译码阶段ID模块输出与ID/EX模块的输入的变量
    wire [`AluOpBus] id_aluop_o;
    wire [`AluSelBus] id_alusel_o;
    wire [`RegBus] id_reg1_o;
    wire [`RegBus] id_reg2_o;
    wire id_wreg_o;
    wire [`RegAddrBus] id_wd_o;
    //连接ID/EX模块输出与执行阶段EX模块输入的变量
    wire [`AluOpBus] ex_aluop_i;
    wire [`AluSelBus] ex_alusel_i;
    wire [`RegBus] ex_reg1_i;
    wire [`RegBus] ex_reg2_i;
    wire [`RegAddrBus] ex_wd_i;
    wire ex_wreg_i;
    //连接执行阶段EX模块输出与EX/MEM模块的输入的变量
    wire [`RegBus] ex_wdata_o;
    wire [`RegAddrBus] ex_wd_o;
    wire ex_wreg_o;
    //连接EX/MEM模块输出与访存MEM模块输入的变量
    wire [`RegBus] mem_wdata_i;
    wire [`RegAddrBus] mem_wd_i;
    wire mem_wreg_i;
    //连接MEM模块输出与MEM/WB模块输入的变量
    wire [`RegBus] mem_wdata_o;
    wire [`RegAddrBus] mem_wd_o;
    wire mem_wreg_o;
    //连接MEM/WB模块输出与寄存器堆模块输入的变量
    wire [`RegBus] wb_wdata_o;
    wire [`RegAddrBus] wb_wd_o;
    wire wb_wreg_o;

    //pc_reg例化
    pc_reg pc_reg0(
    .clk(clk),    .rst(rst),    .pc(rom_addr_o),    .ce(rom_ce_o)
    );
    
    //IF/ID模块例化
    if_id if_id0(
    .rst(rst),    .clk(clk),    .if_inst(rom_data_i),    .id_inst(id_inst_i)
    );

    //译码阶段ID模块例化
    id id0(
    .rst(rst),    .inst_i(id_inst_i),

    .reg1_data_i(reg1_data),    .reg2_data_i(reg2_data),

    .reg1_read_o(reg1_read),    .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr),    .reg2_addr_o(reg2_addr),

    .alusel_o(id_alusel_o),    .aluop_o(id_aluop_o),
    .reg1_o(id_reg1_o),    .reg2_o(id_reg2_o),
    .wd_o(id_wd_o),    .wreg_o(id_wreg_o),

    .ex_wreg_i(ex_wd_o),    .ex_wdata_i(ex_wdata_o),    .ex_wd_i(ex_wd_o),

    .mem_wreg_i(mem_wreg_o),    .mem_wdata_i(mem_wdata_o),    .mem_wd_i(mem_wd_o)      
    );

    //通用寄存器Regfile模块例化
    regfile regfile0(
    .clk(clk),    .rst(rst),

    .we(wb_wreg_o),    .waddr(wb_wd_o),    .wdata(wb_wdata_o),

    .re1(reg1_read),    .raddr1(reg1_addr),    .rdata1(reg1_data),

    .re2(reg2_read),    .raddr2(reg2_addr),    .rdata2(reg2_data)
    );

    //ID/EX模块例化
    id_ex id_ex0(
    .clk(clk),    .rst(rst),

    .id_alusel(id_alusel_o),    .id_aluop(id_aluop_o),
    .id_reg1(id_reg1_o),    .id_reg2(id_reg2_o),
    .id_wd(id_wd_o),      .id_wreg(id_wreg_o),

    .ex_alusel(ex_alusel_i),    .ex_aluop(ex_aluop_i),
    .ex_reg1(ex_reg1_i),    .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i),    .ex_wreg(ex_wreg_i)
    );

    //EX模块例化
    ex ex0(
    .rst(rst),

    .alusel_i(ex_alusel_i),    .aluop_i(ex_aluop_i),
    .reg1_i(ex_reg1_i),    .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i),    .wreg_i(ex_wreg_i),

    .wd_o(ex_wd_o),    .wreg_o(ex_wreg_o),    .wdata_o(ex_wdata_o)
    );

    //EX/MEM模块例化
    ex_mem ex_mem0(
    .clk(clk),    .rst(rst),

    .ex_wd(ex_wd_o),    .ex_wreg(ex_wreg_o),    .ex_wdata(ex_wdata_o),

    .mem_wd(mem_wd_i),    .mem_wreg(mem_wreg_i),    .mem_wdata(mem_wdata_i)
    );

    //MEM模块例化
    mem mem0(
    .rst(rst),

    .wd_i(mem_wd_i),    .wreg_i(mem_wreg_i),    .wdata_i(mem_wdata_i),

    .wd_o(mem_wd_o),    .wreg_o(mem_wreg_o),    .wdata_o(mem_wdata_o)
    );

    //MEM/WB模块例化
    mem_wb mem_wb0(
    .clk(clk),    .rst(rst),

    .mem_wd(mem_wd_o),    .mem_wreg(mem_wreg_o),    .mem_wdata(mem_wdata_o),

    .wb_wd(wb_wd_o),    .wb_wreg(wb_wreg_o),    .wb_wdata(wb_wdata_o)
    );

endmodule