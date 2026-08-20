`timescale 1ns/1ps
module B_Test(
	input logic [63:0] B,
	output logic [63:0] result,
	output logic zero, negative
);

	 
	 
	
	
	isZero test(.in(B), .out(zero));
	assign negative = B[63];
	assign result = B;

endmodule

module B_Test_tb();
	
	parameter delay = 100000;
	logic 				clk;
	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out; 

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	B_Test assd (.B, .result, .zero, .negative);

	
	// Clock setup
	parameter clock_period = 200000;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 
	

	initial begin
		
	
		
		
		B = 64'd0;
		
		@(posedge clk);
		
		
		B = ~64'd1123+1;
		
		@(posedge clk);
		
		
		B = 64'd130;
		
		@(posedge clk);
		$stop;
		
	end
endmodule