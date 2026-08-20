`timescale 1ns/1ps
module ADD_SUB_A_B(
	input logic [63:0] A, B,
	input logic isSUB,
	output logic [63:0] result,
	output logic zero, negative, carry, overflow
);
	logic [63:0] couts;
	logic B_xor_isSUB_0;
	
	logic B_xor_isSUB_63;
	
	xor #50 B_xor0(B_xor_isSUB_0, isSUB, B[0]);
	xor #50 B_xor63(B_xor_isSUB_63, isSUB, B[63]);
	
	
	//assign B_xor_isSUB_0 = (isSUB & ~B[0]) | (~isSUB & B[0]);
	//assign B_xor_isSUB_63 = (isSUB & ~B[63]) | (~isSUB & B[63]);

	FullAdd Add_0(.A(A[0]), .B(B_xor_isSUB_0), .Cin(isSUB), .Sum(result[0]), .Cout(couts[0]));

	generate 
		genvar i;
		for(i = 1; i < 63; i = i + 1)begin : loop 
			logic B_xor_isSUB_i;
			xor #50 asd(B_xor_isSUB_i, isSUB, B[i]);
		
			FullAdd Add_1_63(.A(A[i]), .B(B_xor_isSUB_i), .Cin(couts[i-1]), .Sum(result[i]), .Cout(couts[i]));
		end
	endgenerate
	
	

	
	FullAdd Add_63(.A(A[63]), .B(B_xor_isSUB_63), .Cin(couts[62]), .Sum(result[63]), .Cout(couts[63]));
	 
	 
	and #50 carried(carry, 1'b1, couts[63]);
	xor #50 overflowed(overflow, couts[63], couts[62]); 
	and #50 negatived(negative, 1'b1, result[63]);
	
	//assign carry = couts[63];
	//assign overflow = (couts[63] & ~couts[62]) | (~couts[63] & couts[62]);
	//assign negative = result[63];			 //negative case
	isZero test(.in(result), .out(zero));//zero case
	
endmodule




















module ADD_SUB_A_B_tb();
	
	parameter delay = 100000;
	logic 				clk, isSUB;
	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out; 

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	ADD_SUB_A_B asdasdasd (.A, .B, .isSUB, .result, .zero, .negative, .carry(carry_out), .overflow);

	
	// Clock setup
	parameter clock_period = 200000;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 
	

	initial begin
		
	
		
		A = ~64'd1+1;//overflow
		B = 64'd1;
		isSUB = 1;
		@(posedge clk);
		
		A = ~64'd1+1;
		B = 64'd1;
		isSUB = 0;
		@(posedge clk);
		
		A = ~64'd1+1;
		B = 64'd1123;
		isSUB = 0;
		@(posedge clk);
		
		A = 64'd143;
		B = 64'd130;
		isSUB = 1;
		@(posedge clk);
		
		A = 64'd112343;
		B = 64'd132340;
		isSUB = 1;
		@(posedge clk);
		$stop;
		
	end
endmodule