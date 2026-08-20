// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

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
	
	// result = A and B
	Bit_a_and_b a_and_b(.A(A), .B(B), .result(result_Arr[4]), .zero(zero_Arr[4]), .negative(negative_Arr[4]));
	
	// result = A or B
	BitAOrB a_or_b(.A(A), .B(B), .result(result_Arr[5]), .zero(zero_Arr[5]), .negative(negative_Arr[5]));
	
	// result = A XOR B
	Bit_a_xor_b a_xor_b(.A(A), .B(B), .result(result_Arr[6]), .zero(zero_Arr[6]), .negative(negative_Arr[6]));
	
	
	//assign values to the array to pass into the mux
	ConcatinateBits ALU_Arr0(.carry_out_Arr(1'b0), .overflow_Arr(1'b0), .zero_Arr(zero_Arr[0]), .negative_Arr(negative_Arr[0]), .result_Arr(result_Arr[0]), .result(ALU_Arr[0]));								 //0
	ConcatinateBits ALU_Arr2(.carry_out_Arr(carry_out_Arr[2]), .overflow_Arr(overflow_Arr[2]), .zero_Arr(zero_Arr[2]), .negative_Arr(negative_Arr[2]), .result_Arr(result_Arr[2]), .result(ALU_Arr[2]));//2
	ConcatinateBits ALU_Arr3(.carry_out_Arr(carry_out_Arr[3]), .overflow_Arr(overflow_Arr[3]), .zero_Arr(zero_Arr[3]), .negative_Arr(negative_Arr[3]), .result_Arr(result_Arr[3]), .result(ALU_Arr[3]));//3
	ConcatinateBits ALU_Arr4(.carry_out_Arr(1'b0), .overflow_Arr(1'b0), .zero_Arr(zero_Arr[4]), .negative_Arr(negative_Arr[4]), .result_Arr(result_Arr[4]), .result(ALU_Arr[4]));								 //4
	ConcatinateBits ALU_Arr5(.carry_out_Arr(1'b0), .overflow_Arr(1'b0), .zero_Arr(zero_Arr[5]), .negative_Arr(negative_Arr[5]), .result_Arr(result_Arr[5]), .result(ALU_Arr[5]));								 //5
	ConcatinateBits ALU_Arr6(.carry_out_Arr(1'b0), .overflow_Arr(1'b0), .zero_Arr(zero_Arr[6]), .negative_Arr(negative_Arr[6]), .result_Arr(result_Arr[6]), .result(ALU_Arr[6]));								 //6
	
	//assign dummy values to ports 1 and 7 since they r undefined
	ConcatinateBits ALU_Arr1(.carry_out_Arr(1'b0), .overflow_Arr(1'b0), .zero_Arr(1'b0), .negative_Arr(1'b0), .result_Arr(64'b0), .result(ALU_Arr[1]));																 //1
	ConcatinateBits ALU_Arr7(.carry_out_Arr(1'b0), .overflow_Arr(1'b0), .zero_Arr(1'b0), .negative_Arr(1'b0), .result_Arr(64'b0), .result(ALU_Arr[7]));																 //7
	
	/*
	assign ALU_Arr[0] = {2'b00, zero_Arr[0], negative_Arr[0], result_Arr[0]};//0
	assign ALU_Arr[2] = {carry_out_Arr[2], overflow_Arr[2], zero_Arr[2], negative_Arr[2], result_Arr[2]};//2
	assign ALU_Arr[3] = {carry_out_Arr[3], overflow_Arr[3], zero_Arr[3], negative_Arr[3], result_Arr[3]};//3
	assign ALU_Arr[4] = {2'b00, zero_Arr[4], negative_Arr[4], result_Arr[4]};//4
	assign ALU_Arr[5] = {2'b00, zero_Arr[5], negative_Arr[5], result_Arr[5]};//5
	assign ALU_Arr[6] = {2'b00, zero_Arr[6], negative_Arr[6], result_Arr[6]};//6
	*/

	//assign ALU_Arr[1] = 68'b0;//1
	//assign ALU_Arr[7] = 68'b0;//7
	
	
	
	//result 68 bit number as output from the 8 to 1 mux
	logic [67:0] ALU_result_Arr;
	Mux_8_1x64 mux(.in(ALU_Arr), .out(ALU_result_Arr), .selector(cntrl));
	
	//
	
	generate 
		genvar i;
		for(i = 0; i < 64; i = i + 1)begin : loop
			
			and #50 out(result[i], 1'b1, ALU_result_Arr[i]);
		end
	endgenerate
	 
	and #50 negative_(negative, ALU_result_Arr[64], 1'b1);
	and #50 zero_(zero, ALU_result_Arr[65], 1'b1);
	and #50 overflow_(overflow, ALU_result_Arr[66], 1'b1);
	and #50 carry_out_(carry_out, ALU_result_Arr[67], 1'b1);
	
	/*
	assign result = ALU_result_Arr[63:0];
	
	assign negative = ALU_result_Arr[64];
	assign zero = ALU_result_Arr[65];
	assign overflow = ALU_result_Arr[66];
	assign carry_out = ALU_result_Arr[67];
	*/
	
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
		
		A = 64'd123;
		B = 64'd1348886;
		cntrl = ALU_ADD;//A+B
		@(posedge clk);
		
		A = 64'd1;
		B = 64'd1;
		cntrl = ALU_SUBTRACT;//A-B
		@(posedge clk);
		
		A = 64'd10;
		B = 64'd2091;
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
