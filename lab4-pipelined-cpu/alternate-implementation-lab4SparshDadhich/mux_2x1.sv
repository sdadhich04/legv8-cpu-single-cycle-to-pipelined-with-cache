// Submodule for ALU, mux_8x1 and mux_4x1. Acts a 2:1 mux.
// Takes in 1-bit sel and a 2-bit mux_in. Provides a 1-bit mux_out.
`timescale 1ns/10ps
module mux_2x1(sel, mux_in, mux_out);
	input sel;
	input [1:0] mux_in;
	output mux_out;
	
	logic and1_out, and2_out, sel_not;
	not #50 not_sel(sel_not, sel);
	
	// from least to most significant bit select, mux_input 1, mux_input 0
	and #50 and1(and1_out, mux_in[0], sel_not);
	and #50 and2(and2_out, mux_in[1], sel);
	or #50 and1_and2(mux_out, and1_out, and2_out);
	
endmodule// mux_2x1

module mux_2x1_tb();
	logic [1:0] mux_input;
	logic select, clock, mux_output;

	mux_2x1 dut(select, mux_input, mux_output);
	
	parameter clock_period = 100;

	initial begin
			clock <= 0;
			forever #(clock_period /2) clock <= ~clock;
	end
	
	initial begin
			//Test sequence for an and gate truth table
			select <= 0; mux_input <= 2'b00; @(posedge clock);
			select <= 0; mux_input <= 2'b01; @(posedge clock);
			select <= 0; mux_input <= 2'b10; @(posedge clock);
			select <= 0; mux_input <= 2'b11; @(posedge clock);
			select <= 1; mux_input <= 2'b00; @(posedge clock);
			select <= 1; mux_input <= 2'b01; @(posedge clock);
			select <= 1; mux_input <= 2'b10; @(posedge clock);
			select <= 1; mux_input <= 2'b11; @(posedge clock);
			$stop;
	end


endmodule