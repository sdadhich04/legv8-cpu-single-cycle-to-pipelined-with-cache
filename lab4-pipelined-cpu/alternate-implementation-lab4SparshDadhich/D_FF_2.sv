`timescale 1ns/10ps
//Provides a 2 bit
module D_FF_2#(parameter WIDTH=2) (q, d, reset, clk, enable);

	input logic clk, enable, reset;
	input logic [WIDTH-1:0] d;
	output logic [WIDTH-1:0] q;
	
	initial assert(WIDTH>0);
	
	genvar i;
	
	generate
		for(i=0; i<WIDTH; i++) begin : eachDff
			D_FF_enabled dff (.q(q[i]), .d(d[i]), .reset, .clk, .enable);
		end
	endgenerate
endmodule // D_FF_4