// Submodule for mux_8x1. Acts as a 4:1 mux.
// Takes in 2-bit sel and 4-bit mux_in as input.
// Provides a 1-bit mux_out_fin
module mux_4x1(sel, mux_in, mux_out_fin);
	input logic [1:0] sel;
	input logic [3:0] mux_in;
	output logic mux_out_fin;
	
	logic mux1_out, mux2_out;
	
	// From least to most significant bit select input
	mux_2x1 mux1(sel[0], mux_in[1:0], mux1_out);
	mux_2x1 mux2(sel[0], mux_in[3:2], mux2_out);
	mux_2x1 mux3(sel[1], {mux2_out, mux1_out}, mux_out_fin);

endmodule

module mux_4x1_tb();
	logic [1:0] sel;
	logic [3:0] mux_in;
	logic clock, mux_out;
	integer inc_sel, inc_mux_in;

	mux_4x1 dut(sel, mux_in, mux_out);

	
	parameter clock_period = 100;

	initial begin
			clock <= 0;
			forever #(clock_period /2) clock <= ~clock;
	end
	
	initial begin
		//Test sequence for an and gate truth table
		for(inc_sel=0; inc_sel<4; inc_sel++) begin
           //{sel[1], sel[0], mux_in[3], mux_in[2], mux_in[1], mux_in[0]} = inc_sel; @(posedge clock);
			  {sel[1], sel[0]} = inc_sel;
			  for(inc_mux_in=0; inc_mux_in<16; inc_mux_in++) begin
					{mux_in[3], mux_in[2], mux_in[1], mux_in[0]} = inc_mux_in; @(posedge clock);
			  end
		end
		$stop;
	end


endmodule