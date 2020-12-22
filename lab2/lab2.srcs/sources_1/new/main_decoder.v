`timescale 1ns / 1ps

module main_decoder(
    input [5:0] inst,
    output wire jump,branch,alusrc,memwrite,memtoreg,regwrite,regdst,
    output wire [1:0] Aluop
    );

    reg [8:0] controls;
    assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,Aluop[1:0]} = controls;

    always @(*) begin
        case(inst)
            6'b000000: controls <= 9'b110000010; //R-type
            6'b100011: controls <= 9'b101001000; //lw
            6'b101011: controls <= 9'b001010000; //sw
            6'b000100: controls <= 9'b000100001; //beq
            6'b001000: controls <= 9'b101000000; //addi
            6'b000100: controls <= 9'b000000100; //jump
            default:   controls <= 9'b000000000; //illegal
        endcase
    end

endmodule
