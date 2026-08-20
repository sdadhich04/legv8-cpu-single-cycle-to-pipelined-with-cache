`timescale 1ns/10ps
// Submodule for the decoder_5x32. Acts a single 3:8 decoder.
// Takes in 3-bit dec_in and 1-bit enable. Provides an 8-bit output dec_out.
module decoder_3x8( dec_in, enable, dec_out);

	input logic [2:0] dec_in;
	input logic enable;
	output logic [7:0] dec_out;
	
	logic out0, out1, out2, out3, out4, out5, out6, out7;
	logic dec_in2, dec_in1, dec_in0;
	logic dec_not2, dec_not1, dec_not0;
	
	not #50 not_dec2(dec_not2, dec_in[2]);
	not #50 not_dec1(dec_not1, dec_in[1]);
	not #50 not_dec0(dec_not0, dec_in[0]);
	
	// Sequence of a decoder  
	and_gate_4 dec_0(dec_not2, dec_not1, dec_not0, enable, out0);
	and_gate_4 dec_1(dec_not2, dec_not1, dec_in[0], enable, out1);
	and_gate_4 dec_2(dec_not2, dec_in[1], dec_not0, enable, out2);
	and_gate_4 dec_3(dec_not2, dec_in[1], dec_in[0], enable, out3);
	and_gate_4 dec_4(dec_in[2], dec_not1, dec_not0, enable, out4);
	and_gate_4 dec_5(dec_in[2], dec_not1, dec_in[0], enable, out5);
	and_gate_4 dec_6(dec_in[2], dec_in[1], dec_not0, enable, out6);
	and_gate_4 dec_7(dec_in[2], dec_in[1], dec_in[0], enable, out7);
	
	assign dec_out = {out7,out6,out5,out4,out3,out2,out1,out0};

endmodule//decoder_3x8

module decoder_3x8_tb();
	logic [2:0] in;
	logic enable, clock;
	logic [7:0] dec_out;

	decoder_3x8 dut(in, enable, dec_out);
	
	parameter clock_period = 100;

	initial begin
			clock <= 0;
			forever #(clock_period /2) clock <= ~clock;
	end
	
	initial begin
			//Test sequence for an and gate truth table
			in[2] <= 0; in[1] <= 0; in[0] <= 0; enable <= 1; @(posedge clock); // dec_out = 00000001
			in[2] <= 0; in[1] <= 0; in[0] <= 1; enable <= 1; @(posedge clock); // dec_out = 00000010
			in[2] <= 0; in[1] <= 1; in[0] <= 0; enable <= 1; @(posedge clock); // dec_out = 00000100
			in[2] <= 0; in[1] <= 1; in[0] <= 1; enable <= 1; @(posedge clock); // dec_out = 00001000
			in[2] <= 1; in[1] <= 0; in[0] <= 0; enable <= 1; @(posedge clock); // dec_out = 00010000
			in[2] <= 1; in[1] <= 0; in[0] <= 1; enable <= 1; @(posedge clock); // dec_out = 00100000
			in[2] <= 1; in[1] <= 1; in[0] <= 0; enable <= 1; @(posedge clock); // dec_out = 01000000
			in[2] <= 1; in[1] <= 1; in[0] <= 1; enable <= 1; @(posedge clock); // dec_out = 10000000
			$stop;
	end
endmodule