// Submodule for regfile module. Acts as a 64-bit register.
// Takes in 1-bit clk, enable, reset and a 64-bit "d" as input.
// Provides a 64-bit q as output.
module D_FF_64#(parameter WIDTH=64) (q, d, reset, clk, enable);

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
	
endmodule

module D_FF_64_tb();

	logic [63:0] q, d;
	logic clock, enable;
	
	D_FF_64 d_ff64(q, d, clock, enable);
	
	parameter clock_period = 100;

	initial begin
			clock <= 0;
			forever #(clock_period /2) clock <= ~clock;
	end
	
	initial begin
		d <= 32; enable = 1; @(posedge clock);
		d <= 32; enable = 0; @(posedge clock);
		d <= 5; repeat(5)@(posedge clock);
		d <= 5; enable = 1;@(posedge clock);
		@(posedge clock);
		$stop;
	end
	

endmodule