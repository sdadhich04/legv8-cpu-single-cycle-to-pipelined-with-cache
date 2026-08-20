`timescale 1ns/1ps
module Bit_a_xor_b #(parameter WIDTH = 64)(
	input logic [WIDTH-1:0] A, B,
	output logic [WIDTH-1:0] result,
	output logic zero, negative	
);

	generate 
		genvar i;
		for(i = 0; i < WIDTH; i = i + 1)begin : loop
						
			xor #50 xorgate(result[i], A[i], B[i]);
			//assign result[i] = A[i] ^ B[i];
		end
	endgenerate
	
	and #50 negativeoutput(negative, result[WIDTH-1], 1'b1);
	isZero #(.WIDTH(WIDTH)) test(.in(result), .out(zero));//zero case
	
endmodule





























module Bit_a_xor_b_tb();
	
	parameter delay = 100000;
	logic 				clk;
	logic		[4:0]	A, B;

	logic		[4:0]	result;
	logic					negative, zero, overflow, carry_out ; 

	
	

	Bit_a_xor_b #(.WIDTH(5)) duasdasdt (.A, .B, .result, .zero, .negative);

	
	// Clock setup
	parameter clock_period = 200000;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 
	

	initial begin
		
	
		
	
		
		A = 5'd2;
		B = 5'd3;
		
		@(posedge clk);
		
		A = 5'd2;
		B = 5'd2;
		
		@(posedge clk);
		$stop;
		
	end
endmodule