`timescale 1ns / 1ps

module Controller(
    input wire [5:0] Op,Funct,
    input wire zero,
    output wire jump,alusrc,memwrite,memtoreg,regwrite,regdst,pcsrc,
    output wire [2:0] Alucontrol
    );

    wire [1:0] Aluop;
    wire branch;

    main_decoder main_decoder_u0(
    .inst(Op),
    .jump(jump),
    .branch(branch),
    .alusrc(alusrc),
    .memwrite(memwrite),
    .memtoreg(memtoreg),
    .regwrite(regwrite),
    .regdst(regdst),
    .Aluop(Aluop)
    );

    Alu_control Alu_control_u0(
    .inst(Funct),
    .Aluop(Aluop),
    .Alucontrol(Alucontrol)
    );

    assign pcsrc = branch & zero;

endmodule
