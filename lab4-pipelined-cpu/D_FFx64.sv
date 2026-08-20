module D_FFx64(
	input logic [63:0] d,
	output logic [63:0] q,
	input logic reset, clk

);

	genvar i;
	generate
		for(i = 0; i < 64; i = i + 1)begin  : DFF
			D_FF init(.q(q[i]), .d(d[i]), .reset, .clk);
			
			
		end
	endgenerate
endmodule
