`timescale 1ns/10ps
// Submodule for decoder_3x8. Acts as logic gates for a decoder.
// Takes in 1-bit a, b, c and enable as input. Outputs a 1-bit andOut.
module and_gate_4( a, b, c, enable, andOut);
	
	input logic a, b, c, enable;
	output logic andOut;
	
	and #50 and_1 (andOut, a, b, c, enable);
	
	
endmodule// and_gate_4


module and_gate_4_tb();
	logic A, B, C, E, andOut, clock, enable;

	and_gate_4 dut(A, B, C, enable, andOut);
	
	parameter clock_period = 100;

	initial begin
			clock <= 0;
			forever #(clock_period /2) clock <= ~clock;
	end
	
	initial begin
			//Test sequence for an and gate truth table
			A <= 0; B <= 0; C <= 0; E <= 0; @(posedge clock); // andOut = 0
			A <= 0; B <= 0; C <= 1; E <= 0;@(posedge clock);  // andOut = 0
			A <= 0; B <= 1; C <= 0; E <= 0;@(posedge clock);  // andOut = 0
			A <= 0; B <= 1; C <= 1; E <= 0;@(posedge clock);  // andOut = 0
			A <= 1; B <= 0; C <= 0; E <= 0;@(posedge clock); // andOut = 0
			A <= 1; B <= 0; C <= 1; E <= 0;@(posedge clock);  // andOut = 0
			A <= 1; B <= 1; C <= 0; E <= 0;@(posedge clock);  // andOut = 0
			A <= 1; B <= 1; C <= 1; E <= 0;@(posedge clock);  // andOut = 0
			
			A <= 0; B <= 0; C <= 0; E <= 1; @(posedge clock); // andOut = 0
			A <= 0; B <= 0; C <= 1; E <= 1;@(posedge clock);  // andOut = 0
			A <= 0; B <= 1; C <= 0; E <= 1;@(posedge clock);  // andOut = 0
			A <= 0; B <= 1; C <= 1; E <= 1;@(posedge clock);  // andOut = 0
			A <= 1; B <= 0; C <= 0; E <= 1;@(posedge clock); // andOut = 0
			A <= 1; B <= 0; C <= 1; E <= 1;@(posedge clock);  // andOut = 0
			A <= 1; B <= 1; C <= 0; E <= 1;@(posedge clock);  // andOut = 0
			A <= 1; B <= 1; C <= 1; E <= 1;@(posedge clock);  // andOut = 1
			$stop;
	end
endmodule