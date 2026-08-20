`timescale 1ps/1ps
//Deturmines which of the two 32x64 to 64 mux recives the RegWrite
module Mux_2_1 (
	input logic in0, in1, 
	input logic sel,
	output logic out
);
	logic a, b;
	logic notSel;
	
	and #50 and1(a, in1, sel);
	
	not #50 not1(notSel, sel);
	
	and #50 and2(b, in0, notSel);
	
	or #50 or1(out, a, b);
	
endmodule