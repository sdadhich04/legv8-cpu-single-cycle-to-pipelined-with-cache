// Submodule for alu. Provides 6 different operations for regular output,
// subtraction, addition, logic AND, logic OR and logic XOR. 
// Takes in 3-bit sel, 1-bit bus_a, bus_b
// and carry_in as inputs. Provides 1-bit alu_out and carry_out as outputs.
`timescale 1ns/10ps
module alu_1bit(sel, bus_a, bus_b, carry_in, carry_out, alu_out);
	input logic [2:0] sel;
	input logic bus_a, bus_b, carry_in;
	output logic alu_out, carry_out;
	
	// x acts as GND for unused 8:1 mux operations 
	logic x;
	assign x = 'x;
	
	logic sum, not_bus_b, bus_b_muxed;
	logic and_out, or_out, xor_out;
	
	// Creats an adder and subtractor logic of an ALU
	not #50 not1(not_bus_b, bus_b);
	mux_2x1 mux2x1(sel[0],{not_bus_b,bus_b}, bus_b_muxed);
	fullAdder fa({bus_a, bus_b_muxed}, carry_in, carry_out, sum);
	
	and #50 and1(and_out, bus_a, bus_b);
	or #50 or1(or_out, bus_a, bus_b);
	xor #50 xor1(xor_out, bus_a, bus_b);
	
	//mux sequence operation
	//  sel   output
	//  000 	 B
	//  010 	 A + B
	//  011 	 A - B
	//  100 	 A and B
	//  101 	 A or B
	//  110 	 A xor B
	mux_8x1 mux8x1(sel, { x, xor_out, or_out, and_out, sum, sum, x, bus_b}, alu_out);
	
endmodule

module ALU_tb();
	logic [2:0] sel;
	logic bus_a, bus_b, carry_in,carry_out, alu_out, clock;

	ALU dut(sel, bus_a, bus_b, carry_in, carry_out, alu_out);
	
	parameter clock_period = 100;

	initial begin
			clock <= 0;
			forever #(clock_period /2) clock <= ~clock;
	end
	
	initial begin
			//Test sequence for addition //010
			bus_a <= 0; bus_b <=0; carry_in <=0; sel<=3'b010;@(posedge clock);
			bus_a <= 0; bus_b <=1; carry_in <=0; sel<=3'b010;@(posedge clock);
			bus_a <= 1; bus_b <=0; carry_in <=0; sel<=3'b010;@(posedge clock);
			bus_a <= 1; bus_b <=1; carry_in <=0; sel<=3'b010;@(posedge clock);
			
			//Test sequence for subtraction //011
			bus_a <= 0; bus_b <=0; carry_in <=1; sel<=3'b011;@(posedge clock);
			bus_a <= 0; bus_b <=1; carry_in <=1; sel<=3'b011;@(posedge clock);
			bus_a <= 1; bus_b <=0; carry_in <=1; sel<=3'b011;@(posedge clock);
			bus_a <= 1; bus_b <=1; carry_in <=1; sel<=3'b011;@(posedge clock);
			$stop;
	end
endmodule