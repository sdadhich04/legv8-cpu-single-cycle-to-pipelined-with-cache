//Sub module for ALU. Takes in 2-bit bus_in and 1-bit carry_in as inputs.
//Provides a 1-bit carry_out and sum as outputs.
`timescale 1ns/10ps
module fullAdder (bus_in, carry_in, carry_out, sum);
	input logic [1:0] bus_in;
	input logic carry_in;
	output logic carry_out;
	output logic sum;
	
	logic xor1_out, xor2_out;
	logic and1_out, and2_out;
	
	xor #50 xor1(xor1_out, bus_in[1], bus_in[0]);
	xor #50 xor2(sum, xor1_out, carry_in);
	
	and #50 and1(and1_out, xor1_out, carry_in);
	and #50 and2(and2_out, bus_in[1], bus_in[0]);
	or #50 and3(carry_out, and1_out, and2_out);
	
	
	
endmodule//fullAdder

module fullAdder_tb();
	logic [1:0] bus_in;
	logic carry_in, carry_out, sum, clock;

	fullAdder full1(bus_in, carry_in, carry_out, sum);
	
	parameter clock_period = 100;

	initial begin
			clock <= 0;
			forever #(clock_period /2) clock <= ~clock;
	end
	
	initial begin
			//Test sequence for an and gate truth table
			bus_in <= 2'b00; carry_in <=0; @(posedge clock);
			bus_in <= 2'b00; carry_in <=1; @(posedge clock);
			bus_in <= 2'b01; carry_in <=0; @(posedge clock);
			bus_in <= 2'b01; carry_in <=1; @(posedge clock);
			bus_in <= 2'b10; carry_in <=0; @(posedge clock);
			bus_in <= 2'b10; carry_in <=1; @(posedge clock);
			bus_in <= 2'b11; carry_in <=0; @(posedge clock);
			bus_in <= 2'b11; carry_in <=1; @(posedge clock);
			$stop;
	end
endmodule