// Submodule for alu_1bit. Acts as an 8:1 mux.
// Takes in 3-bit sel and an 8-bit mux_in as input.
// Provides 1-bit mux_out_fin as output.
module mux_8x1(sel, mux_in, mux_out_fin);
	input logic [2:0] sel;
	input logic [7:0] mux_in;
	output logic mux_out_fin;
	
	logic mux1_out, mux2_out;
	
	// From least to most significant bit select input
	mux_4x1 mux1(sel[1:0], mux_in[3:0], mux1_out);
	mux_4x1 mux2(sel[1:0], mux_in[7:4], mux2_out);
	mux_2x1 mux3(sel[2], {mux2_out, mux1_out}, mux_out_fin);
	
endmodule