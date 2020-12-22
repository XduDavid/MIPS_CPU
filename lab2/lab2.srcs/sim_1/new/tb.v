`timescale 1ns / 1ps

module tb();

    reg rst;
	reg clk;
	wire [5:0] ans;
	wire [6:0] seg;
	wire [9:0] control_sig;
	initial
	begin 
		clk = 1'b0;
		rst = 1'b0;
		#500;
		rst = 1'b1;
	end
	always #20 clk = ~clk;
	top top(
		.clk(clk),
        .reset_n(rst),
        .control_sig(control_sig),
        .seg(seg),
        .ans(ans)
		);
endmodule
