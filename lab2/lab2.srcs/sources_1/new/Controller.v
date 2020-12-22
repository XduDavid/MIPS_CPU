`timescale 1ns / 1ps

module Controller(
    input wire [31:0] inst,
    output wire jump,branch,alusrc,memwrite,memtoreg,regwrite,regdst,
    output wire [2:0] Alucontrol
    );

    wire [1:0] Aluop;

    main_decoder main_decoder_u0(
    .inst(inst[31:26]),
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
    .inst(inst[5:0]),
    .Aluop(Aluop),
    .Alucontrol(Alucontrol)
    );

endmodule
