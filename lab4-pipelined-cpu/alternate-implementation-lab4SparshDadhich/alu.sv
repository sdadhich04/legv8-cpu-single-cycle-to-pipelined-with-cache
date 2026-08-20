//Top level module that preforms 64-bit ALU operations. Takes in 
// 64-bit A, B, and 3-bit cntrl as inputs. Provides a 64-bit result
// 1-bit zero, overflow, carry_out and negative as output.
`timescale 1ns/10ps
module alu(A, B, cntrl, result, negative, zero, overflow, carry_out);
	input logic [63:0] A, B;
	input logic [2:0] cntrl;
	output logic [63:0] result;
	output logic zero, overflow, carry_out, negative;
	
	logic [63:0] carryout;
	logic [63:0] or_value;
	
	assign carry_out = carryout[63];
	assign negative = result[63];
	
	xor #50 xor1(overflow, carryout[63], carryout[62]);
	not #50 not1(zero, or_value[63]);
	
	//Generates a 64-bit alu and or gate logic to check for zero values
	genvar adder_i, or_i;
	alu_1bit alu1(cntrl, A[0], B[0], cntrl[0], carryout[0], result[0]);
	or #50 or1(or_value[0], result[1], result[0]);
	
	generate
		for(adder_i=1; adder_i<64; adder_i++) begin : eachAdder
			alu_1bit alu2(cntrl, A[adder_i], B[adder_i], carryout[adder_i - 1], carryout[adder_i], result[adder_i]);
		end
		
		for(or_i=1;or_i<64;or_i++) begin : eachOr
			or #50 or1(or_value[or_i], result[or_i], or_value[or_i-1]);
		end
	endgenerate
	
	
endmodule//ALU_64

// Previous testbench. Use alustim testbench for actual testing.
module ALU_64_tb();
	logic [2:0] cntrl;
	logic [63:0] A, B, result;
	logic zero, overflow, carry_out, negative, clock;

	alu dut(A, B, cntrl, result, negative, zero, overflow, carry_out);
	
	parameter clock_period = 100;

	initial begin
			clock <= 0;
			forever #(clock_period /2) clock <= ~clock;
	end
	
	initial begin
			// Checks random operations
			A <= 8'b00000000; B <= 8'b00000000; cntrl<=3'b011; @(posedge clock);
			A <= 8'b10100110; B <= 8'b00010111; cntrl<=3'b011; @(posedge clock);
			A <= 1'b1; B <= 8'b00010111; cntrl<=3'b011; @(posedge clock);
			A <= 1'b1; B <= 8'b00010111; cntrl<=3'b100; @(posedge clock);
			A <= 1'b1; B <= 8'b00010111; cntrl<=3'b101; @(posedge clock);
			A <= 1'b1; B <= 8'b00010111; cntrl<=3'b110; @(posedge clock);
			A <= ~'0; B <= 8'b00010111; cntrl<=3'b110; @(posedge clock);
			A <= ~'0; B <= 8'b1; cntrl<=3'b010; @(posedge clock);
			// Check for overflow
			A <= 64'b0111111111111111111111111111111111111111111111111111111111111111; B <= 8'b1; cntrl<=3'b010; @(posedge clock);

			@(posedge clock);
			$stop;
	end
endmodule