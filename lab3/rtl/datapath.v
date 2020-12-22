`timescale 1ns / 1ps

module datapath(
    input wire clk,rst,
	input wire memtoreg,pcsrc,
	input wire alusrc,regdst,
	input wire regwrite,jump,
	input wire[2:0] alucontrol,
	output wire overflow,zero,
	output wire[31:0] pc,
	input wire[31:0] instr,
	output wire[31:0] aluout,writedata,
	input wire[31:0] readdata
    );

    wire [31:0] pcplus,pcnext,pcbranch,pcnextbr;
    wire [31:0] signlmm,signimmsh;
    wire [4:0] writereg;
    wire [31:0] srca,srcb;
    wire [31:0] result;

    flopr #(32) pcreg(
    .clk(clk),
    .rst(rst),
	.d(pcnext),
	.q(pc)
    );

    adder pcplus4(
    .a(pc),
    .b(32'd4),
	.y(pcplus)
    );

    signext se(
    .a(instr[15:0]),
    .y(signlmm)
    );

    sl2 immsh(
    .a(signlmm),
    .b(signimmsh)
    );

    adder pcbra(
    .a(signimmsh),
    .b(pcplus),
	.y(pcbranch)
    );

    mux2 #(32) pcbrmux(
    .d0(pcplus),
    .d1(pcbranch),
	.s(pcsrc),
	.y(pcnextbr)
    );

    mux2 #(32) pcmux(
    .d0(pcnextbr),
    .d1({pcplus[31:28],instr[25:0],2'b00}),
	.s(jump),
	.y(pcnext)
    );

    mux2 #(5) wrmux(
    .d0(instr[20:16]),
    .d1(instr[15:11]),
	.s(regdst),
	.y(writereg)
    );

    regfile reg_file(
    .a1(instr[25:21]),
    .a2(instr[20:16]),
    .a3(writereg),
    .clk(~clk),
    .we3(regwrite),
    .wd3(result),
    .rd1(srca),
    .rd2(writedata)
    );

    mux2 #(32) srcbmux(
    .d0(writedata),
    .d1(signlmm),
	.s(alusrc),
	.y(srcb)
    );

    alu alu_u0(
    .a(srca),
    .b(srcb),
	.op(alucontrol),
	.y(aluout),
	.overflow(overflow),
	.zero(zero)
    );

    mux2 #(32) resmux(
    .d0(aluout),
    .d1(readdata),
	.s(memtoreg),
	.y(result)
    );

endmodule
