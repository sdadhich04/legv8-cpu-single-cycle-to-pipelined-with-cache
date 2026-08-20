`timescale 1ns/1ps
module ProgramCounter(

input clk, UncondBr, BrTaken, reset,
input [31:0] instruction,

output [63:0] address

);

	logic [63:0] CondAddr19;
	logic [63:0] BrAddr26;
	
	//signal extened instructions CondAddr and BrAddr
	SignExtender #(.InputBits(19)) CondAddr(.in(instruction[23:5]), .out(CondAddr19)); //CondAddr
	SignExtender #(.InputBits(26)) BrAddr(.in(instruction[25:0]), .out(BrAddr26)); //BrAddr
	
	
	//UncondBranch Mux
	logic [63:0] BranchResult;
	Mux_2_1_64Bit UncondBranch(.in0(CondAddr19), .in1(BrAddr26), .out(BranchResult), .sel(UncondBr));
	
	//multiply by 4
	logic [63:0] MultipliedValue;
	shifter MultiplyFour(.value(BranchResult), .direction(1'b0), .distance(6'd2), .result(MultipliedValue));
	
	
	
	logic [3:0] unused_flags_branch;
	logic [3:0] unused_flags_plus4;
	logic [63:0]branch_result;
	logic [63:0]plus4_result;
	
	//branch adder
	alu addBranch (.A(MultipliedValue), .B(address), .cntrl(3'b010), .result(branch_result), .negative(unused_flags_branch[0]), .zero(unused_flags_branch[1]), .overflow(unused_flags_branch[2]), .carry_out(unused_flags_branch[3]));
	
	//+4 adder
	alu addFour (.A(address), .B(64'd4), .cntrl(3'b010), .result(plus4_result), .negative(unused_flags_plus4[0]), .zero(unused_flags_plus4[1]), .overflow(unused_flags_plus4[2]), .carry_out(unused_flags_plus4[3]));
	
	
	//MuxBranch Taken
	logic [63:0] PC_input;
	Mux_2_1_64Bit BranchTaken(.in0(plus4_result), .in1(branch_result), .out(PC_input), .sel(BrTaken));
	
	//PC
	D_FFx64 PC(.d(PC_input), .q(address), .reset(reset), .clk);


	
	
	
endmodule