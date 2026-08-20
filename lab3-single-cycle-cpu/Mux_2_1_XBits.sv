`timescale 1ps/1ps
module Mux_2_1_XBits #(parameter WIDTH = 64)(
	input logic[WIDTH-1:0]  in0, in1,
	output logic[WIDTH-1:0]  out,
	input logic sel
);



	genvar i;
	generate
		for(i = 0; i < WIDTH; i = i + 1)begin : Mux_2_1_XBits
			Mux_2_1 mux(.in0(in0[i]), .in1(in1[i]), .sel(sel), .out(out[i]));
			
			
		end
	endgenerate
	
endmodule