`timescale 1ns/1ps
module Bit_a_and_b(
	input logic [63:0] A, B,
	output logic [63:0] result,
	output logic zero, negative
);

	generate 
		genvar i;
		for(i = 0; i < 64; i = i + 1)begin : loop
			
			and #50 andgate(result[i], A[i], B[i]);
		end
	endgenerate
	
	and #50 negativeoutput(negative, result[63], 1'b1);
	//assign negative = result[63];			 //negative case
	isZero test(.in(result), .out(zero));//zero case
	
endmodule

module Bit_a_and_b_tb();
	
	parameter delay = 100000;
	logic 				clk;
	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out; 

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	Bit_a_and_b asd (.A, .B, .result, .zero, .negative);

	
	// Clock setup
	parameter clock_period = 200000;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 
	

	initial begin
		
	
		
		A = ~64'd1+1;
		B = 64'd0;
		
		@(posedge clk);
		
		A = ~64'd1+1;
		B = 64'd1123;
		
		@(posedge clk);
		
		A = 64'd143;
		B = 64'd130;
		
		@(posedge clk);
		$stop;
		
	end
endmodule