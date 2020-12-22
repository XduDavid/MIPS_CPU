`timescale 1ns / 1ps

module top(
    input wire clk,rst,
    output wire[31:0] writedata,dataadr,
	output wire memwrite
    );

    wire [31:0] pc;
    wire [31:0] instr,readdata;

    mips mips_u0(
    .clk(clk),
    .rst(rst),
    .instr(instr),
    .memwrite(memwrite),
    .pc(pc),
    .aluout(dataadr),
    .writedata(writedata),
    .readdata(readdata)
    );

    blk_mem_gen_0 data_memory(
    .clka(~clk),    // input wire clka
    .wea({4{memwrite}}),      // input wire [3 : 0] wea
    .addra(dataadr),  // input wire [31 : 0] addra
    .dina(writedata),    // input wire [31 : 0] dina
    .douta(readdata)  // output wire [31 : 0] douta
    );

    inst_mem inst_mem(
    .clka(clk),    // input wire clka
    .addra(pc),  // input wire [31 : 0] addra
    .douta(instr)  // output wire [31 : 0] douta
    );


endmodule
