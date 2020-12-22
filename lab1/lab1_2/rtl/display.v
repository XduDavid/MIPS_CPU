`timescale 1ns / 1ps

module display(
    input wire clk,reset,
    input wire [31:0]s,
    output wire [6:0]seg,
    output reg [5:0]ans
    );
    reg [17:0]count;
    reg [4:0]digit; 
    always@(posedge clk) begin
        if(~reset)  
            count = 0;
        else 
            count = count + 1;
    end
    
       
    always @(posedge clk)
    case(count[17:15])
        0:begin
            ans = 6'b111110;
            digit = s[3:0];
        end
        
        1:begin
            ans = 6'b111101;
            digit = s[7:4];
        end

        2:begin
            ans = 6'b111011;
            digit =s[11:8];
        end
        
        3:begin
            ans = 6'b110111;
            digit = s[15:12];
        end
        
        4:begin
            ans = 6'b101111;
            digit = s[19:16];
        end
            
        5:begin
            ans = 6'b011111;
            digit = s[23:20];
        end
    
        6:begin
            ans = 6'b111111;
            digit = s[27:24];
        end

        7:begin
            ans = 6'b111111;
            digit = s[31:28];
        end
    endcase
    
    seg7 U4(.din(digit),.dout(seg));
endmodule