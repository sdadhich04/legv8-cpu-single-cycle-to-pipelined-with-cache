`timescale 1ps/1ps
module Decoder_5_32 (in, out, enable);
	
	
	input logic [4:0] in;
	output logic [31:0] out;
	input logic enable;
	
	
	 generate
        genvar i;
        for(i = 0; i < 32; i = i + 1) begin  : decoderChecker


            assign out[i] = 
                ((in[4] & i[4]) | (~in[4] & ~i[4])) &
                ((in[3] & i[3]) | (~in[3] & ~i[3])) &
                ((in[2] & i[2]) | (~in[2] & ~i[2])) &
                ((in[1] & i[1]) | (~in[1] & ~i[1])) &
                ((in[0] & i[0]) | (~in[0] & ~i[0])); 
        end
    endgenerate
	
endmodule



module decoder_testbench();
	logic clk;
	
	logic [4:0] in;
	logic [31:0] out;
	logic enable;
	logic [5:0]input_val;
	Decoder_5_32 dut(.in, .out, .enable);

	
	
	
	// Clock setup
	parameter clock_period = 100;

	initial begin
		clk = 0;
		forever #(clock_period / 2) clk <= ~clk;	
	end 


	initial begin
		
		enable = 1'b1;

		for (input_val = 0; input_val < 32; input_val = input_val + 1) begin
		  in = input_val;
		  @(posedge clk);
		  $display("Time: %0t | input_val = %0d | out = %b", $time, input_val, out);
		end

		

		$display("done");
		$stop; // <- make the simulation stop completely	
	end
endmodule
