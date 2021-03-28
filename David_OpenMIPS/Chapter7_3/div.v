`include "defines.v"

module div(
    input wire rst,
    input wire clk,
    input wire signed_div_i,     
    input wire [31:0] opdata1_i,  
    input wire [31:0] opdata2_i,  
    input wire start_i,           
    input wire annul_i,           
    output reg [63:0] result_o,   
    output reg ready_o            
);

    parameter DivFree = 2'b00;
    parameter DivByZero = 2'b01;
    parameter DivOn = 2'b10;
    parameter DivEnd = 2'b11;
    reg [1:0] current_state,next_state;

    reg [5:0] cnt;

    reg [31:0] temp_op1,temp_op2;

    reg [64:0] dividend;
    reg [31:0] divisor;
    wire [32:0] div_temp;

    assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
            current_state <= DivFree;
        end
        else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case(current_state)
            DivFree:begin
                if((start_i == `DivStart) && (annul_i == 1'b0) && (opdata2_i == `ZeroWord)) begin
                    next_state = DivByZero;
                end
                else if((start_i == `DivStart) && (annul_i == 1'b0) && (opdata2_i != `ZeroWord)) begin
                    next_state = DivOn;
                end
                else begin
                    next_state = DivFree;
                end
            end
            DivOn:begin
                if(annul_i == 1'b1) begin
                    next_state = DivFree;
                end
                else begin
                    if(cnt == 32'd32) begin
                        next_state = DivEnd;
                    end
                    else begin
                        next_state = DivOn;
                    end
                end
            end
            DivByZero:begin
                next_state = DivEnd;
            end
            DivEnd:begin
                if(start_i == `DivStart) begin
                    next_state = DivEnd;
                end
                else begin
                    next_state = DivFree;
                end
            end
            default:begin
                next_state = DivFree;
            end
        endcase
    end

    always @(*) begin
        if(next_state == DivOn) begin
            if(cnt == 6'd0) begin
                if((signed_div_i == 1'b1) && (opdata1_i[31] == 1'b1)) begin
                    temp_op1 = ~opdata1_i + 1'b1;
                end
                else begin
                    temp_op1 = opdata1_i;
                end
                if((signed_div_i == 1'b1) && (opdata2_i[31] == 1'b1)) begin
                    temp_op2 = ~opdata2_i + 1'b1;
                end
                else begin
                    temp_op2 = opdata2_i;
                end
                dividend = {`ZeroWord,temp_op1,1'b0};
                divisor = temp_op2;
            end
            else begin
                temp_op1 = `ZeroWord;
                temp_op2 = `ZeroWord;
            end
        end
        else begin
            temp_op1 = `ZeroWord;
            temp_op2 = `ZeroWord;
        end
    end

    always @(posedge clk) begin
        case(next_state)
            DivFree:begin
                cnt <= 6'd0;
                dividend <= 65'd0;
                divisor <= 32'd0;
                temp_op1 <= 32'd0;
                temp_op2 <= 32'd0;
                result_o <= {`ZeroWord,`ZeroWord};
                ready_o <= `DivResultNotReady;
            end
            DivOn:begin
                cnt <= cnt + 1'd1;
                    if(div_temp[32] == 1'b0) begin
                        dividend <= {div_temp[31:0],dividend[31:0],1'b1};
                    end
                    else begin
                        dividend <= {dividend[63:0],1'b0};
                    end 
                end
            DivByZero:begin
                dividend <= 65'd0;
            end
            DivEnd:begin
                if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ opdata2_i[31]) == 1'b1)) begin
                    result_o[31:0] <= {~dividend[31:0] + 1'b1};
                end
                else begin
                    result_o[31:0] <= dividend[31:0];
                end
                if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ dividend[64]) == 1'b1)) begin
                    result_o[63:32] <= {~dividend[64:33] + 1'b1};
                end
                else begin
                    result_o[63:32] <= dividend[64:33];
                end
                ready_o <= `DivResultReady;
            end
        endcase
    end    

endmodule