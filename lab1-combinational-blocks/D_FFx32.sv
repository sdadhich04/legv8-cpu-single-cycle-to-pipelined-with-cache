module D_FFx32(
	input logic [31:0] d,
	output logic [31:0] q,
	input logic reset, clk

);

	genvar i;
	generate
		for(i = 0; i < 32; i = i + 1)begin  : instantiate
			D_FF init(.q(q[i]), .d(d[i]), .reset, .clk);
			
			
		end
	endgenerate
endmodule
