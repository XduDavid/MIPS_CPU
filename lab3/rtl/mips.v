`timescale 1ns / 1ps

module mips(
    input clk,rst,
    input wire [31:0] instr,
    output wire memwrite,
    output wire [31:0] pc,
    output wire [31:0] aluout,writedata,readdata
    );

    wire jump,alusrc,zero,memtoreg,regwrite,regdst,pcsrc,overflow;
    wire [2:0] Alucontrol;

    Controller cu(
    .Op(instr[31:26]),
    .Funct(instr[5:0]),
    .zero(zero),
    .jump(jump),
    .alusrc(alusrc),
    .memwrite(memwrite),
    .memtoreg(memtoreg),
    .regwrite(regwrite),
    .regdst(regdst),
    .pcsrc(pcsrc),
    .Alucontrol(Alucontrol)
    );

    datapath data_way(
    .clk(clk),
    .rst(rst),
	.memtoreg(memtoreg),
    .pcsrc(pcsrc),
	.alusrc(alusrc),
    .regdst(regdst),
	.regwrite(regwrite),
    .jump(jump),
	.alucontrol(Alucontrol),
	.overflow(overflow),
    .zero(zero),
	.pc(pc),
	.instr(instr),
	.aluout(aluout),
    .writedata(writedata),
	.readdata(readdata)
    );

endmodule
