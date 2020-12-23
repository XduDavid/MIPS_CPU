`timescale 1ns / 1ps

module Alu_control(
    input wire [5:0] inst,
    input wire [1:0] Aluop,
    output reg [2:0] Alucontrol
    );

    always @(*) begin
        case(Aluop)
            2'b00: Alucontrol <= 3'b010;
            2'b01: Alucontrol <= 3'b110;
            default: begin
                case(inst)
                    6'b100000: Alucontrol <= 3'b010;
                    6'b100010: Alucontrol <= 3'b110;
                    6'b100100: Alucontrol <= 3'b000;
                    6'b100101: Alucontrol <= 3'b001;
                    6'b101010: Alucontrol <= 3'b111;
                    default:   Alucontrol <= 3'b000;
                endcase
            end
        endcase
    end

endmodule
