`timescale 1ns/10ps
module mux_16x1(sel, mux_in, mux_out_fin);
	input logic [3:0] sel;
	input logic [15:0] mux_in;
	output logic mux_out_fin;
	
	logic mux1_out, mux2_out;
	
	// From least to most significant bit select input
	mux_8x1 mux1(sel[2:0], mux_in[7:0], mux1_out);
	mux_8x1 mux2(sel[2:0], mux_in[15:8], mux2_out);
	mux_2x1 mux3(sel[3], {mux2_out, mux1_out}, mux_out_fin);
	
endmodule

module mux_16x1_tb();
	logic [1:0] sel;
	logic [3:0] mux_in;
	logic clock, mux_out;
	integer i;

	mux_4x1 dut(sel, mux_in, mux_out);

	
	parameter clock_period = 100;

	initial begin
			clock <= 0;
			forever #(clock_period /2) clock <= ~clock;
	end
	
	initial begin
		//Test sequence for an and gate truth table
		for(i=0; i<1048576; i++) begin
           {sel[1], sel[0], mux_in[3], mux_in[2], mux_in[1], mux_in[0]} = i; @(posedge clock);
		end
		$stop;
	end


endmodule