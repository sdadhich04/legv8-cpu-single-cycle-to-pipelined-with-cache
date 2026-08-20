`timescale 1ns/1ps
module alu(
	input logic [63:0] A, B,
	input logic [2:0] cntrl,
	output logic [63:0] result,
	output logic negative, zero, overflow, carry_out
);

	//68 bits with the last four being 1 bit output "flags"
	//ALU_Arr[67]	carry_out
	//ALU_Arr[66]	overflow
	//ALU_Arr[65]	zero
	//ALU_Arr[64]	negative
	logic [67:0] ALU_Arr [0:7];
	
	logic [63:0] result_Arr [0:7];
	logic [7:0] negative_Arr;
	logic [7:0] zero_Arr;
	logic [7:0] overflow_Arr;
	logic [7:0] carry_out_Arr;
	
	
	// result = B
	B_Test testing_b(.B(B), .result(result_Arr[0]), .zero(zero_Arr[0]), .negative(negative_Arr[0]));
	
	// result = ADD & SUB
	ADD_SUB_A_B Add(.A(A), .B(B), .isSUB(cntrl[0]), .result(result_Arr[2]), .zero(zero_Arr[2]), .negative(negative_Arr[2]), .carry(carry_out_Arr[2]), .overflow(overflow_Arr[2]));
	ADD_SUB_A_B Sub(.A(A), .B(B), .isSUB(cntrl[0]), .result(result_Arr[3]), .zero(zero_Arr[3]), .negative(negative_Arr[3]), .carry(carry_out_Arr[3]), .overflow(overflow_Arr[3]));
	
	// result = A or B
	Bit_a_and_b a_and_b(.A(A), .B(B), .result(result_Arr[4]), .zero(zero_Arr[4]), .negative(negative_Arr[4]));
	
	// result = A and B
	Bit_a_or_b a_or_b(.A(A), .B(B), .result(result_Arr[5]), .zero(zero_Arr[5]), .negative(negative_Arr[5]));
	
	// result = A XOR B
	Bit_a_xor_b a_xor_b(.A(A), .B(B), .result(result_Arr[6]), .zero(zero_Arr[6]), .negative(negative_Arr[6]));
	
	
	//assign values to the array to pass into the mux
	assign ALU_Arr[0] = {2'b00, zero_Arr[0], negative_Arr[0], result_Arr[0]};//0
	assign ALU_Arr[2] = {carry_out_Arr[2], overflow_Arr[2], zero_Arr[2], negative_Arr[2], result_Arr[2]};//2
	assign ALU_Arr[3] = {carry_out_Arr[3], overflow_Arr[3], zero_Arr[3], negative_Arr[3], result_Arr[3]};//3
	assign ALU_Arr[4] = {2'b00, zero_Arr[4], negative_Arr[4], result_Arr[4]};//4
	assign ALU_Arr[5] = {2'b00, zero_Arr[5], negative_Arr[5], result_Arr[5]};//5
	assign ALU_Arr[6] = {2'b00, zero_Arr[6], negative_Arr[6], result_Arr[6]};//6
	//assign dummy values to ports 1 and 7 since they r undefined
	assign ALU_Arr[1] = 68'b0;//1
	assign ALU_Arr[7] = 68'b0;//7
	
	
	
	//result 68 bit number as output from the 8 to 1 mux
	logic [67:0] ALU_result_Arr;
	Mux_8_1x64 mux(.in(ALU_Arr), .out(ALU_result_Arr), .selector(cntrl));
	
	
	assign result = ALU_result_Arr[63:0];
	assign negative = ALU_result_Arr[64];
	assign zero = ALU_result_Arr[65];
	assign overflow = ALU_result_Arr[66];
	assign carry_out = ALU_result_Arr[67];
	
endmodule 


module alu_tb();
	
	parameter delay = 100000;
	logic 				clk;
	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ; 

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	
	// Clock setup
	parameter clock_period = 200000;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 



	initial begin
		
	
		A = 64'd1;
		B = 64'd1;
		cntrl = ALU_PASS_B;//B
		@(posedge clk);
		
		A = 64'd1;
		B = 64'd1;
		cntrl = ALU_ADD;//A+B
		@(posedge clk);
		
		A = 64'd1;
		B = 64'd1;
		cntrl = ALU_SUBTRACT;//A-B
		@(posedge clk);
		
		A = 64'd109;
		B = 64'd1231;
		cntrl = ALU_AND;//and
		@(posedge clk);
		
		A = 64'd123;
		B = 64'd1234351;
		cntrl = ALU_OR;//or
		@(posedge clk);
		
		A = 64'd1231;
		B = 64'd1234;
		cntrl = ALU_XOR;//xor
		@(posedge clk);
		
		$stop;
		
	end
endmodule
