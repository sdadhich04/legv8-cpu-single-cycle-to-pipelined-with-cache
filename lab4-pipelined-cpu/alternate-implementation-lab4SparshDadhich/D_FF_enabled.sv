// Submodule for D_FF_64. Acts as an enabled flip flop.
// Takes in d, reset, clk and enable as 1-bit inputs
// Provides a 1-bit q as output.
module D_FF_enabled(q, d, reset, clk, enable);
	
	input logic d, reset, clk, enable;
	output logic q;
	
	logic mux_out;
	
	//and check_enable(q, 1'b1, enable);
	mux_2x1 check_enable(enable, {d,q}, mux_out);
	
	D_FF DFF(.q, .d(mux_out), .reset, .clk);
	
endmodule// D_FF_enabled

module D_FF_enabled_tb();
	
	
	logic q, d;
	logic clock, enable;
	
	D_FF_64 d_ff64(q, d, clock, enable);
	
	parameter clock_period = 100;

	initial begin
			clock <= 0;
			forever #(clock_period /2) clock <= ~clock;
	end
	
	initial begin
		d <= 1; enable <= 1; @(posedge clock);
		d <= 1; enable <= 0; @(posedge clock);
		$stop;
	end

endmodule