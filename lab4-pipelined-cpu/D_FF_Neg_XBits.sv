module D_FF_Neg_XBits #(WIDTH = 64)(
	input logic [WIDTH-1:0] d,
	output logic [WIDTH-1:0] q,
	input logic reset, clk

);

	genvar i;
	generate
		for(i = 0; i < WIDTH; i = i + 1)begin  : DFF
			D_FF_NegEdge init(.q(q[i]), .d(d[i]), .reset, .clk);
			
			
		end
	endgenerate
endmodule
