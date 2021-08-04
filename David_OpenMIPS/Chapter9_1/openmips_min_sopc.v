`include "defines.v"

module openmips_min_sopc(
    input wire clk,
    input wire rst
);

    //连接指令寄存器
    wire [`InstAddrBus] inst_addr;
    wire [`InstBus] inst;
    wire rom_ce;

    //连接RAM
    wire ram_ce_in;
    wire ram_we_in;
    wire[`DataAddrBus] ram_addr_in;
    wire[3:0] ram_sel_in;
    wire[`DataBus] ram_data_i;
    wire[`DataBus] ram_data_o;

    //例化处理器OpenMips
    openmips openmips0(
        .clk(clk),  .rst(rst),
        .rom_data_i(inst),        .rom_addr_o(inst_addr),
        .rom_ce_o(rom_ce),

        .ram_data_i(ram_data_o),  .ram_addr_o(ram_addr_in),
        .ram_data_o(ram_data_i),  .ram_we_o(ram_we_in),
        .ram_sel_o(ram_sel_in),   .ram_ce_o(ram_ce_in)
    );

    //例化指令存储器ROM
    inst_rom inst_rom0(
    .ce(rom_ce),
    .addr(inst_addr),    .inst(inst)
    );

    //例化RAM存储器
    data_ram data_ram0(
        .clk(clk),          .ce(ram_ce_in),
        .we(ram_we_in),     .addr(ram_addr_in),
        .sel(ram_sel_in),   .data_i(ram_data_i),
        .data_o(ram_data_o)
    );
endmodule