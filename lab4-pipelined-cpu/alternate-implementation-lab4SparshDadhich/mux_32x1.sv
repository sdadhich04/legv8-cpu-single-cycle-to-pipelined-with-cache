// Sumbodule for the regfile module. Acts as a 32:1 mux.
// Takes in a 5-bit sel and 32-bit mux_in as inputs. Provides a 1-bit mux_out_fin
`timescale 1ns/10ps
module mux_32x1(sel, mux_in, mux_out_fin);
	input logic [4:0] sel;
	input logic [31:0] mux_in;
	output logic mux_out_fin;
	
	logic mux1_out, mux2_out;
	
	// From least to most significant bit select input
	mux_16x1 mux1(sel[3:0], mux_in[15:0], mux1_out);
	mux_16x1 mux2(sel[3:0], mux_in[31:16], mux2_out);
	mux_2x1 mux3(sel[4], {mux2_out, mux1_out}, mux_out_fin);
	
endmodule // mux_32x1

module mux_32x1_tb();
	logic [4:0] sel;
	logic [31:0] mux_in;
	logic clock, mux_out;
	integer inc_sel, inc_mux_in;

	mux_32x1 dut(sel, mux_in, mux_out);

	
	parameter clock_period = 100;

	initial begin
			clock <= 0;
			forever #(clock_period /2) clock <= ~clock;
	end
	
	initial begin
		//Test sequence for an and gate truth table
		for(inc_sel=0; inc_sel<32; inc_sel++) begin
           //{sel[1], sel[0], mux_in[3], mux_in[2], mux_in[1], mux_in[0]} = inc_sel; @(posedge clock);
			  sel = inc_sel;
			  for(inc_mux_in=0; inc_mux_in<50; inc_mux_in++) begin
					mux_in = inc_mux_in; @(posedge clock);
			  end
		end
		$stop;
	end
endmodule